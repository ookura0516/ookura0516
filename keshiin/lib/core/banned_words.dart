/// 郵便切手と紛らわしく見えないように、シート名・消印の場所・一言から弾く語。
///
/// 郵便切手類模造等取締法への配慮（設計書「リスクと対策」）。
/// ここでの判定は機械的な予防策で、法的な確認の代わりにはならない。
library;

/// 判定の結果。[ok] でないとき [reason] に理由が入る。
class WordCheck {
  const WordCheck.ok() : ok = true, reason = null;
  const WordCheck.ng(String this.reason) : ok = false;

  final bool ok;
  final String? reason;
}

/// 正規化した文字列に含まれていたら弾く語（正規化後の形で持つ）。
const List<String> bannedTerms = [
  '郵便', // 日本郵便・郵便局・郵便切手を含む
  'ゆうびん',
  'ユウビン',
  '郵政',
  '〒',
  'nippon',
  'ニッポン',
  'japanpost',
  'yubin',
  'yuubin',
  'postage',
];

/// 通貨記号。どこにあっても弾く。
const List<String> currencySymbols = [
  '¥', '￥', r'$', '€', '£', '₩', '元', '円', //
];

/// 全角英数・全角記号を半角に、英字を小文字にし、空白と記号の区切りを除く。
/// 「Ｎ Ｉ Ｐ Ｐ Ｏ Ｎ」や「N.I.P.P.O.N」のような書き方もまとめて捕まえる。
String normalizeForCheck(String input) {
  final b = StringBuffer();
  for (final rune in input.runes) {
    var c = rune;
    // 全角 ASCII（！〜～）を半角へ。
    if (c >= 0xFF01 && c <= 0xFF5E) c -= 0xFEE0;
    // 全角空白
    if (c == 0x3000) c = 0x20;
    // 半角カナの「ﾕｳﾋﾞﾝ」などは全角カナへ（よく使う範囲だけ）。
    final s = String.fromCharCode(c);
    b.write(_halfKana[s] ?? s);
  }
  var s = b.toString().toLowerCase();
  // 濁点の合成（ﾋﾞ → ビ）
  s = s.replaceAllMapped(RegExp('([゠-ヿ])゛'), (m) {
    final base = m[1]!.codeUnitAt(0);
    return String.fromCharCode(base + 1);
  });
  // 空白・中点・区切り記号を除く。
  s = s.replaceAll(RegExp(r'[\s\.\-_・･/|,，、。]'), '');
  return s;
}

const Map<String, String> _halfKana = {
  'ﾕ': 'ユ', 'ｳ': 'ウ', 'ﾋ': 'ヒ', 'ﾝ': 'ン', 'ﾆ': 'ニ', 'ｯ': 'ッ', 'ﾎ': 'ホ', //
  'ﾟ': '゜', 'ﾞ': '゛',
};

/// シート名・旅のシート名の判定。
WordCheck checkSheetTitle(String input) => _check(input, label: 'シート名');

/// 消印の一言の判定。
WordCheck checkPostmarkNote(String input) => _check(input, label: '一言');

/// 消印の場所の判定。「○○局」の形式（郵便局名に見える形）も弾く。
WordCheck checkPostmarkPlace(String input) {
  final base = _check(input, label: '場所');
  if (!base.ok) return base;
  final n = normalizeForCheck(input);
  if (n.endsWith('局')) {
    return const WordCheck.ng('場所を「○○局」の形にはできません');
  }
  return const WordCheck.ok();
}

WordCheck _check(String input, {required String label}) {
  final n = normalizeForCheck(input);
  for (final t in bannedTerms) {
    if (n.contains(t)) {
      return WordCheck.ng('$labelに「${_display(t)}」は使えません');
    }
  }
  for (final c in currencySymbols) {
    // 「円」「元」は地名（円山・元町）にも使うので、数字のすぐ後ろのときだけ弾く。
    if (c == '円' || c == '元') {
      if (RegExp('[0-9〇一二三四五六七八九十百千万]$c').hasMatch(n)) {
        return WordCheck.ng('$labelに金額のような表記は使えません');
      }
      continue;
    }
    if (n.contains(c)) {
      return WordCheck.ng('$labelに通貨記号は使えません');
    }
  }
  // 「84yen」「100jpy」のような額面に見える表記。
  if (RegExp(r'[0-9]+(yen|jpy|sen)').hasMatch(n) ||
      RegExp(r'(yen|jpy)[0-9]+').hasMatch(n)) {
    return WordCheck.ng('$labelに金額のような表記は使えません');
  }
  return const WordCheck.ok();
}

String _display(String t) => switch (t) {
  'nippon' => 'NIPPON',
  'japanpost' => 'JAPAN POST',
  'yubin' || 'yuubin' => 'YUBIN',
  'postage' => 'POSTAGE',
  _ => t,
};
