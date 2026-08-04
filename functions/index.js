/**
 * Flock — sunucusuz admin botu (Cloud Functions v2).
 *
 *  • onVerificationSubmitted — yeni/yeniden selfie gelince Telegram'a
 *    fotoğraflı bildirim + [Onayla]/[Reddet] butonları.
 *  • onReportCreated — yeni şikayet gelince kart + [Hesabı kilitle].
 *  • telegramWebhook — buton tıklamaları ve /durum komutu.
 *
 * Kimlik: Admin SDK, Functions'ın kendi yetkisiyle çalışır (anahtar dosyası
 * yok). Bot token'ı ve webhook sırrı Secret Manager'da tutulur.
 */
const { onRequest } = require("firebase-functions/v2/https");
const { onDocumentWritten, onDocumentCreated } = require("firebase-functions/v2/firestore");
const { defineSecret } = require("firebase-functions/params");
const { setGlobalOptions } = require("firebase-functions/v2");
const admin = require("firebase-admin");

admin.initializeApp();
const db = admin.firestore();

const BOT_TOKEN = defineSecret("TELEGRAM_BOT_TOKEN");
const WEBHOOK_SECRET = defineSecret("TELEGRAM_WEBHOOK_SECRET");

// Yalnızca bu Telegram sohbeti komut verir / bildirim alır (gizli değil).
const ADMIN_CHAT_ID = 1075679150;

setGlobalOptions({ region: "europe-west1", maxInstances: 5 });

// ---------------------------------------------------------------- Telegram
const url = (token, m) => `https://api.telegram.org/bot${token}/${m}`;

