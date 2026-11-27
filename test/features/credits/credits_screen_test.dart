import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tunely/features/credits/screen/credits_screen.dart';

void main() {
  testWidgets('credits screen renders and rolls without errors', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreditsScreen()));

    expect(find.text('TUNELY'), findsOneWidget);

    // Let the roll advance: the opening title should scroll off screen.
    await tester.pump(const Duration(seconds: 10));

    expect(find.text('TUNELY'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
