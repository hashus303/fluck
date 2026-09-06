import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Çevrimiçi/çevrimdışı durumunu izler.
///
/// İKİ AŞAMALI, çünkü tek başına yeterli değiller:
/// - [Connectivity] yalnızca AĞ ARAYÜZÜ olup olmadığını söyler. İnternetsiz
///   bir Wi-Fi'ye bağlıyken "bağlı" der ama hiçbir şey yüklenmez.
/// - Bu yüzden arayüz varken ayrıca gerçek bir ERİŞİM SINAMASI yapılır.
///
/// Yanlış alarm vermemek için varsayılan "çevrimiçi": ilk sınama bitene kadar
/// kullanıcıya uyarı gösterilmez.
class ConnectivityService with WidgetsBindingObserver {
  ConnectivityService._();
  static final ConnectivityService instance = ConnectivityService._();

  /// Uygulamanın tamamı bunu dinler.
  final ValueNotifier<bool> online = ValueNotifier<bool>(true);

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _sub;
  Timer? _retry;
  bool _probing = false;

  /// Çevrimdışıyken kendi kendine tekrar dener.
  ///
  /// Arayüz olayı beklemek yetmez: Wi-Fi bağlı ama internet yokken hiçbir
  /// [Connectivity] olayı gelmez ve şerit kullanıcı elle denemedikçe asılı
  /// kalırdı. Çevrimiçiyken timer kapalı — boşa yoklama yok.
  static const _retryInterval = Duration(seconds: 6);

  void init() {
    WidgetsBinding.instance.addObserver(this);
    _sub = _connectivity.onConnectivityChanged.listen((_) => refresh());
    refresh();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    _retry?.cancel();
  }

  /// Uygulama öne gelince tazele — arka planda bağlantı değişmiş olabilir.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refresh();
  }

  Future<void> refresh() async {
    if (_probing) return;
    _probing = true;
    try {
      final results = await _connectivity.checkConnectivity();
      final hasInterface =
          results.any((r) => r != ConnectivityResult.none);
      _setOnline(hasInterface && await _reachable());
    } catch (_) {
      // Sınama kurulamadıysa kullanıcıyı yanlış yere yönlendirmektense
      // çevrimiçi say — uyarı yalnızca EMİN olduğumuzda çıksın.
      _setOnline(true);
    } finally {
      _probing = false;
    }
  }

  void _setOnline(bool value) {
    online.value = value;
    if (value) {
      _retry?.cancel();
      _retry = null;
    } else {
      _retry ??= Timer.periodic(_retryInterval, (_) => refresh());
    }
  }

  /// Gerçekten dışarı çıkabiliyor muyuz? Kısa DNS sınaması; ek paket
  /// gerektirmez ve kaptif portal arkasındaki sahte bağlantıyı yakalar.
  Future<bool> _reachable() async {
    if (kIsWeb) return true; // tarayıcıda dart:io yok
    try {
      final r = await InternetAddress.lookup('firestore.googleapis.com')
          .timeout(const Duration(seconds: 4));
      return r.isNotEmpty && r.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } on TimeoutException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
