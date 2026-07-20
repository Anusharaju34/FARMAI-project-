import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class IrrigationScheduleScreen extends StatefulWidget {
  const IrrigationScheduleScreen({super.key});

  @override
  State<IrrigationScheduleScreen> createState() =>
      _IrrigationScheduleScreenState();
}

class _IrrigationScheduleScreenState extends State<IrrigationScheduleScreen> {
  bool _valveState = false;
  String _wateringMode = 'Automatic';

  final List<Map<String, dynamic>> _schedule = [
    {
      'time': '06:00 AM',
      'duration': '15 mins',
      'volume': '12 m³',
      'status': 'Completed',
      'color': AppTheme.primaryGreen
    },
    {
      'time': '12:00 PM',
      'duration': '10 mins',
      'volume': '8 m³',
      'status': 'Skipped (Rain)',
      'color': Colors.orange
    },
    {
      'time': '06:00 PM',
      'duration': '15 mins',
      'volume': '12 m³',
      'status': 'Scheduled',
      'color': Colors.blue
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Irrigation Schedule',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Smart Control Panel
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0288D1), Color(0xFF005b9f)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smart Valve #1 Status',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'North Plot Sprinklers',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Switch(
                        value: _valveState,
                        activeColor: Colors.white,
                        activeTrackColor: Colors.greenAccent,
                        inactiveTrackColor: Colors.white30,
                        onChanged: (v) {
                          setState(() => _valveState = v);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                                content: Text(_valveState
                                    ? 'Sprinklers turned ON'
                                    : 'Sprinklers turned OFF')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Moisture Level: 42% (Optimal)',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                      Text(
                        _valveState ? 'IRRIGATING NOW' : 'VALVE CLOSED',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Mode Selector
            const SectionHeader(title: 'Irrigation Mode')
                .animate()
                .fadeIn(delay: 100.ms),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ModeButton(
                    label: 'Automatic (AI)',
                    subtitle: 'Water based on soil sensor data',
                    isSelected: _wateringMode == 'Automatic',
                    onTap: () => setState(() => _wateringMode = 'Automatic'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ModeButton(
                    label: 'Scheduled',
                    subtitle: 'Water on fixed hourly timers',
                    isSelected: _wateringMode == 'Scheduled',
                    onTap: () => setState(() => _wateringMode = 'Scheduled'),
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Timetable Schedule
            const SectionHeader(title: 'Today\'s Watering Timeline')
                .animate()
                .fadeIn(delay: 300.ms),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _schedule.length,
                  itemBuilder: (context, idx) {
                    final item = _schedule[idx];
                    final color = item['color'] as Color;

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['time'] as String,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                              Text(
                                'Volume: ${item['volume']}',
                                style: TextStyle(
                                    color: Colors.grey[500], fontSize: 11),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Text(
                            item['duration'] as String,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13),
                          ),
                          const SizedBox(width: 16),
                          StatusBadge(
                              label: item['status'] as String, color: color),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryGreen.withOpacity(0.04)
              : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGreen : Colors.grey[200]!,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: isSelected ? AppTheme.primaryGreen : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[500],
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
