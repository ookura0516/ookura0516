import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../scenario/model.dart';
import '../theme.dart';

/// 手がかりのパネル1枚を描く。
///
/// [onCableSelected] を渡すと、ケーブルをタップして選べるようになる。
class PanelView extends StatelessWidget {
  const PanelView({
    super.key,
    required this.panel,
    this.selectedCable,
    this.onCableSelected,
  });

  final PanelSpec panel;
  final int? selectedCable;
  final ValueChanged<int>? onCableSelected;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (panel.title != null) ...[
              Text(
                panel.title!,
                style: text.titleSmall?.copyWith(color: HisokagiTheme.star),
              ),
              const SizedBox(height: 12),
            ],
            _body(context),
            if (panel.caption != null) ...[
              const SizedBox(height: 12),
              Text(
                panel.caption!,
                style: text.bodySmall?.copyWith(color: HisokagiTheme.textDim),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _body(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return switch (panel) {
      TextPanel(:final body) =>
        Text(body, style: text.bodyLarge?.copyWith(height: 1.7)),
      ListPanel(:final items, :final numbered) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < items.length; i++)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 28,
                      child: Text(numbered ? '${i + 1}.' : '・',
                          style: text.bodyLarge
                              ?.copyWith(color: HisokagiTheme.starDim)),
                    ),
                    Expanded(
                      child: Text(items[i],
                          style: text.bodyLarge?.copyWith(height: 1.5)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      SymbolRowPanel(:final symbols) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final s in symbols)
              Container(
                width: 60,
                height: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: HisokagiTheme.surfaceHi,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(s,
                    style: const TextStyle(
                        fontSize: 34, color: HisokagiTheme.star, height: 1)),
              ),
          ],
        ),
      TablePanel(:final headers, :final rows) => Table(
          border: TableBorder.symmetric(
            inside: const BorderSide(color: HisokagiTheme.surfaceHi),
          ),
          children: [
            TableRow(children: [
              for (final h in headers)
                _cell(h, style: text.labelLarge?.copyWith(color: HisokagiTheme.textDim)),
            ]),
            for (final r in rows)
              TableRow(children: [
                for (var i = 0; i < r.length; i++)
                  _cell(r[i],
                      style: i == 0
                          ? const TextStyle(fontSize: 26, color: HisokagiTheme.star)
                          : text.titleLarge),
              ]),
          ],
        ),
      ClockPanel(:final hour, :final minute) => Center(
          child: SizedBox(
            width: 220,
            height: 220,
            child: CustomPaint(
              painter: ClockPainter(hour: hour, minute: minute),
              child: Semantics(label: '針の止まったアナログ時計'),
            ),
          ),
        ),
      CablePanel(:final colors) => _Cables(
          colors: colors,
          selected: selectedCable,
          onSelected: onCableSelected,
        ),
      GridPanel(:final rowLabels, :final colLabels, :final cells) => Table(
          defaultColumnWidth: const FlexColumnWidth(),
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          columnWidths: const {0: FixedColumnWidth(36)},
          children: [
            TableRow(children: [
              const SizedBox(),
              for (final c in colLabels)
                _cell(c, style: text.labelLarge?.copyWith(color: HisokagiTheme.textDim)),
            ]),
            for (var r = 0; r < cells.length; r++)
              TableRow(children: [
                _cell(rowLabels[r],
                    style: text.titleMedium?.copyWith(color: HisokagiTheme.textDim)),
                for (final ch in cells[r]) _cell(ch, style: text.titleLarge),
              ]),
          ],
        ),
    };
  }

  static Widget _cell(String s, {TextStyle? style}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(s, textAlign: TextAlign.center, style: style),
      );
}

class _Cables extends StatelessWidget {
  const _Cables({required this.colors, this.selected, this.onSelected});

  final List<CableColor> colors;
  final int? selected;
  final ValueChanged<int>? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (var i = 0; i < colors.length; i++)
          Semantics(
            button: onSelected != null,
            selected: selected == i + 1,
            label: '左から${i + 1}本目、${colors[i].label}',
            child: GestureDetector(
              key: Key('cable-${i + 1}'),
              onTap: onSelected == null ? null : () => onSelected!(i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected == i + 1
                        ? HisokagiTheme.star
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 22,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8A90A6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    Container(width: 12, height: 110, color: Color(colors[i].argb)),
                    const SizedBox(height: 6),
                    Text(colors[i].label,
                        style: const TextStyle(color: HisokagiTheme.textDim)),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

/// 針の止まったアナログ時計。
class ClockPainter extends CustomPainter {
  ClockPainter({required this.hour, required this.minute});

  final int hour;
  final int minute;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2 - 4;
    canvas.drawCircle(c, r, Paint()..color = const Color(0xFFF3EEDF));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..color = HisokagiTheme.starDim
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5,
    );

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (var i = 1; i <= 12; i++) {
      final a = i * math.pi / 6 - math.pi / 2;
      tp.text = TextSpan(
        text: '$i',
        style: const TextStyle(
            color: Color(0xFF2A2A33), fontSize: 18, fontWeight: FontWeight.w600),
      );
      tp.layout();
      final p = c + Offset(math.cos(a), math.sin(a)) * (r - 22);
      tp.paint(canvas, p - Offset(tp.width / 2, tp.height / 2));
    }
    for (var i = 0; i < 60; i++) {
      final a = i * math.pi / 30;
      final long = i % 5 == 0;
      final p1 = c + Offset(math.sin(a), -math.cos(a)) * (r - 4);
      final p2 = c + Offset(math.sin(a), -math.cos(a)) * (r - (long ? 11 : 7));
      canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = const Color(0xFF555566)
          ..strokeWidth = long ? 2.5 : 1,
      );
    }

    void hand(double turns, double length, double width) {
      final a = turns * 2 * math.pi;
      canvas.drawLine(
        c,
        c + Offset(math.sin(a), -math.cos(a)) * length,
        Paint()
          ..color = const Color(0xFF1C1C24)
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round,
      );
    }

    hand(((hour % 12) + minute / 60) / 12, r * 0.5, 7);
    hand(minute / 60, r * 0.78, 4);
    canvas.drawCircle(c, 6, Paint()..color = const Color(0xFF1C1C24));
  }

  @override
  bool shouldRepaint(ClockPainter old) =>
      old.hour != hour || old.minute != minute;
}
