import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/scan_repository_impl.dart';
import '../../domain/entities/scan_entity.dart';

/// State class for scan history list.
class HistoryState {
  final List<ScanEntity> scans;
  final bool isLoading;
  final String? error;

  const HistoryState({
    this.scans = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<ScanEntity>? scans,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      scans: scans ?? this.scans,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier managing scan history state and database operations.
class HistoryNotifier extends StateNotifier<HistoryState> {
  final Ref _ref;

  HistoryNotifier(this._ref) : super(const HistoryState());

  /// Load all scans for current user from Supabase.
  Future<void> loadScans() async {
    state = state.copyWith(isLoading: true, error: null);

    final repo = _ref.read(scanRepositoryProvider);
    final result = await repo.getUserScans();

    if (result.failure != null) {
      state = state.copyWith(
        isLoading: false,
        error: result.failure!.message,
      );
    } else {
      state = state.copyWith(
        isLoading: false,
        scans: result.scans ?? [],
      );
    }
  }

  /// Delete a scan and refresh list.
  Future<void> deleteScan(String scanId) async {
    final repo = _ref.read(scanRepositoryProvider);
    final result = await repo.deleteScan(scanId);

    if (result.failure != null) {
      state = state.copyWith(error: result.failure!.message);
    } else {
      // Optimistically remove from list
      state = state.copyWith(
        scans: state.scans.where((s) => s.id != scanId).toList(),
      );
    }
  }

  /// Add a newly completed scan to the top of the list.
  void addScan(ScanEntity scan) {
    state = state.copyWith(scans: [scan, ...state.scans]);
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref);
});

/// Quick stats derived from scan history.
final scanStatsProvider = Provider<Map<String, int>>((ref) {
  final scans = ref.watch(historyProvider).scans;
  final safe = scans.where((s) => s.riskScore < 30).length;
  final suspicious = scans.where((s) => s.riskScore >= 30 && s.riskScore < 60).length;
  final dangerous = scans.where((s) => s.riskScore >= 60).length;
  return {
    'total': scans.length,
    'safe': safe,
    'suspicious': suspicious,
    'dangerous': dangerous,
  };
});
