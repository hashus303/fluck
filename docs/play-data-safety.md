# Play Console — Veri Güvenliği (Data Safety) Beyanı

> Bu dosya, Play Console'daki **Uygulama içeriği → Veri güvenliği** formunun
> cevaplarıdır. Kodun kendisinden çıkarıldı; tahmin yok. Formu doldururken
> aşağıdaki tabloları birebir uygula.
>
> Kaynak sürüm: `1.0.1+9` · Hazırlandı: 6 Eylül 2026
> Gizlilik politikası URL'i: `https://hashus303.github.io/fluck/privacy-policy.html`

---

## 0. Genel sorular

| Soru | Cevap | Gerekçe |
|---|---|---|
| Uygulamanız kullanıcı verisi topluyor mu? | **Evet** | Hesap, profil, konum, selfie |
| Verileri üçüncü taraflarla paylaşıyor musunuz? | **Hayır** | Reklam ağı yok, analitik yok, satış yok. Firebase bir *işleyici*, "paylaşım" sayılmaz |
| Aktarımda şifreleniyor mu? | **Evet** | Tüm trafik HTTPS (Firebase, OSM, ipify) |
| Kullanıcı silme talep edebilir mi? | **Evet** | Uygulama içinden Profil → "Hesabı sil" + web formu |
| Bağımsız güvenlik denetimi | **Hayır** | Yaptırılmadı |
| Aile Programı | **Hayır** | 18+ uygulama |

**Silme URL'i:** `https://hashus303.github.io/fluck/hesap-silme.html`

---

## 1. Kişisel bilgiler (Personal info)

| Veri türü | Topl. | Payl. | Zorunlu | Amaç |
|---|---|---|---|---|
| **E-posta adresi** | ✅ | ❌ | Zorunlu | Hesap yönetimi, giriş |
| **Ad** | ✅ | ❌ | Zorunlu | Uygulama işlevi (profilde ve flock'ta görünür) |
| **Kullanıcı kimlikleri** (Firebase UID) | ✅ | ❌ | Zorunlu | Hesap yönetimi |
| **Diğer bilgiler** (yaş, ilgi alanları) | ✅ | ❌ | Zorunlu | Uygulama işlevi (eşleştirme, 18+ denetimi) |

> Adres, telefon, ırk/etnik köken, siyasi görüş, cinsel yönelim **toplanmıyor**.

## 2. Konum (Location)

| Veri türü | Topl. | Payl. | Zorunlu | Amaç |
|---|---|---|---|---|
| **Yaklaşık konum** | ✅ | ❌ | İsteğe bağlı | Uygulama işlevi — yakındaki flock'lar |
| **Hassas konum** | ✅ | ❌ | İsteğe bağlı | Uygulama işlevi + **Dolandırıcılık önleme** |

**Neden hassas konum:** `LocationAccuracy.high` kullanılıyor ve buluşma noktası
koordinatı flock'a yazılıyor. Ayrıca selfie doğrulaması sırasında konum,
sahtecilik denetimi için kaydediliyor → **"Dolandırıcılık önleme, güvenlik ve
uyumluluk"** amacını da işaretle.

> "İsteğe bağlı" çünkü kullanıcı izni reddederse uygulama şehir seçimiyle
> çalışmaya devam eder.

## 3. Fotoğraflar ve videolar (Photos and videos)

| Veri türü | Topl. | Payl. | Zorunlu | Amaç |
|---|---|---|---|---|
| **Fotoğraflar** | ✅ | ❌ | Zorunlu | Uygulama işlevi + **Dolandırıcılık önleme** |

**Neden zorunlu:** doğrulama selfie'si olmadan hesap uygulamaya giremiyor
(doğrulama kapısı). Profil fotoğrafı da aynı kalemde.

## 4. Uygulama etkinliği (App activity)

| Veri türü | Topl. | Payl. | Zorunlu | Amaç |
|---|---|---|---|---|
| **Uygulama içi etkileşimler** | ✅ | ❌ | Zorunlu | Uygulama işlevi (oluşturulan/katılınan flock'lar, güven skoru) |

## 5. Uygulama bilgileri ve performansı

**Hiçbiri.** Crashlytics, Analytics veya benzeri bir SDK **yok** — pubspec'te
doğrulandı. Kilitlenme günlüğü, tanılama, performans verisi toplanmıyor.

## 6. Cihaz veya diğer kimlikler (Device or other IDs)

| Veri türü | Topl. | Payl. | Zorunlu | Amaç |
|---|---|---|---|---|
| **Cihaz veya diğer kimlikler** | ✅ | ❌ | İsteğe bağlı | Uygulama işlevi (push bildirim) + **Dolandırıcılık önleme** |

Kapsam: **FCM bildirim jetonu** ve doğrulama anında kaydedilen **IP adresi**.
Kullanıcı bildirim izni vermezse jeton alınmaz → isteğe bağlı.

---

## 7. Formda İŞARETLENMEYECEKLER

Yanlışlıkla işaretlenmesin diye açıkça yazıyorum — bunların hiçbiri toplanmıyor:

- Finansal bilgi (ödeme yok; Play Billing bağlanınca Google işler, sen değil)
- Sağlık ve fitness
- Mesajlar (SMS/e-posta içeriği)
- Kişiler (rehber)
- Takvim
- Dosyalar ve belgeler
- Ses / müzik
- Arama ve tarama geçmişi
- Reklam kimliği (reklam yok)

---

## 8. İzin gerekçeleri (Play sorarsa)

| İzin | Gerekçe |
|---|---|
| `ACCESS_FINE_LOCATION` | Yakındaki flock'ları mesafeye göre sıralamak ve buluşma noktasını haritadan seçmek. Arka planda konum **yok**. |
| `ACCESS_COARSE_LOCATION` | Kullanıcı hassas konumu reddederse semt düzeyinde çalışmak. |
| `POST_NOTIFICATIONS` | Doğrulama sonucu, flock'a katılım ve duyuru bildirimleri. Türü kullanıcı Profil → Bildirimler'den kapatabilir. |
| `INTERNET` | Firebase ve harita servisleri. |

> **Arka plan konum izni istemiyoruz** — Play'in en sık takıldığı yer burası.
> `ACCESS_BACKGROUND_LOCATION` manifest'te **yok**, doğrulandı.

---

## 9. Mağaza listesi için hatırlatmalar

- **İçerik derecelendirmesi:** 18+ / Olgun. Uygulama tanışma özelliği içeriyor
  (Date modu) — derecelendirme anketinde "kullanıcılar arası etkileşim" ve
  "kullanıcı tarafından oluşturulan içerik" **evet** işaretlenmeli.
- **Hedef kitle:** 18 ve üzeri. Çocuklara yönelik **değil**.
- **Kullanıcı tarafından oluşturulan içerik:** Evet → moderasyon ve şikâyet
  mekanizması olduğunu belirt (engelleme + rapor + admin incelemesi var).
- **Veri silme:** Hem uygulama içi hem web formu URL'i istenir; ikisi de hazır.
