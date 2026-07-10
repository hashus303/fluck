import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'geo.dart';
import 'location_service.dart';

/// "Benim konumum" tek kaynağı — GPS ya da varsayılan (İstanbul), kalıcı.
/// Mesafe filtresi ve flock oluşturma bunu kullanır.
class LocationController extends ChangeNotifier {
  LatLng _point = UserLocation.istanbul.point;
  final String _label = UserLocation.istanbul.label;
  bool _isGps = false;
  bool _locating = false;

  LatLng get point => _point;
  String get label => _label;
  bool get isGps => _isGps;
  bool get locating => _locating;

  static const _kLat = 'loc_lat';
  static const _kLng = 'loc_lng';
  static const _kGps = 'loc_is_gps';

  /// Önbellekten son konumu yükler (anında); sonra arka planda GPS dener.
  Future<void> load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final lat = p.getDouble(_kLat);
      final lng = p.getDouble(_kLng);
      if (lat != null && lng != null) {
        _point = LatLng(lat, lng);
        _isGps = p.getBool(_kGps) ?? false;
        notifyListeners();
      }
    } catch (_) {/* prefs yoksa varsayılan kalır */}
    // İlk açılışta sessizce GPS dene.
    await useDeviceLocation(silent: true);
  }

  /// Cihaz konumunu almayı dener. Başarısızsa mevcut konumu korur ve
  /// hata nedenini döner ([LocationError.none] = başarılı).
  Future<LocationError> useDeviceLocation({bool silent = false}) async {
    _locating = true;
    notifyListeners();
    final res = await LocationService.instance.getCurrent();
    _locating = false;
    if (!res.ok) {
      notifyListeners();
      return res.error;
    }
    _point = res.point!;
    _isGps = true;
    await _persist();
    notifyListeners();
    return LocationError.none;
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
