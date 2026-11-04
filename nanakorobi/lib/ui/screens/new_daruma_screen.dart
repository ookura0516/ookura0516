import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/entitlements.dart';
import '../../core/local_date.dart';
import '../../core/validation.dart';
import '../../model/models.dart';
import '../../state/create_daruma.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/common.dart';
import '../widgets/l10n_ext.dart';

/// だるま作成：目標名（腹の文字）、色、本番の日、通過点、毎日の一歩。30秒で終わる。
class NewDarumaScreen extends ConsumerStatefulWidget {
  const NewDarumaScreen({super.key});

  @override
  ConsumerState<NewDarumaScreen> createState() => _NewDarumaScreenState();
}

class _NewDarumaScreenState extends ConsumerState<NewDarumaScreen> {
  late final TextEditingController _name;
  late final TextEditingController _action;
  late final TextEditingController _deadlineName;

  @override
  void initState() {
    super.initState();
    final f = ref.read(createDarumaProvider);
    _name = TextEditingController(text: f.name);
    _action = TextEditingController(text: f.dailyAction);
    _deadlineName = TextEditingController(text: f.deadlineName ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _action.dispose();
    _deadlineName.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: today.addDays(30).toDateTime(),
      firstDate: today.toDateTime(),
      lastDate: today.addDays(365 * 3).toDateTime(),
    );
    if (picked == null) return;
    ref.read(createDarumaProvider.notifier).setDeadline(
          LocalDate.fromDateTime(picked),
          name: _deadlineName.text,
        );
  }

  Future<void> _pickPreset() async {
    final preset = await context.push<ExamPreset>(Routes.presets);
    if (preset == null) return;
    ref.read(createDarumaProvider.notifier).setDeadlineFromPreset(preset);
    _deadlineName.text = preset.name;
  }

  Future<void> _addWaypoint() async {
    final l = context.l10n;
    final today = ref.read(todayProvider);
    final name = TextEditingController();
    LocalDate? date;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l.waypointDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                key: const Key('waypoint-name'),
                controller: name,
                decoration: InputDecoration(hintText: l.waypointNameHint),
                maxLength: 20,
              ),
              OutlinedButton(
                key: const Key('waypoint-date'),
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: today.addDays(14).toDateTime(),
                    firstDate: today.toDateTime(),
                    lastDate: today.addDays(365 * 3).toDateTime(),
                  );
                  if (picked != null) setState(() => date = LocalDate.fromDateTime(picked));
                },
                child: Text(date == null ? l.deadlinePick : context.formatDate(date!)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l.cancel)),
            FilledButton(
              key: const Key('waypoint-ok'),
              onPressed: () => Navigator.pop(context, name.text.trim().isNotEmpty && date != null),
              child: Text(l.ok),
            ),
          ],
        ),
      ),
    );
    if (ok == true && date != null) {
      ref.read(createDarumaProvider.notifier).addWaypoint(WaypointInput(name: name.text.trim(), date: date!));
    }
    name.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final form = ref.watch(createDarumaProvider);
    final notifier = ref.read(createDarumaProvider.notifier);
    final hasPlus = ref.watch(hasPlusProvider);
    final activeCount = ref.watch(activeDarumasProvider).length;
    final blocked = !Entitlements.canAddActive(activeCount: activeCount, hasPlus: hasPlus);
    final t = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(form.isBigger ? l.newBiggerTitle : l.newTitle)),
      body: blocked
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l.freeActiveLimit, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('new-to-paywall'),
                      onPressed: () => context.push(Routes.paywallFrom(PaywallEntry.secondDaruma.name)),
                      child: Text(l.paywallEntrySecond),
                    ),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                if (form.isBigger) ...[
                  Text(l.newBiggerBody, style: t.bodyMedium),
                  const SizedBox(height: 12),
                ],
                Text(l.nameLabel, style: t.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('name-field'),
                  controller: _name,
                  maxLength: Limits.nameMax,
                  onChanged: notifier.setName,
                  decoration: InputDecoration(
                    hintText: l.nameHint,
                    errorText: form.name.isNotEmpty && !form.nameOk ? l.nameError : null,
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final p in Limits.namePresets)
                      ActionChip(
                        key: Key('name-preset-$p'),
                        label: Text(p),
                        onPressed: () {
                          _name.text = p;
                          notifier.setName(p);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(l.colorLabel, style: t.titleSmall),
                const SizedBox(height: 8),
                ColorPicker(
                  selected: form.colorId,
                  hasPlus: hasPlus,
                  onSelect: notifier.setColor,
                  onLocked: () => context.push(Routes.paywallFrom(PaywallEntry.secondDaruma.name)),
                ),
                const SizedBox(height: 6),
                Text(colorNote(l, form.colorId), style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
                Text(l.colorNoteDisclaimer, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
                if (!hasPlus) Text(l.colorLocked, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
                const SizedBox(height: 20),
                Text(l.deadlineLabel, style: t.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('deadline-preset'),
                      onPressed: _pickPreset,
                      icon: const Icon(Icons.school_outlined),
                      label: Text(l.deadlinePreset),
                    ),
                    OutlinedButton.icon(
                      key: const Key('deadline-date'),
                      onPressed: _pickDate,
                      icon: const Icon(Icons.calendar_month_outlined),
                      label: Text(form.deadline == null ? l.deadlinePick : context.formatDate(form.deadline!)),
                    ),
                    if (form.deadline != null)
                      TextButton(
                        key: const Key('deadline-clear'),
                        onPressed: () => notifier.setDeadline(null),
                        child: Text(l.deadlineClear),
                      ),
                  ],
                ),
                if (form.deadline != null) ...[
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('deadline-name'),
                    controller: _deadlineName,
                    maxLength: 30,
                    decoration: InputDecoration(hintText: l.deadlineNameHint),
                    onChanged: (v) => notifier.setDeadline(form.deadline, name: v, presetId: form.deadlinePresetId),
                  ),
                ],
                const SizedBox(height: 12),
                Text(l.waypointsLabel, style: t.titleSmall),
                for (var i = 0; i < form.waypoints.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(form.waypoints[i].name),
                    subtitle: Text(context.formatDate(form.waypoints[i].date)),
                    trailing: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => notifier.removeWaypoint(i),
                    ),
                  ),
                if (form.waypoints.length < Limits.waypointsMax)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      key: const Key('waypoint-add'),
                      onPressed: _addWaypoint,
                      icon: const Icon(Icons.add),
                      label: Text(l.waypointAdd),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(l.dailyActionLabel, style: t.titleSmall),
                const SizedBox(height: 6),
                TextField(
                  key: const Key('daily-action'),
                  controller: _action,
                  maxLength: 30,
                  onChanged: notifier.setDailyAction,
                  decoration: InputDecoration(hintText: l.dailyActionHintText),
                ),
                const SizedBox(height: 12),
                Text(l.eyeSideLabel, style: t.titleSmall),
                const SizedBox(height: 6),
                SegmentedButton<EyeSide>(
                  segments: [
                    ButtonSegment(value: EyeSide.left, label: Text(l.eyeLeft)),
                    ButtonSegment(value: EyeSide.right, label: Text(l.eyeRight)),
                  ],
                  selected: {form.eyeSide},
                  onSelectionChanged: (s) => notifier.setEyeSide(s.first),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  key: const Key('to-eye'),
                  onPressed: form.canProceed ? () => context.push(Routes.eye) : null,
                  child: Text(l.toEyeOpening),
                ),
              ],
            ),
    );
  }
}
