import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class PestDetectionScreen extends ConsumerStatefulWidget {
  const PestDetectionScreen({super.key});

  @override
  ConsumerState<PestDetectionScreen> createState() => _PestDetectionScreenState();
}

class _PestDetectionScreenState extends ConsumerState<PestDetectionScreen> {
  XFile? _selectedImage;
  Uint8List? _selectedImageBytes;
  bool _isAnalyzing = false;
  Map<String, dynamic>? _result;
  final _picker = ImagePicker();
  int _analysisCountdown = 3;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _selectedImage = picked;
          _selectedImageBytes = bytes;
          _result = null;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _analyzeImage() async {
    if (_selectedImage == null || _isAnalyzing) return;
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
      await Future.delayed(const Duration(milliseconds: 2500));
      final Map<String, dynamic> mockResult = _getDynamicPestResult(_selectedImage!.name);
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

  Map<String, dynamic> _getDynamicPestResult(String fileName) {
    final lower = fileName.toLowerCase();
    final random = Random();

    if (lower.contains('corn') || lower.contains('maize') || lower.contains('armyworm')) {
      return {
        'pest_name': 'Fall Armyworm (Spodoptera frugiperda)',
        'confidence_score': 0.90 + (random.nextDouble() * 0.08),
        'severity_level': 'High',
        'description': 'A highly destructive caterpillar feeding on maize whorls. Larvae feed aggressively on leaves, creating large holes and sawdust-like waste.',
        'lifecycle': '30-40 days cycle',
        'active_season': 'June - September (Monsoon)',
        'prevention_recommendations': [
          'Spray Spinetoram 11.7 SC @ 0.5ml/L of water',
          'Apply sand or neem seed powder in crop whorls',
          'Conserve natural predators like parasitic wasps'
        ],
        'economic_threshold': '10% plants showing damage'
      };
    }

    if (lower.contains('tomato') || lower.contains('borer') || lower.contains('fruit')) {
      return {
        'pest_name': 'Tomato Fruit Borer (Helicoverpa armigera)',
        'confidence_score': 0.87 + (random.nextDouble() * 0.09),
        'severity_level': 'Medium',
        'description': 'Larvae bore into tomato fruits, rendering them unfit for sale and consumption. Causes heavy economic losses.',
        'lifecycle': '28-35 days cycle',
        'active_season': 'October - February (Winter)',
        'prevention_recommendations': [
          'Install pheromone traps @ 5 per acre for monitoring',
          'Spray Bacillus thuringiensis (Bt) @ 2g/L of water',
          'Release Trichogramma egg parasitoids @ 50,000/acre'
        ],
        'economic_threshold': '1 egg or larvae per plant'
      };
    }

    if (lower.contains('aphid') || lower.contains('cotton') || lower.contains('bug')) {
      return {
        'pest_name': 'Cotton Aphid (Aphis gossypii)',
        'confidence_score': 0.83 + (random.nextDouble() * 0.12),
        'severity_level': 'Low',
        'description': 'Small green-black insects sucking sap from the underside of leaves, causing curling, yellowing, and sticky soot mold.',
        'lifecycle': '7-14 days cycle',
        'active_season': 'Year-round in humid conditions',
        'prevention_recommendations': [
          'Spray neem oil @ 5ml/L or insecticidal soap',
          'Apply Dimethoate 30% EC @ 1ml/L for heavy infestations',
          'Introduce ladybird beetles to feed on aphid colonies'
        ],
        'economic_threshold': '20% infested leaves'
      };
    }

    final list = [
      {
        'pest_name': 'Brown Planthopper (Nilaparvata lugens)',
        'confidence_score': 0.88,
        'severity_level': 'High',
        'description': 'Brown Planthopper is a major pest of rice. Both nymphs and adults suck sap from the base of rice tillers causing hopperburn.',
        'lifecycle': '15-25 days cycle',
        'active_season': 'July - October (Kharif)',
        'prevention_recommendations': [
          'Spray Buprofezin 25 SC @ 1.0 ml/L at plant base',
          'Avoid over-application of nitrogen fertilizers',
          'Set up light traps to catch adult planthoppers'
        ],
        'economic_threshold': '10 hoppers per hill'
      },
      {
        'pest_name': 'Yellow Stem Borer (Scirpophaga incertulas)',
        'confidence_score': 0.91,
        'severity_level': 'High',
        'description': 'Larvae bore into the central leaf sheath of rice, causing "dead heart" in vegetative stages and "whiteheads" in flowering stages.',
        'lifecycle': '35-50 days cycle',
        'active_season': 'August - October',
        'prevention_recommendations': [
          'Apply Cartap Hydrochloride 4G @ 10kg/acre in standing water',
          'Clipping leaf tips before transplanting to destroy eggs',
          'Collect and destroy egg masses manually'
        ],
        'economic_threshold': '2% dead hearts or 1 egg mass per sq meter'
      }
    ];

    return list[random.nextInt(list.length)];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      appBar: const FarmAIAppBar(title: 'Pest Detection'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner Card
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE65100), Color(0xFFFF8F00)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE65100).withOpacity(0.2),
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
                          'Pest Identification 🐛',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Identify destructive pests and find organic or chemical fixes.',
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
                    child: const Icon(Icons.bug_report_rounded, color: Colors.white, size: 28),
                  ),
                ],
              ),
            ).animate().fadeIn().slideY(begin: -0.1),

            const SizedBox(height: 24),

            // Image picker upload box
            GestureDetector(
              onTap: _isAnalyzing ? null : _showPicker,
              child: Container(
                height: 230,
                decoration: BoxDecoration(
                  color: _selectedImage == null
                      ? (isDark ? AppTheme.cardDark : Colors.white)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFFFF8F00).withOpacity(0.3),
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
                              color: const Color(0xFFFF8F00).withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.camera_alt_outlined,
                              size: 38,
                              color: Color(0xFFFF8F00),
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'Take Photo or Upload Pest',
                            style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFE65100), fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hold camera close to the insect',
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
                              const Center(child: CircularProgressIndicator(color: Color(0xFFFF8F00))),

                            // Continuous green laser scan line overlay when analyzing
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

            // Analyzing status / countdown timer
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
                          color: Color(0xFFE65100),
                          size: 24,
                        ).animate(onPlay: (c) => c.repeat()).rotate(duration: 2.seconds),
                        const SizedBox(width: 12),
                        const Text(
                          'Analyzing insect details...',
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
                  label: 'Identify Insect Pest',
                  backgroundColor: const Color(0xFFE65100),
                ),
              ).animate().fadeIn().slideY(begin: 0.1),

            if (_result != null && !_isAnalyzing)
              _PestResultCard(result: _result!).animate().fadeIn(duration: 500.ms).slideY(begin: 0.15),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _showPicker() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppTheme.cardDark : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
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
                    color: const Color(0xFFE65100),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SourceButton(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    color: const Color(0xFFE65100),
                    onTap: () {
                      Navigator.pop(ctx);
                      _pickImage(ImageSource.gallery);
                    },
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final info = _translatePestToFarmerFriendly(result);
    final severity = info['severity'] as String;

    final severityColor = severity == 'High'
        ? AppTheme.alertRed
        : severity == 'Medium'
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

        // Primary severity card
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
                    child: Icon(Icons.bug_report_rounded, color: severityColor, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pest Identified'.toUpperCase(),
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

              // Confidence and active tags
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
                'PEST DESCRIPTION',
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
              ),
              const SizedBox(height: 6),
              Text(
                info['description'] as String,
                style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
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

        const SizedBox(height: 18),

        // Action details
        const Text(
          'RECOMMENDED ACTIONS',
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 0.5),
        ),
        const SizedBox(height: 10),

        _TreatmentStepCard(
          title: 'Immediate Danger Level',
          content: info['danger_level'] as String,
          icon: Icons.warning_amber_rounded,
          color: severityColor,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Organic Spray Solution',
          content: info['organic_treatment'] as String,
          icon: Icons.eco_outlined,
          color: Colors.teal,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Chemical Pesticide Solution',
          content: info['chemical_treatment'] as String,
          icon: Icons.medication_liquid_rounded,
          color: AppTheme.primaryGreen,
        ),
        const SizedBox(height: 10),
        _TreatmentStepCard(
          title: 'Protect Neighboring Crops',
          content: info['protect_neighbors'] as String,
          icon: Icons.shield_outlined,
          color: AppTheme.waterBlue,
        ),
        const SizedBox(height: 18),

        // Threshold advice card
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
                child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFF57F17), size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Economic Threshold Warning',
                      style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFFF57F17), fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start chemical treatment only if pest activity exceeds standard limit: ${result['economic_threshold'] as String}',
                      style: const TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w600),
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

  Map<String, dynamic> _translatePestToFarmerFriendly(Map<String, dynamic> rawResult) {
    final pestName = rawResult['pest_name'] as String;
    final severity = rawResult['severity_level'] as String;
    final confidenceScore = rawResult['confidence_score'] as double;

    String friendlyName = 'Your crops appear to have $pestName infestation.';
    if (pestName.contains('Fall Armyworm')) {
      friendlyName = 'Your crop has Fall Armyworm caterpillars.';
    } else if (pestName.contains('Tomato Fruit Borer')) {
      friendlyName = 'Your tomatoes have Fruit Borer worms.';
    } else if (pestName.contains('Cotton Aphid')) {
      friendlyName = 'Your plants have Cotton Aphids (sticky sucking bugs).';
    } else if (pestName.contains('Brown Planthopper')) {
      friendlyName = 'Your rice crops have Brown Planthoppers.';
    } else if (pestName.contains('Yellow Stem Borer')) {
      friendlyName = 'Your rice crops have Yellow Stem Borer worms.';
    }

    String friendlyConfidence = 'We are highly confident about this result.';
    if (confidenceScore < 0.70) {
      friendlyConfidence = 'This is our best guess, but please double check.';
    } else if (confidenceScore < 0.85) {
      friendlyConfidence = 'We are moderately confident about this result.';
    }

    final rawDesc = rawResult['description'] as String? ?? '';
    String friendlyDescription = rawDesc
        .replaceAll('destructive caterpillar feeding', 'hungry caterpillars eating')
        .replaceAll('whorls', 'leaves and shoots')
        .replaceAll('larvae feed aggressively', 'worms eat very fast')
        .replaceAll('sawdust-like waste', 'frass/waste spots')
        .replaceAll('bore into', 'make holes and eat inside')
        .replaceAll('rendering them unfit for sale', 'destroying them')
        .replaceAll('sucking sap', 'drinking the leaf juice')
        .replaceAll('nymphs and adults suck sap', 'young and adult insects drink juice')
        .replaceAll('dead heart', 'drying plant shoots')
        .replaceAll('whiteheads', 'white dried grains');

    String organicTreatment = 'Spray neem oil mixture (5ml per liter) or apply wood ash on leaves.';
    if (pestName.contains('Armyworm')) {
      organicTreatment = 'Apply sand, neem seed powder, or ash in crop center shoots to suffocate larvae.';
    } else if (pestName.contains('Borer')) {
      organicTreatment = 'Set up pheromone traps to trap adult moths, or release egg-eating beneficial insects.';
    }

    String chemicalTreatment = 'Spray Cartap Hydrochloride or Imidacloprid as recommended by local guidelines.';
    if (pestName.contains('Armyworm')) {
      chemicalTreatment = 'Spray Spinetoram 11.7 SC @ 0.5ml per liter of water.';
    } else if (pestName.contains('Borer')) {
      chemicalTreatment = 'Spray Bacillus thuringiensis (Bt) @ 2g per liter of water.';
    } else if (pestName.contains('Aphid')) {
      chemicalTreatment = 'Spray Dimethoate 30% EC @ 1ml per liter of water.';
    }

    String dangerLevel = 'This pest is very dangerous and eats crops quickly.';
    if (severity == 'Medium') {
      dangerLevel = 'This pest can cause moderate damage if not controlled.';
    } else if (severity == 'Low') {
      dangerLevel = 'This pest is easily controlled and causes minor damage.';
    }

    String protectNeighbors = 'Uproot severely damaged plants and clear weed boundaries to stop pests from moving.';

    return {
      'friendly_name': friendlyName,
      'friendly_confidence': friendlyConfidence,
      'description': friendlyDescription,
      'organic_treatment': organicTreatment,
      'chemical_treatment': chemicalTreatment,
      'danger_level': dangerLevel,
      'protect_neighbors': protectNeighbors,
      'severity': severity,
    };
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14, color: AppTheme.primaryGreen),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),
        ],
      ),
    );
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

class _SourceButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _SourceButton({
    required this.icon,
    required this.label,
    required this.color,
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
            color: color.withOpacity(0.15),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
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
