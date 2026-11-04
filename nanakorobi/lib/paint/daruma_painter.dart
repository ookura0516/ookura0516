import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../core/rules.dart';
import '../model/models.dart';

/// だるまを描く。画像素材は持たず、[DarumaLook] だけから描く。
///
/// 座標は 600×760 の箱（台座を含む）で考え、与えられた大きさに縦横比を保って収める。
/// 筆の順番は 眉（1〜6、7で揃う）→ ひげ（8〜20、21で揃う）→ 腹の文字の縁（22〜49、50で金）
/// → 衣の模様（51〜99、100で金彩）。眉とひげの線は [DarumaLook.seed] で少し揺らし、
/// 同じだるまはいつも同じ顔になる。
class DarumaPainter extends CustomPainter {
  DarumaPainter(
    this.look, {
    this.reveal = 1.0,
    this.eyeReveal = 1.0,
    double? fallAmount,
    this.showBase = true,
    this.eyeHighlight,
  }) : fallAmount = fallAmount ?? (look.fallen ? 1.0 : 0.0);

  final DarumaLook look;

  /// いちばん新しい筆の描き具合（0〜1）。1筆入る演出に使う。
  final double reveal;

  /// いちばん新しく入れた目の描き具合（0〜1）。開眼・満願の演出に使う。
  final double eyeReveal;

  /// 転倒の度合い（0＝立っている、1＝横倒し）。起き上がりの演出に使う。
  final double fallAmount;
  final bool showBase;

  /// 開眼のなぞり中に、入れる目を淡く示す（0＝左目、1＝右目。だるまから見た左右）。
  final int? eyeHighlight;

  static const double boxWidth = 600;
  static const double boxHeight = 760;

  // 顔の中の位置（だるまから見た左目＝向かって右）。
  static const Offset leftEyeCenter = Offset(374, 276);
  static const Offset rightEyeCenter = Offset(226, 276);
  static const double eyeRadius = 46;

  /// だるまの目の中心を、描画領域の座標で返す（なぞり判定用）。
  static Offset eyeCenterIn(Size size, EyeSide side) {
    final t = _transformFor(size);
    final c = side == EyeSide.left ? leftEyeCenter : rightEyeCenter;
    return Offset(c.dx * t.scale + t.dx, c.dy * t.scale + t.dy);
  }

  static double eyeRadiusIn(Size size) => eyeRadius * _transformFor(size).scale;

  static _Transform _transformFor(Size size) {
    final scale = math.min(size.width / boxWidth, size.height / boxHeight);
    final dx = (size.width - boxWidth * scale) / 2;
    final dy = (size.height - boxHeight * scale) / 2;
    return _Transform(scale, dx, dy);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final t = _transformFor(size);
    canvas.save();
    canvas.translate(t.dx, t.dy);
    canvas.scale(t.scale);
    final palette = _Palette.of(look.color);
    final rnd = _Jitter(look.seed);

    if (showBase) _paintBase(canvas, palette);

    canvas.save();
    if (fallAmount > 0) {
      // 横倒し：台座の脇に、頭を左にして倒れる。起き上がりは逆再生。
      // 倒れた体が 600×760 の箱に収まるよう、軸を右上に寄せて少し小さく描く。
      final f = fallAmount.clamp(0.0, 1.0);
      canvas.translate(300 + 120 * f, 676 - 100 * f);
      canvas.rotate(-math.pi / 2 * 0.9 * f);
      final s = 1 - 0.4 * f;
      canvas.scale(s);
      canvas.translate(-300, -676);
    }
    _paintBody(canvas, palette, rnd);
    canvas.restore();
    canvas.restore();
  }

  // ------------------------------------------------------------ 台座

