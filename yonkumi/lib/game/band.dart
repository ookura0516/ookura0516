/// 帯の色（難易度）の名前と、文字の結果に使う絵文字。
///
/// 色はNYTの4色（黄・緑・青・紫）を避け、柿→紅→栗→墨と、明るい色から暗い色へ
/// 並べた。色の区別がつきにくい人にも、明るさの順と色名で難易度が分かる。
class Band {
  const Band._(this.difficulty, this.name, this.emoji, this.label);

  final int difficulty;

  /// 色名（色覚対応の表示に使う）。
  final String name;
  final String emoji;

  /// 難易度の言葉。
  final String label;

  static const kaki = Band._(1, '柿', '🟧', 'やさしい');
  static const beni = Band._(2, '紅', '🟥', 'ふつう');
  static const kuri = Band._(3, '栗', '🟫', 'むずかしい');
  static const sumi = Band._(4, '墨', '⬛', 'とてもむずかしい');

  static const all = [kaki, beni, kuri, sumi];

  static Band of(int difficulty) => all[(difficulty - 1).clamp(0, 3)];

  static Map<int, String> get emojiPalette => {
    for (final b in all) b.difficulty: b.emoji,
  };
}
