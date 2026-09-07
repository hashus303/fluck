import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';

import 'notification_prefs.dart';

/// FCM push bildirimleri: izin iste, token'ı kullanıcının kaydına yaz, ön-planda
/// gelen bildirimi snackbar olarak göster.
///
/// Arka planda / uygulama kapalıyken bildirimi sistem tepsisi kendisi gösterir
/// (bot 'notification' payload'ı gönderir) — ek kod gerekmez. Push kritik
/// değildir: her adım sessizce hata yutar, uygulama akışını bozmaz.
class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  /// MaterialApp'e verilir — ön-plan bildiriminde snackbar için.
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  String? _token;
  String? _uid;
  bool _inited = false;

  /// Şu an açık olan sohbet. Zaten bakılan sohbetin mesajı için ön planda
  /// snackbar çıkarmak gürültü: kullanıcı mesajı balon olarak zaten gördü.
  /// (Sistem tepsisi bildirimi ön planda FCM tarafından zaten gösterilmiyor.)
  static String? openThreadId;

  Future<void> init() async {
    if (_inited || kIsWeb) return; // web push kapsam dışı
    _inited = true;
    try {
      final m = FirebaseMessaging.instance;
      await m.requestPermission(alert: true, badge: true, sound: true);
      _token = await m.getToken();
      if (_uid != null) await _write();
      m.onTokenRefresh.listen((t) async {
        _token = t;
        await _write();
      });
      FirebaseMessaging.onMessage.listen(_onForeground);
    } catch (_) {/* push kritik değil */}
  }

  /// Kullanıcı belli olunca çağrılır — token'ı onun private/push kaydına yazar.
  /// Idempotent: aynı uid için tekrar yazmaz.
  Future<void> registerFor(String uid) async {
    if (_uid == uid) return;
    _uid = uid;
    await _write();
    await NotificationPrefs.instance.load(uid);
  }

  Future<void> _write() async {
    final uid = _uid, token = _token;
    if (uid == null || token == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('private').doc('push')
          .set({
        'tokens': FieldValue.arrayUnion([token]),
        'platform':
            defaultTargetPlatform == TargetPlatform.iOS ? 'ios' : 'android',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void _onForeground(RemoteMessage msg) {
    // Kullanıcı bu türü kapattıysa ön planda da gösterme — ayar her yerde
    // aynı anlama gelsin.
    if (!NotificationPrefs.instance.allows(msg.data['type'] as String?)) return;
    final thread = msg.data['threadId'] as String?;
    if (thread != null && thread == openThreadId) return;
    final n = msg.notification;
    final parts = <String?>[n?.title ?? msg.data['title'], n?.body ?? msg.data['body']]
        .whereType<String>()
        .where((e) => e.isNotEmpty)
        .toList();
    if (parts.isEmpty) return;
    messengerKey.currentState?.showSnackBar(SnackBar(
      content: Text(parts.join(' · ')),
      behavior: SnackBarBehavior.floating,
    ));
  }
}
