import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/game_session.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/result_grid.dart';
import 'purchase_sheet.dart';
import 'puzzle_screen.dart';
import 'result_screen.dart';

/// 過去の問題。解いた日は結果グリッドがサムネイルになる。
/// 無料は直近7日分。それより前は全問パックで開く。
class ArchiveScreen extends StatelessWidget {
  const ArchiveScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final days = app.archiveDays;
    return Scaffold(
      appBar: AppBar(title: const Text('アーカイブ')),
      body: days.isEmpty
          ? const Center(child: Text('まだ問題がありません'))
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: days.length + 1,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) {
                if (i == 0) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                    child: Text(
                      app.purchases.owned
                          ? 'すべての問題を遊べます'
                          : '無料で遊べるのは直近$kFreeArchiveDays日分です。'
                                'それより前は全問パックで開きます。',
                      style: const TextStyle(color: YonkumiTheme.inkDim),
                    ),
                  );
                }
                return _DayTile(day: days[i - 1]);
              },
            ),
    );
  }
}

class _DayTile extends StatelessWidget {
  const _DayTile({required this.day});

  final int day;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final date = app.clock.dateOf(day);
    final record = app.recordFor(day);
    final locked = app.isLocked(day);
    final inProgress = record == null && app.log.progressFor(day).isNotEmpty;
    final status = record == null
        ? (inProgress ? '解きかけ' : '未挑戦')
        : record.perfect
        ? 'パーフェクト'
        : record.cleared
        ? 'クリア'
        : '失敗';
    final rerun = app.schedule.isRerun(day);
    Widget? thumb;
    if (record != null) {
      final entry = app.entryFor(day);
      if (entry != null) {
        thumb = ResultGrid(
          rows: resultGrid(entry.puzzle, record.guesses),
          cell: 7,
          gap: 1.5,
        );
      }
    }
    return ListTile(
      key: ValueKey('day-$day'),
      leading: SizedBox(
        width: 40,
        child: Center(
          child:
              thumb ??
              Icon(
                locked ? Icons.lock_outline : Icons.grid_view,
                color: YonkumiTheme.inkDim,
              ),
        ),
      ),
      title: Text('第$day問${day == app.today ? '（今日）' : ''}'),
      subtitle: Text(
        '${date.month}月${date.day}日・$status${rerun ? '・再出題' : ''}',
      ),
      trailing: locked ? const Icon(Icons.lock_outline, size: 18) : null,
      onTap: () {
        if (locked) {
          showPurchaseSheet(context);
          return;
        }
        final entry = app.entryFor(day);
        if (entry == null) return;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => record != null
                ? ResultScreen(entry: entry)
                : PuzzleScreen(entry: entry),
          ),
        );
      },
    );
  }
}
