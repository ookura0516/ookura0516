import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../model/models.dart';
import '../daruma/daruma_painter.dart';
import '../daruma/daruma_view.dart';

/// 指でなぞって目を入れる。目の中をひと筆でなぞれたら [onTraced] を呼ぶ。
///
/// 指の動きは [Listener] で生で受ける（GestureDetector のパンは 36px 動くまで始まらず、
/// 小さな目をなぞる筆には遅い）。親のスクロールに取られないよう、触れた瞬間に
/// ジェスチャの勝ちを宣言する（EagerGestureRecognizer）。
class EyeTracePad extends StatefulWidget {
  const EyeTracePad({
    super.key,
    required this.look,
    required this.targetEye,
    required this.onTraced,
    this.enabled = true,
    this.semanticsLabel,
  });

  final DarumaLook look;
  final EyeSide targetEye;
  final VoidCallback onTraced;
  final bool enabled;
  final String? semanticsLabel;

  @override
  State<EyeTracePad> createState() => _EyeTracePadState();
}

class _EyeTracePadState extends State<EyeTracePad> {
  final List<Offset> _points = [];
  int? _pointer;

  /// 画面の座標 → だるまの箱（100×125）の座標。
  static (double scale, Offset origin) transformFor(Size size) {
    final scale = math.min(size.width / DarumaPainter.boxWidth, size.height / DarumaPainter.boxHeight);
    final origin = Offset(
      (size.width - DarumaPainter.boxWidth * scale) / 2,
      (size.height - DarumaPainter.boxHeight * scale) / 2,
    );
    return (scale, origin);
  }

  /// 目の中を、十分な長さでなぞったか。
  static bool covers(List<Offset> points, Size size, EyeSide eye) {
    if (points.length < 4) return false;
    final (scale, origin) = transformFor(size);
    final center = DarumaPainter.eyeCenter(eye) * scale + origin;
    final radius = (DarumaPainter.eyeRadius + 2) * scale;
    var inside = 0;
    var length = 0.0;
    Offset? prev;
    for (final p in points) {
      if ((p - center).distance <= radius) {
        inside++;
        if (prev != null) length += (p - prev).distance;
        prev = p;
      } else {
        prev = null;
      }
    }
    return inside >= 4 && length >= DarumaPainter.eyeRadius * scale * 1.2;
  }

  void _down(PointerDownEvent e) {
    if (!widget.enabled || _pointer != null) return;
    setState(() {
      _pointer = e.pointer;
      _points
        ..clear()
        ..add(e.localPosition);
    });
  }

  void _move(PointerMoveEvent e) {
    if (e.pointer != _pointer) return;
    setState(() => _points.add(e.localPosition));
  }

  void _up(PointerEvent e, Size size) {
    if (e.pointer != _pointer) return;
    final ok = covers(_points, size, widget.targetEye);
    setState(() {
      _pointer = null;
      _points.clear();
    });
    if (ok) widget.onTraced();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: DarumaPainter.aspectRatio,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.biggest;
          return RawGestureDetector(
            behavior: HitTestBehavior.opaque,
            gestures: widget.enabled
                ? {
                    EagerGestureRecognizer: GestureRecognizerFactoryWithHandlers<EagerGestureRecognizer>(
                      EagerGestureRecognizer.new,
                      (_) {},
                    ),
                  }
                : const {},
            child: Listener(
              behavior: HitTestBehavior.opaque,
              onPointerDown: _down,
              onPointerMove: _move,
              onPointerUp: (e) => _up(e, size),
              onPointerCancel: (e) => _up(e, size),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DarumaView(
                    look: widget.look,
                    highlightEye: widget.enabled ? widget.targetEye : null,
                    semanticsLabel: widget.semanticsLabel,
                  ),
                  if (_points.isNotEmpty) CustomPaint(painter: _InkPainter(List.of(_points), transformFor(size).$1)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.points, this.scale);

  final List<Offset> points;
  final double scale;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final p in points.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      path,
      Paint()
        ..color = const Color(0xFF1B1A1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.2 * scale
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
  }

  @override
  bool shouldRepaint(_InkPainter old) => old.points.length != points.length || old.scale != scale;
}
