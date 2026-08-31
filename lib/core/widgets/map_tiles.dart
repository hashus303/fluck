import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// Harita taban tile'larını uygulamanın sıcak coral temasıyla harmanlar.
/// Yalnızca taban harita etkilenir — marker'lar (VibeDot, konum pini) ayrı
/// katman olduğu için canlı kalır.
///
/// PERF: Eskiden her tile [ColorFiltered] ile sarılıyordu; bu tile başına bir
/// `saveLayer` (offscreen katman) açtığı için pan/zoom sırasında orta/düşük
/// cihazlarda donmaya yol açıyordu. Bunun yerine tile'ın üstüne tek bir yarı
/// saydam coral dikdörtgen boyuyoruz (foreground decoration = tek `drawRect`,
/// saveLayer yok) — görsel olarak aynı sıcaklık, neredeyse bedava.
Widget themedTileBuilder(BuildContext context, Widget tile, TileImage image) {
  return DecoratedBox(
    position: DecorationPosition.foreground,
    // AppColors.brand (#FB5436) @ ~%5 alpha (0x0D). const kalsın diye literal.
    decoration: const BoxDecoration(color: Color(0x0DFB5436)),
    child: tile,
  );
}
