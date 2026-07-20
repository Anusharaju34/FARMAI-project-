import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_theme.dart';
import '../../widgets/common/common_widgets.dart';

class CreateForumPostScreen extends StatefulWidget {
  const CreateForumPostScreen({super.key});

  @override
  State<CreateForumPostScreen> createState() => _CreateForumPostScreenState();
}

class _CreateForumPostScreenState extends State<CreateForumPostScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  void _submitPost() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    await Future.delayed(const Duration(milliseconds: 1500));

    if (mounted) {
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Forum post published successfully!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const FarmAIAppBar(
        title: 'Ask Question',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Post to Community Forum',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.darkGreen,
                ),
              ).animate().fadeIn(),
              const SizedBox(height: 16),

              // Title input
              FarmTextField(
                controller: _titleCtrl,
                label: 'Question Title',
                hint: 'Be specific, e.g. White powder on grape leaves?',
                prefixIcon: Icons.help_outline_rounded,
                validator: (val) => val == null || val.isEmpty ? 'Please enter a title' : null,
              ).animate().fadeIn(delay: 100.ms),

              const SizedBox(height: 16),

              // Description input
              FarmTextField(
                controller: _contentCtrl,
                label: 'Describe your query',
                hint: 'Describe your crop symptoms, recent weather changes, soil type, and anything else that helps other farmers and experts diagnose the issue.',
                maxLines: 6,
                prefixIcon: Icons.description_outlined,
                validator: (val) => val == null || val.isEmpty ? 'Please describe your query' : null,
              ).animate().fadeIn(delay: 200.ms),

              const SizedBox(height: 16),

              // Tags input
              FarmTextField(
                controller: _tagsCtrl,
                label: 'Tags (comma separated)',
                hint: 'e.g. Grapes, Pest, Fungus',
                prefixIcon: Icons.label_outline_rounded,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 24),

              // Image attachment box
              GestureDetector(
                onTap: () {},
                child: Container(
                  height: 120,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen.withOpacity(0.3)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.add_photo_alternate_rounded, color: AppTheme.primaryGreen, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        'Attach Plant Photo (Optional)',
                        style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.w600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 32),

              // Submit Button
              LoadingButton(
                isLoading: _isSubmitting,
                onPressed: _submitPost,
                label: 'Post to Forum',
              ).animate().fadeIn(delay: 400.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
