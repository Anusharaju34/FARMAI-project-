import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

// New screen imports
import '../screens/weather/weather_detail_screen.dart';
import '../screens/market/market_product_detail_screen.dart';
import '../screens/market/create_market_listing_screen.dart';
import '../screens/forum/forum_post_detail_screen.dart';
import '../screens/forum/create_forum_post_screen.dart';
import '../screens/expert/expert_chat_screen.dart';
import '../screens/disease/disease_history_screen.dart';
import '../screens/irrigation/irrigation_schedule_screen.dart';
import '../screens/soil/soil_health_screen.dart';
import '../screens/farm/farm_management_screen.dart';
import '../screens/calendar/crop_calendar_screen.dart';
import '../screens/settings/notification_settings_screen.dart';
import '../screens/settings/language_selection_screen.dart';
import '../screens/settings/help_support_screen.dart';

class AppRoutes {
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

  // New screens
  static const String weatherDetail = '/weather-detail';
  static const String marketProductDetail = '/market-product-detail';
  static const String createMarketListing = '/create-market-listing';
  static const String forumPostDetail = '/forum-post-detail';
  static const String createForumPost = '/create-forum-post';
  static const String expertChat = '/expert-chat';
  static const String diseaseHistory = '/disease-history';
  static const String irrigationSchedule = '/irrigation-schedule';
  static const String soilHealth = '/soil-health';
  static const String farmManagement = '/farm-management';
  static const String cropCalendar = '/crop-calendar';
  static const String notificationSettings = '/settings-notifications';
  static const String languageSelection = '/settings-language';
  static const String helpSupport = '/settings-help-support';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;

      final isAuthRoute =
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
          // New screens
          GoRoute(
            path: AppRoutes.weatherDetail,
            builder: (context, state) => const WeatherDetailScreen(),
          ),
          GoRoute(
            path: AppRoutes.marketProductDetail,
            builder: (context, state) => const MarketProductDetailScreen(),
          ),
          GoRoute(
            path: AppRoutes.createMarketListing,
            builder: (context, state) => const CreateMarketListingScreen(),
          ),
          GoRoute(
            path: AppRoutes.forumPostDetail,
            builder: (context, state) => const ForumPostDetailScreen(),
          ),
          GoRoute(
            path: AppRoutes.createForumPost,
            builder: (context, state) => const CreateForumPostScreen(),
          ),
          GoRoute(
            path: AppRoutes.expertChat,
            builder: (context, state) => const ExpertChatScreen(),
          ),
          GoRoute(
            path: AppRoutes.diseaseHistory,
            builder: (context, state) => const DiseaseHistoryScreen(),
          ),
          GoRoute(
            path: AppRoutes.irrigationSchedule,
            builder: (context, state) => const IrrigationScheduleScreen(),
          ),
          GoRoute(
            path: AppRoutes.soilHealth,
            builder: (context, state) => const SoilHealthScreen(),
          ),
          GoRoute(
            path: AppRoutes.farmManagement,
            builder: (context, state) => const FarmManagementScreen(),
          ),
          GoRoute(
            path: AppRoutes.cropCalendar,
            builder: (context, state) => const CropCalendarScreen(),
          ),
          GoRoute(
            path: AppRoutes.notificationSettings,
            builder: (context, state) => const NotificationSettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.languageSelection,
            builder: (context, state) => const LanguageSelectionScreen(),
          ),
          GoRoute(
            path: AppRoutes.helpSupport,
            builder: (context, state) => const HelpSupportScreen(),
          ),
        ],
      ),
    ],
  );
});