/// Represents a phishing analysis result before persisting to database.
class ScanResultEntity {
  final int riskScore;           // 0–100
  final String verdict;          // 'SAFE' | 'SUSPICIOUS' | 'DANGER'
  final List<String> flags;      // List of detected issues
  final List<String> safePoints; // List of positive indicators
  final String summary;          // Human-readable explanation

  const ScanResultEntity({
    required this.riskScore,
    required this.verdict,
    required this.flags,
    required this.safePoints,
    required this.summary,
  });

  /// Serialize to JSON string for database storage.
  String toJsonString() {
    final flagsStr = flags.map((f) => '"$f"').join(',');
    final safeStr = safePoints.map((s) => '"$s"').join(',');
    return '{"verdict":"$verdict","flags":[$flagsStr],"safePoints":[$safeStr],"summary":"${summary.replaceAll('"', '\\"')}"}';
  }
}
