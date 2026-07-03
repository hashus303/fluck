# Flock — Ürün Tanımı

> Spontan sosyal aktivite uygulaması. Kullanıcı akşam sıkıldığında uygulamayı açar,
> yakınındaki insanların anlık aktivite davetlerini görür (kahve, yürüyüş, bilardo vs.),
> katılır ya da kendi davetini yayınlar. **Davetler 2 saatte otomatik sona erer.**

## Temel fikir

- **Anlıklık:** Planlı değil, "şimdi" buluşmaları. Her davet (flock) 2 saatlik ömre sahip.
- **Yakınlık:** Mesafe filtresiyle (10/25/100 km / her yer) yalnızca yakındaki davetler.
- **Vibe odaklı:** Aktivite kategorileri — kahve, bar, yürüyüş, oyun, yemek, müzik.
- **Güvenlik öncelikli:** Grup buluşmaları, kimlik doğrulama, SOS — kadın güvenliği merkezde.

## Platform & Backend

| Katman | Teknoloji |
|--------|-----------|
| İstemci | Flutter (iOS + Android), feature-based mimari |
| Backend | Firebase: Firestore, Auth, (planlı) Cloud Functions, FCM |
| Konum/Harita | Google Maps API + `flutter_map`, `geolocator`, reverse-geocode |

## Güvenlik sistemi (ürün vizyonu)

Aşağıdakiler **hedeflenen** güvenlik özellikleridir. Hangilerinin kodda gerçekten
yapıldığını [STATUS.md](STATUS.md) gösterir.

1. **TC kimlik + selfie doğrulama** — gerçek kimlik garantisi
2. **Minimum 3 kişi** — 1-1 buluşma yok, hep grup
3. **Sadece partner mekanlar** — buluşma yalnızca anlaşmalı, güvenli mekanlarda
4. **Güvenilir kişiyle konum paylaşımı** — buluşma sırasında bir yakına canlı konum
5. **Check-in sistemi** — mekana varış / güvende olma teyidi
6. **SOS butonu (112 bağlantısı)** — acil durumda tek dokunuş
7. **AI sohbet moderasyonu** — taciz/uygunsuz içerik filtreleme
8. **Hesap puanlama (trust score)** — davranışa göre güven skoru

## Ana ekranlar

- **Harita + liste** — yakındaki davetler (mesafe + vibe filtreli)
- **Davet oluştur** — aktivite, mekan (haritadan), grup boyutu (3-8); 2 saat expiry
- **Profil + güven skoru**
- **Güvenlik merkezi** — SOS, konum paylaşımı, kimlik durumu, trust score

## Sözlük

- **Flock** — bir aktivite daveti / buluşma grubu (uygulamanın temel nesnesi)
- **Vibe** — aktivite kategorisi (coffee/bar/walk/games/food/music)
- **Host** — daveti oluşturan; otomatik ilk üye
- **Trust score** — kullanıcının güven puanı (0-100)

---
İlgili: [ARCHITECTURE.md](ARCHITECTURE.md) (kod haritası) · [STATUS.md](STATUS.md) (yapıldı/yapılacak)
