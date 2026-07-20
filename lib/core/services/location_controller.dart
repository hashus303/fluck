import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'geo.dart';
import 'geocoding_service.dart';
import 'location_service.dart';

/// "Benim konumum" tek kaynağı — GPS ya da varsayılan (İstanbul), kalıcı.
/// Mesafe filtresi ve flock oluşturma bunu kullanır.
class LocationController extends ChangeNotifier {
  LatLng _point = UserLocation.istanbul.point;
  String _label = UserLocation.istanbul.label;
  bool _labelResolved = false;
  bool _isGps = false;
  bool _locating = false;

  LatLng get point => _point;
  String get label => _label;
  /// Etiket gerçek konumdan (reverse geocode) mi geldi, yoksa varsayılan mı?
  bool get labelResolved => _labelResolved;
  bool get isGps => _isGps;
  bool get locating => _locating;

  static const _kLat = 'loc_lat';
  static const _kLng = 'loc_lng';
  static const _kGps = 'loc_is_gps';
  static const _kLabel = 'loc_label';

  /// Önbellekten son konumu yükler (anında); sonra arka planda GPS dener.
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final lat = p.getDouble(_kLat);
      final lng = p.getDouble(_kLng);
      if (lat != null && lng != null) {
        _point = LatLng(lat, lng);
        _isGps = p.getBool(_kGps) ?? false;
        final label = p.getString(_kLabel);
        if (label != null && label.isNotEmpty) {
          _label = label;
          _labelResolved = true;
        }
        notifyListeners();
      }
    } catch (_) {/* prefs yoksa varsayılan kalır */}
    // İlk açılışta sessizce GPS dene (izin penceresi AÇMADAN —
    // izin daha önce verilmişse konum alınır, verilmemişse kullanıcı
    // "GPS kullan"a bastığında sorulur).
    await useDeviceLocation(silent: true);
  }

  /// Cihaz konumunu almayı dener. Başarısızsa mevcut konumu korur ve
  /// hata nedenini döner ([LocationError.none] = başarılı).
  /// [silent] true ise izin penceresi açılmaz.
  Future<LocationError> useDeviceLocation({bool silent = false}) async {
    _locating = true;
    notifyListeners();
    final res = await LocationService.instance.getCurrent(requestPermission: !silent);
    _locating = false;
    if (!res.ok) {
      notifyListeners();
      return res.error;
    }
    _point = res.point!;
    _isGps = true;
    await _persist();
    notifyListeners();
    _resolveLabel(_point); // arka planda; beklemeye gerek yok
    return LocationError.none;
  }

  /// Konumun bölge etiketini (ör. "Moda, Kadıköy") arka planda çözer.
  Future<void> _resolveLabel(LatLng at) async {
    final name = await GeocodingService.reverseLabel(at);
    if (name == null || name.isEmpty) return;
    // Geocode dönene kadar konum değiştiyse eski etiketi yazma.
    if (at.lat != _point.lat || at.lng != _point.lng) return;
    _label = name;
    _labelResolved = true;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_kLabel, name);
    } catch (_) {}
    notifyListeners();
  }

  Future<void> _persist() async {
    try {
      final p = await SharedPreferences.getInstance();
      await p.setDouble(_kLat, _point.lat);
      await p.setDouble(_kLng, _point.lng);
      await p.setBool(_kGps, _isGps);
    } catch (_) {}
  }
}

/// LocationController'ı ağaç boyunca paylaşır (LocaleScope ile aynı desen).
class LocationScope extends InheritedNotifier<LocationController> {
  const LocationScope({super.key, required LocationController controller, required super.child})
      : super(notifier: controller);

  static LocationController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocationScope>();
    assert(scope != null, 'LocationScope bulunamadı');
    return scope!.notifier!;
  }
}
