# fluck

Flutter tabanlı mobil uygulama. Firebase (Auth + Firestore) ve Google Maps entegrasyonu ile feature-based mimari kullanır.

## 📚 Dokümantasyon

- [docs/PRODUCT.md](docs/PRODUCT.md) — Flock ne, neden (ürün tanımı + güvenlik vizyonu)
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) — kod haritası, veri modelleri, Firestore şeması
- [docs/STATUS.md](docs/STATUS.md) — yapıldı / yapılacak + bilinen riskler

> Yeni bir oturuma başlarken önce bu üç dosyayı oku — kodu baştan taramaya gerek kalmaz.

## Teknolojiler

- **Flutter** (Dart)
- **firebase_core / firebase_auth** — kimlik doğrulama
- **cloud_firestore** — veritabanı
- **google_maps_flutter** — harita

## Klasör Yapısı

```
lib/
├── main.dart
├── firebase_options.dart        # flutterfire configure ile üretilir
├── core/
│   ├── services/                # FirebaseService vb. ortak servisler
│   └── widgets/
└── features/
    ├── auth/                    # giriş / kayıt
    │   ├── data/
    │   └── presentation/
    ├── home/
    │   ├── data/
    │   └── presentation/
    ├── invite/                  # davet akışı
    │   ├── data/
    │   └── presentation/
    ├── profile/
    │   ├── data/
    │   └── presentation/
    └── safety/                  # güvenlik özellikleri
        ├── data/
        └── presentation/
```

Her feature kendi `data` (model/repository) ve `presentation` (UI) katmanlarını içerir.

## Kurulum

```bash
flutter pub get
```

### Firebase yapılandırması

`lib/firebase_options.dart` şu an bir iskelettir. Gerçek değerleri üretmek için:

```bash
dart pub global activate flutterfire_cli
flutterfire configure --project=<firebase-proje-id>
```

Bu komut Android/iOS yapılandırma dosyalarını ve `firebase_options.dart` dosyasını oluşturur.

### Google Maps API anahtarı

- **Android:** `android/app/src/main/AndroidManifest.xml` içine `com.google.android.geo.API_KEY` meta-data ekleyin.
- **iOS:** `ios/Runner/AppDelegate.swift` içinde `GMSServices.provideAPIKey("...")` çağrısı ekleyin.

## Çalıştırma

```bash
flutter run
```

> Not: Firebase yapılandırması yapılmadan da uygulama iskelet olarak çalışır;
> `FirebaseService.init()` yapılandırma eksikse hatayı yakalayıp loglar.
