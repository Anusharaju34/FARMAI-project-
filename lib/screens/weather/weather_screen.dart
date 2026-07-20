import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../routes/app_router.dart';

class WeatherScreen extends ConsumerWidget {
  const WeatherScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weather = ref.watch(weatherProvider('Chennai, India'));

    return Scaffold(
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
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 320,
          pinned: true,
          backgroundColor: const Color(0xFF1565C0),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_on_rounded,
                            color: Colors.white70, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          weather.location,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${weather.temperature.round()}°',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 80,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                    Text(
                      weather.condition,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Feels like ${weather.feelsLike.round()}°C',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Stats Row
                _StatsRow(weather: weather)
                    .animate()
                    .fadeIn()
                    .slideY(begin: 0.2),

                const SizedBox(height: 20),

                // Forecast
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '5-Day Forecast',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.push(AppRoutes.weatherDetail),
                      child: const Text('Detailed Forecast',
                          style: TextStyle(color: AppTheme.primaryGreen)),
                    ),
                  ],
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                _ForecastList(forecast: weather.forecast)
                    .animate()
                    .fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // Farming Advisory
                _FarmingAdvisory(weather: weather)
                    .animate()
                    .fadeIn(delay: 400.ms),

                const SizedBox(height: 80),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.water_drop_rounded,
            value: '${weather.humidity}%',
            label: 'Humidity',
            color: AppTheme.skyBlue,
          ),
          _divider(),
          _StatItem(
            icon: Icons.air_rounded,
            value: '${weather.windSpeed.round()} km/h',
            label: 'Wind',
            color: const Color(0xFF78909C),
          ),
          _divider(),
          _StatItem(
            icon: Icons.grain_rounded,
            value: '${weather.rainfall} mm',
            label: 'Rainfall',
            color: const Color(0xFF1E88E5),
          ),
          _divider(),
          _StatItem(
            icon: Icons.wb_sunny_rounded,
            value: 'UV ${weather.uvIndex}',
            label: 'UV Index',
            color: AppTheme.sunYellow,
          ),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        height: 40,
        width: 1,
        color: Colors.grey[200],
      );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _StatItem(
      {required this.icon,
      required this.value,
      required this.label,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 11),
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
      // Show mock forecast
      final mockForecast = [
        {
          'day': 'Mon',
          'max': 32,
          'min': 24,
          'icon': Icons.wb_sunny_rounded,
          'rain': '10%'
        },
        {
          'day': 'Tue',
          'max': 29,
          'min': 22,
          'icon': Icons.cloud_rounded,
          'rain': '40%'
        },
        {
          'day': 'Wed',
          'max': 27,
          'min': 21,
          'icon': Icons.water_rounded,
          'rain': '80%'
        },
        {
          'day': 'Thu',
          'max': 30,
          'min': 23,
          'icon': Icons.wb_cloudy_rounded,
          'rain': '20%'
        },
        {
          'day': 'Fri',
          'max': 33,
          'min': 25,
          'icon': Icons.wb_sunny_rounded,
          'rain': '5%'
        },
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
                icon: Icons.wb_sunny_rounded,
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

  const _ForecastItem(
      {required this.day,
      required this.max,
      required this.min,
      required this.icon,
      required this.rain});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(
              day,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Icon(icon, color: AppTheme.sunYellow, size: 24),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.water_drop_rounded,
                  color: AppTheme.skyBlue, size: 14),
              const SizedBox(width: 2),
              Text(rain,
                  style:
                      const TextStyle(fontSize: 12, color: AppTheme.skyBlue)),
            ],
          ),
          const SizedBox(width: 16),
          Text(
            '$min°',
            style: TextStyle(color: Colors.grey[500], fontSize: 14),
          ),
          const SizedBox(width: 8),
          Text(
            '$max°',
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
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

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Farming Advisory',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...advisories.map(
            (a) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_rounded,
                      color: AppTheme.primaryGreen, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      a,
                      style: const TextStyle(fontSize: 13, height: 1.5),
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
          'High humidity: Monitor crops for fungal diseases. Consider preventive fungicide application.');
    }
    if (w.temperature > 35) {
      advisories.add(
          'High temperature alert: Schedule irrigation in early morning or evening to reduce evaporation losses.');
    }
    if (w.uvIndex > 7) {
      advisories.add(
          'High UV Index: Avoid pesticide spraying during 10 AM - 3 PM to prevent phytotoxicity.');
    }
    if (w.windSpeed > 20) {
      advisories.add(
          'Strong winds: Avoid spray operations. Support tall crops with stakes to prevent lodging.');
    }
    advisories.add(
        'Current conditions are suitable for field operations in the morning hours.');
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
          Text('Unable to load weather data'),
        ],
      ),
    );
  }
}
