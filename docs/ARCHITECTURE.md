# Flock — Mimari & Kod Haritası

> Amaç: bu dosya, kodu baştan okumadan projeyi anlamayı sağlar. Dosya başına bir satır,
> veri modelleri ve Firestore şeması burada. Detay için ilgili dosyaya git.

## Yığın

- **Flutter** (Dart SDK ^3.11.1), Material 3, özel tema (`core/theme`)
- **Firebase:** `firebase_core`, `firebase_auth` (e-posta/şifre), `cloud_firestore`
- **Konum/Harita:** `google_maps_flutter`, `flutter_map` + `latlong2`, `geolocator`, `http` (reverse-geocode)
- **Yerel:** `shared_preferences` (konum cache), `intl` + `flutter_localizations` (TR/EN, `l10n.yaml` + ARB)
- **State:** Hafif — `ChangeNotifier` + `InheritedNotifier` (`LocaleScope`, `LocationScope`). Harici state lib yok.

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
│   │   ├── location_controller.dart # "Benim konumum" tek kaynağı + LocationScope; prefs cache + GPS
│   │   └── geocoding_service.dart  # reverse/forward geocode (mekan/alan adı)
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
│   │                presentation/onboarding_screen.dart # İlk kurulum akışı
│   │                presentation/profile_screen.dart    # Profil görünümü
│   ├── home/        presentation/home_screen.dart     # Ana akış: canlı flock listesi + mesafe/vibe filtre + katıl
│   │                presentation/map_screen.dart      # Harita görünümü
│   ├── flock/       data/flock_doc.dart               # Firestore flock belgesi modeli + toFlock()
│   │                data/flock_repository.dart         # flocks koleksiyonu: watchActive/create/join/leave
│   │                data/dev_seeder.dart               # SADECE DEV: örnek flock'lar yazar (isSeed=true)
│   │                presentation/flock_detail_screen.dart # Tek flock detay + katıl/ayrıl
│   ├── invite/      presentation/invite_screen.dart   # Davet oluştur (vibe, mekan, grup 3-8, 2sa expiry)
│   ├── safety/      presentation/safety_screen.dart   # Güvenlik merkezi (SOS, trust score, kimlik — çoğu UI-only)
│   └── notifications/ data/notification_repository.dart # users/{uid}/notifications: join bildirimleri
│                      presentation/notifications_screen.dart
└── l10n/            app_localizations*.dart            # Üretilen TR/EN çeviriler (AppL10n)
```

## Veri modelleri

### UserProfile — `features/profile/data/user_profile.dart`
`uid, name, age, interests[], photoProvided, selfieProvided, verificationStatus('none'|'pending'|'verified'), onboardingComplete, email`
> Not: TC kimlik alanı yok; doğrulama şimdilik sadece boolean bayraklar.

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
  verificationStatus, onboardingComplete, email, updatedAt
  └── notifications/{notifId}
        type('join'), flockId, venue, actorName, read, createdAt

flocks/{flockId}
  vibeId, venue, area, hostUid, hostName, verifiedHost,
  lat, lng, total, memberUids[], memberNames[],
  createdAt, expiresAt, isSeed?(dev)
```

**Kurallar** (`firestore.rules`): users okuma=auth, yazma=sahibi. notifications create=auth, oku/güncelle/sil=sahibi. flocks oku=auth, create=host kendisi, **update=auth (çok geniş — bkz. STATUS riskler)**, delete=host.

## Önemli akışlar

- **Açılış:** `main()` → Firebase init → `runApp` → locale/location arka planda yüklenir.
- **Oturum kapısı:** `AuthGate` (Firebase yoksa direkt RootScreen) → giriş varsa `_ProfileGate` → onboarding bitmemişse `OnboardingScreen`, bittiyse `RootScreen` (4 sekmeli kabuk).
- **Flock listele:** `home_screen` → `FlockRepository.watchActive()` (expiresAt>now) → istemcide haversine ile mesafe + vibe filtre → mesafeye göre sırala.
- **Katıl:** `FlockRepository.join()` transaction (dolu/expired kontrolü) → host'a `notifyJoin` (best-effort).
- **Oluştur:** `invite_screen` → `FlockRepository.create()` → `expiresAt = now + 2sa`.
- **Mesafe filtresi tamamen istemcide** — tüm aktif flock'lar çekilip cihazda filtrelenir (ölçeklenme notu: STATUS).

## Yapılandırma gereksinimleri

- `firebase_options.dart` — proje `fluck-app-fv0kh` için doldurulmuş (web/android/ios).
- Google Maps API anahtarı: Android `AndroidManifest.xml` `com.google.android.geo.API_KEY`; iOS `AppDelegate.swift` `GMSServices.provideAPIKey(...)`.

---
İlgili: [PRODUCT.md](PRODUCT.md) (ne/neden) · [STATUS.md](STATUS.md) (yapıldı/yapılacak + riskler)
