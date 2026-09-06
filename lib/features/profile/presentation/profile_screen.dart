import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_locale.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/notification_prefs.dart';
import '../../../core/services/image_util.dart';
import '../../../main.dart' show themeController;
import '../../auth/data/auth_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../flock/data/dev_seeder.dart';
import '../../flock/data/rating_repository.dart';
import '../data/interests.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';
import '../../premium/data/premium_service.dart';
import '../../premium/presentation/paywall_screen.dart';
import '../../safety/data/moderation_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfile?>? _profileFuture;
  Future<({double avg, int count})?>? _ratingFuture;

  @override
  void initState() {
    super.initState();
    if (FirebaseService.instance.isInitialized) {
      final uid = AuthRepository.instance.currentUser?.uid;
      if (uid != null) {
        _profileFuture = UserProfileRepository.instance.fetch(uid);
        _ratingFuture = RatingRepository.instance.received(uid);
      }
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
    // Ad yoksa e-postanın @ öncesi, o da yoksa nötr "Flocker".
    final fallbackName =
        (email != null && email.contains('@')) ? email.split('@').first : 'Flocker';
    final name = (profile?.name.isNotEmpty ?? false) ? profile!.name : fallbackName;
    final nameLine = profile != null && profile.age > 0 ? '$name, ${profile.age}' : name;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.brandSoft, Colors.transparent],
              ),
            ),
            child: Column(children: [
              Stack(clipBehavior: Clip.none, children: [
                // Avatara dokununca fotoğraf değiştirilebilir (canlı modda).
                Semantics(
                  button: true,
                  label: t.a11yChangePhoto,
                  child: GestureDetector(
                    onTap: _changePhoto,
                    child: FlockAvatar(
                        name: name, size: 84, photoB64: profile?.photoB64),
                  ),
                ),
                // Yeşil ✓ yalnızca gerçekten doğrulanmış hesapta.
                if (profile?.isVerified ?? false)
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
                  )
                else
                  Positioned(
                    bottom: 0, right: -2,
                    child: Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Icon(Icons.photo_camera_outlined,
                          size: 14, color: AppColors.textMuted),
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
              // Gerçek istatistikler: güven skoru (sinyal + yıldız) ve
              // buluşmalardan alınan ortalama puan.
              if (profile != null)
                FutureBuilder<({double avg, int count})?>(
                  future: _ratingFuture,
                  builder: (context, snap) {
                    final r = snap.data;
                    final score = combinedTrustScore(profile.trustScore, r?.avg);
                    return Row(children: [
                      Expanded(child: _StatCard(value: '$score', label: t.statTrust)),
                      if (r != null) ...[
                        const SizedBox(width: 10),
                        Expanded(
                            child: _StatCard(
                                value: '★ ${r.avg.toStringAsFixed(1)}',
                                label: t.statRatingReal)),
                      ],
                    ]);
                  },
                ),
              const SizedBox(height: 22),
              const _PlusRow(),
              const SizedBox(height: 12),
              const _LanguageRow(),
              const SizedBox(height: 12),
              const _ThemeRow(),
              const SizedBox(height: 22),
              const _NotifSection(),
              const SizedBox(height: 22),
              const _BlockedSection(),
              // Dev seeder — yalnızca debug build + geliştirici hesabı.
              if (kDebugMode &&
                  FirebaseService.instance.isInitialized &&
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
                    icon: Icon(Icons.logout, size: 18, color: AppColors.danger),
                    label: Text(t.signOut,
                        style: AppText.body(14, weight: FontWeight.w700, color: AppColors.danger)),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _confirmDeleteAccount,
                    child: Text(t.deleteAccount,
                        style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textMuted)),
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

  /// Avatara dokununca galeriden fotoğraf seç, küçült ve profile kaydet.
  Future<void> _changePhoto() async {
    if (!FirebaseService.instance.isInitialized) return;
    final uid = AuthRepository.instance.currentUser?.uid;
    if (uid == null) return;
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final f = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        imageQuality: 82,
      );
      if (f == null) return; // iptal
      final b64 = base64Encode(ImageUtil.shrink(await f.readAsBytes()));
      await UserProfileRepository.instance.updatePhoto(uid, b64);
      if (!mounted) return;
      // Yeni fotoğrafı hemen göster.
      setState(() => _profileFuture = UserProfileRepository.instance.fetch(uid));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.obPickFailed)));
    }
  }

  /// Play politikası: hesap oluşturan uygulama, uygulama içinden kalıcı hesap
  /// silme sunmak zorunda. Önce Firestore verisi (profil + bildirimler), sonra
  /// auth kaydı silinir; AuthGate akışı otomatik giriş ekranına döndürür.
  Future<void> _confirmDeleteAccount() async {
    final t = AppL10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteAccountTitle),
        content: Text(t.deleteAccountBody),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false), child: Text(t.cancel)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.deleteAccount,
                style: TextStyle(color: AppColors.danger)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final uid = AuthRepository.instance.currentUser?.uid;
    if (uid == null) return;
    final messenger = ScaffoldMessenger.of(context);
    try {
      await UserProfileRepository.instance.deleteAccountData(uid);
      await AuthRepository.instance.deleteAccount();
    } on FirebaseAuthException catch (e) {
      messenger.showSnackBar(SnackBar(
          content: Text(e.code == 'requires-recent-login'
              ? t.deleteAccountReauth
              : t.errGeneric)));
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errGeneric)));
    }
  }
}

