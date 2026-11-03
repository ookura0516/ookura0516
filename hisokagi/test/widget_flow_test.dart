import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hisokagi/core/room_code.dart';
import 'package:hisokagi/game/services.dart';
import 'package:hisokagi/game/session.dart';
import 'package:hisokagi/main.dart';
import 'package:hisokagi/scenario/model.dart';
import 'package:hisokagi/ui/app_controller.dart';
import 'package:hisokagi/ui/screens/play_screen.dart';
import 'package:hisokagi/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'fakes.dart';

const code = RoomCode(scenario: 1, players: 2, seed: 233);

Future<AppController> _controller() async {
  SharedPreferences.setMockInitialValues({});
  return AppController(
      store: await SessionStore.open(), purchases: FakePurchaseService());
}

void _phoneSize(WidgetTester tester) {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _pumpPlay(WidgetTester tester, AppController app, GameSession s) {
  return tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(
        theme: HisokagiTheme.dark,
        home: PlayScreen(session: s),
      ),
    ),
  );
}

/// 画面外でまだ作られていない部品は、見えるまでスクロールする。
Future<void> _reveal(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200,
        scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(f);
}

Future<void> _tapVisible(WidgetTester tester, Finder f) async {
  await _reveal(tester, f);
  await tester.pumpAndSettle();
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// 答えを画面から入れる。
Future<void> _enterAnswer(WidgetTester tester, StageInstance stage) async {
  switch (stage.input) {
    case DigitsInput() || KanaInput():
      await _reveal(tester, find.byKey(const Key('answer')));
      await tester.enterText(find.byKey(const Key('answer')), stage.answer);
    case TimeInput():
      final parts = stage.answer.split(':');
      await _tapVisible(tester, find.byKey(const Key('answer-hour')));
      await tester.tap(find.text(parts[0]).last);
      await tester.pumpAndSettle();
      await _tapVisible(tester, find.byKey(const Key('answer-minute')));
      await tester.tap(find.text(parts[1]).last);
      await tester.pumpAndSettle();
    case CableChoiceInput():
      await _tapVisible(tester, find.byKey(Key('cable-${stage.answer}')));
  }
  await _tapVisible(tester, find.byKey(const Key('submit-answer')));
}

void main() {
  testWidgets('1台モード：画面から最後まで解ける', (tester) async {
    _phoneSize(tester);
    final app = await _controller();
    final s = app.start(code: code, mode: PlayMode.solo, roles: {Role.a, Role.b});
    await _pumpPlay(tester, app, s);

    for (var i = 0; i < s.stages.length; i++) {
      final stage = s.stages[i];
      if (find.byKey(const Key('curtain-open')).evaluate().isNotEmpty) {
        await _tapVisible(tester, find.byKey(const Key('curtain-open')));
      }
      if (s.activeRole != stage.inputRole) {
        await _tapVisible(
            tester, find.text('「${s.roleInfo(stage.inputRole).name}」に交代する'));
        await _tapVisible(tester, find.byKey(const Key('curtain-open')));
      }
      expect(find.byKey(const Key('submit-answer')), findsOneWidget,
          reason: stage.title);
      await _enterAnswer(tester, stage);
    }

    expect(find.text('クリア'), findsOneWidget);
    expect(s.isCleared, isTrue);
    expect(s.mistakes, 0);
  });

  testWidgets('2台モード（A側）：答えを入れると合言葉が出て、相棒の合言葉で進む',
      (tester) async {
    _phoneSize(tester);
    final app = await _controller();
    final a = app.start(code: code, mode: PlayMode.linked, roles: {Role.a});
    await _pumpPlay(tester, app, a);

    for (var i = 0; i < a.stages.length; i++) {
      final stage = a.stages[i];
      if (stage.inputRole == Role.a) {
        // まちがえるとスナックバーが出て進まない
        if (stage.input is DigitsInput) {
          await _reveal(tester, find.byKey(const Key('answer')));
          await tester.enterText(find.byKey(const Key('answer')), '0');
          await _tapVisible(tester, find.byKey(const Key('submit-answer')));
          expect(find.text('反応がない。ちがうようだ。'), findsOneWidget);
          expect(a.currentIndex, i);
        }
        await _enterAnswer(tester, stage);
        expect(find.byKey(const Key('passphrase')), findsOneWidget);
        expect(find.text(a.passphraseOf(i)), findsOneWidget);
        await tester.tap(find.text('伝えた'));
        await tester.pumpAndSettle();
      } else {
        // 相棒（B）の端末が同じ部屋番号から出す合言葉
        final b = GameSession(code: code, mode: PlayMode.linked, roles: {Role.b});
        final word = b.passphraseOf(i);
        await _reveal(tester, find.byKey(const Key('passphrase-input')));
        await tester.enterText(
            find.byKey(const Key('passphrase-input')), 'まちがい');
        await _tapVisible(tester, find.byKey(const Key('submit-passphrase')));
        expect(a.currentIndex, i);
        await tester.enterText(find.byKey(const Key('passphrase-input')), word);
        await _tapVisible(tester, find.byKey(const Key('submit-passphrase')));
      }
    }

    expect(find.text('クリア'), findsOneWidget);
    // 部屋は保存されていて、読み戻すと終わった状態になっている
    final restored = app.store.load()!;
    expect(restored.isCleared, isTrue);
  });

  testWidgets('部屋にはいる：まちがった番号は弾き、正しい番号で役Bになる', (tester) async {
    _phoneSize(tester);
    final app = await _controller();
    await tester.pumpWidget(HisokagiApp(controller: app));
    await tester.tap(find.text('部屋にはいる'));
    await tester.pumpAndSettle();

    final wrong = code.text.replaceRange(5, 6, '${(int.parse(code.text[5]) + 1) % 10}');
    await tester.enterText(find.byKey(const Key('join-code')), wrong);
    await tester.tap(find.text('はいる'));
    await tester.pumpAndSettle();
    expect(find.textContaining('アプリのバージョンがちがいます'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('join-code')), code.display);
    await tester.tap(find.text('はいる'));
    await tester.pumpAndSettle();
    expect(find.text('管制室'), findsOneWidget);
    expect(app.session!.roles, {Role.b});
    expect(app.session!.code, code);

    await _tapVisible(tester, find.byKey(const Key('start')));
    expect(find.text('はじまり'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('passphrase-input')));
    expect(find.byKey(const Key('passphrase-input')), findsOneWidget);
  });

  testWidgets('部屋をつくると番号が出て、タイトルに「つづきから」が出る', (tester) async {
    _phoneSize(tester);
    final app = await _controller();
    await tester.pumpWidget(HisokagiApp(controller: app));
    await tester.tap(find.text('部屋をつくる'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('閉館後の天文台'));
    await tester.pumpAndSettle();

    final shown = tester.widget<Text>(find.byKey(const Key('room-code'))).data!;
    expect(shown, app.session!.code.display);
    expect(find.text('ドームの中'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.textContaining('つづきから'), findsOneWidget);
  });
}
