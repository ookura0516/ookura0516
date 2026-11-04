import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import 'archive_screen.dart';
import 'puzzle_screen.dart';
import 'settings_screen.dart';

/// 起動すると、その日の問題がすぐに出る（タイトル画面は置かない）。
/// 初回だけ、先にチュートリアル問を出す。
class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    if (!app.settings.tutorialDone) {
      return PuzzleScreen(key: const ValueKey('tutorial'), entry: app.tutorial);
    }
    final entry = app.todayEntry;
    if (entry == null) return const _NoPuzzle();
    // 日付が替わったら作り直す。
    return PuzzleScreen(
      key: ValueKey('day-${entry.day}'),
      entry: entry,
      isToday: true,
    );
  }
}

class _NoPuzzle extends StatelessWidget {
  const _NoPuzzle();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final first = app.clock.firstDay;
    return Scaffold(
      appBar: AppBar(
        title: const Text('ヨンクミ'),
        actions: [
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
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            app.today < 1
                ? '第1問は${first.month}月${first.day}日に出ます'
                : '問題を読み込めませんでした。アプリを更新してください',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
