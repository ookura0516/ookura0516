import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import '../core/crop.dart';
import '../core/frames.dart';
import '../core/perforation.dart';
import 'postmark_painter.dart';

/// 切手1枚を描くのに要るもの。画像は先に読み込んだもの（無ければ灰色の仮の面）。
class StampVisual {
  const StampVisual({
    required this.photo,
    required this.crop,
    required this.shape,
    required this.frame,
    this.serial = 0,
    this.sheetName = '',
    this.postmark,
  });

  final ui.Image? photo;
  final CropRect crop;
  final StampShape shape;
  final FrameSpec frame;

  /// 左上の通し番号。0なら描かない。
  final int serial;

  /// 右下の小さなシート名。
  final String sheetName;
  final PostmarkData? postmark;
}

/// 切手の外形と写真の窓。
class StampGeometry {
  StampGeometry._(
    this.outline,
    this.window,
    this.windowBounds,
    this.perforation,
  );

  /// 紙の外形（目打ちの穴の中心が並ぶ線）。
  final List<Offset> outline;

  /// 写真を入れる窓。
  final List<Offset> window;
  final Rect windowBounds;
  final Perforation perforation;

  /// [area] の中に、[shape] の縦横比で切手を置く。
  factory StampGeometry.fit(Rect area, StampShape shape, FrameSpec frame) {
    final aspect = switch (frame.outline) {
      StampOutline.rect => shape.aspect,
      StampOutline.triangle => 1 / (math.sqrt(3) / 2), // 正三角形（幅÷高さ）
      StampOutline.diamond => 1.0,
    };
    // 穴の半円が外にはみ出す分を先に引いておく。
    final short0 = math.min(area.width, area.height);
    final holeR = short0 * frame.pitch * frame.hole;
    final inner = area.deflate(holeR);
    double w = inner.width;
    double h = w / aspect;
    if (h > inner.height) {
      h = inner.height;
      w = h * aspect;
    }
    final body = Rect.fromCenter(center: inner.center, width: w, height: h);
    final short = math.min(w, h);
    final perf = Perforation(
      pitch: short * frame.pitch,
      radius: short * frame.pitch * frame.hole,
    );
    final m = short * frame.margin + perf.radius;

    switch (frame.outline) {
      case StampOutline.rect:
        final outline = [
          body.topLeft,
          body.topRight,
          body.bottomRight,
          body.bottomLeft,
        ];
        final win = body.deflate(m);
        return StampGeometry._(
          outline,
          [win.topLeft, win.topRight, win.bottomRight, win.bottomLeft],
          win,
          perf,
        );
      case StampOutline.triangle:
        final outline = [
          Offset(body.center.dx, body.top),
          body.bottomRight,
          body.bottomLeft,
        ];
        final win = _insetConvex(outline, m * 1.1);
        return StampGeometry._(outline, win, _bounds(win), perf);
      case StampOutline.diamond:
        final outline = [
          Offset(body.center.dx, body.top),
          Offset(body.right, body.center.dy),
          Offset(body.center.dx, body.bottom),
          Offset(body.left, body.center.dy),
        ];
        final win = _insetConvex(outline, m * 1.1);
        return StampGeometry._(outline, win, _bounds(win), perf);
    }
  }

  Rect get bounds => _bounds(outline);
}

Rect _bounds(List<Offset> pts) {
  var l = double.infinity, t = double.infinity;
  var r = -double.infinity, b = -double.infinity;
  for (final p in pts) {
    l = math.min(l, p.dx);
    t = math.min(t, p.dy);
    r = math.max(r, p.dx);
    b = math.max(b, p.dy);
  }
  return Rect.fromLTRB(l, t, r, b);
}

/// 凸多角形の各辺を内側に [d] だけ平行移動した多角形（辺の交点を取り直す）。
List<Offset> _insetConvex(List<Offset> poly, double d) {
  final n = poly.length;
  // 向き（面積の符号）で内側の法線を決める。
  var area = 0.0;
  for (var i = 0; i < n; i++) {
    final a = poly[i], b = poly[(i + 1) % n];
    area += a.dx * b.dy - b.dx * a.dy;
  }
  final sign = area > 0 ? 1.0 : -1.0;
  final lines = <(Offset, Offset)>[];
  for (var i = 0; i < n; i++) {
    final a = poly[i], b = poly[(i + 1) % n];
    final e = b - a;
    final len = e.distance;
    final normal = Offset(-e.dy / len, e.dx / len) * sign;
    lines.add((a + normal * d, b + normal * d));
  }
  final out = <Offset>[];
  for (var i = 0; i < n; i++) {
    final (p1, p2) = lines[(i - 1 + n) % n];
    final (q1, q2) = lines[i];
    out.add(_intersect(p1, p2, q1, q2));
  }
  return out;
}

