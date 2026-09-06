import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show debugPrint, kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Firebase Auth sarmalayıcı — e-posta/şifre ile giriş, kayıt ve çıkış.
class AuthRepository {
  AuthRepository._();
  static final AuthRepository instance = AuthRepository._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Oturum durumu akışı — kullanıcı giriş/çıkış yaptıkça yayılır.
  Stream<User?> authState() => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserCredential> signIn(String email, String password) {
    return _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserCredential> signUp(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  /// Firebase web OAuth client'ı (google-services.json `client_type: 3`).
  /// Android'de Firebase'e verilecek idToken bu client için üretilir.
  static const _webClientId =
      '182331722242-lfi0a0gm6clgksfv1dp9g1njptvi4abi.apps.googleusercontent.com';

  bool _googleInitialized = false;

  /// Google hesabıyla giriş/kayıt. Android'de native hesap seçici
  /// (google_sign_in); tarayıcı akışı Chrome'un bölümlenmiş depolamasında
  /// "missing initial state" hatası verdiği için kullanılmıyor. Web'de popup.
  /// Hesap yoksa otomatik oluşur; onboarding kapısı (main.dart) yeni
  /// kullanıcıyı profil kurulumuna yönlendirir.
  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      return _auth.signInWithPopup(GoogleAuthProvider());
    }
    final signIn = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await signIn.initialize(serverClientId: _webClientId);
      _googleInitialized = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await signIn.authenticate();
    } on GoogleSignInException catch (e) {
      debugPrint('FLOCK_GSI code=${e.code} desc=${e.description}');
      throw _mapGoogleError(e);
    } catch (e) {
      debugPrint('FLOCK_GSI raw=$e');
      throw FirebaseAuthException(code: 'google-unknown', message: '$e');
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'google-sign-in-failed');
    }
    return _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
  }

  /// Google akisinin hatasini, auth ekraninin kullaniciya anlamli bir mesaj
  /// gosterebilecegi koda cevirir. Sessizce yutulan TEK durum gercek iptal;
  /// gerisi ekranda gorunur — "hicbir sey olmuyor" sikayeti bundan cikiyordu.
  FirebaseAuthException _mapGoogleError(GoogleSignInException e) {
    final desc = (e.description ?? '').toLowerCase();
    // Play Services, hesabin sifresini yeniden istediginde akisi iptal gibi
    // bitirir; eklenti de bunu 'canceled' diye raporlar. Ayirt edici olan
    // aciklama metni: '[16] Cancelled by user.' vs '[16] Account reauth failed.'
    // (Durum kodu '[16]' HER IKISINDE de var — ona bakmak yanlis pozitif verir.)
    final userCancelled = desc.isEmpty ||
        desc.contains('cancelled by user') ||
        desc.contains('canceled by user') ||
        desc.contains('user canceled') ||
        desc.contains('user cancelled');
    final reauth = desc.contains('reauth');
    final noAccount = desc.contains('no credential') || desc.contains('no account');
    switch (e.code) {
      case GoogleSignInExceptionCode.canceled:
        if (userCancelled) return FirebaseAuthException(code: 'user-cancelled');
        return FirebaseAuthException(
            code: reauth ? 'google-account-reauth' : 'google-unknown',
            message: desc);
      case GoogleSignInExceptionCode.interrupted:
      case GoogleSignInExceptionCode.uiUnavailable:
        return FirebaseAuthException(code: 'google-interrupted', message: desc);
      case GoogleSignInExceptionCode.clientConfigurationError:
      case GoogleSignInExceptionCode.providerConfigurationError:
        return FirebaseAuthException(code: 'google-config', message: desc);
      case GoogleSignInExceptionCode.userMismatch:
      case GoogleSignInExceptionCode.unknownError:
        return FirebaseAuthException(
            code: reauth
                ? 'google-account-reauth'
                : noAccount
                    ? 'google-no-account'
                    : 'google-unknown',
            message: desc);
    }
  }

  Future<void> signOut() => _auth.signOut();

  /// Hesabı kalıcı olarak siler (Play "hesap silme" politikası gereği).
  /// Son giriş eskiyse FirebaseAuth 'requires-recent-login' hatası fırlatır.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
