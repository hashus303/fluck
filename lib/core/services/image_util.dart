import 'dart:typed_data';

import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// Profil görselleri için ortak yardımcılar (onboarding + profil ekranı).
class ImageUtil {
  ImageUtil._();

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

  /// Görselde en az bir yüz var mı? (klavye/duvar fotoğrafı kabul edilmesin)
  /// Yalnızca Android/iOS — web'de çağırma.
  static Future<bool> hasFace(String path) async {
    final detector = FaceDetector(
      options: FaceDetectorOptions(performanceMode: FaceDetectorMode.accurate),
    );
    try {
      final faces = await detector.processImage(InputImage.fromFilePath(path));
      return faces.isNotEmpty;
    } finally {
      await detector.close();
    }
  }
}
