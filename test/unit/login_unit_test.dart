import 'package:flutter_test/flutter_test.dart';

String? validateEmail(String? v) {
  if (v == null || v.isEmpty) return 'Enter your email';
  if (!v.contains('@') || v.length < 3) return 'Enter a valid email';
  return null;
}

String? validatePassword(String? v) {
  if (v == null || v.isEmpty) return 'Enter your password';
  if (v.length < 6) return 'Password too short';
  return null;
}

void main() {
  group('Login Validators', () {
    test('valid email passes', () {
      expect(validateEmail('farmer@example.com'), isNull);
    });

    test('empty email fails', () {
      expect(validateEmail(''), 'Enter your email');
    });

    test('null email fails', () {
      expect(validateEmail(null), 'Enter your email');
    });

    test('email without @ fails', () {
      expect(validateEmail('bademail.com'), 'Enter a valid email');
    });

    test('valid password passes', () {
      expect(validatePassword('123456'), isNull);
      expect(validatePassword('password123'), isNull);
    });

    test('empty password fails', () {
      expect(validatePassword(''), 'Enter your password');
    });

    test('null password fails', () {
      expect(validatePassword(null), 'Enter your password');
    });

    test('short password fails', () {
      expect(validatePassword('12345'), 'Password too short');
    });
  });
}
