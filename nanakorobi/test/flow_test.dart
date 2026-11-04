// 画面から通しで：初回説明 → 作成 → 開眼（なぞり） → ホーム → 今日の一歩 → 転ぶ → 起き上がる。
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/app.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/repository.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/paint/daruma_painter.dart';
import 'package:nanakorobi/state/providers.dart';
import 'package:nanakorobi/ui/screens/home_screen.dart';

class _Clock {
  DateTime now = DateTime(2026, 11, 13, 9, 0);
}

Future<ProviderContainer> _pumpApp(WidgetTester tester, _Clock clock, MemoryDarumaRepository repo) async {
  tester.view.physicalSize = const Size(1170, 2532);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  // 日本語の画面で確かめる。
  tester.platformDispatcher.localeTestValue = const Locale('ja');
  tester.platformDispatcher.localesTestValue = const [Locale('ja')];
  addTearDown(tester.platformDispatcher.clearLocaleTestValue);
  addTearDown(tester.platformDispatcher.clearLocalesTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        settingsStoreProvider.overrideWithValue(MemorySettingsStore()),
        repositoryProvider.overrideWithValue(repo),
        clockProvider.overrideWithValue(() => clock.now),
      ],
      child: const NanakorobiApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(NanakorobiApp)));
}

/// 画面外でまだ作られていない部品は、見えるまでスクロールする。
Future<void> _reveal(WidgetTester tester, Finder f) async {
  if (f.evaluate().isEmpty) {
    await tester.scrollUntilVisible(f, 200, scrollable: find.byType(Scrollable).first);
  }
  await tester.ensureVisible(f);
  await tester.pumpAndSettle();
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final f = find.byKey(key);
  await _reveal(tester, f);
  await tester.tap(f);
  await tester.pumpAndSettle();
}

