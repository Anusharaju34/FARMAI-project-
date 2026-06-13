import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:farmai/visible_test_app.dart';
import '../test/mocks/mock_providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full E2E screen sweep', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: getTestProviderOverrides(),
        child: const VisibleTestApp(),
      ),
    );
    await tester.pumpAndSettle();

    final List<String> paths = [
      '/screen-list',
      '/splash',
      '/onboarding',
      '/login',
      '/register',
      '/forgot-password',
      '/home',
      '/disease-detection',
      '/pest-detection',
      '/weather',
      '/market-price',
      '/irrigation',
      '/community-forum',
      '/expert-helpline',
      '/notifications',
      '/profile',
      '/settings',
    ];

    for (final path in paths) {
      visibleRouter.go(path);
      // Pump several frames to allow animations/transitions to settle
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle(const Duration(milliseconds: 500));
      expect(find.byType(VisibleTestApp), findsOneWidget);
    }
  });
}
