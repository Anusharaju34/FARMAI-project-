import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/screens/auth/register_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  testWidgets('Register screen renders forms and handles validations', (WidgetTester tester) async {
    await tester.pumpWidget(buildTestableWidget(const RegisterScreen()));
    await tester.pumpAndSettle();

    // Verify layout elements (using findsWidgets since "Create Account" appears as header and button text)
    expect(find.text('Create Account'), findsWidgets);
    expect(find.text('Join FARMAI – your smart farming partner'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4)); // Name, Email, Password, Confirm Password

    // Trigger validation by tapping submit without inputting text
    final submitButton = find.text('Create Account').last;
    await tester.tap(submitButton);
    await tester.pump();

    // Validation messages should appear
    expect(find.text('Enter your full name'), findsOneWidget);
    expect(find.text('Enter your email'), findsOneWidget);
    expect(find.text('Enter a password'), findsOneWidget);
  });
}
