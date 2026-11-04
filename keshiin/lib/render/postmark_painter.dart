import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import '../core/day_slots.dart';
import '../core/frames.dart';
import '../core/postmark_jitter.dart';
import '../core/rng.dart';

/// 消印に描く中身。
class PostmarkData {
  const PostmarkData({
    required this.date,
    required this.place,
    required this.note,
    required this.seed,
    this.fontId = 'gothic',
  });

  final Day date;
  final String place;
  final String note;
  final int seed;
  final String fontId;
}

const Color inkColor = Color(0xFF26303F);

/// 消印を描く。[center] は基準位置、[diameter] は外側の円の直径。
///
/// 二重の円の間に場所（上の円弧）と一言（下の円弧）、内側に日付、右に波線。
/// 位置・角度・かすれは [PostmarkData.seed] だけから決まる。
void paintPostmark(
  Canvas canvas,
  Offset center,
  double diameter,
  PostmarkData data,
) {
  final j = PostmarkJitter.fromSeed(data.seed);
  final font = postmarkFontById(data.fontId);
  final c = center + Offset(j.dx, j.dy) * diameter;
  final outerR = diameter / 2;
  final innerR = outerR * 0.64;
  final ink = inkColor.withValues(alpha: j.inkStrength);

  final waveLen = diameter * 0.95;
  final bounds = Rect.fromLTRB(
    c.dx - outerR * 1.6,
    c.dy - outerR * 1.6,
    c.dx + outerR + waveLen + outerR,
    c.dy + outerR * 1.6,
  );

  canvas.saveLayer(bounds, Paint());
  canvas.translate(c.dx, c.dy);
  canvas.rotate(j.angle);

  final stroke = Paint()
    ..style = PaintingStyle.stroke
    ..color = ink
    ..isAntiAlias = true;

  // 二重の円
  canvas.drawCircle(
    Offset.zero,
    outerR,
    stroke..strokeWidth = diameter * 0.034,
  );
  canvas.drawCircle(
    Offset.zero,
    innerR,
    stroke..strokeWidth = diameter * 0.022,
  );

  // 円弧に沿った文字
  final ringMid = (outerR + innerR) / 2;
  final ringFont = (outerR - innerR) * 0.62;
  if (data.place.isNotEmpty) {
    _arcText(canvas, data.place, ringMid, ringFont, font, ink, top: true);
  }
  if (data.note.isNotEmpty) {
    _arcText(canvas, data.note, ringMid, ringFont * 0.9, font, ink, top: false);
  }

  // 内側：日付と上下の横線
  final dateText = data.date.dotted;
  final dateStyle = _style(font, ink, innerR * 0.36);
  final tp = TextPainter(
    text: TextSpan(text: dateText, style: dateStyle),
    textDirection: TextDirection.ltr,
  )..layout();
  final maxW = innerR * 1.72;
  final scale = tp.width > maxW ? maxW / tp.width : 1.0;
  canvas.save();
  canvas.scale(scale, 1);
  tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
  canvas.restore();
  final barY = innerR * 0.42;
  final barHalf = innerR * 0.78;
  final bar = Paint()
    ..color = ink
    ..strokeWidth = diameter * 0.018;
  canvas.drawLine(Offset(-barHalf, -barY), Offset(barHalf, -barY), bar);
  canvas.drawLine(Offset(-barHalf, barY), Offset(barHalf, barY), bar);

  // 右の波線
  final wave = Paint()
    ..style = PaintingStyle.stroke
    ..color = ink
    ..strokeWidth = diameter * 0.026
    ..strokeCap = StrokeCap.round;
  const lines = 5;
  final gap = diameter * 0.15;
  final start = outerR * 1.12;
  final amp = diameter * 0.035;
  for (var i = 0; i < lines; i++) {
    final y = (i - (lines - 1) / 2) * gap;
    final path = Path()..moveTo(start, y);
    const steps = 24;
    for (var s = 1; s <= steps; s++) {
      final x = start + waveLen * s / steps;
      path.lineTo(x, y + math.sin(s / steps * math.pi * 4) * amp);
    }
    canvas.drawPath(path, wave);
  }

  // インクのかすれ：シードから決まる位置で、小さな点と擦れを抜く。
  _scuff(canvas, data.seed, outerR, waveLen);

  canvas.restore();
}

