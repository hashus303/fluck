import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../../../core/services/geo.dart';

/// Date destesinde gösterilen kişi.
class DiscoveryPerson {
  final String uid;
  final String name;
  final int age;
  final List<String> interests;
  final String? photoB64;
  final LatLng? point;

  /// Kullanıcıya olan uzaklık (km). Konum yoksa null.
  final double? km;

  const DiscoveryPerson({
    required this.uid,
    required this.name,
    required this.age,
    required this.interests,
    this.photoB64,
    this.point,
    this.km,
  });

  DiscoveryPerson withDistance(double? value) => DiscoveryPerson(
        uid: uid,
        name: name,
        age: age,
        interests: interests,
        photoB64: photoB64,
        point: point,
        km: value,
      );
}

/// Date modunun veri katmanı: keşfedilebilirlik, deste ve beğeni/geçme.
///
/// GİZLİLİK KARARLARI — bunlar bilinçli, değiştirilmeden önce düşünülmeli:
/// - Keşfedilebilirlik **varsayılan KAPALI**. Kullanıcı açıkça açmadan
///   destede görünmez.
/// - Konum **kabaca** yazılır (2 ondalık ≈ 1 km). Tam koordinat asla
///   paylaşılmaz; mesafe bu kaba noktadan hesaplanır.
/// - Yalnızca **doğrulanmış** hesaplar destede yer alır.
/// - Beğeni/geçme geçmişi kullanıcının `private/` alanında; kimse göremez.
///   Karşılıklılığı saptamak için ayrıca `likes/{from}_{to}` yazılır — onu da
///   yalnızca iki taraf okuyabilir (bkz. firestore.rules).
class DiscoveryRepository {
  DiscoveryRepository._();
  static final DiscoveryRepository instance = DiscoveryRepository._();

  FirebaseFirestore get _db => FirebaseFirestore.instance;

  /// Kaba konum hassasiyeti: 2 ondalık ≈ 1.1 km. Semt düzeyi.
  static double _coarse(double v) => (v * 100).roundToDouble() / 100;

  /// Coğrafi kutu boyu (derece). 0.25° ≈ 28 km — bir şehir ölçeği.
  static const _cell = 0.25;

  /// Konumdan kutu anahtarı. Sorgu bu anahtar üzerinden daraltılır; aksi
  /// halde `limit` veritabanındaki RASTGELE kişileri getirir ve "yakınındaki"
  /// sözü yalan olur (1000 kayıtta ölçüldü).
  static String _box(double lat, double lng) {
    final a = (lat / _cell).floor();
    final b = (lng / _cell).floor();
    return '${a}_$b';
  }

  /// Merkez kutu + 8 komşusu. Kenarda oturanlar komşu kutudakileri de görsün.
  static List<String> _boxesAround(LatLng at) {
    final a = (at.lat / _cell).floor();
    final b = (at.lng / _cell).floor();
    return [
      for (var i = -1; i <= 1; i++)
        for (var j = -1; j <= 1; j++) '${a + i}_${b + j}',
    ];
  }

  // ---------------------------------------------------------------------
  // Keşfedilebilirlik
  // ---------------------------------------------------------------------

  final ValueNotifier<bool> discoverable = ValueNotifier<bool>(false);

  Future<void> loadDiscoverable(String uid) async {
    try {
      final snap = await _db.collection('users').doc(uid).get();
      discoverable.value = (snap.data()?['discoverable'] as bool?) ?? false;
    } catch (_) {/* okunamadıysa kapalı say */}
  }

  /// Keşfedilebilirliği aç/kapat. Açarken kaba konum da yazılır; kapatırken
  /// konum SİLİNİR — kullanıcı çıktığında izi kalmasın.
  Future<void> setDiscoverable(String uid, bool value, {LatLng? at}) async {
    discoverable.value = value;
    try {
      await _db.collection('users').doc(uid).set({
        'discoverable': value,
        if (value && at != null) ...{
          'geoLat': _coarse(at.lat),
          'geoLng': _coarse(at.lng),
          'geoBox': _box(at.lat, at.lng),
          'geoAt': FieldValue.serverTimestamp(),
        },
        if (!value) ...{
          'geoLat': FieldValue.delete(),
          'geoLng': FieldValue.delete(),
          'geoBox': FieldValue.delete(),
          'geoAt': FieldValue.delete(),
        },
      }, SetOptions(merge: true));
    } catch (_) {/* sessiz — bir sonraki açılışta tazelenir */}
  }