async function tg(token, method, payload) {
  const res = await fetch(url(token, method), {
    method: "POST",
    headers: { "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  return res.json().catch(() => ({}));
}

async function tgPhoto(token, b64, caption, keyboard) {
  const form = new FormData();
  form.append("chat_id", String(ADMIN_CHAT_ID));
  form.append("photo", new Blob([Buffer.from(b64, "base64")], { type: "image/jpeg" }), "p.jpg");
  if (caption) form.append("caption", caption.slice(0, 1000));
  if (keyboard) form.append("reply_markup", JSON.stringify(keyboard));
  const res = await fetch(url(token, "sendPhoto"), { method: "POST", body: form });
  return res.json().catch(() => ({}));
}

const REASON_TR = {
  harassment: "Taciz / rahatsız etme", fake: "Sahte profil",
  no_show: "Gelmedi", safety: "Güvenlik endişesi", other: "Diğer",
};

// ------------------------------------------------ doğrulama sonucu işleyici
async function setStatus(uid, status) {
  await db.doc(`users/${uid}`).set({ verificationStatus: status }, { merge: true });
  await db.collection(`users/${uid}/notifications`).add({
    type: "verification",
    status: status === "verified" ? "approved" : "rejected",
    read: false,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
  });
}

async function nameOf(uid) {
  try {
    const s = await db.doc(`users/${uid}`).get();
    const u = s.data() || {};
    return `${u.name || "(adsız)"}${u.email ? " <" + u.email + ">" : ""}`;
  } catch (_) {
    return "(silinmiş hesap)";
  }
}

// ---------------------------------------------------- Trigger: yeni selfie
exports.onVerificationSubmitted = onDocumentWritten(
  { document: "users/{uid}/private/verification", secrets: [BOT_TOKEN] },
  async (event) => {
    const after = event.data?.after;
    if (!after || !after.exists) return; // silme (ör. hesap kapatma)
    const selfie = after.get("selfieB64");
    if (!selfie) return;

    const uid = event.params.uid;
    const userSnap = await db.doc(`users/${uid}`).get();
    const u = userSnap.data() || {};
    if (u.verificationStatus === "verified") return; // zaten onaylı

    const token = BOT_TOKEN.value();
    const caption =
      `🕵️ Doğrulama bekliyor\n${u.name || "(adsız)"} · ${u.age || "?"} · ${u.email || ""}\nuid: ${uid}`;
    const kb = { inline_keyboard: [[
      { text: "✅ Onayla", callback_data: `approve:${uid}` },
      { text: "❌ Reddet", callback_data: `reject:${uid}` },
    ]] };
    if (u.photoB64) await tgPhoto(token, u.photoB64, `Profil fotoğrafı — ${u.name || ""}`);
    if (selfie) await tgPhoto(token, selfie, caption, kb);
    else await tg(token, "sendMessage", { chat_id: ADMIN_CHAT_ID, text: caption + "\n(selfie yok)", reply_markup: kb });
  }
);

// ------------------------------------------------------ Trigger: yeni şikayet
exports.onReportCreated = onDocumentCreated(
  { document: "reports/{reportId}", secrets: [BOT_TOKEN] },
  async (event) => {
    const r = event.data?.data();
    if (!r) return;
    const token = BOT_TOKEN.value();
    const text =
      `🚩 Yeni şikayet: ${REASON_TR[r.reason] || r.reason}\n` +
      `Şikayet edilen: ${await nameOf(r.reportedUid)}\n` +
      `Şikayet eden: ${await nameOf(r.reporterUid)}\n` +
      (r.note ? `Not: “${r.note}”\n` : "") +
      (r.flockId ? `Flock: ${r.flockId}` : "");
    await tg(token, "sendMessage", {
      chat_id: ADMIN_CHAT_ID,
      text,
      reply_markup: { inline_keyboard: [[
        { text: "🔒 Hesabı kilitle", callback_data: `reject:${r.reportedUid}` },
      ]] },
    });
  }
);

// --------------------------------------------------------------- /durum özeti
async function statusSummary() {
  const now = admin.firestore.Timestamp.now();
  const [pending, flocks, reports] = await Promise.all([
    db.collection("users").where("verificationStatus", "==", "pending").count().get(),
    db.collection("flocks").where("expiresAt", ">", now).count().get(),
    db.collection("reports").count().get(),
  ]);
  return `📊 Flock durum\n` +
    `Bekleyen doğrulama: ${pending.data().count}\n` +
    `Aktif flock: ${flocks.data().count}\n` +
    `Toplam şikayet: ${reports.data().count}`;
}

// ------------------------------------------------------- Telegram webhook'u
exports.telegramWebhook = onRequest(
  { secrets: [BOT_TOKEN, WEBHOOK_SECRET], invoker: "public" },
  async (req, res) => {
    // Yalnızca Telegram'dan gelen istekleri kabul et (gizli başlık).
    if (req.get("X-Telegram-Bot-Api-Secret-Token") !== WEBHOOK_SECRET.value()) {
      return res.status(403).send("forbidden");
    }
    const token = BOT_TOKEN.value();
    const up = req.body || {};
    try {
      if (up.message && up.message.chat && up.message.chat.id === ADMIN_CHAT_ID) {
        const text = (up.message.text || "").trim();
        if (text === "/durum") {
          await tg(token, "sendMessage", { chat_id: ADMIN_CHAT_ID, text: await statusSummary() });
        } else if (text.startsWith("/start")) {
          await tg(token, "sendMessage", { chat_id: ADMIN_CHAT_ID, text: "🪶 Flock admin botu hazır. Doğrulama ve şikayetler otomatik düşer. Komut: /durum" });
        }
      }
      if (up.callback_query) {
        const q = up.callback_query;
        if (q.message && q.message.chat && q.message.chat.id === ADMIN_CHAT_ID) {
          const [action, uid] = (q.data || "").split(":");
          // uid'yi doc yoluna koymadan önce biçim doğrula (yol enjeksiyonu yok).
          const safeUid = /^[A-Za-z0-9_-]{1,128}$/.test(uid || "");
          if ((action === "approve" || action === "reject") && safeUid) {
            await setStatus(uid, action === "approve" ? "verified" : "rejected");
            await tg(token, "answerCallbackQuery", { callback_query_id: q.id, text: action === "approve" ? "Onaylandı ✅" : "Reddedildi ❌" });
            await tg(token, "editMessageReplyMarkup", { chat_id: q.message.chat.id, message_id: q.message.message_id, reply_markup: { inline_keyboard: [] } });
            await tg(token, "sendMessage", { chat_id: ADMIN_CHAT_ID, text: `${uid} → ${action === "approve" ? "verified ✅" : "rejected/kilitli ❌"}` });
          }
        } else {
          await tg(token, "answerCallbackQuery", { callback_query_id: q.id });
        }
      }
    } catch (e) {
      console.error("webhook error", e);
    }
    res.status(200).send("ok"); // Telegram tekrar denemesin diye daima 200
  }
);
