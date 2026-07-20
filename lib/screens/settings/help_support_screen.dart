import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _msgCtrl = TextEditingController();
  bool _isSubmitting = false;

  final List<Map<String, String>> _faqs = [
    {
      'q': 'How does the AI disease detection work?',
      'a': 'You take or upload a photo of your infected crop leaf. Our artificial intelligence models scan the lesions, compare them with thousands of indexed disease datasets, and return the most probable disease along with organic and chemical treatment instructions.',
    },
    {
      'q': 'Are the market crop prices updated in real-time?',
      'a': 'Yes, crop prices are fetched directly from central and state government APMC database feeds every morning to give you the most accurate regional selling prices.',
    },
    {
      'q': 'How can I schedule a consult with a live agronomist?',
      'a': 'Navigate to the "Expert Helpline" page from the bottom bar, select "Diseases" or "Soil Queries", type your question, and one of our online partner agronomists will initiate a chat or call with you.',
    },
  ];

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _submitTicket() async {
    if (_msgCtrl.text.isEmpty) return;
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isSubmitting = false);
      _msgCtrl.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Support ticket created! We will contact you soon.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Help & Support',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // FAQs
            const SectionHeader(title: 'Frequently Asked Questions').animate().fadeIn(),
            const SizedBox(height: 12),

            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _faqs.length,
                  itemBuilder: (context, idx) {
                    final faq = _faqs[idx];
                    return ExpansionTile(
                      title: Text(
                        faq['q']!,
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.darkGreen),
                      ),
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                          child: Text(
                            faq['a']!,
                            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.grey[700]),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 24),

            // Help Contact Cards
            const SectionHeader(title: 'Direct Support Channel').animate().fadeIn(delay: 200.ms),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _ContactCard(
                    icon: Icons.phone_in_talk_rounded,
                    title: 'Toll-Free Call',
                    subtitle: '1800-420-6900',
                    onTap: () {},
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ContactCard(
                    icon: Icons.mail_outline_rounded,
                    title: 'Email Us',
                    subtitle: 'support@farmai.org',
                    onTap: () {},
                    color: AppTheme.skyBlue,
                  ),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 24),

            // Submit Ticket Form
            const SectionHeader(title: 'Submit Support Ticket').animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 12),

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
                  const Text(
                    'Describe your technical or app issue below:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _msgCtrl,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      hintText: 'Enter details of the issue here...',
                      filled: true,
                      fillColor: AppTheme.surfaceLight,
                    ),
                  ),
                  const SizedBox(height: 16),
                  LoadingButton(
                    isLoading: _isSubmitting,
                    onPressed: _submitTicket,
                    label: 'Submit Ticket',
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  const _ContactCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}
