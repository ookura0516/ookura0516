import 'package:flutter/material.dart';

import '../../app/app_state.dart';
import '../../core/day_slots.dart';
import '../theme.dart';
import 'stamp_view.dart';

/// 5列×6行のマス。空欄は日付、今日の空欄は点滅する点線。
class SheetGrid extends StatelessWidget {
  const SheetGrid({
    super.key,
    required this.data,
    required this.today,
    required this.onEmpty,
    required this.onStamp,
    this.animate = true,
  });

  final MonthData data;
  final Day today;
  final void Function(Day day) onEmpty;
  final void Function(StampEntry e) onStamp;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final days = daysInMonth(data.year, data.month);
    return Column(
      children: [
        for (var r = 0; r < sheetRows; r++)
          Row(
            children: [
              for (var c = 0; c < sheetColumns; c++)
                Expanded(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _cell(context, r * sheetColumns + c, days),
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cell(BuildContext context, int index, int days) {
    final dayNum = index + 1;
    if (dayNum > days) return const SizedBox.shrink();
    final entry = data.cells[index];
    final day = Day(data.year, data.month, dayNum);
    if (entry != null) {
      return Semantics(
        label: '${data.month}月$dayNum日の切手',
        button: true,
        child: InkWell(
          key: Key('stamp-${day.iso}'),
          onTap: () => onStamp(entry),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: ClipRect(child: StampView(entry: entry)),
          ),
        ),
      );
    }
    final isToday = day == today;
    final future = day > today;
    return Semantics(
      label: isToday ? '今日のマス、空欄' : '$dayNum日、空欄',
      button: !future,
      child: InkWell(
        key: Key('cell-${day.iso}'),
        onTap: () => onEmpty(day),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: isToday
              ? _TodayCell(day: dayNum, animate: animate)
              : DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: KeshiinTheme.line.withValues(
                        alpha: future ? 0.4 : 1,
                      ),
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Center(
                    child: Text(
                      '$dayNum',
                      style: TextStyle(
                        color: KeshiinTheme.inkDim.withValues(
                          alpha: future ? 0.35 : 0.7,
                        ),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _TodayCell extends StatefulWidget {
  const _TodayCell({required this.day, required this.animate});
  final int day;
  final bool animate;

  @override
  State<_TodayCell> createState() => _TodayCellState();
}

class _TodayCellState extends State<_TodayCell>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (widget.animate && !reduce) {
      if (!_c.isAnimating) _c.repeat(reverse: true);
    } else {
      _c.value = 1;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) => CustomPaint(
        painter: _DashedBox(
          KeshiinTheme.accent.withValues(alpha: 0.35 + 0.65 * _c.value),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${widget.day}',
                style: const TextStyle(
                  color: KeshiinTheme.accent,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(Icons.add, size: 18, color: KeshiinTheme.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedBox extends CustomPainter {
  _DashedBox(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke;
    const dash = 5.0;
    void line(Offset a, Offset b) {
      final len = (b - a).distance;
      for (var t = 0.0; t < len; t += dash * 2) {
        canvas.drawLine(
          a + (b - a) * (t / len),
          a + (b - a) * ((t + dash).clamp(0, len) / len),
          p,
        );
      }
    }

    final r = Offset.zero & size;
    line(r.topLeft, r.topRight);
    line(r.topRight, r.bottomRight);
    line(r.bottomRight, r.bottomLeft);
    line(r.bottomLeft, r.topLeft);
  }

  @override
  bool shouldRepaint(_DashedBox old) => old.color != color;
}
