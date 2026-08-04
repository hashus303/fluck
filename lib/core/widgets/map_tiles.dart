import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../theme/app_colors.dart';

/// Harita taban tile'larını uygulamanın sıcak coral temasıyla harmanlar.
/// Yalnızca taban harita etkilenir — marker'lar (VibeDot, konum pini) ayrı
/// katman olduğu için canlı kalır. [alpha] ile coral yoğunluğu ayarlanır.
Widget themedTileBuilder(BuildContext context, Widget tile, TileImage image) {
  return ColorFiltered(
    colorFilter: ColorFilter.mode(
      AppColors.brand.withValues(alpha: 0.05),
      BlendMode.multiply,
    ),
    child: tile,
  );
}
