/// Application-wide constants for PhishEye.
class AppConstants {
  AppConstants._();

  // ─── Supabase table names ──────────────────────────────────────
  static const String scansTable = 'scans';

  // ─── Scan types ────────────────────────────────────────────────
  static const String scanTypeUrl = 'url';
  static const String scanTypeEmail = 'email';

  // ─── Risk score thresholds ─────────────────────────────────────
  static const int riskSafe = 30;
  static const int riskSuspicious = 60;
  static const int riskDanger = 100;

  // ─── Animation durations ───────────────────────────────────────
  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow = Duration(milliseconds: 600);

  // ─── Phishing detection heuristics ────────────────────────────
  // Suspicious TLDs commonly used in phishing
  static const List<String> suspiciousTlds = [
    '.xyz', '.top', '.club', '.click', '.loan', '.work',
    '.party', '.stream', '.download', '.win', '.gq', '.ml',
    '.cf', '.ga', '.tk',
  ];

  // Suspicious keywords in URLs
  static const List<String> suspiciousUrlKeywords = [
    'login', 'signin', 'account', 'verify', 'update', 'secure',
    'banking', 'paypal', 'amazon', 'microsoft', 'apple', 'google',
    'confirm', 'password', 'credential', 'suspended', 'unlock',
    'wallet', 'crypto', 'free', 'prize', 'winner', 'claim',
  ];

  // Suspicious phrases in emails/messages
  static const List<String> suspiciousEmailPhrases = [
    'urgent action required', 'verify your account', 'click here immediately',
    'your account has been suspended', 'confirm your identity',
    'you have won', 'congratulations', 'claim your prize',
    'limited time offer', 'act now', 'update your information',
    'unusual activity', 'security alert', 'password expired',
    'your account will be closed', 'verify immediately',
    'send money', 'wire transfer', 'gift card', 'itunes card',
    'nigerian prince', 'inheritance', 'million dollars',
    'dear customer', 'dear user', 'dear account holder',
  ];

  // Known legitimate domains (whitelist sample)
  static const List<String> trustedDomains = [
    'google.com', 'youtube.com', 'facebook.com', 'twitter.com',
    'instagram.com', 'linkedin.com', 'microsoft.com', 'apple.com',
    'amazon.com', 'github.com', 'stackoverflow.com', 'reddit.com',
    'wikipedia.org', 'netflix.com', 'spotify.com',
  ];
}
