import 'dart:ui';

/// 切手の外形。
enum StampOutline { rect, triangle, diamond }

/// 縁の飾り。すべてこのアプリのための自作の幾何模様で、実在の切手を写したものではない。
enum FrameOrnament { none, doubleLine, wave, dots, corners }

/// フレーム（目打ちの形・縁の色）。
class FrameSpec {
  const FrameSpec({
    required this.id,
    required this.name,
    required this.premium,
    required this.paper,
    required this.line,
    this.outline = StampOutline.rect,
    this.ornament = FrameOrnament.none,
    this.margin = 0.07,
    this.pitch = 0.065,
    this.hole = 0.36,
  });

  final String id;
  final String name;

  /// 買い切り「記念」で解放するか。
  final bool premium;

  /// 紙の色（白縁の色）。
  final Color paper;

  /// 写真のまわりの細い線と飾りの色。
  final Color line;

  final StampOutline outline;
  final FrameOrnament ornament;

  /// 白縁の幅（切手の短辺に対する割合）。
  final double margin;

  /// 目打ちの間隔（短辺に対する割合）。
  final double pitch;

  /// 穴の半径（間隔に対する割合）。
  final double hole;
}

const List<FrameSpec> allFrames = [
  // 無料の3種
  FrameSpec(
    id: 'shiro',
    name: '白縁',
    premium: false,
    paper: Color(0xFFFBFAF6),
    line: Color(0xFFD8D3C8),
  ),
  FrameSpec(
    id: 'kinari',
    name: '生成り・細目',
    premium: false,
    paper: Color(0xFFF3EBD9),
    line: Color(0xFFB9A98A),
    pitch: 0.05,
    hole: 0.34,
  ),
  FrameSpec(
    id: 'sumi',
    name: '墨縁',
    premium: false,
    paper: Color(0xFF2B2A28),
    line: Color(0xFF6D6A63),
  ),
  // 記念（買い切り）の8種
  FrameSpec(
    id: 'ogata',
    name: '大型',
    premium: true,
    paper: Color(0xFFFBFAF6),
    line: Color(0xFF9C8F78),
    ornament: FrameOrnament.doubleLine,
    margin: 0.12,
    pitch: 0.055,
  ),
  FrameSpec(
    id: 'sankaku',
    name: '三角',
    premium: true,
    paper: Color(0xFFFBF7EC),
    line: Color(0xFFC08B5C),
    outline: StampOutline.triangle,
    margin: 0.06,
    pitch: 0.06,
  ),
  FrameSpec(
    id: 'hishi',
    name: '菱形',
    premium: true,
    paper: Color(0xFFF7F4EE),
    line: Color(0xFF7D8FA6),
    outline: StampOutline.diamond,
    margin: 0.06,
    pitch: 0.06,
  ),
  FrameSpec(
    id: 'nami',
    name: '波の縁',
    premium: true,
    paper: Color(0xFFF4F1E8),
    line: Color(0xFF4F7A94),
    ornament: FrameOrnament.wave,
    margin: 0.1,
  ),
  FrameSpec(
    id: 'tsubu',
    name: '粒の縁',
    premium: true,
    paper: Color(0xFFFAF3EE),
    line: Color(0xFFC77D7D),
    ornament: FrameOrnament.dots,
    margin: 0.1,
  ),
  FrameSpec(
    id: 'kado',
    name: '角飾り',
    premium: true,
    paper: Color(0xFFF6F2E4),
    line: Color(0xFF8A7A4A),
    ornament: FrameOrnament.corners,
    margin: 0.1,
  ),
  FrameSpec(
    id: 'yoru',
    name: '夜色',
    premium: true,
    paper: Color(0xFF1F2A44),
    line: Color(0xFF8FA3C9),
    ornament: FrameOrnament.doubleLine,
    margin: 0.09,
  ),
  FrameSpec(
    id: 'wakakusa',
    name: '若草',
    premium: true,
    paper: Color(0xFFEFF3E2),
    line: Color(0xFF7E9A5A),
    ornament: FrameOrnament.dots,
    pitch: 0.05,
  ),
];

const String defaultFrameId = 'shiro';

FrameSpec frameById(String id) =>
    allFrames.firstWhere((f) => f.id == id, orElse: () => allFrames.first);

/// 消印の書体。端末に入っている書体を使う（フォントファイルは同梱しない）。
class PostmarkFont {
  const PostmarkFont(
    this.id,
    this.name,
    this.families, {
    this.premium = false,
    this.weight = FontWeight.w600,
  });
  final String id;
  final String name;
  final List<String> families;
  final bool premium;
  final FontWeight weight;
}

const List<PostmarkFont> postmarkFonts = [
  PostmarkFont('gothic', 'ゴシック', [
    'Hiragino Sans',
    'Noto Sans CJK JP',
    'Noto Sans JP',
    'sans-serif',
  ]),
  PostmarkFont('mincho', '明朝', [
    'Hiragino Mincho ProN',
    'Noto Serif CJK JP',
    'Noto Serif JP',
    'serif',
  ], premium: true),
  PostmarkFont(
    'futo',
    '太ゴシック',
    ['Hiragino Sans', 'Noto Sans CJK JP', 'Noto Sans JP', 'sans-serif'],
    premium: true,
    weight: FontWeight.w900,
  ),
];

PostmarkFont postmarkFontById(String id) => postmarkFonts.firstWhere(
  (f) => f.id == id,
  orElse: () => postmarkFonts.first,
);

/// 切手の縦横。
enum StampShape {
  square(1.0),
  portrait(3 / 4);

  const StampShape(this.aspect);

  /// 幅 ÷ 高さ
  final double aspect;

  static StampShape parse(String s) =>
      StampShape.values.firstWhere((v) => v.name == s, orElse: () => square);
}