/// 目の円の中を指でひと回りなぞる。
Future<void> _traceEye(WidgetTester tester, EyeSide side) async {
  final f = find.byKey(const Key('eye-trace'));
  final size = tester.getSize(f);
  final origin = tester.getTopLeft(f);
  final c = DarumaPainter.eyeCenterIn(size, side);
  final r = DarumaPainter.eyeRadiusIn(size) * 0.7;
  final g = await tester.startGesture(origin + c);
  var prev = origin + c;
  for (var i = 1; i <= 30; i++) {
    final a = 2 * math.pi * i / 30;
    final p = origin + c + Offset(math.cos(a) * r, math.sin(a) * r);
    await g.moveBy(p - prev);
    prev = p;
    await tester.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('初回説明から開眼、今日の一歩、転んで起き上がるまで', (tester) async {
    final clock = _Clock();
    final repo = MemoryDarumaRepository();
    final container = await _pumpApp(tester, clock, repo);

    // 初回説明 3 枚。
    expect(find.byKey(const Key('onboarding-next')), findsOneWidget);
    await _tap(tester, const Key('onboarding-next'));
    await _tap(tester, const Key('onboarding-next'));
    await _tap(tester, const Key('onboarding-next'));

    // 作成：2字未満では進めない。
    expect(find.byKey(const Key('name')), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('to-eye')));
    expect(find.byKey(const Key('to-eye')), findsOneWidget);
    await tester.enterText(find.byKey(const Key('name')), '合');
    await _tap(tester, const Key('to-eye'));
    expect(find.text('2〜6字で入れてください'), findsOneWidget);
    await _reveal(tester, find.byKey(const Key('name')));
    await tester.enterText(find.byKey(const Key('name')), '合格');
    await _tap(tester, const Key('color-black'));
    await _reveal(tester, find.byKey(const Key('daily-action')));
    await tester.enterText(find.byKey(const Key('daily-action')), '英単語20個');
    await _tap(tester, const Key('to-eye'));

    // 開眼：なぞるまで「はじめる」は押せない。
    expect(find.byKey(const Key('eye-trace')), findsOneWidget);
    final created = (await repo.activeDetail())!;
    expect(created.daruma.name, '合格');
    expect(created.daruma.color, DarumaColor.black);
    expect(created.daruma.dailyAction, '英単語20個');
    await _traceEye(tester, created.daruma.eyeSide);
    expect(find.text('開眼。今日から始まります。'), findsOneWidget);
    await _tap(tester, const Key('eye-start'));

    // ホーム：今日の一歩。
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(find.byKey(const Key('home-step')), findsOneWidget);
    await _tap(tester, const Key('home-step'));
    expect(find.byKey(const Key('home-done')), findsOneWidget);
    expect((await repo.activeDetail())!.brushCount, 1);
    expect(find.textContaining('筆 1本'), findsOneWidget);

    // 取り消すと戻る。
    await _tap(tester, const Key('home-undo'));
    expect(find.byKey(const Key('home-step')), findsOneWidget);
    expect((await repo.activeDetail())!.brushCount, 0);
    await _tap(tester, const Key('home-step'));

    // 3日あけると転ぶ。記録で起き上がって金の筋が1本。
    clock.now = DateTime(2026, 11, 16, 9, 0);
    container.read(todayProvider.notifier).refresh();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('home-fallen')), findsOneWidget);
    await _tap(tester, const Key('home-step'));
    final after = (await repo.activeDetail())!;
    expect(after.brushCount, 2);
    expect(after.riseCount, 1);
    expect(after.isFallenOn(LocalDate(2026, 11, 16)), isFalse);
    expect(find.textContaining('起き上がり 1回'), findsOneWidget);

    // 記録画面に行ける。
    await _tap(tester, const Key('home-records'));
    expect(find.text('英単語20個'), findsWidgets);
    await _reveal(tester, find.byKey(const Key('detail-complete')));
    expect(find.byKey(const Key('detail-complete')), findsOneWidget);

    await tester.pump(const Duration(seconds: 4));
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('2体目は作れず、満願にすると棚に残る', (tester) async {
    final clock = _Clock();
    final repo = MemoryDarumaRepository();
    await repo.create(
      const NewDaruma(name: '必勝', color: DarumaColor.red, eyeSide: EyeSide.left),
      today: LocalDate(2026, 11, 1),
    );
    final container = await _pumpApp(tester, clock, repo);
    await container.read(settingsProvider.notifier).markOnboardingDone();
    await tester.pumpAndSettle();
    // 初回説明が出たまま（リダイレクトは '/' を開いたとき）なら進める。
    while (find.byKey(const Key('onboarding-next')).evaluate().isNotEmpty) {
      await _tap(tester, const Key('onboarding-next'));
    }
    if (find.byKey(const Key('name')).evaluate().isNotEmpty) {
      await tester.enterText(find.byKey(const Key('name')), '合格');
      await _tap(tester, const Key('to-eye'));
      // 現役がいるので作れない → ホームへ。
      expect(find.text('現役のだるまは1体まで'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(HomeScreen), findsOneWidget);

    // 記録 → 両目。
    await _tap(tester, const Key('home-records'));
    await _tap(tester, const Key('detail-complete'));
    final d = (await repo.activeDetail())!;
    final second = d.daruma.eyeSide == EyeSide.left ? EyeSide.right : EyeSide.left;
    await _traceEye(tester, second);
    expect(find.text('満願。おめでとうございます。'), findsOneWidget);
    expect(await repo.activeDetail(), isNull);
    expect((await repo.all()).single.status, DarumaStatus.completed);
    await _tap(tester, const Key('eye-start'));
    expect(find.byKey(const Key('shelf-new')), findsOneWidget);
    expect(find.byKey(const Key('shelf-retry-1')), findsOneWidget);

    // 両目の直後の評価依頼（2秒後）を待ってから片づける。
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpWidget(const SizedBox());
  });
}
