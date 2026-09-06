import 'package:flutter/material.dart';

/// Flock Design System renk token'ları.
/// Kaynak: Flock App UI kit (coral marka, cream zemin, trust-green vurgular).
///
/// İki şema: açık (krem/kâğıt) ve koyu (kavrulmuş kahve). Koyu şema açığın
/// tersi DEĞİL — kendi yüzey basamakları ve kendi marka tonu var: koyu zeminde
/// derin coral kaybolduğu için marka aydınlanır ve üstündeki yazı koyulaşır
/// (Material 3'ün primary / on-primary kalıbı).
///
/// Semantik token'lar (`brand`, `bgPage`, `textBody` …) `_brightness`'a göre
/// çözülür; ham basamaklar (`coral500`, `ink900` …) sabittir. Renk seçerken
/// daima semantik olanı kullan — ham basamak yalnız şema tanımlarında geçmeli.
class AppColors {
  AppColors._();

  // ---------------------------------------------------------------------
  // Aktif şema
  // ---------------------------------------------------------------------

  static Brightness _brightness = Brightness.light;

  static bool get isDark => _brightness == Brightness.dark;

  /// Yalnızca [ThemeController] çağırır. Değişince ağacın yeniden kurulması
  /// gerekir (const alt ağaçlar kendiliğinden yeniden çizilmez) — main.dart'ta
  /// `KeyedSubtree` bunu yapar.
  static set brightness(Brightness value) => _brightness = value;

  static T _pick<T>(T light, T dark) => isDark ? dark : light;

  // ---------------------------------------------------------------------
  // Ham basamaklar — sabit
  // ---------------------------------------------------------------------

  // --- Coral (marka) ---
  static const coral50 = Color(0xFFFFF1ED);
  static const coral100 = Color(0xFFFFE0D6);
  static const coral200 = Color(0xFFFFC2AF);
  static const coral300 = Color(0xFFFF9B7E);
  static const coral400 = Color(0xFFFF7350);
  static const coral500 = Color(0xFFFB5436); // saf marka — parıltı/degrade
  static const coral650 = Color(0xFFD5300B); // açık şemanın markası (AA)
  static const coral700 = Color(0xFFBE2F18); // basılı hâl

  // --- Trust (güven / safe) ---
  static const trust50 = Color(0xFFE8F8F1);
  static const trust100 = Color(0xFFC7EFDD);
  static const trust300 = Color(0xFF54CB9C);
  static const trust400 = Color(0xFF3FBF8F);
  static const trust500 = Color(0xFF0E9669);
  static const trust550 = Color(0xFF0C8059); // açık şema success (AA)
  static const trust600 = Color(0xFF0A7B57);

  // --- Sky (info) ---
  static const sky300 = Color(0xFF6E9BEC);
  static const sky500 = Color(0xFF2D6BE0);
  static const sky600 = Color(0xFF1F54BD);

  // --- Ink (açık şema nötrleri) ---
  static const ink900 = Color(0xFF1A1512);
  static const ink800 = Color(0xFF2C2521);
  static const ink600 = Color(0xFF6B5E55);
  static const ink550 = Color(0xFF726560); // soluk metin (AA)
  static const ink300 = Color(0xFFD2C7BE);
  static const ink200 = Color(0xFFE8DFD8);
  static const ink100 = Color(0xFFF3ECE5);

  // --- Espresso (koyu şema nötrleri — sıcak, nötr gri değil) ---
  static const espresso900 = Color(0xFF0F0B0A); // çukur
  static const espresso800 = Color(0xFF16110F); // sayfa
  static const espresso700 = Color(0xFF211A17); // kart
  static const espresso600 = Color(0xFF2E2622); // ince kenarlık
  static const espresso500 = Color(0xFF3F3630); // belirgin kenarlık

  // --- Sand (koyu şema metni) ---
  static const sand50 = Color(0xFFF7F1EB);
  static const sand100 = Color(0xFFE3D9D1);
  static const sand300 = Color(0xFFB4A69C);
  static const sand400 = Color(0xFF9C8E84);

  // --- Açık yüzeyler ---
  static const cream = Color(0xFFFBF4EE);
  static const creamDeep = Color(0xFFF4EAE0);
  static const paper = Color(0xFFFFFFFF);

  // --- Durum renkleri ---
  static const amber500 = Color(0xFFF5A524);
  static const amber700 = Color(0xFFB87407); // açık şema warning (3:1)
  static const red300 = Color(0xFFFF6B70);
  static const red500 = Color(0xFFE5484D);
  static const red550 = Color(0xFFD61E24); // açık şema danger (AA)
  static const red600 = Color(0xFFCB2A30);

  // ---------------------------------------------------------------------
  // Semantik token'lar — şemaya göre çözülür
  // ---------------------------------------------------------------------

  static Color get brand => _pick(coral650, coral400);
  static Color get brandHover => _pick(coral700, coral300);
  static Color get brandSoft => _pick(coral50, const Color(0xFF33190F));

