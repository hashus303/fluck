#!/usr/bin/env node
/**
 * Flock — Telegram admin botu (geliştirici makinesinde çalışır).
 *
 * Ne yapar:
 *  - Yeni selfie doğrulaması geldiğinde: fotoğraflı mesaj + [Onayla] [Reddet]
 *  - Yeni şikayet geldiğinde: şikayet kartı + [Hesabı kilitle]
 *  - /durum → bekleyen doğrulama, aktif flock ve şikayet sayıları
 *
 * Kurulum (bir kez):
 *  1) Telegram'da @BotFather → /newbot → token'ı al
 *  2) node admin_bot.js <BOT_TOKEN>
 *  3) Konsolda çıkan eşleştirme kodunu kendi botuna gönder: /start <kod>
 * Sonraki çalıştırmalar: node admin_bot.js
 *
 * Notlar: Firebase erişimi için `firebase login` oturumunu kullanır
 * (admin_review.js ile aynı). Token ve sohbet kimliği bot_config.json'a
 * yazılır — bu dosya gitignore'dadır, repoya girmez.
 */
const fs = require('fs');
const os = require('os');
const path = require('path');
const crypto = require('crypto');

const PROJECT = 'fluck-app-fv0kh';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;
const CLIENT_ID = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';
const CFG_PATH = path.join(__dirname, 'bot_config.json');
const POLL_FIRESTORE_MS = 45_000;

let cfg = {};
try { cfg = JSON.parse(fs.readFileSync(CFG_PATH, 'utf8')); } catch (_) {}
const saveCfg = () => fs.writeFileSync(CFG_PATH, JSON.stringify(cfg, null, 2));

// ---------- Firebase erişim jetonu ----------
// İki yol: (1) SERVICE ACCOUNT KEY — sunucuda (EC2/VDS). GOOGLE_APPLICATION_
// CREDENTIALS ortam değişkeni ya da tools/sa-key.json dosyası varsa kullanılır.
// (2) CLI OTURUMU — yerel geliştirmede (`firebase login`). Anahtar yoksa buna düşer.
const SA_KEY = process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  (fs.existsSync(path.join(__dirname, 'sa-key.json')) ? path.join(__dirname, 'sa-key.json') : null);

let _gauth = null;
function refreshTokenFromConfigstore() {
  const p = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  const j = JSON.parse(fs.readFileSync(p, 'utf8'));
  const rt = j.tokens && j.tokens.refresh_token;
  if (!rt) throw new Error('Firebase CLI oturumu yok — önce `firebase login` çalıştır.');
  return rt;
}

let fbTok = null, fbTokExp = 0;
async function fbToken() {
  if (fbTok && Date.now() < fbTokExp) return fbTok;
  if (SA_KEY) {
    // Service account (sunucu) — google-auth-library ile Firestore jetonu.
    if (!_gauth) {
      const { GoogleAuth } = require('google-auth-library');
      _gauth = new GoogleAuth({
        keyFile: SA_KEY,
        scopes: ['https://www.googleapis.com/auth/datastore'],
      });
    }
    const client = await _gauth.getClient();
    const t = await client.getAccessToken();
    fbTok = t.token;
    fbTokExp = Date.now() + 55 * 60 * 1000; // ~1 saat, erken yenile
    return fbTok;
  }
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'refresh_token',
      refresh_token: refreshTokenFromConfigstore(),
      client_id: CLIENT_ID,
      client_secret: CLIENT_SECRET,
    }),
  });
  if (!res.ok) throw new Error(`Firebase token alınamadı: ${res.status}`);
  const j = await res.json();
  fbTok = j.access_token;
  fbTokExp = Date.now() + ((j.expires_in || 3600) - 60) * 1000;
  return fbTok;
}

async function fb(url, opts = {}) {
  const res = await fetch(url, {
    ...opts,
    headers: {
      Authorization: `Bearer ${await fbToken()}`,
      'Content-Type': 'application/json',
      ...(opts.headers || {}),
    },
  });
  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);
  return res.json();
}

const val = (f) => f ? (f.stringValue ?? f.integerValue ?? f.booleanValue ?? null) : null;

async function runQuery(structuredQuery) {
  const rows = await fb(`${BASE}:runQuery`, {
    method: 'POST',
    body: JSON.stringify({ structuredQuery }),
  });
  return rows.filter((r) => r.document).map((r) => ({
    id: r.document.name.split('/').pop(),
    f: r.document.fields || {},
  }));
}

