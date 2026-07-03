# Flock — Durum: Yapıldı / Yapılacak

> Vizyon ([PRODUCT.md](PRODUCT.md)) ile kodun gerçek durumu arasındaki fark.
> Son güncelleme: 2026-07-04.

## ✅ Gerçekten yapıldı (çalışıyor)

- **E-posta/şifre auth** (Firebase Auth) — giriş/kayıt/çıkış
- **Onboarding + profil** — ad, yaş, ilgi alanları, foto/selfie *bayrakları*
- **Flock yaşam döngüsü** — oluştur / katıl / ayrıl; **süre host seçimli: 30 dk / 1 sa / 2 sa** otomatik expiry (istemci hesaplı)
- **Şansına bırak (🎲)** — ana ekranda zar butonu: filtredeki katılabilir flock'lardan rastgelesini alt sayfada gösterir; katıl / tekrar çevir
- **Mesafe filtresi** — haversine, 10/25/100 km / her yer; vibe filtresi; mesafeye göre sıralama
- **Harita + liste** — gerçek OSM haritası (`flutter_map`): canlı flock pinleri, konumum, pin→kart→detay; konum seçici, GPS (`geolocator`), reverse-geocode (Nominatim)
- **Uygulama-içi bildirim** — birisi flock'a katılınca host'a (Firestore `notifications`)
- **TR/EN lokalizasyon**, özel tema, responsive shell
- **Grup boyutu 3-8** — davet oluştururken min 3 UI'da zorlanıyor
- **Dev seeder** — farklı şehirlerde örnek flock (mesafe filtresini denemek için)

## 🟡 Kısmen / sadece UI (backend yok)

- **Kimlik doğrulama** — `verificationStatus` + `photoProvided/selfieProvided` *bayrakları* var; **TC kimlik alanı ve gerçek doğrulama akışı yok**. Güvenlik ekranındaki kimlik doğrulama kartı artık kullanıcının gerçek doğrulama durumunu yansıtıyor.
- **Trust score** — güvenlik ekranındaki trust score artık kullanıcının profilindeki sinyallere (onboarding, kimlik doğrulama durumu, fotoğraf ve selfie sağlama durumları) göre dinamik olarak hesaplanıyor, ancak bu sinyallerin kendileri henüz gerçek bir doğrulama akışına (OCR/yüz tanıma gibi) bağlı değil.

## ❌ Henüz yok (vizyonda var, kodda yok)

- **TC kimlik + selfie doğrulama** (gerçek akış / OCR / yüz eşleştirme)
- **Partner mekan kısıtı** — mekan şu an serbest metin + haritadan herhangi bir nokta
- **Güvenilir kişiyle canlı konum paylaşımı**
- **Check-in sistemi**
- **AI sohbet moderasyonu** — uygulamada sohbet/chat hiç yok
- **Cloud Functions** — expiry temizliği, doğrulama, moderasyon sunucu tarafı yok
- **FCM / push bildirim** — bildirimler yalnızca uygulama-içi (Firestore), push yok
- **"Min 3 kişi" gerçek zorlama** — oluştururken hedef boyut min 3, ama buluşmanın gerçekten 3 kişiye ulaşması zorlanmıyor

## 🔁 Ürün kararları

