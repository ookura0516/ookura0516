import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_session.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/board.dart';
import 'archive_screen.dart';
import 'result_screen.dart';
import 'settings_screen.dart';

/// 問題を解く画面（今日の問題・アーカイブ・チュートリアル）。
class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({super.key, required this.entry, this.isToday = false});

  final PuzzleEntry entry;

  /// 起動直後の「今日の問題」として出しているか（上にメニューを出す）。
  final bool isToday;

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  String? _message;
  int _messageSerial = 0;

  PuzzleEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final s = app.sessionFor(entry);
    final colorNames = app.settings.colorNames;
    final date = entry.date;
    return Scaffold(
      appBar: AppBar(
        title: Text(entry.isTutorial ? '遊び方の問題' : '第${entry.day}問'),
        actions: [
          if (widget.isToday) ...[
            IconButton(
              tooltip: 'アーカイブ',
              icon: const Icon(Icons.calendar_month_outlined),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const ArchiveScreen())),
            ),
            IconButton(
              tooltip: '設定',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen())),
            ),
          ],
          if (entry.isTutorial && !app.settings.tutorialDone)
            TextButton(onPressed: app.skipTutorial, child: const Text('とばす')),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              children: [
                if (entry.isTutorial)
                  const _Hint(
                    '16語の中から、同じ仲間の4語を選んで「決定」。'
                    '4組すべて当てればクリアです。間違えられるのは4回まで。',
                  )
                else
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      [
                        if (date != null) '${date.month}月${date.day}日',
                        if (entry.rerun) '再出題',
                        '4語ずつ4組に分ける',
                      ].join('・'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: YonkumiTheme.inkDim),
                    ),
                  ),
                for (final g in s.solved)
                  SolvedBand(group: g, colorNames: colorNames),
                if (s.failed)
                  for (final g in s.unsolved)
                    SolvedBand(
                      group: g,
                      colorNames: colorNames,
                      revealed: true,
                    ),
                if (!s.finished)
                  TileGrid(
                    words: s.board,
                    selected: s.selected,
                    onTap: (w) => setState(() => s.toggle(w)),
                  ),
                const SizedBox(height: 8),
                MistakesLeft(
                  left: s.mistakesLeft,
                  max: GameSession.maxMistakes,
                ),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: Text(
                        _message ?? '',
                        key: ValueKey(_messageSerial),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ),
                if (!s.finished)
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => setState(() {
                            s.shuffle();
                            _message = null;
                          }),
                          child: const Text('シャッフル'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: s.selected.isEmpty
                              ? null
                              : () => setState(s.deselectAll),
                          child: const Text('選択解除'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: s.canSubmit ? () => _submit(app, s) : null,
                          child: const Text('決定'),
                        ),
                      ),
                    ],
                  )
                else
                  FilledButton(
                    onPressed: () => _openResult(context),
                    child: const Text('結果を見る'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit(AppController app, GameSession s) async {
    final r = s.submit();
    setState(() {
      _messageSerial++;
      _message = switch (r) {
        SubmitResult.correct => '正解！「${s.solved.last.title}」',
        SubmitResult.oneAway => s.failed ? '残念、あと1つでした' : 'あと1つ！',
        SubmitResult.wrong => s.failed ? '間違いが4回になりました' : 'ちがいます',
        SubmitResult.alreadyTried => 'その4語はもう試しました',
      };
    });
    await app.afterSubmit(entry, s);
    if (s.finished && mounted) _openResult(context);
  }

  void _openResult(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ResultScreen(entry: entry)));
  }
}

class _Hint extends StatelessWidget {
  const _Hint(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Text(text, style: const TextStyle(height: 1.5)),
      ),
    );
  }
}
