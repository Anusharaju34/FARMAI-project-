import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:farmai/screens/auth/forgot_password_screen.dart';
import 'package:farmai/screens/auth/login_screen.dart';
import 'package:farmai/screens/auth/onboarding_screen.dart';
import 'package:farmai/screens/auth/register_screen.dart';
import 'package:farmai/screens/disease/disease_detection_screen.dart';
import 'package:farmai/screens/expert/expert_helpline_screen.dart';
import 'package:farmai/screens/forum/community_forum_screen.dart';
import 'package:farmai/screens/home/home_screen.dart';
import 'package:farmai/screens/irrigation/irrigation_screen.dart';
import 'package:farmai/screens/market/market_price_screen.dart';
import 'package:farmai/screens/notifications/notifications_screen.dart';
import 'package:farmai/screens/pest/pest_detection_screen.dart';
import 'package:farmai/screens/profile/profile_screen.dart';
import 'package:farmai/screens/settings/settings_screen.dart';
import 'package:farmai/screens/weather/weather_screen.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await Supabase.initialize(
      url: 'https://example.supabase.co',
      anonKey: 'test-anon-key',
    );
  });

  final screens = [
    {
      'widget': const OnboardingScreen(),
      'type': OnboardingScreen,
    },
    {
      'widget': const LoginScreen(),
      'type': LoginScreen,
    },
    {
      'widget': const RegisterScreen(),
      'type': RegisterScreen,
    },
    {
      'widget': const ForgotPasswordScreen(),
      'type': ForgotPasswordScreen,
    },
    {
      'widget': const HomeScreen(),
      'type': HomeScreen,
    },
    {
      'widget': const DiseaseDetectionScreen(),
      'type': DiseaseDetectionScreen,
    },
    {
      'widget': const PestDetectionScreen(),
      'type': PestDetectionScreen,
    },
    {
      'widget': const WeatherScreen(),
      'type': WeatherScreen,
    },
    {
      'widget': const MarketPriceScreen(),
      'type': MarketPriceScreen,
    },
    {
      'widget': const IrrigationScreen(),
      'type': IrrigationScreen,
    },
    {
      'widget': const CommunityForumScreen(),
      'type': CommunityForumScreen,
    },
    {
      'widget': const ExpertHelplineScreen(),
      'type': ExpertHelplineScreen,
    },
    {
      'widget': const NotificationsScreen(),
      'type': NotificationsScreen,
    },
    {
      'widget': const ProfileScreen(),
      'type': ProfileScreen,
    },
    {
      'widget': const SettingsScreen(),
      'type': SettingsScreen,
    },
  ];

  testWidgets('render all major app screens in browser', (WidgetTester tester) async {
    for (final screenData in screens) {
      final widget = screenData['widget'] as Widget;
      final screenType = screenData['type'] as Type;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: widget,
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      expect(find.byType(screenType), findsOneWidget,
          reason: 'Expected screen ${screenType.toString()} to be displayed');
      await tester.pump(const Duration(seconds: 1));
    }
  });
}
