import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/local_date.dart';
import '../../core/rules.dart';
import '../../data/presets.dart';
import '../../data/repository.dart';
import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/actions.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';
import '../widgets/daruma_view.dart';

/// だるま作成：腹の文字、色、本番の日（任意）、毎日の一歩（任意）。30秒で終わる。
class NewDarumaScreen extends ConsumerStatefulWidget {
  const NewDarumaScreen({super.key, this.parentId, this.sizeRank, this.presetName});

  /// 「ひと回り大きいだるま」のやり直し元。
  final int? parentId;
  final int? sizeRank;
  final String? presetName;

  @override
  ConsumerState<NewDarumaScreen> createState() => _NewDarumaScreenState();
}

class _NewDarumaScreenState extends ConsumerState<NewDarumaScreen> {
  static const _nameChips = ['合格', '必勝', '英語', '走る', '貯金', '家内安全'];

  late final TextEditingController _name = TextEditingController(text: widget.presetName ?? '');
  final _deadlineName = TextEditingController();
  final _dailyAction = TextEditingController();
  DarumaColor _color = DarumaColor.red;
  LocalDate? _deadline;
  bool _submitting = false;
  bool _nameTouched = false;

  @override
  void dispose() {
    _name.dispose();
    _deadlineName.dispose();
    _dailyAction.dispose();
    super.dispose();
  }

  bool get _nameOk => Rules.isValidName(_name.text);

  Future<void> _pickPreset() async {
    final preset = await context.push<ExamPreset>('/presets');
    if (preset == null) return;
    setState(() {
      _deadline = preset.date;
      _deadlineName.text = preset.short;
    });
  }

  Future<void> _pickDate() async {
    final today = ref.read(todayProvider);
    final picked = await showDatePicker(
      context: context,
      initialDate: (_deadline ?? today.addDays(30)).toLocalDateTime(),
      firstDate: today.toLocalDateTime(),
      lastDate: today.addDays(366 * 3).toLocalDateTime(),
    );
    if (picked == null) return;
    setState(() => _deadline = LocalDate.fromDateTime(picked));
  }

  Future<void> _submit() async {
    setState(() => _nameTouched = true);
    if (!_nameOk || _submitting) return;
    setState(() => _submitting = true);
    final l = L10n.of(context);
    final eyeSide = ref.read(settingsProvider).defaultEyeSide;
    try {
      final d = await ref.read(actionsProvider).create(NewDaruma(
            name: _name.text.trim(),
            color: _color,
            eyeSide: eyeSide,
            deadline: _deadline,
            deadlineLabel: _deadline == null
                ? null
                : (_deadlineName.text.trim().isEmpty ? l.homeDeadlineDefault : _deadlineName.text.trim()),
            dailyAction: _dailyAction.text.trim().isEmpty ? null : _dailyAction.text.trim(),
            parentId: widget.parentId,
            sizeRank: widget.sizeRank ?? 1,
          ));
      if (mounted) context.go('/new/eye/${d.id}');
    } on ActiveDarumaExists {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l.activeExistsTitle),
          content: Text(l.activeExistsBody),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.ok))],
        ),
      );
      if (mounted) context.go('/');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = L10n.of(context);
    final today = ref.watch(todayProvider);
    final eyeSide = ref.watch(settingsProvider).defaultEyeSide;
    final preview = DarumaLook(
      color: _color,
      text: _name.text.trim().isEmpty ? '合格' : _name.text.trim(),
      openedEyes: 0,
      eyeSide: eyeSide,
      sizeRank: widget.sizeRank ?? 1,
      seed: 5,
    );
    final colorNames = {
      DarumaColor.red: l.colorRed,
      DarumaColor.white: l.colorWhite,
      DarumaColor.black: l.colorBlack,
    };
    final colorSwatches = {
      DarumaColor.red: NanakorobiTheme.red,
      DarumaColor.white: const Color(0xFFF4EFE6),
      DarumaColor.black: const Color(0xFF2B2B2E),
    };
    return Scaffold(
      appBar: AppBar(title: Text(l.newTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            SizedBox(height: 220, child: DarumaView(preview, animate: false)),
            const SizedBox(height: 12),
            Text(l.nameLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('name'),
              controller: _name,
              maxLength: 6,
              decoration: InputDecoration(
                hintText: l.nameHint,
                errorText: _nameTouched && !_nameOk ? l.nameError : null,
              ),
              onChanged: (_) => setState(() => _nameTouched = true),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final n in _nameChips)
                  ChoiceChip(
                    label: Text(n),
                    selected: _name.text == n,
                    onSelected: (_) => setState(() {
                      _name.text = n;
                      _nameTouched = true;
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            Text(l.colorLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final c in DarumaColor.values) ...[
                  Expanded(
                    child: ChoiceChip(
                      key: Key('color-${c.name}'),
                      avatar: CircleAvatar(backgroundColor: colorSwatches[c], radius: 9),
                      label: Center(child: Text(colorNames[c]!)),
                      selected: _color == c,
                      onSelected: (_) => setState(() => _color = c),
                    ),
                  ),
                  if (c != DarumaColor.values.last) const SizedBox(width: 8),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Text(l.colorNote, style: const TextStyle(fontSize: 12, color: NanakorobiTheme.inkDim)),
            const SizedBox(height: 20),
            Text(l.deadlineLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _deadline == null
                                ? l.deadlineNone
                                : '${formatDate(_deadline!)}  ${l.presetsDaysLeft(Rules.daysLeft(_deadline!, today))}',
                            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (_deadline != null)
                          TextButton(
                            onPressed: () => setState(() {
                              _deadline = null;
                              _deadlineName.clear();
                            }),
                            child: Text(l.clearDeadline),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('pick-preset'),
                            onPressed: _pickPreset,
                            child: Text(l.pickFromPresets),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            key: const Key('pick-date'),
                            onPressed: _pickDate,
                            child: Text(l.pickDate),
                          ),
                        ),
                      ],
                    ),
                    if (_deadline != null) ...[
                      const SizedBox(height: 10),
                      TextField(
                        controller: _deadlineName,
                        maxLength: 12,
                        decoration: InputDecoration(
                          labelText: l.deadlineNameLabel,
                          hintText: l.deadlineNameHint,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(l.dailyActionLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              key: const Key('daily-action'),
              controller: _dailyAction,
              maxLength: 20,
              decoration: InputDecoration(hintText: l.dailyActionHint),
            ),
            const SizedBox(height: 20),
            FilledButton(
              key: const Key('to-eye'),
              onPressed: _submitting ? null : _submit,
              child: Text(l.toEye),
            ),
          ],
        ),
      ),
    );
  }
}
