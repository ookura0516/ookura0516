import 'package:flutter/material.dart';

/// 夜空の紺と、星の金色。
class HisokagiTheme {
  static const Color bg = Color(0xFF0D1426);
  static const Color surface = Color(0xFF172140);
  static const Color surfaceHi = Color(0xFF22305A);
  static const Color star = Color(0xFFF2C96B);
  static const Color starDim = Color(0xFFB8975A);
  static const Color text = Color(0xFFEAF0FF);
  static const Color textDim = Color(0xFF9AA6C7);
  static const Color good = Color(0xFF7BD8A0);
  static const Color danger = Color(0xFFF08A8A);

  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: const ColorScheme.dark(
        primary: star,
        onPrimary: Color(0xFF1B1608),
        secondary: starDim,
        surface: surface,
        onSurface: text,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: text,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        margin: EdgeInsets.symmetric(vertical: 6),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: surface),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: surfaceHi,
        contentTextStyle: TextStyle(color: text),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceHi,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: text,
          side: const BorderSide(color: surfaceHi, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  static const BoxDecoration sky = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF15204A), bg, Color(0xFF070B17)],
      stops: [0.0, 0.55, 1.0],
    ),
  );
}
