import 'package:geolocator/geolocator.dart';

import 'geo.dart';

/// Cihaz GPS'inden konum alır. İzin yoksa / kapalıysa / desteklenmiyorsa null döner.
class LocationService {
  LocationService._();
  static final LocationService instance = LocationService._();

  Future<LatLng?> getCurrent() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      // Web HTTP'de (HTTPS değil) ya da izin reddinde buraya düşer.
      return null;
    }
  }
}
