import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmai/screens/auth/register_screen.dart';
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
  testWidgets('Register screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: RegisterScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Login screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: LoginScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Home screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: HomeScreen()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Market price screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: MarketPriceScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Weather screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: WeatherScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Community forum screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: CommunityForumScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Expert helpline screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: ExpertHelplineScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Irrigation screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: IrrigationScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Notifications screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: NotificationsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Profile screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: ProfileScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });

  testWidgets('Settings screen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Scaffold), findsWidgets);
  });
}
