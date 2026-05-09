import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../providers/url_scan_provider.dart';

class UrlScanPage extends ConsumerStatefulWidget {
  const UrlScanPage({super.key});

  @override
  ConsumerState<UrlScanPage> createState() => _UrlScanPageState();
}

class _UrlScanPageState extends ConsumerState<UrlScanPage> {
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
    await ref.read(urlScanProvider.notifier).analyzeUrl(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(urlScanProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('URL SCANNER'),
        actions: [
          if (state.result != null)
            IconButton(
              icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
              onPressed: () {
                _controller.clear();
                ref.read(urlScanProvider.notifier).clearResult();
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

                // ─── Input Field ─────────────────────────────────
                _buildInputSection(context, state),
                const SizedBox(height: 16),

                // ─── Scan Button ─────────────────────────────────
                if (!state.isScanning)
                  ElevatedButton.icon(
                    onPressed: _scan,
                    icon: const Icon(Icons.search, size: 18),
                    label: const Text('ANALYZE URL'),
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
          'PHISHING URL DETECTOR',
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppTheme.accentCyan,
              ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
        const SizedBox(height: 4),
        Text(
          'Paste a suspicious URL to analyze it for phishing indicators',
          style: Theme.of(context).textTheme.bodyMedium,
        ).animate().fadeIn(delay: 100.ms),
      ],
    );
  }

  Widget _buildInputSection(BuildContext context, UrlScanState state) {
    return CyberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.link, color: AppTheme.accentCyan, size: 16),
              const SizedBox(width: 8),
              Text(
                'TARGET URL',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            style: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'https://example.com/page',
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste, color: AppTheme.textMuted, size: 18),
                onPressed: () async {
                  final data = await Clipboard.getData(Clipboard.kTextPlain);
                  if (data?.text != null) {
                    _controller.text = data!.text!;
                  }
                },
              ),
            ),
            validator: (v) {
              if (v == null || v.trim().isEmpty) return 'URL is required';
              if (!v.contains('.')) return 'Enter a valid URL';
              return null;
            },
          ),
          const SizedBox(height: 8),
          // Quick paste examples
          Text(
            'EXAMPLES:',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            children: [
              _ExampleChip(
                label: 'http://paypa1.com',
                onTap: () => _controller.text = 'http://paypa1.com/login',
              ),
              _ExampleChip(
                label: 'https://google.com',
                onTap: () => _controller.text = 'https://google.com',
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms);
  }

  Widget _buildScanning(BuildContext context) {
    return CyberCard(
      borderColor: AppTheme.accentCyan.withOpacity(0.3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
              strokeWidth: 2,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            'SCANNING URL...',
            style: Theme.of(context).textTheme.labelLarge,
          )
              .animate(onPlay: (c) => c.repeat())
              .shimmer(duration: 1200.ms, color: AppTheme.accentCyan),
        ],
      ),
    ).animate().fadeIn();
  }

  Widget _buildResults(BuildContext context, UrlScanState state) {
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

        // Summary
        CyberCard(
          borderColor: riskColor.withOpacity(0.3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    result.riskScore < 30
                        ? Icons.check_circle_outline
                        : result.riskScore < 60
                            ? Icons.warning_amber_outlined
                            : Icons.dangerous_outlined,
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

        // Danger flags
        if (result.flags.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildFlagList(context, result.flags),
        ],

        // Safe points
        if (result.safePoints.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildSafeList(context, result.safePoints),
        ],

        // Warning note
        if (result.riskScore >= 60) ...[
          const SizedBox(height: 16),
          _buildWarningBanner(context),
        ],
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
              const Icon(Icons.flag, color: AppTheme.accentRed, size: 16),
              const SizedBox(width: 8),
              Text(
                'THREATS DETECTED (${flags.length})',
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
                      const Icon(
                        Icons.chevron_right,
                        color: AppTheme.accentRed,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
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
                  const Icon(Icons.check,
                      color: AppTheme.accentGreen, size: 14),
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

  Widget _buildWarningBanner(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.accentRed.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.accentRed.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: AppTheme.accentRed, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'DO NOT enter passwords, payment info, or personal data on this URL.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.accentRed,
                  ),
            ),
          ),
        ],
      ),
    ).animate().shake(duration: 600.ms);
  }
}

class _ExampleChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _ExampleChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppTheme.borderSubtle),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 10,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
