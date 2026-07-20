import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/services/image_util.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_repository.dart';
import '../data/interests.dart';
import '../data/user_profile.dart';
import '../data/user_profile_repository.dart';

/// Kayıt sonrası Tinder benzeri profil kurulumu:
/// ad → yaş → ilgi alanları → fotoğraf → selfie doğrulama.
class OnboardingScreen extends StatefulWidget {
  final String uid;
  final String? email;
  const OnboardingScreen({super.key, required this.uid, this.email});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const _total = 5;
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _ageCtrl = TextEditingController();
  final Set<String> _interests = {};
  Uint8List? _photo;
  Uint8List? _selfie;

  final _picker = ImagePicker();
  bool _saving = false;
  String? _error;

  /// Geliştirici hesabı — foto/selfie adımları zorunlu değil (test kolaylığı).
  bool get _isDev => widget.email == 'haskartal303@gmail.com';

  @override
  void initState() {
    super.initState();
    // Google ile girişte adı önceden doldur (kullanıcı değiştirebilir).
    if (FirebaseService.instance.isInitialized) {
      final displayName = AuthRepository.instance.currentUser?.displayName;
      if (displayName != null && displayName.trim().isNotEmpty) {
        _nameCtrl.text = displayName.trim();
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().length >= 2;
      case 1:
        final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
        return age >= 18 && age <= 120;
      case 2:
        return _interests.length >= 3;
      case 3:
        return _isDev || _photo != null;
      case 4:
        return _isDev || _selfie != null;
      default:
        return false;
    }
  }

  Future<void> _pick({required bool selfie, required ImageSource source}) async {
    // Web HTTP (HTTPS değil) iOS Safari'de kamera (getUserMedia) engellenir.
    // Dosya seçici, iOS'ta zaten "Fotoğraf Çek" seçeneğini sunar ve HTTPS gerektirmez.
    // Selfie mobilde HER ZAMAN kameradan çekilir — galeriden eski/başka
    // fotoğraf seçilerek doğrulama kandırılamasın.
    final effectiveSource =
        kIsWeb ? ImageSource.gallery : (selfie ? ImageSource.camera : source);
    try {
      final XFile? f = await _picker.pickImage(
        source: effectiveSource,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1024,
        imageQuality: 82,
      );
      if (f == null) return; // kullanıcı iptal etti
      // Selfie'de gerçek bir yüz olmalı — ML Kit cihazda kontrol eder
      // (web'de desteklenmez, orada atlanır).
      if (selfie && !kIsWeb && !await ImageUtil.hasFace(f.path)) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppL10n.of(context).obSelfieNoFace)),
        );
        return;
      }
      final bytes = await f.readAsBytes();
      if (!mounted) return;
      setState(() => selfie ? _selfie = bytes : _photo = bytes);
    } catch (e) {
      // İzin reddi ya da platform desteklemiyorsa kullanıcıya geri bildir.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppL10n.of(context).obPickFailed)),
      );
    }
  }


  Future<void> _next() async {
    if (!_canAdvance) return;
    if (_step < _total - 1) {
      setState(() => _step++);
      return;
    }
    // Son adım: profili kaydet.
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final photoB64 =
          _photo == null ? null : base64Encode(ImageUtil.shrink(_photo!));
      final profile = UserProfile(
        uid: widget.uid,
        name: _nameCtrl.text.trim(),
        age: int.tryParse(_ageCtrl.text.trim()) ?? 0,
        interests: _interests.toList(),
        photoProvided: _photo != null,
        selfieProvided: _selfie != null,
        verificationStatus: _selfie != null ? 'pending' : 'none',
        onboardingComplete: true,
        email: widget.email,
        photoB64: photoB64,
      );
      await UserProfileRepository.instance.save(profile);
      // Selfie inceleme için kilitli private alana yazılır (yalnızca sahibi
      // ve konsoldaki admin görür). Hata kayıt akışını bozmasın.
      if (_selfie != null) {
        try {
          await UserProfileRepository.instance.saveVerificationSelfie(
            widget.uid,
            base64Encode(ImageUtil.shrink(_selfie!, maxDim: 480)),
          );
        } catch (_) {/* selfie sonra tekrar istenebilir */}
      }
      // Kaydedildikten sonra AuthGate'in profil akışı uygulamayı açar.
    } catch (e) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = AppL10n.of(context).errGeneric;
        });
      }
    }
  }

  void _back() {
    if (_step > 0) setState(() => _step--);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Column(children: [
          // header: back + progress
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 20, 8),
            child: Row(children: [
              SizedBox(
                width: 40,
                child: _step > 0
                    ? IconButton(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back, color: AppColors.textStrong),
                      )
                    : null,
              ),
              Expanded(child: _ProgressBar(step: _step + 1, total: _total)),
              const SizedBox(width: 40),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(t.obStep(_step + 1, _total),
                style: AppText.eyebrow(color: AppColors.brand)),
          ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: SingleChildScrollView(
                key: ValueKey(_step),
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: _stepContent(t),
              ),
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(_error!,
                  style: AppText.body(13, weight: FontWeight.w600, color: AppColors.danger)),
            ),
          // footer CTA
          Container(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceCard,
              border: Border(top: BorderSide(color: AppColors.borderSubtle)),
            ),
            child: _saving
                ? const Center(child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: CircularProgressIndicator(color: AppColors.brand)))
                : Column(mainAxisSize: MainAxisSize.min, children: [
                    Opacity(
                      opacity: _canAdvance ? 1 : 0.45,
                      child: FlockButton(
                        label: _step == _total - 1 ? t.obFinish : t.obContinue,
                        full: true,
                        onPressed: _canAdvance ? _next : null,
                      ),
                    ),
                    if (_isDev && _step >= 3)
                      TextButton(
                        onPressed: _next,
                        child: Text('${t.obSkip} (dev)',
                            style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textMuted)),
                      ),
                  ]),
          ),
        ]),
      ),
    );
  }

  Widget _stepContent(AppL10n t) {
    switch (_step) {
      case 0:
        return _StepShell(
          emoji: '👋',
          title: t.obNameTitle,
          subtitle: t.obNameSubtitle,
          child: _Field(
            controller: _nameCtrl,
            hint: t.obNameHint,
            textCapitalization: TextCapitalization.words,
            onChanged: (_) => setState(() {}),
          ),
        );
      case 1:
        return _StepShell(
          emoji: '🎂',
          title: t.obAgeTitle,
          subtitle: t.obAgeSubtitle,
          child: _Field(
            controller: _ageCtrl,
            hint: t.obAgeHint,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(3)],
            onChanged: (_) => setState(() {}),
          ),
        );
      case 2:
        return _StepShell(
          emoji: '✨',
          title: t.obInterestsTitle,
          subtitle: t.obInterestsSubtitle,
          child: Wrap(
            spacing: 9,
            runSpacing: 9,
            children: [
              for (final it in kInterests)
                _InterestChip(
                  label: interestLabel(t, it.id),
                  emoji: it.emoji,
                  selected: _interests.contains(it.id),
                  onTap: () => setState(() {
                    if (!_interests.remove(it.id)) _interests.add(it.id);
                  }),
                ),
            ],
          ),
        );
      case 3:
        return _StepShell(
          emoji: '📸',
          title: t.obPhotoTitle,
          subtitle: t.obPhotoSubtitle,
          child: _PhotoPicker(
            bytes: _photo,
            shape: BoxShape.rectangle,
            actions: [
              _PickAction(
                label: t.obPhotoGallery,
                icon: Icons.image,
                variant: _photo == null ? FlockBtn.primary : FlockBtn.secondary,
                onTap: () => _pick(selfie: false, source: ImageSource.gallery),
              ),
              _PickAction(
                label: t.obPhotoTake,
                icon: Icons.camera_alt,
                variant: FlockBtn.secondary,
                onTap: () => _pick(selfie: false, source: ImageSource.camera),
              ),
            ],
          ),
        );
      case 4:
        return _StepShell(
          emoji: '🤳',
          title: t.obSelfieTitle,
          subtitle: t.obSelfieSubtitle,
          child: Column(children: [
            _PhotoPicker(
              bytes: _selfie,
              shape: BoxShape.circle,
              actions: [
                _PickAction(
                  label: _selfie == null ? t.obSelfieTake : t.obSelfieRetake,
                  icon: Icons.camera_alt,
                  variant: _selfie == null ? FlockBtn.primary : FlockBtn.secondary,
                  onTap: () => _pick(selfie: true, source: ImageSource.camera),
                ),
              ],
            ),
            if (_selfie != null) ...[
              const SizedBox(height: 14),
              FlockBadge(t.obSelfieDone, icon: '✓', tone: BadgeTone.success),
            ],
          ]),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

class _StepShell extends StatelessWidget {
  final String emoji, title, subtitle;
  final Widget child;
  const _StepShell({required this.emoji, required this.title, required this.subtitle, required this.child});
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(emoji, style: const TextStyle(fontSize: 40)),
      const SizedBox(height: 14),
      Text(title, style: AppText.display(28)),
      const SizedBox(height: 6),
      Text(subtitle, style: AppText.body(15, color: AppColors.textMuted)),
      const SizedBox(height: 26),
      child,
    ]);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  const _Field({
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
  });
  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      inputFormatters: inputFormatters,
      onChanged: onChanged,
      style: AppText.body(17, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body(17, color: AppColors.textFaint),
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _InterestChip({required this.label, required this.emoji, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.brand : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: selected ? AppColors.brand : AppColors.borderSubtle, width: 1.5),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(label,
              style: AppText.body(14, weight: FontWeight.w700,
                  color: selected ? Colors.white : AppColors.textBody)),
        ]),
      ),
    );
  }
}

