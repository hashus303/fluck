import 'package:cloud_firestore/cloud_firestore.dart';

/// Tek bir bildirim: birinin flock'una katılması ('join') ya da
/// admin doğrulama sonucu ('verification' — status: approved/rejected).
class AppNotification {
  final String id;
  final String type; // 'join' | 'verification'
  final String flockId;
  final String venue;
  final String actorName;
  final String status; // 'verification' için: 'approved' | 'rejected'
  final DateTime? createdAt;
  final bool read;

  const AppNotification({
    required this.id,
    required this.type,
    required this.flockId,
    required this.venue,
    required this.actorName,
    this.status = '',
    this.createdAt,
    this.read = false,
  });

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
        id: id,
        type: (m['type'] ?? 'join') as String,
        flockId: (m['flockId'] ?? '') as String,
        venue: (m['venue'] ?? '') as String,
        actorName: (m['actorName'] ?? '') as String,
        status: (m['status'] ?? '') as String,
        createdAt: (m['createdAt'] as Timestamp?)?.toDate(),
        read: (m['read'] ?? false) as bool,
      );
}

/// `users/{uid}/notifications` — uygulama-içi bildirim akışı.
class NotificationRepository {
  NotificationRepository._();
  static final NotificationRepository instance = NotificationRepository._();

  CollectionReference<Map<String, dynamic>> _col(String uid) =>
      FirebaseFirestore.instance.collection('users').doc(uid).collection('notifications');

  /// Birinin flock'a katıldığını host'a bildirir.
  /// [actorUid] yazan kişinin kimliği — Firestore kuralı sahteciliği engellemek
  /// için bunun request.auth.uid ile eşleşmesini ister.
  Future<void> notifyJoin({
    required String hostUid,
    required String actorUid,
    required String actorName,
    required String flockId,
    required String venue,
  }) async {
    await _col(hostUid).add({
      'type': 'join',
      'flockId': flockId,
      'venue': venue,
      'actorUid': actorUid,
      'actorName': actorName,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<AppNotification>> watch(String uid) => _col(uid)
      .orderBy('createdAt', descending: true)
      .limit(50)
      .snapshots()
      .map((s) => s.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());

  Stream<int> unreadCount(String uid) =>
      _col(uid).where('read', isEqualTo: false).snapshots().map((s) => s.docs.length);

  Future<void> markAllRead(String uid) async {
    final unread = await _col(uid).where('read', isEqualTo: false).get();
    final batch = FirebaseFirestore.instance.batch();
    for (final d in unread.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }
}
