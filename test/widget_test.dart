import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fluck/main.dart';

void main() {
  testWidgets('App renders root screen with navigation', (tester) async {
    await tester.pumpWidget(const FluckApp());

    // Alt navigasyon ve varsayılan Home ekranı görünmeli.
    expect(find.text('Home'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
  });
}
