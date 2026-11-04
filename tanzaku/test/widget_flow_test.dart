import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/main.dart';
import 'package:tanzaku/render/style.dart';
import 'package:tanzaku/ui/screens/compose_screen.dart';
import 'package:tanzaku/ui/screens/tanzaku_screen.dart';

import 'helpers.dart';

void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<TestApp> _start(
  WidgetTester tester, {
  Map<String, Object> prefs = const {},
}) async {
  _phone(tester);
  final t = await tester.runAsync(() => makeApp(prefs: prefs));
  await tester.pumpWidget(TanzakuApp(controller: t!.controller));
  await tester.pumpAndSettle();
  return t;
}

Future<void> _tap(WidgetTester tester, Finder f) async {
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// データベースの読み書きが終わるまで待つ。
Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 50)),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ホーム → 兼題で詠む → 短冊 → 共有 → ホームに最近の句', (tester) async {
    final t = await _start(tester);
    final theme = t.controller.todayTheme!;
    expect(find.text('今日の兼題'), findsOneWidget);
    expect(find.byKey(const Key('today-theme')), findsOneWidget);
    expect(find.text(theme.word), findsWidgets);
    expect(find.text('今は秋'), findsOneWidget);
    expect(find.text('連続 0 日'), findsOneWidget);

    await _tap(tester, find.byKey(const Key('compose-theme')));
    expect(find.byType(ComposeScreen), findsOneWidget);
    expect(find.text('兼題　'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('line-0')), '古池や');
    await tester.enterText(find.byKey(const Key('line-1')), '蛙飛びこむ');
    await tester.enterText(find.byKey(const Key('line-2')), '水の音');
    await tester.pumpAndSettle();
    expect(find.textContaining('5・7・5'), findsOneWidget);
    expect(find.textContaining('五七五'), findsOneWidget);
    expect(find.textContaining('蛙　春・動物'), findsOneWidget);
    expect(find.byKey(const Key('kigasanari')), findsNothing);

    await tester.enterText(find.byKey(const Key('maegaki')), '深川にて');
    await tester.tap(find.byKey(const Key('save-haiku')));
    await _settle(tester);
    expect(find.byType(TanzakuScreen), findsOneWidget);
    expect(find.byKey(const Key('tanzaku-preview')), findsOneWidget);

    expect(t.controller.haiku.single.body, '古池や\n蛙飛びこむ\n水の音');
    expect(t.controller.haiku.single.maegaki, '深川にて');
    expect(t.controller.haiku.single.themeKigoId, theme.id);

    // 共有（画像の書き出しは実際に描く）
    await tester.ensureVisible(find.byKey(const Key('share-image')));
    await tester.tap(find.byKey(const Key('share-image')));
    await tester.runAsync(() async {
      for (var i = 0; i < 100 && t.share.shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(t.share.shared.single, contains('tanzaku_'));

    // ホームに戻ると最近の句と連続日数
    await _tap(tester, find.byType(BackButton));
    expect(find.text('連続 1 日'), findsOneWidget);
    expect(
      find.byKey(Key('recent-${t.controller.haiku.single.id}')),
      findsOneWidget,
    );
    expect(t.widgets.last!.streak, 1);
    expect(t.widgets.last!.kigo, theme.word);
    expect(t.widgets.last!.tomorrowDate, '2026-11-05');
  });

  testWidgets('季重なりを知らせ、季語がなければ無季と出す', (tester) async {
    await _start(tester);
    await _tap(tester, find.byKey(const Key('compose-free')));
    await tester.enterText(find.byKey(const Key('line-0')), '菜の花や');
    await tester.enterText(find.byKey(const Key('line-1')), '月は東に');
    await tester.enterText(find.byKey(const Key('line-2')), '日は西に');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('kigasanari')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('line-0')), '電車の窓');
    await tester.enterText(find.byKey(const Key('line-1')), '');
    await tester.enterText(find.byKey(const Key('line-2')), '');
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('kigo-none')), findsOneWidget);
    // 読みの分からない漢字があると「約」
    expect(find.textContaining('約'), findsWidgets);
  });

  testWidgets('有料の書体を選ぶと購入の案内が出て、買うと使える', (tester) async {
    final t = await _start(tester);
    await tester.runAsync(
      () => t.controller.addHaiku(lines: ['木枯や', '竹に隠れて', 'しづまりぬ']),
    );
    await tester.pumpAndSettle();
    final id = t.controller.haiku.single.id;
    await tester.pumpWidget(TanzakuApp(controller: t.controller));
    final nav = tester.state<NavigatorState>(find.byType(Navigator).first);
    nav.push(MaterialPageRoute(builder: (_) => TanzakuScreen(haikuId: id)));
    await tester.pumpAndSettle();

    await _tap(tester, find.byKey(const Key('font-yuji')));
    expect(find.textContaining('すずり（買い切り ¥730）'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('buy-suzuri')));
    await _settle(tester);
    expect(t.controller.hasSuzuri, isTrue);
    expect(t.controller.lastStyle.font, TanzakuFont.yuji);
    final chip = tester.widget<ChoiceChip>(find.byKey(const Key('font-yuji')));
    expect(chip.selected, isTrue);
  });

  testWidgets('歳時記で探して、その季語で詠む', (tester) async {
    await _start(tester);
    await _tap(tester, find.text('歳時記'));
    // 今の季節（秋）が最初に選ばれている
    expect(
      tester.widget<ChoiceChip>(find.byKey(const Key('season-now'))).selected,
      isTrue,
    );
    await _tap(tester, find.byKey(const Key('season-all')));
    await tester.enterText(find.byKey(const Key('saijiki-search')), 'こがらし');
    await tester.pumpAndSettle();
    final tile = find.byKey(
      Key('kigo-tile-${dictionary.search('こがらし').first.id}'),
    );
    await _tap(tester, tile);
    expect(find.text('木枯や竹に隠れてしづまりぬ　松尾芭蕉'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('compose-with-kigo')));
    expect(find.byType(ComposeScreen), findsOneWidget);
    expect(find.textContaining('木枯　冬・天文'), findsOneWidget);
  });

  testWidgets('句帳から推敲すると、前の版が履歴に残る', (tester) async {
    final t = await _start(tester);
    await tester.runAsync(
      () => t.controller.addHaiku(lines: ['柿食へば', '鐘が鳴るなり', '法隆寺']),
    );
    await tester.pumpAndSettle();
    final h = t.controller.haiku.single;

    await _tap(tester, find.text('句帳'));
    expect(find.text('柿食へば　鐘が鳴るなり　法隆寺'), findsOneWidget);
    await _tap(tester, find.text('季節'));
    expect(find.text('秋（1）'), findsOneWidget);

    await _tap(tester, find.byKey(Key('haiku-${h.id}')));
    await _settle(tester);
    expect(find.text('推敲の履歴（0）'), findsOneWidget);
    await _tap(tester, find.byKey(const Key('revise')));
    await tester.enterText(find.byKey(const Key('line-1')), '鐘がなるなり');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-haiku')));
    await _settle(tester);
    await _settle(tester);
    expect(find.text('推敲の履歴（1）'), findsOneWidget);
    expect(find.text('柿食へば　鐘が鳴るなり　法隆寺'), findsOneWidget);
    expect(t.controller.haiku.single.body, '柿食へば\n鐘がなるなり\n法隆寺');

    await _tap(tester, find.byKey(const Key('detail-favorite')));
    await _settle(tester);
    expect(t.controller.haiku.single.favorite, isTrue);
  });

  testWidgets('設定：雅号、通知、書き出し、購入', (tester) async {
    final t = await _start(tester);
    await _tap(tester, find.text('設定'));
    await _tap(tester, find.byKey(const Key('gago')));
    await tester.enterText(find.byKey(const Key('gago-field')), '月庵');
    await _tap(tester, find.byKey(const Key('gago-save')));
    await _settle(tester);
    expect(t.controller.gago, '月庵');
    expect(find.text('月庵'), findsOneWidget);

    await _tap(tester, find.byKey(const Key('notify')));
    await _settle(tester);
    expect(t.controller.notifyEnabled, isTrue);
    expect(t.notifications.scheduled.length, 14);
    expect(t.notifications.scheduled.first.$2, startsWith('今日の兼題　'));
    expect(t.notifications.minutes, 8 * 60);

    await _tap(tester, find.byKey(const Key('export')));
    await _settle(tester);
    expect(t.share.files.keys.single, 'tanzaku_20261104.json');

    await _tap(tester, find.byKey(const Key('font-licenses')));
    expect(find.text('Noto Serif JP'), findsOneWidget);
    expect(find.text('Yuji Syuku'), findsOneWidget);
  });

  testWidgets('昨日の分を詠むで連続日数を戻せる', (tester) async {
    final t = await _start(tester);
    await tester.runAsync(
      () => t.controller.addHaiku(
        lines: ['おとといの', '句', ''],
        composedOn: DateTime(2026, 11, 2),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('revive')), findsOneWidget);
    await _tap(tester, find.byKey(const Key('revive')));
    expect(find.text('昨日の分を詠む'), findsWidgets);
    await tester.enterText(find.byKey(const Key('line-0')), '昨日の句');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('save-haiku')));
    await _settle(tester);
    expect(t.controller.streak.days, 2);
    expect(t.controller.haiku.first.composedOn, DateTime(2026, 11, 3));
  });

  testWidgets('端末の文字サイズを大きくしても入力欄は崩れない', (tester) async {
    _phone(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 2.0;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final t = await tester.runAsync(() => makeApp());
    await tester.pumpWidget(TanzakuApp(controller: t!.controller));
    await tester.pumpAndSettle();
    await _tap(tester, find.byKey(const Key('compose-free')));
    final field = tester.widget<TextField>(find.byKey(const Key('line-0')));
    expect(field.style!.fontSize, greaterThanOrEqualTo(18));
    expect(tester.takeException(), isNull);
  });

  testWidgets('ウィジェットや通知をタップすると「詠む」が開く', (tester) async {
    final t = await _start(tester);
    t.widgets.clickController.add(Uri.parse('tanzaku://compose?homeWidget'));
    await tester.pumpAndSettle();
    expect(find.byType(ComposeScreen), findsOneWidget);
    expect(find.text('兼題　'), findsOneWidget);

    await _tap(tester, find.byType(BackButton));
    expect(find.byType(ComposeScreen), findsNothing);
    t.notifications.tapController.add(Uri.parse('tanzaku://compose'));
    await tester.pumpAndSettle();
    expect(find.byType(ComposeScreen), findsOneWidget);

    // 知らないリンクでは何もしない
    await _tap(tester, find.byType(BackButton));
    t.notifications.tapController.add(Uri.parse('https://example.com/compose'));
    await tester.pumpAndSettle();
    expect(find.byType(ComposeScreen), findsNothing);
  });
}
