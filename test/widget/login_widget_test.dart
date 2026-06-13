import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/auth/login_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Login screen renders all input fields and buttons', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
    await tester.pumpAndSettle();

    // Verify presence of elements
    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign In'), findsWidgets);
    expect(find.byType(Form), findsOneWidget);

    // Find email and password text fields
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Fill in text
    final textFields = find.byType(TextFormField);
    await tester.enterText(textFields.at(0), 'farmer@example.com');
    await tester.enterText(textFields.at(1), 'password123');
    await tester.pump();

    // Verify text is entered (allow multiple widgets due to TextField text-editing overlays)
    expect(find.text('farmer@example.com'), findsWidgets);
    expect(find.text('password123'), findsWidgets);
  });
}
