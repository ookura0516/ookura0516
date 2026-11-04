import 'package:flutter/material.dart';

/// 和紙の生成りと墨、朱と金（ookura_design の代わり。README「共有パッケージの差し替え」）。
///
/// 主役はだるま。背景は静かな生成りにして、色はだるま側に持たせる。
class NanakorobiTheme {
  const NanakorobiTheme._();

  static const Color paper = Color(0xFFF7F1E6);
  static const Color paperDeep = Color(0xFFEFE5D3);
  static const Color card = Color(0xFFFFFBF4);
  static const Color ink = Color(0xFF2A2320);
  static const Color inkDim = Color(0xFF7A6E66);
  static const Color vermilion = Color(0xFFC73E2E);
  static const Color gold = Color(0xFFC9A227);
  static const Color goldLight = Color(0xFFE8C867);
  static const Color good = Color(0xFF3C8C5A);
  static const Color danger = Color(0xFFB4322A);

  /// 毛筆体のフォント（Yuji Syuku、SIL OFL 1.1）。pubspec の family 名。
  /// 描画側（DarumaPainter）は null も受け付け、そのときは端末のフォントの太字で描く（README「毛筆体フォント」）。
  static const String brushFontFamily = 'NanakorobiBrush';

  /// [fontFamily] は画面の文字のフォント。null なら端末のフォント。ストア素材の撮影でだけ指定する。
  static ThemeData light({String? fontFamily}) {
    var base = ThemeData.light(useMaterial3: true);
    if (fontFamily != null) {
      base = base.copyWith(
        textTheme: base.textTheme.apply(fontFamily: fontFamily),
        primaryTextTheme: base.primaryTextTheme.apply(fontFamily: fontFamily),
      );
    }
    return base.copyWith(
      scaffoldBackgroundColor: paper,
      colorScheme: const ColorScheme.light(
        primary: vermilion,
        onPrimary: Color(0xFFFFF6F0),
        secondary: gold,
        onSecondary: ink,
        surface: card,
        onSurface: ink,
        error: danger,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: paper,
        foregroundColor: ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
      ),
      cardTheme: const CardThemeData(
        color: card,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          side: BorderSide(color: paperDeep),
        ),
      ),
      dialogTheme: const DialogThemeData(backgroundColor: card),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: card,
        showDragHandle: true,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ink,
        contentTextStyle: TextStyle(color: paper, fontFamily: fontFamily),
        behavior: SnackBarBehavior.floating,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: card,
        selectedColor: const Color(0xFFF4D9D2),
        side: const BorderSide(color: paperDeep),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: card,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: paperDeep),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: paperDeep),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: fontFamily),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          foregroundColor: ink,
          side: const BorderSide(color: Color(0xFFD9CDB8), width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: TextStyle(fontSize: 16, fontFamily: fontFamily),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: vermilion,
          textStyle: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: fontFamily),
        ),
      ),
      listTileTheme: const ListTileThemeData(iconColor: inkDim),
      dividerTheme: const DividerThemeData(color: paperDeep),
    );
  }
}
