import 'package:flutter_test/flutter_test.dart';
import 'package:ookura_daily/ookura_daily.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yonkumi/core/axis.dart';
import 'package:yonkumi/core/schedule.dart';
import 'package:yonkumi/core/tutorial.dart';
import 'package:yonkumi/game/daily_notice.dart';
import 'package:yonkumi/game/play_log.dart';
import 'package:yonkumi/game/share_text.dart';
import 'package:yonkumi/game/stats.dart';
import 'package:yonkumi/game/widget_data.dart';

import 'fakes.dart';

PlayRecord rec(
  int day, {
  int? playedOn,
  bool cleared = true,
  int mistakes = 0,
  List<List<String>>? guesses,
}) => PlayRecord(
  day: day,
  puzzle: day,
  playedOnDay: playedOn ?? day,
  guesses: guesses ?? [for (final g in kTutorialPuzzle.groups) g.words],
  cleared: cleared,
  mistakes: mistakes,
);

void main() {
  group('連続日数', () {
    test('失敗した日も「解いた日」として数える', () {
      final s = PlayStats.compute(
        [rec(8), rec(9, cleared: false, mistakes: 4), rec(10)],
        today: 10,
        puzzleOf: (_) => kTutorialPuzzle,
      );
      expect(s.streak, const StreakSummary(current: 3, longest: 3));
    });

    test('あとからアーカイブで解いた日は数えない', () {
      final s = PlayStats.compute(
        [rec(8), rec(9, playedOn: 12), rec(10)],
        today: 10,
        puzzleOf: (_) => kTutorialPuzzle,
      );
      expect(s.streak.current, 1);
      expect(s.played, 3);
    });
  });

  test('成績は記録から集計する', () {
    final fruit = kTutorialPuzzle.groups[0].words;
    final s = PlayStats.compute(
      [
        rec(1),
        rec(2, mistakes: 2),
        rec(3, cleared: false, mistakes: 4, guesses: [fruit]),
      ],
      today: 3,
      puzzleOf: (_) => kTutorialPuzzle,
    );
    expect(s.played, 3);
    expect(s.cleared, 2);
    expect(s.perfect, 1);
    expect(s.averageMistakes, 2);
    expect(s.clearRate, closeTo(2 / 3, 1e-9));
    // 季語の組は3回出て、当てたのは2回
    expect(s.byAxis[AxisType.season]!.solved, 2);
    expect(s.byAxis[AxisType.season]!.total, 3);
    expect(s.byAxis[AxisType.manual]!.solved, 3);
  });

  test('記録は端末に残り、読み直せる', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final log = PlayLog(prefs);
    await log.saveProgress(5, [
      ['a', 'b', 'c', 'd'],
    ]);
    await log.finish(rec(4, mistakes: 1));
    final again = PlayLog(prefs);
    expect(again.recordFor(4)!.mistakes, 1);
    expect(again.progressFor(5), [
      ['a', 'b', 'c', 'd'],
    ]);
    // 同じ日の2回目の記録は上書きしない
    await again.finish(rec(4, mistakes: 3));
    expect(PlayLog(prefs).recordFor(4)!.mistakes, 1);
  });

  test('壊れた記録でも起動できる', () async {
    SharedPreferences.setMockInitialValues({'yonkumi.records.v1': '{oops'});
    final log = PlayLog(await SharedPreferences.getInstance());
    expect(log.records, isEmpty);
  });

  group('ウィジェット用データ', () {
    test('解いた日は「解決済み」、翌日分は未解決で連続は続く', () {
      final now = jst(2026, 11, 4, 20);
      final snap = widgetSnapshot(clock: kClock, now: now, streakDays: [3, 4]);
      expect(snap.today.title, '第4問');
      expect(snap.today.status, '解決済み');
      expect(snap.today.streak, 2);
      expect(snap.tomorrow.title, '第5問');
      expect(snap.tomorrow.done, isFalse);
      expect(snap.tomorrow.streak, 2);
      expect(snap.switchAt, DateTime.utc(2026, 11, 4, 15));
      expect(snap.entryAt(jst(2026, 11, 5, 0)), same(snap.tomorrow));
    });

    test('今日を解いていなければ、翌日には連続が0になる', () {
      final snap = widgetSnapshot(
        clock: kClock,
        now: jst(2026, 11, 4, 9),
        streakDays: [2, 3],
      );
      expect(snap.today.status, '未解決');
      expect(snap.today.streak, 2);
      expect(snap.tomorrow.streak, 0);
    });
  });

  group('通知の予約', () {
    test('文面は「第N問が出ました」だけ、1日1件', () {
      final n = planNotices(
        clock: kClock,
        now: jst(2026, 11, 4, 6),
        hour: 8,
        todayDone: false,
      );
      expect(n.length, 7);
      expect(n.first.body, '第4問が出ました');
      expect(n.first.at, jst(2026, 11, 4, 8));
      expect(n.last.body, '第10問が出ました');
    });

    test('今日はもう解いた・時刻を過ぎたなら翌日から', () {
      expect(
        planNotices(
          clock: kClock,
          now: jst(2026, 11, 4, 6),
          hour: 8,
          todayDone: true,
        ).first.body,
        '第5問が出ました',
      );
      expect(
        planNotices(
          clock: kClock,
          now: jst(2026, 11, 4, 9),
          hour: 8,
          todayDone: false,
        ).first.body,
        '第5問が出ました',
      );
    });
  });

  test('文字の結果は絵文字の四角で、答えを含まない', () {
    final t = shareText(
      day: 12,
      date: const CivilDate(2026, 11, 12),
      grid: [
        [1, 1, 2, 1],
        [1, 1, 1, 1],
        [4, 4, 4, 4],
        [2, 2, 2, 2],
        [3, 3, 3, 3],
      ],
      cleared: true,
      mistakes: 1,
      streak: 3,
    );
    expect(
      t,
      'ヨンクミ 第12問（11/12）\n'
      '🟧🟧🟥🟧\n🟧🟧🟧🟧\n⬛⬛⬛⬛\n🟥🟥🟥🟥\n🟫🟫🟫🟫\n'
      '間違い 1/4・連続3日\n#ヨンクミ',
    );
    // NYT の4色（黄・緑・青・紫）を使わない
    for (final c in ['🟨', '🟩', '🟦', '🟪']) {
      expect(t, isNot(contains(c)));
    }
  });

  test('失敗の文字結果', () {
    final t = shareText(
      day: 3,
      date: const CivilDate(2026, 11, 3),
      grid: [
        [1, 1, 1, 1],
        [2, 3, 2, 2],
        [2, 3, 3, 2],
        [4, 3, 2, 2],
        [3, 2, 4, 4],
      ],
      cleared: false,
      mistakes: 4,
      streak: 1,
    );
    expect(t, contains('間違い 4/4・あと3組'));
  });
}
