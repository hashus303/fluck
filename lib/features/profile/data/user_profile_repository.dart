import 'package:cloud_firestore/cloud_firestore.dart';

import 'user_profile.dart';

/// Firestore `users/{uid}` belgesini okuyup yazar.
class UserProfileRepository {
  UserProfileRepository._();
  static final UserProfileRepository instance = UserProfileRepository._();

  CollectionReference<Map<String, dynamic>> get _users =>
      FirebaseFirestore.instance.collection('users');

  /// Profil belgesini canlı dinler (onboarding tamamlandı mı kontrolü için).
  Stream<UserProfile?> watch(String uid) {
    return _users.doc(uid).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return UserProfile.fromMap(uid, snap.data()!);
    });
  }

  Future<UserProfile?> fetch(String uid) async {
    final snap = await _users.doc(uid).get();
    if (!snap.exists || snap.data() == null) return null;
    return UserProfile.fromMap(uid, snap.data()!);
  }

  /// Onboarding sonunda profili kaydeder (merge ile).
  Future<void> save(UserProfile profile) async {
    _photoCache.remove(profile.uid);
    await _users.doc(profile.uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    // E-posta herkese-okunur belgede DEĞİL, yalnızca kilitli private alanda.
    if (profile.email != null && profile.email!.isNotEmpty) {
      await _users.doc(profile.uid).collection('private').doc('contact')
          .set({'email': profile.email}, SetOptions(merge: true));
    }
  }

  /// Profil fotoğrafını günceller.
  ///
  /// PERF: Fotoğraf ARTIK ana kullanıcı belgesinde DEĞİL, `public/photo`
  /// alt belgesinde. Sebebi ölçüldü: base64 foto belgeyi ~22 KB yapıyordu ve
  /// Date destesi 40 kişi çektiğinde yalnızca avatar göstermek için ~900 KB
  /// indiriliyordu. Firestore istemci SDK'sında alan maskesi (projection)
  /// yok — tek çözüm veriyi ayırmak.
  ///
  /// Aynı yazımda eski alan da silinir; kullanıcı fotoğrafını güncelledikçe
  /// veri kendiliğinden taşınır.
  Future<void> updatePhoto(String uid, String photoB64) async {
    _photoCache[uid] = photoB64;
    await _users.doc(uid).collection('public').doc('photo').set({
      'b64': photoB64,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    await _users.doc(uid).set({
      'photoB64': FieldValue.delete(),
      'photoProvided': true,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Doğrulama selfie'sini kilitli private alanına yazar. Kurallar gereği
  /// bu belgeyi yalnızca sahibi yazabilir/okuyabilir; inceleme konsoldan
  /// (admin) yapılır ve sonucu `verificationStatus` alanına işlenir.
  /// [meta] — doğrulama anındaki güvenlik verisi (lat/lng/ip). Varsa yazılır.
  Future<void> saveVerificationSelfie(String uid, String selfieB64,
      {Map<String, dynamic>? meta}) {
    return _users.doc(uid).collection('private').doc('verification').set({
      'selfieB64': selfieB64,
      'submittedAt': FieldValue.serverTimestamp(),
      ...?meta,
    });
  }

  /// Reddedilen kullanıcı yeni selfie gönderir: selfie private alana yazılır,
  /// statü tekrar 'pending' olur (kurallar 'verified' yazmayı zaten engeller).
  Future<void> resubmitSelfie(String uid, String selfieB64,
      {Map<String, dynamic>? meta}) async {
    await saveVerificationSelfie(uid, selfieB64, meta: meta);
    await _users.doc(uid).set({
      'selfieProvided': true,
      'verificationStatus': 'pending',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Üye avatarları için profil fotoğrafı (base64) — bellek önbellekli.
  ///
  /// Önce hafif `public/photo` alt belgesine bakar. Yoksa ESKİ kayıtlar için
  /// ana belgeye düşer (geriye dönük uyumluluk) — o kullanıcı fotoğrafını bir
  /// kez güncelleyince veri yeni yere taşınır.
  final Map<String, String?> _photoCache = {};

  /// Önbellekteki değeri SENKRON döndürür (yoksa null).
  ///
  /// [fetchPhotoB64] önbellek dolu olsa bile Future döndürür; FutureBuilder o
  /// yüzden bir kare boş çizer ve kart 'önce boş gelip sonra dolar'. Bunu
  /// initialData olarak vermek o kareyi ortadan kaldırır.
  String? cachedPhoto(String uid) => _photoCache[uid];

  Future<String?> fetchPhotoB64(String uid) async {
    if (_photoCache.containsKey(uid)) return _photoCache[uid];
    try {
      final snap =
          await _users.doc(uid).collection('public').doc('photo').get();
      final b64 = snap.data()?['b64'] as String?;
      if (b64 != null && b64.isNotEmpty) {
        _photoCache[uid] = b64;
        return b64;
      }
      final p = await fetch(uid); // eski kayıt
      _photoCache[uid] = p?.photoB64;
    } catch (_) {
      return null; // çevrimdışı / Firebase yok — avatar baş harfe düşer
    }
    return _photoCache[uid];
  }

  /// Hesap silme: bildirimler, private doğrulama verisi ve profil belgesi
  /// kaldırılır. (Flock üyelikleri bilinçli olarak bırakılır — flock'lar en
  /// geç 2 saatte kendiliğinden sona erer.)
  Future<void> deleteAccountData(String uid) async {
    final doc = _users.doc(uid);
    final notifs = await doc.collection('notifications').get();
    final privates = await doc.collection('private').get();
    final batch = FirebaseFirestore.instance.batch();
    for (final n in notifs.docs) {
      batch.delete(n.reference);
    }
    for (final p in privates.docs) {
      batch.delete(p.reference);
    }
    batch.delete(doc);
    await batch.commit();
  }
}
