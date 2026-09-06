import 'package:cloud_firestore/cloud_firestore.dart';

/// Seni beğenen kişi.
class Admirer {
  final String uid;
  final String name;
  final int age;
  final DateTime? at;

  /// Sen de onu beğendin mi? (karşılıklı)
  final bool mutual;

  const Admirer({
    required this.uid,
    required this.name,
    required this.age,
    required this.mutual,
    this.at,
  });
}

/// "Seni kim beğendi" verisi — Flock+ özelliği.
///
/// GÜVENLİK: `likes` kuralı okumayı yalnızca iki tarafa açar. Buradaki sorgu
/// `to == ben` olduğu için kural sağlanır; başkasının beğeni listesi
/// çekilemez (bkz. firestore.rules).
class LikesRepository {
  LikesRepository._();
  static final LikesRepository instance = LikesRepository._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Beğeni sayısı — kalp üzerindeki rozet için. Rozet "9+"da doyduğundan
  /// dinlenen veri 10 ile sınırlı.
  Stream<int> incomingCount(String uid) => _db
      .collection('likes')
      .where('to', isEqualTo: uid)
      .limit(10)
      .snapshots()
      .map((s) => s.docs.length);

  /// Seni beğenenler, yenisi üstte.
  Future<List<Admirer>> incoming(String uid, {int limit = 50}) async {
    final snap = await _db
        .collection('likes')
        .where('to', isEqualTo: uid)
        .limit(limit)
        .get();

    // Kendi beğendiklerim — karşılıklıyı saptamak için tek okuma.
    final mine = await _likedByMe(uid);

    final rows = <Admirer>[];
    for (final d in snap.docs) {
      final from = d.data()['from'] as String?;
      if (from == null || from == uid) continue;
      final profile = await _db.collection('users').doc(from).get();
      final m = profile.data();
      if (m == null) continue; // hesap silinmiş
      rows.add(Admirer(
        uid: from,
        name: (m['name'] as String?) ?? '',
        age: (m['age'] as num?)?.toInt() ?? 0,
        mutual: mine.contains(from),
        at: (d.data()['createdAt'] as Timestamp?)?.toDate(),
      ));
    }
    rows.sort((a, b) {
      if (a.mutual != b.mutual) return a.mutual ? -1 : 1; // karşılıklı üstte
      final x = a.at, y = b.at;
      if (x == null || y == null) return 0;
      return y.compareTo(x);
    });
    return rows;
  }

  Future<Set<String>> _likedByMe(String uid) async {
    try {
      final snap = await _db
          .collection('users').doc(uid)
          .collection('private').doc('swipes')
          .get();
      return ((snap.data()?['liked'] as List?) ?? const [])
          .whereType<String>()
          .toSet();
    } catch (_) {
      return <String>{};
    }
  }
}
