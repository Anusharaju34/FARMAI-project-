import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/language_selection_screen.dart';
import '../screens/auth/splash_screen.dart';
import '../screens/auth/onboarding_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/disease/disease_detection_screen.dart';
import '../screens/pest/pest_detection_screen.dart';
import '../screens/weather/weather_screen.dart';
import '../screens/market/market_price_screen.dart';
import '../screens/irrigation/irrigation_screen.dart';
import '../screens/forum/community_forum_screen.dart';
import '../screens/expert/expert_helpline_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../widgets/common/main_scaffold.dart';

class AppRoutes {
  static const String language = '/language';
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String diseaseDetection = '/disease-detection';
  static const String pestDetection = '/pest-detection';
  static const String weather = '/weather';
  static const String marketPrice = '/market-price';
  static const String irrigation = '/irrigation';
  static const String communityForum = '/community-forum';
  static const String expertHelpline = '/expert-helpline';
  static const String notifications = '/notifications';
  static const String profile = '/profile';
  static const String settings = '/settings';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.language,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isAuthRoute =
          state.matchedLocation == AppRoutes.language ||
          state.matchedLocation == AppRoutes.splash ||
          state.matchedLocation == AppRoutes.onboarding ||
          state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register ||
          state.matchedLocation == AppRoutes.forgotPassword;

      if (!isLoggedIn && !isAuthRoute) {
        return AppRoutes.login;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.language,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainScaffold(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: AppRoutes.diseaseDetection,
            builder: (context, state) => const DiseaseDetectionScreen(),
          ),
          GoRoute(
            path: AppRoutes.pestDetection,
            builder: (context, state) => const PestDetectionScreen(),
          ),
          GoRoute(
            path: AppRoutes.weather,
            builder: (context, state) => const WeatherScreen(),
          ),
          GoRoute(
            path: AppRoutes.marketPrice,
            builder: (context, state) => const MarketPriceScreen(),
          ),
          GoRoute(
            path: AppRoutes.irrigation,
            builder: (context, state) => const IrrigationScreen(),
          ),
          GoRoute(
            path: AppRoutes.communityForum,
            builder: (context, state) => const CommunityForumScreen(),
          ),
          GoRoute(
            path: AppRoutes.expertHelpline,
            builder: (context, state) => const ExpertHelplineScreen(),
          ),
          GoRoute(
            path: AppRoutes.notifications,
            builder: (context, state) => const NotificationsScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
    ],
  );
});