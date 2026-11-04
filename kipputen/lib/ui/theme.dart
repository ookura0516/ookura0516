import 'package:flutter/material.dart';

/// 駅の待合室の、生成り色の壁と深緑の文字。
class KipTheme {
  static const Color bg = Color(0xFFF3EFE4);
  static const Color surface = Color(0xFFFFFCF4);
  static const Color ink = Color(0xFF22342A);
  static const Color inkDim = Color(0xFF66756B);
  static const Color line = Color(0xFFD9D2BF);
  static const Color accent = Color(0xFF2F6B4F);
  static const Color gold = Color(0xFFC9A227);
  static const Color punch = Color(0xFFB3412F);
  static const Color locked = Color(0xFFCFCABB);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: bg,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        surface: surface,
        primary: accent,
        onSurface: ink,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bg,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: surface,
        indicatorColor: Color(0xFFD5E6D9),
      ),
      cardTheme: const CardThemeData(
        color: surface,
        margin: EdgeInsets.symmetric(vertical: 6),
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
          foregroundColor: ink,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
