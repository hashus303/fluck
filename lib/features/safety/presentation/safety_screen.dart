import 'package:flutter/material.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../../profile/data/user_profile.dart';
import '../../profile/data/user_profile_repository.dart';
import '../data/moderation_repository.dart';

/// Çevrimdışı / yüklenirken kullanılan önizleme profili.
const _previewProfile = UserProfile(
  uid: 'preview',
  verificationStatus: 'verified',
  photoProvided: true,
  selfieProvided: true,
  onboardingComplete: true,
);

/// Güvenlik — doğrulama durumu + engellediklerin (işlevsel, broşür değil).
class SafetyScreen extends StatefulWidget {
  const SafetyScreen({super.key});

  @override
  State<SafetyScreen> createState() => _SafetyScreenState();
}

class _SafetyScreenState extends State<SafetyScreen> {
  UserProfile _profile = _previewProfile;
  List<UserProfile> _blocked = [];
  bool _loading = true;

  bool get _live =>
      FirebaseService.instance.isInitialized &&
      AuthRepository.instance.currentUser != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!_live) {
      setState(() => _loading = false);
      return;
    }
    final uid = AuthRepository.instance.currentUser!.uid;
    final profile = await UserProfileRepository.instance.fetch(uid);
    final blockedUids = await ModerationRepository.instance.fetchBlockedUids(uid);
    final blocked = <UserProfile>[];
    for (final b in blockedUids) {
      final p = await UserProfileRepository.instance.fetch(b);
      blocked.add(p ?? UserProfile(uid: b));
    }
    if (!mounted) return;
    setState(() {
      _profile = profile ?? _previewProfile;
      _blocked = blocked;
      _loading = false;
    });
  }

  Future<void> _unblock(UserProfile u) async {
    if (!_live) return;
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final uid = AuthRepository.instance.currentUser!.uid;
    setState(() => _blocked.removeWhere((x) => x.uid == u.uid));
    try {
      await ModerationRepository.instance.unblock(uid, u.uid);
      messenger.showSnackBar(SnackBar(content: Text(t.unblockDone)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errGeneric)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          Text(t.navSafety, style: AppText.display(28)),
          const SizedBox(height: 2),
          Text(t.safetyLede, style: AppText.body(14, color: AppColors.textMuted)),
          const SizedBox(height: 20),

          _IdentityCard(profile: _profile),
          const SizedBox(height: 22),

          // --- Engellediklerin ---
          Row(children: [
            Text(t.blockedTitle, style: AppText.display(18)),
            const Spacer(),
            if (_blocked.isNotEmpty)
              Text(t.blockedCount(_blocked.length),
                  style: AppText.body(12.5, weight: FontWeight.w700, color: AppColors.textMuted)),
          ]),
          const SizedBox(height: 12),

          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.brand)),
            )
          else if (_blocked.isEmpty)
            _EmptyBlocked()
          else
            for (final u in _blocked) ...[
              _BlockedRow(profile: u, onUnblock: () => _unblock(u)),
              const SizedBox(height: 10),
            ],
        ],
      ),
    );
  }
}

class _EmptyBlocked extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 26),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Column(children: [
        const Icon(Icons.block_flipped, size: 30, color: AppColors.textFaint),
        const SizedBox(height: 10),
        Text(t.blockedEmpty,
            textAlign: TextAlign.center,
            style: AppText.body(14.5, weight: FontWeight.w700, color: AppColors.textBody)),
        const SizedBox(height: 4),
        Text(t.blockedEmptyHint,
            textAlign: TextAlign.center,
            style: AppText.body(12.5, color: AppColors.textMuted)),
      ]),
    );
  }
}

class _BlockedRow extends StatelessWidget {
  final UserProfile profile;
  final VoidCallback onUnblock;
  const _BlockedRow({required this.profile, required this.onUnblock});

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final name = profile.name.isNotEmpty ? profile.name : t.regularFlocker;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(children: [
        FlockAvatar(name: name, size: 40, photoB64: profile.photoB64),
        const SizedBox(width: 12),
        Expanded(
          child: Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(14.5, weight: FontWeight.w700, color: AppColors.textStrong)),
        ),
        const SizedBox(width: 8),
        TextButton(
          onPressed: onUnblock,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brand,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
          child: Text(t.unblock,
              style: AppText.body(13, weight: FontWeight.w800, color: AppColors.brand)),
        ),
      ]),
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
