import '../entities/scan_entity.dart';
import '../../../../core/utils/failures.dart';

/// Abstract repository interface for scan data operations.
/// The domain layer depends only on this interface, not on Supabase directly.
abstract class ScanRepository {
  /// Saves a completed scan result to the database.
  Future<({ScanEntity? scan, Failure? failure})> saveScan({
    required String input,
    required String type,
    required int riskScore,
    required String resultJson,
  });

  /// Fetches all scans for the currently authenticated user.
  Future<({List<ScanEntity>? scans, Failure? failure})> getUserScans();

  /// Deletes a specific scan by ID.
  Future<({bool success, Failure? failure})> deleteScan(String scanId);
}
