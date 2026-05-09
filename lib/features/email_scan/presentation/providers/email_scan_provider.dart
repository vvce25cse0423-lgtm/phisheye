import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../history/data/repositories/scan_repository_impl.dart';
import '../../../history/domain/entities/scan_result_entity.dart';
import '../../../history/presentation/providers/history_provider.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../url_scan/domain/services/phishing_detection_service.dart';

/// State for email/message scan feature.
class EmailScanState {
  final bool isScanning;
  final ScanResultEntity? result;
  final String? scannedText;
  final String? error;

  const EmailScanState({
    this.isScanning = false,
    this.result,
    this.scannedText,
    this.error,
  });

  EmailScanState copyWith({
    bool? isScanning,
    ScanResultEntity? result,
    String? scannedText,
    String? error,
  }) {
    return EmailScanState(
      isScanning: isScanning ?? this.isScanning,
      result: result ?? this.result,
      scannedText: scannedText ?? this.scannedText,
      error: error,
    );
  }

  EmailScanState reset() => const EmailScanState();
}

/// Notifier for email/message scan operations.
class EmailScanNotifier extends StateNotifier<EmailScanState> {
  final Ref _ref;

  EmailScanNotifier(this._ref) : super(const EmailScanState());

  /// Analyze email/message text, persist result to Supabase.
  Future<void> analyzeEmail(String text) async {
    if (text.trim().isEmpty) {
      state = state.copyWith(error: 'Please enter a message or email to scan');
      return;
    }

    state = state.copyWith(isScanning: true, error: null);

    // Slight delay for UX
    await Future.delayed(const Duration(milliseconds: 600));

    // Run heuristic analysis
    final result = PhishingDetectionService.analyzeEmail(text);

    // Persist to Supabase
    final repo = _ref.read(scanRepositoryProvider);
    final saveResult = await repo.saveScan(
      input: text,
      type: AppConstants.scanTypeEmail,
      riskScore: result.riskScore,
      resultJson: result.toJsonString(),
    );

    if (saveResult.failure != null) {
      state = state.copyWith(
        isScanning: false,
        result: result,
        scannedText: text,
        error: 'Scan complete but failed to save: ${saveResult.failure!.message}',
      );
    } else {
      if (saveResult.scan != null) {
        _ref.read(historyProvider.notifier).addScan(saveResult.scan!);
      }
      state = state.copyWith(
        isScanning: false,
        result: result,
        scannedText: text,
      );
    }
  }

  void clearResult() => state = state.reset();
}

final emailScanProvider =
    StateNotifierProvider<EmailScanNotifier, EmailScanState>((ref) {
  return EmailScanNotifier(ref);
});
