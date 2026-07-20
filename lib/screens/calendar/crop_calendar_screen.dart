import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class CropCalendarScreen extends StatefulWidget {
  const CropCalendarScreen({super.key});

  @override
  State<CropCalendarScreen> createState() => _CropCalendarScreenState();
}

class _CropCalendarScreenState extends State<CropCalendarScreen> {
  String _selectedCrop = 'Rice';
  final List<String> _crops = ['Rice', 'Tomatoes', 'Wheat'];

  final Map<String, List<Map<String, dynamic>>> _tasks = {
    'Rice': [
      {
        'title': 'Apply Nitrogen Fertilizer',
        'desc': 'Top-dress urea at 50 kg/hectare during the tillering stage.',
        'time': 'Today, 8:00 AM',
        'isDone': false,
        'icon': Icons.opacity_rounded,
        'color': Colors.blue,
      },
      {
        'title': 'Shallow Flooding Management',
        'desc': 'Maintain standing water level of 2-5 cm in fields.',
        'time': 'Tomorrow, 9:00 AM',
        'isDone': true,
        'icon': Icons.water_rounded,
        'color': AppTheme.skyBlue,
      },
      {
        'title': 'Manual Weeding',
        'desc': 'Remove weeds between rows to prevent nutrient competition.',
        'time': 'June 26, 2026',
        'isDone': false,
        'icon': Icons.content_cut_rounded,
        'color': AppTheme.soilBrown,
      },
      {
        'title': 'Prophylactic Fungicide Spray',
        'desc': 'Spray Propiconazole to guard against Leaf Blast risks.',
        'time': 'June 29, 2026',
        'isDone': false,
        'icon': Icons.science_rounded,
        'color': AppTheme.alertRed,
      },
    ],
    'Tomatoes': [
      {
        'title': 'Install Staking Supports',
        'desc': 'Stake heavy branches to support weight of fruit clusters.',
        'time': 'Today, 10:00 AM',
        'isDone': true,
        'icon': Icons.grid_goldenratio_rounded,
        'color': AppTheme.warningOrange,
      },
      {
        'title': 'Drip Irrigation Session',
        'desc': 'Run drip irrigation system for 30 minutes in early morning.',
        'time': 'Tomorrow, 6:30 AM',
        'isDone': false,
        'icon': Icons.water_drop_rounded,
        'color': AppTheme.skyBlue,
      },
      {
        'title': 'Pruning Sucker Shoots',
        'desc': 'Pinch off suckers growing in leaf axils to improve aeration.',
        'time': 'June 28, 2026',
        'isDone': false,
        'icon': Icons.cut_rounded,
        'color': AppTheme.primaryGreen,
      },
    ],
    'Wheat': [
      {
        'title': 'Field Preparation',
        'desc': 'Deep plough soil and apply organic compost.',
        'time': 'July 05, 2026',
        'isDone': false,
        'icon': Icons.agriculture_rounded,
        'color': AppTheme.soilBrown,
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    final currentTasks = _tasks[_selectedCrop] ?? [];
    final completedCount = currentTasks.where((t) => t['isDone'] as bool).length;
    final totalCount = currentTasks.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Crop Calendar',
        showBack: true,
      ),
      body: Column(
        children: [
          // Crop Selector Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: Row(
              children: [
                const Text(
                  'Select Crop:',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _crops.length,
                      itemBuilder: (context, idx) {
                        final crop = _crops[idx];
                        final isSelected = _selectedCrop == crop;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedCrop = crop),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.primaryGreen : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected ? Colors.transparent : Colors.grey[300]!,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              crop,
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Weekly Progress',
                              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            Text(
                              '$completedCount/$totalCount Tasks Done',
                              style: const TextStyle(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Colors.grey[200],
                            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.1),

                  const SizedBox(height: 24),

                  // Tasks Timeline
                  const SectionHeader(title: 'Timeline Tasks').animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: 12),

                  if (currentTasks.isEmpty)
                    const EmptyStateWidget(
                      icon: Icons.calendar_today_rounded,
                      title: 'No Tasks Scheduled',
                      subtitle: 'There are no active tasks for this crop in the upcoming calendar.',
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: currentTasks.length,
                      itemBuilder: (context, i) {
                        final t = currentTasks[i];
                        final isDone = t['isDone'] as bool;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Icon & Timeline connector line
                              Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: isDone
                                          ? AppTheme.primaryGreen.withOpacity(0.12)
                                          : (t['color'] as Color).withOpacity(0.08),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isDone ? AppTheme.primaryGreen : t['color'] as Color,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: Icon(
                                      isDone ? Icons.check_rounded : t['icon'] as IconData,
                                      color: isDone ? AppTheme.primaryGreen : t['color'] as Color,
                                      size: 18,
                                    ),
                                  ),
                                  if (i < currentTasks.length - 1)
                                    Container(
                                      width: 2,
                                      height: 70,
                                      color: Colors.grey[200],
                                    ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              // Task details card
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.all(14),
                                  decoration: BoxDecoration(
                                    color: isDone ? AppTheme.surfaceLight.withOpacity(0.3) : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDone ? AppTheme.primaryGreen.withOpacity(0.2) : Colors.grey[200]!,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              t['title'] as String,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 13,
                                                decoration: isDone ? TextDecoration.lineThrough : null,
                                                color: isDone ? Colors.grey : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          Checkbox(
                                            value: isDone,
                                            activeColor: AppTheme.primaryGreen,
                                            onChanged: (val) {
                                              setState(() {
                                                t['isDone'] = val ?? false;
                                              });
                                            },
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        t['desc'] as String,
                                        style: TextStyle(
                                          fontSize: 12,
                                          height: 1.4,
                                          color: isDone ? Colors.grey[400] : Colors.grey[600],
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        t['time'] as String,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: isDone ? Colors.grey[400] : AppTheme.primaryGreen,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
