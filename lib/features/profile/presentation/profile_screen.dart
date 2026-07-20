import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/app_locale.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/services/image_util.dart';
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
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.coral50, Colors.transparent],
              ),
            ),
            child: Column(children: [
              Stack(clipBehavior: Clip.none, children: [
                // Avatara dokununca fotoğraf değiştirilebilir (canlı modda).
                GestureDetector(
                  onTap: _changePhoto,
                  child: FlockAvatar(name: name, size: 84, photoB64: profile?.photoB64),
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
                      child: const Icon(Icons.photo_camera_outlined,
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
              // Gerçek güven skoru — profil sinyallerinden (Güvenlik ekranıyla aynı).
              if (profile != null)
                SizedBox(
                  width: double.infinity,
                  child: _StatCard(value: '${profile.trustScore}', label: t.statTrust),
                ),
              const SizedBox(height: 22),
              const _LanguageRow(),
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
                    icon: const Icon(Icons.logout, size: 18, color: AppColors.danger),
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
                style: const TextStyle(color: AppColors.danger)),
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

