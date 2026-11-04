import 'package:flutter/material.dart';

import '../game/band.dart';

/// 和紙の地と墨の文字。帯は柿・紅・栗・墨。
class YonkumiTheme {
  static const Color paper = Color(0xFFF6F1E7);
  static const Color surface = Color(0xFFFFFCF6);
  static const Color tile = Color(0xFFE8DFCF);
  static const Color tileSelected = Color(0xFF4A423B);
  static const Color ink = Color(0xFF2B2622);
  static const Color inkDim = Color(0xFF75695E);
  static const Color line = Color(0xFFD9CEBB);
  static const Color accent = Color(0xFF9C3D2E);

  /// 帯の地色。明るい順に並べ、色が見分けにくくても明るさで順が分かる。
  static Color band(int difficulty) => switch (Band.of(difficulty)) {
    Band.kaki => const Color(0xFFF0A65E),
    Band.beni => const Color(0xFFC9483F),
    Band.kuri => const Color(0xFF7B4B2C),
    _ => const Color(0xFF2E2A2A),
  };

  /// 帯の上の文字色。
  static Color onBand(int difficulty) =>
      difficulty == 1 ? ink : const Color(0xFFFFF8EE);

  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      surface: surface,
    ).copyWith(primary: ink, onPrimary: surface, secondary: accent);
    return base.copyWith(
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: surface,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: ink,
          foregroundColor: surface,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ink,
          minimumSize: const Size(48, 48),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          side: const BorderSide(color: inkDim),
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: SegmentedButton.styleFrom(
          selectedBackgroundColor: tile,
          selectedForegroundColor: ink,
          foregroundColor: ink,
          side: const BorderSide(color: inkDim),
        ),
      ),
      textTheme: base.textTheme.apply(bodyColor: ink, displayColor: ink),
    );
  }
}
