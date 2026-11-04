import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/daruma_colors.dart';
import '../../core/rng.dart';
import '../../core/strokes.dart';
import '../../model/models.dart';

/// だるまを描く。画像素材は持たず、すべて線と面で描く。
///
/// 描くもの：体（色）、顔、目（開眼の状態）、眉（鶴の羽の線）、ひげ（亀の甲の線）、
/// 腹の文字（縦書き）、腹の文字の縁、衣の模様、台座と金の筋、大きさの段階、転倒。
/// 眉とひげの線は [DarumaLook.seed] を種にした決定的な乱数で少し揺らし、
/// 同じだるまはいつも同じ顔になる。
///
/// 座標は幅 100・高さ 125 の箱で考え、与えられた大きさに収めて描く。
class DarumaPainter extends CustomPainter {
  DarumaPainter({
    required this.look,
    this.fallProgress = 0,
    this.newStrokeProgress = 1,
    this.highlightEye,
    this.brushFontFamily,
    this.showBase = true,
    this.textScale = 1,
  }) : _jitter = _Jitter(look.seed);

  final DarumaLook look;

  /// 0 = 立っている、1 = 横倒し。
  final double fallProgress;

  /// いちばん新しい筆の描き進み（0〜1）。1 で描き切り。
  final double newStrokeProgress;

  /// 開眼のとき、入れる目を光らせる。
  final EyeSide? highlightEye;

  /// 毛筆体のフォント。null なら端末のフォント。
  final String? brushFontFamily;
  final bool showBase;
  final double textScale;

  final _Jitter _jitter;

  static const boxWidth = 100.0;
  static const boxHeight = 125.0;
  static const aspectRatio = boxWidth / boxHeight;

  static const _gold = Color(0xFFC9A227);
  static const _goldLight = Color(0xFFE8C867);
  static const _ink = Color(0xFF1B1A1E);
  static const _baseColor = Color(0xFF3B2A1E);
  static const _baseTop = Color(0xFF55402E);

  // ------------------------------------------------------------ 形

  /// 体。上がやや細く、下がどっしりした形。
  static Path bodyPath() => Path()
    ..moveTo(50, 6)
    ..cubicTo(78, 6, 94, 36, 94, 66)
    ..cubicTo(94, 86, 86, 104, 72, 108)
    ..lineTo(28, 108)
    ..cubicTo(14, 104, 6, 86, 6, 66)
    ..cubicTo(6, 36, 22, 6, 50, 6)
    ..close();

  /// 顔。
  static Path facePath() => Path()
    ..moveTo(50, 17)
    ..cubicTo(68, 17, 76, 30, 76, 44)
    ..cubicTo(76, 60, 66, 70, 50, 72)
    ..cubicTo(34, 70, 24, 60, 24, 44)
    ..cubicTo(24, 30, 32, 17, 50, 17)
    ..close();

  static const eyeRadius = 7.2;
  static const pupilRadius = 5.0;

  /// 目の中心。[EyeSide.left] はだるまの左目＝向かって右。
  static Offset eyeCenter(EyeSide side) =>
      side == EyeSide.left ? const Offset(62, 42) : const Offset(38, 42);

  static const bellyCenter = Offset(50, 88);

  // ------------------------------------------------------------ 描く

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(size.width / boxWidth, size.height / boxHeight);
    final dx = (size.width - boxWidth * scale) / 2;
    final dy = (size.height - boxHeight * scale) / 2;
    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    if (showBase) _paintBase(canvas);

    // 転倒：体の中心を軸に倒し、台座の上に寝かせる。
    final t = fallProgress.clamp(0.0, 1.0);
    if (t > 0) {
      final angle = t * math.pi / 2 * 0.96 * (look.firstEye == EyeSide.left ? 1 : -1);
      const pivot = Offset(50, 57);
      canvas.translate(0, 8 * t);
      canvas.translate(pivot.dx, pivot.dy);
      canvas.rotate(angle);
      canvas.translate(-pivot.dx, -pivot.dy);
    }

