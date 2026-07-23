import 'dart:math';
import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Selfie sırasında istenen rastgele hareket (canlılık / anti-spoofing).
/// Kayıtlı ya da başkasının düz fotoğrafı bu pozu tutamayacağı için,
/// selfie'nin o an çekildiğini kanıtlar. ML Kit cihazda ölçer (ücretsiz).
enum SelfieChallenge { smile, turnHead, tiltHead }

/// Selfie kontrol sonucu — UI doğru mesajı göstersin diye ayrıştırılmış.
enum SelfieCheck { ok, noFace, wrongPose }

class ImageUtil {
  ImageUtil._();

  static final _rand = Random();

  /// Rastgele bir poz seç (onboarding/kapı selfie adımına girerken).
  static SelfieChallenge randomChallenge() =>
      SelfieChallenge.values[_rand.nextInt(SelfieChallenge.values.length)];

  /// Görseli Firestore'a sığacak boyuta indirir (uzun kenar [maxDim] px,
  /// JPEG). 1MB belge limitine karşı ~25KB hedeflenir.
  static Uint8List shrink(Uint8List bytes, {int maxDim = 320, int quality = 72}) {
    final src = img.decodeImage(bytes);
    if (src == null) return bytes;
    final resized = (src.width <= maxDim && src.height <= maxDim)
        ? src
        : (src.width >= src.height
            ? img.copyResize(src, width: maxDim)
            : img.copyResize(src, height: maxDim));
    return Uint8List.fromList(img.encodeJpg(resized, quality: quality));
  }

  static Future<Face?> _detect(String path) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(
        enableClassification: true, // gülümseme olasılığı için
        performanceMode: FaceDetectorMode.accurate,
      ),
    );
    try {
      final faces = await detector.processImage(InputImage.fromFilePath(path));
      return faces.isEmpty ? null : faces.first;
    } finally {
      await detector.close();
    }
  }

  /// Selfie'de yüz var mı VE istenen poz tutulmuş mu? Yalnızca Android/iOS.
  static Future<SelfieCheck> checkSelfie(String path, SelfieChallenge c) async {
    final face = await _detect(path);
    if (face == null) return SelfieCheck.noFace;
    final ok = switch (c) {
      SelfieChallenge.smile => (face.smilingProbability ?? 0) > 0.6,
      // Ön kamera aynalaması yön karıştırdığı için "yana" (iki yön de) kabul.
      SelfieChallenge.turnHead => (face.headEulerAngleY ?? 0).abs() > 18,
      SelfieChallenge.tiltHead => (face.headEulerAngleZ ?? 0).abs() > 15,
    };
    return ok ? SelfieCheck.ok : SelfieCheck.wrongPose;
  }
}
