import 'package:flutter_test/flutter_test.dart';
import 'package:farmai/routes/app_router.dart';

void main() {
  test('Web route constants are configured correctly', () {
    expect(AppRoutes.splash, '/');
    expect(AppRoutes.onboarding, '/onboarding');
    expect(AppRoutes.login, '/login');
    expect(AppRoutes.home, '/home');
    expect(AppRoutes.communityForum, '/community-forum');
    expect(AppRoutes.weather, '/weather');
  });
}