- **Google Maps MVP'den çıkarıldı, OSM API'ye geçildi (2026-07-04)** — `google_maps_flutter` bağımlılığı silindi (kodda zaten kullanılmıyordu); harita [OpenStreetMap API'leriyle](https://wiki.openstreetmap.org/wiki/API) çalışıyor (tile + Nominatim, anahtarsız). Placeholder harita ekranı gerçek OSM haritasına çevrildi (canlı pinler). Zorunlu atıf (`OsmAttribution`) iki haritaya da eklendi. Yüksek trafikte tile politikası gereği kendi tile sunucusuna geçilmeli.
- **SOS kaldırıldı (2026-07-04)** — SOS butonu ve 112 entegrasyonu hedefi üründen bilinçli olarak çıkarıldı. Gerekçe: uygulama bir acil durum aracı değil; sahte güven hissi veren dekoratif bir SOS taşımak yerine güvenlik, grup buluşması + kimlik/trust score + (planlanan) check-in ve konum paylaşımıyla sağlanacak. Acil durumda telefonun kendi 112 akışı esastır.
- **Spontanelik odağı** — ürün "plan yapmadan hemen çık" fikrine göre keskinleştirildi: davet süresi kısaltılabilir (30 dk "yıldırım" flock'ları) ve "Şansına bırak" ile karar verme yükü sıfırlanıyor.

## 🟢 Çözülen riskler / hatalar (Tamamlandı)

1. **Firestore: flock `update` çok açık** — `firestore.rules` güncellenerek yalnızca `memberUids` ve `memberNames` alanlarının güncellenebilmesi sağlandı. Diğer alanlar (hostUid, expiresAt vb.) kilitlendi. Kapasite kontrolü eklendi.
2. **Paralel diziler `memberUids`/`memberNames` + `arrayUnion`** — Üye listesindeki çakışma ve bozulma problemleri, `memberNames` alanının list yerine `uid -> name` map tipine geçirilmesiyle çözüldü. Eski veri yapısına geriye dönük uyumluluk korundu.
3. **Bildirim `create` açık** — Bildirim oluştururken `actorUid`'nin, isteği gönderen kullanıcının auth UID'si ile eşleşmesi zorunluluğu getirilerek sahtecilik engellendi.
4. **Güvenlik / Trust Score entegrasyonu** — Güvenlik ekranındaki trust score ve kimlik doğrulama durum kartı, statik değerler yerine kullanıcının profilindeki gerçek verilerden beslenecek şekilde dinamikleştirildi.

## 📦 Play Store hazırlığı (2026-07-04)

Kod tarafı yapıldı:
- **Release imzalama** — upload keystore + `android/key.properties` (gitignore'da) + Gradle signing config; dosya yoksa debug imzaya düşer
- **Hesap silme** — Play politikası gereği uygulama içinden: onay diyaloğu → profil + bildirimler + auth kaydı silinir (`requires-recent-login` durumunda yeniden giriş istenir)
- **Dev seeder `kDebugMode` arkasında** — release build'e hiç girmez
- **User-Agent düzeltmeleri** — Nominatim ve OSM tile isteklerinde gerçek uygulama kimliği (`com.hashus303.fluck`)
- Boş "Profili düzenle" butonu kaldırıldı

Hâlâ gerekli (kod dışı):
- Play Console hesabı, store metinleri, ekran görüntüleri, 512×512 ikon + 1024×500 feature graphic
- **Gerçek uygulama ikonu** (hâlâ varsayılan Flutter ikonu — `flutter_launcher_icons`)
- **Gizlilik politikası URL'si** + Data Safety formu (hesap, konum, foto verisi toplanıyor)
- Web üzerinden hesap silme talebi sayfası (Play politikası ister)
- İçerik derecelendirme anketi (18+ sosyal buluşma), internal testing track'te gerçek cihaz testi
- Firestore rules'un canlıya deploy edilmesi + App Check (Play Integrity) + Play imza SHA'sının Firebase'e eklenmesi

## 🔴 Bilinen riskler / hatalar (kod incelemesinden)

1. **`silent` parametresi ölü** — `location_controller.dart:42`. `load()` "sessiz GPS" beklerken ilk açılışta izin penceresi fırlar.
2. **`_label` hiç güncellenmiyor** — `location_controller.dart:11`. GPS'te bile "İstanbul". `geocoding_service` ile güncellenebilir.
3. **Mesafe filtresi tamamen istemcide** — `flock_repository.dart:19` tüm aktif flock'ları çeker. Ölçeklenmez → ileride geohash/GeoFirestore.
4. **Firebase anahtarları repoda** — sır değil ama güvenlik tamamen kurallara bağlı → **App Check** önerilir.

## Öneri sırası (yapılırsa)

1. Konum/adres etiketinin (`_label`) GPS konumuna göre güncellenmesini sağlama
2. Check-in + güvenilir kişiyle konum paylaşımı (güvenlik MVP'si)
3. Cloud Functions (expiry temizliği) + FCM push
4. AI moderasyon + partner mekan altyapısı

---
İlgili: [PRODUCT.md](PRODUCT.md) · [ARCHITECTURE.md](ARCHITECTURE.md)
