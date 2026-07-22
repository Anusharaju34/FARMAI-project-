import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../routes/app_router.dart';

class IrrigationScreen extends ConsumerStatefulWidget {
  const IrrigationScreen({super.key});

  @override
  ConsumerState<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends ConsumerState<IrrigationScreen> {
  String _selectedCrop = 'Rice';
  String _selectedSoil = 'Clay';
  double _farmArea = 1.0;
  Map<String, dynamic>? _schedule;
  bool _isCalculating = false;

  Future<void> _calculateIrrigation() async {
    setState(() => _isCalculating = true);
    await Future.delayed(const Duration(milliseconds: 1200));

    final advice = _getIrrigationAdvice(_selectedCrop, _selectedSoil, _farmArea);
    final userId = Supabase.instance.client.auth.currentUser?.id;

    if (userId != null) {
      await SupabaseService.saveIrrigationRecord({
        'user_id': userId,
        'crop_type': _selectedCrop,
        'soil_type': _selectedSoil,
        'water_required': advice['waterRequired'],
        'schedule': advice['schedule'],
        'recommendations': advice['recommendations'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    if (mounted) {
      setState(() {
        _schedule = advice;
        _isCalculating = false;
      });
    }
  }

  Map<String, dynamic> _getIrrigationAdvice(String crop, String soil, double area) {
    final cropWater = {
      'Rice': 8.0,
      'Wheat': 5.5,
      'Maize': 6.0,
      'Cotton': 7.0,
      'Sugarcane': 9.0,
      'Tomato': 5.0,
      'Potato': 4.5,
      'Onion': 4.0,
      'Soybean': 5.5,
      'Groundnut': 5.0,
    };

    final soilFactor = {
      'Clay': 0.8,
      'Sandy': 1.4,
      'Loamy': 1.0,
      'Silty': 0.9,
      'Peaty': 0.7,
      'Chalky': 1.1,
      'Black Cotton': 0.75,
    };

    final baseWater = cropWater[crop] ?? 5.5;
    final factor = soilFactor[soil] ?? 1.0;
    final dailyWater = baseWater * factor * area;
    final weeklyWater = dailyWater * 7;

    // Moisture percentage estimation
    final soilMoisture = {
      'Clay': 0.75,
      'Sandy': 0.32,
      'Loamy': 0.58,
      'Silty': 0.62,
      'Peaty': 0.82,
      'Chalky': 0.42,
      'Black Cotton': 0.70,
    };

    return {
      'waterRequired': dailyWater,
      'weeklyTotal': weeklyWater,
      'moistureLevel': soilMoisture[soil] ?? 0.55,
      'schedule': 'Every ${_getFrequency(crop, soil)} days',
      'bestTime': 'Early morning (6–8 AM) or evening (5–7 PM)',
      'method': _getBestMethod(crop, soil),
      'recommendations': [
        'Apply ${(dailyWater * 1000).toStringAsFixed(0)} liters per day for $area hectare',
        'Use drip irrigation to reduce water usage by up to 40%',
        'Mulch the soil to retain moisture for longer periods',
        'Monitor leaf color – pale yellow indicates water stress',
        'Check soil at 10 cm depth – irrigate when dry to touch',
        if (soil == 'Sandy') 'Sandy soil drains fast – increase irrigation frequency',
        if (soil == 'Clay') 'Clay soil retains water – avoid overwatering to prevent root rot',
        if (crop == 'Rice') 'Maintain 5 cm standing water during critical growth stages',
      ],
      'weeklySchedule': _getWeeklySchedule(crop),
    };
  }

  String _getFrequency(String crop, String soil) {
    if (soil == 'Sandy') return '1–2';
    if (soil == 'Clay') return '4–5';
    if (crop == 'Rice') return '2–3';
    return '3–4';
  }

  String _getBestMethod(String crop, String soil) {
    if (crop == 'Rice') return 'Flood Irrigation';
    if (soil == 'Sandy') return 'Drip Irrigation';
    if (['Tomato', 'Potato', 'Onion'].contains(crop)) return 'Drip / Sprinkler';
    return 'Furrow / Sprinkler';
  }

  List<Map<String, dynamic>> _getWeeklySchedule(String crop) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final highWater = ['Rice', 'Sugarcane', 'Cotton'];
    return days.asMap().entries.map((e) {
      final irrigate = highWater.contains(crop) ? e.key % 2 == 0 : e.key % 3 == 0;
      return {'day': e.value, 'irrigate': irrigate};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: FarmAIAppBar(
        title: 'Irrigation Advisor',
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded, color: AppTheme.waterBlue),
            onPressed: () => context.push(AppRoutes.irrigationSchedule),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0288D1).withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Smart Irrigation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'AI-powered water scheduling advice.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Icon(Icons.water_rounded, color: Colors.white, size: 36),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Input Form Card
            _InputCard(
              selectedCrop: _selectedCrop,
              selectedSoil: _selectedSoil,
              farmArea: _farmArea,
              onCropChanged: (v) => setState(() => _selectedCrop = v!),
              onSoilChanged: (v) => setState(() => _selectedSoil = v!),
              onAreaChanged: (v) => setState(() => _farmArea = v),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 18),

            // Calculate Button
            LoadingButton(
              isLoading: _isCalculating,
              onPressed: _calculateIrrigation,
              label: 'Calculate Irrigation Plan',
              backgroundColor: const Color(0xFF0288D1),
            ).animate().fadeIn(delay: 300.ms),

            if (_schedule != null) ...[
              const SizedBox(height: 24),
              _IrrigationResult(
                schedule: _schedule!,
                crop: _selectedCrop,
                soil: _selectedSoil,
              ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
            ],

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }
}

class _InputCard extends StatelessWidget {
  final String selectedCrop;
  final String selectedSoil;
  final double farmArea;
  final void Function(String?) onCropChanged;
  final void Function(String?) onSoilChanged;
  final void Function(double) onAreaChanged;

  const _InputCard({
    required this.selectedCrop,
    required this.selectedSoil,
    required this.farmArea,
    required this.onCropChanged,
    required this.onSoilChanged,
    required this.onAreaChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark ? AppTheme.borderDark : AppTheme.borderLight,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Farm Parameters',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const SizedBox(height: 18),

          // Crop selector
          const Text('Crop Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedCrop,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.grass_rounded, size: 18),
            ),
            items: AppConstants.cropTypes.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: onCropChanged,
          ),

          const SizedBox(height: 18),

          // Soil selector
          const Text('Soil Type', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedSoil,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.layers_rounded, size: 18),
            ),
            items: AppConstants.soilTypes.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: onSoilChanged,
          ),

          const SizedBox(height: 18),

          // Area Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Farm Area', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0288D1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${farmArea.toStringAsFixed(1)} hectares',
                  style: const TextStyle(
                    color: Color(0xFF0288D1),
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: farmArea,
            min: 0.5,
            max: 10.0,
            divisions: 19,
            activeColor: const Color(0xFF0288D1),
            inactiveColor: const Color(0xFF0288D1).withOpacity(0.2),
            onChanged: onAreaChanged,
          ),
        ],
      ),
    );
  }
}

class _IrrigationResult extends StatelessWidget {
  final Map<String, dynamic> schedule;
  final String crop;
  final String soil;

