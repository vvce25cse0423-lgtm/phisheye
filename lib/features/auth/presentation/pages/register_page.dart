import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/auth_provider.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(authProvider.notifier).signUp(
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 16),
          onPressed: () => context.go(AppRoutes.login),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PhishEyeLogo(size: 40)
                    .animate()
                    .fadeIn(duration: 400.ms),
                const SizedBox(height: 28),
                Text(
                  'CREATE ACCOUNT',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.2),
                const SizedBox(height: 4),
                Text(
                  'Join PhishEye to protect yourself from phishing attacks',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate(delay: 120.ms).fadeIn(),
                const SizedBox(height: 32),

                // Error
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
                            child: Text(state.error!,
                                style: const TextStyle(
                                    color: AppTheme.accentRed,
                                    fontFamily: 'Rajdhani',
                                    fontSize: 13)),
                          ),
                        ],
                      ),
                    ),
                  ).animate().shake(),

                // Email
                Text('EMAIL ADDRESS',
                        style: Theme.of(context).textTheme.labelLarge)
                    .animate(delay: 160.ms)
                    .fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      color: AppTheme.textPrimary),
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
                ).animate(delay: 180.ms).fadeIn(),

                const SizedBox(height: 20),

                // Password
                Text('PASSWORD',
                        style: Theme.of(context).textTheme.labelLarge)
                    .animate(delay: 220.ms)
                    .fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Min. 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscurePass
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Password is required';
                    if (v.length < 6) return 'Minimum 6 characters';
                    return null;
                  },
                ).animate(delay: 240.ms).fadeIn(),

                const SizedBox(height: 20),

                // Confirm password
                Text('CONFIRM PASSWORD',
                        style: Theme.of(context).textTheme.labelLarge)
                    .animate(delay: 260.ms)
                    .fadeIn(),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  style: const TextStyle(
                      fontFamily: 'Rajdhani',
                      fontSize: 15,
                      color: AppTheme.textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Repeat password',
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textMuted, size: 18),
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: AppTheme.textMuted,
                          size: 18),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Please confirm password';
                    if (v != _passCtrl.text) return 'Passwords do not match';
                    return null;
                  },
                ).animate(delay: 280.ms).fadeIn(),

                const SizedBox(height: 32),

                state.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.accentCyan),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _register,
                        icon: const Icon(Icons.person_add_outlined, size: 18),
                        label: const Text('CREATE ACCOUNT'),
                      ).animate(delay: 320.ms).fadeIn(),

                const SizedBox(height: 16),

                OutlinedButton(
                  onPressed: () => context.go(AppRoutes.login),
                  child: const Text('ALREADY HAVE AN ACCOUNT? SIGN IN'),
                ).animate(delay: 360.ms).fadeIn(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
