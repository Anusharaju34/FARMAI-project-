import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/core/constants/app_constants.dart';
import 'package:farmai/routes/app_router.dart';

void main() {
  test('Core constants are defined and stable', () {
    expect(AppConstants.onboardingKey, 'onboarding_complete');
    expect(AppConstants.themeKey, 'theme_mode');
    expect(AppConstants.cropTypes, contains('Rice'));
    expect(AppConstants.soilTypes, contains('Clay'));
  });

  test('AppRoutes constant values remain correct', () {
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.weather, '/weather');
    expect(AppRoutes.notifications, '/notifications');
  });
}
