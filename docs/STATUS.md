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

- **Kimlik doğrulama** — `verificationStatus` + `photoProvided/selfieProvided` *bayrakları* var; **TC kimlik alanı ve gerçek doğrulama akışı yok**. Güvenlik ekranındaki kimlik doğrulama kartı artık kullanıcının gerçek doğrulama durumunu yansıtıyor.
- **Trust score** — güvenlik ekranındaki trust score artık kullanıcının profilindeki sinyallere (onboarding, kimlik doğrulama durumu, fotoğraf ve selfie sağlama durumları) göre dinamik olarak hesaplanıyor, ancak bu sinyallerin kendileri henüz gerçek bir doğrulama akışına (OCR/yüz tanıma gibi) bağlı değil.
- **SOS butonu** — var ama uzun basınca **sadece snackbar** gösterir; 112 bağlantısı yok.

## ❌ Henüz yok (vizyonda var, kodda yok)

- **TC kimlik + selfie doğrulama** (gerçek akış / OCR / yüz eşleştirme)
- **Partner mekan kısıtı** — mekan şu an serbest metin + haritadan herhangi bir nokta
- **Güvenilir kişiyle canlı konum paylaşımı**
- **Check-in sistemi**
- **SOS → 112 / acil servis entegrasyonu**
- **AI sohbet moderasyonu** — uygulamada sohbet/chat hiç yok
- **Cloud Functions** — expiry temizliği, doğrulama, moderasyon sunucu tarafı yok
- **FCM / push bildirim** — bildirimler yalnızca uygulama-içi (Firestore), push yok
- **"Min 3 kişi" gerçek zorlama** — oluştururken hedef boyut min 3, ama buluşmanın gerçekten 3 kişiye ulaşması zorlanmıyor

## 🟢 Çözülen riskler / hatalar (Tamamlandı)

1. **Firestore: flock `update` çok açık** — `firestore.rules` güncellenerek yalnızca `memberUids` ve `memberNames` alanlarının güncellenebilmesi sağlandı. Diğer alanlar (hostUid, expiresAt vb.) kilitlendi. Kapasite kontrolü eklendi.
2. **Paralel diziler `memberUids`/`memberNames` + `arrayUnion`** — Üye listesindeki çakışma ve bozulma problemleri, `memberNames` alanının list yerine `uid -> name` map tipine geçirilmesiyle çözüldü. Eski veri yapısına geriye dönük uyumluluk korundu.
3. **Bildirim `create` açık** — Bildirim oluştururken `actorUid`'nin, isteği gönderen kullanıcının auth UID'si ile eşleşmesi zorunluluğu getirilerek sahtecilik engellendi.
4. **Güvenlik / Trust Score entegrasyonu** — Güvenlik ekranındaki trust score ve kimlik doğrulama durum kartı, statik değerler yerine kullanıcının profilindeki gerçek verilerden beslenecek şekilde dinamikleştirildi.

## 🔴 Bilinen riskler / hatalar (kod incelemesinden)

1. **`silent` parametresi ölü** — `location_controller.dart:42`. `load()` "sessiz GPS" beklerken ilk açılışta izin penceresi fırlar.
2. **`_label` hiç güncellenmiyor** — `location_controller.dart:11`. GPS'te bile "İstanbul". `geocoding_service` ile güncellenebilir.
3. **Mesafe filtresi tamamen istemcide** — `flock_repository.dart:19` tüm aktif flock'ları çeker. Ölçeklenmez → ileride geohash/GeoFirestore.
4. **Firebase anahtarları repoda** — sır değil ama güvenlik tamamen kurallara bağlı → **App Check** önerilir.

## Öneri sırası (yapılırsa)

1. Konum/adres etiketinin (`_label`) GPS konumuna göre güncellenmesini sağlama
2. SOS, check-in, konum paylaşımı (güvenlik MVP'si)
3. Cloud Functions (expiry temizliği) + FCM push
4. AI moderasyon + partner mekan altyapısı

---
İlgili: [PRODUCT.md](PRODUCT.md) · [ARCHITECTURE.md](ARCHITECTURE.md)
