import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Firebase başlatma ve servis erişimleri için tek noktadan giriş.
class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  bool _initialized = false;
  bool get isInitialized => _initialized;

  /// Firebase'i başlatır. `firebase_options.dart` henüz yapılandırılmadıysa
  /// uygulamanın çökmemesi için hatayı yakalar ve loglar.
  Future<void> init() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      _initialized = true;
      // ignore: avoid_print
      print('Firebase başlatıldı: ${Firebase.app().options.projectId}');
    } catch (e) {
      // ignore: avoid_print
      print('Firebase başlatılamadı (yapılandırma eksik olabilir): $e');
    }
  }

  FirebaseAuth get auth => FirebaseAuth.instance;
  FirebaseFirestore get firestore => FirebaseFirestore.instance;
}
