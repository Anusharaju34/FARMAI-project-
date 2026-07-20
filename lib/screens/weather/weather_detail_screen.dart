import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class WeatherDetailScreen extends StatelessWidget {
  const WeatherDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> hourly = [
      {'time': 'Now', 'temp': '31°C', 'icon': Icons.wb_sunny_rounded, 'rain': '0%'},
      {'time': '3 PM', 'temp': '32°C', 'icon': Icons.wb_sunny_rounded, 'rain': '0%'},
      {'time': '4 PM', 'temp': '31°C', 'icon': Icons.wb_sunny_rounded, 'rain': '10%'},
      {'time': '5 PM', 'temp': '30°C', 'icon': Icons.cloud_rounded, 'rain': '20%'},
      {'time': '6 PM', 'temp': '29°C', 'icon': Icons.cloud_rounded, 'rain': '35%'},
      {'time': '7 PM', 'temp': '28°C', 'icon': Icons.cloud_queue_rounded, 'rain': '40%'},
      {'time': '8 PM', 'temp': '27°C', 'icon': Icons.thunderstorm_rounded, 'rain': '80%'},
    ];

    final List<Map<String, dynamic>> forecast = [
      {'day': 'Today', 'temp': '33° / 25°', 'icon': Icons.wb_sunny_rounded, 'rain': '10%'},
      {'day': 'Wednesday', 'temp': '32° / 26°', 'icon': Icons.cloud_rounded, 'rain': '30%'},
      {'day': 'Thursday', 'temp': '30° / 24°', 'icon': Icons.thunderstorm_rounded, 'rain': '80%'},
      {'day': 'Friday', 'temp': '29° / 23°', 'icon': Icons.thunderstorm_rounded, 'rain': '90%'},
      {'day': 'Saturday', 'temp': '31° / 24°', 'icon': Icons.cloud_queue_rounded, 'rain': '40%'},
      {'day': 'Sunday', 'temp': '32° / 25°', 'icon': Icons.wb_sunny_rounded, 'rain': '20%'},
      {'day': 'Monday', 'temp': '33° / 26°', 'icon': Icons.wb_sunny_rounded, 'rain': '10%'},
    ];

    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Weather Details',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header gradient card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.skyBlue, Color(0xFF01579B)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chennai, India',
                        style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Heavy Rain Forecasted Tonight',
                        style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      SizedBox(height: 12),
                      Text(
                        '31.5°C',
                        style: TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.w800),
                      ),
                      Text(
                        'Feels like 34.0°C · Humidity 65%',
                        style: TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.thunderstorm_rounded, size: 72, color: Colors.white),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Hourly Forecast
            const SectionHeader(title: 'Hourly Forecast').animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: hourly.length,
                itemBuilder: (context, idx) {
                  final h = hourly[idx];
                  return Container(
                    width: 75,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          h['time'] as String,
                          style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        Icon(h['icon'] as IconData, color: AppTheme.skyBlue, size: 24),
                        Text(
                          h['temp'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        Text(
                          h['rain'] as String,
                          style: const TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // 7-Day Forecast
            const SectionHeader(title: '7-Day Forecast').animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: forecast.length,
                  itemBuilder: (context, i) {
                    final f = forecast[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: Text(
                              f['day'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                Icon(f['icon'] as IconData, color: AppTheme.skyBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  f['rain'] as String,
                                  style: const TextStyle(color: Colors.blue, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            f['temp'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 24),

            // Farming Advice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryGreen),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Farming Alert: Suspend spraying of pesticides and liquid fertilizers today due to the high likelihood of rain wash-off this evening.',
                      style: TextStyle(fontSize: 12, height: 1.4, color: Colors.black87),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
