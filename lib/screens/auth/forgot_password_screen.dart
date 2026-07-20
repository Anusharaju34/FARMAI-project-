import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/common/farm_text_field.dart';
import '../../widgets/common/loading_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  Future<void> _send() async {
    if (_emailCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final success = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_emailCtrl.text.trim());
    setState(() {
      _loading = false;
      _sent = success;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => context.pop(),
        ),
        title: const Text('Forgot Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? _SuccessView()
            : _FormView(
                emailCtrl: _emailCtrl,
                loading: _loading,
                onSend: _send,
              ),
      ),
    );
  }
}

class _FormView extends StatelessWidget {
  final TextEditingController emailCtrl;
  final bool loading;
  final VoidCallback onSend;

  const _FormView({
    required this.emailCtrl,
    required this.loading,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.lock_reset_rounded,
            size: 48,
            color: AppTheme.primaryGreen,
          ),
        ).animate().scale().fadeIn(),
        const SizedBox(height: 24),
        Text(
          'Reset Password',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ).animate(delay: 200.ms).fadeIn(),
        const SizedBox(height: 8),
        Text(
          'Enter your registered email address and we\'ll send you a reset link.',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ).animate(delay: 300.ms).fadeIn(),
        const SizedBox(height: 32),
        FarmTextField(
          controller: emailCtrl,
          label: 'Email Address',
          hint: 'farmer@example.com',
          keyboardType: TextInputType.emailAddress,
          prefixIcon: Icons.email_outlined,
        ).animate(delay: 400.ms).fadeIn().slideY(begin: 0.2),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: LoadingButton(
            isLoading: loading,
            onPressed: onSend,
            label: 'Send Reset Link',
          ),
        ).animate(delay: 500.ms).fadeIn(),
      ],
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppTheme.primaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
          ).animate().scale(curve: Curves.elasticOut),
          const SizedBox(height: 24),
          Text(
            'Email Sent!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ).animate(delay: 300.ms).fadeIn(),
          const SizedBox(height: 8),
          Text(
            'Check your inbox and follow the link to reset your password.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ).animate(delay: 400.ms).fadeIn(),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Back to Login'),
          ).animate(delay: 500.ms).fadeIn(),
        ],
      ),
    );
  }
}
