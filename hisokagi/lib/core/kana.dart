/// 入力のゆれを吸収する。
///
/// - 前後と途中の空白（全角を含む）を取り除く
/// - 全角の英数字を半角にする
/// - カタカナをひらがなにする
/// - 英字を小文字にする
String normalizeInput(String input) {
  final buf = StringBuffer();
  for (final rune in input.runes) {
    var c = rune;
    if (c == 0x20 || c == 0x3000 || c == 0x09 || c == 0x0A || c == 0x0D) {
      continue;
    }
    if (c >= 0xFF01 && c <= 0xFF5E) {
      c -= 0xFEE0; // 全角ASCII → 半角
    }
    if (c >= 0x30A1 && c <= 0x30F6) {
      c -= 0x60; // カタカナ → ひらがな
    }
    if (c >= 0x41 && c <= 0x5A) {
      c += 0x20;
    }
    buf.writeCharCode(c);
  }
  return buf.toString();
}
