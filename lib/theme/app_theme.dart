import 'package:flutter/material.dart';

/// App theme — dark mode primary, cyan accent, refined typography.
class AppTheme {
  static const Color accent = Color(0xFF06b6d4);
  static const Color accentDim = Color(0xFF0891a6);
  static const Color warning = Color(0xFFf59e0b);
  static const Color success = Color(0xFF10b981);
  static const Color error = Color(0xFFef4444);
  static const Color bgPrimary = Color(0xFF0a0a0f);
  static const Color bgSecondary = Color(0xFF131319);
  static const Color bgTertiary = Color(0xFF1a1a23);
  static const Color border = Color(0xFF2a2a35);
  static const Color borderLight = Color(0xFF3a3a48);
  static const Color textPrimary = Color(0xFFf0f0f5);
  static const Color textSecondary = Color(0xFFa0a0b0);
  static const Color textTertiary = Color(0xFF6a6a78);
  static const double spaceXs = 4.0;
  static const double spaceSm = 8.0;
  static const double spaceMd = 12.0;
  static const double spaceLg = 16.0;
  static const double spaceXl = 24.0;
  static const double spaceXxl = 32.0;
  static const double radiusSm = 6.0;
  static const double radiusMd = 10.0;
  static const double radiusLg = 14.0;
  static const Duration aniFast = Duration(milliseconds: 150);
  static const Duration aniNormal = Duration(milliseconds: 250);
  static const Duration aniSlow = Duration(milliseconds: 400);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      primaryColor: accent,
      colorScheme: const ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: bgSecondary,
        error: error,
      ),
      fontFamily: 'SF Pro Text',
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.3),
        titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: textPrimary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textPrimary),
        bodyLarge: TextStyle(fontSize: 16, color: textPrimary),
        bodyMedium: TextStyle(fontSize: 14, color: textPrimary),
        bodySmall: TextStyle(fontSize: 12, color: textSecondary),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: textPrimary),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textPrimary, letterSpacing: -0.2),
        iconTheme: IconThemeData(color: textPrimary),
      ),
      cardTheme: const CardThemeData(color: bgSecondary, elevation: 0, margin: EdgeInsets.zero),
      dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spaceLg,
          vertical: spaceMd,
        ),
        hintStyle: const TextStyle(color: textSecondary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: spaceLg, vertical: spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMd),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: accent),
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 22),
      useMaterial3: true,
    );
  }
}
