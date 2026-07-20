import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Şikayet ve engelleme — Play UGC politikası gereği zorunlu moderasyon.
///
/// - Şikayetler `reports` koleksiyonuna yazılır; istemci OKUYAMAZ
///   (yalnızca admin, konsol/araç üzerinden görür).
/// - Engel listesi `users/{uid}/private/blocks` belgesinde tutulur
///   (kilitli alan — yalnızca sahibi). Engellenen kullanıcının host'u ya da
///   üyesi olduğu flock'lar feed/haritada istemci tarafında gizlenir.
class ModerationRepository {
  ModerationRepository._();
  static final ModerationRepository instance = ModerationRepository._();

  /// Engellenen uid'ler — feed/harita filtreleri dinler.
  final ValueNotifier<Set<String>> blocked = ValueNotifier(<String>{});
  bool _blocksLoaded = false;

  DocumentReference<Map<String, dynamic>> _blocksDoc(String uid) =>
      FirebaseFirestore.instance
          .collection('users').doc(uid)
          .collection('private').doc('blocks');

  /// Engel listesini bir kez yükler (uygulama açılışında feed'den çağrılır).
  Future<void> loadBlocks(String uid) async {
    if (_blocksLoaded) return;
    try {
      final snap = await _blocksDoc(uid).get();
      final uids = List<String>.from(snap.data()?['uids'] ?? const []);
      blocked.value = uids.toSet();
      _blocksLoaded = true;
    } catch (_) {/* çevrimdışı — engelsiz devam */}
  }

  Future<void> block(String uid, String targetUid) async {
    final next = {...blocked.value, targetUid};
    blocked.value = next; // UI anında tepki versin
    await _blocksDoc(uid).set({
      'uids': next.toList(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Bu flock engellenen birini içeriyor mu? (host ya da üye)
  bool hidesFlock(String hostUid, List<String> memberUids) {
    final b = blocked.value;
    if (b.isEmpty) return false;
    return b.contains(hostUid) || memberUids.any(b.contains);
  }

  /// Şikayet oluşturur. reason: harassment|fake|no_show|safety|other.
  Future<void> report({
    required String reporterUid,
    required String reportedUid,
    required String reason,
    String? flockId,
    String? note,
  }) {
    return FirebaseFirestore.instance.collection('reports').add({
      'reporterUid': reporterUid,
      'reportedUid': reportedUid,
      'reason': reason,
      'flockId': ?flockId,
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