    _paintBody(canvas);
    _paintRobe(canvas);
    _paintFace(canvas);
    _paintBelly(canvas);
    _paintEyes(canvas);
    _paintEyebrows(canvas);
    _paintBeard(canvas);

    canvas.restore();
  }

  DarumaColor get _color => DarumaColor.byId(look.colorId);

  Color get _lineOnBody => _color.isLight ? Color(_color.shade) : const Color(0xFFF3E8D2);

  /// 金の文字と縁。白・黄・金などの明るい体では、沈まないよう濃い金にする。
  Color get _goldOnBody => _color.isLight ? const Color(0xFF9A7A14) : _gold;

  void _paintBase(Canvas canvas) {
    final rect = RRect.fromRectAndRadius(const Rect.fromLTWH(20, 108, 60, 13), const Radius.circular(4));
    final n = look.goldLines;
    // 転ぶほど台座が金になる。10本を超えたら地の色も金に寄せる。
    final blend = ((n - 10) / 20).clamp(0.0, 1.0);
    canvas.drawRRect(rect, Paint()..color = Color.lerp(_baseColor, _gold, blend * 0.6)!);
    canvas.drawRect(
      const Rect.fromLTWH(20, 108, 60, 3),
      Paint()..color = Color.lerp(_baseTop, _goldLight, blend * 0.6)!,
    );
    final lines = math.min(n, 10);
    if (lines > 0) {
      final paint = Paint()
        ..color = _gold
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round;
      final gap = 56 / (lines + 1);
      for (var i = 0; i < lines; i++) {
        final x = 22 + gap * (i + 1);
        final j = _jitter.at(190 + i) * 0.6;
        canvas.drawLine(Offset(x + j, 112), Offset(x - j, 119.5), paint);
      }
    }
  }

  void _paintBody(Canvas canvas) {
    final body = bodyPath();
    final c = _color;
    // 影。
    canvas.drawPath(
      body.shift(const Offset(0, 1.2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.12)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawPath(
      body,
      Paint()
        ..shader = ui.Gradient.radial(
          const Offset(40, 40),
          95,
          [Color.lerp(Color(c.body), Colors.white, 0.18)!, Color(c.body), Color(c.shade)],
          const [0.0, 0.55, 1.0],
        ),
    );
    canvas.drawPath(
      body,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.6
        ..color = Color(c.shade),
    );
    // 100筆：衣に金彩（体の縁に金の線）。
    if (look.goldRobe) {
      canvas.drawPath(
        body,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..color = _gold.withValues(alpha: 0.9),
      );
    }
  }

  void _paintFace(Canvas canvas) {
    final face = facePath();
    canvas.drawPath(face, Paint()..color = Color(_color.face));
    canvas.drawPath(
      face,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = Color(_color.shade).withValues(alpha: 0.8),
    );
    // 鼻と口。いつも同じ。
    final ink = Paint()
      ..color = _ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(50, 48)
        ..quadraticBezierTo(51.5, 52, 50, 55),
      ink,
    );
    canvas.drawPath(
      Path()
        ..moveTo(45.5, 60)
        ..quadraticBezierTo(50, 62.5 + _jitter.at(0) * 1.2, 54.5, 60),
      ink..strokeWidth = 1.5,
    );
  }

  void _paintEyes(Canvas canvas) {
    for (final side in EyeSide.values) {
      final c = eyeCenter(side);
      final open = switch (look.eyes) {
        EyeState.none => false,
        EyeState.one => side == look.firstEye,
        EyeState.both => true,
      };
      if (highlightEye == side) {
        canvas.drawCircle(
          c,
          eyeRadius + 3,
          Paint()
            ..color = _goldLight.withValues(alpha: 0.55)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
        );
      }
      canvas.drawCircle(c, eyeRadius, Paint()..color = Colors.white);
      canvas.drawCircle(
        c,
        eyeRadius,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = open ? 1.3 : 0.9
          ..color = open ? _ink : _ink.withValues(alpha: 0.35),
      );
      if (open) {
        canvas.drawCircle(c, pupilRadius, Paint()..color = _ink);
        canvas.drawCircle(c + const Offset(-1.6, -1.8), 1.3, Paint()..color = Colors.white.withValues(alpha: 0.85));
      }
    }
  }

  /// 眉：鶴の羽。左右の主線のあと、羽の線が交互に増える（7筆）。
  void _paintEyebrows(Canvas canvas) {
    final count = StrokePlan.eyebrowCount(look.strokes);
    for (var i = 0; i < count; i++) {
      _drawStroke(canvas, _eyebrowStroke(i), _strokeProgressFor(i + 1), _ink, 2.6 - (i >= 2 ? 0.8 : 0));
    }
  }

  Path _eyebrowStroke(int i) {
    final j = _jitter;
    if (i < 2) {
      // 主線。i=0 は向かって左、i=1 は向かって右。
      final m = i == 0 ? -1.0 : 1.0;
      final lift = j.at(1 + i) * 1.5;
      return Path()
        ..moveTo(50 + m * 8, 34 + j.at(3 + i))
        ..cubicTo(50 + m * 16, 28 + lift, 50 + m * 24, 28 + lift, 50 + m * 29, 33 + j.at(5 + i));
    }
    // 羽の線：主線の上に、外側へ跳ねる短い線。
    final k = i - 2; // 0..4
    final m = k.isEven ? -1.0 : 1.0;
    final n = k ~/ 2; // 0,0,1,1,2
    final x = 50 + m * (13 + n * 5.5);
    final y = 30.5 - n * 0.6 + j.at(10 + k) * 0.8;
    return Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(x + m * 2.5, y - 3.5 + j.at(20 + k) * 0.7, x + m * 5.5, y - 5.5);
  }

  /// ひげ：亀の甲のように頬から外へ広がる線。左右交互に増える（14筆）。
  void _paintBeard(Canvas canvas) {
    final count = StrokePlan.beardCount(look.strokes);
    for (var i = 0; i < count; i++) {
      _drawStroke(
        canvas,
        _beardStroke(i),
        _strokeProgressFor(StrokePlan.eyebrowEnd + i + 1),
        _ink,
        1.8,
      );
    }
  }

  Path _beardStroke(int i) {
    final j = _jitter;
    final m = i.isEven ? -1.0 : 1.0;
    final n = i ~/ 2; // 0..6
    final sx = 50 + m * (7 + n * 0.9);
    final sy = 50 + n * 2.4 + j.at(30 + i) * 0.6;
    final ex = 50 + m * (15 + n * 2.4);
    final ey = 55 + n * 3.0 + j.at(45 + i) * 0.9;
    return Path()
      ..moveTo(sx, sy)
      ..quadraticBezierTo(sx + m * 6, sy - 1.5 + j.at(60 + i) * 1.2, ex, ey);
  }

  /// 腹の文字（縦書き）と、その縁（29筆）。50筆で文字が金になる。
  void _paintBelly(Canvas canvas) {
    final text = look.text;
    if (text.isNotEmpty) {
      final chars = text.characters.toList();
      final n = chars.length;
      final fontSize = switch (n) {
            1 => 16.0,
            2 => 13.0,
            3 => 10.5,
            4 => 8.5,
            _ => 7.0,
          } *
          textScale;
      final lineHeight = fontSize * 1.05;
      final total = lineHeight * n;
      var y = bellyCenter.dy - total / 2;
      final color = look.goldText ? _goldOnBody : (_color.isLight ? _ink : const Color(0xFFF7EFDF));
      for (final ch in chars) {
        final tp = TextPainter(
          text: TextSpan(
            text: ch,
            style: TextStyle(
              fontFamily: brushFontFamily,
              fontSize: fontSize,
              // 毛筆体（Yuji Syuku）は Regular だけなので太字を指定しない。端末のフォントで描くときは太く。
              fontWeight: brushFontFamily == null ? FontWeight.w800 : FontWeight.w400,
              color: color,
              height: 1,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(bellyCenter.dx - tp.width / 2, y + (lineHeight - tp.height) / 2));
        y += lineHeight;
      }
    }

    final count = StrokePlan.bellyCount(look.strokes);
    if (count == 0) return;
    final ring = Path()..addOval(Rect.fromCenter(center: bellyCenter, width: 34, height: 40));
    final metric = ring.computeMetrics().first;
    final seg = metric.length / StrokePlan.bellyStrokes;
    final color = look.goldText ? _goldOnBody : _lineOnBody;
    for (var i = 0; i < count; i++) {
      final start = seg * i + 0.8 + _jitter.at(80 + i) * 0.5;
      final end = seg * (i + 1) - 0.8;
      final piece = metric.extractPath(start, end);
      _drawStroke(canvas, piece, _strokeProgressFor(StrokePlan.beardEnd + i + 1), color, 1.5);
    }
  }

  /// 衣の模様（51筆〜）。腹の縁の外側に、環状に短い筆を置く。100筆で金になる。
  void _paintRobe(Canvas canvas) {
    final count = StrokePlan.robeCount(look.strokes);
    if (count == 0) return;
    canvas.save();
    canvas.clipPath(bodyPath());
    final face = facePath();
    final color = look.goldRobe ? _goldOnBody : _lineOnBody.withValues(alpha: 0.85);
    for (var i = 0; i < count; i++) {
      final p = _robeMark(i);
      if (p == null) continue;
      if (face.contains(p.$1)) continue;
      final path = Path()
        ..moveTo(p.$1.dx, p.$1.dy)
        ..quadraticBezierTo(p.$2.dx, p.$2.dy, p.$3.dx, p.$3.dy);
      _drawStroke(canvas, path, _strokeProgressFor(StrokePlan.bellyEnd + i + 1), color, 1.3);
    }
    canvas.restore();
  }

  /// i 番目の衣の筆の位置。腹を囲む環を外へ重ねていく。
  (Offset, Offset, Offset)? _robeMark(int i) {
    const perRing = 12;
    final ring = i ~/ perRing;
    final idx = i % perRing;
    final radiusX = 24.0 + ring * 5.0;
    final radiusY = 27.0 + ring * 5.0;
    if (radiusX > 60) return null;
    final offset = ring.isEven ? 0.0 : math.pi / perRing;
    final angle = offset + idx * (2 * math.pi / perRing) + _jitter.at(110 + i) * 0.05;
    final c = Offset(
      bellyCenter.dx + radiusX * math.cos(angle),
      bellyCenter.dy + radiusY * math.sin(angle),
    );
    if (c.dy < 60) return null;
    // 中心に向かう短い筆。
    final dir = Offset(math.cos(angle), math.sin(angle));
    final start = c - dir * 1.6;
    final end = c + dir * 1.6;
    final ctrl = c + Offset(-dir.dy, dir.dx) * (0.8 + _jitter.at(150 + i) * 0.4);
    return (start, ctrl, end);
  }

  // ------------------------------------------------------------ 筆

  /// n 筆目（1始まり）をどこまで描くか。最新の筆だけ [newStrokeProgress] に従う。
  double _strokeProgressFor(int strokeIndex) =>
      strokeIndex == look.strokes ? newStrokeProgress.clamp(0.0, 1.0) : 1.0;

  void _drawStroke(Canvas canvas, Path path, double progress, Color color, double width) {
    if (progress <= 0) return;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = width
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    if (progress >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    for (final m in path.computeMetrics()) {
      canvas.drawPath(m.extractPath(0, m.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(DarumaPainter old) =>
      old.look != look ||
      old.fallProgress != fallProgress ||
      old.newStrokeProgress != newStrokeProgress ||
      old.highlightEye != highlightEye ||
      old.brushFontFamily != brushFontFamily ||
      old.showBase != showBase ||
      old.textScale != textScale;
}

/// 種から決まる揺らぎの列。同じ種なら同じ顔。
class _Jitter {
  _Jitter(int seed) {
    final rng = DeterministicRng(seed);
    _values = List.generate(256, (_) => rng.jitter(1.0));
  }

  late final List<double> _values;

  /// -1〜1。
  double at(int i) => _values[i % _values.length];
}
