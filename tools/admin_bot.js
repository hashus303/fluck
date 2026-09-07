#!/usr/bin/env node
/**
 * Flock — Telegram admin botu (profesyonel sürüm).
 *
 * OTOMATİK:
 *  - Yeni doğrulama → foto + [Onayla] [Reddet(sebepli)]
 *  - Yeni şikayet   → kart + [Uyar] [Kilitle] [Yoksay]
 *  - Yeni üye       → anlık "🆕 yeni üye" bildirimi
 *  - Her sabah 09:00 (TR) → günlük özet
 *  - Firestore'a ulaşılamazsa → uyarı alarmı
 *
 * KOMUTLAR (Telegram "/" menüsünde de görünür):
 *  /bekleyenler          bekleyen TÜM doğrulamalar (foto + butonlar)
 *  /kullanici <isim|uid> tek ekranda kişi kartı + aksiyon butonları
 *  /onayla <isim|uid>    doğrula   ·  /reddet <isim|uid>  reddet
 *  /yenidendogrula <..>  kişiyi tekrar selfie'ye zorla
 *  /sikayetler           bekleyen şikayetler
 *  /flocklar             aktif flock'lar
 *  /liste                tüm profiller + durum
 *  /foto <..>            kişinin fotoğrafları
 *  /istatistik           büyüme sayıları
 *  /ozet                 günlük özeti şimdi gönder
 *  /duyuru <mesaj>       tüm kullanıcılara uygulama-içi duyuru (onaylı)
 *  /durum                özet sayılar   ·  /yardim  komut listesi
 *
 * Kurulum: node admin_bot.js <BOT_TOKEN> → /start <kod>. Sonra: node admin_bot.js
 * Sunucuda (VM): TELEGRAM_BOT_TOKEN, ADMIN_CHAT_ID, GOOGLE_APPLICATION_CREDENTIALS.
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
const POLL_FIRESTORE_MS = 25_000;
const DIGEST_HOUR_TR = 9; // her sabah 09:00 (TR = UTC+3)

let cfg = {};
try { cfg = JSON.parse(fs.readFileSync(CFG_PATH, 'utf8')); } catch (_) {}
const saveCfg = () => fs.writeFileSync(CFG_PATH, JSON.stringify(cfg, null, 2));

// ---------- yardımcılar ----------
const val = (f) => f ? (f.stringValue ?? f.integerValue ?? f.booleanValue ?? null) : null;
const arrLen = (f) => (f && f.arrayValue && f.arrayValue.values) ? f.arrayValue.values.length : 0;
const esc = (s) => String(s == null ? '' : s).replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
// TR saati (UTC+3, DST yok) — tarihi +3s kaydırıp UTC getter'larıyla oku.
const trNow = () => new Date(Date.now() + 3 * 3600 * 1000);
const trDateStr = () => trNow().toISOString().slice(0, 10);
const trHour = () => trNow().getUTCHours();

// ---------- Firebase erişim jetonu ----------
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
    if (!_gauth) {
      const { GoogleAuth } = require('google-auth-library');
      _gauth = new GoogleAuth({ keyFile: SA_KEY, scopes: [
        'https://www.googleapis.com/auth/datastore',
        'https://www.googleapis.com/auth/firebase.messaging',
      ] });
    }
    const client = await _gauth.getClient();
    const t = await client.getAccessToken();
    fbTok = t.token;
    fbTokExp = Date.now() + 55 * 60 * 1000;
    return fbTok;
  }
  const res = await fetch('https://oauth2.googleapis.com/token', {
    method: 'POST',
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    body: new URLSearchParams({
      grant_type: 'refresh_token', refresh_token: refreshTokenFromConfigstore(),
      client_id: CLIENT_ID, client_secret: CLIENT_SECRET,
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
    headers: { Authorization: `Bearer ${await fbToken()}`, 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);
  return res.json();
}

async function runQuery(structuredQuery) {
  const rows = await fb(`${BASE}:runQuery`, { method: 'POST', body: JSON.stringify({ structuredQuery }) });
  return rows.filter((r) => r.document).map((r) => ({ id: r.document.name.split('/').pop(), f: r.document.fields || {} }));
}

/// Belgenin TAM yolunu da döndürür. Koleksiyon-grubu sorgularında gerekli:
/// mesajın hangi sohbete ait olduğu yalnızca yoldan anlaşılır.
async function runQueryFull(structuredQuery) {
  const rows = await fb(`${BASE}:runQuery`, { method: 'POST', body: JSON.stringify({ structuredQuery }) });
  return rows.filter((r) => r.document)
    .map((r) => ({ name: r.document.name, id: r.document.name.split('/').pop(), f: r.document.fields || {} }));
}

const tsVal = (f) => (f && f.timestampValue) ? f.timestampValue : null;
const gtTime = (fieldPath, iso) =>
  ({ fieldFilter: { field: { fieldPath }, op: 'GREATER_THAN', value: { timestampValue: iso } } });
const ascBy = (fieldPath) => [{ field: { fieldPath }, direction: 'ASCENDING' }];

const eqStr = (fieldPath, value) => ({ fieldFilter: { field: { fieldPath }, op: 'EQUAL', value: { stringValue: value } } });

async function pendingUsers(limit = 50) {
  return runQuery({ from: [{ collectionId: 'users' }], where: eqStr('verificationStatus', 'pending'), limit });
}
async function activeFlocks(limit = 50) {
  return runQuery({
    from: [{ collectionId: 'flocks' }],
    where: { fieldFilter: { field: { fieldPath: 'expiresAt' }, op: 'GREATER_THAN', value: { timestampValue: new Date().toISOString() } } },
    limit,
  });
}
async function countFlocksFor(uid) {
  const rows = await runQuery({
    from: [{ collectionId: 'flocks' }],
    where: { fieldFilter: { field: { fieldPath: 'memberUids' }, op: 'ARRAY_CONTAINS', value: { stringValue: uid } } },
    limit: 100,
  });
  return rows.length;
}
async function countReportsFor(uid) {
  const rows = await runQuery({ from: [{ collectionId: 'reports' }], where: eqStr('reportedUid', uid), limit: 100 });
  return rows.length;
}
async function allUsers() {
  const r = await fb(`${BASE}/users?pageSize=300`);
  return (r.documents || []).map((d) => ({ id: d.name.split('/').pop(), f: d.fields || {} }));
}
async function getUser(uid) {
  try { const u = await fb(`${BASE}/users/${uid}`); return { id: uid, f: u.fields || {} }; } catch (_) { return null; }
}
async function findUsers(q) {
  const users = await allUsers();
  const ql = q.toLowerCase();
  let m = users.filter((u) => u.id.toLowerCase() === ql);
  if (!m.length) m = users.filter((u) =>
    (val(u.f.name) || '').toLowerCase().includes(ql) || (val(u.f.email) || '').toLowerCase().includes(ql));
  return m;
}

// ---------- durum değiştirme + denetim izi ----------
async function writeNotification(uid, fields) {
  await fb(`${BASE}/users/${uid}/notifications`, { method: 'POST', body: JSON.stringify({ fields }) });
}
async function adminLog(action, target, extra = {}) {
  try {
    const fields = {
      action: { stringValue: action },
      target: { stringValue: String(target || '') },
      admin: { stringValue: String(cfg.adminChatId || '') },
      at: { timestampValue: new Date().toISOString() },
    };
    if (extra.reason) fields.reason = { stringValue: extra.reason };
    await fb(`${BASE}/admin_log`, { method: 'POST', body: JSON.stringify({ fields }) });
  } catch (e) { console.error('[log]', e.message); }
}
/// verified / rejected. reason yalnızca rejected için anlamlı.
async function setStatus(uid, status, reason) {
  await fb(`${BASE}/users/${uid}?updateMask.fieldPaths=verificationStatus`, {
    method: 'PATCH', body: JSON.stringify({ fields: { verificationStatus: { stringValue: status } } }),
  });
  const notif = {
    type: { stringValue: 'verification' },
    status: { stringValue: status === 'verified' ? 'approved' : 'rejected' },
    read: { booleanValue: false },
    createdAt: { timestampValue: new Date().toISOString() },
  };
  if (reason) notif.reason = { stringValue: reason };
  await writeNotification(uid, notif);
  cfg.seenVerif = (cfg.seenVerif || []).filter((x) => x !== uid);
  saveCfg();
  await adminLog(status === 'verified' ? 'approve' : 'reject', uid, { reason });
  const ptitle = status === 'verified' ? 'Profilin doğrulandı 🎉' : 'Doğrulama sonucu';
  const pbody = status === 'verified'
    ? 'Artık Flock\'a giriş yapabilirsin.'
    : 'Selfie doğrulanamadı — tekrar dene.' + (reason ? ` (${reason})` : '');
  try { await sendPush(uid, ptitle, pbody, 'verification'); } catch (_) {}
}
/// Kişiyi tekrar 'pending' yapar (yeniden selfie).
async function setPending(uid) {
  await fb(`${BASE}/users/${uid}?updateMask.fieldPaths=verificationStatus`, {
    method: 'PATCH', body: JSON.stringify({ fields: { verificationStatus: { stringValue: 'pending' } } }),
  });
  cfg.seenVerif = (cfg.seenVerif || []).filter((x) => x !== uid);
  saveCfg();
  await adminLog('re-verify', uid);
}

// ---------- FCM push ----------
async function pushDocFor(uid) {
  try {
    const d = await fb(`${BASE}/users/${uid}/private/push`);
    const f = d.fields || {};
    const arr = f.tokens && f.tokens.arrayValue && f.tokens.arrayValue.values;
    // Tercih alanı yoksa AÇIK say — eski kullanıcılar sessize düşmesin.
    const pref = (k) => (f[k] && typeof f[k].booleanValue === 'boolean') ? f[k].booleanValue : true;
    return {
      tokens: (arr || []).map((v) => v.stringValue).filter(Boolean),
      prefs: {
        join: pref('notifJoins'),
        announcement: pref('notifAnnouncements'),
        verification: pref('notifVerification'),
        message: pref('notifMessages'),
      },
    };
  } catch (_) {
    return { tokens: [], prefs: { join: true, announcement: true, verification: true, message: true } };
  }
}
async function pushTokensFor(uid) {
  return (await pushDocFor(uid)).tokens;
}
async function removePushToken(uid, tok) {
  try {
    const left = (await pushTokensFor(uid)).filter((x) => x !== tok);
    await fb(`${BASE}/users/${uid}/private/push?updateMask.fieldPaths=tokens`, {
      method: 'PATCH',
      body: JSON.stringify({ fields: { tokens: { arrayValue: { values: left.map((x) => ({ stringValue: x })) } } } }),
    });
  } catch (_) {}
}
/// Kullanıcının tüm cihazlarına push. Sessiz — token yoksa/başarısızsa akışı bozmaz.
///
/// `type` kullanıcının bildirim tercihine karşı denetlenir ('join' |
/// 'announcement' | 'verification'). Kapalıysa hiç gönderilmez — ayarın
/// uygulamada bir anlamı olsun. Ayrıca istemci aynı türü ön planda da eler.
async function sendPush(uid, title, body, type, extraData = {}) {
  let tokens = [], prefs = null;
  try { const d = await pushDocFor(uid); tokens = d.tokens; prefs = d.prefs; } catch (_) {}
  if (type && prefs && prefs[type] === false) return 0;
  if (!tokens.length) return 0;
  let bearer;
  try { bearer = await fbToken(); } catch (_) { return 0; }
  let ok = 0;
  for (const t of tokens) {
    try {
      const res = await fetch(`https://fcm.googleapis.com/v1/projects/${PROJECT}/messages:send`, {
        method: 'POST',
        headers: { Authorization: `Bearer ${bearer}`, 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: { token: t, notification: { title, body }, data: { ...(type ? { type } : {}), ...extraData }, android: { priority: 'HIGH' } } }),
      });
      if (res.ok) { ok++; }
      else {
        const txt = await res.text().catch(() => '');
        if (res.status === 404 || res.status === 400) await removePushToken(uid, t); // geçersiz token temizle
        console.error('[fcm]', res.status, txt.slice(0, 140));
      }
    } catch (e) { console.error('[fcm]', e.message); }
  }
  return ok;
}

// ---------- Telegram ----------
const TG = (m) => `https://api.telegram.org/bot${cfg.token}/${m}`;
async function tg(method, payload) {
  const res = await fetch(TG(method), { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(payload) });
  const j = await res.json().catch(() => ({}));
  if (!j.ok) console.error(`[tg] ${method} hata:`, j.description || res.status);
  return j;
}
async function tgMsg(text, extra = {}) { return tg('sendMessage', { chat_id: cfg.adminChatId, text, ...extra }); }
async function tgHtml(text, extra = {}) { return tgMsg(text, { parse_mode: 'HTML', disable_web_page_preview: true, ...extra }); }
async function tgPhoto(b64, caption, keyboard) {
  const form = new FormData();
  form.append('chat_id', String(cfg.adminChatId));
  form.append('photo', new Blob([Buffer.from(b64, 'base64')], { type: 'image/jpeg' }), 'photo.jpg');
  form.append('caption', (caption || '').slice(0, 1000));
  if (keyboard) form.append('reply_markup', JSON.stringify(keyboard));
  const res = await fetch(TG('sendPhoto'), { method: 'POST', body: form });
  const j = await res.json().catch(() => ({}));
  if (!j.ok) console.error('[tg] sendPhoto hata:', j.description || res.status);
  return j;
}

const REASON_TR = { harassment: 'Taciz / rahatsız etme', fake: 'Sahte profil', no_show: 'Gelmedi', safety: 'Güvenlik endişesi', other: 'Diğer' };
const REJ = { blur: 'Fotoğraf net değil', noface: 'Yüz görünmüyor', pose: 'İstenen hareket yapılmamış', fake: 'Uygunsuz / sahte', other: 'Doğrulanamadı' };
const STICON = { pending: '🕵️', verified: '✅', rejected: '❌', none: '⚪' };

// ---------- foto arşivi ----------
const VERIF_DIR = path.join(__dirname, '..', 'verifications');
function saveB64(file, b64) { fs.mkdirSync(path.dirname(file), { recursive: true }); fs.writeFileSync(file, Buffer.from(b64, 'base64')); }
function archiveVerification(uid, selfieB64, profileB64) {
  try {
    const dir = path.join(VERIF_DIR, uid);
    if (selfieB64) saveB64(path.join(dir, `selfie-${Date.now()}.jpg`), selfieB64);
    if (profileB64) saveB64(path.join(dir, 'profile.jpg'), profileB64);
  } catch (e) { console.error('[arşiv]', e.message); }
}
function archivedPhotos(uid) {
  const dir = path.join(VERIF_DIR, uid);
  if (!fs.existsSync(dir)) return {};
  const files = fs.readdirSync(dir);
  const selfies = files.filter((f) => f.startsWith('selfie-')).sort();
  return { selfie: selfies.length ? path.join(dir, selfies[selfies.length - 1]) : null, profile: files.includes('profile.jpg') ? path.join(dir, 'profile.jpg') : null };
}
const fileToB64 = (p) => fs.readFileSync(p).toString('base64');

async function selfieOf(uid) {
  try { const v = await fb(`${BASE}/users/${uid}/private/verification`); return val((v.fields || {}).selfieB64); } catch (_) { return null; }
}
async function sendUserPhotos(uid, name) {
  const label = name || uid; const arch = archivedPhotos(uid); let sent = false;
  if (arch.profile) { await tgPhoto(fileToB64(arch.profile), `Profil — ${label}`); sent = true; }
  else { const u = await getUser(uid); const p = u && val(u.f.photoB64); if (p) { await tgPhoto(p, `Profil — ${label}`); sent = true; } }
  if (arch.selfie) { await tgPhoto(fileToB64(arch.selfie), `Selfie — ${label}`); sent = true; }
  else { const s = await selfieOf(uid); if (s) { await tgPhoto(s, `Selfie — ${label}`); sent = true; } }
  return sent;
}

// ---------- kartlar ----------
const verifyKeyboard = (uid) => ({ inline_keyboard: [[
  { text: '✅ Onayla', callback_data: `approve:${uid}` },
  { text: '❌ Reddet', callback_data: `reject:${uid}` },
  { text: '📷 Profil', callback_data: `profil:${uid}` },
]] });

/// private/verification'dan selfie + (varsa) konum/ip meta verisi.
async function verificationMeta(uid) {
  try {
    const v = await fb(`${BASE}/users/${uid}/private/verification`);
    const f = v.fields || {};
    return { selfie: val(f.selfieB64), lat: val(f.lat), lng: val(f.lng), city: val(f.city), ip: val(f.ip) };
  } catch (_) { return {}; }
}

/// TEK kart: selfie + tüm bilgiler + butonlar. Profil foto tek tıkla ([📷 Profil]).
async function sendPendingCard(u) {
  const meta = await verificationMeta(u.id);
  const photo = val(u.f.photoB64);
  archiveVerification(u.id, meta.selfie, photo);
  const locLine = (meta.city || meta.lat) ? `📍 ${meta.city || ''}${meta.lat ? ` (${meta.lat}, ${meta.lng})` : ''}\n` : '';
  const ipLine = meta.ip ? `🌐 ${meta.ip}\n` : '';
  const caption = `🕵️ Doğrulama bekliyor\n` +
    `${val(u.f.name) || '(adsız)'} · ${val(u.f.age) || '?'}${val(u.f.email) ? ' · ' + val(u.f.email) : ''}\n` +
    locLine + ipLine + `uid: ${u.id}`;
  if (meta.selfie) await tgPhoto(meta.selfie, caption, verifyKeyboard(u.id));
  else if (photo) await tgPhoto(photo, caption + '\n(selfie yok — profil foto)', verifyKeyboard(u.id));
  else await tgMsg(caption + '\n(fotoğraf yok)', { reply_markup: verifyKeyboard(u.id) });
}

async function sendReportCard(r) {
  const reportedUid = val(r.f.reportedUid);
  let reported = reportedUid, reporter = val(r.f.reporterUid);
  const ru = await getUser(reportedUid); if (ru) reported = `${val(ru.f.name) || '(adsız)'} (${val(ru.f.email) || reportedUid})`;
  const pu = await getUser(reporter); if (pu) reporter = val(pu.f.name) || '(adsız)';
  const text = `🚩 <b>Şikayet:</b> ${esc(REASON_TR[val(r.f.reason)] || val(r.f.reason))}\n` +
    `Şikayet edilen: ${esc(reported)}\nŞikayet eden: ${esc(reporter)}\n` +
    (val(r.f.note) ? `Not: “${esc(val(r.f.note))}”\n` : '') + (val(r.f.flockId) ? `Flock: ${esc(val(r.f.flockId))}` : '');
  await tgHtml(text, { reply_markup: { inline_keyboard: [[
    { text: '⚠️ Uyar', callback_data: `warn:${reportedUid}` },
    { text: '🔒 Kilitle', callback_data: `reject:${reportedUid}` },
    { text: '✔️ Yoksay', callback_data: `ignore:${r.id}` },
  ]] } });
}

async function sendUserCard(u) {
  const uid = u.id, name = val(u.f.name) || '(adsız)', st = val(u.f.verificationStatus) || 'none';
  let flocks = 0, reports = 0;
  try { flocks = await countFlocksFor(uid); } catch (_) {}
  try { reports = await countReportsFor(uid); } catch (_) {}
  const interests = (u.f.interests && u.f.interests.arrayValue && u.f.interests.arrayValue.values || [])
    .map((v) => v.stringValue).filter(Boolean).join(', ');
  const text = `${STICON[st] || '⚪'} <b>${esc(name)}</b> · ${val(u.f.age) || '?'}\n` +
    `${esc(val(u.f.email) || '')}\n` +
    `Durum: <b>${st}</b> · Onboarding: ${val(u.f.onboardingComplete) ? 'bitti' : 'yarım'}\n` +
    `Katıldığı flock: ${flocks} · Aldığı şikayet: ${reports}\n` +
    (interests ? `İlgi: ${esc(interests)}\n` : '') + `<code>${esc(uid)}</code>`;
  await tgHtml(text, { reply_markup: { inline_keyboard: [
    [{ text: '✅ Onayla', callback_data: `approve:${uid}` }, { text: '❌ Reddet', callback_data: `reject:${uid}` }],
    [{ text: '📷 Fotoğraflar', callback_data: `photos:${uid}` }, { text: '🔄 Yeniden doğrulat', callback_data: `repend:${uid}` }],
  ] } });
}

// ---------- otomatik izleyiciler ----------
cfg.seenVerif = cfg.seenVerif || [];
cfg.seenReports = cfg.seenReports || [];
cfg.newSinceDigest = cfg.newSinceDigest || 0;

async function checkPendingVerifications() {
  const rows = await pendingUsers(50);
  for (const u of rows) {
    if (cfg.seenVerif.includes(u.id)) continue;
    await sendPendingCard(u); cfg.seenVerif.push(u.id); saveCfg();
  }
}
/// Şikayetler — su işaretiyle. Eskiden her turda en yeni 30 şikayet
/// çekiliyordu (25 sn'de 30 okuma = günde ~104 bin); artık sakin turda boş.
async function checkReports() {
  const first = !cfg.reportWatermark;
  const since = cfg.reportWatermark || new Date(0).toISOString();
  const rows = await runQuery({
    from: [{ collectionId: 'reports' }],
    where: gtTime('createdAt', since),
    orderBy: ascBy('createdAt'),
    limit: 30,
  });
  for (const r of rows) {
    if (!cfg.seenReports.includes(r.id)) {
      await sendReportCard(r);
      cfg.seenReports.push(r.id);
      if (cfg.seenReports.length > 500) cfg.seenReports = cfg.seenReports.slice(-500);
    }
    cfg.reportWatermark = tsVal(r.f.createdAt) || cfg.reportWatermark;
  }
  if (first || rows.length) saveCfg();
}
/// Yeni üyeler — SU İŞARETİYLE.
///
/// MALİYET: eskiden her turda `allUsers()` çağrılıyordu; `pageSize=300` ile
/// 25 saniyede bir 300 belge = günde ~1 milyon okuma. Artık yalnızca
/// `updatedAt` su işaretinden yeni olanlar çekiliyor: sakin turda sorgu boş
/// döner (Firestore boş sonucu 1 okuma sayar).
///
/// `updatedAt` profil düzenlemesinde de değişir; ayırt etmeyi `seenUsers`
/// yapıyor (zaten yapıyordu). `createdAt` alanı şemada yok, eklemek için
/// istemci tarafında kayıt/düzenleme ayrımı gerekirdi.
async function checkNewSignups() {
  const first = !cfg.userWatermark;
  const since = cfg.userWatermark || new Date().toISOString();
  const rows = await runQuery({
    from: [{ collectionId: 'users' }],
    where: gtTime('updatedAt', since),
    orderBy: ascBy('updatedAt'),
    limit: 20,
  });
  if (rows.length) {
    cfg.userWatermark = tsVal(rows[rows.length - 1].f.updatedAt) || since;
  } else if (first) {
    cfg.userWatermark = since;
  }
  if (first) { saveCfg(); return; } // ilk çalıştırma: yalnızca tohumla, ping yok
  cfg.seenUsers = cfg.seenUsers || [];
  for (const u of rows) {
    if (cfg.seenUsers.includes(u.id)) continue;
    cfg.seenUsers.push(u.id);
    if (cfg.seenUsers.length > 500) cfg.seenUsers = cfg.seenUsers.slice(-500);
    cfg.newSinceDigest = (cfg.newSinceDigest || 0) + 1;
    // pending ise ayrı ping atma — doğrulama kartı zaten geliyor (çift mesaj olmasın).
    if ((val(u.f.verificationStatus) || 'none') === 'pending') continue;
    await tgHtml(`🆕 <b>Yeni üye:</b> ${esc(val(u.f.name) || '(adsız)')} · ${val(u.f.age) || '?'}\n` +
      `${esc(val(u.f.email) || '')}\nDurum: ${val(u.f.verificationStatus) || 'none'}`);
  }
  saveCfg();
}

// ---------- yeni mesaj → push ----------
//
// NEDEN BURADA: Cloud Functions bu projede hiç açılmamış; tek bir tetikleyici
// için Blaze + Cloud Build + Artifact Registry açmak yeni bir maliyet yüzeyi
// demekti. Bot zaten 7/24 dönüyor ve servis hesabı elinde.
//
// MALİYET: tur başına TEK koleksiyon-grubu sorgusu; sakin turda boş döner
// (1 okuma). Mesaj başına ek okuma yalnızca alıcının push belgesi — sohbet
// bilgisi ve gönderenin adı bellekte önbelleklenir.

/// Bot kapalıyken biriken eski mesajları açılışta yağdırmayalım.
const MSG_MAX_AGE_MS = 10 * 60 * 1000;

/// Sohbet belgesi önbelleği. Okuduğumuz alanlar (tür, üyeler, flockId)
/// sohbetin ömrü boyunca DEĞİŞMEZ, o yüzden süresiz tutulabilir.
const _threadCache = new Map();
async function threadInfo(threadId) {
  const hit = _threadCache.get(threadId);
  if (hit) return hit;
  try {
    const d = await fb(`${BASE}/threads/${threadId}`);
    const f = d.fields || {};
    const info = {
      kind: val(f.kind) || 'dm',
      flockId: val(f.flockId) || '',
      members: ((f.memberUids && f.memberUids.arrayValue && f.memberUids.arrayValue.values) || [])
        .map((v) => v.stringValue).filter(Boolean),
    };
    if (_threadCache.size > 500) _threadCache.clear();
    _threadCache.set(threadId, info);
    return info;
  } catch (_) { return null; }
}

const _nameCache = new Map();
async function displayName(uid) {
  const hit = _nameCache.get(uid);
  if (hit && Date.now() - hit.t < 10 * 60_000) return hit.v;
  const u = await getUser(uid);
  const v = (u && val(u.f.name)) || 'Biri';
  if (_nameCache.size > 500) _nameCache.clear();
  _nameCache.set(uid, { v, t: Date.now() });
  return v;
}

/// Flock sohbetinde alıcılar CANLI üyelikten gelir; sonradan katılan da
/// bildirim alsın, ayrılan almasın. Kısa ömürlü önbellek: flock en fazla
/// 2 saat yaşıyor, 60 sn bayatlık zararsız.
const _flockCache = new Map();
async function flockInfo(flockId) {
  const hit = _flockCache.get(flockId);
  if (hit && Date.now() - hit.t < 60_000) return hit.v;
  try {
    const d = await fb(`${BASE}/flocks/${flockId}`);
    const f = d.fields || {};
    const v = {
      venue: val(f.venue) || 'Flock',
      members: ((f.memberUids && f.memberUids.arrayValue && f.memberUids.arrayValue.values) || [])
        .map((x) => x.stringValue).filter(Boolean),
    };
    _flockCache.set(flockId, { v, t: Date.now() });
    return v;
  } catch (_) { return null; }
}

const clip = (s, n) => (s.length > n ? `${s.slice(0, n - 1)}…` : s);

async function checkNewMessages() {
  const first = !cfg.msgWatermark;
  const since = cfg.msgWatermark || new Date().toISOString();
  if (first) { cfg.msgWatermark = since; saveCfg(); return; } // ilk tur: tohumla

  const rows = await runQueryFull({
    from: [{ collectionId: 'messages', allDescendants: true }],
    where: gtTime('at', since),
    orderBy: ascBy('at'),
    limit: 30,
  });
  if (!rows.length) return;

  cfg.msgSeen = cfg.msgSeen || [];
  for (const m of rows) {
    const at = tsVal(m.f.at);
    if (at) cfg.msgWatermark = at;
    if (cfg.msgSeen.includes(m.name)) continue;
    cfg.msgSeen.push(m.name);
    if (cfg.msgSeen.length > 100) cfg.msgSeen = cfg.msgSeen.slice(-100);

    // Bot bir süre kapalı kaldıysa geçmişi bildirime çevirme.
    if (at && Date.now() - Date.parse(at) > MSG_MAX_AGE_MS) continue;

    const from = val(m.f.from);
    const text = val(m.f.text) || '';
    // .../documents/threads/{threadId}/messages/{msgId}
    const parts = m.name.split('/');
    const threadId = parts[parts.length - 3];
    if (!from || !threadId) continue;

    const th = await threadInfo(threadId);
    if (!th) continue;

    let recipients = [];
    let title = '';
    let body = clip(text, 120);
    if (th.kind === 'flock') {
      const fl = await flockInfo(th.flockId);
      if (!fl) continue;
      recipients = fl.members.filter((u) => u !== from);
      title = fl.venue;
      body = `${await displayName(from)}: ${clip(text, 110)}`;
    } else {
      recipients = th.members.filter((u) => u !== from);
      title = await displayName(from);
    }

    for (const uid of recipients) {
      try { await sendPush(uid, title, body, 'message', { threadId }); } catch (_) {}
    }
  }
  saveCfg();
}

// ---------- özet & istatistik ----------
async function digestText() {
  const users = await allUsers();
  const total = users.length;
  const verified = users.filter((u) => val(u.f.verificationStatus) === 'verified').length;
  const pending = users.filter((u) => val(u.f.verificationStatus) === 'pending').length;
  const flocks = await activeFlocks(300);
  const reports = await runQuery({ from: [{ collectionId: 'reports' }], limit: 300 });
  const pct = total ? Math.round((verified / total) * 100) : 0;
  return `📅 <b>Günlük özet</b> — ${trDateStr().slice(8)}.${trDateStr().slice(5, 7)}\n\n` +
    `🆕 Yeni üye (dünden beri): <b>${cfg.newSinceDigest || 0}</b>\n` +
    `🕵️ Bekleyen doğrulama: <b>${pending}</b>${pending ? '  → /bekleyenler' : ''}\n` +
    `🚩 Toplam şikayet: <b>${reports.length}</b>\n` +
    `👥 Toplam profil: <b>${total}</b>  (✅ ${verified} · %${pct} doğrulanmış)\n` +
    `🎉 Aktif flock: <b>${flocks.length}</b>`;
}
async function sendDigest() { await tgHtml(await digestText()); cfg.newSinceDigest = 0; saveCfg(); }

async function statusSummary() {
  const pending = await pendingUsers(300);
  const flocks = await activeFlocks(300);
  const reports = await runQuery({ from: [{ collectionId: 'reports' }], limit: 300 });
  const names = pending.map((u) => `• ${val(u.f.name) || '(adsız)'}`).join('\n');
  return `📊 Flock durum\nBekleyen doğrulama: ${pending.length}${pending.length ? '\n' + names : ''}\n` +
    `Aktif flock: ${flocks.length}\nToplam şikayet: ${reports.length}\n\nButonlarla görmek için: /bekleyenler`;
}

// ---------- duyuru (broadcast) ----------
async function broadcast(text) {
  const users = await allUsers(); let ok = 0;
  for (const u of users) {
    try {
      await writeNotification(u.id, {
        type: { stringValue: 'announcement' }, text: { stringValue: text },
        read: { booleanValue: false }, createdAt: { timestampValue: new Date().toISOString() },
      });
      try { await sendPush(u.id, '📣 Duyuru', text, 'announcement'); } catch (_) {}
      ok++;
    } catch (_) {}
  }
  await adminLog('broadcast', `${ok} kişi`, { reason: text.slice(0, 100) });
  return ok;
}

const COMMANDS = [
  ['bekleyenler', 'Bekleyen doğrulamalar'], ['kullanici', 'Kişi kartı: /kullanici <isim|uid>'],
  ['onayla', 'Doğrula: /onayla <isim|uid>'], ['reddet', 'Reddet: /reddet <isim|uid>'],
  ['yenidendogrula', 'Tekrar selfie iste'], ['sikayetler', 'Bekleyen şikayetler'],
  ['flocklar', 'Aktif flock’lar'], ['liste', 'Tüm profiller'], ['foto', 'Fotoğraflar: /foto <..>'],
  ['istatistik', 'Büyüme sayıları'], ['ozet', 'Günlük özeti gönder'], ['duyuru', 'Herkese duyuru'],
  ['durum', 'Özet sayılar'], ['yardim', 'Komut listesi'],
];
const HELP = '🪶 <b>Flock admin botu</b>\n\n' + COMMANDS.map(([c, d]) => `/${c} — ${esc(d)}`).join('\n');

// ---------- komut yönlendirici ----------
async function handleCommand(text) {
  const lower = text.toLowerCase();
  const arg = (n) => text.slice(n).trim();

  if (lower === '/yardim' || lower === '/help' || lower === '/start') return tgHtml(HELP);
  if (lower === '/durum') { try { return tgMsg(await statusSummary()); } catch (e) { return tgMsg(`Hata: ${e.message}`); } }
  if (lower === '/istatistik' || lower === '/ozet') { try { return tgHtml(await digestText()).then(() => { if (lower === '/ozet') { cfg.newSinceDigest = 0; saveCfg(); } }); } catch (e) { return tgMsg(`Hata: ${e.message}`); } }

  if (lower === '/bekleyenler' || lower === '/pending') {
    try { const rows = await pendingUsers(50); if (!rows.length) return tgMsg('✅ Bekleyen doğrulama yok.'); await tgMsg(`🕵️ ${rows.length} bekleyen doğrulama:`); for (const u of rows) await sendPendingCard(u); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); } return;
  }
  if (lower === '/sikayetler' || lower === '/sikayet') {
    try { const rows = await runQuery({ from: [{ collectionId: 'reports' }], orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }], limit: 20 }); if (!rows.length) return tgMsg('✅ Bekleyen şikayet yok.'); await tgMsg(`🚩 Son ${rows.length} şikayet:`); for (const r of rows) await sendReportCard(r); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); } return;
  }
  if (lower === '/flocklar') {
    try {
      const rows = await activeFlocks(50); if (!rows.length) return tgMsg('Aktif flock yok.');
      const lines = [];
      for (const f of rows) {
        const host = await getUser(val(f.f.hostUid));
        const venue = val(f.f.venueName) || val(f.f.venue) || val(f.f.place) || '(mekan)';
        const joined = arrLen(f.f.memberUids); const total = val(f.f.total) || joined;
        lines.push(`🎉 ${esc(venue)} · ${joined}/${total}\n  host: ${esc(host ? (val(host.f.name) || '?') : '?')}`);
      }
      return tgHtml(`Aktif flock (${rows.length}):\n\n` + lines.join('\n'));
    } catch (e) { return tgMsg(`Hata: ${e.message}`); }
  }
  if (lower === '/liste') {
    try {
      const users = await allUsers(); if (!users.length) return tgMsg('Kullanıcı yok.');
      const order = { pending: 0, rejected: 1, none: 2, verified: 3 };
      const sorted = [...users].sort((a, b) => (order[val(a.f.verificationStatus) || 'none'] ?? 9) - (order[val(b.f.verificationStatus) || 'none'] ?? 9));
      const lines = sorted.slice(0, 60).map((u) => { const st = val(u.f.verificationStatus) || 'none'; return `${STICON[st] || '⚪'} ${val(u.f.name) || '(adsız)'} · ${st}\n  ${val(u.f.email) || ''}\n  ${u.id}`; });
      return tgMsg(`👥 ${users.length} kullanıcı:\n\n` + lines.join('\n'));
    } catch (e) { return tgMsg(`Hata: ${e.message}`); }
  }

  if (lower.startsWith('/kullanici')) {
    const q = arg(10); if (!q) return tgMsg('Kullanım: /kullanici <isim, e-posta ya da uid>');
    try { const m = await findUsers(q); if (!m.length) return tgMsg('Eşleşme yok.'); if (m.length > 1) return tgMsg('Birden fazla eşleşme, uid ile dene:\n' + m.slice(0, 8).map((u) => `• ${val(u.f.name) || '(adsız)'} — ${u.id}`).join('\n')); await sendUserCard(m[0]); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); } return;
  }
  if (lower.startsWith('/onayla') || lower.startsWith('/reddet')) {
    const approve = lower.startsWith('/onayla'); const q = arg(7);
    if (!q) return tgMsg(`Kullanım: ${approve ? '/onayla' : '/reddet'} <isim|uid>`);
    try { const m = await findUsers(q); if (!m.length) return tgMsg('Eşleşme yok.'); if (m.length > 1) return tgMsg('Birden fazla eşleşme, uid ile dene:\n' + m.slice(0, 8).map((u) => `• ${val(u.f.name) || '(adsız)'} — ${u.id}`).join('\n')); const u = m[0]; await setStatus(u.id, approve ? 'verified' : 'rejected', approve ? undefined : REJ.other); return tgMsg(`${val(u.f.name) || u.id} → ${approve ? 'verified ✅' : 'rejected ❌'}`); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); }
  }
  if (lower.startsWith('/yenidendogrula')) {
    const q = arg(15); if (!q) return tgMsg('Kullanım: /yenidendogrula <isim|uid>');
    try { const m = await findUsers(q); if (!m.length) return tgMsg('Eşleşme yok.'); if (m.length > 1) return tgMsg('uid ile dene:\n' + m.slice(0, 8).map((u) => `• ${val(u.f.name) || '(adsız)'} — ${u.id}`).join('\n')); await setPending(m[0].id); return tgMsg(`${val(m[0].f.name) || m[0].id} → pending 🕵️ (tekrar selfie isteniyor)`); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); }
  }
  if (lower.startsWith('/foto')) {
    const q = arg(5).toLowerCase(); if (!q) return tgMsg('Kullanım: /foto <isim, e-posta ya da uid>');
    try { const matches = await findUsers(q); if (!matches.length) return tgMsg('Eşleşme yok.'); for (const m of matches.slice(0, 3)) { const ok = await sendUserPhotos(m.id, val(m.f.name)); if (!ok) await tgMsg(`${val(m.f.name) || m.id}: fotoğraf yok.`); } if (matches.length > 3) await tgMsg(`(${matches.length} eşleşme, ilk 3 — daha net ara)`); }
    catch (e) { return tgMsg(`Hata: ${e.message}`); } return;
  }
  if (lower.startsWith('/duyuru')) {
    const msg = arg(7); if (!msg) return tgMsg('Kullanım: /duyuru <mesaj>');
    cfg.pendingBroadcast = msg; saveCfg();
    return tgHtml(`📣 <b>Duyuru önizleme:</b>\n\n${esc(msg)}\n\n<i>Tüm kullanıcılara uygulama-içi bildirim gider.</i>`, { reply_markup: { inline_keyboard: [[{ text: '✅ Gönder', callback_data: 'bcast_send' }, { text: '❌ İptal', callback_data: 'bcast_cancel' }]] } });
  }
  if (lower.startsWith('/')) return tgMsg('Bilinmeyen komut. /yardim');
}

// ---------- callback (butonlar) ----------
async function handleCallback(query) {
  const data = query.data || '';
  const ack = (text) => tg('answerCallbackQuery', { callback_query_id: query.id, text });
  const clearKb = () => tg('editMessageReplyMarkup', { chat_id: query.message.chat.id, message_id: query.message.message_id, reply_markup: { inline_keyboard: [] } });

  const [action, a1, a2] = data.split(':');

  if (action === 'approve' && a1) {
    try { await setStatus(a1, 'verified'); await ack('Onaylandı ✅'); await clearKb(); await tgMsg(`${a1} → verified ✅`); } catch (e) { await ack(`Hata: ${e.message}`.slice(0, 190)); }
    return;
  }
  if (action === 'reject' && a1) { // sebep menüsü göster
    await ack('Sebep seç');
    await tg('editMessageReplyMarkup', { chat_id: query.message.chat.id, message_id: query.message.message_id, reply_markup: { inline_keyboard: [
      [{ text: '📷 Net değil', callback_data: `rej:${a1}:blur` }, { text: '🙈 Yüz yok', callback_data: `rej:${a1}:noface` }],
      [{ text: '🙂 Hareket yok', callback_data: `rej:${a1}:pose` }, { text: '🚫 Uygunsuz', callback_data: `rej:${a1}:fake` }],
      [{ text: 'Diğer', callback_data: `rej:${a1}:other` }, { text: '↩️ Vazgeç', callback_data: `rejcancel:${a1}` }],
    ] } });
    return;
  }
  if (action === 'rej' && a1) {
    try { await setStatus(a1, 'rejected', REJ[a2] || REJ.other); await ack('Reddedildi ❌'); await clearKb(); await tgMsg(`${a1} → rejected ❌ (${REJ[a2] || REJ.other})`); } catch (e) { await ack(`Hata: ${e.message}`.slice(0, 190)); }
    return;
  }
  if (action === 'rejcancel' && a1) { await ack('Geri'); await tg('editMessageReplyMarkup', { chat_id: query.message.chat.id, message_id: query.message.message_id, reply_markup: verifyKeyboard(a1) }); return; }
  if (action === 'warn' && a1) {
    try { const wtext = 'Bir şikayet nedeniyle uyarıldın. Lütfen topluluk kurallarına dikkat et.'; await writeNotification(a1, { type: { stringValue: 'warning' }, text: { stringValue: wtext }, read: { booleanValue: false }, createdAt: { timestampValue: new Date().toISOString() } }); await adminLog('warn', a1); try { await sendPush(a1, '⚠️ Uyarı', wtext); } catch (_) {} await ack('Uyarı gönderildi ⚠️'); await clearKb(); await tgMsg(`${a1} → uyarıldı ⚠️`); } catch (e) { await ack(`Hata: ${e.message}`.slice(0, 190)); }
    return;
  }
  if (action === 'ignore' && a1) { await adminLog('report-ignore', a1); await ack('Yoksayıldı'); await clearKb(); return; }
  if (action === 'photos' && a1) { await ack('Fotoğraflar geliyor'); try { const u = await getUser(a1); const ok = await sendUserPhotos(a1, u && val(u.f.name)); if (!ok) await tgMsg('Fotoğraf yok.'); } catch (e) { await tgMsg(`Hata: ${e.message}`); } return; }
  if (action === 'profil' && a1) { await ack('Profil'); try { const u = await getUser(a1); const p = u && val(u.f.photoB64); if (p) await tgPhoto(p, `Profil — ${(u && val(u.f.name)) || ''}`); else { const arch = archivedPhotos(a1); if (arch.profile) await tgPhoto(fileToB64(arch.profile), 'Profil'); else await tgMsg('Profil fotoğrafı yok.'); } } catch (e) { await tgMsg(`Hata: ${e.message}`); } return; }
  if (action === 'repend' && a1) { try { await setPending(a1); await ack('Tekrar selfie istendi 🔄'); await tgMsg(`${a1} → pending 🕵️`); } catch (e) { await ack(`Hata: ${e.message}`.slice(0, 190)); } return; }
  if (action === 'bcast_send') { await ack('Gönderiliyor…'); const msg = cfg.pendingBroadcast; delete cfg.pendingBroadcast; saveCfg(); if (!msg) return tgMsg('Duyuru bulunamadı.'); try { const n = await broadcast(msg); await clearKb(); await tgMsg(`📣 Duyuru ${n} kullanıcıya gönderildi.`); } catch (e) { await tgMsg(`Hata: ${e.message}`); } return; }
  if (action === 'bcast_cancel') { delete cfg.pendingBroadcast; saveCfg(); await ack('İptal'); await clearKb(); return; }
}

// ---------- döngüler ----------
let tgOffset = 0;
async function pollTelegramOnce() {
  const j = await tg('getUpdates', { timeout: 50, offset: tgOffset });
  for (const up of j.result || []) {
    tgOffset = up.update_id + 1;
    if (up.message) {
      const chatId = up.message.chat.id; const text = (up.message.text || '').trim();
      if (!cfg.adminChatId) {
        if (text === `/start ${cfg.pairCode}`) { cfg.adminChatId = chatId; delete cfg.pairCode; saveCfg(); await tg('sendMessage', { chat_id: chatId, text: '🪶 Eşleşti!', parse_mode: 'HTML' }); await tgHtml(HELP); console.log(`Eşleşti — adminChatId: ${chatId}`); }
        continue;
      }
      if (chatId !== cfg.adminChatId) continue;
      try { await handleCommand(text); } catch (e) { console.error('[cmd]', e.message); }
    }
    if (up.callback_query) {
      if (up.callback_query.message?.chat?.id !== cfg.adminChatId) continue;
      try { await handleCallback(up.callback_query); } catch (e) { console.error('[cb]', e.message); }
    }
  }
}

let fsErrs = 0, fsAlerted = false;
async function fsTick() {
  try {
    await checkPendingVerifications(); await checkReports(); await checkNewSignups();
    await checkNewMessages();
    if (fsAlerted) { await tgMsg('✅ Bağlantı düzeldi, bot normale döndü.'); fsAlerted = false; }
    fsErrs = 0;
  } catch (e) {
    fsErrs++; console.error('[fs]', e.message);
    if (fsErrs >= 3 && !fsAlerted) { fsAlerted = true; try { await tgHtml(`⚠️ <b>Bot uyarısı:</b> Firestore'a ulaşılamıyor.\n<code>${esc(e.message).slice(0, 200)}</code>\nDenemeye devam ediyorum.`); } catch (_) {} }
  }
}

// ---------- başlat ----------
(async () => {
  if (process.env.TELEGRAM_BOT_TOKEN) cfg.token = process.env.TELEGRAM_BOT_TOKEN;
  if (process.env.ADMIN_CHAT_ID) cfg.adminChatId = Number(process.env.ADMIN_CHAT_ID);
  const argToken = process.argv[2];
  if (argToken) { cfg.token = argToken; saveCfg(); }
  if (!cfg.token) { console.error('Bot token gerekli.'); process.exit(1); }
  if (!cfg.adminChatId) { cfg.pairCode = crypto.randomInt(100000, 999999).toString(); saveCfg(); console.log(`Eşleştirme: botuna gönder → /start ${cfg.pairCode}`); }
  if (cfg.lastDigest === undefined) { cfg.lastDigest = trDateStr(); saveCfg(); } // ilk kurulum: bugün özeti atma

  await fbToken();
  console.log('Bot çalışıyor.');

  // Telegram "/" komut menüsü
  try { await tg('setMyCommands', { commands: COMMANDS.map(([command, description]) => ({ command, description })) }); } catch (_) {}

  // Açılış mesajı
  if (cfg.adminChatId) {
    try { const n = (await pendingUsers(300)).length; await tgHtml(`🪶 <b>Bot başladı ve çalışıyor.</b>\nBekleyen doğrulama: <b>${n}</b>` + (n ? `  → /bekleyenler` : '') + `\n\nKomutlar: /yardim`); } catch (e) { console.error('[başlangıç]', e.message); }
  }

  (async function tgLoop() { for (;;) { try { await pollTelegramOnce(); } catch (e) { console.error('[tg]', e.message); await new Promise((r) => setTimeout(r, 5000)); } } })();
  (async function fsLoop() { for (;;) { if (cfg.adminChatId) await fsTick(); await new Promise((r) => setTimeout(r, POLL_FIRESTORE_MS)); } })();
  (async function digestLoop() { for (;;) { try { if (cfg.adminChatId && cfg.lastDigest !== trDateStr() && trHour() >= DIGEST_HOUR_TR) { cfg.lastDigest = trDateStr(); saveCfg(); await sendDigest(); } } catch (e) { console.error('[digest]', e.message); } await new Promise((r) => setTimeout(r, 60_000)); } })();
})().catch((e) => { console.error(e.message); process.exit(1); });