Offset _intersect(Offset p1, Offset p2, Offset q1, Offset q2) {
  final r = p2 - p1, s = q2 - q1;
  final denom = r.dx * s.dy - r.dy * s.dx;
  if (denom.abs() < 1e-9) return p2;
  final t = ((q1.dx - p1.dx) * s.dy - (q1.dy - p1.dy) * s.dx) / denom;
  return p1 + r * t;
}

/// 外形ごとのくり抜き済みのパス（同じ大きさ・フレームなら使い回す）。
final Map<String, Path> _pathCache = {};

Path _paperPath(StampGeometry g) {
  final key =
      '${g.outline.map((o) => '${o.dx.toStringAsFixed(1)},${o.dy.toStringAsFixed(1)}').join(';')}'
      '|${g.perforation.pitch.toStringAsFixed(2)}|${g.perforation.radius.toStringAsFixed(2)}';
  final hit = _pathCache[key];
  if (hit != null) return hit;
  if (_pathCache.length > 64) _pathCache.clear();
  return _pathCache[key] = g.perforation.cutPolygon(g.outline);
}

/// 切手を [area] に描く。[withPostmark] が偽なら消印を省く（トリミング中のプレビューなど）。
void paintStamp(
  Canvas canvas,
  Rect area,
  StampVisual v, {
  bool withPostmark = true,
  bool shadow = true,
}) {
  final g = StampGeometry.fit(area, v.shape, v.frame);
  final paper = _paperPath(g);
  final short = math.min(g.bounds.width, g.bounds.height);

  // 紙の厚み：ごく薄い影を少し右下に。
  if (shadow) {
    canvas.drawShadow(paper, const Color(0xFF000000), short * 0.012, false);
    canvas.drawPath(
      paper.shift(Offset(short * 0.004, short * 0.006)),
      Paint()
        ..color = const Color(0x22000000)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, short * 0.006),
    );
  }
  canvas.drawPath(paper, Paint()..color = v.frame.paper);

  // 縁の飾り
  _ornament(canvas, g, v.frame, short);

  // 写真
  final window = Path()..addPolygon(g.window, true);
  canvas.save();
  canvas.clipPath(window);
  final photo = v.photo;
  if (photo != null) {
    final src = v.crop.toPixels(
      photo.width.toDouble(),
      photo.height.toDouble(),
    );
    final dst = _cover(src.size, g.windowBounds);
    canvas.drawImageRect(
      photo,
      src,
      dst,
      Paint()..filterQuality = FilterQuality.medium,
    );
  } else {
    canvas.drawRect(g.windowBounds, Paint()..color = const Color(0xFFBFC4C9));
  }
  canvas.restore();

  // 写真のまわりの細い線
  canvas.drawPath(
    window,
    Paint()
      ..style = PaintingStyle.stroke
      ..color = v.frame.line
      ..strokeWidth = math.max(0.5, short * 0.006),
  );

  // 通し番号（左上）とシート名（右下）。額面に見えないよう「No.」を付け、数字だけにはしない。
  final wb = g.windowBounds;
  final small = short * 0.065;
  if (v.serial > 0) {
    _label(
      canvas,
      'No.${v.serial}',
      wb.topLeft + Offset(short * 0.035, short * 0.03),
      small,
      alignRight: false,
    );
  }
  if (v.sheetName.isNotEmpty) {
    _label(
      canvas,
      v.sheetName,
      wb.bottomRight - Offset(short * 0.035, short * 0.03 + small * 1.2),
      small * 0.85,
      alignRight: true,
      maxWidth: wb.width * 0.7,
    );
  }

  final pm = v.postmark;
  if (withPostmark && pm != null) {
    final b = g.bounds;
    final d = short * 0.46;
    paintPostmark(
      canvas,
      Offset(b.left + b.width * 0.36, b.top + b.height * 0.66),
      d,
      pm,
    );
  }
}

