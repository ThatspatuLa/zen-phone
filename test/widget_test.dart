// Basic smoke test for Zen Phone.
//
// Verifies the app starts and renders the Home screen without throwing.

import 'package:flutter_test/flutter_test.dart';

import 'package:zen_phone/main.dart';

void main() {
  testWidgets('App boots to Home', (WidgetTester tester) async {
    await tester.pumpWidget(const ZenPhoneApp());
    await tester.pump();
    // Home app bar title
    expect(find.text('Pulse'), findsOneWidget);
  });
}
