/// 色の番号の並びを、絵文字の四角の行に変える（文字だけの結果共有用）。
///
/// [rows] の各行は色の番号の並び、[palette] は番号から絵文字への対応。
/// 対応のない番号は [fallback] にする。
String emojiGrid(
  Iterable<Iterable<int>> rows,
  Map<int, String> palette, {
  String fallback = '⬜',
}) => rows.map((r) => r.map((c) => palette[c] ?? fallback).join()).join('\n');
