import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/entry.dart';
import '../../core/expr.dart';
import '../../core/judge.dart';
import '../../daily/daily.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/ticket.dart';
import 'how_to.dart';
import 'share_screen.dart';
import 'solutions_screen.dart';

/// 切符1枚を解く画面。今日の切符（[daily]）と、図鑑からの練習の両方で使う。
class PlayScreen extends StatefulWidget {
  const PlayScreen({
    super.key,
    required this.number,
    required this.daily,
    this.day,
    this.serial,
    this.caption,
  });

  final String number;
  final bool daily;

  /// 切符の日付。練習なら今日。
  final Day? day;
  final int? serial;
  final String? caption;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen>
    with SingleTickerProviderStateMixin {
  late Entry _entry = Entry(widget.number);
  late final AnimationController _punch = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 520),
  );
  final Stopwatch _watch = Stopwatch()..start();
  Timer? _tick;
  String? _message;
  bool _messageIsError = false;

  /// 直前に正解した式。入力が空のあいだ切符に印字しておく。
  String? _lastSolved;

  @override
  void initState() {
    super.initState();
    final app = context.read<AppController>();
    if (widget.daily) app.openToday();
    if (app.foundCount(widget.number) > 0) {
      _punch.value = 1;
      final found = app.foundDisplays(widget.number);
      _lastSolved = found.isEmpty ? null : found.last;
    }
    _tick = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && app.settings.showTimer) setState(() {});
    });
  }

  @override
  void didUpdateWidget(PlayScreen old) {
    super.didUpdateWidget(old);
    if (old.number != widget.number) {
      _entry = Entry(widget.number);
      _lastSolved = null;
      _message = null;
      _punch.value = 0;
      _watch.reset();
    }
  }

  @override
  void dispose() {
    _tick?.cancel();
    _punch.dispose();
    super.dispose();
  }

  void _edit(void Function(Entry e) f) {
    setState(() {
      f(_entry);
      _message = null;
    });
    if (_entry.isComplete) _judge();
  }

  Future<void> _judge() async {
    final app = context.read<AppController>();
    final expr = _entry.expr!;
    final text = _entry.text;
    final res = await app.submit(
      widget.number,
      expr,
      inputText: text,
      daily: widget.daily,
      seconds: _watch.elapsed.inSeconds,
    );
    if (!mounted) return;
    final j = res.judgement;
    switch (j.verdict) {
      case Verdict.notTen:
        _show('= ${j.value}。10 になりません', error: true);
      case Verdict.divByZero:
        _show('0 では割れません', error: true);
      case Verdict.wrongDigits:
        _show('4つの数字を1回ずつ使ってください', error: true);
      case Verdict.correct:
        final left = app.remaining(widget.number);
        setState(() {
          _lastSolved = j.display;
          _entry = Entry(widget.number);
        });
        if (res.firstSolve || _punch.value < 1) {
          _punch.forward(from: 0);
        }
        if (!res.newlyFound) {
          _show('その解はもう見つけています');
        } else if (res.completed) {
          _show('全部見つけました。完！');
        } else if (j.isNewSolution) {
          _show('新しい解です！ あと$left通り');
        } else if (left > 0) {
          _show('正解！ あと$left通り');
        } else {
          _show('正解！');
        }
    }
  }

  void _show(String m, {bool error = false}) => setState(() {
    _message = m;
    _messageIsError = error;
  });

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final number = widget.number;
    final solved = app.foundCount(number) > 0;
    final day = widget.day ?? app.today;
    final shown = _entry.isEmpty
        ? (_lastSolved == null ? null : '$_lastSolved = 10')
        : _entry.text;
    final preview = _entry.preview;
    final goal = app.goalFor(number);
    final found = app.foundCount(number);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.daily ? '今日の切符' : '練習 $number'),
        actions: [
          IconButton(
            tooltip: '遊び方',
            icon: const Icon(Icons.help_outline),
            onPressed: () => showHowTo(context),
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, c) {
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AnimatedBuilder(
                        animation: _punch,
                        builder: (context, _) => Ticket(
                          design: app.design,
                          number: number,
                          dateText: day.dotted,
                          serial: widget.serial,
                          expression: shown,
                          punch: _punch.value,
                          caption: widget.caption,
                        ),
                      ),
                      const SizedBox(height: 10),
                      _StatusRow(
                        solved: solved,
                        found: found,
                        goal: goal,
                        seconds: app.settings.showTimer && !solved
                            ? _watch.elapsed.inSeconds
                            : null,
                      ),
                      const SizedBox(height: 6),
                      _PreviewLine(
                        preview: preview,
                        message: _message,
                        error: _messageIsError,
                      ),
                      const SizedBox(height: 10),
                      _DigitKeys(
                        entry: _entry,
                        onTap: (s) => _edit((e) => e.addDigit(s)),
                      ),
                      const SizedBox(height: 10),
                      _OpKeys(entry: _entry, onEdit: _edit),
                      if (solved) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                key: const Key('open-solutions'),
                                icon: const Icon(Icons.flip),
                                label: Text('切符の裏 $found/$goal'),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        SolutionsScreen(number: number),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton.icon(
                                key: const Key('open-share'),
                                icon: const Icon(Icons.ios_share),
                                label: const Text('共有'),
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => ShareScreen(
                                      number: number,
                                      day: day,
                                      serial: widget.serial,
                                      caption: widget.caption,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({
    required this.solved,
    required this.found,
    required this.goal,
    this.seconds,
  });

  final bool solved;
  final int found;
  final int goal;
  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final left = goal - found;
    final text = !solved
        ? '4つの数字で 10 を作ろう'
        : left <= 0
        ? '全解 $found/$goal　完'
        : '解けた！ あと$left通り';
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            key: const Key('status'),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: KipTheme.ink,
            ),
          ),
        ),
        if (seconds != null)
          Text(
            '${seconds! ~/ 60}:${(seconds! % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(color: KipTheme.inkDim),
          ),
      ],
    );
  }
}

