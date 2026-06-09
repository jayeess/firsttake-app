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
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.error_outline, color: Colors.white,
                  size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        duration: const Duration(seconds: 4),
        elevation: 6,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // Gradient header
          _buildHeader()
              .animate()
              .fadeIn(duration: 600.ms)
              .slideY(begin: -0.15, end: 0, duration: 600.ms),

          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: _emailSent ? _buildSuccessView() : _buildFormView(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 24,
        left: 8,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryDark,
            AppColors.primary,
            AppColors.primaryLight,
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(36),
          bottomRight: Radius.circular(36),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(Icons.arrow_back_ios_new,
                size: 20, color: Colors.white),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Reset Password',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
            ),
          ),
        ],
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
          // Icon
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.primary.withValues(alpha: 0.14),
                    AppColors.primaryLight.withValues(alpha: 0.08),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.lock_reset_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 28),

          // Subtitle
          Text(
            'Enter the email address associated with your account and '
            "we'll send you a link to reset your password.",
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                  height: 1.6,
                ),
            textAlign: TextAlign.center,
          ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
          const SizedBox(height: 36),

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
          ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
          const SizedBox(height: 28),

          // Send button
          CustomButton(
            label: 'Send Reset Link',
            onPressed: _isLoading ? null : _handleSendReset,
            isLoading: _isLoading,
          ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
          const SizedBox(height: 28),

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
          ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        ],
      ),
    );
  }

  Widget _buildSuccessView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Success icon with animated ring and glow
        Center(
          child: Container(
            width: 110,
            height: 110,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.success.withValues(alpha: 0.15),
                  AppColors.success.withValues(alpha: 0.03),
                ],
              ),
            ),
            child: Center(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success.withValues(alpha: 0.18),
                      AppColors.success.withValues(alpha: 0.06),
                    ],
                  ),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.35),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  size: 42,
                  color: AppColors.success,
                ),
              ),
            ),
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOutBack)
            .then()
            .shimmer(delay: 200.ms, duration: 800.ms),
        const SizedBox(height: 32),

        // Title
        Text(
          'Check Your Email',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                letterSpacing: -0.5,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
        const SizedBox(height: 16),

        // Email highlight card
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.email_outlined,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.7)),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  _emailController.text.trim(),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
        const SizedBox(height: 16),

        // Message
        Text(
          'Please check your inbox and follow the instructions '
          'to reset your password.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                height: 1.6,
              ),
          textAlign: TextAlign.center,
        ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
        const SizedBox(height: 40),

        // Back to login button
        CustomButton(
          label: 'Back to Login',
          onPressed: () => context.go('/login'),
        ).animate().fadeIn(delay: 500.ms, duration: 500.ms),
        const SizedBox(height: 14),

        // Resend link
        CustomButton(
          label: 'Resend Link',
          variant: ButtonVariant.outline,
          onPressed: () {
            setState(() => _emailSent = false);
          },
        ).animate().fadeIn(delay: 600.ms, duration: 500.ms),
      ],
    );
  }
}
