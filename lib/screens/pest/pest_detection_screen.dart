import 'package:flutter/foundation.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class PestDetectionScreen extends ConsumerStatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  ConsumerState<PestDetectionScreen> createState() =>
      _PestDetectionScreenState();
}

class _PestDetectionScreenState extends ConsumerState<PestDetectionScreen> {
  XFile? _selectedImage;
  Uint8List? _webImageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  final _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final picked = await _picker.pickImage(
        source: source, imageQuality: 85, maxWidth: 1024);
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
        _result = null;
      });
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null) return;
    setState(() => _isAnalyzing = true);

    await Future.delayed(const Duration(seconds: 2)); // Mock analysis

    setState(() {
      _result = {
        'pest_name': 'Brown Planthopper (Nilaparvata lugens)',
        'confidence_score': 0.87,
        'severity_level': 'High',
        'description':
            'Brown Planthopper is a major pest of rice. Both nymphs and adults suck sap from the base of rice tillers causing hopperburn — yellowing and drying of plants.',
        'lifecycle': '15-25 days from egg to adult',
        'active_season': 'July - October (Kharif season)',
        'prevention_recommendations': [
          'Light traps to monitor and control adult population',
          'Apply neem-based pesticides (Azadirachtin 0.03% @ 2.5 ml/L)',
          'Spray Buprofezin 25 SC @ 1.0 ml/L water on plant base',
          'Maintain optimum plant spacing for air circulation',
          'Avoid over-application of nitrogen fertilizers',
          'Flood the field temporarily to drown crawlers',
          'Conserve natural enemies like spiders and mirid bugs',
        ],
        'economic_threshold': '10 hoppers per hill or 5 hoppers per tiller',
      };
      _isAnalyzing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(title: 'Pest Detection'),
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
                  colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
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
                        Text(
                          'Pest Identification',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Identify pests and get control measures',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.pest_control_rounded,
                      color: Colors.white, size: 40),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Image Upload
            GestureDetector(
              onTap: () => _showPicker(),
              child: Container(
                height: 200,
                decoration: BoxDecoration(
                  color: _selectedImage == null
                      ? const Color(0xFFFFF3E0)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFF8F00).withOpacity(0.4),
                    width: 2,
                    style: _selectedImage == null
                        ? BorderStyle.solid
                        : BorderStyle.none,
                  ),
                ),
                child: _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_rounded,
                            size: 48,
                            color: Color(0xFFFF8F00),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'Upload Pest/Insect Photo',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFE65100),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Camera or Gallery',
                            style: TextStyle(color: Colors.brown, fontSize: 12),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: kIsWeb
                            ? Image.network(_selectedImage!.path,
                                fit: BoxFit.cover)
                            : Image.file(File(_selectedImage!.path),
                                fit: BoxFit.cover),
                      ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 20),

            if (_selectedImage != null && _result == null)
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  isLoading: _isAnalyzing,
                  onPressed: _analyzeImage,
                  label: 'Identify Pest',
                  backgroundColor: const Color(0xFFE65100),
                ),
              ).animate().fadeIn(),

            if (_result != null)
              _PestResultCard(result: _result!)
                  .animate()
                  .fadeIn(duration: 500.ms),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Image Source',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Camera'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE65100),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Gallery'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _PestResultCard extends StatelessWidget {
  final Map<String, dynamic> result;
  const _PestResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final severity = result['severity_level'] as String;
    final severityColor = severity == 'High'
        ? AppTheme.alertRed
        : severity == 'Medium'
            ? AppTheme.warningOrange
            : AppTheme.primaryGreen;
    final confidence = ((result['confidence_score'] as double) * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Result Header
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE65100).withOpacity(0.2),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.bug_report_rounded,
                    color: Color(0xFFE65100),
                    size: 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pest Identified',
                          style: TextStyle(
                            color: Color(0xFFE65100),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          result['pest_name'] as String,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(label: severity, color: severityColor),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: result['confidence_score'] as double,
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryGreen),
                minHeight: 6,
                borderRadius: BorderRadius.circular(4),
              ),
              const SizedBox(height: 4),
              Text(
                '$confidence% confidence',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const Divider(height: 20),
              Text(
                result['description'] as String,
                style: const TextStyle(fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.schedule_rounded,
                      label: result['lifecycle'] as String,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.calendar_month_rounded,
                      label: result['active_season'] as String,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Control Measures
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF3E0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFFF8F00).withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.shield_rounded,
                      color: Color(0xFFE65100), size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Control & Prevention',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFE65100),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...(result['prevention_recommendations'] as List<String>)
                  .map(
                    (t) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Color(0xFFE65100),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              t,
                              style: const TextStyle(fontSize: 13, height: 1.5),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
              const Divider(),
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Color(0xFFE65100), size: 16),
                  const SizedBox(width: 6),
                  const Text(
                    'Economic Threshold: ',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  Expanded(
                    child: Text(
                      result['economic_threshold'] as String,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
  }
}
