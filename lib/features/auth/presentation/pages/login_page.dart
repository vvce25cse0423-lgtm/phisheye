import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();

    await ref.read(authProvider.notifier).signIn(
          email: _emailCtrl.text.trim(),
          password: _passCtrl.text,
        );

    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // ─── Logo ───────────────────────────────────────
                const PhishEyeLogo(size: 44)
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .slideY(begin: -0.2),

                const SizedBox(height: 40),

                // ─── Title ──────────────────────────────────────
                Text(
                  'WELCOME BACK',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.2),

                const SizedBox(height: 6),

                Text(
                  'Sign in to access your threat dashboard',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 150.ms).fadeIn(),

                const SizedBox(height: 40),

                // ─── Error Banner ────────────────────────────────
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                            color: AppTheme.accentRed.withOpacity(0.4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppTheme.accentRed, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              state.error!,
                              style: const TextStyle(
                                color: AppTheme.accentRed,
                                fontFamily: 'Rajdhani',
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().shake().fadeIn(),

                // ─── Email Field ─────────────────────────────────
                Text(
                  'EMAIL ADDRESS',
                  style: Theme.of(context).textTheme.labelLarge,
                ).animate(delay: 200.ms).fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'analyst@company.com',
                    prefixIcon: Icon(Icons.email_outlined,
                        color: AppTheme.textMuted, size: 18),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ).animate(delay: 220.ms).fadeIn(),

                const SizedBox(height: 20),

                // ─── Password Field ──────────────────────────────
                Text(
                  'PASSWORD',
                  style: Theme.of(context).textTheme.labelLarge,
                ).animate(delay: 260.ms).fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _signIn(),
                  style: const TextStyle(
                    fontFamily: 'Rajdhani',
                    fontSize: 15,
                    color: AppTheme.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textMuted,
                        size: 18,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Password must be at least 6 characters';
                    return null;
                  },
                ).animate(delay: 280.ms).fadeIn(),

                const SizedBox(height: 32),

                // ─── Sign In Button ──────────────────────────────
                state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentCyan),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _signIn,
                        icon: const Icon(Icons.login, size: 18),
                        label: const Text('SIGN IN'),
                      ).animate(delay: 320.ms).fadeIn(),

                const SizedBox(height: 16),

                // ─── Register Link ───────────────────────────────
                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.register),
                  child: const Text('CREATE ACCOUNT'),
                ).animate(delay: 360.ms).fadeIn(),

                const SizedBox(height: 40),

                // ─── Security note ───────────────────────────────
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.shield_outlined,
                          color: AppTheme.textMuted, size: 12),
                      const SizedBox(width: 6),
                      Text(
                        'Secured by Supabase Auth',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ).animate(delay: 400.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
