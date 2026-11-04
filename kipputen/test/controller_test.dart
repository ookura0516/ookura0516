import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/expr.dart';
import 'package:kipputen/daily/daily.dart';
import 'package:kipputen/data/records.dart';
import 'package:kipputen/monetize/products.dart';
import 'package:kipputen/ui/app_controller.dart';
import 'package:kipputen/ui/ticket_design.dart';

import 'helpers.dart';

Expr ex(String s) => parse(tokenize(s));

void main() {
  final day = Day(2026, 11, 4); // 4027（ふつう）

  test('今日の切符を解くと、記録・連続日数・ウィジェットが更新される', () async {
    final h = await makeHarness(day);
    final app = h.app;
    expect(app.todayPuzzle.number, '4027');
    app.openToday();
    expect(app.solvedToday(), isFalse);

    final r = await app.submit(
      '4027',
      ex('7 × 2 − 4 + 0'),
      daily: true,
      seconds: 42,
    );
    expect(r.judgement.isCorrect, isTrue);
    expect(r.firstSolve, isTrue);
    expect(app.solvedToday(), isTrue);
    expect(app.streak.current, 1);
    expect(app.averageSeconds, 42);
    expect(app.remaining('4027'), app.goalFor('4027') - 1);

    final last = h.sink.saved.last;
    expect(last['day_20261104_title'], '4027');
    expect(last['day_20261104_done'], '1');
    expect(last['day_20261105_done'], '0');
    expect(h.sink.refreshed.last.first, DateTime.utc(2026, 11, 4, 15));
  });

  test('同じ解（並べ替えただけ）は2回数えない', () async {
    final h = await makeHarness(day);
    await h.app.submit('4027', ex('7 × 2 − 4 + 0'));
    final again = await h.app.submit('4027', ex('0 + 2 × 7 − 4'));
    expect(again.judgement.isCorrect, isTrue);
    expect(again.newlyFound, isFalse);
    expect(h.app.foundCount('4027'), 1);
  });

  test('全解は5つまで。5つで「完」', () async {
    final h = await makeHarness(day);
    final sols = h.app.solutionsFor('5839');
    expect(sols.length, greaterThan(solutionCap));
    expect(h.app.goalFor('5839'), solutionCap);
    for (var i = 0; i < solutionCap; i++) {
      final r = await h.app.submit('5839', ex(sols[i].display));
      expect(r.completed, i == solutionCap - 1);
    }
    expect(h.app.recordOf('5839')!.allFound, isTrue);
    // 6つ目も記録はするが「完」は1回だけ。
    final r6 = await h.app.submit('5839', ex(sols[5].display));
    expect(r6.newlyFound, isTrue);
    expect(r6.completed, isFalse);
  });

  test('解が1つの番号は1つで「完」', () async {
    final h = await makeHarness(day);
    final r = await h.app.submit('1199', ex('9 × (1 + 1 ÷ 9)'));
    expect(r.completed, isTrue);
  });

  test('記録は端末に残る（読み直しても同じ）', () async {
    final h = await makeHarness(day);
    h.app.openToday();
    await h.app.submit('4027', ex('7 × 2 − 4 + 0'), daily: true, seconds: 10);
    await h.app.updateSettings((s) => s.birthday = '0516');
    final again = Records(h.prefs);
    expect(again.solved['4027']!.found.length, 1);
    expect(again.plays['20261104']!.cleared, isTrue);
    expect(again.settings.birthday, '0516');
  });

  test('連続日数：前日に解いていれば2日', () async {
    final h = await makeHarness(day.addDays(-1));
    final y = h.app.todayPuzzle;
    final sol = h.app.solutionsFor(y.number).first.display;
    await h.app.submit(y.number, ex(sol), daily: true);
    final h2 = await makeHarness(day, reuse: true);
    await h2.app.submit('4027', ex('7 × 2 − 4 + 0'), daily: true);
    expect(h2.app.streak.current, 2);
  });

  test('評価依頼は初回利用日には出さず、初めての全解で出す', () async {
    final h = await makeHarness(day);
    h.app.openToday();
    await h.app.submit('1199', ex('9 × (1 + 1 ÷ 9)'));
    expect(h.review.asked, 0);

    final h2 = await makeHarness(day.addDays(3), reuse: true);
    await h2.app.submit('1158', ex('8 ÷ (1 − 1 ÷ 5)'));
    // 2つ目の全解なので「初めての全解」ではない。
    expect(h2.review.asked, 0);

    final h3 = await makeHarness(
      day.addDays(3),
      prefs: {
        'kipputen.play_log.v1':
            '[{"d":"20261101","n":"5045","s":null,"c":false}]',
      },
    );
    await h3.app.submit('1199', ex('9 × (1 + 1 ÷ 9)'));
    expect(h3.review.asked, 1);
  });

  test('デザインパックは買うまで使えない', () async {
    final h = await makeHarness(day);
    await h.app.updateSettings((s) => s.design = 'sakura');
    expect(h.app.design.id, TicketDesign.standard.id);
    await h.app.purchases.buy(Product.designPack);
    expect(h.app.design.id, 'sakura');
  });

  test('広告削除を買うとバナーを出さない', () async {
    final h = await makeHarness(day);
    expect(h.app.showAds, isTrue);
    await h.app.purchases.buy(Product.removeAds);
    expect(h.app.showAds, isFalse);
  });

  test('事前計算に当たらない正解はログに残す', () async {
    final h = await makeHarness(day);
    // 本物の本では起きないので、記録の仕組みだけ確かめる。
    h.app.records.newSolutionLog.add('1158: x');
    await h.app.records.saveNewSolutions();
    expect(Records(h.prefs).newSolutionLog, ['1158: x']);
  });
}
