import 'package:flutter/material.dart';

/// 紙の生成りと、消印のインクの色。
class KeshiinTheme {
  static const Color paper = Color(0xFFF4EFE4);
  static const Color card = Color(0xFFFBF8F1);
  static const Color ink = Color(0xFF2E3440);
  static const Color inkDim = Color(0xFF6B6459);
  static const Color accent = Color(0xFFB8432F); // 朱
  static const Color line = Color(0xFFD9D0BF);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: ink,
        onPrimary: Colors.white,
        secondary: accent,
        surface: card,
        onSurface: ink,
        error: accent,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: card,
        indicatorColor: line,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

/// アプリ内の注意書き（設計書「リスクと対策」）。
const String kNotPostageNotice = '切手風のデザインで、郵便には使えません。';
