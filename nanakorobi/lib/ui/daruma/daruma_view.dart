import 'package:flutter/material.dart';

import '../../core/size_rank.dart';
import '../../model/models.dart';
import '../a11y.dart';
import '../theme.dart';
import 'daruma_painter.dart';

/// だるまの絵。筆が増えたときの描画演出（0.5秒）と、転倒・起き上がりの演出を持つ。
class DarumaView extends StatefulWidget {
  const DarumaView({
    super.key,
    required this.look,
    this.width,
    this.highlightEye,
    this.fitRank = false,
    this.showBase = true,
    this.semanticsLabel,
  });

  final DarumaLook look;

  /// 幅。null なら親に合わせる（縦横比は 100:125）。
  final double? width;
  final EyeSide? highlightEye;

  /// 棚で、大きさの段階に応じて縮める。
  final bool fitRank;
  final bool showBase;
  final String? semanticsLabel;

  @override
  State<DarumaView> createState() => _DarumaViewState();
}

class _DarumaViewState extends State<DarumaView> with SingleTickerProviderStateMixin {
  late final AnimationController _stroke = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    value: 1,
  );

  @override
  void didUpdateWidget(DarumaView old) {
    super.didUpdateWidget(old);
    if (widget.look.darumaId == old.look.darumaId && widget.look.strokes == old.look.strokes + 1) {
      if (A11y.reduceMotion(context)) {
        _stroke.value = 1;
      } else {
        _stroke.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _stroke.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = widget.fitRank ? SizeRank.fitScale(widget.look.sizeRank) : 1.0;
    final fallDuration = A11y.motion(context, const Duration(milliseconds: 700));
    Widget child = TweenAnimationBuilder<double>(
      tween: Tween(end: widget.look.fallen ? 1.0 : 0.0),
      duration: fallDuration,
      curve: widget.look.fallen ? Curves.easeInBack : Curves.easeOutBack,
      builder: (context, fall, _) => AnimatedBuilder(
        animation: _stroke,
        builder: (context, _) => CustomPaint(
          painter: DarumaPainter(
            look: widget.look,
            fallProgress: fall,
            newStrokeProgress: _stroke.value,
            highlightEye: widget.highlightEye,
            brushFontFamily: NanakorobiTheme.brushFontFamily,
            showBase: widget.showBase,
          ),
        ),
      ),
    );
    child = AspectRatio(aspectRatio: DarumaPainter.aspectRatio, child: child);
    if (scale != 1.0) {
      child = FractionallySizedBox(
        widthFactor: scale,
        alignment: Alignment.bottomCenter,
        child: child,
      );
    }
    if (widget.width != null) {
      child = SizedBox(width: widget.width, child: child);
    }
    final label = widget.semanticsLabel;
    if (label != null) {
      child = Semantics(label: label, image: true, child: ExcludeSemantics(child: child));
    }
    return child;
  }
}
