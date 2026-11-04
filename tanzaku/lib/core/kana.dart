/// かなの判定と変換。
library;

bool isHiragana(int c) => (c >= 0x3041 && c <= 0x309F);
bool isKatakana(int c) =>
    (c >= 0x30A0 && c <= 0x30FF) || (c >= 0x31F0 && c <= 0x31FF);
bool isKana(int c) => isHiragana(c) || isKatakana(c);

/// 漢字（CJK統合漢字と拡張A、互換漢字、々〆）。
bool isKanji(int c) =>
    (c >= 0x4E00 && c <= 0x9FFF) ||
    (c >= 0x3400 && c <= 0x4DBF) ||
    (c >= 0xF900 && c <= 0xFAFF) ||
    (c >= 0x20000 && c <= 0x2FFFF) ||
    c == 0x3005 || // 々
    c == 0x3006; // 〆

/// カタカナをひらがなに（ー などはそのまま）。
String toHiragana(String s) {
  final out = StringBuffer();
  for (final c in s.runes) {
    if (c >= 0x30A1 && c <= 0x30F6) {
      out.writeCharCode(c - 0x60);
    } else {
      out.writeCharCode(c);
    }
  }
  return out.toString();
}
