import 'dart:math';

import 'package:flutter/material.dart';

import '../core/japanese_date.dart';
import '../core/vertical.dart';
import 'style.dart';
import 'tanzaku_painter.dart';
import 'washi.dart';

/// 月の十句ポスター（1080×1350）。右から左へ10句を縦書きで並べる。
class PosterPainter extends CustomPainter {
  PosterPainter({
    required this.year,
    required this.month,
    required this.haiku,
    required this.style,
    this.gago = '',
    this.appName = 'タンザク',
  });

  final int year;
  final int month;

  /// 1句ずつ、3行を改行でつないだもの。最大10句。
  final List<String> haiku;
  final TanzakuStyle style;
  final String gago;
  final String appName;

  static const _advance = 1.06;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    paintWashi(canvas, rect, style.washi);
    final ink = style.washi.ink;
    final m = size.width * 0.07;

    // 題（右端）
    final title = '${wafuMonth(month)}の十句';
    final titleF = size.width * 0.055;
    _column(canvas, title, size.width - m - titleF / 2, m, titleF, ink);
    _column(
      canvas,
      reiwaYear(year),
      size.width - m - titleF * 1.6,
      m + titleF * 0.3,
      titleF * 0.42,
      ink.withValues(alpha: 0.7),
    );

    // 句（10列）
    final items = haiku.take(10).toList();
    final areaRight = size.width - m - titleF * 2.4;
    final areaLeft = m + size.width * 0.1;
    final pitch = (areaRight - areaLeft) / max(1, 10);
    final top = m + size.height * 0.04;
    final bottom = size.height - m - size.height * 0.08;
    for (var i = 0; i < items.length; i++) {
      final text = items[i]
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .join('　');
      final glyphs = toVertical(text)
          .where((g) => g.text.trim().isNotEmpty)
          .length;
      final f = min(pitch * 0.62, (bottom - top) / (max(1, glyphs) * _advance));
      _column(canvas, text, areaRight - pitch * (i + 0.5), top, f, ink);
    }

    // 落款（左下）
    if (gago.trim().isNotEmpty && style.showSeal) {
      final s = size.width * 0.075;
      final r = Rect.fromLTWH(
        m,
        size.height - m - s - size.height * 0.03,
        s,
        s,
      );
      paintSeal(canvas, r, gago, style.seal, style.font.family);
      _column(
        canvas,
        gago,
        r.center.dx,
        r.top - size.width * 0.03 - gago.characters.length * s * 0.5 * _advance,
        s * 0.5,
        ink,
      );
    }
    if (appName.isNotEmpty) {
      final tp = TextPainter(
        text: TextSpan(
          text: appName,
          style: TextStyle(
            fontFamily: 'NotoSerifJP',
            fontSize: size.width * 0.02,
            color: ink.withValues(alpha: 0.45),
            letterSpacing: 4,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      tp.paint(
        canvas,
        Offset(size.width - m - tp.width, size.height - m * 0.7 - tp.height),
      );
    }
  }

  void _column(
    Canvas canvas,
    String text,
    double cx,
    double top,
    double f,
    Color color,
  ) {
    var y = top;
    for (final g in toVertical(text)) {
      if (g.text.trim().isEmpty && g.text != '　') continue;
      final tp = TextPainter(
        text: TextSpan(
          text: g.text,
          style: TextStyle(
            fontFamily: style.font.family,
            fontFamilyFallback: const ['NotoSerifJP'],
            fontSize: f,
            height: 1,
            color: color,
          ),
        ),
        textDirection: TextDirection.ltr,
        textScaler: TextScaler.noScaling,
      )..layout();
      final c = Offset(cx, y + f * _advance / 2);
      final half = Offset(tp.width / 2, tp.height / 2);
      switch (g.placement) {
        case VerticalPlacement.rotate:
          canvas.save();
          canvas.translate(c.dx, c.dy);
          canvas.rotate(pi / 2);
          tp.paint(canvas, -half);
          canvas.restore();
        case VerticalPlacement.smallKana:
          tp.paint(canvas, c - half + Offset(f * 0.12, -f * 0.12));
        case VerticalPlacement.punctuation:
          tp.paint(canvas, c - half + Offset(f * 0.58, -f * 0.55));
        case VerticalPlacement.upright:
          tp.paint(canvas, c - half);
      }
      y += f * _advance;
    }
  }

  @override
  bool shouldRepaint(PosterPainter old) =>
      old.haiku.join('|') != haiku.join('|') ||
      old.style != style ||
      old.gago != gago;
}
