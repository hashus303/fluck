/// Harita tile sağlayıcısı — tek kaynak. Tüm harita ekranları buradan okur.
///
/// MapTiler anahtarı derleme sırasında `--dart-define=MAPTILER_KEY=...` ile
/// verilir; böylece anahtar (public) repoya girmez. Anahtar verilmezse ham
/// OpenStreetMap tile'larına düşer (geliştirme kolaylığı — üretim değil).
class MapConfig {
  MapConfig._();

  static const _key = String.fromEnvironment('MAPTILER_KEY');

  /// MapTiler stil kimliği. Başlangıçta sade/aydınlık 'dataviz'; MapTiler
  /// Studio'da coral markalı özel stil yapılıp buradaki id değiştirilebilir.
  static const style = String.fromEnvironment(
    'MAPTILER_STYLE',
    defaultValue: 'dataviz',
  );

  static bool get usingMapTiler => _key.isNotEmpty;

  /// TileLayer için url şablonu. [retina] hi-DPI ekranlarda keskin tile ister.
  static String urlTemplate({bool retina = false}) {
    if (!usingMapTiler) {
      return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
    final r = retina ? '@2x' : '';
    return 'https://api.maptiler.com/maps/$style/{z}/{x}/{y}$r.png?key=$_key';
  }

  /// Zorunlu atıf metni — sağlayıcıya göre değişir.
  static String get attribution => usingMapTiler
      ? '© MapTiler © OpenStreetMap contributors'
      : '© OpenStreetMap contributors';

  static const userAgentPackageName = 'com.hashus303.fluck';
}
