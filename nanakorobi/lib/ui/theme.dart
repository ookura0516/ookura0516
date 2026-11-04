import 'package:flutter/material.dart';

/// 和紙の生成りと、だるまの赤、金。
class NanakorobiTheme {
  static const Color paper = Color(0xFFF3ECDF);
  static const Color paperDeep = Color(0xFFE9DFCC);
  static const Color card = Color(0xFFFFFDF8);
  static const Color ink = Color(0xFF2A221C);
  static const Color inkDim = Color(0xFF6B5A4A);
  static const Color red = Color(0xFFC3262A);
  static const Color redDeep = Color(0xFF8E1F22);
  static const Color gold = Color(0xFFE2B94E);
  static const Color goldDeep = Color(0xFFB8892E);
  static const Color line = Color(0xFFDCD2C0);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: red,
        onPrimary: Colors.white,
        secondary: goldDeep,
        onSecondary: ink,
        surface: card,
        onSurface: ink,
        error: redDeep,
        outline: line,
      ),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        color: card,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: line),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: paper, fontSize: 15),
        behavior: SnackBarBehavior.floating,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: red, width: 1.6),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: ink,
          side: const BorderSide(color: inkDim),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: inkDim),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: card,
        selectedColor: const Color(0xFFF7D9D6),
        side: const BorderSide(color: line),
        labelStyle: const TextStyle(color: ink),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      dividerTheme: const DividerThemeData(color: line),
      listTileTheme: const ListTileThemeData(iconColor: inkDim),
    );
  }
}