  void _paintBase(Canvas canvas, _Palette p) {
    final rr = RRect.fromRectAndRadius(const Rect.fromLTWH(104, 664, 392, 58), const Radius.circular(16));
    canvas.drawRRect(rr, Paint()..color = const Color(0xFF3A2A22));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(124, 712, 352, 24), const Radius.circular(9)),
      Paint()..color = const Color(0xFF2A1D17),
    );
    // 金の筋＝起き上がり回数。12本まで並べ、それ以上は太い1本にまとめる。
    final n = look.goldStripes;
    if (n <= 0) return;
    final gold = Paint()..color = _gold;
    final shown = math.min(n, 12);
    final span = 300.0;
    final step = shown == 1 ? 0.0 : span / (shown - 1);
    final start = shown == 1 ? 300.0 : 150.0;
    for (var i = 0; i < shown; i++) {
      final x = start + step * i;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(x - 5, 673, 10, 40), const Radius.circular(4)),
        gold,
      );
    }
    if (n > 12) {
      final tp = _text('$n', 22, _gold, bold: true);
      tp.paint(canvas, Offset(470 - tp.width / 2, 675));
    }
  }

  // ------------------------------------------------------------ 体

  void _paintBody(Canvas canvas, _Palette p, _Jitter rnd) {
    // 体
    final body = Path()
      ..moveTo(300, 30)
      ..cubicTo(402, 30, 468, 112, 490, 232)
      ..cubicTo(510, 342, 584, 442, 574, 562)
      ..cubicTo(566, 650, 470, 678, 300, 678)
      ..cubicTo(130, 678, 34, 650, 26, 562)
      ..cubicTo(16, 442, 90, 342, 110, 232)
      ..cubicTo(132, 112, 198, 30, 300, 30)
      ..close();
    canvas.drawPath(body, Paint()..color = p.body);
    canvas.drawPath(
      body,
      Paint()
        ..color = p.outline
        ..style = PaintingStyle.stroke
        ..strokeWidth = 7
        ..strokeJoin = StrokeJoin.round,
    );
    // つや
    canvas.drawPath(
      Path()
        ..moveTo(156, 118)
        ..cubicTo(196, 70, 244, 50, 290, 46),
      Paint()
        ..color = p.highlight
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round,
    );

    // 衣の模様（51〜99筆）と金彩（100筆）
    _paintRobe(canvas, p);

    // 肩の金彩
    final goldStroke = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(74, 430)
        ..relativeCubicTo(16, -30, 40, -46, 70, -54),
      goldStroke..strokeWidth = 7,
    );
    canvas.drawPath(
      Path()
        ..moveTo(526, 430)
        ..relativeCubicTo(-16, -30, -40, -46, -70, -54),
      goldStroke..strokeWidth = 7,
    );

    // 顔（金の縁取り）
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(300, 296), width: 396, height: 412),
      Paint()
        ..color = _gold
        ..style = PaintingStyle.stroke
        ..strokeWidth = 11,
    );
    canvas.drawOval(
      Rect.fromCenter(center: const Offset(300, 296), width: 368, height: 384),
      Paint()..color = p.face,
    );

    _paintBrows(canvas, p, rnd);
    _paintEyes(canvas, p);
    _paintNose(canvas);
    _paintBeard(canvas, p, rnd);
    _paintBellyText(canvas, p);
  }

  // ------------------------------------------------------------ 眉（鶴）

  /// 眉の筆：左右3本ずつ。L1 R1 L2 R2 L3 R3 の順に1〜6筆。7筆で揃う。
  static List<_Stroke> _browStrokes(_Jitter rnd) {
    final j = rnd.values(12, 4);
    List<_Stroke> side(bool left) {
      final s = left ? 1.0 : -1.0;
      Offset m(double x, double y, int k) => Offset(300 + s * (x - 300) + j[k], y + j[k + 1]);
      return [
        _Stroke([m(150, 246, 0), m(190, 214, 2), m(228, 202, 4)], 15),
        _Stroke([m(214, 206, 6), m(256, 196, 8), m(296, 204, 10)], 14),
        _Stroke([m(166, 236, 2), m(212, 224, 6), m(262, 212, 0)], 11),
      ];
    }
    final l = side(true);
    final r = side(false);
    return [l[0], r[0], l[1], r[1], l[2], r[2]];
  }

  void _paintBrows(Canvas canvas, _Palette p, _Jitter rnd) {
    final ink = Paint()
      ..color = p.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final n = look.brushCount;
    if (n >= Rules.browsMilestone) {
      final j = rnd.values(4, 5);
      final fill = Paint()..color = p.ink;
      final isNew = n == Rules.browsMilestone;
      if (isNew) fill.color = p.ink.withValues(alpha: reveal);
      // 鶴の翼のような太い眉。
      canvas.drawPath(
        Path()
          ..moveTo(132 + j[0], 256)
          ..quadraticBezierTo(206, 148 + j[1], 300, 204)
          ..quadraticBezierTo(232, 186, 174 + j[2], 240)
          ..quadraticBezierTo(152, 262, 132 + j[0], 256)
          ..close(),
        fill,
      );
      canvas.drawPath(
        Path()
          ..moveTo(468 - j[3], 256)
          ..quadraticBezierTo(394, 148 + j[1], 300, 204)
          ..quadraticBezierTo(368, 186, 426 - j[2], 240)
          ..quadraticBezierTo(448, 262, 468 - j[3], 256)
          ..close(),
        fill,
      );
      return;
    }
    final strokes = _browStrokes(rnd);
    for (var i = 0; i < n && i < strokes.length; i++) {
      final s = strokes[i];
      final frac = i == n - 1 ? reveal : 1.0;
      _drawStroke(canvas, s, ink..strokeWidth = s.width, frac);
    }
  }

  // ------------------------------------------------------------ ひげ（亀）

  /// ひげの筆：13本。8〜20筆で1本ずつ、21筆で揃う。
  static List<_Stroke> _beardStrokes(_Jitter rnd) {
    final j = rnd.values(16, 4, offset: 20);
    Offset o(double x, double y, int k) => Offset(x + j[k % 16], y + j[(k + 1) % 16]);
    return [
      _Stroke([o(296, 350, 0), o(268, 338, 2), o(216, 360, 4)], 11), // 口ひげ 左
      _Stroke([o(304, 350, 0), o(332, 338, 2), o(384, 360, 4)], 11), // 口ひげ 右
      _Stroke([o(150, 340, 6), o(156, 400, 8), o(206, 440, 10)], 16), // 頬 左1
      _Stroke([o(450, 340, 6), o(444, 400, 8), o(394, 440, 10)], 16), // 頬 右1
      _Stroke([o(166, 384, 12), o(188, 420, 14), o(228, 450, 1)], 11), // 頬 左2
      _Stroke([o(434, 384, 12), o(412, 420, 14), o(372, 450, 1)], 11), // 頬 右2
      _Stroke([o(262, 474, 3), o(300, 486, 5), o(338, 474, 7)], 10), // あご 中
      _Stroke([o(206, 440, 10), o(234, 456, 9), o(262, 462, 11)], 14), // 頬 左3
      _Stroke([o(394, 440, 10), o(366, 456, 9), o(338, 462, 11)], 14), // 頬 右3
      _Stroke([o(232, 470, 13), o(248, 480, 15), o(268, 484, 2)], 10), // あご 左
      _Stroke([o(368, 470, 13), o(352, 480, 15), o(332, 484, 2)], 10), // あご 右
      _Stroke([o(186, 356, 4), o(200, 392, 6), o(236, 424, 8)], 9), // 頬 左4
      _Stroke([o(414, 356, 4), o(400, 392, 6), o(364, 424, 8)], 9), // 頬 右4
    ];
  }

  void _paintBeard(Canvas canvas, _Palette p, _Jitter rnd) {
    final n = look.brushCount - Rules.browsMilestone; // 8筆目が1本目
    if (n <= 0) return;
    final strokes = _beardStrokes(rnd);
    final complete = look.beardComplete;
    final ink = Paint()
      ..color = p.ink
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final shown = math.min(n, strokes.length);
    for (var i = 0; i < shown; i++) {
      final s = strokes[i];
      final isNew = !complete && i == shown - 1;
      final width = complete ? s.width + 2 : s.width;
      _drawStroke(canvas, s, ink..strokeWidth = width, isNew ? reveal : 1.0);
    }
    if (complete && look.brushCount == Rules.beardMilestone) {
      // 揃った演出：あご全体に薄い輪郭を足す。
      canvas.drawPath(
        Path()
          ..moveTo(232, 470)
          ..cubicTo(256, 486, 344, 486, 368, 470),
        ink
          ..strokeWidth = 10
          ..color = p.ink.withValues(alpha: reveal),
      );
    }
  }

  // ------------------------------------------------------------ 目・鼻

  void _paintEyes(Canvas canvas, _Palette p) {
    final ring = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final outline = Paint()
      ..color = p.ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7;
    final white = Paint()..color = Colors.white;
    void eye(Offset c, bool painted, bool highlight, {bool newest = false}) {
      canvas.drawCircle(c, 54, ring);
      canvas.drawCircle(c, eyeRadius, white);
      canvas.drawCircle(c, eyeRadius, outline);
      if (painted) {
        final r = newest ? 33 * eyeReveal.clamp(0.0, 1.0) : 33.0;
        if (r > 0) {
          canvas.drawCircle(c, r, Paint()..color = p.ink);
          if (r > 20) canvas.drawCircle(c.translate(12, -14), 9 * (r / 33), white);
        }
      } else if (highlight) {
        canvas.drawCircle(
          c,
          33,
          Paint()
            ..color = p.ink.withValues(alpha: 0.12)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 3,
        );
      }
    }
    final first = look.eyeSide; // 最初に入れる目
    final second = first == EyeSide.left ? EyeSide.right : EyeSide.left;
    final firstPainted = look.openedEyes >= 1;
    final secondPainted = look.openedEyes >= 2;
    eye(_center(first), firstPainted, eyeHighlight == _index(first), newest: look.openedEyes == 1);
    eye(_center(second), secondPainted, eyeHighlight == _index(second), newest: look.openedEyes == 2);
  }

  static Offset _center(EyeSide s) => s == EyeSide.left ? leftEyeCenter : rightEyeCenter;
  static int _index(EyeSide s) => s == EyeSide.left ? 0 : 1;

  void _paintNose(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(300, 318)
        ..relativeCubicTo(-10, 12, -14, 22, -4, 28)
        ..relativeCubicTo(10, -6, 6, -16, -4, -28),
      Paint()
        ..color = const Color(0xFF9A5B3C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  // ------------------------------------------------------------ 腹の文字

  void _paintBellyText(Canvas canvas, _Palette p) {
    final chars = look.text.trim().runes.map(String.fromCharCode).toList();
    if (chars.isEmpty) return;
    final n = chars.length;
    // 4字までは1列（上から 500〜660 に収める）。5〜6字は右から2列。
    final twoColumns = n >= 5;
    final perColumn = twoColumns ? (n + 1) ~/ 2 : n;
    final fontSize = switch (perColumn) { 1 => 80.0, 2 => 74.0, 3 => 50.0, _ => 38.0 };
    final lineGap = fontSize * 1.04;
    final top = 500.0 + (160 - perColumn * lineGap) / 2;
    final columns = twoColumns
        ? [chars.sublist(0, perColumn), chars.sublist(perColumn)]
        : [chars];
    final columnX = twoColumns ? [300.0 + fontSize * 0.62, 300.0 - fontSize * 0.62] : [300.0];
    final brush = look.brushCount;
    final outlineProgress = brush <= Rules.beardMilestone
        ? 0.0
        : math.min(1.0, (brush - Rules.beardMilestone) / (Rules.goldTextMilestone - Rules.beardMilestone - 1));
    final goldFill = look.goldText;
    final fillColor = goldFill ? _gold : p.textOnBody;
    final isNewGold = brush == Rules.goldTextMilestone;
    for (var col = 0; col < columns.length; col++) {
      final cx = columnX[col];
      final column = columns[col];
      for (var i = 0; i < column.length; i++) {
        final y = top + i * lineGap;
        if (outlineProgress > 0 && !goldFill) {
          final w = 1.0 + 4.0 * outlineProgress * (brush == Rules.beardMilestone + 1 ? reveal : 1.0);
          final tpOutline = _text(
            column[i],
            fontSize,
            _gold,
            family: 'YujiSyuku',
            foreground: Paint()
              ..color = _gold
              ..style = PaintingStyle.stroke
              ..strokeWidth = w,
          );
          tpOutline.paint(canvas, Offset(cx - tpOutline.width / 2, y));
        }
        final tp = _text(
          column[i],
          fontSize,
          isNewGold ? Color.lerp(p.textOnBody, _gold, reveal)! : fillColor,
          family: 'YujiSyuku',
        );
        tp.paint(canvas, Offset(cx - tp.width / 2, y));
      }
    }
  }

  // ------------------------------------------------------------ 衣の模様

  /// 51〜99筆で小さな金の模様が1つずつ、100筆で裾に金彩。
  void _paintRobe(Canvas canvas, _Palette p) {
    final n = look.brushCount - Rules.goldTextMilestone;
    if (n <= 0) return;
    final gold = Paint()
      ..color = _gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    final shown = math.min(n, _robeSlots.length);
    for (var i = 0; i < shown; i++) {
      final c = _robeSlots[i];
      final isNew = !look.goldRobe && i == shown - 1;
      final paint = isNew ? (Paint()..color = _gold.withValues(alpha: reveal)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round) : gold;
      // 小さな波（七宝のかけら）。
      canvas.drawPath(
        Path()
          ..moveTo(c.dx - 10, c.dy)
          ..quadraticBezierTo(c.dx - 5, c.dy - 8, c.dx, c.dy)
          ..quadraticBezierTo(c.dx + 5, c.dy + 8, c.dx + 10, c.dy),
        paint,
      );
    }
    if (look.goldRobe) {
      final a = look.brushCount == Rules.goldRobeMilestone ? reveal : 1.0;
      canvas.drawPath(
        Path()
          ..moveTo(70, 600)
          ..cubicTo(170, 640, 430, 640, 530, 600),
        Paint()
          ..color = _gold.withValues(alpha: a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 9
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  /// 衣の模様の置き場（49か所）。顔と文字を避け、体の下半分に並べる。
  static final List<Offset> _robeSlots = _makeRobeSlots();

  static List<Offset> _makeRobeSlots() {
    final slots = <Offset>[];
    const rows = [
      (y: 470.0, xs: [96.0, 504.0]),
      (y: 500.0, xs: [84.0, 140.0, 460.0, 516.0]),
      (y: 530.0, xs: [76.0, 130.0, 184.0, 416.0, 470.0, 524.0]),
      (y: 560.0, xs: [72.0, 126.0, 180.0, 234.0, 366.0, 420.0, 474.0, 528.0]),
      (y: 590.0, xs: [84.0, 138.0, 192.0, 246.0, 354.0, 408.0, 462.0, 516.0]),
      (y: 620.0, xs: [110.0, 164.0, 218.0, 382.0, 436.0, 490.0]),
      (y: 644.0, xs: [150.0, 204.0, 258.0, 342.0, 396.0, 450.0]),
      (y: 440.0, xs: [112.0, 488.0]),
      (y: 410.0, xs: [126.0, 474.0]),
      (y: 380.0, xs: [112.0, 488.0]),
      (y: 350.0, xs: [100.0, 500.0]),
      (y: 320.0, xs: [92.0, 508.0]),
      (y: 290.0, xs: [90.0, 510.0]),
    ];
    for (final r in rows) {
      for (final x in r.xs) {
        slots.add(Offset(x, r.y));
      }
    }
    return slots.take(49).toList();
  }

  // ------------------------------------------------------------ 道具

  void _drawStroke(Canvas canvas, _Stroke s, Paint paint, double frac) {
    final path = Path()..moveTo(s.points[0].dx, s.points[0].dy);
    path.quadraticBezierTo(s.points[1].dx, s.points[1].dy, s.points[2].dx, s.points[2].dy);
    if (frac >= 1) {
      canvas.drawPath(path, paint);
      return;
    }
    if (frac <= 0) return;
    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * frac), paint);
    }
  }

  static TextPainter _text(
    String s,
    double size,
    Color color, {
    String? family,
    bool bold = false,
    Paint? foreground,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: s,
        style: TextStyle(
          color: foreground == null ? color : null,
          foreground: foreground,
          fontSize: size,
          fontFamily: family,
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          height: 1.0,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return tp;
  }

  static const Color _gold = Color(0xFFE2B94E);

  @override
  bool shouldRepaint(DarumaPainter old) =>
      old.look != look ||
      old.reveal != reveal ||
      old.eyeReveal != eyeReveal ||
      old.fallAmount != fallAmount ||
      old.showBase != showBase ||
      old.eyeHighlight != eyeHighlight;
}

class _Transform {
  const _Transform(this.scale, this.dx, this.dy);
  final double scale;
  final double dx;
  final double dy;
}

class _Stroke {
  const _Stroke(this.points, this.width);
  final List<Offset> points;
  final double width;
}

/// 決定的な揺らぎ。だるまの id を種にして、同じだるまはいつも同じ顔にする。
class _Jitter {
  _Jitter(int seed) : _state = (seed & 0x7fffffff) + 1;

  int _state;

  double _next() {
    // 32ビットの xorshift。
    var x = _state;
    x ^= (x << 13) & 0xffffffff;
    x ^= x >> 17;
    x ^= (x << 5) & 0xffffffff;
    _state = x;
    return (x & 0xffff) / 0xffff;
  }

  /// [-amp, amp] の値を n 個。
  List<double> values(int n, double amp, {int offset = 0}) {
    for (var i = 0; i < offset; i++) {
      _next();
    }
    return List.generate(n, (_) => (_next() * 2 - 1) * amp);
  }
}

class _Palette {
  const _Palette({
    required this.body,
    required this.outline,
    required this.highlight,
    required this.face,
    required this.ink,
    required this.textOnBody,
  });

  final Color body;
  final Color outline;
  final Color highlight;
  final Color face;
  final Color ink;
  final Color textOnBody;

  static _Palette of(DarumaColor c) => switch (c) {
        DarumaColor.red => const _Palette(
            body: Color(0xFFC3262A),
            outline: Color(0xFF7A1414),
            highlight: Color(0xBFE25C53),
            face: Color(0xFFF5E8D2),
            ink: Color(0xFF1C1C1C),
            textOnBody: Color(0xFF1C1C1C),
          ),
        DarumaColor.white => const _Palette(
            body: Color(0xFFF4EFE6),
            outline: Color(0xFFB9AE9C),
            highlight: Color(0xBFFFFFFF),
            face: Color(0xFFFBF4E8),
            ink: Color(0xFF1C1C1C),
            textOnBody: Color(0xFF8E1F22),
          ),
        DarumaColor.black => const _Palette(
            body: Color(0xFF2B2B2E),
            outline: Color(0xFF0F0F10),
            highlight: Color(0x80707076),
            face: Color(0xFFF5E8D2),
            ink: Color(0xFF1C1C1C),
            textOnBody: Color(0xFFF5E8D2),
          ),
      };
}

/// [DarumaLook] を PNG にする（ウィジェットと共有画像用）。
Future<ui.Image> rasterizeDaruma(DarumaLook look, {double width = 600, double height = 760}) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  DarumaPainter(look).paint(canvas, Size(width, height));
  final picture = recorder.endRecording();
  return picture.toImage(width.round(), height.round());
}
