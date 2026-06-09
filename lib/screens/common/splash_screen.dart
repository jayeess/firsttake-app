import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../utils/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _navigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    final authState = ref.read(authStateProvider);
    authState.when(
      data: (user) {
        if (user != null) {
          // Check user type and navigate accordingly
          ref.read(currentUserDataProvider.future).then((userData) {
            if (!mounted) return;
            if (userData == null) {
              context.go('/login');
            } else if (userData.userType.name == 'TALENT') {
              context.go('/talent');
            } else if (userData.userType.name == 'RECRUITER') {
              context.go('/recruiter');
            } else {
              context.go('/admin');
            }
          }).catchError((_) {
            if (mounted) context.go('/login');
          });
        } else {
          context.go('/login');
        }
      },
      loading: () => context.go('/login'),
      error: (_, __) => context.go('/login'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryDark,
              AppColors.primary,
              AppColors.primaryLight,
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Subtle decorative circles
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),
            Positioned(
              bottom: -80,
              left: -40,
              child: Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
              ),
            ),
            // Main content
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo with outer glow ring
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) {
                      final pulseValue =
                          0.06 + (_pulseController.value * 0.06);
                      return Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color:
                                Colors.white.withValues(alpha: pulseValue),
                            width: 2.5,
                          ),
                        ),
                        child: child,
                      );
                    },
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(26),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.primaryDark,
                              AppColors.primary,
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'FT',
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.6, 0.6),
                        end: const Offset(1.0, 1.0),
                        duration: 700.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 500.ms),
                  const SizedBox(height: 28),
                  const Text(
                    'FirstTake',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 350.ms, duration: 600.ms)
                      .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 350.ms,
                          duration: 600.ms),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Where Talent Meets Opportunity',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white.withValues(alpha: 0.9),
                        letterSpacing: 0.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 600.ms, duration: 600.ms)
                      .slideY(
                          begin: 0.15,
                          end: 0,
                          delay: 600.ms,
                          duration: 600.ms),
                  const SizedBox(height: 48),
                  // Loading dots
                  SizedBox(
                    width: 48,
                    height: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: EdgeInsets.only(
                              right: index < 2 ? 8 : 0),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.6),
                            shape: BoxShape.circle,
                          ),
                        )
                            .animate(
                              onPlay: (controller) =>
                                  controller.repeat(),
                            )
                            .scaleXY(
                              begin: 0.6,
                              end: 1.0,
                              delay: Duration(milliseconds: index * 200),
                              duration: 600.ms,
                              curve: Curves.easeInOut,
                            )
                            .then()
                            .scaleXY(
                              begin: 1.0,
                              end: 0.6,
                              duration: 600.ms,
                              curve: Curves.easeInOut,
                            );
                      }),
                    ),
                  )
                      .animate()
                      .fadeIn(delay: 900.ms, duration: 400.ms),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
