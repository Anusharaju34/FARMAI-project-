import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    final userId = ref.read(currentUserProvider)?.id;
    if (userId != null) {
      ref.read(notificationsProvider.notifier).loadNotifications(userId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final weather = ref.watch(weatherProvider('Chennai, India'));
    final unread = ref.watch(unreadNotificationsCountProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppTheme.darkGreen,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppTheme.darkGreen, AppTheme.primaryGreen],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset('assets/images/logo.png'),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'FARMAI',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                            const Spacer(),
                            // Notifications
                            Stack(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.notifications_rounded,
                                    color: Colors.white,
                                  ),
                                  onPressed: () =>
                                      context.push(AppRoutes.notifications),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: const BoxDecoration(
                                        color: AppTheme.alertRed,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            // Settings
                            IconButton(
                              icon: const Icon(Icons.settings_rounded,
                                  color: Colors.white),
                              onPressed: () => context.push(AppRoutes.settings),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Good morning,',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          user?.email?.split('@')[0] ?? 'Farmer',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Weather Card
                  weather
                      .when(
                        data: (w) => w != null
                            ? _WeatherCard(weather: w)
                            : const SizedBox.shrink(),
                        loading: () => _ShimmerCard(height: 100),
                        error: (_, __) => const SizedBox.shrink(),
                      )
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideY(begin: 0.2),

                  const SizedBox(height: 20),

                  // Quick Actions
                  SectionHeader(
                    title: 'Quick Actions',
                    actionLabel: 'See All',
                    onAction: () {},
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: 12),

                  _QuickActionsGrid().animate().fadeIn(delay: 300.ms),

                  const SizedBox(height: 20),

                  // Disease & Pest Alerts
                  SectionHeader(title: 'Recent Alerts')
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 12),
                  _AlertsSection().animate().fadeIn(delay: 500.ms),

                  const SizedBox(height: 20),

                  // Market Snapshot
                  SectionHeader(
                    title: 'Market Snapshot',
                    actionLabel: 'Full Market',
                    onAction: () => context.push(AppRoutes.marketPrice),
                  ).animate().fadeIn(delay: 600.ms),
                  const SizedBox(height: 12),
                  _MarketSnapshot().animate().fadeIn(delay: 700.ms),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// WEATHER CARD
// ============================================================

class _WeatherCard extends StatelessWidget {
  final dynamic weather;
  const _WeatherCard({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.skyBlue, Color(0xFF0288D1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.skyBlue.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${weather.temperature.round()}°C',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                weather.location,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _WeatherStat(
                icon: Icons.water_drop_rounded,
                value: '${weather.humidity}%',
                label: 'Humidity',
              ),
              const SizedBox(height: 8),
              _WeatherStat(
                icon: Icons.air_rounded,
                value: '${weather.windSpeed} km/h',
                label: 'Wind',
              ),
              const SizedBox(height: 8),
              _WeatherStat(
                icon: Icons.wb_sunny_rounded,
                value: 'UV ${weather.uvIndex}',
                label: 'UV Index',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStat(
      {required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 4),
        Text(
          '$label: $value',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
    );
  }
}

// ============================================================
// QUICK ACTIONS GRID
// ============================================================

class _QuickActionsGrid extends StatelessWidget {
  final List<_QuickAction> actions = [
    _QuickAction(
      icon: Icons.biotech_rounded,
      label: 'Disease\nDetection',
      color: Color(0xFF388E3C),
      route: AppRoutes.diseaseDetection,
    ),
    _QuickAction(
      icon: Icons.pest_control_rounded,
      label: 'Pest\nDetection',
      color: Color(0xFFE65100),
      route: AppRoutes.pestDetection,
    ),
    _QuickAction(
      icon: Icons.water_rounded,
      label: 'Irrigation\nAdvice',
      color: Color(0xFF0288D1),
      route: AppRoutes.irrigation,
    ),
    _QuickAction(
      icon: Icons.show_chart_rounded,
      label: 'Market\nPrices',
      color: Color(0xFF7B1FA2),
      route: AppRoutes.marketPrice,
    ),
    _QuickAction(
      icon: Icons.cloud_rounded,
      label: 'Weather\nForecast',
      color: Color(0xFF00695C),
      route: AppRoutes.weather,
    ),
    _QuickAction(
      icon: Icons.support_agent_rounded,
      label: 'Expert\nHelpline',
      color: Color(0xFFC62828),
      route: AppRoutes.expertHelpline,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: actions.length,
      itemBuilder: (context, i) {
        final a = actions[i];
        return GestureDetector(
          onTap: () => context.push(a.route),
          child: Container(
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: a.color.withOpacity(0.2)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(a.icon, color: a.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  a.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: a.color,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final String route;

  const _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.route,
  });
}

// ============================================================
// ALERTS SECTION
// ============================================================

class _AlertsSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alerts = [
      _AlertItem(
        icon: Icons.warning_rounded,
        title: 'Leaf Blight Detected',
        subtitle: 'Your Rice crop shows early signs of leaf blight',
        color: AppTheme.alertRed,
        time: '2h ago',
      ),
      _AlertItem(
        icon: Icons.bug_report_rounded,
        title: 'Aphid Infestation Alert',
        subtitle: 'High aphid activity reported in your region',
        color: AppTheme.warningOrange,
        time: '5h ago',
      ),
    ];

    return Column(
      children: alerts
          .map(
            (a) => Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: a.color.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: a.color.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: a.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(a.icon, color: a.color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.title,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: a.color,
                          ),
                        ),
                        Text(
                          a.subtitle,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    a.time,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _AlertItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final String time;

  const _AlertItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.time,
  });
}

// ============================================================
// MARKET SNAPSHOT
// ============================================================

class _MarketSnapshot extends StatelessWidget {
  final List<Map<String, dynamic>> crops = const [
    {'name': 'Rice', 'price': '₹2,340', 'change': '+2.3%', 'up': true},
    {'name': 'Wheat', 'price': '₹1,890', 'change': '-0.8%', 'up': false},
    {'name': 'Tomato', 'price': '₹890', 'change': '+5.1%', 'up': true},
    {'name': 'Cotton', 'price': '₹6,450', 'change': '+1.2%', 'up': true},
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: crops.map((c) {
        final isUp = c['up'] as bool;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.grass_rounded,
                  size: 18,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                c['name'] as String,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                c['price'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isUp ? AppTheme.primaryGreen : AppTheme.alertRed)
                      .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUp
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 10,
                      color: isUp ? AppTheme.primaryGreen : AppTheme.alertRed,
                    ),
                    Text(
                      c['change'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: isUp ? AppTheme.primaryGreen : AppTheme.alertRed,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _ShimmerCard extends StatelessWidget {
  final double height;
  const _ShimmerCard({required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}
