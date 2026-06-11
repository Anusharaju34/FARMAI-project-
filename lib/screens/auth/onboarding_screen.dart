import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      icon: Icons.biotech_rounded,
      title: 'AI Disease Detection',
      subtitle:
          'Upload crop photos and get instant AI-powered disease diagnosis with treatment recommendations',
      color: AppTheme.primaryGreen,
    ),
    OnboardingItem(
      icon: Icons.cloud_rounded,
      title: 'Smart Weather Alerts',
      subtitle:
          'Real-time weather monitoring with farming-specific alerts for rainfall, temperature & humidity',
      color: AppTheme.skyBlue,
    ),
    OnboardingItem(
      icon: Icons.trending_up_rounded,
      title: 'Market Intelligence',
      subtitle:
          'Track crop prices, predict market trends and get insights to maximize your farm profits',
      color: AppTheme.soilBrown,
    ),
    OnboardingItem(
      icon: Icons.people_rounded,
      title: 'Farmer Community',
      subtitle:
          'Connect with thousands of farmers, share knowledge and get expert agricultural advice',
      color: AppTheme.accentGreen,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip Button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _complete,
                child: Text(
                  'Skip',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Pages
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _items.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (context, i) =>
                    _OnboardingPage(item: _items[i], index: i),
              ),
            ),

            // Dots + Button
            Padding(
              padding: const EdgeInsets.all(AppConstants.paddingLG),
              child: Column(
                children: [
                  // Dots
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _items.length,
                      (i) => AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? AppTheme.primaryGreen
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Next/Get Started Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_currentPage < _items.length - 1) {
                          _controller.nextPage(
                            duration: 300.ms,
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _complete();
                        }
                      },
                      child: Text(
                        _currentPage < _items.length - 1
                            ? 'Next'
                            : 'Get Started',
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (_currentPage == _items.length - 1)
                    TextButton(
                      onPressed: () => context.go(AppRoutes.login),
                      child: const Text('Already have an account? Sign In'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.onboardingKey, true);
    if (!mounted) return;
    context.go(AppRoutes.login);
  }
}

class _OnboardingPage extends StatelessWidget {
  final OnboardingItem item;
  final int index;

  const _OnboardingPage({required this.item, required this.index});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingXL),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              item.icon,
              size: 100,
              color: item.color,
            ),
          )
              .animate(key: ValueKey('icon_$index'))
              .scale(
                begin: const Offset(0.6, 0.6),
                duration: 500.ms,
                curve: Curves.elasticOut,
              )
              .fadeIn(),

          const SizedBox(height: 48),

          Text(
            item.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('title_$index'), delay: 200.ms)
              .fadeIn()
              .slideY(begin: 0.2, end: 0),

          const SizedBox(height: 16),

          Text(
            item.subtitle,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: Colors.grey[600], height: 1.6),
            textAlign: TextAlign.center,
          )
              .animate(key: ValueKey('subtitle_$index'), delay: 400.ms)
              .fadeIn()
              .slideY(begin: 0.2, end: 0),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const OnboardingItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });
}
