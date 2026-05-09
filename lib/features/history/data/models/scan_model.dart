import '../../domain/entities/scan_entity.dart';

/// Data model for Supabase scans table.
/// Handles JSON serialization/deserialization.
class ScanModel extends ScanEntity {
  const ScanModel({
    required super.id,
    required super.userId,
    required super.input,
    required super.type,
    required super.riskScore,
    required super.result,
    required super.createdAt,
  });

  /// Create from Supabase row map.
  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      input: json['input'] as String,
      type: json['type'] as String,
      riskScore: json['risk_score'] as int,
      result: json['result'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to Supabase insert map.
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'input': input,
      'type': type,
      'risk_score': riskScore,
      'result': result,
    };
  }

  /// Convert domain entity to model.
  factory ScanModel.fromEntity(ScanEntity entity) {
    return ScanModel(
      id: entity.id,
      userId: entity.userId,
      input: entity.input,
      type: entity.type,
      riskScore: entity.riskScore,
      result: entity.result,
      createdAt: entity.createdAt,
    );
  }
}
