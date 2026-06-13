import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/expert/expert_helpline_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Expert helpline screen displays query status and responses', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const ExpertHelplineScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Screen Header
    expect(find.text('Expert Helpline'), findsWidgets);

    // Verify queries are displayed
    expect(find.text('Yellowing leaves in Wheat crop'), findsOneWidget);
    expect(find.text('Crop Disease'), findsOneWidget);
    expect(find.text('Answered'), findsOneWidget);

    // Verify response text exists
    expect(find.textContaining('chlorosis'), findsOneWidget);
  });
}
