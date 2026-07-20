# Flock — Durum: Yapıldı / Yapılacak

> Vizyon ([PRODUCT.md](PRODUCT.md)) ile kodun gerçek durumu arasındaki fark.
> Son güncelleme: 2026-07-19.

## ✅ Gerçekten yapıldı (çalışıyor)

- **E-posta/şifre auth** (Firebase Auth) — giriş/kayıt/çıkış
- **Google ile giriş** — native hesap seçici (`google_sign_in` + SHA-1); yeni kullanıcı otomatik onboarding'e düşer, adı Google'dan önceden dolar
- **Gerçek profil fotoğrafları** — onboarding fotoğrafı küçültülüp (`ImageUtil.shrink`, ~320px JPEG) `users/{uid}.photoB64` olarak saklanır; avatarlar (profil + flock üye listesi) gerçek fotoğraf gösterir; profilde avatara dokunarak değiştirilir
- **Selfie doğrulaması gerçek** — ML Kit yüz algılama cihazda çalışır (yüzsüz görsel reddedilir), selfie yalnızca KAMERADAN çekilebilir, kilitli `private/verification` alanına kaydedilir, admin `tools/admin_review.js` ile inceleyip onaylar/reddeder
- **Doğrulama kapısı** — selfie'si onaylanmayan kullanıcı uygulamaya giremez: `pending` → bekleme ekranı (onay gelince canlı açılır), `rejected` → bildirim + yeni selfie çekme ekranı → tekrar incelemeye düşer
- **Buluşma sonrası yıldızlı puanlama (2026-07-20)** — flock bitince ana ekranda "Nasıl geçti?" istemi; üyeler birbirine 1-5 yıldız verir (`ratings` koleksiyonu: deterministik id → kişi başı tek oy, yalnız süresi dolmuş flock'un gerçek üyeleri, değiştirilemez). Trust score artık %60 profil sinyali + %40 yıldız ortalaması; profilde gerçek "Ortalama puan" kartı
- **Şikayet + engelleme (2026-07-20, Play UGC zorunluluğu)** — flock detayında üye çipine dokun → Şikayet et (5 sebep + opsiyonel not → istemcinin okuyamadığı `reports` koleksiyonu; admin `admin_review.js`'te görür) / Engelle (`private/blocks`; engellenenin host/üye olduğu flock'lar feed+haritadan gizlenir). Olay durumunda veri şikayetçiye değil, resmî talep hâlinde yetkili makama verilir (Tinder modeli)
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

- **Kimlik doğrulama** — selfie akışı artık gerçek (yüz algılama + manuel admin incelemesi + kapı); **TC kimlik alanı ve otomatik yüz EŞLEŞTİRME hâlâ yok** (selfie ile profil fotoğrafını insan karşılaştırıyor).
- **Trust score** — profil sinyallerinden (doğrulama, foto, selfie, onboarding) dinamik hesaplanıyor; **buluşma sonrası yıldız puanlarına bağlanması planlandı** (görevde).

## ❌ Henüz yok (vizyonda var, kodda yok)

- **TC kimlik + otomatik yüz eşleştirme** (OCR / face-match — inceleme şimdilik manuel)
- **Telefon numarası doğrulama** (Firebase Phone Auth — Blaze planı gerekebilir)
- **Telegram admin botu + canlı izleme paneli** — doğrulama bildirimi + tek dokunuş onay; ölçek için şart (elle onay günde ~50 kayıtta tıkanır)
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

Yapıldı (devam):
- **Gerçek uygulama ikonu** — marka coral + "yükselen flock" motifi; `assets/icon/` kaynak, `flutter_launcher_icons` ile tüm Android (adaptive dahil) / iOS / web boyutları üretildi
- **Store görselleri** — `store_assets/play-icon-512.png` + `store_assets/play-feature-1024x500.png`
- **Gizlilik politikası + hesap silme sayfaları** — `docs/privacy-policy.html`, `docs/hesap-silme.html` (TR+EN); GitHub Pages üzerinden yayınlanır

Hâlâ gerekli (kod dışı):
- Play Console hesabı, store metinleri, ekran görüntüleri (cihazdan)
- Data Safety formunun doldurulması (politika sayfası hazır; **profil fotoğrafı + selfie toplandığı forma eklenmeli**)
- İçerik derecelendirme anketi (18+ sosyal buluşma), internal testing track'te gerçek cihaz testi
- ~~Firestore rules'un canlıya deploy edilmesi~~ ✅ **Deploy edildi (2026-07-19)** — Firebase CLI kuruldu, kurallar canlıda; sonraki değişikliklerde `firebase deploy --only firestore:rules`
- ~~Google sağlayıcısı~~ ✅ **Açıldı (2026-07-19)** — support email + SHA-1 (upload key) eklendi, `google-services.json` güncellendi
- App Check (Play Integrity) + Play'e çıkınca **Play imza SHA'sının** Firebase'e eklenmesi
- PR'lar merge olunca GitHub Pages kaynağını `main`'e çevirmek

## 🔴 Bilinen riskler / hatalar (kod incelemesinden)

1. **Mesafe filtresi tamamen istemcide** — `flock_repository.dart:19` tüm aktif flock'ları çeker. Ölçeklenmez → ileride geohash/GeoFirestore.
2. **Firebase anahtarları repoda** — sır değil ama güvenlik tamamen kurallara bağlı → **App Check** önerilir.

## 🚀 2026-07-19 gelişmeleri (yayın sprinti)

- **Google ile giriş eklendi** — önce `signInWithProvider` (tarayıcı) denendi, Chrome'un bölümlenmiş depolaması "missing initial state" hatası verdi → **native `google_sign_in`'e geçildi** (SHA-1 + web client id). Cihazda test edildi, çalışıyor.
- **Profil placeholder temizliği** — sahte istatistikler (90/23/4.9), sahte geçmiş flock'lar ve "Jordan Vale" kaldırıldı; gerçek trust score kartı; avatardaki ✓ yalnızca doğrulanmış hesapta.
- **Fotoğraf altyapısı** — foto/selfie artık gerçekten kaydediliyor (Firestore base64; Storage/Blaze gerekmedi). Avatarlar gerçek fotoğraf gösteriyor; profilden fotoğraf değiştirilebiliyor.
- **Selfie doğrulama gerçek oldu** — ML Kit yüz algılama (klavye fotoğrafı vakası kapandı), kamera-zorunlu selfie, kilitli `private/verification`, `tools/admin_review.js` ile inceleme/onay/red + kullanıcıya bildirim.
- **Doğrulama kapısı** — pending/rejected kullanıcı uygulamaya giremiyor; redde yeni selfie akışı. (Geliştirici hesabı muaf.)
- **Kurallar sertleştirilip CANLIYA deploy edildi** — istemci kendini `verified` yapamaz; `private/` yalnızca sahibine; eski açık kurallar proddan kalktı.
- **Auth ekranı logosu** gerçek uygulama ikonuyla değiştirildi.
- **Not:** ML Kit nedeniyle APK ~85MB oldu — Play'e AAB yüklendiği için kullanıcıya inen boyut çok daha küçük olur.
- **Ortam:** Android SDK `C:\Asdk`'ya taşınmıştı; `local.properties` ve `build_release.bat` güncellendi. Node.js LTS + Firebase CLI (npm) kuruldu.

## 📈 Ölçek eşikleri (2026-07-19 analizi)

| Eşik | Ne patlar | Çare |
|---|---|---|
| ~100-300 DAU | Spark planı günlük 50K okuma kotası → feed boş kalır | Blaze planına geçiş |
| ~50-100 kayıt/gün | Elle selfie onayı tıkanır | Telegram admin botu |
| ~1-5K kullanıcı | OSM tile/Nominatim politika engeli → harita beyaz | Ücretli tile sağlayıcı (MapTiler/Stadia) |
| ~5-10K DAU | "Herkes tüm flock'ları dinler" modeli (maliyet + jank) | Geohash'li yakınlık sorgusu |

Kök neden: `watchActive()` tüm aktif flock'ları her istemciye indirir (mesafe filtresi istemcide). Auth/kurallar/transaction'lar ölçeklenebilir durumda.

## 🟢 Yayın öncesi bug temizliği (2026-07-19)

- **`silent` parametresi artık gerçek** — ilk açılışta izin penceresi fırlamaz; GPS yalnızca izin zaten verilmişse sessizce alınır, izin sorusu kullanıcı "GPS kullan"a basınca sorulur (`location_service.dart` `requestPermission` parametresi).
- **Konum etiketi GPS'e göre güncelleniyor** — başarılı GPS sonrası Nominatim reverse-geocode ile "Moda, Kadıköy" gibi gerçek bölge etiketi çözülür, kalıcı saklanır ve ana ekranda gösterilir (`LocationController._resolveLabel`).
- **Flock detay haritası düzeltildi** — yanlış User-Agent (`com.fluck.app` → `com.hashus303.fluck`), eksik `retinaMode` (hi-DPI netliği) ve eksik zorunlu OSM atıfı (`OsmAttribution`) eklendi.
- **Harita ekranında sessiz GPS hatası giderildi** — "konumumu bul" butonu başarısız olunca artık ana ekranla aynı hata mesajları gösterilir; harita hatada eski konuma zıplamaz.
- **Davet oluşturmada boş bölge etiketi** — kullanıcı haritayı hiç oynatmadıysa bölge, yayınlama sırasında konumdan reverse-geocode ile doldurulur.

## Öneri sırası (yapılırsa)

1. Telegram admin botu (doğrulama onayını otomatize et — ölçek darboğazı #1)
2. Buluşma sonrası yıldızlı puanlama → dinamik trust score
3. Telefon numarası doğrulama (Phone Auth; Blaze kontrolü)
4. Check-in + güvenilir kişiyle konum paylaşımı (güvenlik MVP'si)
5. Cloud Functions (expiry temizliği) + FCM push
6. Geohash sorgu + ücretli tile sağlayıcı (ölçek eşiklerine göre)

---
İlgili: [PRODUCT.md](PRODUCT.md) · [ARCHITECTURE.md](ARCHITECTURE.md)
