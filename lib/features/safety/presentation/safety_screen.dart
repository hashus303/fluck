import 'package:flutter/material.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_profile.dart';
import '../../profile/data/user_profile_repository.dart';

/// Çevrimdışı / yüklenirken kullanılan önizleme profili (tam doğrulanmış → skor 100).
const _previewProfile = UserProfile(
  uid: 'preview',
  verificationStatus: 'verified',
  photoProvided: true,
  selfieProvided: true,
  onboardingComplete: true,
);

/// Güvenlik merkezi — kimlik durumu ve güven skorunu gerçek profilden gösterir.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final live = FirebaseService.instance.isInitialized &&
        AuthRepository.instance.currentUser != null;
    if (!live) {
      return const _SafetyBody(profile: _previewProfile);
    }
    final uid = AuthRepository.instance.currentUser!.uid;
    return StreamBuilder<UserProfile?>(
      stream: UserProfileRepository.instance.watch(uid),
      builder: (context, snap) =>
          _SafetyBody(profile: snap.data ?? _previewProfile),
    );
  }
}

class _SafetyBody extends StatelessWidget {
  final UserProfile profile;
  const _SafetyBody({required this.profile});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final score = profile.trustScore;
    final features = [
      ['👥', t.featGroupTitle, t.featGroupDesc],
      ['📍', t.featLocationTitle, t.featLocationDesc],
      ['⭐', t.featRatingsTitle, t.featRatingsDesc],
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(t.safetyTitle, style: AppText.display(28)),
          const SizedBox(height: 2),
          Text(t.safetySubtitle, style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          _IdentityCard(profile: profile),
          const SizedBox(height: 14),

          // Trust score — gerçek profil skorundan.
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: AppColors.borderSubtle),
              boxShadow: AppColors.shadowCard,
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t.yourTrustScore, style: AppText.eyebrow()),
                  Text('$score', style: AppText.mono(40, color: AppColors.textStrong)),
                ]),
                if (score >= 70)
                  FlockBadge(t.trusted, icon: '↑', tone: BadgeTone.success),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Stack(children: [
                  Container(height: 9, color: AppColors.surfaceSunken),
                  FractionallySizedBox(
                    widthFactor: (score / 100).clamp(0.0, 1.0),
                    child: Container(
                      height: 9,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(colors: [AppColors.success, Color(0xFF34B98C)]),
                      ),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 10),
              Text(t.trustScoreNote, style: AppText.body(12.5, color: AppColors.textMuted)),
            ]),
          ),
          const SizedBox(height: 14),

          for (final f in features) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.borderSubtle),
              ),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f[0], style: const TextStyle(fontSize: 20)),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(f[1], style: AppText.body(14.5, weight: FontWeight.w700, color: AppColors.textStrong)),
                    const SizedBox(height: 2),
                    Text(f[2], style: AppText.body(12.5, color: AppColors.textMuted)),
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 14),

          // Emergency SOS
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6F6),
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: const Color(0xFFF6D2D3)),
            ),
            child: Column(children: [
              Text(t.emergency,
                  style: AppText.body(14, weight: FontWeight.w700, color: AppColors.danger)),
              const SizedBox(height: 4),
              Text(t.emergencyDesc,
                  textAlign: TextAlign.center,
                  style: AppText.body(12.5, color: AppColors.textMuted)),
              const SizedBox(height: 16),
              _SosButton(),
              const SizedBox(height: 14),
              Text(t.pressHold, style: AppText.body(11.5, color: AppColors.textFaint)),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Kimlik doğrulama kartı — verificationStatus'a göre 3 durum.
class _IdentityCard extends StatelessWidget {
  final UserProfile profile;
  const _IdentityCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);

    late final Color bg, border, circle;
    late final String title, subtitle;
    if (profile.isVerified) {
      bg = AppColors.successSoft;
      border = const Color(0xFFC6ECDB);
      circle = AppColors.success;
      title = t.identityVerified;
      subtitle = t.idConfirmed;
    } else if (profile.isVerificationPending) {
      bg = const Color(0xFFFFF7E8);
      border = const Color(0xFFF3E2BC);
      circle = AppColors.warning;
      title = t.obVerificationPending;
      subtitle = '';
    } else {
      bg = AppColors.surfaceCard;
      border = AppColors.borderSubtle;
      circle = AppColors.textFaint;
      title = t.obNotVerified;
      subtitle = t.authFootnote;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: border),
      ),
      child: Row(children: [
        Container(
          width: 50, height: 50,
          decoration: BoxDecoration(color: circle, shape: BoxShape.circle),
          alignment: Alignment.center,
          child: const Text('🛡️', style: TextStyle(fontSize: 24)),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(child: Text(title, style: AppText.display(18))),
              if (profile.isVerified) ...[
                const SizedBox(width: 8),
                const VerifiedBadge(),
              ],
            ]),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(subtitle,
                  style: AppText.body(13, weight: FontWeight.w600,
                      color: profile.isVerified ? AppColors.success : AppColors.textMuted)),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _SosButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).sosActivated)),
        );
      },
      child: Container(
        width: 108, height: 108,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(0, -0.24),
            colors: [Color(0xFFF2696D), AppColors.danger],
          ),
          boxShadow: AppColors.glowDanger,
        ),
        alignment: Alignment.center,
        child: Text(AppL10n.of(context).sos,
            style: AppText.display(24, color: Colors.white).copyWith(letterSpacing: 1)),
      ),
    );
  }
}
