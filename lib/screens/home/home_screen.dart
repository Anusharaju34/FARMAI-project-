import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _currentUserName = 'Farmer';

  @override
  void initState() {
    super.initState();
    _loadCurrentUser();

    final userId = SupabaseService.currentUser?.id;
    if (userId != null) {
      ref.read(notificationsProvider.notifier).loadNotifications(userId);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  void _loadCurrentUser() {
    final authUser = SupabaseService.currentUser;
    final email = authUser?.email;
    if (email != null && email.isNotEmpty) {
      _currentUserName = email.split('@').first;
    } else {
      _currentUserName = 'Farmer';
    }
  }

  @override
  Widget build(BuildContext context) {
    final weather = ref.watch(weatherProvider('Chennai, India'));
    final unread = ref.watch(unreadNotificationsCountProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final currentAuthUser = SupabaseService.currentUser;
    final currentEmail = currentAuthUser?.email;
    final displayedUserName = currentEmail != null && currentEmail.isNotEmpty
        ? currentEmail.split('@').first
        : _currentUserName;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ==================================================
          // GLASSMORPHIC APP BAR & GREETING HEADER
          // ==================================================
          SliverAppBar(
            expandedHeight: 210,
            pinned: true,
            stretch: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark 
                        ? [const Color(0xFF0F2620), const Color(0xFF0A0F0D)]
                        : [const Color(0xFFE0F2F1), AppTheme.backgroundLight],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
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
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGreen.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: AppTheme.primaryGreen.withOpacity(0.2),
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: Image.asset(
                                'assets/images/logo.png',
                                errorBuilder: (context, _, __) => const Icon(
                                  Icons.eco_rounded,
                                  color: AppTheme.primaryGreen,
                                  size: 24,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'FARMAI',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.5,
                                color: AppTheme.darkGreen,
                              ),
                            ),
                            const Spacer(),

                            // Notifications
                            Stack(
                              children: [
                                ClipOval(
                                  child: Material(
                                    color: Colors.transparent,
                                    child: IconButton(
                                      icon: Icon(
                                        Icons.notifications_rounded,
                                        color: isDark ? Colors.white : AppTheme.darkGreen,
                                      ),
                                      onPressed: () => context.push(AppRoutes.notifications),
                                    ),
                                  ),
                                ),
                                if (unread > 0)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: AppTheme.alertRed,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isDark ? AppTheme.backgroundDark : Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),

                            // Settings
                            ClipOval(
                              child: Material(
                                color: Colors.transparent,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.settings_rounded,
                                    color: isDark ? Colors.white : AppTheme.darkGreen,
                                  ),
                                  onPressed: () => context.push(AppRoutes.settings),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '🌾',
                          style: TextStyle(fontSize: 32),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_getGreeting()},',
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.grey[700],
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          displayedUserName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1.0,
                            color: isDark ? Colors.white : AppTheme.darkGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ==================================================
          // DASHBOARD CONTENT
          // ==================================================
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  const SizedBox(height: 8),

                  // Gemini-style Premium AI Assist Banner
                  PremiumGlassCard(
                    padding: const EdgeInsets.all(18),
                    color: isDark ? const Color(0xFF16221E) : const Color(0xFFE8F5E9),
                    borderOpacity: 0.15,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF00BFA5), Color(0xFF00796B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.auto_awesome_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'AI Crop Assistant Active',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 15,
                                  color: isDark ? Colors.white : AppTheme.darkGreen,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Detect leaf blight risk & check recommendations.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? Colors.white70 : Colors.grey[700],
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 14,
                          color: isDark ? Colors.white60 : AppTheme.darkGreen,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Weather Summary Card
                  weather.when(
                    data: (weatherData) {
                      if (weatherData == null) return const SizedBox.shrink();
                      return _WeatherCard(weather: weatherData);
                    },
                    loading: () => const SkeletonLoader(width: double.infinity, height: 140),
                    error: (_, __) => const SizedBox.shrink(),
                  ).animate().fadeIn(delay: 150.ms).slideY(begin: 0.1),

                  const SizedBox(height: 20),

                  // Quick Actions Grid Title
                  const SectionHeader(title: 'Farming Services'),
                  const SizedBox(height: 8),

                  // Premium Actions Grid
                  const _QuickActionsGrid(),

                  const SizedBox(height: 24),

                  // Disease detection and forum shortcuts
                  const SectionHeader(title: 'Recent Activity Alerts'),
                  const SizedBox(height: 8),
                  const _AlertsSection(),

                  const SizedBox(height: 24),

                  // Market snapshot overview
                  SectionHeader(
                    title: 'Live Market snapshot',
                    actionLabel: 'Market Feed',
                    onAction: () => context.push(AppRoutes.marketPrice),
                  ),
                  const SizedBox(height: 8),
                  const _MarketSnapshot(),

                  const SizedBox(height: 100), // Spacing for floating navigation bar
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0288D1), Color(0xFF00B0FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0288D1).withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
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
                  fontSize: 46,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -1,
                ),
              ),
              Text(
                weather.condition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.white70, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    weather.location,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _WeatherStatItem(
                icon: Icons.water_drop_rounded,
                value: '${weather.humidity}%',
                label: 'Humidity',
              ),
              const SizedBox(height: 8),
              _WeatherStatItem(
                icon: Icons.air_rounded,
                value: '${weather.windSpeed} km/h',
                label: 'Wind',
              ),
              const SizedBox(height: 8),
              _WeatherStatItem(
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

class _WeatherStatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _WeatherStatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.white70, size: 14),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

// ============================================================
// QUICK ACTIONS GRID
// ============================================================

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  final List<_QuickAction> actions = const [
    _QuickAction(
      icon: Icons.biotech_rounded,
      label: 'Disease\nDetection',
      color: Color(0xFF00796B),
      route: AppRoutes.diseaseDetection,
    ),
    _QuickAction(
      icon: Icons.pest_control_rounded,
      label: 'Pest\nDetection',
      color: Color(0xFFE65100),
      route: AppRoutes.pestDetection,
    ),
    _QuickAction(
      icon: Icons.water_drop_rounded,
      label: 'Smart\nIrrigation',
      color: Color(0xFF0288D1),
      route: AppRoutes.irrigation,
    ),
    _QuickAction(
      icon: Icons.trending_up_rounded,
      label: 'Market\nPrices',
      color: Color(0xFF6A1B9A),
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
        childAspectRatio: 1.05,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: actions.length,
      itemBuilder: (context, index) {
        final action = actions[index];
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return GestureDetector(
          onTap: () => context.push(action.route),
          child: PremiumGlassCard(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: 20,
            borderOpacity: 0.05,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: action.color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    action.icon,
                    color: action.color,
                    size: 22,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  action.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white.withOpacity(0.9) : AppTheme.darkGreen,
                    height: 1.2,
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
  const _AlertsSection();

  final List<_AlertItem> alerts = const [
    _AlertItem(
      icon: Icons.warning_rounded,
      title: 'Leaf Blight Detected',
      subtitle: 'Your Rice crop diagnosis shows blight risk.',
      color: AppTheme.alertRed,
      time: '2h ago',
    ),
    _AlertItem(
      icon: Icons.bug_report_rounded,
      title: 'Aphid Infestation Warning',
      subtitle: 'Higher aphid activity in Madurai region.',
      color: AppTheme.warningOrange,
      time: '5h ago',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: alerts.map((alert) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 1,
            ),
            boxShadow: AppTheme.premiumShadow,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: alert.color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(alert.icon, color: alert.color, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                alert.time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        );
      }).toList(),
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
  const _MarketSnapshot();

  final List<Map<String, dynamic>> crops = const [
    {
      'name': 'Rice (Paddy)',
      'price': '₹2,450',
      'change': '+2.0%',
      'up': true,
    },
    {
      'name': 'Tomato',
      'price': '₹1,200',
      'change': '+5.3%',
      'up': true,
    },
    {
      'name': 'Cotton',
      'price': '₹6,450',
      'change': '+1.2%',
      'up': true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: crops.map((crop) {
        final isUp = crop['up'] as bool;
        final color = isUp ? AppTheme.primaryGreen : AppTheme.alertRed;

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
              width: 1,
            ),
            boxShadow: AppTheme.premiumShadow,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppTheme.primaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.eco_rounded,
                  size: 18,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                crop['name'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                crop['price'] as String,
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                      size: 10,
                      color: color,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      crop['change'] as String,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: color,
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