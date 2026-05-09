import 'package:flutter/material.dart';

/// PhishEye dark cybersecurity theme.
/// Color palette: Deep navy background, electric cyan accent, warning amber.
class AppTheme {
  AppTheme._();

  // ─── Palette ───────────────────────────────────────────────────
  static const Color bgDeep = Color(0xFF070B14);
  static const Color bgCard = Color(0xFF0D1224);
  static const Color bgSurface = Color(0xFF111829);
  static const Color bgElevated = Color(0xFF1A2235);

  static const Color accentCyan = Color(0xFF00E5FF);
  static const Color accentCyanDim = Color(0xFF0097A7);
  static const Color accentGreen = Color(0xFF00FF88);
  static const Color accentAmber = Color(0xFFFFB300);
  static const Color accentRed = Color(0xFFFF3D71);
  static const Color accentPurple = Color(0xFF9C27B0);

  static const Color textPrimary = Color(0xFFE8EAF6);
  static const Color textSecondary = Color(0xFF7986CB);
  static const Color textMuted = Color(0xFF3D4B6B);
  static const Color textCyan = Color(0xFF00E5FF);

  static const Color borderSubtle = Color(0xFF1E2D4A);
  static const Color borderActive = Color(0xFF00E5FF);

  // ─── Risk score colours ────────────────────────────────────────
  static Color riskColor(int score) {
    if (score < 30) return accentGreen;
    if (score < 60) return accentAmber;
    return accentRed;
  }

  static String riskLabel(int score) {
    if (score < 30) return 'SAFE';
    if (score < 60) return 'SUSPICIOUS';
    return 'DANGER';
  }

  // ─── Theme ─────────────────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDeep,
        colorScheme: const ColorScheme.dark(
          primary: accentCyan,
          secondary: accentGreen,
          error: accentRed,
          surface: bgCard,
          onPrimary: bgDeep,
          onSecondary: bgDeep,
          onError: bgDeep,
          onSurface: textPrimary,
        ),
        fontFamily: 'Rajdhani',
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: -0.5,
          ),
          displayMedium: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: textPrimary,
            letterSpacing: 1.2,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.8,
          ),
          titleLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: textPrimary,
            letterSpacing: 0.5,
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: textPrimary,
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Rajdhani',
            fontSize: 13,
            color: textSecondary,
          ),
          bodySmall: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 11,
            color: textMuted,
          ),
          labelLarge: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: accentCyan,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: bgElevated,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderSubtle, width: 1),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: borderSubtle, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentCyan, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: accentRed, width: 1),
          ),
          hintStyle: const TextStyle(
            color: textMuted,
            fontFamily: 'Rajdhani',
            fontSize: 14,
          ),
          labelStyle: const TextStyle(
            color: textSecondary,
            fontFamily: 'Rajdhani',
            fontSize: 14,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: accentCyan,
            foregroundColor: bgDeep,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 13,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: accentCyan,
            side: const BorderSide(color: accentCyan, width: 1.5),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: const TextStyle(
              fontFamily: 'SpaceMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
        cardTheme: CardTheme(
          color: bgCard,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: borderSubtle, width: 1),
          ),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDeep,
          elevation: 0,
          centerTitle: false,
          iconTheme: IconThemeData(color: textPrimary),
          titleTextStyle: TextStyle(
            fontFamily: 'SpaceMono',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: textPrimary,
            letterSpacing: 1,
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: bgCard,
          selectedItemColor: accentCyan,
          unselectedItemColor: textMuted,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),
        dividerTheme: const DividerThemeData(
          color: borderSubtle,
          thickness: 1,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: bgElevated,
          contentTextStyle: const TextStyle(
            color: textPrimary,
            fontFamily: 'Rajdhani',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: borderSubtle),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
}
