import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/daily/daily.dart';
import 'package:kipputen/main.dart';

import 'helpers.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<Harness> _pumpApp(WidgetTester tester, Day day) async {
  _phone(tester);
  final h = await makeHarness(day);
  await tester.pumpWidget(KipputenApp(controller: h.app));
  await tester.pumpAndSettle();
  return h;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

Future<void> _key(WidgetTester tester, String id) =>
    _tap(tester, find.byKey(Key(id)));

String _text(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data!;

void main() {
  // 2026-11-06（金）は 1199。解は「9 × (1 + 1 ÷ 9)」の1つだけ（分数の難問）。
  final friday = Day(2026, 11, 6);

  testWidgets('今日の切符：キーで式を入れ、途中結果が出て、正解で入鋏・完・共有まで', (tester) async {
    final h = await _pumpApp(tester, friday);
    expect(_text(tester, 'ticket-number'), '1 1 9 9');
    expect(find.text('今日の切符'), findsWidgets);
    expect(_text(tester, 'status'), '4つの数字で 10 を作ろう');

    await _key(tester, 'digit-2'); // 9
    // 数字の直後に数字は押せない（連結できない）。
    expect(
      tester.widget<FilledButton>(find.byKey(const Key('digit-0'))).onPressed,
      isNull,
    );
    await _key(tester, 'key-mul');
    await _key(tester, 'key-open');
    await _key(tester, 'digit-0'); // 1
    await _key(tester, 'key-add');
    await _key(tester, 'digit-1'); // 1
    expect(_text(tester, 'preview'), '途中結果 = 18');
    await _key(tester, 'key-div');
    await _key(tester, 'digit-3'); // 9
    expect(_text(tester, 'preview'), '途中結果 = 10');
    expect(_text(tester, 'ticket-expression'), '9 × (1 + 1 ÷ 9');
    await _key(tester, 'key-close');
    expect(_text(tester, 'ticket-expression'), '9 × (1 + 1 ÷ 9) = 10');

    expect(_text(tester, 'preview'), '全部見つけました。完！');
    expect(_text(tester, 'status'), '全解 1/1　完');
    expect(h.app.solvedToday(), isTrue);
    expect(h.sink.saved.last['day_20261106_done'], '1');

    // 切符の裏（全解探し）
    await _key(tester, 'open-solutions');
    expect(_text(tester, 'solution-0'), '9 × (1 + 1 ÷ 9) = 10');
    expect(find.byKey(const Key('kan-stamp')), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    // 共有：全解の日は3枚の扇。初期は式を隠す。
    await _key(tester, 'open-share');
    expect(find.byKey(const Key('share-fan')), findsOneWidget);
    expect(find.text('★★★ = 10'), findsNWidgets(3));
    await _key(tester, 'toggle-hide');
    expect(find.text('9 × (1 + 1 ÷ 9) = 10'), findsNWidgets(3));

    await tester.tap(find.byKey(const Key('do-share')));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();
    expect(h.share.shared, hasLength(1));
    expect(h.share.shared.single.text, contains('1199'));
    expect(h.share.shared.single.png.take(4), [0x89, 0x50, 0x4E, 0x47]); // PNG
  });

  testWidgets('10 にならない式は不正解と出て、消して直せる', (tester) async {
    await _pumpApp(tester, friday);
    for (final k in [
      'digit-0',
      'key-add',
      'digit-1',
      'key-add',
      'digit-2',
      'key-add',
      'digit-3',
    ]) {
      await _key(tester, k);
    }
    expect(_text(tester, 'preview'), '= 20。10 になりません');
    expect(_text(tester, 'status'), '4つの数字で 10 を作ろう');
    await _key(tester, 'key-back');
    expect(_text(tester, 'preview'), '途中結果 = 11');
    await _key(tester, 'key-clear');
    expect(_text(tester, 'preview'), ' ');
  });

  testWidgets('解が複数ある日は「あと◯通り」と出る', (tester) async {
    final h = await _pumpApp(tester, Day(2026, 11, 4)); // 4027
    // 7 × 2 − 4 + 0
    for (final k in [
      'digit-3',
      'key-mul',
      'digit-2',
      'key-sub',
      'digit-0',
      'key-add',
      'digit-1',
    ]) {
      await _key(tester, k);
    }
    final left = h.app.goalFor('4027') - 1;
    expect(_text(tester, 'status'), '解けた！ あと$left通り');
    await _key(tester, 'open-solutions');
    expect(_text(tester, 'solution-1'), '？？？');
    expect(find.byKey(const Key('kan-stamp')), findsNothing);
  });

  testWidgets('バナーは図鑑画面の下だけ。広告削除を買うと消える', (tester) async {
    await _pumpApp(tester, friday);
    expect(find.byKey(const Key('ad-banner')), findsNothing);

    await _tap(tester, find.text('図鑑'));
    expect(find.byKey(const Key('ad-banner')), findsOneWidget);
    expect(find.byKey(const Key('collection-count')), findsOneWidget);

    await _tap(tester, find.text('設定'));
    expect(find.byKey(const Key('ad-banner')), findsNothing);
    final buy = find.descendant(
      of: find.byKey(const Key('buy-removeAds')),
      matching: find.text('¥480'),
    );
    await tester.scrollUntilVisible(
      buy,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await _tap(tester, buy);
    await _key(tester, 'confirm-buy');
    expect(find.text('購入済み'), findsOneWidget);

    await _tap(tester, find.text('図鑑'));
    expect(find.byKey(const Key('ad-banner')), findsNothing);
  });

  testWidgets('図鑑：番号を選んで練習し、解くと図鑑が埋まる', (tester) async {
    final h = await _pumpApp(tester, friday);
    await _tap(tester, find.text('図鑑'));
    expect(_text(tester, 'collection-count'), '解いた切符 0 / 8147');

    // グリッドの左上から 0025 のマスを押す（行=上2桁、列=下2桁、1マス9px）。
    final origin = tester.getTopLeft(find.byKey(const Key('collection-grid')));
    await tester.tapAt(origin + const Offset(25 * 9 + 4, 4));
    await tester.pumpAndSettle();
    expect(find.text('0025'), findsOneWidget);
    expect(find.textContaining('まだ解いていません'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10)); // シートを閉じる
    await tester.pumpAndSettle();

    // 番号を入れて探す
    await _key(tester, 'pick-number');
    await tester.enterText(find.byKey(const Key('number-field')), '1158');
    await _tap(tester, find.text('見る'));
    await _key(tester, 'practice');
    expect(find.text('練習 1158'), findsOneWidget);
    expect(_text(tester, 'ticket-number'), '1 1 5 8');

    // 8 ÷ (1 − 1 ÷ 5)
    for (final k in [
      'digit-3',
      'key-div',
      'key-open',
      'digit-0',
      'key-sub',
      'digit-1',
      'key-div',
      'digit-2',
      'key-close',
    ]) {
      await _key(tester, k);
    }
    expect(_text(tester, 'status'), '全解 1/1　完');
    // 練習で解いても、今日の切符は解いたことにならない。
    expect(h.app.solvedToday(), isFalse);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(_text(tester, 'collection-count'), '解いた切符 1 / 8147');
  });

  testWidgets('設定：デザインパックの切符は購入の確認が出て、買うと選べる', (tester) async {
    final h = await _pumpApp(tester, friday);
    await _tap(tester, find.text('設定'));
    final sakura = find.byKey(const Key('design-sakura'));
    await tester.scrollUntilVisible(
      sakura,
      200,
      scrollable: find.byType(Scrollable).last,
    );
    await _tap(tester, sakura);
    expect(find.text('硬券デザインパック'), findsWidgets);
    await _key(tester, 'confirm-buy');
    expect(h.app.design.id, 'sakura');
  });
}
