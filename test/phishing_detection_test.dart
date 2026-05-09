import 'package:flutter_test/flutter_test.dart';
import 'package:phisheye/features/url_scan/domain/services/phishing_detection_service.dart';

void main() {
  group('PhishingDetectionService - URL Analysis', () {
    test('safe HTTPS URL scores low', () {
      final result = PhishingDetectionService.analyzeUrl('https://google.com');
      expect(result.riskScore, lessThan(30));
      expect(result.verdict, equals('SAFE'));
    });

    test('HTTP URL gets penalty', () {
      final result = PhishingDetectionService.analyzeUrl('http://example.com');
      expect(result.riskScore, greaterThan(0));
    });

    test('raw IP address scores high', () {
      final result = PhishingDetectionService.analyzeUrl('http://192.168.1.1/login');
      expect(result.riskScore, greaterThanOrEqualTo(30));
    });

    test('suspicious TLD increases score', () {
      final result = PhishingDetectionService.analyzeUrl('https://legit-bank.xyz/verify');
      expect(result.riskScore, greaterThan(10));
    });

    test('brand impersonation scores high', () {
      final result = PhishingDetectionService.analyzeUrl(
          'http://paypal-secure-login.com/verify/account');
      expect(result.riskScore, greaterThanOrEqualTo(60));
    });

    test('flags list is not empty for suspicious URLs', () {
      final result = PhishingDetectionService.analyzeUrl(
          'http://paypal-login.xyz/secure/verify/account/confirm');
      expect(result.flags, isNotEmpty);
    });
  });

  group('PhishingDetectionService - Email Analysis', () {
    test('normal email scores low', () {
      final result = PhishingDetectionService.analyzeEmail(
          'Hi John, your order has been shipped. Thank you for shopping with us.');
      expect(result.riskScore, lessThan(30));
    });

    test('urgent phishing email scores high', () {
      final result = PhishingDetectionService.analyzeEmail(
          'URGENT: Your account has been suspended. Verify your account immediately '
          'by clicking the link. Dear customer, act now or lose access.');
      expect(result.riskScore, greaterThanOrEqualTo(60));
    });

    test('prize lure scores high', () {
      final result = PhishingDetectionService.analyzeEmail(
          'Congratulations! You have won a free gift. Claim your reward now!');
      expect(result.riskScore, greaterThan(20));
    });

    test('generic greeting adds to score', () {
      final safe = PhishingDetectionService.analyzeEmail('Hi John, thanks for contacting us.');
      final phish = PhishingDetectionService.analyzeEmail('Dear customer, please verify.');
      expect(phish.riskScore, greaterThan(safe.riskScore));
    });
  });
}
