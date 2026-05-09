import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/utils/failures.dart';
import '../../../../core/utils/supabase_provider.dart';
import '../../domain/entities/scan_entity.dart';
import '../../domain/repositories/scan_repository.dart';
import '../datasources/scan_remote_datasource.dart';

/// Concrete implementation of ScanRepository using Supabase.
class ScanRepositoryImpl implements ScanRepository {
  final ScanRemoteDataSource _dataSource;

  ScanRepositoryImpl(this._dataSource);

  @override
  Future<({ScanEntity? scan, Failure? failure})> saveScan({
    required String input,
    required String type,
    required int riskScore,
    required String resultJson,
  }) async {
    try {
      final model = await _dataSource.saveScan(
        input: input,
        type: type,
        riskScore: riskScore,
        resultJson: resultJson,
      );
      return (scan: model as ScanEntity, failure: null);
    } on PostgrestException catch (e) {
      return (scan: null, failure: DatabaseFailure(e.message));
    } catch (e) {
      return (scan: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<({List<ScanEntity>? scans, Failure? failure})> getUserScans() async {
    try {
      final models = await _dataSource.getUserScans();
      return (scans: models.cast<ScanEntity>(), failure: null);
    } on PostgrestException catch (e) {
      return (scans: null, failure: DatabaseFailure(e.message));
    } catch (e) {
      return (scans: null, failure: UnknownFailure(e.toString()));
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteScan(String scanId) async {
    try {
      await _dataSource.deleteScan(scanId);
      return (success: true, failure: null);
    } on PostgrestException catch (e) {
      return (success: false, failure: DatabaseFailure(e.message));
    } catch (e) {
      return (success: false, failure: UnknownFailure(e.toString()));
    }
  }
}

// ─── Riverpod Providers ───────────────────────────────────────────────────────

final scanRemoteDataSourceProvider = Provider<ScanRemoteDataSource>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ScanRemoteDataSource(client);
});

final scanRepositoryProvider = Provider<ScanRepository>((ref) {
  final dataSource = ref.watch(scanRemoteDataSourceProvider);
  return ScanRepositoryImpl(dataSource);
});
