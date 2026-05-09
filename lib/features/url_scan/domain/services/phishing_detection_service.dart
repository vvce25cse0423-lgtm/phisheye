import 'dart:math';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../history/domain/entities/scan_result_entity.dart';

/// Core phishing detection engine using heuristic rule-based analysis.
class PhishingDetectionService {
  PhishingDetectionService._();

  static ScanResultEntity analyzeUrl(String url) {
    final flags = <String>[];
    final safePoints = <String>[];
    int score = 0;
    final normalizedUrl = url.trim().toLowerCase();

    // 1. HTTPS check
    if (normalizedUrl.startsWith('https://')) {
      safePoints.add('Uses HTTPS secure connection');
    } else if (normalizedUrl.startsWith('http://')) {
      flags.add('Uses insecure HTTP (no encryption)');
      score += 15;
    } else {
      flags.add('Missing URL scheme (http/https)');
      score += 10;
    }

    // 2. URL length
    if (url.length > 100) {
      flags.add('Unusually long URL (${url.length} chars)');
      score += 15;
    } else if (url.length > 75) {
      flags.add('Long URL may be obfuscating the real domain');
      score += 8;
    } else {
      safePoints.add('URL length is normal');
    }

    // 3. Raw IP address
    final ipPattern = RegExp(r'\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b');
    if (ipPattern.hasMatch(normalizedUrl)) {
      flags.add('Uses raw IP address instead of a domain name');
      score += 25;
    }

    // 4. Suspicious TLD
    final hasSuspiciousTld =
        AppConstants.suspiciousTlds.any((tld) => normalizedUrl.contains(tld));
    if (hasSuspiciousTld) {
      final tld = AppConstants.suspiciousTlds
          .firstWhere((t) => normalizedUrl.contains(t));
      flags.add('Suspicious top-level domain detected: $tld');
      score += 20;
    }

    // 5. Trusted domain whitelist
    final isTrusted = AppConstants.trustedDomains
        .any((d) => _extractDomain(normalizedUrl) == d);
    if (isTrusted) {
      safePoints.add('Domain is on the trusted whitelist');
      score = max(0, score - 10);
    }

    // 6. Brand impersonation
    const brandKeywords = [
      'paypal', 'amazon', 'google', 'microsoft', 'apple',
      'facebook', 'instagram', 'netflix', 'bank', 'wellsfargo',
      'chase', 'citibank', 'hsbc',
    ];
    for (final brand in brandKeywords) {
      if (normalizedUrl.contains(brand) && !isTrusted) {
        flags.add('Contains brand name "$brand" – possible impersonation');
        score += 20;
        break;
      }
    }

    // 7. Suspicious keywords in path
    int keywordHits = 0;
    for (final kw in AppConstants.suspiciousUrlKeywords) {
      if (normalizedUrl.contains(kw)) keywordHits++;
    }
    if (keywordHits >= 3) {
      flags.add('Multiple suspicious keywords in URL ($keywordHits hits)');
      score += 20;
    } else if (keywordHits >= 1) {
      flags.add('Suspicious keyword(s) found in URL');
      score += 8;
    }

    // 8. Excessive subdomains
    final uri = Uri.tryParse(url);
    if (uri != null) {
      final hostParts = uri.host.split('.');
      if (hostParts.length > 4) {
        flags.add('Excessive subdomains (${hostParts.length - 2})');
        score += 15;
      } else {
        safePoints.add('Normal subdomain structure');
      }
    }

    // 9. Encoded chars / @ obfuscation
    final obfuscationPattern = RegExp(r'(%[0-9a-f]{2}|@)');
    if (obfuscationPattern.hasMatch(normalizedUrl)) {
      flags.add('URL contains encoded characters or "@" obfuscation');
      score += 15;
    }

    // 10. Hyphen abuse in domain
    if (uri != null) {
      final hyphenCount = uri.host.split('-').length - 1;
      if (hyphenCount >= 3) {
        flags.add('Domain has excessive hyphens ($hyphenCount)');
        score += 10;
      }
    }

    score = score.clamp(0, 100);
    if (safePoints.isEmpty) safePoints.add('No strong trust signals detected');

    return ScanResultEntity(
      riskScore: score,
      verdict: AppTheme.riskLabel(score),
      flags: flags,
      safePoints: safePoints,
      summary: _buildUrlSummary(score, flags.length),
    );
  }

