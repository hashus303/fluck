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
  Future<void> save(UserProfile profile) {
    return _users.doc(profile.uid).set({
      ...profile.toMap(),
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
