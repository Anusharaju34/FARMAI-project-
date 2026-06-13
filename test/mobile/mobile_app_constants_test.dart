import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/core/constants/app_constants.dart';

void main() {
  test('Mobile constants load expected values', () {
    expect(AppConstants.cropTypes, isNotEmpty);
    expect(AppConstants.soilTypes, contains('Clay'));
    expect(AppConstants.onboardingKey, 'onboarding_complete');
    expect(AppConstants.radiusMD, 12.0);
  });
}
