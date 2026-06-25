import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Uygulama dilini (TR/EN) yöneten ve seçimi kalıcı saklayan controller.
class LocaleController extends ChangeNotifier {
  static const _prefsKey = 'app_locale';
  static const supported = [Locale('en'), Locale('tr')];

  Locale _locale = const Locale('en');
  Locale get locale => _locale;

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final code = prefs.getString(_prefsKey);
      if (code != null && supported.any((l) => l.languageCode == code)) {
        _locale = Locale(code);
        notifyListeners();
      }
    } catch (_) {
      // SharedPreferences erişilemezse (ör. sandboxed iframe) sessizce geç.
    }
  }

  Future<void> setLocale(Locale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, locale.languageCode);
    } catch (_) {
      // Kalıcı kaydetme başarısız olsa da dil değişimi geçerli kalır.
    }
  }

  void toggle() {
    setLocale(_locale.languageCode == 'tr' ? const Locale('en') : const Locale('tr'));
  }
}

/// Alt ağaçtan controller'a erişim için InheritedNotifier.
class LocaleScope extends InheritedNotifier<LocaleController> {
  const LocaleScope({super.key, required LocaleController controller, required super.child})
      : super(notifier: controller);

  static LocaleController of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<LocaleScope>();
    assert(scope != null, 'LocaleScope bulunamadı');
    return scope!.notifier!;
  }
}
