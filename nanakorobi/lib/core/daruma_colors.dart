/// だるまの12色。id は保存に使うので変えない。
///
/// 色の意味は産地や店で違うので、アプリでは断定しない。一言の由来は ARB（colorNote…）で持つ。
/// 無料は 0〜2（赤・白・黒）。
enum DarumaColor {
  red(0, 0xFFC73E2E, 0xFFF6E7C9, 0xFF8F2418),
  white(1, 0xFFF4EFE4, 0xFFFBF7EE, 0xFFB8AE9A),
  black(2, 0xFF2B2A2E, 0xFFF1E6CF, 0xFF0F0E11),
  yellow(3, 0xFFE8B931, 0xFFFBF3D6, 0xFFB38A17),
  green(4, 0xFF3C8C5A, 0xFFEAF2DD, 0xFF245A39),
  blue(5, 0xFF2F62A8, 0xFFE6EEF9, 0xFF1C3F70),
  purple(6, 0xFF6E4A9E, 0xFFF0E8F7, 0xFF472C6B),
  pink(7, 0xFFE58AA5, 0xFFFBEEF2, 0xFFB95C7A),
  gold(8, 0xFFC9A227, 0xFFFBF4D8, 0xFF8F6F12),
  orange(9, 0xFFE0762F, 0xFFFBEBDD, 0xFFA3521B),
  navy(10, 0xFF1F2A5C, 0xFFE8EAF3, 0xFF111837),
  brown(11, 0xFF7A4B2A, 0xFFF3E7DA, 0xFF4E2E18);

  const DarumaColor(this.id, this.body, this.face, this.shade);

  final int id;

  /// 体の色（ARGB）。
  final int body;

  /// 顔の色。
  final int face;

  /// 輪郭と影の色。
  final int shade;

  static DarumaColor byId(int id) => values.firstWhere((c) => c.id == id, orElse: () => red);

  /// 白・黄・桃・金など明るい体には黒い線、暗い体には白っぽい線を使う。
  bool get isLight => this == white || this == yellow || this == pink || this == gold;
}
