/// Domain entity representing a single phishing scan result.
/// This is pure Dart with no external dependencies.
class ScanEntity {
  final String id;
  final String userId;
  final String input;      // The URL or email/message text that was scanned
  final String type;       // 'url' or 'email'
  final int riskScore;     // 0–100
  final String result;     // JSON string with detailed breakdown
  final DateTime createdAt;

  const ScanEntity({
    required this.id,
    required this.userId,
    required this.input,
    required this.type,
    required this.riskScore,
    required this.result,
    required this.createdAt,
  });

  /// Convenience getter for parsed result details.
  bool get isSafe => riskScore < 30;
  bool get isSuspicious => riskScore >= 30 && riskScore < 60;
  bool get isDangerous => riskScore >= 60;

  /// Short preview of the input (for list display).
  String get inputPreview {
    if (input.length <= 50) return input;
    return '${input.substring(0, 47)}...';
  }
}
