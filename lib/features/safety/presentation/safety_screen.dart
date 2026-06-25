import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';

class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
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

          // Identity verified card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: AppColors.successSoft,
              borderRadius: BorderRadius.circular(AppRadius.card),
              border: Border.all(color: const Color(0xFFC6ECDB)),
            ),
            child: Row(children: [
              Container(
                width: 50, height: 50,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: const Text('🛡️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Flexible(child: Text(t.identityVerified, style: AppText.display(18))),
                    const SizedBox(width: 8),
                    const VerifiedBadge(),
                  ]),
                  const SizedBox(height: 2),
                  Text(t.idConfirmed,
                      style: AppText.body(13, weight: FontWeight.w600, color: AppColors.success)),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Trust score card
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
                  Text('90', style: AppText.mono(40, color: AppColors.textStrong)),
                ]),
                FlockBadge(t.trusted, icon: '↑', tone: BadgeTone.success),
              ]),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.pill),
                child: Stack(children: [
                  Container(height: 9, color: AppColors.surfaceSunken),
                  FractionallySizedBox(
                    widthFactor: 0.9,
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
