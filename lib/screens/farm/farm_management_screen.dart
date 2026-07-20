import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class FarmManagementScreen extends StatefulWidget {
  const FarmManagementScreen({super.key});

  @override
  State<FarmManagementScreen> createState() => _FarmManagementScreenState();
}

class _FarmManagementScreenState extends State<FarmManagementScreen> {
  final List<Map<String, dynamic>> _plots = [
    {
      'name': 'North Field (Plot A)',
      'crop': 'Rice (Basmati)',
      'area': '1.5 Hectares',
      'plantedDate': 'May 12, 2026',
      'status': 'Growing',
      'color': AppTheme.primaryGreen,
    },
    {
      'name': 'Hillside Field (Plot B)',
      'crop': 'Tomatoes (Roma)',
      'area': '1.0 Hectares',
      'plantedDate': 'June 01, 2026',
      'status': 'Flowering',
      'color': AppTheme.warningOrange,
    },
    {
      'name': 'Riverbed Area (Plot C)',
      'crop': 'Fallow (Soil Recovery)',
      'area': '2.0 Hectares',
      'plantedDate': 'N/A',
      'status': 'Resting',
      'color': AppTheme.soilBrown,
    },
  ];

  void _addNewPlot() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add New Farm Plot',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppTheme.darkGreen),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Plot Name',
                hintText: 'e.g. South Field',
                prefixIcon: Icon(Icons.map_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Size / Area',
                hintText: 'e.g. 1.2 Hectares',
                prefixIcon: Icon(Icons.square_foot_rounded),
              ),
            ),
            const SizedBox(height: 12),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Crop Type',
                hintText: 'e.g. Wheat',
                prefixIcon: Icon(Icons.grass_rounded),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _plots.add({
                      'name': 'New Field (Plot ${_plots.length + 1})',
                      'crop': 'Wheat (Sonalika)',
                      'area': '1.2 Hectares',
                      'plantedDate': 'June 23, 2026',
                      'status': 'Seeded',
                      'color': Colors.blue,
                    });
                  });
                  Navigator.pop(ctx);
                },
                child: const Text('Create Plot'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Farm Management',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Acreage card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2)),
              ),
              child: const Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Managed Land',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '4.5 Hectares',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.darkGreen,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '3 Active Plots',
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryGreen, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  Spacer(),
                  Icon(Icons.landscape_rounded, size: 54, color: AppTheme.primaryGreen),
                ],
              ),
            ).animate().fadeIn().slideY(begin: 0.1),

            const SizedBox(height: 24),

            // Active Plots
            SectionHeader(
              title: 'Your Plots',
              actionLabel: '+ Add Plot',
              onAction: _addNewPlot,
            ).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 12),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _plots.length,
              itemBuilder: (context, i) {
                final p = _plots[i];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (p['color'] as Color).withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.terrain_rounded, color: p['color'] as Color, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              p['name'] as String,
                              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Crop: ${p['crop']}',
                              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                            Text(
                              'Planted: ${p['plantedDate']}',
                              style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          StatusBadge(label: p['status'] as String, color: p['color'] as Color),
                          const SizedBox(height: 8),
                          Text(
                            p['area'] as String,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 12),

            // Crop Rotations Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.withOpacity(0.15)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_rounded, color: AppTheme.warningOrange),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Tip: Rotate Riverbed Area with Nitrogen-fixing legumes (e.g., Soybeans) in July to restore soil vitality naturally.',
                      style: TextStyle(fontSize: 12, height: 1.4),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}
