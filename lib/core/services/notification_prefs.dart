import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Kullanıcının bildirim tercihleri.
///
/// NEDEN VAR: rakip analizinde (Meetup) negatif yorumların %8'i "aşırı
/// bildirim" — *"10 dakikadır bildirimden uygulamayı açamadım"*. Tek bir
/// aç/kapa yetmez; kullanıcı hangi TÜR bildirimi istediğini seçebilmeli.
///
/// Tercihler `users/{uid}/private/push` belgesinde token'larla AYNI yerde
/// tutulur; böylece sunucu (admin botu) push atmadan önce tek okumayla hem
/// token'ı hem tercihi görür.
class NotificationPrefs {
  NotificationPrefs._();
  static final NotificationPrefs instance = NotificationPrefs._();

  /// Varsayılan: hepsi açık. Kullanıcı kısıtlamayı kendisi seçer.
  static const _defaults = <String, bool>{
    'notifJoins': true,
    'notifAnnouncements': true,
    'notifVerification': true,
  };

  final ValueNotifier<Map<String, bool>> prefs =
      ValueNotifier<Map<String, bool>>(Map.of(_defaults));

  String? _uid;

  bool get joins => prefs.value['notifJoins'] ?? true;
  bool get announcements => prefs.value['notifAnnouncements'] ?? true;
  bool get verification => prefs.value['notifVerification'] ?? true;

  /// Bildirim türünün adına göre izin. Bilinmeyen tür ENGELLENMEZ — yeni bir
  /// tür eklendiğinde sessizce kaybolmasın.
  bool allows(String? type) => switch (type) {
        'join' => joins,
        'announcement' => announcements,
        'verification' || 'verification_rejected' => verification,
        _ => true,
      };

  Future<void> load(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc('push')
          .get();
      final data = snap.data() ?? const <String, dynamic>{};
      prefs.value = {
        for (final k in _defaults.keys) k: data[k] as bool? ?? _defaults[k]!,
      };
    } catch (_) {
      // Okunamadıysa varsayılanlarla devam — bildirim tercihi kritik değil.
    }
  }

  Future<void> set(String key, bool value) async {
    if (!_defaults.containsKey(key)) return;
    prefs.value = {...prefs.value, key: value};
    final uid = _uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('private')
          .doc('push')
          .set({key: value}, SetOptions(merge: true));
    } catch (_) {
      // Yazılamazsa bu oturumda geçerli kalır; bir sonraki açılışta tazelenir.
    }
  }
}
