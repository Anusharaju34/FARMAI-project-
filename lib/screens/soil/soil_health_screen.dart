import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class SoilHealthScreen extends StatelessWidget {
  const SoilHealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Soil Health',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.3),
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
                          'Soil Quality Index',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '84 / 100',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Excellent Health',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.science_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // NPK Metrics Section
            const SectionHeader(title: 'Nutrient Analysis (NPK)').animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _NutrientBar(
                      label: 'Nitrogen (N)',
                      value: 0.65,
                      percentageText: '65%',
                      status: 'Optimal',
                      color: Colors.blue,
                    ),
                    const Divider(height: 24),
                    _NutrientBar(
                      label: 'Phosphorus (P)',
                      value: 0.32,
                      percentageText: '32%',
                      status: 'Low',
                      color: Colors.orange,
                    ),
                    const Divider(height: 24),
                    _NutrientBar(
                      label: 'Potassium (K)',
                      value: 0.85,
                      percentageText: '85%',
                      status: 'High',
                      color: Colors.red,
                    ),
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Soil Parameters
            const SectionHeader(title: 'Soil Properties').animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.opacity_rounded,
                    label: 'Moisture',
                    value: '42%',
                    status: 'Adequate',
                    color: AppTheme.skyBlue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.thermostat_rounded,
                    label: 'Temperature',
                    value: '26.4°C',
                    status: 'Optimal',
                    color: AppTheme.warningOrange,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.waves_rounded,
                    label: 'pH Level',
                    value: '6.5 pH',
                    status: 'Slightly Acidic',
                    color: AppTheme.soilBrown,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PropertyCard(
                    icon: Icons.bar_chart_rounded,
                    label: 'Organic Matter',
                    value: '3.4%',
                    status: 'Good',
                    color: Colors.teal,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 500.ms),

            const SizedBox(height: 24),

            // Crop Recommendation Section
            const SectionHeader(title: 'Recommended Fertilizers & Action').animate().fadeIn(delay: 600.ms),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lightbulb_outline_rounded, color: AppTheme.primaryGreen),
                      SizedBox(width: 8),
                      Text(
                        'Expert Advice',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.darkGreen,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Phosphorus is currently deficient in your field. To balance nutrients, we recommend applying Single Superphosphate (SSP) at 120 kg/hectare before sowing.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 700.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  final String label;
  final double value;
  final String percentageText;
  final String status;
  final Color color;

  const _NutrientBar({
    required this.label,
    required this.value,
    required this.percentageText,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            Row(
              children: [
                Text(
                  percentageText,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(width: 8),
                StatusBadge(label: status, color: color),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String status;
  final Color color;

  const _PropertyCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.status,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 18,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              status,
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