/// Flock+ satırı — durumu gösterir, dokununca paywall açar.
class _PlusRow extends StatelessWidget {
  const _PlusRow();

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return ValueListenableBuilder<PremiumState>(
      valueListenable: PremiumService.instance.state,
      builder: (context, plus, _) {
        final active = plus.isPlus;
        final days = plus.trialDaysLeft;
        final title = !active
            ? t.plusTitle
            : (plus.inTrial && days != null
                ? t.plusTrialActiveTitle(days)
                : t.plusActiveTitle);
        final subtitle = active ? t.plusManage : t.plusTagline;
        return InkSurface(
          onTap: () => PaywallScreen.show(context),
          color: active ? AppColors.brandSoft : AppColors.surfaceCard,
          radius: AppRadius.md,
          borderColor:
              active ? AppColors.brandSoftStrong : AppColors.borderSubtle,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: AppColors.brandGradient),
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text("+",
                    style: TextStyle(
                        color: AppColors.onBrand,
                        fontSize: 19,
                        fontWeight: FontWeight.w900)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: AppText.body(14.5,
                              weight: FontWeight.w800,
                              color: AppColors.textStrong)),
                      const SizedBox(height: 1),
                      Text(subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppText.body(12, color: AppColors.textMuted)),
                    ]),
              ),
              Icon(Icons.chevron_right, color: AppColors.textFaint),
          ]),
        );
      },
    );
  }
}

/// Engellediklerin — Güvenlik sekmesi kaldırıldı, buraya taşındı.
/// Kendi kendini yükler; boşsa dostça bir boş durum gösterir.
class _BlockedSection extends StatefulWidget {
  const _BlockedSection();
  @override
  State<_BlockedSection> createState() => _BlockedSectionState();
}

class _BlockedSectionState extends State<_BlockedSection> {
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
      if (mounted) setState(() => _loading = false);
      return;
    }
    final uid = AuthRepository.instance.currentUser!.uid;
    final uids = await ModerationRepository.instance.fetchBlockedUids(uid);
    final list = <UserProfile>[];
    for (final b in uids) {
      final prof = await UserProfileRepository.instance.fetch(b);
      list.add(prof ?? UserProfile(uid: b));
    }
    if (!mounted) return;
    setState(() {
      _blocked = list;
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
    // Yükleniyorsa ya da hiç engel yoksa bölümü sade tut.
    if (_loading) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(t.blockedTitle, style: AppText.display(18)),
        const Spacer(),
        if (_blocked.isNotEmpty)
          Text(t.blockedCount(_blocked.length),
              style: AppText.body(12.5,
                  weight: FontWeight.w700, color: AppColors.textMuted)),
      ]),
      const SizedBox(height: 10),
      if (_blocked.isEmpty)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Column(children: [
            Text(t.blockedEmpty,
                textAlign: TextAlign.center,
                style: AppText.body(14,
                    weight: FontWeight.w700, color: AppColors.textBody)),
            const SizedBox(height: 3),
            Text(t.blockedEmptyHint,
                textAlign: TextAlign.center,
                style: AppText.body(12, color: AppColors.textMuted)),
          ]),
        )
      else
        for (final u in _blocked) ...[
          _BlockedRow(profile: u, onUnblock: () => _unblock(u)),
          const SizedBox(height: 8),
        ],
    ]);
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(children: [
        FlockAvatar(name: name, size: 36, photoB64: profile.photoB64),
        const SizedBox(width: 11),
        Expanded(
          child: Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.body(14,
                  weight: FontWeight.w700, color: AppColors.textStrong)),
        ),
        TextButton(
          onPressed: onUnblock,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.brand,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
          child: Text(t.unblock,
              style: AppText.body(12.5,
                  weight: FontWeight.w800, color: AppColors.brand)),
        ),
      ]),
    );
  }
}

