import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluck/core/app_locale.dart';
import 'package:fluck/core/services/location_controller.dart';
import 'package:fluck/main.dart';

/// Firebase başlatılmadığı için uygulama çevrimdışı modda açılır:
/// AuthGate doğrudan RootScreen'i gösterir, Home örnek veriyle (kFlocks) dolar.
/// Harita içeren ekranlar IndexedStack ile baştan kurulduğundan pumpAndSettle
/// yerine pump() kullanırız (flutter_map'in takılmaması için).
Future<void> pumpApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(480, 3000); // tüm içerik sığsın
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(FluckApp(
    localeController: LocaleController(),
    locationController: LocationController(),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  group('Home akışı (çevrimdışı)', () {
    testWidgets('varsayılan 25 km yarıçapında 4 yakın flock listeler', (tester) async {
      await pumpApp(tester);
      expect(find.text('Find your flock'), findsOneWidget);
      // İstanbul'daki 4 flock menzilde; uzak şehirler (Ankara/İzmir) hariç.
      expect(find.text('4 flocks live near you'), findsOneWidget);
      expect(find.text('Karga Bar'), findsOneWidget);
    });

    testWidgets('"Anywhere" yarıçapı uzak şehirleri de getirir (6 flock)', (tester) async {
      await pumpApp(tester);
      // 'Anywhere' yatay çubuğun sonunda, ekran dışında — önce görünür kıl.
      await tester.ensureVisible(find.text('Anywhere'));
      await tester.pump();
      await tester.tap(find.text('Anywhere'));
      await tester.pump();
      expect(find.text('6 flocks live near you'), findsOneWidget);
    });

    testWidgets('Coffee vibe filtresi akışı tek flock\'a daraltır', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Coffee').first); // vibe çipi (ağaçta kartlardan önce)
      await tester.pump();
      expect(find.text('1 flocks live near you'), findsOneWidget);
      expect(find.text('Moda Sahil'), findsOneWidget); // coffee
      expect(find.text('Karga Bar'), findsNothing); // bar — elenmeli
    });
  });

  group('Harita sekmesi (OSM)', () {
    testWidgets('gerçek OSM haritası flock pinleri ve atıf ile açılır', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Map'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // OSM zorunlu atıfı görünür (LocationPicker henüz açık değil → tek).
      expect(find.text('© OpenStreetMap contributors'), findsOneWidget);
    });
  });

  group('Güvenlik sekmesi', () {
    testWidgets('trust score görünür, SOS artık yok', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.text('Safety'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Çevrimdışı önizleme profili tam doğrulanmış → skor 100, kimlik doğrulanmış.
      expect(find.text('100'), findsOneWidget);
      expect(find.text('Identity verified'), findsOneWidget);
      // SOS kaldırıldı — ekranda hiçbir izi olmamalı.
      expect(find.text('SOS'), findsNothing);
      expect(find.text('Emergency'), findsNothing);
    });
  });

  group('Şansına bırak (🎲)', () {
    testWidgets('zar butonu rastgele bir flock\'u alt sayfada gösterir', (tester) async {
      await pumpApp(tester);
      expect(find.text('Surprise me'), findsOneWidget);

      await tester.tap(find.text('Surprise me'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Your fate flock'), findsOneWidget);
      expect(find.text('Roll again'), findsOneWidget);
      // Menzildeki 4 flock'tan biri kartta — hepsinde Join butonu olur.
      expect(find.text('Join'), findsWidgets);
    });
  });

  group('Davet oluştur', () {
    testWidgets('mekan girilince Post butonu aktif etikete döner', (tester) async {
      await pumpApp(tester);
      await tester.tap(find.byIcon(Icons.add)); // ortadaki "+" oluştur butonu
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Start a flock'), findsOneWidget);
      // Mekan boşken buton "Enter a venue name" (pasif) gösterir.
      expect(find.text('Enter a venue name'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Test Cafe');
      await tester.pump();
      // Mekan girilince buton aktif etikete döner (varsayılan süre 2 saat).
      expect(find.text('Post invite · live for 2 hours'), findsOneWidget);

      // Süre seçimi butona ve bilgilendirme notuna yansır.
      await tester.ensureVisible(find.text('⚡ 30 min'));
      await tester.pump();
      await tester.tap(find.text('⚡ 30 min'));
      await tester.pump();
      expect(find.text('Post invite · live for 30 min'), findsOneWidget);
      expect(find.text('Your invite goes live instantly and expires in 30 min.'), findsOneWidget);
    });
  });
}
