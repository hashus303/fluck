import 'dart:convert';

import 'package:http/http.dart' as http;

import 'location_service.dart';

/// Doğrulama (selfie) anındaki güvenlik meta verisi: yaklaşık konum + public IP.
/// Sahtecilik/kötüye kullanım tespiti içindir; admin panelinde görünür.
///
/// Best-effort: alınamazsa boş döner, doğrulama akışını ASLA engellemez/bloklamaz.
class VerificationMeta {
  final double? lat;
  final double? lng;
  final String? ip;
  const VerificationMeta({this.lat, this.lng, this.ip});

  Map<String, dynamic> toMap() => {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (ip != null) 'ip': ip,
      };

  /// Konumu (izin varsa, sormadan) ve public IP'yi kısa zaman aşımıyla toplar.
  static Future<VerificationMeta> capture() async {
    double? lat, lng;
    String? ip;
    try {
      // requestPermission: false — doğrulama anında yeni izin penceresi açma.
      final r = await LocationService.instance.getCurrent(requestPermission: false);
      if (r.ok && r.point != null) {
        lat = r.point!.lat;
        lng = r.point!.lng;
      }
    } catch (_) {/* konum yoksa boş geç */}
    try {
      final res = await http
          .get(Uri.parse('https://api.ipify.org?format=json'))
          .timeout(const Duration(seconds: 4));
      if (res.statusCode == 200) {
        ip = jsonDecode(res.body)['ip'] as String?;
      }
    } catch (_) {/* IP alınamazsa boş geç */}
    return VerificationMeta(lat: lat, lng: lng, ip: ip);
  }
}
