import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';

class IrrigationScreen extends ConsumerStatefulWidget {
  const IrrigationScreen({super.key});

  @override
  ConsumerState<IrrigationScreen> createState() => _IrrigationScreenState();
}

class _IrrigationScreenState extends ConsumerState<IrrigationScreen> {
  String _selectedCrop = 'Rice';
  String _selectedSoil = 'Clay';
  double _farmArea = 1.0;
  String? _result;
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

    setState(() {
      _schedule = advice;
      _isCalculating = false;
    });
  }

  Map<String, dynamic> _getIrrigationAdvice(
      String crop, String soil, double area) {
    // Crop base water requirement (mm/day)
    final cropWater = {
      'Rice': 8.0, 'Wheat': 5.5, 'Maize': 6.0, 'Cotton': 7.0,
      'Sugarcane': 9.0, 'Tomato': 5.0, 'Potato': 4.5, 'Onion': 4.0,
      'Soybean': 5.5, 'Groundnut': 5.0,
    };

    // Soil moisture retention factor
    final soilFactor = {
      'Clay': 0.8, 'Sandy': 1.4, 'Loamy': 1.0, 'Silty': 0.9,
      'Peaty': 0.7, 'Chalky': 1.1, 'Black Cotton': 0.75,
    };

    final baseWater = cropWater[crop] ?? 5.5;
    final factor = soilFactor[soil] ?? 1.0;
    final dailyWater = baseWater * factor * area; // cubic meters per day
    final weeklyWater = dailyWater * 7;

    return {
      'waterRequired': dailyWater,
      'weeklyTotal': weeklyWater,
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
      final irrigate = highWater.contains(crop)
          ? e.key % 2 == 0
          : e.key % 3 == 0;
      return {'day': e.value, 'irrigate': irrigate};
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(title: 'Irrigation Advisor'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0277BD), Color(0xFF29B6F6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Smart Irrigation',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('AI-powered water management advice',
                            style:
                                TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.water_rounded, color: Colors.white, size: 44),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Input Form
            _InputCard(
              selectedCrop: _selectedCrop,
              selectedSoil: _selectedSoil,
              farmArea: _farmArea,
              onCropChanged: (v) => setState(() => _selectedCrop = v!),
              onSoilChanged: (v) => setState(() => _selectedSoil = v!),
              onAreaChanged: (v) => setState(() => _farmArea = v),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // Calculate Button
            SizedBox(
              width: double.infinity,
              child: LoadingButton(
                isLoading: _isCalculating,
                onPressed: _calculateIrrigation,
                label: 'Calculate Irrigation Plan',
                backgroundColor: const Color(0xFF0277BD),
              ),
            ).animate().fadeIn(delay: 300.ms),

            if (_schedule != null) ...[
              const SizedBox(height: 24),
              _IrrigationResult(schedule: _schedule!)
                  .animate()
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: 0.2),
            ],

            const SizedBox(height: 80),
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
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Details',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),

          // Crop
          const Text('Crop Type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedCrop,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.grass_rounded, size: 18),
            ),
            items: AppConstants.cropTypes
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: onCropChanged,
          ),

          const SizedBox(height: 16),

          // Soil
          const Text('Soil Type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedSoil,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.layers_rounded, size: 18),
            ),
            items: AppConstants.soilTypes
                .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                .toList(),
            onChanged: onSoilChanged,
          ),

          const SizedBox(height: 16),

          // Area Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Farm Area',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF0277BD).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${farmArea.toStringAsFixed(1)} hectares',
                  style: const TextStyle(
                    color: Color(0xFF0277BD),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
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
            activeColor: const Color(0xFF0277BD),
            onChanged: onAreaChanged,
          ),
        ],
      ),
    );
  }
}

class _IrrigationResult extends StatelessWidget {
  final Map<String, dynamic> schedule;
  const _IrrigationResult({required this.schedule});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Stats
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0277BD), Color(0xFF29B6F6)],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              _StatBox(
                label: 'Daily Water',
                value: '${(schedule['waterRequired'] as double).toStringAsFixed(1)}m³',
                icon: Icons.water_drop_rounded,
              ),
              _vDivider(),
              _StatBox(
                label: 'Weekly Total',
                value: '${(schedule['weeklyTotal'] as double).toStringAsFixed(0)}m³',
                icon: Icons.local_drink_rounded,
              ),
              _vDivider(),
              _StatBox(
                label: 'Frequency',
                value: schedule['schedule'] as String,
                icon: Icons.schedule_rounded,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Method & Timing
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              _InfoRow(
                icon: Icons.settings_rounded,
                label: 'Best Method',
                value: schedule['method'] as String,
              ),
              const Divider(height: 16),
              _InfoRow(
                icon: Icons.access_time_rounded,
                label: 'Best Time',
                value: schedule['bestTime'] as String,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Weekly Schedule
        _WeeklyScheduleWidget(
            days: (schedule['weeklySchedule'] as List)
                .cast<Map<String, dynamic>>()),

        const SizedBox(height: 16),

        // Recommendations
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.eco_rounded,
                      color: AppTheme.primaryGreen, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Recommendations',
                    style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.darkGreen),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(schedule['recommendations'] as List<String>).map(
                (r) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 15, color: AppTheme.primaryGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(r,
                            style: const TextStyle(
                                fontSize: 13, height: 1.4)),
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
        height: 40,
        width: 1,
        color: Colors.white.withOpacity(0.3),
        margin: const EdgeInsets.symmetric(horizontal: 4),
      );
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _StatBox(
      {required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14),
              textAlign: TextAlign.center),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.7), fontSize: 11),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: const Color(0xFF0277BD)),
        const SizedBox(width: 8),
        Text('$label: ',
            style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: Color(0xFF0277BD))),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 13)),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Weekly Schedule',
              style:
                  TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
          const SizedBox(height: 12),
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
                      color: irrigate
                          ? const Color(0xFF0277BD)
                          : Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      irrigate
                          ? Icons.water_drop_rounded
                          : Icons.do_not_disturb_rounded,
                      color: irrigate ? Colors.white : Colors.grey[400],
                      size: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    d['day'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      color: irrigate ? const Color(0xFF0277BD) : Colors.grey,
                      fontWeight: irrigate ? FontWeight.w700 : FontWeight.w400,
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
