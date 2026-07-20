# Flock — Mimari & Kod Haritası

> Amaç: bu dosya, kodu baştan okumadan projeyi anlamayı sağlar. Dosya başına bir satır,
> veri modelleri ve Firestore şeması burada. Detay için ilgili dosyaya git.

## Yığın

- **Flutter** (Dart SDK ^3.11.1), Material 3, özel tema (`core/theme`)
- **Firebase:** `firebase_core`, `firebase_auth` (e-posta/şifre + **Google girişi**: `google_sign_in`, native hesap seçici), `cloud_firestore`
- **Görüntü/Doğrulama:** `image_picker`, `image` (küçültme), `google_mlkit_face_detection` (cihazda yüz algılama — selfie doğrulaması)
- **Konum/Harita:** OpenStreetMap ([API'ler](https://wiki.openstreetmap.org/wiki/API): tile + Nominatim) — `flutter_map` + `latlong2`, `geolocator`, `http`. **Anahtar gerektirmez**; "© OpenStreetMap contributors" atıfı zorunlu (`OsmAttribution`).
- **Yerel:** `shared_preferences` (konum cache), `intl` + `flutter_localizations` (TR/EN, `l10n.yaml` + ARB)
- **State:** Hafif — `ChangeNotifier` + `InheritedNotifier` (`LocaleScope`, `LocationScope`). Harici state lib yok.
- **Admin araçları:** `tools/admin_review.js` (Node) — bekleyen selfie doğrulamalarını yerel HTML'de gösterir, onay/red + kullanıcıya bildirim yazar (Firebase CLI oturumunu kullanır; çıktısı `tools/review.html` gitignore'da).

## Mimari ilkeler

- **Feature-based:** `lib/features/<feature>/{data,presentation}`. `data` = model + repository, `presentation` = UI.
- **Tekil servisler:** Repository ve servisler `instance` singleton deseniyle (örn. `FlockRepository.instance`).
- **Graceful degradation:** Firebase yapılandırılmamışsa uygulama çöker yerine örnek veriyle (`kFlocks`) çalışır. `FirebaseService.isInitialized` her yerde kapı görevi görür.
- **Responsive shell:** `main.dart > _ResponsiveShell` geniş ekranda içeriği 480px telefon genişliğinde ortalar.

## Klasör / dosya haritası

```
lib/
├── main.dart                      # Giriş; AuthGate→ProfileGate→RootScreen; alt nav (4 sekme + "+" oluştur)
├── firebase_options.dart          # FlutterFire çıktısı; proje: fluck-app-fv0kh (GERÇEK anahtarlar commit'li)
├── core/
│   ├── app_locale.dart            # LocaleController + LocaleScope (TR/EN, prefs'te kalıcı)
│   ├── models/flock.dart          # Vibe katalogu (kVibes), Flock UI modeli, Person, kFlocks örnek veri
│   ├── services/
│   │   ├── firebase_service.dart  # Firebase init (hata yutar), auth/firestore erişimi
│   │   ├── geo.dart               # LatLng, UserLocation (varsayılan İstanbul), haversineKm, distanceLabel
│   │   ├── location_service.dart  # geolocator sarmalı — getCurrent() izin/GPS yoksa null
│   │   ├── location_controller.dart # "Benim konumum" tek kaynağı + LocationScope; prefs cache + GPS + bölge etiketi
│   │   ├── geocoding_service.dart  # reverse/forward geocode (mekan/alan adı)
│   │   └── image_util.dart         # shrink (Firestore'a sığan JPEG) + hasFace (ML Kit yüz kontrolü)
│   ├── theme/                      # app_colors.dart (marka renkleri/glow), app_theme.dart (AppText, AppRadius)
│   └── widgets/
│       ├── flock_widgets.dart      # InviteCard, FlockButton, FlockBadge, VerifiedBadge vb. paylaşılan UI
│       └── location_picker.dart    # Haritadan konum seçici (davet oluşturmada)
├── features/
│   ├── auth/        data/auth_repository.dart        # FirebaseAuth: signIn/signUp/signOut/authState
│   │                presentation/auth_screen.dart    # Giriş/kayıt ekranı
│   ├── profile/     data/user_profile.dart           # UserProfile modeli (bkz. şema)
│   │                data/user_profile_repository.dart # users/{uid} oku/yaz/izle
│   │                data/interests.dart               # İlgi alanı katalogu (onboarding)
│   │                presentation/onboarding_screen.dart # İlk kurulum akışı (foto + KAMERA-zorunlu selfie + yüz kontrolü)
│   │                presentation/profile_screen.dart    # Profil görünümü (gerçek foto; avatara dokun → değiştir)
│   │                presentation/verification_gate_screen.dart # Doğrulama kapısı: pending bekleme / rejected yeni selfie
│   ├── home/        presentation/home_screen.dart     # Ana akış: canlı flock listesi + mesafe/vibe filtre + katıl + "Şansına bırak" (🎲)
│   │                presentation/map_screen.dart      # Gerçek OSM haritası: canlı flock pinleri, konumum, pin→kart→detay
│   ├── flock/       data/flock_doc.dart               # Firestore flock belgesi modeli + toFlock()
│   │                data/flock_repository.dart         # flocks koleksiyonu: watchActive/create/join/leave
│   │                data/dev_seeder.dart               # SADECE DEV: örnek flock'lar yazar (isSeed=true)
│   │                presentation/flock_detail_screen.dart # Tek flock detay + katıl/ayrıl
│   ├── invite/      presentation/invite_screen.dart   # Davet oluştur (vibe, mekan, grup 3-8, süre 30dk/1sa/2sa)
│   ├── safety/      presentation/safety_screen.dart   # Güvenlik merkezi (trust score, kimlik durumu — SOS üründen kaldırıldı)
│   └── notifications/ data/notification_repository.dart # users/{uid}/notifications: join bildirimleri
│                      presentation/notifications_screen.dart
└── l10n/            app_localizations*.dart            # Üretilen TR/EN çeviriler (AppL10n)
```

## Veri modelleri

### UserProfile — `features/profile/data/user_profile.dart`
`uid, name, age, interests[], photoProvided, selfieProvided, verificationStatus('none'|'pending'|'verified'|'rejected'), onboardingComplete, email, photoB64`
- `photoB64`: küçültülmüş profil fotoğrafı (JPEG base64, ~320px) — avatarlarda gösterilir.
- `trustScore` (türetilmiş): doğrulama + foto/selfie + onboarding sinyallerinden 0-100.
> Not: TC kimlik alanı yok; selfie incelemesi manuel (admin), yüz eşleştirme otomatik değil.

### Flock (UI modeli) — `core/models/flock.dart`
`id, vibeId, venue, area, host, verifiedHost, minutesLeft, total, members[Person], lat, lng`
- `Vibe`: id/label/emoji/color. Katalog `kVibes` (coffee, bar, walk, games, food, music).
- `Person`: name, verified.

### FlockDoc (Firestore modeli) — `features/flock/data/flock_doc.dart`
UI `Flock`'a `toFlock()` ile dönüşür. `isExpired`, `isFull`, `minutesLeft` hesaplanır.

## Firestore şeması

```
users/{uid}
  uid, name, age, interests[], photoProvided, selfieProvided,
  verificationStatus, onboardingComplete, email, photoB64, updatedAt
  ├── notifications/{notifId}
  │     type('join'|'verification'), flockId, venue, actorName,
  │     status('approved'|'rejected' — verification için), read, createdAt
  └── private/{docId}                 # kilitli: yalnızca sahibi; admin konsoldan
        verification: selfieB64, submittedAt

flocks/{flockId}
  vibeId, venue, area, hostUid, hostName, verifiedHost,
  lat, lng, total, memberUids[], memberNames{uid:name},
  createdAt, expiresAt, isSeed?(dev)
```

**Kurallar** (`firestore.rules`, canlıda): users okuma=auth; create/update=sahibi **ama `verificationStatus:'verified'` istemciden yazılamaz** (yalnızca admin/konsol); delete=sahibi. `private/*` yalnızca sahibi (diğer kullanıcılara tamamen kapalı). notifications create=auth (yalnızca katıldığın flock'un host'una, kendi adına 'join'), oku/güncelle/sil=sahibi — admin araçları kural dışıdır (IAM). flocks oku=auth, create=host kendisi, update=yalnızca kendi üyeliğin (join/leave, kapasite korunur), delete=host.

## Önemli akışlar

- **Açılış:** `main()` → Firebase init → `runApp` → locale/location arka planda yüklenir.
- **Oturum kapısı:** `AuthGate` (Firebase yoksa direkt RootScreen) → giriş varsa `_ProfileGate` → onboarding bitmemişse `OnboardingScreen` → **doğrulama kapısı**: `verificationStatus != 'verified'` ise `VerificationGateScreen` (pending=bekle, rejected=yeni selfie; statü canlı izlendiği için onay anında uygulama açılır; geliştirici hesabı muaf) → `RootScreen` (4 sekmeli kabuk).
- **Google girişi:** `AuthRepository.signInWithGoogle()` — mobilde native `google_sign_in` (`serverClientId` = web OAuth client), idToken → `signInWithCredential`; web'de popup. İptal `user-cancelled` koduyla yutulur.
- **Selfie doğrulama:** onboarding/kapı → kamera-zorunlu çekim → `ImageUtil.hasFace` (ML Kit) → `private/verification`'a base64 → admin `tools/admin_review.js` (listele/approve/reject) → statü + kullanıcıya 'verification' bildirimi.
- **Flock listele:** `home_screen` → `FlockRepository.watchActive()` (expiresAt>now) → istemcide haversine ile mesafe + vibe filtre → mesafeye göre sırala.
- **Şansına bırak:** `home_screen > _surprise()` → filtre/yarıçap içindeki katılabilir (üye olunmayan, dolu olmayan) flock'lardan rastgele biri alt sayfada → katıl / tekrar çevir.
- **Katıl:** `FlockRepository.join()` transaction (dolu/expired kontrolü) → host'a `notifyJoin` (best-effort).
- **Oluştur:** `invite_screen` → `FlockRepository.create(lifetime: ...)` → `expiresAt = now + host'un seçtiği süre (30dk / 1sa / 2sa)`.
- **Mesafe filtresi tamamen istemcide** — tüm aktif flock'lar çekilip cihazda filtrelenir (ölçeklenme notu: STATUS).

## Ölçek notları (2026-07-19)

Darboğaz `watchActive()`: tüm aktif flock'lar her istemciye iner ve canlı dinlenir → maliyet **kullanıcı × flock** ile büyür. Eşikler ve çareler [STATUS.md](STATUS.md) "Ölçek eşikleri" tablosunda; özetle: Spark kotası (~100-300 DAU) → Blaze; elle selfie onayı (~50 kayıt/gün) → Telegram botu; OSM politikası (~1-5K kullanıcı) → ücretli tile; dinleme modeli (~5-10K DAU) → geohash sorgusu. Auth, kurallar ve join transaction'ları bu ölçeklerde sorunsuz.

## Yapılandırma gereksinimleri

- `firebase_options.dart` — proje `fluck-app-fv0kh` için doldurulmuş (web/android/ios).
- Harita için ek yapılandırma yok — OpenStreetMap anahtarsızdır. Tek koşul: atıf (`OsmAttribution`) ve [tile kullanım politikası](https://operations.osmfoundation.org/policies/tiles/) (geçerli `userAgentPackageName` gönderiliyor).

---
İlgili: [PRODUCT.md](PRODUCT.md) (ne/neden) · [STATUS.md](STATUS.md) (yapıldı/yapılacak + riskler)
