import 'package:firebase_auth/firebase_auth.dart';

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

  Future<void> signOut() => _auth.signOut();
}
