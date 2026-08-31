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

  /// Profil fotoğrafını günceller (profil ekranındaki "fotoğraf değiştir").
  Future<void> updatePhoto(String uid, String photoB64) {
    _photoCache.remove(uid);
    return _users.doc(uid).set({
      'photoB64': photoB64,
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

  /// Üye avatarları için profil fotoğrafı (base64) — basit bellek önbellekli.
  final Map<String, String?> _photoCache = {};
  Future<String?> fetchPhotoB64(String uid) async {
    if (_photoCache.containsKey(uid)) return _photoCache[uid];
    try {
      final p = await fetch(uid);
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