/// [size] の画像で [dst] を隙間なく覆う矩形。
Rect _cover(Size src, Rect dst) {
  final s = math.max(dst.width / src.width, dst.height / src.height);
  return Rect.fromCenter(
    center: dst.center,
    width: src.width * s,
    height: src.height * s,
  );
}

void _label(
  Canvas canvas,
  String text,
  Offset at,
  double size, {
  required bool alignRight,
  double? maxWidth,
}) {
  final tp = TextPainter(
    text: TextSpan(
      text: text,
      style: TextStyle(
        fontSize: size,
        color: const Color(0xF2FFFFFF),
        fontWeight: FontWeight.w600,
        fontFamily: postmarkFonts.first.families.first,
        fontFamilyFallback: postmarkFonts.first.families.skip(1).toList(),
        letterSpacing: size * 0.05,
        shadows: [
          Shadow(color: const Color(0x99000000), blurRadius: size * 0.4),
        ],
      ),
    ),
    textDirection: TextDirection.ltr,
    maxLines: 1,
    ellipsis: '…',
  )..layout(maxWidth: maxWidth ?? double.infinity);
  tp.paint(canvas, alignRight ? at - Offset(tp.width, 0) : at);
}

void _ornament(Canvas canvas, StampGeometry g, FrameSpec f, double short) {
  final paint = Paint()
    ..style = PaintingStyle.stroke
    ..color = f.line
    ..strokeWidth = math.max(0.5, short * 0.005);
  final gap = short * f.margin * 0.45;
  switch (f.ornament) {
    case FrameOrnament.none:
      return;
    case FrameOrnament.doubleLine:
      canvas.drawPath(
        Path()..addPolygon(_insetConvex(g.window, -gap), true),
        paint,
      );
    case FrameOrnament.wave:
      final ring = _insetConvex(g.window, -gap);
      final path = Path();
      for (var i = 0; i < ring.length; i++) {
        final a = ring[i], b = ring[(i + 1) % ring.length];
        final e = b - a;
        final len = e.distance;
        final n = Offset(-e.dy / len, e.dx / len);
        final waves = math.max(2, (len / (short * 0.08)).round());
        path.moveTo(a.dx, a.dy);
        for (var s = 1; s <= waves * 8; s++) {
          final t = s / (waves * 8);
          final p =
              a + e * t + n * math.sin(t * waves * 2 * math.pi) * short * 0.012;
          path.lineTo(p.dx, p.dy);
        }
      }
      canvas.drawPath(path, paint);
    case FrameOrnament.dots:
      final ring = _insetConvex(g.window, -gap);
      final dot = Paint()..color = f.line;
      final perf = Perforation(pitch: short * 0.045, radius: short * 0.008);
      for (final c in perf.centersForPolygon(ring)) {
        canvas.drawCircle(c, perf.radius, dot);
      }
    case FrameOrnament.corners:
      final ring = _insetConvex(g.window, -gap);
      final arm = short * 0.12;
      for (var i = 0; i < ring.length; i++) {
        final p = ring[i];
        final prev = ring[(i - 1 + ring.length) % ring.length];
        final next = ring[(i + 1) % ring.length];
        final toPrev = (prev - p) / (prev - p).distance;
        final toNext = (next - p) / (next - p).distance;
        canvas.drawPath(
          Path()
            ..moveTo((p + toPrev * arm).dx, (p + toPrev * arm).dy)
            ..lineTo(p.dx, p.dy)
            ..lineTo((p + toNext * arm).dx, (p + toNext * arm).dy),
          paint..strokeWidth = math.max(0.8, short * 0.01),
        );
        canvas.drawCircle(
          p + (toPrev + toNext) * (arm * 0.35),
          short * 0.012,
          Paint()..color = f.line,
        );
      }
  }
}

/// ウィジェットとして置くための CustomPainter。
class StampPainter extends CustomPainter {
  StampPainter(this.visual, {this.withPostmark = true, this.shadow = true});

  final StampVisual visual;
  final bool withPostmark;
  final bool shadow;

  @override
  void paint(Canvas canvas, Size size) {
    paintStamp(
      canvas,
      Offset.zero & size,
      visual,
      withPostmark: withPostmark,
      shadow: shadow,
    );
  }

  @override
  bool shouldRepaint(StampPainter old) =>
      old.visual != visual ||
      old.withPostmark != withPostmark ||
      old.shadow != shadow;
}