void _scuff(Canvas canvas, int seed, double r, double waveLen) {
  final rng = SeededRng(seed ^ 0x5bd1e995);
  final erase = Paint()..blendMode = BlendMode.dstOut;
  final w = r * 2 + waveLen + r * 0.3;
  // 細かい点
  for (var i = 0; i < 260; i++) {
    final x = rng.range(-r * 1.1, -r * 1.1 + w);
    final y = rng.range(-r * 1.1, r * 1.1);
    final rad = rng.range(0.004, 0.022) * r * 2;
    erase.color = Color.fromRGBO(0, 0, 0, rng.range(0.35, 1));
    canvas.drawCircle(Offset(x, y), rad, erase);
  }
  // 押しの弱いところ（大きくて薄い抜け）
  for (var i = 0; i < 3; i++) {
    final x = rng.range(-r, r + waveLen * 0.6);
    final y = rng.range(-r, r);
    final rad = rng.range(0.25, 0.5) * r;
    erase.color = Color.fromRGBO(0, 0, 0, rng.range(0.18, 0.4));
    canvas.drawCircle(Offset(x, y), rad, erase);
  }
}

TextStyle _style(PostmarkFont f, Color color, double size) => TextStyle(
  color: color,
  fontSize: size,
  fontWeight: f.weight,
  fontFamily: f.families.first,
  fontFamilyFallback: f.families.skip(1).toList(),
  height: 1.0,
);

/// 文字を1字ずつ回して円弧に並べる。[top] なら上の弧（左から右）、
/// 偽なら下の弧（同じく左から右に読めるように内向きにする）。
void _arcText(
  Canvas canvas,
  String text,
  double radius,
  double size,
  PostmarkFont font,
  Color color, {
  required bool top,
}) {
  final chars = [for (final r in text.runes) String.fromCharCode(r)];
  if (chars.isEmpty) return;
  var fontSize = size;
  List<TextPainter> layout(double fs) => [
    for (final ch in chars)
      TextPainter(
        text: TextSpan(text: ch, style: _style(font, color, fs)),
        textDirection: TextDirection.ltr,
      )..layout(),
  ];
  var painters = layout(fontSize);
  double sweep(List<TextPainter> ps) =>
      ps.fold<double>(0, (a, p) => a + p.width) / radius +
      (ps.length - 1) * 0.04;
  // 円弧の 150° に収まらなければ文字を小さくする。
  const maxSweep = 150 * math.pi / 180;
  final total = sweep(painters);
  if (total > maxSweep) {
    fontSize *= maxSweep / total;
    painters = layout(fontSize);
  }
  final s = sweep(painters);
  var angle = (top ? -math.pi / 2 : math.pi / 2) + (top ? -s / 2 : s / 2);
  for (final tp in painters) {
    final a = tp.width / radius;
    final mid = top ? angle + a / 2 : angle - a / 2;
    canvas.save();
    canvas.rotate(mid);
    if (top) {
      canvas.translate(radius, 0);
      canvas.rotate(math.pi / 2);
    } else {
      canvas.translate(radius, 0);
      canvas.rotate(-math.pi / 2);
    }
    tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
    canvas.restore();
    angle = top ? angle + a + 0.04 : angle - a - 0.04;
  }
}

/// 消印の外接矩形の目安（共有画像の余白を決めるため）。
Rect postmarkExtent(Offset center, double diameter) => Rect.fromLTRB(
  center.dx - diameter * 0.65,
  center.dy - diameter * 0.65,
  center.dx + diameter * 1.75,
  center.dy + diameter * 0.65,
);

/// テストで描画結果を比べるための、消印だけの画像。
Future<ui.Image> renderPostmarkImage(PostmarkData data, {double size = 200}) {
  final rec = ui.PictureRecorder();
  final canvas = Canvas(rec);
  paintPostmark(canvas, Offset(size * 0.35, size / 2), size * 0.5, data);
  return rec.endRecording().toImage(size.toInt(), size.toInt());
}
