# Flock — Durum: Yapıldı / Yapılacak

> Vizyon ([PRODUCT.md](PRODUCT.md)) ile kodun gerçek durumu arasındaki fark.
> Son güncelleme: 2026-06-28.

## ✅ Gerçekten yapıldı (çalışıyor)

- **E-posta/şifre auth** (Firebase Auth) — giriş/kayıt/çıkış
- **Onboarding + profil** — ad, yaş, ilgi alanları, foto/selfie *bayrakları*
- **Flock yaşam döngüsü** — oluştur / katıl / ayrıl, **2 saat otomatik expiry** (istemci hesaplı)
- **Mesafe filtresi** — haversine, 10/25/100 km / her yer; vibe filtresi; mesafeye göre sıralama
- **Harita + liste** — `flutter_map`, konum seçici, GPS (`geolocator`), reverse-geocode (alan adı)
- **Uygulama-içi bildirim** — birisi flock'a katılınca host'a (Firestore `notifications`)
- **TR/EN lokalizasyon**, özel tema, responsive shell
- **Grup boyutu 3-8** — davet oluştururken min 3 UI'da zorlanıyor
- **Dev seeder** — farklı şehirlerde örnek flock (mesafe filtresini denemek için)

## 🟡 Kısmen / sadece UI (backend yok)

- **Kimlik doğrulama** — `verificationStatus` + `photoProvided/selfieProvided` *bayrakları* var; **TC kimlik alanı ve gerçek doğrulama akışı yok**. Güvenlik ekranındaki "Kimlik doğrulandı" kartı sabit/dekoratif.
- **Trust score** — güvenlik ekranında **sabit "90"**; profilde `trustScore` alanı yok, hesaplama yok.
- **SOS butonu** — var ama uzun basınca **sadece snackbar** gösterir; 112 bağlantısı yok.

## ❌ Henüz yok (vizyonda var, kodda yok)

- **TC kimlik + selfie doğrulama** (gerçek akış / OCR / yüz eşleştirme)
- **Partner mekan kısıtı** — mekan şu an serbest metin + haritadan herhangi bir nokta
- **Güvenilir kişiyle canlı konum paylaşımı**
- **Check-in sistemi**
- **SOS → 112 / acil servis entegrasyonu**
- **AI sohbet moderasyonu** — uygulamada sohbet/chat hiç yok
- **Hesap puanlama (trust score) hesaplama mantığı**
- **Cloud Functions** — expiry temizliği, doğrulama, moderasyon sunucu tarafı yok
- **FCM / push bildirim** — bildirimler yalnızca uygulama-içi (Firestore), push yok
- **"Min 3 kişi" gerçek zorlama** — oluştururken hedef boyut min 3, ama buluşmanın gerçekten 3 kişiye ulaşması zorlanmıyor

## 🔴 Bilinen riskler / hatalar (kod incelemesinden)

1. **Firestore: flock `update` çok açık** — `firestore.rules:27` `allow update: if request.auth != null;`. Herhangi bir kullanıcı herhangi bir flock'un her alanını (hostUid dahil) değiştirebilir. → sadece `memberUids/memberNames` değişimine kısıtla (`affectedKeys().hasOnly([...])`).
2. **Paralel diziler `memberUids`/`memberNames` + `arrayUnion`** — `flock_repository.dart:85`. Aynı isim tekilleşir → sayı tutmaz; `leave()`'de `arrayRemove([name])` aynı isimli herkesi siler. → tek `members:[{uid,name}]` yapısı ya da transaction içinde oku-değiştir-yaz.
3. **Bildirim `create` açık** — `firestore.rules:15`. Spam'e açık.
4. **`silent` parametresi ölü** — `location_controller.dart:42`. `load()` "sessiz GPS" beklerken ilk açılışta izin penceresi fırlar.
5. **`_label` hiç güncellenmiyor** — `location_controller.dart:11`. GPS'te bile "İstanbul". `geocoding_service` ile güncellenebilir.
6. **Mesafe filtresi tamamen istemcide** — `flock_repository.dart:19` tüm aktif flock'ları çeker. Ölçeklenmez → ileride geohash/GeoFirestore.
7. **Firebase anahtarları repoda** — sır değil ama güvenlik tamamen kurallara bağlı → **App Check** önerilir.

## Öneri sırası (yapılırsa)

1. Firestore `update`/`create` kurallarını sıkılaştır (güvenlik, küçük iş)
2. Üye listesini tek yapıya çevir (veri bütünlüğü)
3. Trust score + kimlik doğrulamayı gerçek veriye bağla
4. SOS, check-in, konum paylaşımı (güvenlik MVP'si)
5. Cloud Functions (expiry temizliği) + FCM push
6. AI moderasyon + partner mekan altyapısı

---
İlgili: [PRODUCT.md](PRODUCT.md) · [ARCHITECTURE.md](ARCHITECTURE.md)
