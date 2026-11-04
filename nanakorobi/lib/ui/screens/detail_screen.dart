import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/local_date.dart';
import '../../core/rules.dart';
import '../../data/presets.dart';
import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/actions.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';
import '../widgets/daruma_view.dart';

/// だるまの詳細：記録のカレンダー、ひとこと、目標の編集、満願・納める。
class DetailScreen extends ConsumerStatefulWidget {
  const DetailScreen({super.key, required this.darumaId});

  final int darumaId;

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  LocalDate? _month;

  Future<void> _confirmRetire(DarumaDetail detail) async {
    final l = L10n.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.retireConfirmTitle),
        content: Text(l.retireConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
          FilledButton(
            key: const Key('retire-confirm'),
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l.retire),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await ref.read(actionsProvider).retire(detail);
    if (mounted) context.go('/shelf');
  }

  Future<void> _edit(DarumaDetail detail) async {
    final result = await showDialog<_GoalEdit>(
      context: context,
      builder: (_) => _EditGoalDialog(daruma: detail.daruma),
    );
    if (result == null || !mounted) return;
    await ref.read(actionsProvider).updateGoal(
          detail.daruma,
          deadline: result.deadline,
          deadlineLabel: result.deadlineLabel,
          dailyAction: result.dailyAction,
        );
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final async = ref.watch(darumaDetailProvider(widget.darumaId));
    return Scaffold(
      appBar: AppBar(title: Text(l.detailTitle)),
      body: SafeArea(
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (detail) {
            if (detail == null) return Center(child: Text(l.homeNoDaruma));
            final d = detail.daruma;
            final month = _month ?? today.firstOfMonth;
            final memos = detail.checkins.where((c) => (c.memo ?? '').isNotEmpty).toList().reversed.take(20);
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 96,
                      height: 120,
                      child: DarumaView(detail.lookOn(today), animate: false),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
                          Text(
                            '${l.homeDaysSince(Rules.daysSinceOpened(d.createdOn, today))}\n'
                            '${l.homeBrushes(detail.brushCount)} ・ ${l.homeRises(detail.riseCount)}',
                            style: const TextStyle(color: NanakorobiTheme.inkDim, height: 1.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.event_outlined),
                        title: Text(l.detailDeadline),
                        subtitle: Text(
                          d.deadline == null
                              ? l.deadlineNone
                              : '${d.deadlineLabel ?? l.homeDeadlineDefault}  ${formatDate(d.deadline!)}',
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.directions_walk),
                        title: Text(l.detailDailyAction),
                        subtitle: Text(d.dailyAction ?? '—'),
                      ),
                      if (d.isActive)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton.icon(
                            key: const Key('detail-edit'),
                            onPressed: () => _edit(detail),
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            label: Text(l.detailEdit),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                _RecordCalendar(
                  month: month,
                  detail: detail,
                  today: today,
                  onPrev: () => setState(() => _month = _shiftMonth(month, -1)),
                  onNext: () => setState(() => _month = _shiftMonth(month, 1)),
                ),
                if (memos.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(l.detailMemos, style: const TextStyle(fontWeight: FontWeight.bold)),
                  for (final c in memos)
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Text(formatDate(c.date), style: const TextStyle(color: NanakorobiTheme.inkDim)),
                      title: Text(c.memo!),
                    ),
                ],
                if (d.isActive) ...[
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    key: const Key('detail-complete'),
                    onPressed: () => context.push('/daruma/${d.id}/complete'),
                    icon: const Icon(Icons.visibility),
                    label: Text(l.detailComplete),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton(
                    key: const Key('detail-retire'),
                    onPressed: () => _confirmRetire(detail),
                    child: Text(l.detailRetire),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

LocalDate _shiftMonth(LocalDate month, int by) {
  final m0 = month.year * 12 + (month.month - 1) + by;
  return LocalDate(m0 ~/ 12, m0 % 12 + 1, 1);
}

/// 記録のカレンダー：記録した日、記録のない日（開眼から昨日まで）、今日。
class _RecordCalendar extends StatelessWidget {
  const _RecordCalendar({
    required this.month,
    required this.detail,
    required this.today,
    required this.onPrev,
    required this.onNext,
  });

  final LocalDate month;
  final DarumaDetail detail;
  final LocalDate today;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final first = month.firstOfMonth;
    final leading = first.weekday % 7; // 日曜始まり
    final days = first.daysInMonth;
    final stepDays = {for (final c in detail.checkins) if (c.kind == CheckinKind.step) c.date};
    final created = detail.daruma.createdOn;
    final end = detail.daruma.completedOn ?? detail.daruma.retiredOn ?? today;
    final cells = <Widget>[];
    for (var i = 0; i < leading; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= days; day++) {
      final date = LocalDate(month.year, month.month, day);
      final stepped = stepDays.contains(date);
      final missed = !stepped && !date.isBefore(created) && date.isBefore(end) && date != created;
      final isToday = date == today;
      cells.add(Center(
        child: Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: stepped ? NanakorobiTheme.red : Colors.transparent,
            border: isToday ? Border.all(color: NanakorobiTheme.ink, width: 1.5) : null,
          ),
          alignment: Alignment.center,
          child: Text(
            '$day',
            style: TextStyle(
              color: stepped
                  ? Colors.white
                  : missed
                      ? NanakorobiTheme.line
                      : NanakorobiTheme.ink,
              fontWeight: stepped || isToday ? FontWeight.bold : FontWeight.normal,
              decoration: missed ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(onPressed: onPrev, icon: const Icon(Icons.chevron_left)),
                Expanded(
                  child: Text(
                    l.monthTitle(month.year, month.month),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                IconButton(onPressed: onNext, icon: const Icon(Icons.chevron_right)),
              ],
            ),
            GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.1,
              children: cells,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircleAvatar(radius: 5, backgroundColor: NanakorobiTheme.red),
                const SizedBox(width: 4),
                Text(l.calendarStep, style: const TextStyle(fontSize: 12, color: NanakorobiTheme.inkDim)),
                const SizedBox(width: 14),
                const Text('1', style: TextStyle(fontSize: 12, color: NanakorobiTheme.line, decoration: TextDecoration.lineThrough)),
                const SizedBox(width: 4),
                Text(l.calendarMissed, style: const TextStyle(fontSize: 12, color: NanakorobiTheme.inkDim)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoalEdit {
  const _GoalEdit({this.deadline, this.deadlineLabel, this.dailyAction});
  final LocalDate? deadline;
  final String? deadlineLabel;
  final String? dailyAction;
}

class _EditGoalDialog extends ConsumerStatefulWidget {
  const _EditGoalDialog({required this.daruma});

  final Daruma daruma;

  @override
  ConsumerState<_EditGoalDialog> createState() => _EditGoalDialogState();
}

class _EditGoalDialogState extends ConsumerState<_EditGoalDialog> {
  late LocalDate? _deadline = widget.daruma.deadline;
  late final _label = TextEditingController(text: widget.daruma.deadlineLabel ?? '');
  late final _daily = TextEditingController(text: widget.daruma.dailyAction ?? '');

  @override
  void dispose() {
    _label.dispose();
    _daily.dispose();
    super.dispose();
  }

  Future<void> _pickPreset() async {
    final preset = await context.push<ExamPreset>('/presets');
    if (preset == null) return;
    setState(() {
      _deadline = preset.date;
      _label.text = preset.short;
    });
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_deadline ?? today.addDays(30)).toLocalDateTime(),
      firstDate: today.addDays(-366).toLocalDateTime(),
      lastDate: today.addDays(366 * 3).toLocalDateTime(),
    );
    if (picked == null) return;
    setState(() => _deadline = LocalDate.fromDateTime(picked));
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    return AlertDialog(
      title: Text(l.detailEdit),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.deadlineLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(_deadline == null ? l.deadlineNone : formatDate(_deadline!)),
            Wrap(
              spacing: 8,
              children: [
                TextButton(onPressed: _pickPreset, child: Text(l.pickFromPresets)),
                TextButton(onPressed: _pickDate, child: Text(l.pickDate)),
                if (_deadline != null)
                  TextButton(
                    onPressed: () => setState(() {
                      _deadline = null;
                      _label.clear();
                    }),
                    child: Text(l.clearDeadline),
                  ),
              ],
            ),
            if (_deadline != null)
              TextField(
                controller: _label,
                maxLength: 12,
                decoration: InputDecoration(labelText: l.deadlineNameLabel),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _daily,
              maxLength: 20,
              decoration: InputDecoration(labelText: l.dailyActionLabel, hintText: l.dailyActionHint),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.cancel)),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_GoalEdit(
            deadline: _deadline,
            deadlineLabel: _deadline == null
                ? null
                : (_label.text.trim().isEmpty ? l.homeDeadlineDefault : _label.text.trim()),
            dailyAction: _daily.text,
          )),
          child: Text(l.save),
        ),
      ],
    );
  }
}
