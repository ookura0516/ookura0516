/// カタカナをひらがなにする。長音符「ー」などはそのまま残す。
String toHiragana(String s) {
  final out = StringBuffer();
  for (final r in s.runes) {
    // ァ(30A1)〜ヶ(30F6) → ぁ(3041)〜ゖ(3096)
    out.writeCharCode(r >= 0x30A1 && r <= 0x30F6 ? r - 0x60 : r);
  }
  return out.toString();
}

/// 画面に出す文字数（タイルは7文字まで）。
int displayLength(String s) => s.runes.length;
