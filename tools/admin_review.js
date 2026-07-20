#!/usr/bin/env node
/**
 * Flock — yerel doğrulama inceleme aracı (yalnızca geliştirici makinesi).
 *
 * Firebase CLI'nin oturumunu (firebase login) kullanır; ekstra anahtar gerekmez.
 * Kullanım:
 *   node admin_review.js            → bekleyenleri listele, review.html üret
 *   node admin_review.js approve <uid>  → kullanıcıyı 'verified' yap
 *   node admin_review.js reject <uid>   → kullanıcıyı 'none' yap (reddet)
 *
 * Not: review.html kişisel fotoğraflar içerir — repoya girmez (.gitignore).
 */
const fs = require('fs');
const os = require('os');
const path = require('path');

const PROJECT = 'fluck-app-fv0kh';
const BASE = `https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents`;

// Firebase CLI'nin herkese açık OAuth istemci sabitleri (firebase-tools kaynağından).
const CLIENT_ID = '563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com';
const CLIENT_SECRET = 'j9iVZfS8kkCEFUPaAeJV0sAi';

function refreshTokenFromConfigstore() {
  const p = path.join(os.homedir(), '.config', 'configstore', 'firebase-tools.json');
  const j = JSON.parse(fs.readFileSync(p, 'utf8'));
  const rt = j.tokens && j.tokens.refresh_token;
  if (!rt) throw new Error('Firebase CLI oturumu yok — önce `firebase login` çalıştır.');
  return rt;
}

async function accessToken() {
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
  if (!res.ok) throw new Error(`Token alınamadı: ${res.status} ${await res.text()}`);
  return (await res.json()).access_token;
}

const val = (f) => f ? (f.stringValue ?? f.integerValue ?? f.booleanValue ?? null) : null;

async function api(token, url, opts = {}) {
  const res = await fetch(url, {
    ...opts,
    headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'application/json', ...(opts.headers || {}) },
  });
  if (!res.ok) throw new Error(`${res.status}: ${await res.text()}`);
  return res.json();
}

async function listPending(token) {
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'users' }],
      where: {
        fieldFilter: {
          field: { fieldPath: 'verificationStatus' },
          op: 'EQUAL',
          value: { stringValue: 'pending' },
        },
      },
      limit: 100,
    },
  };
  const rows = await api(token, `${BASE}:runQuery`, { method: 'POST', body: JSON.stringify(body) });
  const out = [];
  for (const r of rows) {
    if (!r.document) continue;
    const f = r.document.fields || {};
    const uid = r.document.name.split('/').pop();
    let selfieB64 = null, submittedAt = null;
    try {
      const v = await api(token, `${BASE}/users/${uid}/private/verification`);
      selfieB64 = val((v.fields || {}).selfieB64);
      submittedAt = (v.fields || {}).submittedAt?.timestampValue ?? null;
    } catch (_) { /* selfie yüklenmemiş */ }
    out.push({
      uid,
      name: val(f.name) || '(adsız)',
      email: val(f.email) || '',
      age: val(f.age) || '',
      photoB64: val(f.photoB64),
      selfieB64,
      submittedAt,
    });
  }
  return out;
}

