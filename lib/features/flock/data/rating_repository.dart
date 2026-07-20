import 'package:cloud_firestore/cloud_firestore.dart';

/// `ratings/{flockId_raterUid_ratedUid}` — buluşma sonrası üye puanları.
/// Belge kimliği deterministik: aynı flock'ta aynı kişiye ikinci kez puan
/// verilemez (create var olan belgeye çakışır, kurallar update'i yasaklar).
/// Kurallar ayrıca: yalnızca flock üyeleri, yalnızca süre dolduktan sonra,
/// kendine puan yok, 1-5 arası tam sayı.
class RatingRepository {
  RatingRepository._();
  static final RatingRepository instance = RatingRepository._();

  CollectionReference<Map<String, dynamic>> get _col =>
      FirebaseFirestore.instance.collection('ratings');

  String _id(String flockId, String raterUid, String ratedUid) =>
      '${flockId}_${raterUid}_$ratedUid';

  /// Bir üyeye yıldız verir. Aynı üyeye ikinci kez verilirse
  /// permission-denied fırlar (kurallar gereği) — çağıran yutabilir.
  Future<void> rate({
    required String flockId,
    required String raterUid,
    required String ratedUid,
    required int stars,
  }) {
    return _col.doc(_id(flockId, raterUid, ratedUid)).set({
      'flockId': flockId,
      'raterUid': raterUid,
      'ratedUid': ratedUid,
      'stars': stars,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Bu flock'ta puanladığım üyelerin uid'leri (tekrar sormamak için).
  Future<Set<String>> ratedUidsInFlock(String flockId, String raterUid) async {
    final snap = await _col
        .where('flockId', isEqualTo: flockId)
        .where('raterUid', isEqualTo: raterUid)
        .get();
    return {for (final d in snap.docs) (d.data()['ratedUid'] ?? '') as String};
  }

  /// Kullanıcının ALDIĞI puanların ortalaması ve sayısı (trust score +
  /// profil istatistiği için). Hiç puan yoksa null döner.
  Future<({double avg, int count})?> received(String uid) async {
    final snap = await _col.where('ratedUid', isEqualTo: uid).get();
    if (snap.docs.isEmpty) return null;
    var sum = 0;
    for (final d in snap.docs) {
      sum += ((d.data()['stars'] ?? 0) as num).toInt();
    }
    return (avg: sum / snap.docs.length, count: snap.docs.length);
  }
}

/// Profil sinyalleri + alınan yıldızlardan birleşik güven skoru (0-100).
/// Puan yoksa yalnızca sinyal skoru (mevcut davranış). Puan varsa:
/// %60 sinyaller + %40 yıldız ortalaması (1★=0, 5★=tam puan).
int combinedTrustScore(int signalScore, double? ratingAvg) {
  if (ratingAvg == null) return signalScore;
  final ratingPart = ((ratingAvg - 1) / 4 * 100).clamp(0, 100);
  return (signalScore * 0.6 + ratingPart * 0.4).round().clamp(0, 100);
}
