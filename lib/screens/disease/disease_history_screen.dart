import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/common_widgets.dart';

class DiseaseHistoryScreen extends ConsumerStatefulWidget {
  const DiseaseHistoryScreen({super.key});

  @override
  ConsumerState<DiseaseHistoryScreen> createState() =>
      _DiseaseHistoryScreenState();
}

class _DiseaseHistoryScreenState extends ConsumerState<DiseaseHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final userId = ref.watch(currentUserProvider)?.id ?? 'test-user-uuid-123';

    final predictionsAsync = ref.watch(diseasePredictionsProvider(userId));

    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Diagnosis History',
        showBack: true,
      ),
      body: predictionsAsync.when(
        data: (predictions) {
          if (predictions.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.biotech_rounded,
              title: 'No Diagnostics Done',
              subtitle:
                  'Use the AI Crop Diagnosis scanner to detect crop diseases and view report history here.',
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'AI Diagnoses Logged',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${predictions.length} Scans',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.darkGreen,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.history_edu_rounded,
                        size: 48,
                        color: AppTheme.primaryGreen,
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1),
                const SizedBox(height: 24),
                const SectionHeader(
                  title: 'Past Reports',
                ).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: predictions.length,
                  itemBuilder: (context, index) {
                    final prediction = predictions[index];

                    final confidence =
                        (prediction.confidenceScore * 100).round();

                    final severityColor = prediction.severity == 'Severe'
                        ? AppTheme.alertRed
                        : prediction.severity == 'Medium' ||
                                prediction.severity == 'Moderate'
                            ? AppTheme.warningOrange
                            : AppTheme.primaryGreen;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.grey.shade200,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.01),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        clipBehavior: Clip.antiAlias,
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          childrenPadding: EdgeInsets.zero,
                          shape: const Border(),
                          collapsedShape: const Border(),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: severityColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.coronavirus_rounded,
                              color: severityColor,
                              size: 20,
                            ),
                          ),
                          title: Text(
                            prediction.diseaseName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                          subtitle: Text(
                            'Crop: ${prediction.cropType} · '
                            '$confidence% Confidence',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          trailing: StatusBadge(
                            label: prediction.severity,
                            color: severityColor,
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Divider(),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Treatment Actions Taken / Recommended:',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 12,
                                      color: AppTheme.darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (prediction.treatmentSuggestions.isEmpty)
                                    const Text(
                                      'No treatment suggestions available.',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    )
                                  else
                                    ...prediction.treatmentSuggestions.map(
                                      (suggestion) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              margin: const EdgeInsets.only(
                                                top: 5,
                                              ),
                                              width: 5,
                                              height: 5,
                                              decoration: const BoxDecoration(
                                                color: AppTheme.primaryGreen,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                suggestion,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  height: 1.4,
                                                ),
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
                        ),
                      ),
                    );
                  },
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => EmptyStateWidget(
          icon: Icons.error_outline_rounded,
          title: 'Failed to load',
          subtitle: error.toString(),
        ),
      ),
    );
  }
}
