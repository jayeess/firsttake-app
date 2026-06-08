import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme/app_colors.dart';
import '../../utils/validators/email_validator.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/custom_text_field.dart';
import '../../widgets/common/custom_button.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await ref
          .read(authNotifierProvider.notifier)
          .sendPasswordReset(_emailController.text.trim());

      if (!mounted) return;
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showError(_parseError(e));
    }
  }

  String _parseError(Object error) {
    final msg = error.toString();
    if (msg.contains('user-not-found')) {
      return 'No account found with this email address.';
    } else if (msg.contains('invalid-email')) {
      return 'The email address is not valid.';
    } else if (msg.contains('too-many-requests')) {
      return 'Too many attempts. Please try again later.';
    } else if (msg.contains('network-request-failed')) {
      return 'Network error. Please check your connection.';
    }
    return 'Failed to send reset email. Please try again.';
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: _emailSent ? _buildSuccessView() : _buildFormView(),
          ),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_ios_new, size: 20),
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Icon
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primaryLight.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.lock_reset_outlined,
              size: 36,
              color: AppColors.primary,
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 24),

          // Title
          Text(
            'Forgot Password?',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 12),

          // Subtitle
          Text(
            'Enter the email address associated with your account and '
            "we'll send you a link to reset your password.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
          const SizedBox(height: 32),

          // Email field
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email address',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: EmailValidator.validate,
            onFieldSubmitted: (_) => _handleSendReset(),
          ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
          const SizedBox(height: 28),

          // Send button
          CustomButton(
            label: 'Send Reset Link',
            onPressed: _isLoading ? null : _handleSendReset,
            isLoading: _isLoading,
          ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // Back to login
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Remember your password? ',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              GestureDetector(
                onTap: () => context.pop(),
                child: const Text(
                  'Login',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.successLight,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.mark_email_read_outlined,
            size: 44,
            color: AppColors.success,
          ),
        ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
        const SizedBox(height: 28),

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
        const SizedBox(height: 12),

        // Message
        Text(
          'We have sent a password reset link to\n'
          '${_emailController.text.trim()}',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
        const SizedBox(height: 12),
        Text(
          'Please check your inbox and follow the instructions '
          'to reset your password.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.textHint,
                height: 1.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 400.ms),
        const SizedBox(height: 36),

        // Back to login button
        CustomButton(
          label: 'Back to Login',
          onPressed: () => context.go('/login'),
        ).animate().fadeIn(delay: 500.ms, duration: 400.ms),
        const SizedBox(height: 16),

        // Resend link
        CustomButton(
          label: 'Resend Link',
          variant: ButtonVariant.outline,
          onPressed: () {
            setState(() => _emailSent = false);
          },
        ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
      ],
    );
  }
}
