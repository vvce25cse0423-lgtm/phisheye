import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/data/repositories/scan_repository_impl.dart';
import '../../../history/domain/entities/scan_result_entity.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../services/phishing_detection_service.dart';

/// State for URL scan feature.
class UrlScanState {
  final bool isScanning;
  final ScanResultEntity? result;
  final String? scannedUrl;
  final String? error;

  const UrlScanState({
    this.isScanning = false,
    this.result,
    this.scannedUrl,
    this.error,
  });

  UrlScanState copyWith({
    bool? isScanning,
    ScanResultEntity? result,
    String? scannedUrl,
    String? error,
  }) {
    return UrlScanState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      scannedUrl: scannedUrl ?? this.scannedUrl,
      error: error,
    );
  }

  UrlScanState reset() => const UrlScanState();
}

/// Notifier for URL scan operations.
class UrlScanNotifier extends StateNotifier<UrlScanState> {
  final Ref _ref;

  UrlScanNotifier(this._ref) : super(const UrlScanState());

  /// Analyze a URL, save result to Supabase, update history.
  Future<void> analyzeUrl(String url) async {
    if (url.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a URL to scan');
      return;
    }

    state = state.copyWith(isScanning: true, error: null);

    // Simulate slight processing delay for UX
    await Future.delayed(const Duration(milliseconds: 800));

    // Run heuristic analysis
    final result = PhishingDetectionService.analyzeUrl(url);

    // Persist to Supabase
    final repo = _ref.read(scanRepositoryProvider);
    final saveResult = await repo.saveScan(
      input: url,
      type: AppConstants.scanTypeUrl,
      riskScore: result.riskScore,
      resultJson: result.toJsonString(),
    );

    if (saveResult.failure != null) {
      state = state.copyWith(
        isScanning: false,
        result: result,
        scannedUrl: url,
        error: 'Scan complete but failed to save: ${saveResult.failure!.message}',
      );
    } else {
      // Add to history
      if (saveResult.scan != null) {
        _ref.read(historyProvider.notifier).addScan(saveResult.scan!);
      }

      state = state.copyWith(
        isScanning: false,
        result: result,
        scannedUrl: url,
      );
    }
  }

  void clearResult() => state = state.reset();
}

final urlScanProvider =
    StateNotifierProvider<UrlScanNotifier, UrlScanState>((ref) {
  return UrlScanNotifier(ref);
});