async function setStatus(token, uid, status) {
  await api(token,
    `${BASE}/users/${uid}?updateMask.fieldPaths=verificationStatus`,
    { method: 'PATCH', body: JSON.stringify({ fields: { verificationStatus: { stringValue: status } } }) });
  // Kullanıcıya uygulama-içi bildirim düşür (onay/red).
  await api(token, `${BASE}/users/${uid}/notifications`, {
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

async function listReports(token) {
  const body = {
    structuredQuery: {
      from: [{ collectionId: 'reports' }],
      orderBy: [{ field: { fieldPath: 'createdAt' }, direction: 'DESCENDING' }],
      limit: 100,
    },
  };
  const rows = await api(token, `${BASE}:runQuery`, { method: 'POST', body: JSON.stringify(body) });
  const nameCache = {};
  const nameOf = async (uid) => {
    if (!(uid in nameCache)) {
      try {
        const u = await api(token, `${BASE}/users/${uid}`);
        nameCache[uid] = `${val((u.fields || {}).name) || '(adsız)'} <${val((u.fields || {}).email) || ''}>`;
      } catch (_) { nameCache[uid] = '(silinmiş hesap)'; }
    }
    return nameCache[uid];
  };
  const out = [];
  for (const r of rows) {
    if (!r.document) continue;
    const f = r.document.fields || {};
    out.push({
      reporter: await nameOf(val(f.reporterUid)),
      reported: await nameOf(val(f.reportedUid)),
      reportedUid: val(f.reportedUid),
      reason: val(f.reason),
      note: val(f.note) || '',
      flockId: val(f.flockId) || '',
      at: f.createdAt?.timestampValue ?? '',
    });
  }
  return out;
}

const REASON_TR = {
  harassment: 'Taciz / rahatsız etme', fake: 'Sahte profil',
  no_show: 'Gelmedi', safety: 'Güvenlik endişesi', other: 'Diğer',
};

const imgTag = (b64, w) => b64
  ? `<img src="data:image/jpeg;base64,${b64}" style="width:${w}px;border-radius:12px">`
  : `<div style="width:${w}px;height:${w}px;border-radius:12px;background:#333;display:flex;align-items:center;justify-content:center;color:#888">yok</div>`;

function reportsHtml(reports) {
  if (!reports.length) return '<p style="color:#888;font-family:system-ui">Şikayet yok 🎉</p>';
  return reports.map((r) => `
    <div style="background:#241d1d;border-radius:14px;padding:16px;margin:10px 0;color:#eee;font-family:system-ui">
      <b style="color:#ff7a6e">${REASON_TR[r.reason] || r.reason}</b>
      <span style="color:#888;font-size:12px"> · ${r.at}${r.flockId ? ' · flock: ' + r.flockId : ''}</span>
      <p style="margin:8px 0 0;font-size:14px"><b>Şikayet edilen:</b> ${r.reported}<br>
      <b>Şikayet eden:</b> ${r.reporter}</p>
      ${r.note ? `<p style="margin:8px 0 0;font-size:13px;color:#ccc">“${r.note}”</p>` : ''}
      <p style="margin:10px 0 0;font-size:12.5px;color:#888">Hesabı kilitlemek için:
      <code style="background:#111;padding:2px 6px;border-radius:5px">node admin_review.js reject ${r.reportedUid}</code>
      (doğrulamasını düşürür → uygulamaya giremez)</p>
    </div>`).join('\n');
}

function html(list, reportsSection) {
  const cards = list.map((u) => `
    <div style="background:#1d1f24;border-radius:16px;padding:20px;margin:14px 0;color:#eee;font-family:system-ui">
      <h3 style="margin:0 0 4px">${u.name} <span style="color:#888;font-weight:400">· ${u.age} · ${u.email}</span></h3>
      <p style="color:#888;margin:0 0 12px;font-size:13px">uid: ${u.uid}${u.submittedAt ? ' · selfie: ' + u.submittedAt : ''}</p>
      <div style="display:flex;gap:16px">
        <div><p style="margin:0 0 6px;font-size:13px;color:#aaa">Profil fotoğrafı</p>${imgTag(u.photoB64, 200)}</div>
        <div><p style="margin:0 0 6px;font-size:13px;color:#aaa">Doğrulama selfie'si</p>${imgTag(u.selfieB64, 200)}</div>
      </div>
      <p style="margin:14px 0 0;font-size:13px;color:#aaa">Onaylamak için: <code style="background:#111;padding:3px 7px;border-radius:6px">node admin_review.js approve ${u.uid}</code>
      &nbsp;·&nbsp; Reddetmek için: <code style="background:#111;padding:3px 7px;border-radius:6px">node admin_review.js reject ${u.uid}</code></p>
    </div>`).join('\n');
  return `<!doctype html><meta charset="utf-8"><title>Flock — doğrulama incelemesi</title>
  <body style="background:#101114;max-width:760px;margin:30px auto;padding:0 16px">
  <h2 style="color:#eee;font-family:system-ui">Bekleyen doğrulamalar (${list.length})</h2>
  ${cards || '<p style="color:#888;font-family:system-ui">Bekleyen doğrulama yok 🎉</p>'}
  <h2 style="color:#eee;font-family:system-ui;margin-top:34px">Şikayetler</h2>
  ${reportsSection || ''}</body>`;
}

(async () => {
  const [cmd, uid] = process.argv.slice(2);
  const token = await accessToken();
  if (cmd === 'approve' || cmd === 'reject') {
    if (!uid) throw new Error('uid gerekli');
    await setStatus(token, uid, cmd === 'approve' ? 'verified' : 'rejected');
    console.log(`${uid} → ${cmd === 'approve' ? 'verified ✓' : 'reddedildi (kullanıcıya yeni selfie ekranı açılır)'}`);
    return;
  }
  const list = await listPending(token);
  const reports = await listReports(token);
  const out = path.join(__dirname, 'review.html');
  fs.writeFileSync(out, html(list, reportsHtml(reports)));
  console.log(`${list.length} bekleyen doğrulama, ${reports.length} şikayet → ${out}`);
})().catch((e) => { console.error(e.message); process.exit(1); });
