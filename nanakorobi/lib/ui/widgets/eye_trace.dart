import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../model/models.dart';
import '../../paint/daruma_painter.dart';
import 'daruma_view.dart';

/// 指でなぞって目を入れる。
///
/// 目の円の中を指がなぞった長さが目の直径の 1.5 倍を越えたら「入った」。
/// 1筆で済む（設計書「だるまの育ち方」）。
class EyeTrace extends StatefulWidget {
  const EyeTrace({
    super.key,
    required this.look,
    required this.side,
    required this.onPainted,
    this.done = false,
  });

  /// 入れる前の見た目（開眼なら openedEyes 0、満願なら 1）。
  final DarumaLook look;

  /// 入れる目。
  final EyeSide side;
  final VoidCallback onPainted;

  /// 入れ終えたあと（目を入れた look を描く）。
  final bool done;

  @override
  State<EyeTrace> createState() => _EyeTraceState();
}

class _EyeTraceState extends State<EyeTrace> {
  double _traced = 0;
  Offset? _last;
  final List<Offset> _trail = [];
  bool _fired = false;

  void _onStart(Offset p) {
    _last = p;
    _trail.clear();
  }

  void _onMove(Offset p, Size size) {
    final c = DarumaPainter.eyeCenterIn(size, widget.side);
    final r = DarumaPainter.eyeRadiusIn(size);
    final last = _last;
    if (last != null && (p - c).distance <= r * 1.25) {
      _traced += (p - last).distance;
      _trail.add(p);
      if (_traced >= r * 3 && !_fired) {
        _fired = true;
        widget.onPainted();
      }
      setState(() {});
    }
    _last = p;
  }

  @override
  Widget build(BuildContext context) {
    final sideIndex = widget.side == EyeSide.left ? 0 : 1;
    final look = widget.done
        ? widget.look.copyWith(openedEyes: widget.look.openedEyes + 1)
        : widget.look;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final c = DarumaPainter.eyeCenterIn(size, widget.side);
        final r = DarumaPainter.eyeRadiusIn(size);
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: widget.done ? null : (d) => _onStart(d.localPosition),
          onPanUpdate: widget.done ? null : (d) => _onMove(d.localPosition, size),
          onPanEnd: (_) => _last = null,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DarumaView(look, eyeHighlight: widget.done ? null : sideIndex),
              if (!widget.done)
                IgnorePointer(
                  child: CustomPaint(
                    painter: _TracePainter(
                      center: c,
                      radius: r,
                      trail: _trail,
                      progress: math.min(1, _traced / (r * 3)),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _TracePainter extends CustomPainter {
  _TracePainter({required this.center, required this.radius, required this.trail, required this.progress});

  final Offset center;
  final double radius;
  final List<Offset> trail;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    // 入れる目を示す破線の輪。
    final ring = Paint()
      ..color = const Color(0xFFC3262A).withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    const dashes = 18;
    for (var i = 0; i < dashes; i++) {
      final a0 = i * 2 * math.pi / dashes;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius * 1.35),
        a0,
        math.pi / dashes,
        false,
        ring,
      );
    }
    // 指の跡（墨）。
    if (trail.length >= 2) {
      final p = Path()..moveTo(trail.first.dx, trail.first.dy);
      for (final o in trail.skip(1)) {
        p.lineTo(o.dx, o.dy);
      }
      canvas.save();
      canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius * 0.98)));
      canvas.drawPath(
        p,
        Paint()
          ..color = const Color(0xFF1C1C1C).withValues(alpha: 0.85)
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = radius * 0.5,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_TracePainter old) =>
      old.progress != progress || old.trail.length != trail.length || old.center != center;
}
