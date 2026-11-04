import 'package:characters/characters.dart';

/// 縦書きでの1文字の置き方。
enum VerticalPlacement {
  /// そのまま立てて置く。漢字・かな・英数字・絵文字。
  upright,

  /// 90度回す。長音「ー」、波ダッシュ、括弧、ダッシュ類。
  rotate,

  /// 右上に寄せる。小書きのかな（っ・ゃ など）。
  smallKana,

  /// 右上に寄せる。句読点（、。）。
  punctuation,
}

class VerticalGlyph {
  const VerticalGlyph(this.text, this.placement);
  final String text;
  final VerticalPlacement placement;

  @override
  bool operator ==(Object other) =>
      other is VerticalGlyph &&
      other.text == text &&
      other.placement == placement;

  @override
  int get hashCode => Object.hash(text, placement);

  @override
  String toString() => '$text:${placement.name}';
}

/// 90度回す文字。約30文字。
const rotatedChars = {
  'ー', '－', '-', '―', '—', '‐', '〜', '～', '~', '…', '‥', '＝', '=', //
  '（', '）', '(', ')', '「', '」', '『', '』', '【', '】', '〔', '〕', //
  '［', '］', '[', ']', '｛', '｝', '{', '}', '〈', '〉', '《', '》', //
  '＜', '＞', '<', '>', '：', ':', '；', ';', '→', '←',
};

/// 右上に寄せる小書きのかな。
const smallKanaChars = {
  'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'っ', 'ゃ', 'ゅ', 'ょ', 'ゎ', 'ゕ', 'ゖ', //
  'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', 'ッ', 'ャ', 'ュ', 'ョ', 'ヮ', 'ヵ', 'ヶ', //
  'ㇰ',
  'ㇱ',
  'ㇲ',
  'ㇳ',
  'ㇴ',
  'ㇵ',
  'ㇶ',
  'ㇷ',
  'ㇸ',
  'ㇹ',
  'ㇺ',
  'ㇻ',
  'ㇼ',
  'ㇽ',
  'ㇾ',
  'ㇿ',
};

/// 右上に寄せる句読点。
const punctuationChars = {'、', '。', '，', '．', ',', '.'};

/// 1行の文字列を、縦に並べる文字の列にする。
/// 絵文字（結合文字を含む）は1つの文字として扱い、回さない。
List<VerticalGlyph> toVertical(String line) => [
  for (final ch in line.characters)
    if (ch != '\n' && ch != '\r') VerticalGlyph(ch, placementOf(ch)),
];

VerticalPlacement placementOf(String ch) {
  if (rotatedChars.contains(ch)) return VerticalPlacement.rotate;
  if (smallKanaChars.contains(ch)) return VerticalPlacement.smallKana;
  if (punctuationChars.contains(ch)) return VerticalPlacement.punctuation;
  return VerticalPlacement.upright;
}
