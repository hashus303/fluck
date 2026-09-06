import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image_util.dart';
import '../../../core/services/verification_meta.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../data/selfie_challenge_label.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';

/// Doğrulama kapısı — selfie incelemesi bitmeden uygulama açılmaz.
/// 'pending': bekleme ekranı. 'rejected': yeni selfie çekip yeniden gönderme.
/// Statü canlı izlendiği (main.dart) için onaylanınca uygulama kendiliğinden açılır.
class VerificationGateScreen extends StatefulWidget {
  final UserProfile profile;
  const VerificationGateScreen({super.key, required this.profile});

  @override
  State<VerificationGateScreen> createState() => _VerificationGateScreenState();
}

class _VerificationGateScreenState extends State<VerificationGateScreen> {
  bool _busy = false;
  final SelfieChallenge _challenge = ImageUtil.randomChallenge();

  Future<void> _retakeSelfie() async {
    final t = AppL10n.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      final f = await ImagePicker().pickImage(
        source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        imageQuality: 82,
      );
      if (f == null) return; // iptal
      if (!kIsWeb) {
        final check = await ImageUtil.checkSelfie(f.path, _challenge);
        if (!mounted) return;
        if (check != SelfieCheck.ok) {
          messenger.showSnackBar(SnackBar(
            content: Text(check == SelfieCheck.noFace
                ? t.obSelfieNoFace
                : t.obSelfieWrongPose(selfieChallengeLabel(t, _challenge))),
          ));
          return;
        }
      }
      setState(() => _busy = true);
      final b64 = base64Encode(ImageUtil.shrink(await f.readAsBytes(), maxDim: 480));
      final meta = await VerificationMeta.capture();
      await UserProfileRepository.instance
          .resubmitSelfie(widget.profile.uid, b64, meta: meta.toMap());
      // Statü 'pending'e döner; main.dart'taki canlı akış ekranı yeniler.
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(t.errGeneric)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    final pending = widget.profile.isVerificationPending;   // 'pending' — selfie incelemede
    final rejected = widget.profile.isVerificationRejected; // 'rejected'
    // pending → beklet (yine de yeniden gönderme çıkışı sun); rejected/none →
    // doğrudan selfie gönderme ekranı (kimse çıkışsız kalmasın).
    final needsSubmit = !pending;

    final emoji = pending ? '🕵️' : (rejected ? '🙈' : '📸');
    final title = pending
        ? t.verifPendingTitle
        : (rejected ? t.verifRejectedTitle : t.verifNeedTitle);
    final body = pending
        ? t.verifPendingBody
        : (rejected ? t.verifRejectedBody : t.verifNeedBody);

    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: rejected ? AppColors.dangerSoft : AppColors.brandSoft,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(emoji, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 22),
              Text(title, textAlign: TextAlign.center, style: AppText.display(24)),
              const SizedBox(height: 10),
              Text(body,
                  textAlign: TextAlign.center,
                  style: AppText.body(14.5, color: AppColors.textMuted)),
              const SizedBox(height: 20),
              if (needsSubmit) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.brandSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Column(children: [
                    Text(t.obSelfieChallengeLabel,
                        style: AppText.body(12,
                            weight: FontWeight.w700, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(selfieChallengeLabel(t, _challenge),
                        textAlign: TextAlign.center,
                        style: AppText.body(16,
                            weight: FontWeight.w800, color: AppColors.brandHover)),
                  ]),
                ),
                const SizedBox(height: 16),
                _busy
                    ? CircularProgressIndicator(color: AppColors.brand)
                    : FlockButton(
                        label: t.verifRetake,
                        full: true,
                        leadingIcon: Icons.photo_camera_outlined,
                        onPressed: _retakeSelfie,
                      ),
              ] else ...[
                // Beklerken: canlı spinner + takılırsa yeniden gönderme çıkışı.
                CircularProgressIndicator(color: AppColors.brand),
                const SizedBox(height: 14),
                if (!_busy)
                  TextButton(
                    onPressed: _retakeSelfie,
                    child: Text(t.verifResend,
                        style: AppText.body(13.5,
                            weight: FontWeight.w700, color: AppColors.brand)),
                  ),
              ],
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => AuthRepository.instance.signOut(),
                child: Text(t.signOut,
                    style: AppText.body(13.5,
                        weight: FontWeight.w700, color: AppColors.textMuted)),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