/// Doğrulama sonucunu işler + kullanıcıya uygulama-içi bildirim yazar.
async function setStatus(uid, status) {
  await fb(`${BASE}/users/${uid}?updateMask.fieldPaths=verificationStatus`, {
    method: 'PATCH',
    body: JSON.stringify({ fields: { verificationStatus: { stringValue: status } } }),
  });
  await fb(`${BASE}/users/${uid}/notifications`, {
    method: 'POST',
    body: JSON.stringify({
      fields: {
        type: { stringValue: 'verification' },
        status: { stringValue: status === 'verified' ? 'approved' : 'rejected' },
        read: { booleanValue: false },
        createdAt: { timestampValue: new Date().toISOString() },
      },
    }),
  });
}

// ---------- Telegram ----------
const TG = (m) => `https://api.telegram.org/bot${cfg.token}/${m}`;

async function tg(method, payload) {
  const res = await fetch(TG(method), {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
  const j = await res.json().catch(() => ({}));
  if (!j.ok) console.error(`[tg] ${method} hata:`, j.description || res.status);
  return j;
}

async function tgPhoto(b64, caption, keyboard) {
  const form = new FormData();
  form.append('chat_id', String(cfg.adminChatId));
  form.append('photo', new Blob([Buffer.from(b64, 'base64')], { type: 'image/jpeg' }), 'photo.jpg');
  form.append('caption', caption.slice(0, 1000));
  if (keyboard) form.append('reply_markup', JSON.stringify(keyboard));
  const res = await fetch(TG('sendPhoto'), { method: 'POST', body: form });
  const j = await res.json().catch(() => ({}));
  if (!j.ok) console.error('[tg] sendPhoto hata:', j.description || res.status);
  return j;
}

const REASON_TR = {
  harassment: 'Taciz / rahatsız etme', fake: 'Sahte profil',
  no_show: 'Gelmedi', safety: 'Güvenlik endişesi', other: 'Diğer',
};

// ---------- Doğrulama fotoğrafı arşivi (sunucu diski) ----------
// Selfie'ler ve profil fotoğrafları burada kalıcı tutulur; Firestore'a ek
// olarak SENİN sunucunda da durur, /foto ile geçmişe bakılabilir.
const VERIF_DIR = path.join(__dirname, '..', 'verifications');

function saveB64(file, b64) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, Buffer.from(b64, 'base64'));
}

function archiveVerification(uid, selfieB64, profileB64) {
  try {
    const dir = path.join(VERIF_DIR, uid);
    if (selfieB64) saveB64(path.join(dir, `selfie-${Date.now()}.jpg`), selfieB64);
    if (profileB64) saveB64(path.join(dir, 'profile.jpg'), profileB64);
  } catch (e) {
    console.error('[arşiv]', e.message);
  }
}

/// uid klasöründeki en yeni selfie ve profil dosya yolları (yoksa null).
function archivedPhotos(uid) {
  const dir = path.join(VERIF_DIR, uid);
  if (!fs.existsSync(dir)) return {};
  const files = fs.readdirSync(dir);
  const selfies = files.filter((f) => f.startsWith('selfie-')).sort();
  return {
    selfie: selfies.length ? path.join(dir, selfies[selfies.length - 1]) : null,
    profile: files.includes('profile.jpg') ? path.join(dir, 'profile.jpg') : null,
  };
}

const fileToB64 = (p) => fs.readFileSync(p).toString('base64');

// ---------- Firestore izleyicisi ----------
cfg.seenVerif = cfg.seenVerif || [];
cfg.seenReports = cfg.seenReports || [];

async function checkPendingVerifications() {
  const rows = await runQuery({
    from: [{ collectionId: 'users' }],
    where: { fieldFilter: { field: { fieldPath: 'verificationStatus' }, op: 'EQUAL', value: { stringValue: 'pending' } } },
    limit: 50,
  });
  for (const u of rows) {
    if (cfg.seenVerif.includes(u.id)) continue;
    let selfie = null;
    try {
      const v = await fb(`${BASE}/users/${u.id}/private/verification`);
      selfie = val((v.fields || {}).selfieB64);
    } catch (_) {}
    const caption =
      `🕵️ Yeni doğrulama bekliyor\n` +
      `${val(u.f.name) || '(adsız)'} · ${val(u.f.age) || '?'} · ${val(u.f.email) || ''}\n` +
      `uid: ${u.id}`;
    const keyboard = { inline_keyboard: [[
      { text: '✅ Onayla', callback_data: `approve:${u.id}` },
      { text: '❌ Reddet', callback_data: `reject:${u.id}` },
    ]] };
    const photo = val(u.f.photoB64);
    // Fotoğrafları sunucu diskine arşivle (Firestore'a EK olarak, kalıcı).
    archiveVerification(u.id, selfie, photo);
    if (photo) await tgPhoto(photo, `Profil fotoğrafı — ${val(u.f.name) || ''}`);
    if (selfie) await tgPhoto(selfie, caption, keyboard);
    else await tg('sendMessage', { chat_id: cfg.adminChatId, text: caption + '\n(selfie yüklenmemiş)', reply_markup: keyboard });
    cfg.seenVerif.push(u.id);
    saveCfg();
  }
}

