import 'package:flutter/material.dart';

import '../../core/local_date.dart';
import '../theme.dart';
import 'l10n_ext.dart';

enum DayMark { none, step, rest, fell, future }

/// 記録のカレンダー。筆の日・休みの日・転んだ日を色で見せる。
class CalendarGrid extends StatefulWidget {
  const CalendarGrid({
    super.key,
    required this.initialMonth,
    required this.markOf,
    required this.today,
    this.onTapDay,
  });

  final LocalDate initialMonth;
  final DayMark Function(LocalDate day) markOf;
  final LocalDate today;
  final void Function(LocalDate day)? onTapDay;

  @override
  State<CalendarGrid> createState() => _CalendarGridState();
}

class _CalendarGridState extends State<CalendarGrid> {
  late LocalDate _month = widget.initialMonth.firstOfMonth;

  void _shift(int months) {
    var y = _month.year;
    var m = _month.month + months;
    while (m < 1) {
      m += 12;
      y--;
    }
    while (m > 12) {
      m -= 12;
      y++;
    }
    setState(() => _month = LocalDate(y, m, 1));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final first = _month;
    final leading = first.weekday % 7; // 日曜始まり
    final days = first.daysInMonth;
    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox.shrink());
    }
    for (var d = 1; d <= days; d++) {
      final day = LocalDate(first.year, first.month, d);
      cells.add(_DayCell(day: day, mark: widget.markOf(day), isToday: day == widget.today, onTap: widget.onTapDay));
    }
    return Column(
      children: [
        Row(
          children: [
            IconButton(onPressed: () => _shift(-1), icon: const Icon(Icons.chevron_left), tooltip: '<'),
            Expanded(
              child: Text(
                l.monthLabel(first.year, first.month),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            IconButton(onPressed: () => _shift(1), icon: const Icon(Icons.chevron_right), tooltip: '>'),
          ],
        ),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: cells,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 14,
          children: [
            _Legend(color: NanakorobiTheme.vermilion, label: l.calendarLegendStep),
            _Legend(color: NanakorobiTheme.gold, label: l.calendarLegendRest),
            _Legend(color: NanakorobiTheme.inkDim, label: l.calendarLegendFell),
          ],
        ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({required this.day, required this.mark, required this.isToday, this.onTap});

  final LocalDate day;
  final DayMark mark;
  final bool isToday;
  final void Function(LocalDate)? onTap;

  @override
  Widget build(BuildContext context) {
    final color = switch (mark) {
      DayMark.step => NanakorobiTheme.vermilion,
      DayMark.rest => NanakorobiTheme.gold,
      DayMark.fell => NanakorobiTheme.inkDim,
      DayMark.none || DayMark.future => Colors.transparent,
    };
    final filled = mark == DayMark.step || mark == DayMark.rest;
    return InkWell(
      onTap: onTap == null ? null : () => onTap!(day),
      child: Center(
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : null,
            border: Border.all(
              color: isToday ? NanakorobiTheme.ink : (mark == DayMark.fell ? color : Colors.transparent),
              width: isToday ? 1.5 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              fontSize: 13,
              color: filled ? Colors.white : (mark == DayMark.future ? NanakorobiTheme.inkDim.withValues(alpha: 0.5) : NanakorobiTheme.ink),
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 10, height: 10, decoration: BoxDecoration(shape: BoxShape.circle, color: color)),
          const SizedBox(width: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ],
      );
}
