import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/fall.dart';
import '../../core/local_date.dart';
import '../../core/validation.dart';
import '../../model/models.dart';
import '../../state/create_daruma.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/calendar_grid.dart';
import '../widgets/l10n_ext.dart';

/// だるまの詳細：記録のカレンダー、メモ、設定変更、満願／納める。
class DarumaDetailScreen extends ConsumerWidget {
  const DarumaDetailScreen({super.key, required this.id});

  final String id;

  Future<void> _retire(BuildContext context, WidgetRef ref, Daruma d) async {
    final l = context.l10n;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.retireConfirmTitle),
        content: Text(l.retireConfirmBody),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
          FilledButton(key: const Key('retire-confirm'), onPressed: () => Navigator.pop(context, true), child: Text(l.retireAction)),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(darumaActionsProvider).retire(d.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.retiredToast)));
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, DarumaBundle b) async {
    final l = context.l10n;
    final today = ref.read(todayProvider);
    var deadline = b.daruma.deadline;
    final deadlineName = TextEditingController(text: b.daruma.deadlineName ?? '');
    final action = TextEditingController(text: b.daruma.dailyAction ?? '');
    final waypoints = [for (final m in b.milestones) WaypointInput(name: m.name, date: m.date, presetId: m.presetId)];
    var clear = false;

    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Padding(
          padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l.editGoal, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: (deadline ?? today.addDays(30)).toDateTime(),
                          firstDate: today.toDateTime(),
                          lastDate: today.addDays(365 * 3).toDateTime(),
                        );
                        if (picked != null) {
                          setState(() {
                            deadline = LocalDate.fromDateTime(picked);
                            clear = false;
                          });
                        }
                      },
                      child: Text(deadline == null ? l.deadlinePick : context.formatDate(deadline!)),
                    ),
                  ),
                  if (deadline != null)
                    IconButton(
                      icon: const Icon(Icons.close),
                      tooltip: l.deadlineClear,
                      onPressed: () => setState(() {
                        deadline = null;
                        clear = true;
                      }),
                    ),
                ],
              ),
              if (deadline != null)
                TextField(controller: deadlineName, decoration: InputDecoration(hintText: l.deadlineNameHint)),
              const SizedBox(height: 8),
              TextField(
                controller: action,
                maxLength: 30,
                decoration: InputDecoration(labelText: l.dailyActionLabel, hintText: l.dailyActionHintText),
              ),
              for (var i = 0; i < waypoints.length; i++)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(waypoints[i].name),
                  subtitle: Text(context.formatDate(waypoints[i].date)),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => setState(() => waypoints.removeAt(i)),
                  ),
                ),
              if (waypoints.length < Limits.waypointsMax)
                TextButton.icon(
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: today.addDays(14).toDateTime(),
                      firstDate: today.toDateTime(),
                      lastDate: today.addDays(365 * 3).toDateTime(),
                    );
                    if (picked == null || !context.mounted) return;
                    final name = TextEditingController();
                    final named = await showDialog<String>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text(l.waypointDialogTitle),
                        content: TextField(controller: name, autofocus: true, decoration: InputDecoration(hintText: l.waypointNameHint)),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: Text(l.cancel)),
                          FilledButton(onPressed: () => Navigator.pop(context, name.text.trim()), child: Text(l.ok)),
                        ],
                      ),
                    );
                    if (named != null && named.isNotEmpty) {
                      setState(() => waypoints.add(WaypointInput(name: named, date: LocalDate.fromDateTime(picked))));
                    }
                  },
                  icon: const Icon(Icons.add),
                  label: Text(l.waypointAdd),
                ),
              const SizedBox(height: 8),
              FilledButton(key: const Key('edit-save'), onPressed: () => Navigator.pop(context, true), child: Text(l.save)),
            ],
          ),
        ),
      ),
    );
    if (ok != true) return;
    await ref.read(darumaActionsProvider).updateGoal(
          b.id,
          deadline: deadline,
          clearDeadline: clear,
          deadlineName: deadlineName.text.trim(),
          dailyAction: action.text,
          waypoints: waypoints,
        );
  }

  Future<void> _bigger(BuildContext context, WidgetRef ref, Daruma d) async {
    ref.read(createDarumaProvider.notifier).startBigger(d);
    await context.push(Routes.newDaruma);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final b = ref.watch(bundleProvider(id));
    final look = ref.watch(lookProvider(id));
    final today = ref.watch(todayProvider);
    if (b == null || look == null) {
      return Scaffold(appBar: AppBar(title: Text(l.detailTitle)));
    }
    final d = b.daruma;
    final t = Theme.of(context).textTheme;
    final gaps = d.isActive
        ? FallJudge.gapDays(openedOn: d.openedOn, today: today, stepDates: b.stepDates, restDates: b.restDates).toSet()
        : <LocalDate>{};
    final memos = b.checkins.where((c) => c.memo != null && c.memo!.isNotEmpty).toList().reversed.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(d.name),
        actions: [
          if (d.isActive)
            IconButton(
              key: const Key('detail-edit'),
              tooltip: l.editGoal,
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => _edit(context, ref, b),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          Center(child: DarumaView(look: look, width: 170, semanticsLabel: d.name)),
          const SizedBox(height: 8),
          Text(
            [
              switch (d.status) {
                DarumaStatus.active => l.statusActive,
                DarumaStatus.completed => l.statusCompleted,
                DarumaStatus.retired => l.statusRetired,
              },
              l.openedOn(context.formatDate(d.openedOn)),
              if (d.completedOn != null) l.completedOn(context.formatDate(d.completedOn!)),
              if (d.retiredOn != null) l.retiredOn(context.formatDate(d.retiredOn!)),
              l.sizeRankLabel(d.sizeRank),
            ].join('　'),
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim),
          ),
          Text(
            '${l.strokesCount(look.strokes)}　${l.riseLabel} ${l.riseCount(look.riseCount)}',
            textAlign: TextAlign.center,
            style: t.titleMedium,
          ),
          if (d.deadline != null)
            Text(l.deadlineRow(d.deadlineName ?? '', context.formatDate(d.deadline!)), textAlign: TextAlign.center),
          for (final m in b.milestones)
            Text(l.waypointRow(m.name, context.formatDate(m.date)), textAlign: TextAlign.center),
          if (d.dailyAction != null) Text(l.dailyActionRow(d.dailyAction!), textAlign: TextAlign.center),
          const SizedBox(height: 12),
          CalendarGrid(
            initialMonth: today,
            today: today,
            markOf: (day) {
              final c = b.checkinOn(day);
              if (c != null) return c.kind == CheckinKind.step ? DayMark.step : DayMark.rest;
              if (gaps.contains(day)) return DayMark.fell;
              return day > today ? DayMark.future : DayMark.none;
            },
          ),
          const SizedBox(height: 16),
          Text(l.memosTitle, style: t.titleSmall),
          if (memos.isEmpty)
            Text(l.noMemos, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim))
          else
            for (final c in memos) Text(l.memoRow(context.formatShortDate(c.date), c.memo!)),
          const SizedBox(height: 20),
          if (d.isActive) ...[
            FilledButton.icon(
              key: const Key('detail-complete'),
              onPressed: () => context.push(Routes.complete(d.id)),
              icon: const Icon(Icons.visibility),
              label: Text(l.completeAction),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              key: const Key('detail-retire'),
              onPressed: () => _retire(context, ref, d),
              child: Text(l.retireAction),
            ),
          ] else ...[
            Text(l.biggerPrompt, textAlign: TextAlign.center, style: t.bodySmall),
            const SizedBox(height: 8),
            FilledButton(
              key: const Key('detail-bigger'),
              onPressed: () => _bigger(context, ref, d),
              child: Text(l.makeBigger),
            ),
          ],
        ],
      ),
    );
  }
}