  static ScanResultEntity analyzeEmail(String text) {
    final flags = <String>[];
    final safePoints = <String>[];
    int score = 0;
    final normalized = text.trim().toLowerCase();

    // 1. Urgency language
    const urgencyPhrases = [
      'urgent', 'immediately', 'act now', 'right away',
      'within 24 hours', 'asap', 'expire', 'expires today',
      'last chance', 'final notice',
    ];
    int urgencyCount = 0;
    for (final p in urgencyPhrases) {
      if (normalized.contains(p)) urgencyCount++;
    }
    if (urgencyCount >= 2) {
      flags.add('High urgency language detected ($urgencyCount indicators)');
      score += 25;
    } else if (urgencyCount == 1) {
      flags.add('Urgency language detected');
      score += 10;
    } else {
      safePoints.add('No urgency manipulation detected');
    }

    // 2. Known phishing phrases
    int phraseHits = 0;
    final matchedPhrases = <String>[];
    for (final phrase in AppConstants.suspiciousEmailPhrases) {
      if (normalized.contains(phrase)) {
        phraseHits++;
        matchedPhrases.add(phrase);
      }
    }
    if (phraseHits >= 3) {
      flags.add('Multiple phishing phrases: ${matchedPhrases.take(3).join(", ")}');
      score += 30;
    } else if (phraseHits > 0) {
      flags.add('Known phishing phrase(s): ${matchedPhrases.join(", ")}');
      score += 15;
    } else {
      safePoints.add('No known phishing phrases found');
    }

    // 3. URL count
    final urlPattern = RegExp(r'https?://\S+', caseSensitive: false);
    final urls = urlPattern.allMatches(text);
    if (urls.length > 3) {
      flags.add('Excessive links in message (${urls.length} URLs)');
      score += 15;
    } else if (urls.isNotEmpty) {
      safePoints.add('Contains ${urls.length} link(s)');
    }

    // 4. Sensitive info requests
    const personalInfoKeywords = [
      'social security', 'ssn', 'credit card', 'card number',
      'cvv', 'pin number', 'bank account', 'routing number',
      'passport', 'date of birth', 'mother maiden',
    ];
    for (final kw in personalInfoKeywords) {
      if (normalized.contains(kw)) {
        flags.add('Requests sensitive information: "$kw"');
        score += 20;
        break;
      }
    }

    // 5. Generic greeting
    const genericGreetings = [
      'dear customer', 'dear user', 'dear account holder',
      'dear member', 'valued customer',
    ];
    for (final greet in genericGreetings) {
      if (normalized.contains(greet)) {
        flags.add('Generic greeting – legitimate companies use your real name');
        score += 10;
        break;
      }
    }

    // 6. Threat language
    const threatPhrases = [
      'account will be closed', 'account suspended', 'account locked',
      'lose access', 'legal action', 'prosecuted',
    ];
    for (final phrase in threatPhrases) {
      if (normalized.contains(phrase)) {
        flags.add('Contains threatening language: "$phrase"');
        score += 20;
        break;
      }
    }

    // 7. Prize / reward lures
    const prizePhrases = [
      'you have won', 'free gift', 'claim your reward',
      'lottery', 'lucky winner',
    ];
    for (final phrase in prizePhrases) {
      if (normalized.contains(phrase)) {
        flags.add('Prize or reward lure detected');
        score += 20;
        break;
      }
    }

    // 8. Short message
    if (text.length < 20) {
      flags.add('Very short message – limited analysis possible');
      score += 5;
    } else {
      safePoints.add('Message length sufficient for analysis');
    }

    score = score.clamp(0, 100);
    if (safePoints.isEmpty) safePoints.add('No strong trust signals detected');

    return ScanResultEntity(
      riskScore: score,
      verdict: AppTheme.riskLabel(score),
      flags: flags,
      safePoints: safePoints,
      summary: _buildEmailSummary(score, flags.length),
    );
  }

  static String _extractDomain(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return '';
    final parts = uri.host.split('.');
    if (parts.length >= 2) {
      return '${parts[parts.length - 2]}.${parts[parts.length - 1]}';
    }
    return uri.host;
  }

  static String _buildUrlSummary(int score, int flagCount) {
    if (score < 30) return 'This URL appears safe. No significant phishing indicators detected.';
    if (score < 60) return 'This URL shows $flagCount suspicious indicator(s). Exercise caution.';
    return 'HIGH RISK: $flagCount phishing indicators found. Do not enter credentials on this site.';
  }

  static String _buildEmailSummary(int score, int flagCount) {
    if (score < 30) return 'This message appears legitimate. No significant phishing patterns found.';
    if (score < 60) return 'This message shows $flagCount suspicious pattern(s). Verify the sender.';
    return 'HIGH RISK: $flagCount phishing patterns found. Do not click links or share personal data.';
  }
}
