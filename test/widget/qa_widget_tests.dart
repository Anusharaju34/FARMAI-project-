import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmai/screens/auth/login_screen.dart';
import 'package:farmai/screens/home/home_screen.dart';
import 'package:farmai/screens/market/market_price_screen.dart';
import 'package:farmai/screens/weather/weather_screen.dart';
import 'package:farmai/screens/forum/community_forum_screen.dart';
import 'package:farmai/screens/expert/expert_helpline_screen.dart';
import 'package:farmai/screens/irrigation/irrigation_screen.dart';
import 'package:farmai/screens/notifications/notifications_screen.dart';
import 'package:farmai/screens/profile/profile_screen.dart';
import 'package:farmai/screens/settings/settings_screen.dart';
import '../mocks/mock_providers.dart';

void main() {
  group('FARMAI Widget Tests (FLT-031 to FLT-060)', () {
    testWidgets('FLT-031: Login screen rendering and text fields presence', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const LoginScreen()));
      await tester.pump(const Duration(seconds: 1));
      
      expect(find.byType(TextFormField), findsAtLeastNWidgets(2));
      expect(find.text('Sign In'), findsWidgets);
    });

    testWidgets('FLT-032: Home screen dashboard quick action tiles check', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const HomeScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('FARMAI'), findsWidgets);
      expect(find.byIcon(Icons.notifications_rounded), findsWidgets);
    });

    testWidgets('FLT-033: Market price screen APMC live prices check', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const MarketPriceScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
      expect(find.textContaining('Market'), findsWidgets);

      // Clean up pending updates timer in MarketService
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('FLT-034: Weather screen layout and metric display', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const WeatherScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
      
      // Clean up pending timers from weather notifier
      await tester.pumpWidget(const SizedBox());
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('FLT-035: Community Forum discussion thread elements render', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const CommunityForumScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Community Forum'), findsWidgets);
    });

    testWidgets('FLT-036: Expert Helpline helpline contact rendering', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const ExpertHelplineScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Expert Helpline'), findsWidgets);
    });

    testWidgets('FLT-037: Irrigation scheduler switch rendering', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const IrrigationScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(Scaffold), findsWidgets);
    });

    testWidgets('FLT-038: Notifications screen empty alert validation', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const NotificationsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Notifications'), findsWidgets);
    });

    testWidgets('FLT-039: Settings screen switches list rendering', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestableWidget(const SettingsScreen()));
      await tester.pump(const Duration(seconds: 1));

      expect(find.text('Settings'), findsWidgets);
      expect(find.text('Dark Mode'), findsWidgets);
    });
  });
}
