import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/image_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
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
      if (!kIsWeb && !await ImageUtil.hasFace(f.path)) {
        messenger.showSnackBar(SnackBar(content: Text(t.obSelfieNoFace)));
        return;
      }
      setState(() => _busy = true);
      final b64 = base64Encode(ImageUtil.shrink(await f.readAsBytes(), maxDim: 480));
      await UserProfileRepository.instance.resubmitSelfie(widget.profile.uid, b64);
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
    final rejected = widget.profile.isVerificationRejected;
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
                  color: rejected ? const Color(0xFFFDECEC) : AppColors.coral50,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(rejected ? '🙈' : '🕵️',
                    style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(height: 22),
              Text(rejected ? t.verifRejectedTitle : t.verifPendingTitle,
                  textAlign: TextAlign.center, style: AppText.display(24)),
              const SizedBox(height: 10),
              Text(rejected ? t.verifRejectedBody : t.verifPendingBody,
                  textAlign: TextAlign.center,
                  style: AppText.body(14.5, color: AppColors.textMuted)),
              const SizedBox(height: 28),
              if (rejected)
                _busy
                    ? const CircularProgressIndicator(color: AppColors.brand)
                    : FlockButton(
                        label: t.verifRetake,
                        full: true,
                        leadingIcon: Icons.photo_camera_outlined,
                        onPressed: _retakeSelfie,
                      )
              else
                const CircularProgressIndicator(color: AppColors.brand),
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
