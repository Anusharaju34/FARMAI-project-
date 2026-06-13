import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/forum/community_forum_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Community forum screen renders posts and user info', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const CommunityForumScreen()));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify Title
    expect(find.text('Community Forum'), findsWidgets);

    // Verify mock forum post details
    expect(find.text('Best practices for Rice cultivation in Kharif season?'), findsOneWidget);
    expect(find.textContaining('SRI method'), findsOneWidget);
    expect(find.text('Ravi Kumar'), findsWidgets);
    expect(find.text('#Rice'), findsOneWidget);
    expect(find.text('#Kharif'), findsOneWidget);
  });
}
