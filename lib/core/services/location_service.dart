import 'package:geolocator/geolocator.dart';

import 'geo.dart';

/// Konum alma sonucundaki hata türü — UI doğru mesajı göstersin diye.
enum LocationError { none, serviceDisabled, denied, deniedForever, failed }

/// Konum sonucu — [point] varsa başarılı, yoksa [error] nedeni verir.
class LocationResult {
  final LatLng? point;
  final LocationError error;
  const LocationResult(this.point, this.error);
  bool get ok => point != null;
}

/// Cihaz GPS'inden konum alır. İzin/servis durumunu ayırt eder,
/// zaman aşımında son bilinen konuma düşer.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LocationResult> getCurrent() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return const LocationResult(null, LocationError.serviceDisabled);
      }

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        return const LocationResult(null, LocationError.deniedForever);
      }
      if (perm == LocationPermission.denied) {
        return const LocationResult(null, LocationError.denied);
      }

      // Yüksek doğruluk 12 sn ile sınırlı; takılırsa son bilinen konuma düş.
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 12),
          ),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) return const LocationResult(null, LocationError.failed);
      return LocationResult(LatLng(pos.latitude, pos.longitude), LocationError.none);
    } catch (_) {
      // Web HTTP'de (HTTPS değil) ya da beklenmeyen hatada buraya düşer.
      return const LocationResult(null, LocationError.failed);
    }
  }

  /// Uygulama ayarları ekranını açar (izin "kalıcı reddedildi" ise).
  Future<void> openSettings() => Geolocator.openAppSettings();
}
