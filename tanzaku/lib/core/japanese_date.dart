/// 漢数字と和暦の日付。短冊の日付に使う。
library;

const _digits = ['〇', '一', '二', '三', '四', '五', '六', '七', '八', '九'];

/// 1〜9999 を「二十四」「百八」のような漢数字に。0 は「〇」。
String kanjiNumber(int n) {
  if (n == 0) return '〇';
  if (n < 0 || n > 9999) return n.toString();
  final buf = StringBuffer();
  void unit(int v, String u) {
    if (v == 0) return;
    if (v > 1) buf.write(_digits[v]);
    buf.write(u);
  }

  unit(n ~/ 1000, '千');
  unit(n ~/ 100 % 10, '百');
  unit(n ~/ 10 % 10, '十');
  final r = n % 10;
  if (r > 0) buf.write(_digits[r]);
  return buf.toString();
}

/// 令和の年（2019年が元年）。
String reiwaYear(int year) {
  final y = year - 2018;
  if (y < 1) return '${kanjiNumber(year)}年';
  return '令和${y == 1 ? '元' : kanjiNumber(y)}年';
}

/// 「令和八年十一月四日」。
String japaneseDate(DateTime d) =>
    '${reiwaYear(d.year)}${kanjiNumber(d.month)}月${kanjiNumber(d.day)}日';

/// 和風月名。
const wafuMonths = [
  '睦月', '如月', '弥生', '卯月', '皐月', '水無月', //
  '文月', '葉月', '長月', '神無月', '霜月', '師走',
];

String wafuMonth(int month) => wafuMonths[month - 1];
