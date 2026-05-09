import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/scan_model.dart';

/// Remote data source for scan operations using Supabase.
class ScanRemoteDataSource {
  final SupabaseClient _client;

  ScanRemoteDataSource(this._client);

  /// Insert a new scan record. Returns the created scan.
  Future<ScanModel> saveScan({
    required String input,
    required String type,
    required int riskScore,
    required String resultJson,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = await _client
        .from(AppConstants.scansTable)
        .insert({
          'user_id': userId,
          'input': input,
          'type': type,
          'risk_score': riskScore,
          'result': resultJson,
        })
        .select()
        .single();

    return ScanModel.fromJson(data);
  }

  /// Fetch all scans for the current user, ordered by newest first.
  Future<List<ScanModel>> getUserScans() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('User not authenticated');

    final data = await _client
        .from(AppConstants.scansTable)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => ScanModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Delete a scan by ID (RLS ensures only owner can delete).
  Future<void> deleteScan(String scanId) async {
    await _client
        .from(AppConstants.scansTable)
        .delete()
        .eq('id', scanId);
  }
}
