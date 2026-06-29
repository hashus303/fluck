import 'package:flutter_test/flutter_test.dart';
import 'package:fluck/core/services/geo.dart';

void main() {
  group('haversineKm', () {
    test('aynı nokta için sıfır döner', () {
      const p = LatLng(41.0082, 28.9784);
      expect(haversineKm(p, p), closeTo(0, 0.0001));
    });

    test('İstanbul–Ankara mesafesi ~350 km', () {
      const istanbul = LatLng(41.0082, 28.9784);
      const ankara = LatLng(39.9334, 32.8597);
      expect(haversineKm(istanbul, ankara), closeTo(350, 20));
    });

    test('simetriktir (a→b == b→a)', () {
      const a = LatLng(40.9900, 29.0290);
      const b = LatLng(38.4370, 27.1428);
      expect(haversineKm(a, b), closeTo(haversineKm(b, a), 0.0001));
    });

    test('yakın noktalar küçük mesafe verir (< 1 km)', () {
      const user = LatLng(40.9900, 29.0290);
      const karga = LatLng(40.9895, 29.0270); // Kadıköy, ~0.2 km
      expect(haversineKm(user, karga), lessThan(1));
    });
  });

  group('distanceLabel', () {
    test('1 km altı metre olarak', () {
      expect(distanceLabel(0.35), '350 m');
      expect(distanceLabel(0.999), '999 m');
    });

    test('1–10 km arası tek ondalık', () {
      expect(distanceLabel(2.4), '2.4 km');
      expect(distanceLabel(9.9), '9.9 km');
    });

    test('10 km ve üstü tam sayı', () {
      expect(distanceLabel(10), '10 km');
      expect(distanceLabel(37.4), '37 km');
    });
  });
}