class _PreviewLine extends StatelessWidget {
  const _PreviewLine({
    required this.preview,
    required this.message,
    required this.error,
  });

  final Preview preview;
  final String? message;
  final bool error;

  @override
  Widget build(BuildContext context) {
    final String text;
    var color = KipTheme.inkDim;
    if (message != null) {
      text = message!;
      color = error ? KipTheme.punch : KipTheme.accent;
    } else if (preview.divByZero) {
      text = '途中結果：0 で割っています';
      color = KipTheme.punch;
    } else if (preview.value != null) {
      text = '途中結果 = ${preview.value}';
    } else {
      text = ' ';
    }
    return Text(
      text,
      key: const Key('preview'),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 15, color: color),
    );
  }
}

class _DigitKeys extends StatelessWidget {
  const _DigitKeys({required this.entry, required this.onTap});

  final Entry entry;
  final void Function(int slot) onTap;

  @override
  Widget build(BuildContext context) {
    final used = entry.usedSlots;
    return Row(
      children: [
        for (var i = 0; i < 4; i++)
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: used.contains(i) ? 0.0 : 1.0,
                child: SizedBox(
                  height: 64,
                  child: FilledButton(
                    key: Key('digit-$i'),
                    style: FilledButton.styleFrom(
                      backgroundColor: KipTheme.ink,
                      foregroundColor: KipTheme.surface,
                      textStyle: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    onPressed: entry.canDigit(i) ? () => onTap(i) : null,
                    child: Text(entry.number[i]),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _OpKeys extends StatelessWidget {
  const _OpKeys({required this.entry, required this.onEdit});

  final Entry entry;
  final void Function(void Function(Entry e) f) onEdit;

  @override
  Widget build(BuildContext context) {
    Widget key(
      String label,
      String id,
      bool enabled,
      void Function(Entry) f, {
      String? semantics,
    }) => Expanded(
      child: Padding(
        padding: const EdgeInsets.all(3),
        child: SizedBox(
          height: 52,
          child: OutlinedButton(
            key: Key('key-$id'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.zero,
              textStyle: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: enabled ? () => onEdit(f) : null,
            child: Semantics(label: semantics, child: Text(label)),
          ),
        ),
      ),
    );
    return Column(
      children: [
        Row(
          children: [
            for (final op in Op.values)
              key(op.symbol, op.name, entry.canOp, (e) => e.addOp(op)),
          ],
        ),
        Row(
          children: [
            key('(', 'open', entry.canOpen, (e) => e.open()),
            key(')', 'close', entry.canClose, (e) => e.close()),
            key(
              '⌫',
              'back',
              !entry.isEmpty,
              (e) => e.backspace(),
              semantics: '1つ消す',
            ),
            key(
              'C',
              'clear',
              !entry.isEmpty,
              (e) => e.clear(),
              semantics: '全部消す',
            ),
          ],
        ),
      ],
    );
  }
}
