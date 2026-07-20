import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
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
      // İptali auth ekranının zaten tanıdığı koda çevir; gerisi generic hata.
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw FirebaseAuthException(code: 'user-cancelled');
      }
      throw FirebaseAuthException(code: 'google-sign-in-failed', message: e.description);
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw FirebaseAuthException(code: 'google-sign-in-failed');
    }
    return _auth.signInWithCredential(GoogleAuthProvider.credential(idToken: idToken));
  }

  Future<void> signOut() => _auth.signOut();

  /// Hesabı kalıcı olarak siler (Play "hesap silme" politikası gereği).
  /// Son giriş eskiyse FirebaseAuth 'requires-recent-login' hatası fırlatır.
  Future<void> deleteAccount() async {
    await _auth.currentUser?.delete();
  }
}