  // ---------------------------------------------------------------------
  // Deste
  // ---------------------------------------------------------------------

  /// Gösterilecek kişiler: doğrulanmış + keşfedilebilir, kendisi hariç,
  /// engellediği ve daha önce karar verdiği kişiler hariç; mesafeye göre sıralı.
  Future<List<DiscoveryPerson>> deck({
    required String uid,
    required LatLng me,
    required Set<String> blocked,
    int limit = 40,
  }) async {
    final decided = await _decided(uid);
    final skip = {uid, ...blocked, ...decided};

    // Önce yakın kutular; oradan yeterli kişi çıkmazsa kutusuz (eski kayıt
    // ya da uzak bölge) sorguya düşülür. `whereIn` en fazla 30 değer alır,
    // 9 kutu sınırın çok altında.
    var docs = (await _db
            .collection('users')
            .where('discoverable', isEqualTo: true)
            .where('verificationStatus', isEqualTo: 'verified')
            .where('geoBox', whereIn: _boxesAround(me))
            .limit(limit + skip.length)
            .get())
        .docs;

    if (docs.length < 5) {
      // Yakında kimse yok — çevreyi genişletmek yerine dürüstçe genel havuza
      // bak; mesafe yine gösterilir, kullanıcı uzaklığı kendi görür.
      docs = (await _db
              .collection('users')
              .where('discoverable', isEqualTo: true)
              .where('verificationStatus', isEqualTo: 'verified')
              .limit(limit + skip.length)
              .get())
          .docs;
    }

    final people = <DiscoveryPerson>[];
    for (final doc in docs) {
      if (skip.contains(doc.id)) continue;
      final m = doc.data();
      final lat = (m['geoLat'] as num?)?.toDouble();
      final lng = (m['geoLng'] as num?)?.toDouble();
      final point = (lat != null && lng != null) ? LatLng(lat, lng) : null;
      people.add(DiscoveryPerson(
        uid: doc.id,
        name: (m['name'] as String?) ?? '',
        age: (m['age'] as num?)?.toInt() ?? 0,
        interests:
            ((m['interests'] as List?) ?? const []).whereType<String>().toList(),
        // Fotoğraf artık ana belgede değil; kart görünürken ayrıca çekilir.
        photoB64: null,
        point: point,
        km: point == null ? null : haversineKm(me, point),
      ));
    }
    // Konumu olanlar önce ve yakından uzağa; konumsuzlar sona.
    people.sort((a, b) {
      if (a.km == null && b.km == null) return 0;
      if (a.km == null) return 1;
      if (b.km == null) return -1;
      return a.km!.compareTo(b.km!);
    });
    return people.take(limit).toList();
  }

  // ---------------------------------------------------------------------
  // Karar (beğen / geç)
  // ---------------------------------------------------------------------

  Future<Set<String>> _decided(String uid) async {
    try {
      final snap = await _db
          .collection('users').doc(uid)
          .collection('private').doc('swipes')
          .get();
      final m = snap.data() ?? const <String, dynamic>{};
      return {
        ...((m['liked'] as List?) ?? const []).whereType<String>(),
        ...((m['passed'] as List?) ?? const []).whereType<String>(),
      };
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> pass(String uid, String targetUid) async {
    try {
      await _db
          .collection('users').doc(uid)
          .collection('private').doc('swipes')
          .set({'passed': FieldValue.arrayUnion([targetUid])},
              SetOptions(merge: true));
    } catch (_) {}
  }

  /// Beğeni. Karşı taraf da beğendiyse `true` döner (karşılıklı).
  Future<bool> like(String uid, String targetUid) async {
    try {
      await _db
          .collection('users').doc(uid)
          .collection('private').doc('swipes')
          .set({'liked': FieldValue.arrayUnion([targetUid])},
              SetOptions(merge: true));
      await _db.collection('likes').doc('${uid}_$targetUid').set({
        'from': uid,
        'to': targetUid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      // Karşı yön var mı? Kuralda 'to == ben' olan belgeyi okuyabiliyorum.
      final back = await _db.collection('likes').doc('${targetUid}_$uid').get();
      return back.exists;
    } catch (_) {
      return false;
    }
  }
}
