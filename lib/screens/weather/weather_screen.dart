import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';
import '../../widgets/common/common_widgets.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider('Chennai, India'));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: weather.when(
        data: (w) => w != null ? _WeatherContent(weather: w) : _ErrorView(),
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primaryGreen,
          ),
        ),
        error: (_, __) => _ErrorView(),
      ),
    );
  }
}

class _WeatherContent extends StatelessWidget {
  final WeatherData weather;
  const _WeatherContent({required this.weather});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          stretch: true,
          backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.primaryGreen,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => Navigator.maybePop(context),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF1E2A1F), const Color(0xFF111E1A)]
                      : [AppTheme.primaryGreen, AppTheme.lightGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          weather.location,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 84,
                        fontWeight: FontWeight.w200,
                        letterSpacing: -2.0,
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                    Text(
                      weather.condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Feels like ${weather.feelsLike.round()}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Card Grid
                _StatsRow(weather: weather)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.15),

                const SizedBox(height: 24),

                // Forecast Heading
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5-Day Forecast',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    TextButton.icon(
                      onPressed: () => context.push(AppRoutes.weatherDetail),
                      icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                      label: const Text('Detailed'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.primaryGreen,
                        textStyle: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 12),
                
                // Forecast Items
                _ForecastList(forecast: weather.forecast)
                    .animate()
                    .fadeIn(delay: 250.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 24),

                // Farming Advisory Card
                _FarmingAdvisory(weather: weather)
                    .animate()
                    .fadeIn(delay: 350.ms)
                    .slideY(begin: 0.1),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WeatherData weather;
  const _StatsRow({required this.weather});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PremiumGlassCard(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      color: isDark ? AppTheme.cardDark : Colors.white,
      borderOpacity: 0.06,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.water_drop_rounded,
            value: '${weather.humidity}%',
            label: 'Humidity',
            color: AppTheme.waterBlue,
          ),
          _divider(context),
          _StatItem(
            icon: Icons.air_rounded,
            value: '${weather.windSpeed.round()} km/h',
            label: 'Wind',
            color: const Color(0xFF78909C),
          ),
          _divider(context),
          _StatItem(
            icon: Icons.grain_rounded,
            value: '${weather.rainfall} mm',
            label: 'Rainfall',
            color: AppTheme.waterBlue,
          ),
          _divider(context),
          _StatItem(
            icon: Icons.wb_sunny_rounded,
            value: 'UV ${weather.uvIndex}',
            label: 'UV Index',
            color: AppTheme.warningOrange,
          ),
        ],
      ),
    );
  }

  Widget _divider(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 36,
      width: 1.2,
      color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _ForecastList extends StatelessWidget {
  final List<WeatherForecast> forecast;
  const _ForecastList({required this.forecast});

  @override
  Widget build(BuildContext context) {
    if (forecast.isEmpty) {
      final mockForecast = [
        {'day': 'Mon', 'max': 32, 'min': 24, 'icon': Icons.wb_sunny_rounded, 'rain': '10%'},
        {'day': 'Tue', 'max': 29, 'min': 22, 'icon': Icons.cloud_rounded, 'rain': '40%'},
        {'day': 'Wed', 'max': 27, 'min': 21, 'icon': Icons.water_rounded, 'rain': '80%'},
        {'day': 'Thu', 'max': 30, 'min': 23, 'icon': Icons.wb_cloudy_rounded, 'rain': '20%'},
        {'day': 'Fri', 'max': 33, 'min': 25, 'icon': Icons.wb_sunny_rounded, 'rain': '5%'},
      ];
      return Column(
        children: mockForecast
            .map(
              (f) => _ForecastItem(
                day: f['day'] as String,
                max: f['max'] as int,
                min: f['min'] as int,
                icon: f['icon'] as IconData,
                rain: f['rain'] as String,
              ),
            )
            .toList(),
      );
    }
    return Column(
      children: forecast
          .map((f) => _ForecastItem(
                day: DateFormat('EEE').format(f.date),
                max: f.maxTemp.round(),
                min: f.minTemp.round(),
                icon: f.chanceOfRain > 50 ? Icons.water_drop_rounded : Icons.wb_sunny_rounded,
                rain: '${f.chanceOfRain.round()}%',
              ))
          .toList(),
    );
  }
}

class _ForecastItem extends StatelessWidget {
  final String day;
  final int max;
  final int min;
  final IconData icon;
  final String rain;

  const _ForecastItem({
    required this.day,
    required this.max,
    required this.min,
    required this.icon,
    required this.rain,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.0,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
          ),
          Icon(
            icon,
            color: icon == Icons.wb_sunny_rounded ? AppTheme.warningOrange : AppTheme.waterBlue,
            size: 24,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: AppTheme.waterBlue, size: 14),
              const SizedBox(width: 2),
              Text(
                rain,
                style: const TextStyle(fontSize: 12, color: AppTheme.waterBlue, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 24),
          Text(
            '$min°',
            style: TextStyle(color: Colors.grey[500], fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 12),
          Text(
            '$max°',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _FarmingAdvisory extends StatelessWidget {
  final WeatherData weather;
  const _FarmingAdvisory({required this.weather});

  @override
  Widget build(BuildContext context) {
    final advisories = _getAdvisories(weather);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.primaryGreen.withOpacity(0.15),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 22),
              SizedBox(width: 8),
              Text(
                'Farming Advisory',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: AppTheme.primaryGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...advisories.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      a,
                      style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getAdvisories(WeatherData w) {
    final advisories = <String>[];
    if (w.humidity > 80) {
      advisories.add(
          'High humidity: Monitor crops for fungal diseases. Consider preventive organic sprays.');
    }
    if (w.temperature > 35) {
      advisories.add(
          'High temperature alert: Schedule drip irrigation in early morning to minimize water loss.');
    }
    if (w.uvIndex > 7) {
      advisories.add(
          'High UV Index: Avoid foliar pesticide sprays during mid-day to prevent leaf burn.');
    }
    if (w.windSpeed > 20) {
      advisories.add(
          'Strong winds: Avoid chemical spray operations. Support young crops with stakes.');
    }
    advisories.add(
        'Current weather suggests favorable conditions for mechanical tillage operations.');
    return advisories;
  }
}

class _ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.cloud_off_rounded, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Unable to load weather data',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
