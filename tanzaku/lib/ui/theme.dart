import 'package:flutter/material.dart';

import '../core/season.dart';
import '../render/style.dart';

/// 和紙の生成りと墨。季節でアクセントの色だけ変える。
class TanzakuTheme {
  static const Color paper = Color(0xFFFBF7F0);
  static const Color ink = Color(0xFF231C17);
  static const Color inkDim = Color(0xFF6B5F55);
  static const Color line = Color(0xFFE5DCCD);
  static const Color shu = Color(0xFFB8282F);

  /// 句の字。
  static const String haikuFont = 'NotoSerifJP';

  static ThemeData of(Season season) {
    final p = SeasonPalette.of(season);
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: p.accent,
        primary: p.accent,
        surface: paper,
        onSurface: ink,
      ),
      scaffoldBackgroundColor: paper,
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: haikuFont,
          fontSize: 20,
          color: ink,
        ),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
          side: BorderSide(color: line),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          borderSide: BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: ink,
          side: const BorderSide(color: line, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 17),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// 入力欄の字（最小18pt。端末の文字サイズの設定はそのまま効く）。
  static const TextStyle input = TextStyle(
    fontFamily: haikuFont,
    fontSize: 22,
    height: 1.4,
    color: ink,
  );
  static const TextStyle inputSmall = TextStyle(
    fontFamily: haikuFont,
    fontSize: 18,
    height: 1.4,
    color: ink,
  );
  static const TextStyle haiku = TextStyle(
    fontFamily: haikuFont,
    fontSize: 18,
    height: 1.5,
    color: ink,
  );
}
