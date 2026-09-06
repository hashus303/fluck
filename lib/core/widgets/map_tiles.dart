import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../theme/app_colors.dart';

/// Harita taban tile'larını uygulamanın sıcak coral temasıyla harmanlar.
/// Yalnızca taban harita etkilenir — marker'lar (VibeDot, konum pini) ayrı
/// katman olduğu için canlı kalır.
///
/// PERF: Eskiden her tile [ColorFiltered] ile sarılıyordu; bu tile başına bir
/// `saveLayer` (offscreen katman) açtığı için pan/zoom sırasında orta/düşük
/// cihazlarda donmaya yol açıyordu. Bunun yerine tile'ın üstüne tek bir yarı
/// saydam coral dikdörtgen boyuyoruz (foreground decoration = tek `drawRect`,
/// saveLayer yok) — görsel olarak aynı sıcaklık, neredeyse bedava.
///
/// Koyu şemada tint uygulanmaz: çevirme filtresini [darkMapLayer] katmanın
/// tamamına bir kez uygular, tint'in de çevrilmesi istenmez.
Widget themedTileBuilder(BuildContext context, Widget tile, TileImage image) {
  if (AppColors.isDark) return tile;
  return DecoratedBox(
    position: DecorationPosition.foreground,
    // AppColors.brandVivid (#FB5436) @ ~%5 alpha (0x0D).
    decoration: const BoxDecoration(color: Color(0x0DFB5436)),
    child: tile,
  );
}

/// OSM'in açık tile'larını koyu şemaya çevirir. Anahtarsız kalmak proje
/// kararı olduğu için karanlık tile sağlayıcısı yok, raster filtreleniyor.
///
/// Matris = ters çevirme + 180° RENK DÖNDÜRME. Düz ters çevirme yetmez:
/// açık mavi deniz kahverengiye, yeşil park mora döner. Döndürme mavinin
/// mavi, yeşilin yeşil kalmasını sağlar — yalnızca aydınlık ters döner.
const ColorFilter _darkMapFilter = ColorFilter.matrix(<double>[
  0.574, -1.430, -0.144, 0, 255, //
  -0.426, -0.430, -0.144, 0, 255, //
  -0.426, -1.430, 0.856, 0, 255, //
  0, 0, 0, 1, 0, //
]);

/// [TileLayer]'ı koyu şemada filtreyle sarar.
///
/// Filtre KATMANIN TAMAMINA bir kez uygulanır — tile başına değil. Eski donma
/// hatası tile başına `saveLayer` açmaktan geliyordu; burada ekran başına tek
/// katman açılır ve maliyet tile sayısıyla ölçeklenmez.
Widget darkMapLayer(Widget tileLayer) {
  if (!AppColors.isDark) return tileLayer;
  return ColorFiltered(colorFilter: _darkMapFilter, child: tileLayer);
}
