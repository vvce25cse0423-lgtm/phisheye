import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/shared_widgets.dart';
import '../../domain/entities/scan_entity.dart';
import '../providers/history_provider.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  @override
  void initState() {
    super.initState();
    // Load scans when page opens
    Future.microtask(() => ref.read(historyProvider.notifier).loadScans());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDeep,
      appBar: AppBar(
        title: const Text('SCAN HISTORY'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppTheme.accentCyan),
            onPressed: () => ref.read(historyProvider.notifier).loadScans(),
          ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(HistoryState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCyan),
        ),
      );
    }

    if (state.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ErrorMessage(
            message: state.error!,
            onRetry: () => ref.read(historyProvider.notifier).loadScans(),
          ),
        ),
      );
    }

    if (state.scans.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: state.scans.length,
      itemBuilder: (context, index) {
        return _ScanHistoryItem(
          scan: state.scans[index],
          index: index,
          onDelete: () => _confirmDelete(state.scans[index].id),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_outlined,
            size: 64,
            color: AppTheme.textMuted,
          ),
          const SizedBox(height: 16),
          Text(
            'NO SCANS YET',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppTheme.textMuted,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start scanning URLs or emails\nto see your history here.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(String scanId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppTheme.borderSubtle),
        ),
        title: const Text(
          'DELETE SCAN',
          style: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Remove this scan from history?',
          style: TextStyle(
            fontFamily: 'Rajdhani',
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'CANCEL',
              style: TextStyle(color: AppTheme.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'DELETE',
              style: TextStyle(color: AppTheme.accentRed),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(historyProvider.notifier).deleteScan(scanId);
    }
  }
}

class _ScanHistoryItem extends StatelessWidget {
  final ScanEntity scan;
  final int index;
  final VoidCallback onDelete;

  const _ScanHistoryItem({
    required this.scan,
    required this.index,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final riskColor = AppTheme.riskColor(scan.riskScore);
    final dateStr = DateFormat('MMM dd, yyyy · HH:mm').format(scan.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CyberCard(
        borderColor: riskColor.withOpacity(0.2),
        child: Row(
          children: [
            // Risk score circle
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor.withOpacity(0.1),
                border: Border.all(color: riskColor, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '${scan.riskScore}',
                  style: TextStyle(
                    fontFamily: 'SpaceMono',
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: riskColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ScanTypeBadge(type: scan.type),
                      const SizedBox(width: 6),
                      RiskBadge(score: scan.riskScore),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    scan.inputPreview,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontSize: 13,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dateStr,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            // Delete button
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: AppTheme.textMuted,
                size: 18,
              ),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    )
        .animate(delay: Duration(milliseconds: index * 50))
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.1, end: 0);
  }
}
