import 'package:flutter/material.dart';

import '../../../core/app_locale.dart';
import '../../../core/models/flock.dart';
import '../../../core/services/firebase_service.dart';
import '../../auth/data/auth_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../flock/data/dev_seeder.dart';
import '../data/interests.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?>? _profileFuture;

  @override
  void initState() {
    super.initState();
    if (FirebaseService.instance.isInitialized) {
      final uid = AuthRepository.instance.currentUser?.uid;
      if (uid != null) _profileFuture = UserProfileRepository.instance.fetch(uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserProfile?>(
      future: _profileFuture,
      builder: (context, snap) => _build(context, snap.data),
    );
  }

  Widget _build(BuildContext context, UserProfile? profile) {
    final t = AppL10n.of(context);
    final email = FirebaseService.instance.isInitialized
        ? AuthRepository.instance.currentUser?.email
        : null;
    final name = (profile?.name.isNotEmpty ?? false) ? profile!.name : 'Jordan Vale';
    final nameLine = profile != null && profile.age > 0 ? '$name, ${profile.age}' : name;
    final stats = [['90', t.statTrust], ['23', t.statFlocks], ['4.9', t.statRating]];
    final past = [
      ['coffee', 'Devoción', t.whenYesterday, '4'],
      ['walk', 'The High Line', t.whenLastWeek, '5'],
      ['games', 'Barcade', t.whenTwoWeeks, '6'],
    ];
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.coral50, Colors.transparent],
              ),
            ),
            child: Column(children: [
              Stack(clipBehavior: Clip.none, children: [
                FlockAvatar(name: name, size: 84),
                Positioned(
                  bottom: 0, right: -2,
                  child: Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.bgPage, width: 3),
                    ),
                    alignment: Alignment.center,
                    child: const Text('✓', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w800)),
                  ),
                ),
              ]),
              const SizedBox(height: 10),
              Text(nameLine, style: AppText.display(24)),
              const SizedBox(height: 2),
              Text(
                email ?? t.profileHandle,
                style: AppText.body(13.5, color: AppColors.textMuted),
              ),
              const SizedBox(height: 10),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (profile?.verificationStatus == 'verified')
                  const VerifiedBadge()
                else if (profile?.verificationStatus == 'pending')
                  FlockBadge(t.obVerificationPending, icon: '⏳', tone: BadgeTone.warning)
                else
                  FlockBadge(t.obNotVerified, icon: '!', tone: BadgeTone.warning),
                const SizedBox(width: 8),
                FlockBadge(t.regularFlocker, icon: '🪶', tone: BadgeTone.coral),
              ]),
              if (profile != null && profile.interests.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    for (final id in profile.interests)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          border: Border.all(color: AppColors.borderSubtle),
                        ),
                        child: Text(interestLabel(t, id),
                            style: AppText.body(12.5, weight: FontWeight.w600)),
                      ),
                  ],
                ),
              ],
            ]),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 18),
              Row(children: [
                for (var i = 0; i < stats.length; i++) ...[
                  if (i > 0) const SizedBox(width: 10),
                  Expanded(child: _StatCard(value: stats[i][0], label: stats[i][1])),
                ],
              ]),
              const SizedBox(height: 22),
              const _LanguageRow(),
              const SizedBox(height: 22),
              Text(t.pastFlocks, style: AppText.eyebrow()),
              const SizedBox(height: 12),
              for (final p in past) ...[
                _PastRow(vibeId: p[0], venue: p[1], when: p[2], people: int.parse(p[3])),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 12),
              FlockButton(label: t.editProfile, variant: FlockBtn.secondary, full: true, onPressed: () {}),
              if (FirebaseService.instance.isInitialized &&
                  AuthRepository.instance.currentUser?.email == 'haskartal303@gmail.com') ...[
                const SizedBox(height: 12),
                FlockButton(
                  label: t.devSeed,
                  variant: FlockBtn.soft,
                  full: true,
                  onPressed: () async {
                    final uid = AuthRepository.instance.currentUser!.uid;
                    final messenger = ScaffoldMessenger.of(context);
                    try {
                      final n = await DevSeeder.seed(uid);
                      messenger.showSnackBar(SnackBar(content: Text(t.devSeedDone(n))));
                    } catch (_) {
                      messenger.showSnackBar(SnackBar(content: Text(t.errGeneric)));
                    }
                  },
                ),
              ],
              if (FirebaseService.instance.isInitialized) ...[
                const SizedBox(height: 10),
                Center(
                  child: TextButton.icon(
                    onPressed: () => AuthRepository.instance.signOut(),
                    icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
                    label: Text(t.signOut,
                        style: AppText.body(14, weight: FontWeight.w700, color: AppColors.danger)),
                  ),
                ),
              ],
              const SizedBox(height: 24),
            ]),
          ),
        ],
      ),
    );
  }
}

/// Dil seçici — TR / EN arası geçiş (kalıcı).
class _LanguageRow extends StatelessWidget {
  const _LanguageRow();
  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final controller = LocaleScope.of(context);
    final code = controller.locale.languageCode;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(children: [
        const Icon(Icons.language, size: 20, color: AppColors.textMuted),
        const SizedBox(width: 12),
        Expanded(child: Text(t.language, style: AppText.body(14.5, weight: FontWeight.w700, color: AppColors.textStrong))),
        _LangSegment(
          options: const [('tr', 'TR'), ('en', 'EN')],
          selected: code,
          onSelect: (c) => controller.setLocale(Locale(c)),
        ),
      ]),
    );
  }
}

class _LangSegment extends StatelessWidget {
  final List<(String, String)> options;
  final String selected;
  final ValueChanged<String> onSelect;
  const _LangSegment({required this.options, required this.selected, required this.onSelect});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (code, label) in options)
          GestureDetector(
            onTap: () => onSelect(code),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: selected == code ? AppColors.brand : Colors.transparent,
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(label,
                  style: AppText.body(13, weight: FontWeight.w700,
                      color: selected == code ? Colors.white : AppColors.textMuted)),
            ),
          ),
      ]),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  const _StatCard({required this.value, required this.label});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
        boxShadow: AppColors.shadowSm,
      ),
      child: Column(children: [
        Text(value, style: AppText.mono(24, color: AppColors.textStrong)),
        const SizedBox(height: 3),
        Text(label.toUpperCase(), style: AppText.eyebrow().copyWith(fontSize: 11.5)),
      ]),
    );
  }
}

class _PastRow extends StatelessWidget {
  final String vibeId, venue, when;
  final int people;
  const _PastRow({required this.vibeId, required this.venue, required this.when, required this.people});
  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final v = vibeById(vibeId);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(children: [
        VibeDot(vibe: v, size: 40),
        const SizedBox(width: 13),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${vibeLabel(t, vibeId)} · $venue',
                style: AppText.body(14.5, weight: FontWeight.w700, color: AppColors.textStrong)),
            const SizedBox(height: 1),
            Text('$when · ${t.peopleCount(people)}', style: AppText.body(12.5, color: AppColors.textMuted)),
          ]),
        ),
        Text('★ 5.0', style: AppText.mono(12, color: AppColors.warning)),
      ]),
    );
  }
}
