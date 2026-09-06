import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_colors.dart';

/// Açık/koyu şemayı yöneten controller.
///
/// Varsayılan sistemi takip eder; kullanıcı isterse sabitleyebilir. Seçim
/// [SharedPreferences]'ta saklanır ve [AppColors]'a yazılır — token'lar
/// oradan okuduğu için tüm ekranlar tek kaynaktan beslenir.
class ThemeController extends ChangeNotifier with WidgetsBindingObserver {
  static const _prefsKey = 'app_theme_mode';

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;

  /// Ağacın yeniden kurulması için anahtar: şema değişince artar.
  /// (const alt ağaçlar kendiliğinden yeniden çizilmediğinden gerekir.)
  int _generation = 0;
  int get generation => _generation;

  /// Uygulama açılışında, ilk kare çizilmeden çağrılır.
  void start() {
    WidgetsBinding.instance.addObserver(this);
    _apply(notify: false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Sistem teması değişti (kullanıcı gece modunu açtı/kapattı).
  @override
  void didChangePlatformBrightness() {
    if (_mode == ThemeMode.system) _apply();
  }

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString(_prefsKey);
      final parsed = switch (saved) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
      if (parsed != _mode) {
        _mode = parsed;
        _apply();
      }
    } catch (_) {
      // Tercih okunamazsa sistemi takip etmeye devam et.
    }
  }

  Future<void> setMode(ThemeMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    _apply();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, mode.name);
    } catch (_) {
      // Kalıcı kayıt başarısız olsa da seçim bu oturumda geçerli.
    }
  }

  /// Sistem → açık → koyu → sistem.
  void cycle() => setMode(switch (_mode) {
        ThemeMode.system => ThemeMode.light,
        ThemeMode.light => ThemeMode.dark,
        ThemeMode.dark => ThemeMode.system,
      });

  Brightness get _resolved => switch (_mode) {
        ThemeMode.light => Brightness.light,
        ThemeMode.dark => Brightness.dark,
        ThemeMode.system =>
          WidgetsBinding.instance.platformDispatcher.platformBrightness,
      };

  void _apply({bool notify = true}) {
    final next = _resolved;
    if (next == (AppColors.isDark ? Brightness.dark : Brightness.light)) {
      if (notify) notifyListeners(); // mod değişti ama şema aynı (ör. sistem→açık)
      return;
    }
    AppColors.brightness = next;
    _generation++;
    if (notify) notifyListeners();
  }
}
