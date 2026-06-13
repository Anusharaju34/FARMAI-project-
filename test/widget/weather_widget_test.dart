import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/weather/weather_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Weather screen details loading smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const WeatherScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify location name
    expect(find.text('Salem, India'), findsOneWidget);

    // Verify temperature
    expect(find.text('32°'), findsOneWidget);

    // Verify condition text
    expect(find.text('Sunny'), findsWidgets);

    // Verify stats exist
    expect(find.text('Humidity'), findsOneWidget);
    expect(find.text('65%'), findsOneWidget);
    expect(find.text('Wind'), findsOneWidget);
    expect(find.text('Rainfall'), findsOneWidget);
    expect(find.text('UV Index'), findsOneWidget);

    // Verify advisory block title
    expect(find.text('Farming Advisory'), findsOneWidget);
  });
}
