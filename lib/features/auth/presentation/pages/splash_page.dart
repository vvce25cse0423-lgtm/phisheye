import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

/// Splash screen shown on app launch.
/// Determines whether to navigate to login or dashboard.
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    // Wait for animations then route
    Future.delayed(const Duration(milliseconds: 2200), _navigate);
  }

  void _navigate() {
    if (!mounted) return;
    final isAuth = ref.read(authProvider).isAuthenticated;
    context.go(isAuth ? AppRoutes.dashboard : AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with pulse animation
            const PhishEyeLogo(size: 72)
                .animate()
                .scale(
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                )
                .fadeIn(duration: 500.ms),

            const SizedBox(height: 32),

            // Tagline
            Text(
              'AI-BASED PHISHING DETECTION',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                    letterSpacing: 2,
                  ),
            )
                .animate(delay: 600.ms)
                .fadeIn(duration: 500.ms)
                .slideY(begin: 0.3),

            const SizedBox(height: 60),

            // Loading indicator
            SizedBox(
              width: 120,
              child: LinearProgressIndicator(
                backgroundColor: AppTheme.bgElevated,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.accentCyan,
                ),
              ),
            )
                .animate(delay: 900.ms)
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 12),

            Text(
              'INITIALIZING THREAT ENGINE...',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 9,
                    color: AppTheme.textMuted,
                    letterSpacing: 1.5,
                  ),
            )
                .animate(delay: 1000.ms)
                .fadeIn(),
          ],
        ),
      ),
    );
  }
}
