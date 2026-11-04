import 'package:flutter/material.dart';

import '../../model/models.dart';
import '../../paint/daruma_painter.dart';

/// だるまを描き、変化に演出を付ける。
///
/// - 筆が増えたら、新しい筆を 0.5 秒で描く
/// - 目が入ったら、瞳を 0.6 秒で広げる
/// - 転倒から起き上がるときは 0.7 秒で回転して立つ
class DarumaView extends StatefulWidget {
  const DarumaView(
    this.look, {
    super.key,
    this.showBase = true,
    this.eyeHighlight,
    this.animate = true,
  });

  final DarumaLook look;
  final bool showBase;
  final int? eyeHighlight;
  final bool animate;

  @override
  State<DarumaView> createState() => _DarumaViewState();
}

class _DarumaViewState extends State<DarumaView> with TickerProviderStateMixin {
  late final AnimationController _stroke =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 500), value: 1);
  late final AnimationController _eye =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 600), value: 1);
  late final AnimationController _rise =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 700), value: 0);

  @override
  void initState() {
    super.initState();
    _rise.value = widget.look.fallen ? 1 : 0;
  }

  @override
  void didUpdateWidget(DarumaView old) {
    super.didUpdateWidget(old);
    final a = old.look;
    final b = widget.look;
    if (!widget.animate) {
      _rise.value = b.fallen ? 1 : 0;
      return;
    }
    if (b.brushCount > a.brushCount) _stroke.forward(from: 0);
    if (b.openedEyes > a.openedEyes) _eye.forward(from: 0);
    if (a.fallen != b.fallen) {
      if (b.fallen) {
        _rise.forward(from: _rise.value);
      } else {
        _rise.reverse(from: _rise.value);
      }
    }
  }

  @override
  void dispose() {
    _stroke.dispose();
    _eye.dispose();
    _rise.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_stroke, _eye, _rise]),
      builder: (context, _) {
        return CustomPaint(
          painter: DarumaPainter(
            widget.look,
            reveal: Curves.easeOut.transform(_stroke.value),
            eyeReveal: Curves.easeOutBack.transform(_eye.value).clamp(0.0, 1.0),
            fallAmount: Curves.easeInOut.transform(_rise.value),
            showBase: widget.showBase,
            eyeHighlight: widget.eyeHighlight,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}