/// Dil seçici — TR / EN arası geçiş (kalıcı).
/// Şema seçimi — sistem / açık / koyu. Simgeler etiketli (TalkBack) ve
/// dokunma hedefleri 48 dp; yeni gelen UI eski borcu tekrarlamasın.
/// Bildirim tercihleri — tür bazında.
///
/// Tek bir "bildirimleri kapat" anahtarı yerine üç ayrı seçim: rakipte en çok
/// şikayet edilen şey spam bildirimdi, ama hepsini kapatmak da doğrulama
/// sonucunu kaçırtır.
class _NotifSection extends StatelessWidget {
  const _NotifSection();

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return ValueListenableBuilder<Map<String, bool>>(
      valueListenable: NotificationPrefs.instance.prefs,
      builder: (context, prefs, _) {
        final rows = <(String, String, String)>[
          ('notifJoins', t.notifJoins, t.notifJoinsBody),
          ('notifAnnouncements', t.notifAnnouncements, t.notifAnnouncementsBody),
          ('notifVerification', t.notifVerification, t.notifVerificationBody),
        ];
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t.notifSection, style: AppText.display(18)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(children: [
              for (var i = 0; i < rows.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, thickness: 1, color: AppColors.divider),
                SwitchListTile.adaptive(
                  value: prefs[rows[i].$1] ?? true,
                  onChanged: (v) => NotificationPrefs.instance.set(rows[i].$1, v),
                  activeThumbColor: AppColors.onBrand,
                  activeTrackColor: AppColors.brand,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                  title: Text(rows[i].$2,
                      style: AppText.body(14.5,
                          weight: FontWeight.w700,
                          color: AppColors.textStrong)),
                  subtitle: Text(rows[i].$3,
                      style: AppText.body(12, color: AppColors.textMuted)),
                ),
              ],
            ]),
          ),
          const SizedBox(height: 8),
          Text(t.notifAllOffHint,
              style: AppText.body(12, color: AppColors.textFaint)),
        ]);
      },
    );
  }
}

class _ThemeRow extends StatelessWidget {
  const _ThemeRow();

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return AnimatedBuilder(
      animation: themeController,
      builder: (context, _) {
        final mode = themeController.mode;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.borderSubtle),
          ),
          child: Row(children: [
            Icon(Icons.contrast, size: 20, color: AppColors.textMuted),
            const SizedBox(width: 12),
            Expanded(
                child: Text(t.theme,
                    style: AppText.body(14.5,
                        weight: FontWeight.w700, color: AppColors.textStrong))),
            _ThemeSegment(
              mode: mode,
              labels: (t.themeSystem, t.themeLight, t.themeDark),
              onSelect: themeController.setMode,
            ),
          ]),
        );
      },
    );
  }
}

class _ThemeSegment extends StatelessWidget {
  final ThemeMode mode;
  final (String, String, String) labels;
  final ValueChanged<ThemeMode> onSelect;
  const _ThemeSegment(
      {required this.mode, required this.labels, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final items = <(ThemeMode, IconData, String)>[
      (ThemeMode.system, Icons.brightness_auto_rounded, labels.$1),
      (ThemeMode.light, Icons.light_mode_rounded, labels.$2),
      (ThemeMode.dark, Icons.dark_mode_rounded, labels.$3),
    ];
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSunken,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        for (final (value, icon, label) in items)
          Semantics(
            label: label,
            selected: mode == value,
            button: true,
            child: InkWell(
              onTap: () => onSelect(value),
              borderRadius: BorderRadius.circular(AppRadius.pill),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: mode == value ? AppColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                alignment: Alignment.center,
                child: Icon(icon,
                    size: 19,
                    color: mode == value
                        ? AppColors.onBrand
                        : AppColors.textMuted),
              ),
            ),
          ),
      ]),
    );
  }
}

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
        Icon(Icons.language, size: 20, color: AppColors.textMuted),
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
          TapTarget(
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
                      color: selected == code ? AppColors.onBrand : AppColors.textMuted)),
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

