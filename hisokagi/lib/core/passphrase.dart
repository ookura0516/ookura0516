import 'kana.dart';
import 'rng.dart';

/// 合言葉に使う、声に出しやすい3文字のひらがなの言葉。
///
/// 小さい「ゃ」「っ」を含まず、似た音の組み合わせを避けている。
/// 並びを変えると既存の部屋の合言葉が変わるので、追加するときは末尾に足す。
const List<String> passphraseWords = [
  'さくら', 'みかん', 'いちご', 'めだか', 'すずめ', 'からす', 'かえる', 'うさぎ',
  'きつね', 'たぬき', 'ひつじ', 'こあら', 'らくだ', 'いるか', 'くじら', 'めろん',
  'とまと', 'ぶどう', 'りんご', 'きのこ', 'たまご', 'つばめ', 'かもめ', 'すいか',
  'こけし', 'だるま', 'たいこ', 'かがみ', 'はさみ', 'ほうき', 'やかん', 'まくら',
  'ふとん', 'たたみ', 'かばん', 'めがね', 'とけい', 'あひる', 'もみじ', 'つくし',
  'あさり', 'わかめ',
];

/// ステージを解いた端末が表示し、相棒の端末が照合する合言葉。
String passphraseFor({
  required int scenario,
  required int seed,
  required int stage,
}) {
  final rng = Rng.forKey(['pass', scenario, seed, stage]);
  return rng.pick(passphraseWords);
}

bool matchesPassphrase(String input, String expected) =>
    normalizeInput(input) == expected;
