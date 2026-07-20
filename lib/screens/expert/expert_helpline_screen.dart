import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/supabase_service.dart';
import '../../widgets/common/common_widgets.dart';
import '../../routes/app_router.dart';

class ExpertHelplineScreen extends ConsumerStatefulWidget {
  const ExpertHelplineScreen({super.key});

  @override
  ConsumerState<ExpertHelplineScreen> createState() =>
      _ExpertHelplineScreenState();
}

class _ExpertHelplineScreenState extends ConsumerState<ExpertHelplineScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _myQueries = [
    {
      'id': 'q1',
      'subject': 'Yellowing leaves in Wheat crop',
      'question':
          'My wheat leaves are turning yellow from the bottom. Applied urea last week. Is this nitrogen deficiency or disease?',
      'status': 'answered',
      'category': 'Crop Disease',
      'expert_reply':
          'Based on your description, this appears to be nitrogen deficiency (chlorosis). The upward progression from lower leaves is a classic sign. Recommendation: Apply split dose of urea (20 kg/acre) immediately. Ensure proper irrigation after application. If yellowing continues after 7 days, consider micronutrient foliar spray (ZnSO4 @ 0.5%).',
      'created_at':
          DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      'replied_at':
          DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
    },
    {
      'id': 'q2',
      'subject': 'Best time to apply Potash for Cotton',
      'question':
          'When should I apply potash (MOP) for Cotton? My crop is at 45 days stage. What quantity is recommended?',
      'status': 'pending',
      'category': 'Crop Nutrition',
      'expert_reply': null,
      'created_at':
          DateTime.now().subtract(const Duration(hours: 6)).toIso8601String(),
      'replied_at': null,
    },
  ];

  final List<Map<String, dynamic>> _experts = [
    {
      'name': 'Dr. A. Krishnaswamy',
      'specialty': 'Crop Pathologist',
      'experience': '22 years',
      'rating': 4.9,
      'totalAnswered': 1240,
      'available': true,
    },
    {
      'name': 'Dr. R. Menon',
      'specialty': 'Soil Scientist',
      'experience': '18 years',
      'rating': 4.8,
      'totalAnswered': 980,
      'available': true,
    },
    {
      'name': 'Ms. S. Gupta',
      'specialty': 'Agronomy Specialist',
      'experience': '14 years',
      'rating': 4.7,
      'totalAnswered': 756,
      'available': false,
    },
    {
      'name': 'Dr. P. Nair',
      'specialty': 'Pest Management',
      'experience': '20 years',
      'rating': 4.9,
      'totalAnswered': 1120,
      'available': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expert Helpline'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_comment_rounded),
            onPressed: () => _showAskExpert(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppTheme.primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppTheme.primaryGreen,
          tabs: const [
            Tab(text: 'My Queries'),
            Tab(text: 'Our Experts'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QueriesTab(queries: _myQueries),
          _ExpertsTab(experts: _experts),
        ],
      ),
    );
  }

  void _showAskExpert(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final questionCtrl = TextEditingController();
    String selectedCategory = 'General';
    bool posting = false;

    final categories = [
      'General',
      'Crop Disease',
      'Pest Control',
      'Crop Nutrition',
      'Irrigation',
      'Seeds & Varieties',
      'Government Schemes',
      'Market',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx2, setModal) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx2).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ask an Expert',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(ctx2),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setModal(() => selectedCategory = v!),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectCtrl,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  hintText: 'Short description of your issue',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: questionCtrl,
                maxLines: 5,
                decoration: const InputDecoration(
                  labelText: 'Your Question',
                  hintText:
                      'Describe the issue in detail – crop type, stage, symptoms, what you have tried...',
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: LoadingButton(
                  isLoading: posting,
                  onPressed: () async {
                    if (subjectCtrl.text.isEmpty || questionCtrl.text.isEmpty)
                      return;
                    setModal(() => posting = true);
                    final userId =
                        Supabase.instance.client.auth.currentUser?.id;
                    await SupabaseService.submitExpertQuery({
                      'user_id': userId,
                      'subject': subjectCtrl.text,
                      'question': questionCtrl.text,
                      'category': selectedCategory,
                      'status': 'pending',
                      'created_at': DateTime.now().toIso8601String(),
                    });
                    setModal(() => posting = false);
                    Navigator.pop(ctx2);
                    setState(() {
                      _myQueries.insert(0, {
                        'id': DateTime.now().millisecondsSinceEpoch.toString(),
                        'subject': subjectCtrl.text,
                        'question': questionCtrl.text,
                        'status': 'pending',
                        'category': selectedCategory,
                        'expert_reply': null,
                        'created_at': DateTime.now().toIso8601String(),
                        'replied_at': null,
                      });
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Question submitted! Expert will reply within 24 hours.'),
                        backgroundColor: AppTheme.primaryGreen,
                      ),
                    );
                  },
                  label: 'Submit Question',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QueriesTab extends StatelessWidget {
  final List<Map<String, dynamic>> queries;
  const _QueriesTab({required this.queries});

  @override
  Widget build(BuildContext context) {
    if (queries.isEmpty) {
      return const EmptyStateWidget(
        icon: Icons.help_outline_rounded,
        title: 'No Questions Yet',
        subtitle: 'Ask our agricultural experts any farming question',
        buttonLabel: 'Ask Expert',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: queries.length,
      itemBuilder: (_, i) => _QueryCard(query: queries[i])
          .animate(delay: Duration(milliseconds: 80 * i))
          .fadeIn()
          .slideY(begin: 0.1),
    );
  }
}

class _QueryCard extends StatelessWidget {
  final Map<String, dynamic> query;
  const _QueryCard({required this.query});

  @override
  Widget build(BuildContext context) {
    final status = query['status'] as String;
    final isAnswered = status == 'answered';
    final statusColor =
        isAnswered ? AppTheme.primaryGreen : AppTheme.warningOrange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.06),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isAnswered
                        ? Icons.mark_chat_read_rounded
                        : Icons.hourglass_empty_rounded,
                    color: statusColor,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        query['subject'] as String,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14),
                      ),
                      Row(
                        children: [
                          StatusBadge(
                              label: query['category'] as String,
                              color: AppTheme.primaryGreen),
                          const SizedBox(width: 6),
                          StatusBadge(
                            label: isAnswered ? 'Answered' : 'Pending',
                            color: statusColor,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Question
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  query['question'] as String,
                  style: const TextStyle(fontSize: 13, height: 1.5),
                ),
                if (isAnswered && query['expert_reply'] != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppTheme.primaryGreen.withOpacity(0.2)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.support_agent_rounded,
                                color: AppTheme.primaryGreen, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Expert Reply',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primaryGreen,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          query['expert_reply'] as String,
                          style: const TextStyle(fontSize: 13, height: 1.5),
                        ),
                      ],
                    ),
                  ),
                ],
                if (!isAnswered) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.warningOrange.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.access_time_rounded,
                            color: AppTheme.warningOrange, size: 14),
                        SizedBox(width: 6),
                        Text(
                          'Expert will respond within 24 hours',
                          style: TextStyle(
                            color: AppTheme.warningOrange,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpertsTab extends StatelessWidget {
  final List<Map<String, dynamic>> experts;
  const _ExpertsTab({required this.experts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: experts.length,
      itemBuilder: (_, i) => _ExpertCard(expert: experts[i])
          .animate(delay: Duration(milliseconds: 80 * i))
          .fadeIn(),
    );
  }
}

class _ExpertCard extends StatelessWidget {
  final Map<String, dynamic> expert;
  const _ExpertCard({required this.expert});

  @override
  Widget build(BuildContext context) {
    final available = expert['available'] as bool;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.expertChat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
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
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: AppTheme.primaryGreen.withOpacity(0.12),
                  child: Text(
                    (expert['name'] as String).split(' ').last[0],
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 20,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                if (available)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGreen,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    expert['name'] as String,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  Text(
                    expert['specialty'] as String,
                    style: const TextStyle(
                      color: AppTheme.primaryGreen,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: AppTheme.sunYellow, size: 14),
                      Text(
                        ' ${expert['rating']} · ',
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                      Text(
                        '${expert['totalAnswered']} answers · ${expert['experience']}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            StatusBadge(
              label: available ? 'Online' : 'Away',
              color: available ? AppTheme.primaryGreen : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