async function checkReports() {
  const rows = await runQuery({
    from: [{ collectionId: 'reports' }],
    orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
    limit: 30,
  });
  for (const r of rows.reverse()) {
    if (cfg.seenReports.includes(r.id)) continue;
    const reportedUid = val(r.f.reportedUid);
    let reported = reportedUid, reporter = val(r.f.reporterUid);
    try {
      const u = await fb(`${BASE}/users/${reportedUid}`);
      reported = `${val((u.fields || {}).name) || '(adsız)'} (${val((u.fields || {}).email) || reportedUid})`;
    } catch (_) {}
    try {
      const u = await fb(`${BASE}/users/${reporter}`);
      reporter = `${val((u.fields || {}).name) || '(adsız)'}`;
    } catch (_) {}
    const text =
      `🚩 Yeni şikayet: ${REASON_TR[val(r.f.reason)] || val(r.f.reason)}\n` +
      `Şikayet edilen: ${reported}\n` +
      `Şikayet eden: ${reporter}\n` +
      (val(r.f.note) ? `Not: “${val(r.f.note)}”\n` : '') +
      (val(r.f.flockId) ? `Flock: ${val(r.f.flockId)}` : '');
    await tg('sendMessage', {
      chat_id: cfg.adminChatId,
      text,
      reply_markup: { inline_keyboard: [[
        { text: '🔒 Hesabı kilitle', callback_data: `reject:${reportedUid}` },
      ]] },
    });
    cfg.seenReports.push(r.id);
    saveCfg();
  }
}

async function statusSummary() {
  const pending = await runQuery({
    from: [{ collectionId: 'users' }],
    where: { fieldFilter: { field: { fieldPath: 'verificationStatus' }, op: 'EQUAL', value: { stringValue: 'pending' } } },
    limit: 300,
  });
  const flocks = await runQuery({
    from: [{ collectionId: 'flocks' }],
    where: { fieldFilter: { field: { fieldPath: 'expiresAt' }, op: 'GREATER_THAN', value: { timestampValue: new Date().toISOString() } } },
    limit: 300,
  });
  const reports = await runQuery({
    from: [{ collectionId: 'reports' }],
    limit: 300,
  });
  return `📊 Flock durum\n` +
    `Bekleyen doğrulama: ${pending.length}\n` +
    `Aktif flock: ${flocks.length}\n` +
    `Toplam şikayet: ${reports.length}`;
}

// ---------- Telegram güncelleme döngüsü ----------
let tgOffset = 0;

