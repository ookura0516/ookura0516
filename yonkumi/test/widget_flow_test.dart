import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:yonkumi/core/puzzle.dart';
import 'package:yonkumi/ui/app_controller.dart';
import 'package:yonkumi/ui/screens/home.dart';
import 'package:yonkumi/ui/theme.dart';

import 'fakes.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _pump(WidgetTester tester, AppController app) async {
  _phone(tester);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(theme: YonkumiTheme.light, home: const Home()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// 4語を選んで決定する（前の選択は外してから）。
Future<void> _guess(WidgetTester tester, List<String> words) async {
  final clear = find.widgetWithText(OutlinedButton, '選択解除');
  if (clear.evaluate().isNotEmpty &&
      tester.widget<OutlinedButton>(clear).onPressed != null) {
    await tester.tap(clear);
    await tester.pump();
  }
  for (final w in words) {
    await tester.tap(find.byKey(ValueKey('tile-$w')));
  }
  await tester.pump();
  await tester.tap(find.text('決定'));
  await tester.pumpAndSettle();
}

/// 間違いの4語（2組から2語ずつ）。
List<String> _wrong(Puzzle p, int a, int b) => [
  ...p.groups[a].words.take(2),
  ...p.groups[b].words.take(2),
];

void main() {
  testWidgets('初回はチュートリアル問を出し、終えると今日の問題へ', (tester) async {
    final t = await TestApp.create(tutorialDone: false);
    await _pump(tester, t.controller);
    expect(find.text('遊び方の問題'), findsOneWidget);
    for (final g in t.controller.tutorial.puzzle.groups) {
      await _guess(tester, g.words);
    }
    expect(find.text('パーフェクト！'), findsOneWidget);
    expect(
      find.byKey(const Key('ad-banner')),
      findsNothing,
      reason: 'チュートリアルの結果に広告は出さない',
    );
    await _tap(tester, find.text('今日の問題へ'));
    expect(find.text('第20問'), findsOneWidget);
    expect(t.controller.settings.tutorialDone, isTrue);
    expect(t.controller.stats.played, 0, reason: 'チュートリアルは成績に数えない');
  });

  testWidgets('今日の問題：「あと1つ」、間違い、正解、結果と共有、広告削除', (tester) async {
    final t = await TestApp.create();
    await _pump(tester, t.controller);
    final p = t.controller.todayEntry!.puzzle;
    expect(find.text('第20問'), findsOneWidget);
    expect(
      find.byKey(const Key('ad-banner')),
      findsNothing,
      reason: '問題の画面に広告は出さない',
    );

    // 3語が同じ組
    await _guess(tester, [
      ...p.groups[0].words.take(3),
      p.groups[1].words.first,
    ]);
    expect(find.text('あと1つ！'), findsOneWidget);
    expect(find.bySemanticsLabel('あと3回まちがえられます'), findsOneWidget);

    // 間違えた4語は選んだまま。同じ4語でもう一度決定しても数えない
    await tester.tap(find.text('決定'));
    await tester.pumpAndSettle();
    expect(find.text('その4語はもう試しました'), findsOneWidget);
    expect(find.bySemanticsLabel('あと3回まちがえられます'), findsOneWidget);

    for (final g in p.groups) {
      await _guess(tester, g.words);
    }
    expect(find.text('クリア！（間違い1回）'), findsOneWidget);
    expect(find.text('5回の決定・連続1日'), findsOneWidget);

    // 文字で共有
    await _tap(tester, find.byKey(const Key('share-text')));
    final text = t.share.texts.single;
    expect(text, startsWith('ヨンクミ 第20問（11/20）'));
    expect(text, contains('#ヨンクミ'));
    for (final w in p.words) {
      expect(text, isNot(contains(w)), reason: '答えを含めない');
    }

    // 解説が全組出る
    for (final g in p.groups) {
      expect(find.text(g.title), findsWidgets);
    }

    // 結果画面の下だけにバナー。広告を消すと消える。
    expect(find.byKey(const Key('ad-banner')), findsOneWidget);
    await tester.tap(find.text('広告を消す'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('buy')));
    await tester.pumpAndSettle();
    expect(t.controller.purchases.owned, isTrue);
    expect(find.byKey(const Key('ad-banner')), findsNothing);

    // 記録とウィジェット
    final rec = t.controller.recordFor(20)!;
    expect(rec.cleared, isTrue);
    expect(rec.mistakes, 1);
    expect(t.widgets.written.last.today.status, '解決済み');
    expect(t.widgets.written.last.today.streak, 1);
  });

  testWidgets('間違い4回で終わっても答えを見せ、連続は途切れない', (tester) async {
    final t = await TestApp.create(
      prefs: {
        // 前日（第19問）に解いた記録
        'yonkumi.records.v1':
            '[{"day":19,"puzzle":19,"playedOn":19,"guesses":[],"cleared":true,"mistakes":0}]',
      },
    );
    await _pump(tester, t.controller);
    final p = t.controller.todayEntry!.puzzle;
    await _guess(tester, _wrong(p, 0, 1));
    await _guess(tester, _wrong(p, 1, 2));
    await _guess(tester, _wrong(p, 2, 3));
    await _guess(tester, _wrong(p, 0, 3));
    expect(find.text('残念、間違いが4回になりました'), findsOneWidget);
    expect(find.text('5回の決定・連続2日').evaluate().isEmpty, isTrue);
    expect(find.text('4回の決定・連続2日'), findsOneWidget);
    for (final g in p.groups) {
      await tester.scrollUntilVisible(
        find.text(g.note),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(g.note), findsOneWidget);
    }
    Navigator.of(tester.element(find.byType(ListView).first)).pop();
    await tester.pumpAndSettle();
    // 問題の画面には答えの帯が出る
    for (final g in p.groups) {
      expect(find.byKey(ValueKey('band-${g.difficulty}')), findsOneWidget);
    }
    expect(find.text('結果を見る'), findsOneWidget);
    expect(t.controller.stats.streak.current, 2);
  });

  testWidgets('解きかけは保存され、開き直しても続きから', (tester) async {
    final t = await TestApp.create();
    await _pump(tester, t.controller);
    final p = t.controller.todayEntry!.puzzle;
    await _guess(tester, p.groups[2].words);
    await _guess(tester, _wrong(p, 0, 1));

    final again = await TestApp.create(
      prefs: {
        'yonkumi.progress.v1': t.controller.log.progressFor(20).isEmpty
            ? '{}'
            : '{"20":[${t.controller.log.progressFor(20).map((g) => '[${g.map((w) => '"$w"').join(',')}]').join(',')}]}',
      },
    );
    final s = again.controller.sessionFor(again.controller.todayEntry!);
    expect(s.solved.single.title, p.groups[2].title);
    expect(s.mistakes, 1);
  });

  testWidgets('アーカイブ：直近7日は無料、それより前は全問パックで開く', (tester) async {
    final t = await TestApp.create();
    await _pump(tester, t.controller);
    await tester.tap(find.byTooltip('アーカイブ'));
    await tester.pumpAndSettle();
    expect(find.text('第20問（今日）'), findsOneWidget);

    // 第13問（7日前）は開ける
    await _tap(tester, find.byKey(const ValueKey('day-13')));
    expect(find.text('第13問'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 第12問（8日前）は購入の案内
    await tester.scrollUntilVisible(find.byKey(const ValueKey('day-12')), 100);
    await _tap(tester, find.byKey(const ValueKey('day-12')));
    expect(find.textContaining('全問パック（買い切り ¥600）'), findsOneWidget);
    await tester.tap(find.byKey(const Key('buy')));
    await tester.pumpAndSettle();
    expect(t.controller.isLocked(12), isFalse);
    await tester.tapAt(const Offset(10, 10)); // シートを閉じる
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const ValueKey('day-12')));
    expect(find.text('第12問'), findsOneWidget);
  });

  testWidgets('アーカイブで解いても連続日数には数えない', (tester) async {
    final t = await TestApp.create();
    final e = t.controller.entryFor(18)!;
    final s = t.controller.sessionFor(e);
    for (final g in e.puzzle.groups) {
      for (final w in g.words) {
        s.toggle(w);
      }
      s.submit();
    }
    await t.controller.afterSubmit(e, s);
    expect(t.controller.recordFor(18)!.cleared, isTrue);
    expect(t.controller.streak.current, 0);
    expect(t.controller.stats.played, 1);
  });

  testWidgets('設定：色名の表示、成績、通知', (tester) async {
    final t = await TestApp.create();
    await _pump(tester, t.controller);
    final p = t.controller.todayEntry!.puzzle;
    await _guess(tester, p.groups[0].words);
    expect(find.text('柿'), findsNothing);

    await tester.tap(find.byTooltip('設定'));
    await tester.pumpAndSettle();
    expect(find.text('遊んだ問題'), findsOneWidget);
    expect(find.textContaining('全問パックで見られます'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('color-names')));
    expect(t.controller.settings.colorNames, isTrue);

    await _tap(tester, find.byKey(const Key('notify')));
    expect(t.controller.settings.notify, isTrue);
    // 12時なので、今日の8時の分は過ぎている
    expect(t.notices.scheduled.first.body, '第21問が出ました');

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('柿'), findsOneWidget, reason: '帯に色名が出る');
  });

  testWidgets('通知が許可されなければオフのまま', (tester) async {
    final t = await TestApp.create();
    t.notices.allow = false;
    expect(await t.controller.setNotify(true), isFalse);
    expect(t.controller.settings.notify, isFalse);
  });

  testWidgets('日本時間の0時を過ぎると次の問題に替わる', (tester) async {
    final t = await TestApp.create(now: jst(2026, 11, 20, 23));
    await _pump(tester, t.controller);
    expect(find.text('第20問'), findsOneWidget);
    t.clock.value = jst(2026, 11, 21, 0).add(const Duration(seconds: 5));
    t.controller.checkDayChange();
    await tester.pumpAndSettle();
    expect(find.text('第21問'), findsOneWidget);
    expect(t.widgets.written.last.today.title, '第21問');
  });

  testWidgets('問題が尽きた日は過去の問題を再出題する', (tester) async {
    final t = await TestApp.create(now: jst(2027, 1, 15));
    final count = t.controller.bundle.count;
    await _pump(tester, t.controller);
    final e = t.controller.todayEntry!;
    expect(e.day, 76);
    expect(e.day, greaterThan(count), reason: '収録数を超えた日で確かめる');
    expect(e.rerun, isTrue);
    expect(e.puzzle.number, inInclusiveRange(1, count));
    expect(find.textContaining('再出題'), findsOneWidget);
  });

  testWidgets('結果画像は縦長1080×1350と正方形1080×1080', (tester) async {
    final t = await TestApp.create();
    await _pump(tester, t.controller);
    for (final g in t.controller.todayEntry!.puzzle.groups) {
      await _guess(tester, g.words);
    }
    Size sizeOf(Uint8List png) {
      final b = ByteData.sublistView(png);
      return Size(b.getUint32(16).toDouble(), b.getUint32(20).toDouble());
    }

    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share-image')));
      for (var i = 0; i < 50 && t.share.images.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(sizeOf(t.share.images.single), const Size(1080, 1350));
    expect(t.share.imageTexts.single, contains('#ヨンクミ'));

    await tester.tap(find.text('正方形'));
    await tester.pumpAndSettle();
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share-image')));
      for (var i = 0; i < 50 && t.share.images.length < 2; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(sizeOf(t.share.images.last), const Size(1080, 1080));
  });
}
