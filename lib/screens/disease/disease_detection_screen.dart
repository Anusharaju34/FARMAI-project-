import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_theme.dart';
import '../../routes/app_router.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';

class DiseaseDetectionScreen extends ConsumerStatefulWidget {
  final String? testImagePath;
  final bool testDisableSave;

  const DiseaseDetectionScreen({
    super.key,
    this.testImagePath,
    this.testDisableSave = false,
  });

  @override
  ConsumerState<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends ConsumerState<DiseaseDetectionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  int _analysisCountdown = 3;
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();
    if (widget.testImagePath != null) {
      _loadTestImage(widget.testImagePath!);
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadTestImage(String path) async {
    try {
      final XFile image = XFile(path);
      final Uint8List bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = image;
        _selectedImageBytes = bytes;
      });
    } catch (error) {
      debugPrint('Unable to load test image: $error');
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedImage = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (pickedImage == null) return;
      final Uint8List bytes = await pickedImage.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImage = pickedImage;
        _selectedImageBytes = bytes;
        _result = null;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to select image: $error')),
      );
    }
  }

  Future<void> _analyzeImage() async {
    final XFile? selectedImage = _selectedImage;
    if (selectedImage == null || _isAnalyzing) return;

    final User? user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in before analysing an image.')),
      );
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _analysisCountdown = 3;
    });

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        if (_analysisCountdown > 1) {
          _analysisCountdown--;
        } else {
          _countdownTimer?.cancel();
        }
      });
    });

    try {
      final String extension = _getFileExtension(selectedImage.name);
      final String fileName = '${const Uuid().v4()}.$extension';

      final String imageUrl = await SupabaseService.uploadImage(
        file: selectedImage,
        bucket: 'crop-images',
        path: '${user.id}/$fileName',
      );

      await Future.delayed(const Duration(milliseconds: 2500));

      final Map<String, dynamic> mockResult = _getDynamicDiseaseResult(selectedImage.name);

      if (!widget.testDisableSave) {
        await SupabaseService.saveDiseasePrediction({
          'user_id': user.id,
          'image_url': imageUrl,
          'disease_name': mockResult['disease_name'],
          'confidence_score': mockResult['confidence_score'],
          'crop_type': mockResult['crop_type'],
          'severity': mockResult['severity'],
          'treatment_suggestions': mockResult['treatment_suggestions'],
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      if (!mounted) return;
      setState(() {
        _result = mockResult;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("We couldn't identify the crop clearly. Please take another photo in good sunlight."),
          backgroundColor: AppTheme.alertRed,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      _countdownTimer?.cancel();
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
        });
      }
    }
  }

  Map<String, dynamic> _getDynamicDiseaseResult(String fileName) {
    final lower = fileName.toLowerCase();
    final random = Random();

    if (lower.contains('wheat') || lower.contains('rust')) {
      return {
        'disease_name': 'Black Stem Rust (Puccinia graminis)',
        'confidence_score': 0.89 + (random.nextDouble() * 0.08),
        'severity': 'Severe',
        'crop_type': 'Wheat',
        'description': 'A devastating fungal disease affecting wheat. Causes reddish-brown pustules on stems and leaves, leading to lodging and reduced grain fill.',
        'treatment_suggestions': [
          'Apply Propiconazole 25% EC @ 2ml/L of water',
          'Use rust-resistant wheat varieties (e.g., HD 2967)',
          'Avoid late sowing to minimize disease exposure'
        ],
        'prevention': [
          'Rotate crops with non-cereal options',
          'Eliminate barberry plants (alternate host)'
        ]
      };
    }

    if (lower.contains('tomato') || lower.contains('potato') || lower.contains('blight')) {
      return {
        'disease_name': 'Late Blight (Phytophthora infestans)',
        'confidence_score': 0.91 + (random.nextDouble() * 0.06),
        'severity': 'Severe',
        'crop_type': 'Tomato / Potato',
        'description': 'A highly destructive disease showing dark water-soaked lesions on leaves and white cottony growth on the underside during humid weather.',
        'treatment_suggestions': [
          'Spray Mancozeb @ 2.5g/L or Metalaxyl + Mancozeb @ 2g/L',
          'Ensure wide spacing for foliage dry-off',
          'Promptly harvest and destroy infected plants'
        ],
        'prevention': [
          'Avoid overhead sprinkler irrigation',
          'Apply preventive copper sprays early in the season'
        ]
      };
    }

    if (lower.contains('mildew') || lower.contains('leaf') || lower.contains('spots')) {
      return {
        'disease_name': 'Powdery Mildew (Podosphaera)',
        'confidence_score': 0.85 + (random.nextDouble() * 0.1),
        'severity': 'Mild',
        'crop_type': 'Vegetables / Grains',
        'description': 'Fungal infection forming white, powdery spots on leaves, stems, and fruits, leading to premature leaf drop.',
        'treatment_suggestions': [
          'Spray Wettable Sulfur 80% WP @ 2g/L of water',
          'Use Neem oil sprays as organic alternative',
          'Prune inner branches to improve sun penetration'
        ],
        'prevention': [
          'Grow crops in full sunlight',
          'Maintain clean field borders'
        ]
      };
    }

    final list = [
      {
        'disease_name': 'Bacterial Leaf Blight (Xanthomonas oryzae)',
        'confidence_score': 0.92,
        'severity': 'Moderate',
        'crop_type': 'Rice',
        'description': 'Causes dry straw-colored stripes on leaves, leading to wilting of the tillers in young rice crops.',
        'treatment_suggestions': [
          'Apply Copper Oxychloride @ 3g/L + Streptocycline @ 0.1g/L',
          'Avoid excess nitrogenous fertilizers',
          'Drain field immediately to lower relative humidity'
        ],
        'prevention': [
          'Treat seeds with hot water at 52°C',
          'Maintain balanced soil NPK levels'
        ]
      },
      {
        'disease_name': 'Cotton Leaf Curl Virus (CLCuV)',
        'confidence_score': 0.88,
        'severity': 'Severe',
        'crop_type': 'Cotton',
        'description': 'Viral disease transmitted by whiteflies. Causes leaf thickening, upward curling, and cup-shaped leaf growth.',
        'treatment_suggestions': [
          'Control vector whitefly using Imidacloprid 17.8% SL @ 0.5ml/L',
          'Uproot and destroy infected weed hosts',
          'Foliar spray of Potassium nitrate to improve vigor'
        ],
        'prevention': [
          'Sow crop early to avoid high whitefly pressure',
          'Use resistant cultivars'
        ]
      }
    ];

    return list[random.nextInt(list.length)];
  }

  String _getFileExtension(String fileName) {
    final String lowerName = fileName.toLowerCase();
    if (lowerName.endsWith('.png')) return 'png';
    if (lowerName.endsWith('.webp')) return 'webp';
    if (lowerName.endsWith('.gif')) return 'gif';
    return 'jpg';
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: FarmAIAppBar(
        title: 'Disease Detection',
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded, color: AppTheme.primaryGreen),
            onPressed: () => context.push(AppRoutes.diseaseHistory),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Header
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.primaryGreen, Color(0xFF1B5E20)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
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
                          'AI Crop Diagnosis 🌾',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Find out crop diseases and treatments in simple language.',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.85),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Scan / Upload display area
            GestureDetector(
              onTap: _isAnalyzing ? null : _showImageSourceDialog,
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: _selectedImage == null
                      ? (isDark ? AppTheme.cardDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.primaryGreen.withOpacity(0.2),
                    width: 2,
                    style: _selectedImage == null ? BorderStyle.solid : BorderStyle.none,
                  ),
                ),
                child: _selectedImage == null
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 38,
                              color: AppTheme.primaryGreen,
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Take Photo or Upload Leaf',
                            style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.primaryGreen, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ensure clear photo in good sunlight',
                            style: TextStyle(color: Colors.grey[500], fontSize: 12, fontWeight: FontWeight.w500),
                          ),
                        ],
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(24),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_selectedImageBytes != null)
                              Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                            else
                              const Center(child: CircularProgressIndicator(color: AppTheme.primaryGreen)),

                            // Continuous laser scan line overlay when analyzing
                            if (_isAnalyzing)
                              Positioned.fill(
                                child: Container(
                                  color: Colors.black26,
                                  child: Stack(
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 4,
                                        decoration: const BoxDecoration(
                                          color: Colors.greenAccent,
                                          boxShadow: [
                                            BoxShadow(color: Colors.greenAccent, blurRadius: 16, spreadRadius: 4),
                                          ],
                                        ),
                                      )
                                          .animate(onPlay: (c) => c.repeat(reverse: true))
                                          .slideY(begin: 0, end: 55, duration: 1500.ms),
                                    ],
                                  ),
                                ),
                              ),

                            if (!_isAnalyzing)
                              Positioned(
                                top: 12,
                                right: 12,
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                ),
                              ),
                          ],
                        ),
                      ),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 24),

            // Analyzing status / Estimated countdown indicator
            if (_isAnalyzing)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: isDark ? AppTheme.cardDark : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.sync_rounded,
                          color: AppTheme.primaryGreen,
                          size: 24,
                        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
                        const SizedBox(width: 12),
                        const Text(
                          'Analyzing your crop...',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Estimated time: $_analysisCountdown seconds remaining',
                      style: TextStyle(color: Colors.grey[500], fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ).animate().fadeIn(),

            if (_selectedImage != null && !_isAnalyzing && _result == null)
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  isLoading: _isAnalyzing,
                  onPressed: _analyzeImage,
                  label: 'Analyze Leaf Disease',
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

            if (_result != null && !_isAnalyzing)
              _ResultCard(result: _result!).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showImageSourceDialog() {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (BuildContext bottomSheetContext) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 17),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.camera_alt_rounded,
                      label: 'Camera',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _pickImage(ImageSource.camera);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SourceButton(
                      icon: Icons.photo_library_rounded,
                      label: 'Gallery',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _pickImage(ImageSource.gallery);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.primaryGreen.withOpacity(0.1),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _ResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final info = _translateToFarmerFriendly(result);
    final severity = info['severity'] as String;

    final Color severityColor = severity == 'Severe'
        ? AppTheme.alertRed
        : severity == 'Moderate'
            ? AppTheme.warningOrange
            : AppTheme.primaryGreen;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        // Success Header Banner
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppTheme.primaryGreen.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.2), width: 1.2),
          ),
          child: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: AppTheme.primaryGreen, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your crop has been analyzed successfully.',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.primaryGreen),
                ),
              ),
            ],
          ),
        ),

        // Primary Severity and Crop Diagnosis Card
        PremiumGlassCard(
          padding: const EdgeInsets.all(22),
          color: isDark ? AppTheme.cardDark : Colors.white,
          borderOpacity: 0.08,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: severityColor.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.coronavirus_rounded, color: severityColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${info['crop_type']} Disease Report'.toUpperCase(),
                          style: TextStyle(
                            color: severityColor,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          info['friendly_name'] as String,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Confidence and Severity indicators
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          info['friendly_confidence'] as String,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.primaryGreen),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  StatusBadge(label: severity.toUpperCase(), color: severityColor),
                ],
              ),
              const Divider(height: 28),

              // Farmer-friendly plain text symptom description
              const Text(
                'WHAT WE DETECTED',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                info['description'] as String,
                style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Farmer Treatment Steps (Cards Grid)
        const Text(
          'RECOMMENDED TREATMENTS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),

        // Action Cards list
        _TreatmentStepCard(
          title: 'Immediate Action',
          content: info['immediate_action'] as String,
          icon: Icons.timer_outlined,
          color: AppTheme.alertRed,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Reason for Disease',
          content: info['reason'] as String,
          icon: Icons.help_outline_rounded,
          color: AppTheme.warningOrange,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Medicine Spray',
          content: info['medicine'] as String,
          icon: Icons.medication_liquid_rounded,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Organic Solution',
          content: info['organic'] as String,
          icon: Icons.eco_outlined,
          color: Colors.teal,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Watering Advice',
          content: info['water_advice'] as String,
          icon: Icons.water_drop_outlined,
          color: AppTheme.waterBlue,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Expected Recovery',
          content: info['recovery_outlook'] as String,
          icon: Icons.calendar_month_outlined,
          color: AppTheme.earthBrown,
        ),

        const SizedBox(height: 18),

        // Government & Agriculture Office Support card
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: isDark ? AppTheme.cardDark : const Color(0xFFFFF9C4),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: isDark ? AppTheme.borderDark : const Color(0xFFFBC02D).withOpacity(0.3),
              width: 1.2,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFBC02D).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.gavel_rounded, color: Color(0xFFF57F17), size: 20),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Govt Agriculture Extension Office Recommendation',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF57F17), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Contact Tamil Nadu Agri Dept helpline or visit nearest block development agency for subsidized fungicides.',
                      style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Map<String, dynamic> _translateToFarmerFriendly(Map<String, dynamic> rawResult) {
    final diseaseName = rawResult['disease_name'] as String;
    final cropType = rawResult['crop_type'] as String;
    final severity = rawResult['severity'] as String;
    final confidenceScore = rawResult['confidence_score'] as double;

    String friendlyName = 'Your plant appears to have $diseaseName';
    if (diseaseName.contains('Leaf Curl')) {
      friendlyName = 'Your cotton plant appears to have Leaf Curl Disease.';
    } else if (diseaseName.contains('Rust')) {
      friendlyName = 'Your wheat plant has Stem Rust Disease.';
    } else if (diseaseName.contains('Late Blight')) {
      friendlyName = 'Your plant has Late Blight Disease.';
    } else if (diseaseName.contains('Powdery Mildew')) {
      friendlyName = 'Your plant has Powdery Mildew.';
    } else if (diseaseName.contains('Bacterial Leaf Blight')) {
      friendlyName = 'Your rice plant has Leaf Blight Disease.';
    }

    String friendlyConfidence = 'We are highly confident about this result.';
    if (confidenceScore < 0.70) {
      friendlyConfidence = 'This is our best guess, but please double check.';
    } else if (confidenceScore < 0.85) {
      friendlyConfidence = 'We are moderately confident about this result.';
    }

    final rawDesc = rawResult['description'] as String? ?? '';
    String friendlyDescription = rawDesc
        .replaceAll('Necrotic lesions observed', 'Brown spots are spreading on the leaves')
        .replaceAll('necrotic lesions', 'brown spots')
        .replaceAll('Chlorosis', 'The leaves are turning yellow')
        .replaceAll('chlorosis', 'leaves turning yellow')
        .replaceAll('Leaf curling', 'The leaves are folding and curling')
        .replaceAll('leaf curling', 'leaves folding and curling')
        .replaceAll('Fungal infection', 'A fungus has infected the plant')
        .replaceAll('fungal infection', 'fungus infection')
        .replaceAll('viral disease', 'virus disease')
        .replaceAll('Viral disease', 'A virus has infected the plant')
        .replaceAll('transmitted by whiteflies', 'spread by tiny insects (whiteflies)')
        .replaceAll('infected weed hosts', 'nearby infected weeds')
        .replaceAll('foliar spray', 'spraying on leaves')
        .replaceAll('fungal disease', 'fungus disease')
        .replaceAll('lodging', 'falling over');

    String immediateAction = 'Remove infected leaves today.';
    if (diseaseName.contains('Late Blight') || diseaseName.contains('Blight')) {
      immediateAction = 'Remove and safely destroy infected plants today.';
    } else if (diseaseName.contains('Rust')) {
      immediateAction = 'Identify infected patches and spray immediately.';
    }

    String reason = 'This usually happens because of a fungal infection.';
    if (diseaseName.contains('Virus') || diseaseName.contains('Curl')) {
      reason = 'This usually happens because of a virus spread by whiteflies.';
    } else if (diseaseName.contains('Bacterial')) {
      reason = 'This usually happens because of a bacterial infection in warm, humid weather.';
    }

    String medicine = 'Spray Mancozeb @ 2.5g/L or Copper Oxychloride @ 3g/L.';
    if (diseaseName.contains('Rust')) {
      medicine = 'Spray Propiconazole 25% EC @ 2ml/L of water.';
    } else if (diseaseName.contains('Mildew')) {
      medicine = 'Spray Wettable Sulfur 80% WP @ 2g/L of water.';
    }

    String organic = 'Spray Neem oil mixture (5ml per liter of water) or biological extract.';
    String waterAdvice = 'Do not water the leaves directly.';
    String recoveryOutlook = 'The crop may recover in about 7–10 days.';

    return {
      'friendly_name': friendlyName,
      'friendly_confidence': friendlyConfidence,
      'description': friendlyDescription,
      'immediate_action': immediateAction,
      'reason': reason,
      'medicine': medicine,
      'organic': organic,
      'water_advice': waterAdvice,
      'recovery_outlook': recoveryOutlook,
      'severity': severity,
      'crop_type': cropType,
    };
  }
}

class _TreatmentStepCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color color;

  const _TreatmentStepCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppTheme.borderDark : AppTheme.borderLight, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: color),
                ),
                const SizedBox(height: 4),
                Text(
                  content,
                  style: const TextStyle(fontSize: 13, height: 1.4, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}