  const _IrrigationResult({
    required this.schedule,
    required this.crop,
    required this.soil,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moisture = schedule['moistureLevel'] as double;
    final waterReq = schedule['waterRequired'] as double;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Premium Gauge and Tank Panel
        Row(
          children: [
            // Circular Moisture Level Gauge
            Expanded(
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'SOIL MOISTURE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 80,
                          width: 80,
                          child: CircularProgressIndicator(
                            value: moisture,
                            strokeWidth: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.waterBlue),
                          ),
                        ),
                        Text(
                          '${(moisture * 100).round()}%',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      soil,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Water Tank level indicator
            Expanded(
              child: Container(
                height: 180,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'DAILY WATER TANK',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: Container(
                        width: 50,
                        decoration: BoxDecoration(
                          color: isDark ? Colors.grey[800] : Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[400]!, width: 1),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            FractionallySizedBox(
                              heightFactor: (waterReq / 15.0).clamp(0.1, 1.0),
                              child: Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${waterReq.toStringAsFixed(1)} m³ / day',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Summary Stats Row
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0288D1), Color(0xFF29B6F6)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              _StatBox(
                label: 'Weekly Vol',
                value: '${(schedule['weeklyTotal'] as double).toStringAsFixed(0)} m³',
                icon: Icons.local_drink_rounded,
              ),
              _vDivider(),
              _StatBox(
                label: 'Interval',
                value: schedule['schedule'] as String,
                icon: Icons.calendar_today_rounded,
              ),
              _vDivider(),
              _StatBox(
                label: 'Optimal time',
                value: 'Morning/Eve',
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Method & Timing Description Block
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: isDark ? AppTheme.borderDark : const Color(0xFFB3E5FC), width: 1.2),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.settings_rounded,
                label: 'Best Method',
                value: schedule['method'] as String,
              ),
              const Divider(height: 20),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Best Time',
                value: schedule['bestTime'] as String,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weekly Grid Schedule Planner
        _WeeklyScheduleWidget(
          days: (schedule['weeklySchedule'] as List).cast<Map<String, dynamic>>(),
        ),

        const SizedBox(height: 16),

        // Recommendations List
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(20),
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
                  Icon(Icons.eco_rounded, color: AppTheme.primaryGreen, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Advisor Recommendations',
                    style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryGreen),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ...(schedule['recommendations'] as List<String>).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.primaryGreen),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          r,
                          style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(
        height: 38,
        width: 1,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white.withOpacity(0.8), size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(color: Colors.white.withOpacity(0.75), fontSize: 10, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF0288D1)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: Color(0xFF0288D1)),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _WeeklyScheduleWidget extends StatelessWidget {
  final List<Map<String, dynamic>> days;
  const _WeeklyScheduleWidget({required this.days});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Plan Calendar',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: days.map((d) {
              final irrigate = d['irrigate'] as bool;
              return Column(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: irrigate ? const Color(0xFF0288D1) : (isDark ? AppTheme.surfaceDark : Colors.grey[200]),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      irrigate ? Icons.water_drop_rounded : Icons.do_not_disturb_rounded,
                      color: irrigate ? Colors.white : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    d['day'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: irrigate ? const Color(0xFF0288D1) : Colors.grey,
                      fontWeight: irrigate ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
