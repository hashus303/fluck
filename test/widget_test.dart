import 'package:flutter_test/flutter_test.dart';

import 'package:fluck/core/app_locale.dart';
import 'package:fluck/core/services/location_controller.dart';
import 'package:fluck/main.dart';

void main() {
  testWidgets('App renders Home feed with Flock branding', (tester) async {
    await tester.pumpWidget(FluckApp(
      localeController: LocaleController(),
      locationController: LocationController(),
    ));
    await tester.pump();

    // Varsayılan dil İngilizce: Home başlığı ve nav etiketleri görünmeli.
    expect(find.text('Find your flock'), findsOneWidget);
    expect(find.text('Safety'), findsWidgets);
    expect(find.text('Profile'), findsWidgets);
  });
}
