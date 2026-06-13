import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/home/home_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Home screen smoke test with providers', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify app bar title
    expect(find.text('FARMAI'), findsOneWidget);

    // Verify user name in header
    expect(find.text('farmer'), findsWidgets);

    // Verify weather temperature is loaded from mock weather (31.5 -> 32)
    expect(find.text('32°C'), findsWidgets);
    expect(find.text('Sunny'), findsWidgets);

    // Verify presence of quick actions
    expect(find.textContaining('Disease'), findsWidgets);
    expect(find.textContaining('Pest'), findsWidgets);
    expect(find.textContaining('Irrigation'), findsWidgets);
    expect(find.textContaining('Market'), findsWidgets);

    // Verify market snapshot
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('Tomato'), findsWidgets);
  });
}