class _PickAction {
  final String label;
  final IconData icon;
  final FlockBtn variant;
  final VoidCallback onTap;
  const _PickAction({required this.label, required this.icon, required this.variant, required this.onTap});
}

class _PhotoPicker extends StatelessWidget {
  final Uint8List? bytes;
  final BoxShape shape;
  final List<_PickAction> actions;
  const _PhotoPicker({required this.bytes, required this.shape, required this.actions});
  @override
  Widget build(BuildContext context) {
    final radius = shape == BoxShape.circle ? null : BorderRadius.circular(AppRadius.xl);
    return Center(
      child: Column(children: [
        GestureDetector(
          onTap: actions.first.onTap,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: AppColors.surfaceSunken,
              shape: shape,
              borderRadius: radius,
              border: Border.all(color: AppColors.borderSubtle, width: 2),
              image: bytes != null
                  ? DecorationImage(image: MemoryImage(bytes!), fit: BoxFit.cover)
                  : null,
            ),
            alignment: Alignment.center,
            child: bytes == null
                ? Icon(
                    shape == BoxShape.circle ? Icons.camera_alt_outlined : Icons.add_a_photo_outlined,
                    size: 40,
                    color: AppColors.textFaint,
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          FlockButton(
            label: actions[i].label,
            variant: actions[i].variant,
            leadingIcon: actions[i].icon,
            full: true,
            onPressed: actions[i].onTap,
          ),
        ],
      ]),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  final int step, total;
  const _ProgressBar({required this.step, required this.total});
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      for (var i = 0; i < total; i++) ...[
        if (i > 0) const SizedBox(width: 6),
        Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 6,
            decoration: BoxDecoration(
              color: i < step ? AppColors.brand : AppColors.ink200,
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
          ),
        ),
      ],
    ]);
  }
}
