import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/email_scan/presentation/pages/email_scan_page.dart';
import '../../features/history/presentation/pages/history_page.dart';
import '../../features/url_scan/presentation/pages/url_scan_page.dart';
import '../widgets/main_shell.dart';

/// Route name constants to avoid magic strings.
class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/dashboard';
  static const urlScan = '/url-scan';
  static const emailScan = '/email-scan';
  static const history = '/history';
}

/// Riverpod provider for GoRouter instance.
final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    redirect: (context, state) {
      final session = Supabase.instance.client.auth.currentSession;
      final isLoggedIn = session != null;
      final isSplash = state.matchedLocation == AppRoutes.splash;
      final isAuth = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.register;

      // If on splash, let it handle redirect itself
      if (isSplash) return null;

      // If not logged in and trying to access protected routes
      if (!isLoggedIn && !isAuth) return AppRoutes.login;

      // If logged in and on auth pages, go to dashboard
      if (isLoggedIn && isAuth) return AppRoutes.dashboard;

      return null;
    },
    routes: [
      // Splash / Loading route
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterPage(),
      ),

      // Main app shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => const DashboardPage(),
          ),
          GoRoute(
            path: AppRoutes.urlScan,
            builder: (context, state) => const UrlScanPage(),
          ),
          GoRoute(
            path: AppRoutes.emailScan,
            builder: (context, state) => const EmailScanPage(),
          ),
          GoRoute(
            path: AppRoutes.history,
            builder: (context, state) => const HistoryPage(),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Route not found: ${state.error}'),
      ),
    ),
  );
});
