import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/kigo.dart';
import '../../data/database.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'tanzaku_screen.dart';

/// 詠む。3行の入力、音数の目安、季語の検出、前書き。
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key, this.theme, this.editing, this.composedOn});

  /// 兼題（または歳時記から選んだ季語）。
  final Kigo? theme;

  /// 推敲するときの元の句。
  final HaikuRow? editing;

  /// 「昨日の分を詠む」のときの日付。
  final DateTime? composedOn;

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
  late final List<TextEditingController> _lines;
  late final TextEditingController _maegaki;
  bool _saving = false;

  static const _labels = ['上五', '中七', '下五'];
  static const _targets = [5, 7, 5];

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    final init = e == null ? ['', '', ''] : splitLines(e.body);
    _lines = [
      for (final s in init)
        TextEditingController(text: s)..addListener(_changed),
    ];
    _maegaki = TextEditingController(text: e?.maegaki ?? '');
  }

  void _changed() => setState(() {});

  @override
  void dispose() {
    for (final c in _lines) {
      c.dispose();
    }
    _maegaki.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final app = context.read<AppController>();
    final lines = [for (final c in _lines) c.text];
    if (lines.every((l) => l.trim().isEmpty)) return;
    setState(() => _saving = true);
    final HaikuRow row;
    if (widget.editing != null) {
      row = await app.revise(
        widget.editing!.id,
        lines: lines,
        maegaki: _maegaki.text,
      );
    } else {
      row = await app.addHaiku(
        lines: lines,
        maegaki: _maegaki.text,
        theme: widget.theme,
        composedOn: widget.composedOn,
      );
    }
    if (!mounted) return;
    if (widget.editing != null) {
      Navigator.pop(context, row);
    } else {
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => TanzakuScreen(haikuId: row.id)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppController>();
    final a = app.analyze([for (final c in _lines) c.text]);
    final theme = widget.theme;
    final editing = widget.editing != null;
    final title = editing
        ? '推敲する'
        : widget.composedOn != null
        ? '昨日の分を詠む'
        : '詠む';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          children: [
            if (theme != null && !editing)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Text(
                      '兼題　',
                      style: TextStyle(color: TanzakuTheme.inkDim),
                    ),
                    KigoChip(kigo: theme),
                  ],
                ),
              ),
            for (var i = 0; i < 3; i++) ...[
              TextField(
                key: Key('line-$i'),
                controller: _lines[i],
                style: TanzakuTheme.input,
                textInputAction: i < 2
                    ? TextInputAction.next
                    : TextInputAction.done,
                decoration: InputDecoration(
                  labelText: _labels[i],
                  hintText: i == 0 && theme != null ? theme.word : null,
                  suffixText: _lines[i].text.trim().isEmpty
                      ? null
                      : a.mora[i].label,
                  suffixStyle: TextStyle(
                    color: a.mora[i].count == _targets[i]
                        ? TanzakuTheme.inkDim
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
            _MoraSummary(analysis: a),
            const SizedBox(height: 12),
            _KigoPanel(analysis: a, theme: theme),
            const SizedBox(height: 16),
            TextField(
              key: const Key('maegaki'),
              controller: _maegaki,
              style: TanzakuTheme.inputSmall,
              decoration: const InputDecoration(
                labelText: '前書き（任意）',
                hintText: '詠んだ場所やきっかけ',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              key: const Key('save-haiku'),
              onPressed: a.isEmpty || _saving ? null : _save,
              child: Text(editing ? '推敲を保存' : '短冊にする'),
            ),
            const SizedBox(height: 8),
            const Text(
              '音数は目安です。漢字の読みは歳時記などの辞書にある語だけ数え、ないものは1字2音として「約」を付けています。字余り・字足らずもそのまま残せます。',
              style: TextStyle(color: TanzakuTheme.inkDim, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoraSummary extends StatelessWidget {
  const _MoraSummary({required this.analysis});
  final DraftAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    if (analysis.isEmpty) return const SizedBox.shrink();
    final parts = [
      for (final m in analysis.mora)
        if (m.count > 0) '${m.count}',
    ].join('・');
    final total = analysis.total;
    return Semantics(
      label: '音数の目安',
      child: Text(
        '音数の目安　$parts（${total.label}）　${analysis.note}',
        key: const Key('mora-summary'),
        style: const TextStyle(color: TanzakuTheme.inkDim),
      ),
    );
  }
}

class _KigoPanel extends StatelessWidget {
  const _KigoPanel({required this.analysis, required this.theme});
  final DraftAnalysis analysis;
  final Kigo? theme;

  @override
  Widget build(BuildContext context) {
    if (analysis.isEmpty) return const SizedBox.shrink();
    final kigo = analysis.detection.kigo;
    if (kigo.isEmpty) {
      return const Text(
        '季語：見つかりません（無季として残せます）',
        key: Key('kigo-none'),
        style: TextStyle(color: TanzakuTheme.inkDim),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('季語', style: TextStyle(color: TanzakuTheme.inkDim)),
            for (final k in kigo) KigoChip(key: Key('kigo-${k.id}'), kigo: k),
          ],
        ),
        if (analysis.detection.kigasanari)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '季重なり：${kigo.map((k) => k.word).join('と')}が季語です。意図したものならそのままで大丈夫です。',
              key: const Key('kigasanari'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          ),
      ],
    );
  }
}
