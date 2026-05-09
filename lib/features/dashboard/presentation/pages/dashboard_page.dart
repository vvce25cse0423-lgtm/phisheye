import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../history/domain/entities/scan_entity.dart';
import '../../../history/presentation/providers/history_provider.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(historyProvider.notifier).loadScans());
  }

  @override
  Widget build(BuildContext context) {
    final historyState = ref.watch(historyProvider);
    final stats = ref.watch(scanStatsProvider);
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const PhishEyeLogo(size: 32),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: AppTheme.textMuted, size: 20),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.accentCyan,
        backgroundColor: AppTheme.bgCard,
        onRefresh: () => ref.read(historyProvider.notifier).loadScans(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Greeting ──────────────────────────────────────
              _buildGreeting(context, authState.user?.email),
              const SizedBox(height: 24),

              // ─── Stats Row ─────────────────────────────────────
              _buildStatsRow(context, stats),
              const SizedBox(height: 24),

              // ─── Quick Actions ─────────────────────────────────
              const SectionHeader(
                  title: 'Quick Scan', subtitle: 'Choose scan type'),
              const SizedBox(height: 14),
              _buildQuickActions(context),
              const SizedBox(height: 24),

              // ─── Pie Chart ─────────────────────────────────────
              if (stats['total']! > 0) ...[
                const SectionHeader(
                    title: 'Threat Distribution',
                    subtitle: 'Risk breakdown of your scans'),
                const SizedBox(height: 14),
                _buildPieChart(context, stats),
                const SizedBox(height: 24),
              ],

              // ─── Recent Scans ──────────────────────────────────
              SectionHeader(
                title: 'Recent Scans',
                trailing: TextButton(
                  onPressed: () => context.go(AppRoutes.history),
                  child: const Text(
                    'VIEW ALL',
                    style: TextStyle(
                      fontFamily: 'SpaceMono',
                      fontSize: 10,
                      color: AppTheme.accentCyan,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _buildRecentScans(context, historyState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreeting(BuildContext context, String? email) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good Morning'
        : hour < 17
            ? 'Good Afternoon'
            : 'Good Evening';
    final name = email?.split('@').first.toUpperCase() ?? 'ANALYST';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$greeting,',
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppTheme.textSecondary),
        ),
        Text(
          name,
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: AppTheme.accentCyan,
                letterSpacing: 2,
              ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }

  Widget _buildStatsRow(BuildContext context, Map<String, int> stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'TOTAL',
            value: '${stats['total']}',
            icon: Icons.bar_chart,
            color: AppTheme.accentCyan,
            delay: 0,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'SAFE',
            value: '${stats['safe']}',
            icon: Icons.check_circle_outline,
            color: AppTheme.accentGreen,
            delay: 80,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
            label: 'DANGER',
            value: '${stats['dangerous']}',
            icon: Icons.dangerous_outlined,
            color: AppTheme.accentRed,
            delay: 160,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.link,
            label: 'SCAN URL',
            subtitle: 'Analyze suspicious links',
            color: AppTheme.accentCyan,
            onTap: () => context.go(AppRoutes.urlScan),
          ).animate(delay: 100.ms).fadeIn().slideX(begin: -0.1),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionCard(
            icon: Icons.email_outlined,
            label: 'SCAN EMAIL',
            subtitle: 'Check messages for phishing',
            color: AppTheme.accentPurple,
            onTap: () => context.go(AppRoutes.emailScan),
          ).animate(delay: 180.ms).fadeIn().slideX(begin: 0.1),
        ),
      ],
    );
  }

  Widget _buildPieChart(BuildContext context, Map<String, int> stats) {
    final total = stats['total']!;
    if (total == 0) return const SizedBox.shrink();

    final safe = stats['safe']!;
    final suspicious = stats['suspicious']!;
    final dangerous = stats['dangerous']!;

    return CyberCard(
      child: Row(
        children: [
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 30,
                sections: [
                  if (safe > 0)
                    PieChartSectionData(
                      value: safe.toDouble(),
                      color: AppTheme.accentGreen,
                      radius: 40,
                      title: '',
                    ),
                  if (suspicious > 0)
                    PieChartSectionData(
                      value: suspicious.toDouble(),
                      color: AppTheme.accentAmber,
                      radius: 40,
                      title: '',
                    ),
                  if (dangerous > 0)
                    PieChartSectionData(
                      value: dangerous.toDouble(),
                      color: AppTheme.accentRed,
                      radius: 40,
                      title: '',
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _LegendItem(
                    color: AppTheme.accentGreen,
                    label: 'Safe',
                    count: safe,
                    total: total),
                const SizedBox(height: 10),
                _LegendItem(
                    color: AppTheme.accentAmber,
                    label: 'Suspicious',
                    count: suspicious,
                    total: total),
                const SizedBox(height: 10),
                _LegendItem(
                    color: AppTheme.accentRed,
                    label: 'Danger',
                    count: dangerous,
                    total: total),
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().scale(begin: const Offset(0.95, 0.95));
  }

  Widget _buildRecentScans(BuildContext context, HistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
            strokeWidth: 2,
          ),
        ),
      );
    }

    if (state.scans.isEmpty) {
      return CyberCard(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Icon(Icons.radar, color: AppTheme.textMuted, size: 40),
                const SizedBox(height: 12),
                Text(
                  'No scans yet',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppTheme.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  'Start by scanning a URL or email above',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final recent = state.scans.take(5).toList();
    return Column(
      children: recent.asMap().entries.map((entry) {
        final scan = entry.value;
        return _RecentScanTile(scan: scan, index: entry.key);
      }).toList(),
    );
  }
}

// ─── Sub-widgets ──────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int delay;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.delay,
  });

  @override
  Widget build(BuildContext context) {
    return CyberCard(
      borderColor: color.withOpacity(0.25),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppTheme.textMuted),
          ),
        ],
      ),
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.2);
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'SpaceMono',
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;

  const _LegendItem({
    required this.color,
    required this.label,
    required this.count,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final pct = total > 0 ? (count / total * 100).toStringAsFixed(0) : '0';
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppTheme.textPrimary),
          ),
        ),
        Text(
          '$count ($pct%)',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 10,
            color: color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _RecentScanTile extends StatelessWidget {
  final ScanEntity scan;
  final int index;

  const _RecentScanTile({required this.scan, required this.index});

  @override
  Widget build(BuildContext context) {
    final riskColor = AppTheme.riskColor(scan.riskScore);
    final dateStr = DateFormat('MMM dd · HH:mm').format(scan.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: CyberCard(
        borderColor: riskColor.withOpacity(0.15),
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor.withOpacity(0.08),
                border: Border.all(color: riskColor, width: 1),
              ),
              child: Center(
                child: Text(
                  '${scan.riskScore}',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.inputPreview,
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      ScanTypeBadge(type: scan.type),
                      const SizedBox(width: 6),
                      Text(
                        dateStr,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            RiskBadge(score: scan.riskScore),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: 100 + index * 60))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.05);
  }
}
