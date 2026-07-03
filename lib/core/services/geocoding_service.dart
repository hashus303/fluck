import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import 'geo.dart';

/// Geocoding sonucu — bir yer adı + koordinatı.
class GeoPlace {
  final String name;
  final String shortLabel; // kart/area için kısa etiket
  final LatLng point;
  const GeoPlace(this.name, this.shortLabel, this.point);
}

/// Anahtar gerektirmeyen geocoding — OpenStreetMap Nominatim.
/// (Android ve web'de çalışır; web'de tarayıcı User-Agent'ı kullanılır.)
class GeocodingService {
  static const _host = 'nominatim.openstreetmap.org';

  // Nominatim kullanım politikası geçerli bir tanıtım + iletişim ister.
  static Map<String, String> get _headers => kIsWeb
      ? const {}
      : const {'User-Agent': 'Flock/1.0 (com.hashus303.fluck; haskartal303@gmail.com)'};

  /// İsim/adres → yerler. [near] verilirse o bölgeye öncelik verir.
  static Future<List<GeoPlace>> search(String query, {LatLng? near}) async {
    if (query.trim().isEmpty) return const [];
    final params = {
      'q': query,
      'format': 'jsonv2',
      'limit': '6',
      'accept-language': 'tr',
    };
    if (near != null) {
      // Yakındaki sonuçlara öncelik için görünüm kutusu (~0.5°).
      params['viewbox'] =
          '${near.lng - 0.5},${near.lat + 0.5},${near.lng + 0.5},${near.lat - 0.5}';
      params['bounded'] = '0';
    }
    try {
      final res = await http.get(Uri.https(_host, '/search', params), headers: _headers);
      if (res.statusCode != 200) return const [];
      final data = jsonDecode(res.body) as List;
      return data.map((e) {
        final m = e as Map<String, dynamic>;
        final full = (m['display_name'] ?? '') as String;
        return GeoPlace(
          _firstPart(full),
          _shortLabel(full),
          LatLng(double.parse(m['lat'] as String), double.parse(m['lon'] as String)),
        );
      }).toList();
    } catch (_) {
      return const [];
    }
  }

  /// Koordinat → kısa bölge etiketi (ör. "Moda, Kadıköy").
  static Future<String?> reverseLabel(LatLng p) async {
    try {
      final res = await http.get(
        Uri.https(_host, '/reverse', {
          'lat': p.lat.toString(),
          'lon': p.lng.toString(),
          'format': 'jsonv2',
          'zoom': '16',
          'accept-language': 'tr',
        }),
        headers: _headers,
      );
      if (res.statusCode != 200) return null;
      final m = jsonDecode(res.body) as Map<String, dynamic>;
      final addr = m['address'] as Map<String, dynamic>?;
      if (addr == null) return _shortLabel((m['display_name'] ?? '') as String);
      final parts = <String>[
        for (final k in ['neighbourhood', 'suburb', 'quarter', 'city_district', 'town', 'city'])
          if (addr[k] != null) addr[k] as String,
      ];
      if (parts.isEmpty) return _shortLabel((m['display_name'] ?? '') as String);
      return parts.take(2).join(', ');
    } catch (_) {
      return null;
    }
  }

  static String _firstPart(String full) =>
      full.split(',').first.trim();

  static String _shortLabel(String full) {
    final parts = full.split(',').map((e) => e.trim()).toList();
    if (parts.length <= 2) return parts.join(', ');
    return parts.take(2).join(', ');
  }
}
