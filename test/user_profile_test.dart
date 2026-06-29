import 'package:flutter_test/flutter_test.dart';
import 'package:fluck/features/profile/data/user_profile.dart';

void main() {
  group('UserProfile.trustScore', () {
    test('tam doğrulanmış + foto + selfie + onboarding → 100', () {
      const p = UserProfile(
        uid: 'u',
        verificationStatus: 'verified',
        photoProvided: true,
        selfieProvided: true,
        onboardingComplete: true,
      );
      expect(p.trustScore, 100);
    });

    test('yeni kullanıcı, hiçbir sinyal yok → 30 (taban)', () {
      const p = UserProfile(uid: 'u');
      expect(p.trustScore, 30);
    });

    test('sadece onboarding tamam → 40', () {
      const p = UserProfile(uid: 'u', onboardingComplete: true);
      expect(p.trustScore, 40);
    });

    test('doğrulama beklemede + onboarding → 50', () {
      const p = UserProfile(
        uid: 'u',
        verificationStatus: 'pending',
        onboardingComplete: true,
      );
      expect(p.trustScore, 50);
    });

    test('doğrulanmış ama foto/selfie/onboarding yok → 60', () {
      const p = UserProfile(uid: 'u', verificationStatus: 'verified');
      expect(p.trustScore, 60);
    });

    test('skor 0–100 aralığında kalır', () {
      const p = UserProfile(
        uid: 'u',
        verificationStatus: 'verified',
        photoProvided: true,
        selfieProvided: true,
        onboardingComplete: true,
      );
      expect(p.trustScore, inInclusiveRange(0, 100));
    });
  });

  group('UserProfile doğrulama bayrakları', () {
    test('isVerified yalnızca verified için true', () {
      expect(const UserProfile(uid: 'u', verificationStatus: 'verified').isVerified, isTrue);
      expect(const UserProfile(uid: 'u', verificationStatus: 'pending').isVerified, isFalse);
      expect(const UserProfile(uid: 'u').isVerified, isFalse);
    });

    test('isVerificationPending yalnızca pending için true', () {
      expect(const UserProfile(uid: 'u', verificationStatus: 'pending').isVerificationPending, isTrue);
      expect(const UserProfile(uid: 'u', verificationStatus: 'verified').isVerificationPending, isFalse);
    });
  });
}
