import 'dart:math' as math;
import 'dart:ui';

/// 目打ち（切手の周囲の穴）の幾何。
///
/// 縁の上に半円が等間隔に並ぶように、穴の中心を辺の上に置く。
/// 角でも間隔がそろうように、まず辺の長さから「その辺に入る間隔の数」を
/// 整数で決め、その数で辺を等分する。すると両端（＝角）にちょうど穴が来て、
/// 隣の辺の並びと角でつながる。
class Perforation {
  const Perforation({required this.pitch, required this.radius})
    : assert(pitch > 0),
      assert(radius > 0);

  /// 穴の中心どうしの目安の間隔。実際の間隔は辺ごとに少し伸び縮みする。
  final double pitch;

  /// 穴の半径。
  final double radius;

  /// 長さ [length] の辺に入る間隔の数。最低でも1。
  static int intervalsFor(double length, double pitch) {
    if (length <= 0) return 1;
    return math.max(1, (length / pitch).round());
  }

  /// 多角形 [vertices]（時計回りでも反時計回りでもよい）の各辺に置く穴の中心。
  ///
  /// 角の穴は1つだけ（重複しない）。辺 i の穴は頂点 i から始まり、
  /// 頂点 i+1 の手前で終わる（そこは次の辺の始まり）。
  List<Offset> centersForPolygon(List<Offset> vertices) {
    final out = <Offset>[];
    for (var i = 0; i < vertices.length; i++) {
      final a = vertices[i];
      final b = vertices[(i + 1) % vertices.length];
      final edge = b - a;
      final n = intervalsFor(edge.distance, pitch);
      for (var k = 0; k < n; k++) {
        out.add(a + edge * (k / n));
      }
    }
    return out;
  }

  /// 矩形の穴の中心。
  List<Offset> centersForRect(Rect r) =>
      centersForPolygon([r.topLeft, r.topRight, r.bottomRight, r.bottomLeft]);

  /// 穴をくり抜いた紙の形。
  Path cutPolygon(List<Offset> vertices) {
    final paper = Path()..addPolygon(vertices, true);
    final holes = Path();
    for (final c in centersForPolygon(vertices)) {
      holes.addOval(Rect.fromCircle(center: c, radius: radius));
    }
    return Path.combine(PathOperation.difference, paper, holes);
  }

  Path cutRect(Rect r) =>
      cutPolygon([r.topLeft, r.topRight, r.bottomRight, r.bottomLeft]);
}

/// 辺ごとの実際の間隔（テスト・デバッグ用）。
List<double> actualPitches(List<Offset> vertices, double pitch) {
  final out = <double>[];
  for (var i = 0; i < vertices.length; i++) {
    final a = vertices[i];
    final b = vertices[(i + 1) % vertices.length];
    final len = (b - a).distance;
    out.add(len / Perforation.intervalsFor(len, pitch));
  }
  return out;
}
