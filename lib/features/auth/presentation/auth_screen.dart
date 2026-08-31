import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/flock_widgets.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_repository.dart';

/// E-posta/şifre ile giriş ve kayıt ekranı.
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  bool _isSignUp = false;
  bool _loading = false;
  bool _obscure = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String _mapError(AppL10n t, Object e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'invalid-credential':
        case 'wrong-password':
        case 'user-not-found':
          return t.errInvalidCredentials;
        case 'email-already-in-use':
          return t.errEmailInUse;
        case 'weak-password':
          return t.errWeakPassword;
        case 'invalid-email':
          return t.errEmailInvalid;
        case 'network-request-failed':
          return t.errNetwork;
        default:
          return e.message ?? t.errGeneric;
      }
    }
    return t.errGeneric;
  }

  Future<void> _submit() async {
    final t = AppL10n.of(context);
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final email = _emailCtrl.text;
      final password = _passwordCtrl.text;
      if (_isSignUp) {
        await AuthRepository.instance.signUp(email, password);
      } else {
        await AuthRepository.instance.signIn(email, password);
      }
      // Başarılı: authStateChanges akışı uygulamayı otomatik geçirir.
    } catch (e) {
      if (mounted) setState(() => _error = _mapError(t, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    final t = AppL10n.of(context);
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthRepository.instance.signInWithGoogle();
      // Başarılı: authStateChanges akışı uygulamayı otomatik geçirir.
    } on FirebaseAuthException catch (e) {
      // Kullanıcı akışı iptal ettiyse hata gösterme.
      const cancelled = {
        'web-context-canceled', 'web-context-cancelled',
        'popup-closed-by-user', 'canceled', 'cancelled', 'user-cancelled',
      };
      if (mounted && !cancelled.contains(e.code)) {
        setState(() => _error = _mapError(t, e));
      }
    } catch (e) {
      if (mounted) setState(() => _error = _mapError(t, e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppL10n.of(context);
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // logo — gerçek uygulama ikonu
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.glowCoral,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset('assets/icon/icon.png',
                        width: 64, height: 64, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 22),
                Text(_isSignUp ? t.createAccount : t.welcomeBack, style: AppText.display(30)),
                const SizedBox(height: 6),
                Text(_isSignUp ? t.signUpSubtitle : t.signInSubtitle,
                    style: AppText.body(14.5, color: AppColors.textMuted)),
                const SizedBox(height: 26),

                _FieldLabel(t.email),
                _FlockField(
                  controller: _emailCtrl,
                  hint: t.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.mail_outline,
                  validator: (v) {
                    final s = (v ?? '').trim();
                    if (s.isEmpty) return t.errEmailRequired;
                    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(s)) {
                      return t.errEmailInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                _FieldLabel(t.password),
                _FlockField(
                  controller: _passwordCtrl,
                  hint: t.passwordHint,
                  obscureText: _obscure,
                  // Kayıtta sıradaki alan onay şifresi → "next"; girişte "done".
                  textInputAction:
                      _isSignUp ? TextInputAction.next : TextInputAction.done,
                  prefixIcon: Icons.lock_outline,
                  onSubmitted: _isSignUp ? null : (_) => _submit(),
                  suffix: IconButton(
                    icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        size: 20, color: AppColors.textFaint),
                    onPressed: () => setState(() => _obscure = !_obscure),
                  ),
                  validator: (v) {
                    final s = v ?? '';
                    if (s.isEmpty) return t.errPasswordRequired;
                    if (s.length < 6) return t.errPasswordShort;
                    return null;
                  },
                ),

                // Şifre onayı — yalnızca kayıt modunda.
                if (_isSignUp) ...[
                  const SizedBox(height: 16),
                  _FieldLabel(t.passwordConfirm),
                  _FlockField(
                    controller: _confirmCtrl,
                    hint: t.passwordConfirmHint,
                    obscureText: _obscureConfirm,
                    textInputAction: TextInputAction.done,
                    prefixIcon: Icons.lock_outline,
                    onSubmitted: (_) => _submit(),
                    suffix: IconButton(
                      icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 20,
                          color: AppColors.textFaint),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      final s = v ?? '';
                      if (s.isEmpty) return t.errPasswordConfirmRequired;
                      if (s != _passwordCtrl.text) return t.errPasswordMismatch;
                      return null;
                    },
                  ),
                ],

                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFDECEC),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: Row(children: [
                      const Icon(Icons.error_outline, size: 18, color: AppColors.danger),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!,
                          style: AppText.body(13, weight: FontWeight.w600, color: AppColors.danger))),
                    ]),
                  ),
                ],

                const SizedBox(height: 24),
                _loading
                    ? const Center(child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: CircularProgressIndicator(color: AppColors.brand)))
                    : Column(children: [
                        FlockButton(
                          label: _isSignUp ? t.signUp : t.signIn,
                          full: true,
                          onPressed: _submit,
                        ),
                        const SizedBox(height: 14),
                        Row(children: [
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text(t.orDivider,
                                style: AppText.body(12.5, weight: FontWeight.w600,
                                    color: AppColors.textFaint)),
                          ),
                          const Expanded(child: Divider(color: AppColors.borderSubtle)),
                        ]),
                        const SizedBox(height: 14),
                        _GoogleButton(label: t.continueWithGoogle, onTap: _googleSignIn),
                      ]),
                const SizedBox(height: 18),
                Center(
                  child: TextButton(
                    onPressed: _loading
                        ? null
                        : () => setState(() {
                              _isSignUp = !_isSignUp;
                              _error = null;
                              _confirmCtrl.clear();
                            }),
                    child: Text(_isSignUp ? t.haveAccountSignIn : t.noAccountSignUp,
                        style: AppText.body(13.5, weight: FontWeight.w700, color: AppColors.brandHover)),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(t.authFootnote,
                      textAlign: TextAlign.center,
                      style: AppText.body(12, color: AppColors.textFaint)),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

/// "Google ile devam et" — beyaz zemin, ince kenarlık (Google marka rehberi).
class _GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _GoogleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.borderSubtle, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Text('G',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF4285F4))),
          const SizedBox(width: 10),
          Text(label,
              style: AppText.body(15, weight: FontWeight.w700, color: AppColors.textStrong)),
        ]),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  const _FieldLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 7, left: 2),
        child: Text(text, style: AppText.body(13, weight: FontWeight.w700, color: AppColors.textBody)),
      );
}

class _FlockField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final IconData? prefixIcon;
  final Widget? suffix;
  final String? Function(String?)? validator;
  final void Function(String)? onSubmitted;

  const _FlockField({
    required this.controller,
    required this.hint,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffix,
    this.validator,
    this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onSubmitted,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      style: AppText.body(15, weight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppText.body(15, color: AppColors.textFaint),
        prefixIcon: prefixIcon != null ? Icon(prefixIcon, size: 20, color: AppColors.textFaint) : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: AppColors.surfaceCard,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.borderSubtle),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.brand, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: const BorderSide(color: AppColors.danger, width: 1.5),
        ),
        errorStyle: AppText.body(12, weight: FontWeight.w600, color: AppColors.danger),
      ),
    );
  }
}
