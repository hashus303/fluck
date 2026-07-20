import 'package:cloud_firestore/cloud_firestore.dart';

import '../../notifications/data/notification_repository.dart';
import 'flock_doc.dart';

/// Firestore `flocks` koleksiyonu — gerçek flock oluşturma, dinleme, katılma.
class FlockRepository {
  FlockRepository._();
  static final FlockRepository instance = FlockRepository._();

  /// Varsayılan / azami aktif kalma süresi. Host oluştururken
  /// 30 dk – 2 sa arasında seçebilir (spontanelik penceresi).
  static const flockLifetime = Duration(hours: 2);

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('flocks');

  /// Süresi dolmamış flock'ları canlı dinler (en yeni biten en sonda).
  /// Mesafe filtresi istemci tarafında yapılır (konum cihazda).
  Stream<List<FlockDoc>> watchActive() {
    final now = Timestamp.now();
    return _col
        .where('expiresAt', isGreaterThan: now)
        .orderBy('expiresAt')
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => FlockDoc.fromMap(d.id, d.data()))
            .toList());
  }

  /// Kullanıcının üyesi olduğu, son [window] içinde süresi dolmuş flock'lar —
  /// "nasıl geçti?" puanlama istemi için. (Composite index gerektirir:
  /// memberUids CONTAINS + expiresAt ASC — firestore.indexes.json)
  Future<List<FlockDoc>> recentlyExpiredMine(String uid,
      {Duration window = const Duration(hours: 24)}) async {
    final now = DateTime.now();
    final snap = await _col
        .where('memberUids', arrayContains: uid)
        .where('expiresAt', isGreaterThan: Timestamp.fromDate(now.subtract(window)))
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();
    return snap.docs.map((d) => FlockDoc.fromMap(d.id, d.data())).toList();
  }

  /// Tek bir flock'u canlı dinler (detay ekranı için).
  Stream<FlockDoc?> watchOne(String id) => _col.doc(id).snapshots().map(
        (s) => (s.exists && s.data() != null) ? FlockDoc.fromMap(s.id, s.data()!) : null,
      );

  /// Yeni flock oluşturur; host otomatik ilk üye olur. Belge id'sini döner.
  Future<String> create({
    required String vibeId,
    required String venue,
    required String area,
    required String hostUid,
    required String hostName,
    required bool verifiedHost,
    required double lat,
    required double lng,
    required int total,
    Duration lifetime = flockLifetime,
  }) async {
    final now = DateTime.now();
    final ref = await _col.add({
      'vibeId': vibeId,
      'venue': venue,
      'area': area,
      'hostUid': hostUid,
      'hostName': hostName,
      'verifiedHost': verifiedHost,
      'lat': lat,
      'lng': lng,
      'total': total,
      'memberUids': [hostUid],
      'memberNames': {hostUid: hostName},
      'createdAt': FieldValue.serverTimestamp(),
      'expiresAt': Timestamp.fromDate(now.add(lifetime)),
    });
    return ref.id;
  }

  /// Kullanıcıyı flock'a ekler. Doluysa ya da süresi dolduysa hata fırlatır.
  /// Başarılı katılımda host'a uygulama-içi bildirim gönderir.
  Future<void> join(String flockId, String uid, String name) async {
    final ref = _col.doc(flockId);
    String? hostUid;
    String venue = '';
    var added = false;
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) {
        throw FlockJoinException('not-found');
      }
      final doc = FlockDoc.fromMap(snap.id, snap.data()!);
      if (doc.isExpired) throw FlockJoinException('expired');
      if (doc.memberUids.contains(uid)) return; // zaten üye
      if (doc.isFull) throw FlockJoinException('full');
      hostUid = doc.hostUid;
      venue = doc.venue;
      added = true;
      tx.update(ref, {
        'memberUids': FieldValue.arrayUnion([uid]),
        'memberNames.$uid': name,
      });
    });

    // Kendi flock'un değilse host'a haber ver (bildirim hatası katılmayı bozmasın).
    if (added && hostUid != null && hostUid != uid) {
      try {
        await NotificationRepository.instance.notifyJoin(
          hostUid: hostUid!,
          actorUid: uid,
          actorName: name,
          flockId: flockId,
          venue: venue,
        );
      } catch (_) {/* bildirim opsiyonel */}
    }
  }

  /// Kullanıcıyı flock'tan çıkarır. Host çıkarsa flock silinir.
  Future<void> leave(String flockId, String uid, String name) async {
    final ref = _col.doc(flockId);
    await FirebaseFirestore.instance.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final doc = FlockDoc.fromMap(snap.id, snap.data()!);
      if (doc.hostUid == uid) {
        tx.delete(ref);
        return;
      }
      tx.update(ref, {
        'memberUids': FieldValue.arrayRemove([uid]),
        'memberNames.$uid': FieldValue.delete(),
      });
    });
  }
}

class FlockJoinException implements Exception {
  final String code; // 'not-found' | 'expired' | 'full'
  FlockJoinException(this.code);
  @override
  String toString() => 'FlockJoinException($code)';
}
