import 'package:flutter_test/flutter_test.dart';

String? validateName(String? v) {
  if (v == null || v.isEmpty) return 'Enter your full name';
  return null;
}

String? validateEmail(String? v) {
  if (v == null || v.isEmpty) return 'Enter your email';
  if (!v.contains('@')) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Enter a password';
  if (v.length < 6) return 'Minimum 6 characters required';
  return null;
}

String? validateConfirmPassword(String? v, String password) {
  if (v != password) return 'Passwords do not match';
  return null;
}

void main() {
  group('Register Validators', () {
    test('Name validator checks', () {
      expect(validateName('John Doe'), isNull);
      expect(validateName(''), 'Enter your full name');
      expect(validateName(null), 'Enter your full name');
    });

    test('Email validator checks', () {
      expect(validateEmail('test@farmai.com'), isNull);
      expect(validateEmail(''), 'Enter your email');
      expect(validateEmail('testfarmai.com'), 'Enter a valid email');
    });

    test('Password validator checks', () {
      expect(validatePassword('secr3tPass'), isNull);
      expect(validatePassword(''), 'Enter a password');
      expect(validatePassword('short'), 'Minimum 6 characters required');
    });

    test('Confirm password checks', () {
      expect(validateConfirmPassword('secr3tPass', 'secr3tPass'), isNull);
      expect(validateConfirmPassword('different', 'secr3tPass'), 'Passwords do not match');
    });
  });
}
