/// Kullanıcı profili — onboarding'de toplanır, Firestore'da `users/{uid}` altında saklanır.
class UserProfile {
  final String uid;
  final String name;
  final int age;
  final List<String> interests;
  final bool photoProvided;
  final bool selfieProvided;
  final String verificationStatus; // 'pending' | 'verified' | 'none'
  final bool onboardingComplete;
  final String? email;

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
      );
}
