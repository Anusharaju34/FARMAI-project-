import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/theme/app_theme.dart';
import 'routes/app_router.dart';
import 'widgets/common/main_scaffold.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/onboarding_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/disease/disease_detection_screen.dart';
import 'screens/expert/expert_helpline_screen.dart';
import 'screens/forum/community_forum_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/irrigation/irrigation_screen.dart';
import 'screens/market/market_price_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/pest/pest_detection_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/weather/weather_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    dotenv.env['SUPABASE_URL'] = 'https://example.supabase.co';
    dotenv.env['SUPABASE_ANON_KEY'] = 'test-anon-key';
  }

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? 'https://example.supabase.co',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? 'test-anon-key',
  );

  runApp(const ProviderScope(child: VisibleTestApp()));
}

final GoRouter visibleRouter = GoRouter(
  initialLocation: '/screen-list',
  routes: [
    GoRoute(
      path: '/screen-list',
      builder: (context, state) => const ScreenListPage(),
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

class VisibleTestApp extends StatelessWidget {
  const VisibleTestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FARMAI Visible Screen Tester',
      theme: AppTheme.lightTheme,
      routerConfig: visibleRouter,
    );
  }
}

class ScreenListPage extends StatelessWidget {
  const ScreenListPage({super.key});

  static final List<_ScreenEntry> _screens = [
    const _ScreenEntry('Splash Screen', AppRoutes.splash),
    const _ScreenEntry('Onboarding', AppRoutes.onboarding),
    const _ScreenEntry('Login', AppRoutes.login),
    const _ScreenEntry('Register', AppRoutes.register),
    const _ScreenEntry('Forgot Password', AppRoutes.forgotPassword),
    const _ScreenEntry('Home', AppRoutes.home),
    const _ScreenEntry('Disease Detection', AppRoutes.diseaseDetection),
    const _ScreenEntry('Pest Detection', AppRoutes.pestDetection),
    const _ScreenEntry('Weather', AppRoutes.weather),
    const _ScreenEntry('Market Price', AppRoutes.marketPrice),
    const _ScreenEntry('Irrigation', AppRoutes.irrigation),
    const _ScreenEntry('Community Forum', AppRoutes.communityForum),
    const _ScreenEntry('Expert Helpline', AppRoutes.expertHelpline),
    const _ScreenEntry('Notifications', AppRoutes.notifications),
    const _ScreenEntry('Profile', AppRoutes.profile),
    const _ScreenEntry('Settings', AppRoutes.settings),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FARMAI Chrome Screen Tester'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _screens.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final entry = _screens[index];
          return ElevatedButton(
            onPressed: () => context.go(entry.path),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              padding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            child: Text(entry.title, style: const TextStyle(fontSize: 16)),
          );
        },
      ),
    );
  }
}

class _ScreenEntry {
  final String title;
  final String path;
  const _ScreenEntry(this.title, this.path);
}