  /// Marka üstündeki yazı/ikon. Açıkta beyaz, koyuda kahve-siyah.
  static Color get onBrand => _pick(paper, espresso800);

  /// Saf marka corali — yalnız METİN TAŞIMAYAN yerlerde (parıltı, degrade,
  /// harita tint'i). Kontrast borcu doğurmaz, marka canlılığını korur.
  static const brandVivid = coral500;

  /// Tehlike yüzeyinin üstündeki yazı. Koyu şemada danger aydınlandığı için
  /// beyaz değil kahve-siyah olur.
  static Color get onDanger => _pick(paper, espresso800);

  /// Marka tonlu yumuşak yüzeyin bir basamak koyusu (degrade, kenarlık).
  static Color get brandSoftStrong => _pick(coral200, const Color(0xFF4A2317));

  static Color get success => _pick(trust550, trust400);
  static Color get successSoft => _pick(trust50, const Color(0xFF0E2A20));
  static Color get info => _pick(sky600, sky300);
  static Color get warning => _pick(amber700, amber500);
  static Color get danger => _pick(red550, red300);
  static Color get dangerSoft => _pick(const Color(0xFFFDECEC), const Color(0xFF2A1614));

  /// Sayfadan kasıtlı olarak KOPAN dolu yüzey ("şansına bırak" slab'ı, seçili
  /// mesafe çipi). Açıkta krem üstünde gece siyahı; koyuda kahve üstünde kum.
  /// Renk değil İLİŞKİ korunur — iki şemada da sayfanın en zıt öğesi.
  static Color get inverseSurface => _pick(ink900, sand100);
  static Color get inverseSurfaceAlt =>
      _pick(const Color(0xFF3A3F52), const Color(0xFFC6CBDA));
  static Color get onInverseSurface => _pick(paper, espresso800);

  /// Marka degradesi — dolu banner ve rozetler. Açıkta derin (beyaz yazı),
  /// koyuda parlak (koyu yazı); iki uçta da [onBrand] okunur kalır.
  static List<Color> get brandGradient =>
      isDark ? const [coral400, coral300] : const [coral650, coral700];

  static Color get bgPage => _pick(cream, espresso800);
  static Color get surfaceSunken => _pick(creamDeep, espresso900);
  static Color get surfaceCard => _pick(paper, espresso700);
  static Color get borderSubtle => _pick(ink200, espresso600);
  static Color get borderStrong => _pick(ink300, espresso500);
  static Color get divider => _pick(ink100, espresso600);

  static Color get textStrong => _pick(ink900, sand50);
  static Color get textBody => _pick(ink800, sand100);
  static Color get textMuted => _pick(ink600, sand300);
  static Color get textFaint => _pick(ink550, sand400);

  // --- Vibe (kategori) renkleri — koyu şemada aydınlatılır ---
  static Color get vibeCoffee => _pick(const Color(0xFFB87333), const Color(0xFFDDA05C));
  static Color get vibeBar => _pick(const Color(0xFF7C3AED), const Color(0xFFB794F6));
  static Color get vibeWalk => _pick(const Color(0xFF1F54BD), sky300);
  static Color get vibeGames => _pick(const Color(0xFFA81E8E), const Color(0xFFE879CF));
  static Color get vibeFood => _pick(const Color(0xFFC2551A), const Color(0xFFF08B4E));
  static Color get vibeMusic => _pick(const Color(0xFFC2185B), const Color(0xFFF472A6));

  // ---------------------------------------------------------------------
  // Gölgeler — açıkta sıcak tonlu, koyuda derin (tonal elevation'a yardımcı)
  // ---------------------------------------------------------------------

  static List<BoxShadow> get shadowCard => isDark
      ? const [
          BoxShadow(color: Color(0x66000000), blurRadius: 16, offset: Offset(0, 6)),
        ]
      : const [
          BoxShadow(color: Color(0x0D281810), blurRadius: 4, offset: Offset(0, 2)),
          BoxShadow(color: Color(0x14281810), blurRadius: 16, offset: Offset(0, 6)),
        ];

  static List<BoxShadow> get shadowSm => isDark
      ? const [
          BoxShadow(color: Color(0x59000000), blurRadius: 6, offset: Offset(0, 2)),
        ]
      : const [
          BoxShadow(color: Color(0x0F281810), blurRadius: 2, offset: Offset(0, 1)),
          BoxShadow(color: Color(0x0D281810), blurRadius: 6, offset: Offset(0, 2)),
        ];

  static List<BoxShadow> get glowCoral => isDark
      ? const [
          BoxShadow(color: Color(0x4DFF7350), blurRadius: 22, offset: Offset(0, 6)),
        ]
      : const [
          BoxShadow(color: Color(0x52FB5436), blurRadius: 20, offset: Offset(0, 6)),
        ];

  static List<BoxShadow> get glowDanger => isDark
      ? const [
          BoxShadow(color: Color(0x4DFF6B70), blurRadius: 18, offset: Offset(0, 6)),
        ]
      : const [
          BoxShadow(color: Color(0x57E5484D), blurRadius: 18, offset: Offset(0, 6)),
        ];
}