async function pollTelegramOnce() {
  const j = await tg('getUpdates', { timeout: 50, offset: tgOffset });
  for (const up of j.result || []) {
    tgOffset = up.update_id + 1;
    if (up.message) {
      const chatId = up.message.chat.id;
      const text = (up.message.text || '').trim();
      if (!cfg.adminChatId) {
        // Eşleştirme: yalnızca doğru kodu gönderen sohbet admin olur.
        if (text === `/start ${cfg.pairCode}`) {
          cfg.adminChatId = chatId;
          delete cfg.pairCode;
          saveCfg();
          await tg('sendMessage', { chat_id: chatId, text: '🪶 Eşleşti! Yeni doğrulama ve şikayetler buraya düşecek. Komut: /durum' });
          console.log(`Eşleşti — adminChatId: ${chatId}`);
        }
        continue;
      }
      if (chatId !== cfg.adminChatId) continue; // yalnızca admin
      if (text === '/durum') {
        try { await tg('sendMessage', { chat_id: chatId, text: await statusSummary() }); }
        catch (e) { await tg('sendMessage', { chat_id: chatId, text: `Hata: ${e.message}` }); }
      } else if (text.startsWith('/foto')) {
        // /foto <uid> → o kişinin arşivlenmiş selfie + profil fotoğrafları.
        const uid = text.slice(5).trim();
        if (!uid) { await tg('sendMessage', { chat_id: chatId, text: 'Kullanım: /foto <uid>' }); continue; }
        try {
          const arch = archivedPhotos(uid);
          if (arch.selfie || arch.profile) {
            if (arch.profile) await tgPhoto(fileToB64(arch.profile), `Profil — ${uid}`);
            if (arch.selfie) await tgPhoto(fileToB64(arch.selfie), `Selfie — ${uid}`);
          } else {
            // Arşivde yok (eski kayıt) — Firestore'dan canlı çek.
            let sent = false;
            try {
              const u = await fb(`${BASE}/users/${uid}`);
              const p = val((u.fields || {}).photoB64);
              if (p) { await tgPhoto(p, `Profil — ${uid}`); sent = true; }
            } catch (_) {}
            try {
              const v = await fb(`${BASE}/users/${uid}/private/verification`);
              const s = val((v.fields || {}).selfieB64);
              if (s) { await tgPhoto(s, `Selfie — ${uid}`); sent = true; }
            } catch (_) {}
            if (!sent) await tg('sendMessage', { chat_id: chatId, text: 'Bu uid için fotoğraf bulunamadı.' });
          }
        } catch (e) {
          await tg('sendMessage', { chat_id: chatId, text: `Hata: ${e.message}` });
        }
      }
    }
    if (up.callback_query) {
      const q = up.callback_query;
      if (q.message?.chat?.id !== cfg.adminChatId) continue;
      const [action, uid] = (q.data || '').split(':');
      if ((action === 'approve' || action === 'reject') && uid) {
        try {
          await setStatus(uid, action === 'approve' ? 'verified' : 'rejected');
          await tg('answerCallbackQuery', { callback_query_id: q.id, text: action === 'approve' ? 'Onaylandı ✅' : 'Reddedildi/kilitlendi ❌' });
          await tg('editMessageReplyMarkup', { chat_id: q.message.chat.id, message_id: q.message.message_id, reply_markup: { inline_keyboard: [] } });
          await tg('sendMessage', { chat_id: cfg.adminChatId, text: `${uid} → ${action === 'approve' ? 'verified ✅' : 'rejected ❌'}` });
        } catch (e) {
          await tg('answerCallbackQuery', { callback_query_id: q.id, text: `Hata: ${e.message}`.slice(0, 190) });
        }
      }
    }
  }
}

// ---------- başlat ----------
(async () => {
  // Sunucuda (EC2) yapılandırma ortam değişkeninden gelir; yerelde config'ten.
  if (process.env.TELEGRAM_BOT_TOKEN) cfg.token = process.env.TELEGRAM_BOT_TOKEN;
  if (process.env.ADMIN_CHAT_ID) cfg.adminChatId = Number(process.env.ADMIN_CHAT_ID);
  const argToken = process.argv[2];
  if (argToken) { cfg.token = argToken; saveCfg(); }
  if (!cfg.token) {
    console.error('Bot token gerekli. Ortam: TELEGRAM_BOT_TOKEN, ya da: node admin_bot.js <BOT_TOKEN>');
    process.exit(1);
  }
  if (!cfg.adminChatId) {
    cfg.pairCode = crypto.randomInt(100000, 999999).toString();
    saveCfg();
    console.log(`Eşleştirme: Telegram'da botuna şunu gönder →  /start ${cfg.pairCode}`);
  }
  await fbToken(); // Firebase oturumu çalışıyor mu, erkenden test et
  console.log('Bot çalışıyor. (Ctrl+C ile durdur)');

  // Telegram: uzun sorgu döngüsü; Firestore: periyodik tarama.
  (async function tgLoop() {
    for (;;) {
      try { await pollTelegramOnce(); }
      catch (e) { console.error('[tg]', e.message); await new Promise((r) => setTimeout(r, 5000)); }
    }
  })();
  (async function fsLoop() {
    for (;;) {
      if (cfg.adminChatId) {
        try { await checkPendingVerifications(); await checkReports(); }
        catch (e) { console.error('[fs]', e.message); }
      }
      await new Promise((r) => setTimeout(r, POLL_FIRESTORE_MS));
    }
  })();
})().catch((e) => { console.error(e.message); process.exit(1); });
