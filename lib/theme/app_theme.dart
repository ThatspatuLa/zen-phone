import 'package:flutter/material.dart';

/// Dark theme — primary mode. Light theme provided as fallback.
class AppTheme {
  static const Color accent = Color(0xFF06b6d4); // cyan
  static const Color bg = Color(0xFF0a0a0f);
  static const Color bgElevated = Color(0xFF14141c);
  static const Color bgCard = Color(0xFF1c1c26);
  static const Color text = Color(0xFFE5E7EB);
  static const Color textMuted = Color(0xFF9CA3AF);
  static const Color border = Color(0xFF2a2a36);

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.dark(
        primary: accent,
        secondary: accent,
        surface: bgElevated,
        onSurface: text,
        onPrimary: Colors.black,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: text,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: IconThemeData(color: text),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: bgElevated,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: bgCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: text),
        bodyMedium: TextStyle(color: text),
        bodySmall: TextStyle(color: textMuted),
        titleLarge: TextStyle(color: text, fontWeight: FontWeight.w600),
        titleMedium: TextStyle(color: text, fontWeight: FontWeight.w600),
        labelSmall: TextStyle(color: textMuted, fontSize: 11),
      ),
      iconTheme: const IconThemeData(color: text),
      dividerColor: border,
      visualDensity: VisualDensity.compact,
    );
  }
}
