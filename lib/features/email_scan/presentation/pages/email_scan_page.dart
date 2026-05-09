import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/email_scan_provider.dart';

class EmailScanPage extends ConsumerStatefulWidget {
  const EmailScanPage({super.key});

  @override
  ConsumerState<EmailScanPage> createState() => _EmailScanPageState();
}

class _EmailScanPageState extends ConsumerState<EmailScanPage> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    await ref.read(emailScanProvider.notifier).analyzeEmail(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(emailScanProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('EMAIL SCANNER'),
        actions: [
          if (state.result != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
              onPressed: () {
                _controller.clear();
                ref.read(emailScanProvider.notifier).clearResult();
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Header ─────────────────────────────────────
                _buildHeader(context),
                const SizedBox(height: 24),

                // ─── Input ───────────────────────────────────────
                _buildInputSection(context, state),
                const SizedBox(height: 16),

                // ─── Button ──────────────────────────────────────
                if (!state.isScanning)
                  ElevatedButton.icon(
                    onPressed: _scan,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('ANALYZE MESSAGE'),
                  ).animate().fadeIn(),

                // ─── Loading ─────────────────────────────────────
                if (state.isScanning) _buildScanning(context),

                // ─── Error ───────────────────────────────────────
                if (state.error != null && state.result == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: ErrorMessage(message: state.error!),
                  ),

                // ─── Results ─────────────────────────────────────
                if (state.result != null) ...[
                  const SizedBox(height: 24),
                  _buildResults(context, state),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'EMAIL / TEXT DETECTOR',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.accentPurple,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
        const SizedBox(height: 4),
        Text(
          'Paste an email or SMS to check for phishing patterns',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context, EmailScanState state) {
    return CyberCard(
      borderColor: AppTheme.accentPurple.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.email_outlined, color: AppTheme.accentPurple, size: 16),
              const SizedBox(width: 8),
              Text(
                'MESSAGE CONTENT',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppTheme.accentPurple),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            maxLines: 8,
            style: const TextStyle(
              fontFamily: 'Rajdhani',
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: const InputDecoration(
              hintText:
                  'Paste email or message content here...\n\nExample:\n"URGENT: Your account has been suspended. Click here immediately to verify your identity."',
              alignLabelWithHint: true,
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter a message to scan';
              }
              if (v.trim().length < 5) return 'Message is too short to analyze';
              return null;
            },
          ),
          const SizedBox(height: 10),
          // Sample templates
          Text(
            'LOAD SAMPLE:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _SampleChip(
                label: 'Phishing Sample',
                onTap: () => _controller.text =
                    'URGENT: Your PayPal account has been suspended due to unusual activity. '
                    'Please verify your account immediately by clicking the link below or your account will be permanently closed. '
                    'Click here: http://paypa1-secure.xyz/verify?user=confirm',
              ),
              _SampleChip(
                label: 'Legitimate Sample',
                onTap: () => _controller.text =
                    'Hi John, thank you for your recent purchase. '
                    'Your order #12345 has been shipped and will arrive in 3-5 business days. '
                    'You can track your package at fedex.com. Contact support@company.com if you have questions.',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildScanning(BuildContext context) {
    return CyberCard(
      borderColor: AppTheme.accentPurple.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor:
                  AlwaysStoppedAnimation<Color>(AppTheme.accentPurple),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'ANALYZING MESSAGE...',
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: AppTheme.accentPurple),
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: AppTheme.accentPurple),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResults(BuildContext context, EmailScanState state) {
    final result = state.result!;
    final riskColor = AppTheme.riskColor(result.riskScore);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Analysis Results'),
        const SizedBox(height: 16),

        // Risk score gauge
        Center(child: RiskGauge(score: result.riskScore)),
        const SizedBox(height: 20),

        // Summary card
        CyberCard(
          borderColor: riskColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.riskScore < 30
                        ? Icons.mark_email_read_outlined
                        : result.riskScore < 60
                            ? Icons.mark_email_unread_outlined
                            : Icons.report_gmailerrorred_outlined,
                    color: riskColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'VERDICT: ${result.verdict}',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: riskColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                result.summary,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
        ).animate().fadeIn(delay: 100.ms),

        // Threat flags
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFlagList(context, result.flags),
        ],

        // Safe signals
        if (result.safePoints.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSafeList(context, result.safePoints),
        ],

        // Guidance box
        const SizedBox(height: 16),
        _buildGuidance(context, result.riskScore),
      ],
    );
  }

  Widget _buildFlagList(BuildContext context, List<String> flags) {
    return CyberCard(
      borderColor: AppTheme.accentRed.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: AppTheme.accentRed, size: 16),
              const SizedBox(width: 8),
              Text(
                'PHISHING INDICATORS (${flags.length})',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppTheme.accentRed),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...flags.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppTheme.accentRed,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textPrimary),
                        ),
                      ),
                    ],
                  ),
                )
                    .animate(delay: Duration(milliseconds: entry.key * 80))
                    .fadeIn()
                    .slideX(begin: -0.1),
              ),
        ],
      ),
    );
  }

  Widget _buildSafeList(BuildContext context, List<String> safePoints) {
    return CyberCard(
      borderColor: AppTheme.accentGreen.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified_outlined,
                  color: AppTheme.accentGreen, size: 16),
              const SizedBox(width: 8),
              Text(
                'SAFE SIGNALS',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppTheme.accentGreen),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...safePoints.map(
            (point) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check, color: AppTheme.accentGreen, size: 14),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      point,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textPrimary),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuidance(BuildContext context, int score) {
    if (score < 30) {
      return CyberCard(
        borderColor: AppTheme.accentGreen.withOpacity(0.2),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates_outlined,
                color: AppTheme.accentGreen, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'This message appears legitimate. Still be cautious when clicking any links.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppTheme.accentGreen),
              ),
            ),
          ],
        ),
      );
    }

    final tips = score >= 60
        ? [
            'Do not click any links in this message',
            'Do not reply with personal information',
            'Report this as phishing to your email provider',
            'Block the sender immediately',
          ]
        : [
            'Verify the sender through official channels',
            'Do not provide personal or financial details',
            'Check the sender\'s email address carefully',
          ];

    return CyberCard(
      borderColor: AppTheme.accentAmber.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: AppTheme.accentAmber, size: 16),
              const SizedBox(width: 8),
              Text(
                'RECOMMENDED ACTIONS',
                style: Theme.of(context)
                    .textTheme
                    .labelLarge
                    ?.copyWith(color: AppTheme.accentAmber),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...tips.map(
            (tip) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.arrow_right,
                      color: AppTheme.accentAmber, size: 16),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      tip,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SampleChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 10,
            color: AppTheme.accentPurple,
          ),
        ),
      ),
    );
  }
}
