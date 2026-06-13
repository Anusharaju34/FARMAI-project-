import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/market/market_price_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Market prices screen renders crop items and trends', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const MarketPriceScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Market Prices'), findsWidgets);

    // Verify Crop details from mocks
    expect(find.text('Rice'), findsWidgets);
    expect(find.text('₹2340'), findsWidgets);
    expect(find.text('+2.3%'), findsWidgets);

    expect(find.text('Tomato'), findsWidgets);
    expect(find.text('₹890'), findsWidgets);
    expect(find.text('+5.1%'), findsWidgets);
  });
}
