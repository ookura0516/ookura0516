import 'dart:math';
import 'dart:ui';

import 'style.dart';

/// 和紙の地を描く。画像を使わず、繊維と砂子を乱数（固定の種）で描く。
void paintWashi(Canvas canvas, Rect rect, Washi washi) {
  canvas.drawRect(rect, Paint()..color = washi.paper);
  final rnd = Random(washi.index * 7919 + 17);
  final scale = rect.shortestSide / 1000;

  // 繊維：短い曲線を薄く重ねる。
  final fiber = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;
  final fiberColor = washi.dark
      ? const Color(0xFFFFFFFF)
      : const Color(0xFF8A7A60);
  final count = (rect.width * rect.height / 2500).clamp(80, 900).toInt();
  for (var i = 0; i < count; i++) {
    final x = rect.left + rnd.nextDouble() * rect.width;
    final y = rect.top + rnd.nextDouble() * rect.height;
    final len = (8 + rnd.nextDouble() * 40) * scale;
    final a = rnd.nextDouble() * pi * 2;
    final bend = (rnd.nextDouble() - 0.5) * len;
    fiber
      ..strokeWidth = (0.6 + rnd.nextDouble() * 1.4) * scale
      ..color = fiberColor.withValues(alpha: 0.04 + rnd.nextDouble() * 0.07);
    final path = Path()
      ..moveTo(x, y)
      ..quadraticBezierTo(
        x + cos(a) * len / 2 - sin(a) * bend,
        y + sin(a) * len / 2 + cos(a) * bend,
        x + cos(a) * len,
        y + sin(a) * len,
      );
    canvas.drawPath(path, fiber);
  }

  // 雲のようなむら。
  for (var i = 0; i < 10; i++) {
    final c = Offset(
      rect.left + rnd.nextDouble() * rect.width,
      rect.top + rnd.nextDouble() * rect.height,
    );
    final r = (120 + rnd.nextDouble() * 260) * scale;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color =
            (washi.dark ? const Color(0xFF000000) : const Color(0xFFFFFFFF))
                .withValues(alpha: 0.10)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, r / 2),
    );
  }

  // 金砂子と藍の金：金の粒を散らす。
  if (washi == Washi.kinsunago || washi == Washi.ai) {
    final gold = Paint();
    final n = washi == Washi.kinsunago ? 420 : 140;
    for (var i = 0; i < n; i++) {
      // 上下の端に多く散らす。
      final edge = rnd.nextBool();
      final t = pow(rnd.nextDouble(), 2.2).toDouble() * 0.35;
      final y = edge
          ? rect.top + rect.height * t
          : rect.bottom - rect.height * t;
      final x = rect.left + rnd.nextDouble() * rect.width;
      gold.color = const Color(0xFFC9A44C)
          .withValues(alpha: 0.35 + rnd.nextDouble() * 0.5);
      final s = (1.2 + rnd.nextDouble() * 3.2) * scale;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(x, y),
          width: s,
          height: s * (0.6 + rnd.nextDouble()),
        ),
        gold,
      );
    }
  }
}
