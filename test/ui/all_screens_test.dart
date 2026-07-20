import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:farmai/screens/auth/splash_screen.dart';
import 'package:farmai/screens/auth/login_screen.dart';
import 'package:farmai/screens/home/home_screen.dart';
import 'package:farmai/screens/weather/weather_screen.dart';
import 'package:farmai/screens/disease/disease_detection_screen.dart';
import 'package:farmai/screens/pest/pest_detection_screen.dart';
import 'package:farmai/screens/market/market_price_screen.dart';
import 'package:farmai/screens/irrigation/irrigation_screen.dart';
import 'package:farmai/screens/forum/community_forum_screen.dart';
import 'package:farmai/screens/expert/expert_helpline_screen.dart';
import 'package:farmai/screens/notifications/notifications_screen.dart';
import 'package:farmai/screens/profile/profile_screen.dart';
import 'package:farmai/screens/settings/settings_screen.dart';
import 'package:farmai/screens/weather/weather_detail_screen.dart';
import 'package:farmai/screens/market/market_product_detail_screen.dart';
import 'package:farmai/screens/market/create_market_listing_screen.dart';
import 'package:farmai/screens/forum/forum_post_detail_screen.dart';
import 'package:farmai/screens/forum/create_forum_post_screen.dart';
import 'package:farmai/screens/expert/expert_chat_screen.dart';
import 'package:farmai/screens/disease/disease_history_screen.dart';
import 'package:farmai/screens/irrigation/irrigation_schedule_screen.dart';
import 'package:farmai/screens/soil/soil_health_screen.dart';
import 'package:farmai/screens/farm/farm_management_screen.dart';
import 'package:farmai/screens/calendar/crop_calendar_screen.dart';
import 'package:farmai/screens/settings/notification_settings_screen.dart';
import 'package:farmai/screens/settings/language_selection_screen.dart';
import 'package:farmai/screens/settings/help_support_screen.dart';
import '../mocks/mock_providers.dart';

// Using global buildTestableWidget from mock_providers.dart

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Individual Screen Widget Tests', () {
    testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SplashScreen()),
          GoRoute(path: '/login', builder: (context, state) => const Scaffold(body: Text('Login'))),
          GoRoute(path: '/home', builder: (context, state) => const Scaffold(body: Text('Home'))),
          GoRoute(path: '/onboarding', builder: (context, state) => const Scaffold(body: Text('Onboarding'))),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: getTestProviderOverrides(),
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );
      expect(find.text('FARMAI'), findsOneWidget);
      expect(find.text('Smart Farming Assistant'), findsOneWidget);
      await tester.pumpAndSettle();
    });

    testWidgets('LoginScreen renders with form fields', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(Form), findsWidgets);
    });

    testWidgets('WeatherScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const WeatherScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(WeatherScreen), findsOneWidget);
    });

    testWidgets('DiseaseDetectionScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DiseaseDetectionScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DiseaseDetectionScreen), findsOneWidget);
    });

    testWidgets('PestDetectionScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const PestDetectionScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(PestDetectionScreen), findsOneWidget);
    });

    testWidgets('MarketPriceScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MarketPriceScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(MarketPriceScreen), findsOneWidget);
    });

    testWidgets('IrrigationScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IrrigationScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(IrrigationScreen), findsOneWidget);
    });

    testWidgets('CommunityForumScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CommunityForumScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CommunityForumScreen), findsOneWidget);
    });

    testWidgets('ExpertHelplineScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ExpertHelplineScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ExpertHelplineScreen), findsOneWidget);
    });

    testWidgets('NotificationsScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const NotificationsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationsScreen), findsOneWidget);
    });

    testWidgets('ProfileScreen renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ProfileScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ProfileScreen), findsOneWidget);
    });

    testWidgets('SettingsScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('WeatherDetailScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const WeatherDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(WeatherDetailScreen), findsOneWidget);
    });

    testWidgets('MarketProductDetailScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MarketProductDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(MarketProductDetailScreen), findsOneWidget);
    });

    testWidgets('CreateMarketListingScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateMarketListingScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CreateMarketListingScreen), findsOneWidget);
    });

    testWidgets('ForumPostDetailScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ForumPostDetailScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ForumPostDetailScreen), findsOneWidget);
    });

    testWidgets('CreateForumPostScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CreateForumPostScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CreateForumPostScreen), findsOneWidget);
    });

    testWidgets('ExpertChatScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ExpertChatScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(ExpertChatScreen), findsOneWidget);
    });

    testWidgets('DiseaseHistoryScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const DiseaseHistoryScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(DiseaseHistoryScreen), findsOneWidget);
    });

    testWidgets('IrrigationScheduleScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IrrigationScheduleScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(IrrigationScheduleScreen), findsOneWidget);
    });

    testWidgets('SoilHealthScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SoilHealthScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(SoilHealthScreen), findsOneWidget);
    });

    testWidgets('FarmManagementScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const FarmManagementScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(FarmManagementScreen), findsOneWidget);
    });

    testWidgets('CropCalendarScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CropCalendarScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(CropCalendarScreen), findsOneWidget);
    });

    testWidgets('NotificationSettingsScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(NotificationSettingsScreen), findsOneWidget);
    });

    testWidgets('LanguageSelectionScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LanguageSelectionScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(LanguageSelectionScreen), findsOneWidget);
    });

    testWidgets('HelpSupportScreen renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const HelpSupportScreen()));
      await tester.pumpAndSettle();
      expect(find.byType(HelpSupportScreen), findsOneWidget);
    });
  });
}
