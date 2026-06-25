import 'dart:math' as math;

/// Basit enlem/boylam noktası.
class LatLng {
  final double lat;
  final double lng;
  const LatLng(this.lat, this.lng);
}

/// Kullanıcının o anki konumu + adı (şimdilik manuel/varsayılan; ileride GPS).
class UserLocation {
  final LatLng point;
  final String label; // "İstanbul" gibi gösterim etiketi
  const UserLocation(this.point, this.label);

  /// GPS gelene kadar varsayılan: İstanbul (Kadıköy çevresi).
  static const istanbul = UserLocation(LatLng(40.9900, 29.0290), 'İstanbul');
}

/// İki nokta arası mesafe (km) — Haversine formülü.
double haversineKm(LatLng a, LatLng b) {
  const earthKm = 6371.0;
  final dLat = _rad(b.lat - a.lat);
  final dLng = _rad(b.lng - a.lng);
  final lat1 = _rad(a.lat);
  final lat2 = _rad(b.lat);
  final h = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(lat1) * math.cos(lat2) * math.sin(dLng / 2) * math.sin(dLng / 2);
  return earthKm * 2 * math.atan2(math.sqrt(h), math.sqrt(1 - h));
}

double _rad(double deg) => deg * (math.pi / 180.0);

/// Mesafeyi okunur etikete çevirir: "350 m", "2.4 km", "37 km".
String distanceLabel(double km) {
  if (km < 1) return '${(km * 1000).round()} m';
  if (km < 10) return '${km.toStringAsFixed(1)} km';
  return '${km.round()} km';
}
