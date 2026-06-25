import 'package:cloud_firestore/cloud_firestore.dart';

/// Test verisi — farklı şehirlerde örnek flock'lar yazar ki mesafe filtresi
/// gerçek Firestore verisiyle denenebilsin. Sadece geliştirme amaçlı.
///
/// Tüm flock'lar [hostUid] (dev hesabı) tarafından yazılır (kurallar gereği),
/// ama üyeler farklı NPC isimleridir; böylece dev bunlara "Katıl"abilir.
class DevSeeder {
  DevSeeder._();

  static const _samples = <Map<String, dynamic>>[
    // — İstanbul (Kadıköy çevresi, yakın) —
    {'vibeId': 'bar', 'venue': 'Karga Bar', 'area': 'Kadıköy', 'host': 'Mara', 'lat': 40.9895, 'lng': 29.0270, 'total': 5, 'mins': 96, 'members': ['Mara', 'Deniz', 'Lee']},
    {'vibeId': 'coffee', 'venue': 'Moda Sahil', 'area': 'Moda', 'host': 'Theo', 'lat': 40.9785, 'lng': 29.0250, 'total': 6, 'mins': 84, 'members': ['Theo', 'Ada', 'Sam', 'Noa']},
    {'vibeId': 'walk', 'venue': 'Caddebostan Sahil', 'area': 'Caddebostan', 'host': 'Jin', 'lat': 40.9630, 'lng': 29.0660, 'total': 5, 'mins': 41, 'members': ['Jin', 'Rey', 'Eda']},
    {'vibeId': 'games', 'venue': 'Pasaj', 'area': 'Beşiktaş', 'host': 'Cleo', 'lat': 41.0420, 'lng': 29.0080, 'total': 6, 'mins': 112, 'members': ['Cleo', 'Max', 'Ivy', 'Tom']},
    // — Uzak şehirler —
    {'vibeId': 'food', 'venue': 'Kızılay Meydanı', 'area': 'Ankara', 'host': 'Burak', 'lat': 39.9208, 'lng': 32.8541, 'total': 5, 'mins': 73, 'members': ['Burak', 'Sena', 'Kaan']},
    {'vibeId': 'music', 'venue': 'Alsancak', 'area': 'İzmir', 'host': 'Derya', 'lat': 38.4370, 'lng': 27.1428, 'total': 6, 'mins': 58, 'members': ['Derya', 'Efe', 'Lara']},
    {'vibeId': 'coffee', 'venue': 'Cumhuriyet Cad.', 'area': 'Bursa', 'host': 'Onur', 'lat': 40.1885, 'lng': 29.0610, 'total': 4, 'mins': 90, 'members': ['Onur', 'Pelin']},
    {'vibeId': 'bar', 'venue': 'Kaleiçi', 'area': 'Antalya', 'host': 'Selin', 'lat': 36.8841, 'lng': 30.7056, 'total': 5, 'mins': 65, 'members': ['Selin', 'Mert', 'Zeynep']},
  ];

  /// Örnek flock'ları yazar. Önce bu dev hesabının eski seed'lerini temizler.
  static Future<int> seed(String hostUid) async {
    final col = FirebaseFirestore.instance.collection('flocks');

    // Eski seed'leri sil (yalnızca isSeed=true & bu host).
    final old = await col.where('hostUid', isEqualTo: hostUid).where('isSeed', isEqualTo: true).get();
    for (final d in old.docs) {
      await d.reference.delete();
    }

    final now = DateTime.now();
    for (final s in _samples) {
      await col.add({
        'vibeId': s['vibeId'],
        'venue': s['venue'],
        'area': s['area'],
        'hostUid': hostUid,
        'hostName': s['host'],
        'verifiedHost': true,
        'lat': s['lat'],
        'lng': s['lng'],
        'total': s['total'],
        'memberUids': [for (var i = 0; i < (s['members'] as List).length; i++) 'npc_${s['venue']}_$i'],
        'memberNames': s['members'],
        'createdAt': FieldValue.serverTimestamp(),
        'expiresAt': Timestamp.fromDate(now.add(Duration(minutes: s['mins'] as int))),
        'isSeed': true,
      });
    }
    return _samples.length;
  }
}
