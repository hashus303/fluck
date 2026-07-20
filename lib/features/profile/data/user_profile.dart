/// Kullanıcı profili — onboarding'de toplanır, Firestore'da `users/{uid}` altında saklanır.
class UserProfile {
  final String uid;
  final String name;
  final int age;
  final List<String> interests;
  final bool photoProvided;
  final bool selfieProvided;
  final String verificationStatus; // 'pending' | 'verified' | 'rejected' | 'none'
  final bool onboardingComplete;
  final String? email;
  /// Küçültülmüş profil fotoğrafı (JPEG, base64). Avatarlarda gösterilir.
  /// Firestore belge limitine (1MB) sığması için ~320px / ~25KB tutulur.
  final String? photoB64;

  const UserProfile({
    required this.uid,
    this.name = '',
    this.age = 0,
    this.interests = const [],
    this.photoProvided = false,
    this.selfieProvided = false,
    this.verificationStatus = 'none',
    this.onboardingComplete = false,
    this.email,
    this.photoB64,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'age': age,
        'interests': interests,
        'photoProvided': photoProvided,
        'selfieProvided': selfieProvided,
        'verificationStatus': verificationStatus,
        'onboardingComplete': onboardingComplete,
        if (email != null) 'email': email,
        if (photoB64 != null) 'photoB64': photoB64,
      };

  factory UserProfile.fromMap(String uid, Map<String, dynamic> m) => UserProfile(
        uid: uid,
        name: (m['name'] ?? '') as String,
        age: (m['age'] ?? 0) as int,
        interests: List<String>.from(m['interests'] ?? const []),
        photoProvided: (m['photoProvided'] ?? false) as bool,
        selfieProvided: (m['selfieProvided'] ?? false) as bool,
        verificationStatus: (m['verificationStatus'] ?? 'none') as String,
        onboardingComplete: (m['onboardingComplete'] ?? false) as bool,
        email: m['email'] as String?,
        photoB64: m['photoB64'] as String?,
      );

  bool get isVerified => verificationStatus == 'verified';
  bool get isVerificationPending => verificationStatus == 'pending';
  bool get isVerificationRejected => verificationStatus == 'rejected';

  /// Profilin gerçek sinyallerinden türetilen güven skoru (0-100).
  /// Şimdilik kimlik doğrulama + foto/selfie + onboarding'e dayanır; ileride
  /// sunucu tarafı (tamamlanan flock'lar, çift yönlü puanlar) bunu genişletir.
  int get trustScore {
    var s = 30;
    if (isVerified) {
      s += 30;
    } else if (isVerificationPending) {
      s += 10;
    }
    if (photoProvided) s += 15;
    if (selfieProvided) s += 15;
    if (onboardingComplete) s += 10;
    return s.clamp(0, 100);
  }
}
