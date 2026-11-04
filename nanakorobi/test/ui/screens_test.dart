import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/app/app.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/services/share_service.dart';
import 'package:nanakorobi/state/app_deps.dart';
import 'package:nanakorobi/state/create_daruma.dart';
import 'package:nanakorobi/state/daruma_actions.dart';
import 'package:nanakorobi/state/providers.dart';
import 'package:nanakorobi/ui/daruma/daruma_painter.dart';

/// 目の中を指でなぞる（EyeTracePad の判定を通る動き）。
Future<void> traceEye(WidgetTester tester, Key padKey, EyeSide side) async {
  final rect = tester.getRect(find.byKey(padKey));
  final scale = math.min(rect.width / DarumaPainter.boxWidth, rect.height / DarumaPainter.boxHeight);
  final origin = Offset(
    rect.left + (rect.width - DarumaPainter.boxWidth * scale) / 2,
    rect.top + (rect.height - DarumaPainter.boxHeight * scale) / 2,
  );
  final center = DarumaPainter.eyeCenter(side) * scale + origin;
  final r = DarumaPainter.eyeRadius * scale;
  final g = await tester.startGesture(center + Offset(-r * 0.7, 0));
  for (var i = 1; i <= 7; i++) {
    await g.moveBy(Offset(r * 0.2, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  for (var i = 1; i <= 7; i++) {
    await g.moveBy(Offset(-r * 0.2, 0));
    await tester.pump(const Duration(milliseconds: 16));
  }
  await g.up();
  await tester.pumpAndSettle();
}

/// 日本語の画面では「戻る」のツールチップが Back ではないので、pageBack の代わり。
Future<void> back(WidgetTester tester) async {
  await tester.tap(find.byType(BackButton).first);
  await tester.pumpAndSettle();
}

void main() {
  late DateTime clock;
  late AppDeps deps;

  Future<void> pumpApp(WidgetTester tester, {bool onboardingDone = false, bool hasPlus = false}) async {
    tester.view.physicalSize = const Size(1170, 2532);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    clock = DateTime(2026, 11, 4, 9);
    deps = AppDeps.fake(
      now: () => clock,
      initialSettings: AppSettings(onboardingDone: onboardingDone),
      hasPlus: hasPlus,
      locale: const Locale('ja'),
    );
    addTearDown(deps.db.close);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDepsProvider.overrideWithValue(deps)],
        child: const NanakorobiApp(),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('初回説明 → 作成 → 開眼 → ホームで今日の一歩 → 詳細・共有・棚・設定・プラスへ遷移できる', (tester) async {
    await pumpApp(tester);

    // /onboarding
    expect(find.text('目を入れて、始める'), findsOneWidget);
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-next')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('onboarding-start')));
    await tester.pumpAndSettle();

    // /new
    expect(find.text('だるまを作る'), findsOneWidget);
    await tester.tap(find.byKey(const Key('name-preset-合格')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('color-2')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('daily-action')), '英単語20個');
    await tester.ensureVisible(find.byKey(const Key('to-eye')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('to-eye')));
    await tester.pumpAndSettle();

    // /new/eye：なぞると開眼して保存される
    expect(find.text('開眼'), findsWidgets);
    await traceEye(tester, const Key('eye-pad'), EyeSide.left);
    expect(find.text('開眼しました'), findsOneWidget);
    expect((await deps.repo.loadAll()).single.daruma.name, '合格');
    expect((await deps.repo.loadAll()).single.daruma.colorId, 2);
    await tester.tap(find.byKey(const Key('eye-home')));
    await tester.pumpAndSettle();

    // / ホーム：今日の一歩
    expect(find.byKey(const Key('today-step')), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-step')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-done')), findsOneWidget);
    expect(find.text('1筆'), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-undo')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('today-step')), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-step')));
    await tester.pumpAndSettle();

    // 2体目はプラスへ
    await tester.tap(find.byKey(const Key('add-daruma')));
    await tester.pumpAndSettle();
    expect(find.text('ナナコロビ プラス'), findsOneWidget);
    expect(find.text('2体目からはプラスで'), findsOneWidget);
    await tester.tap(find.byKey(const Key('buy-plus')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('plus-active')), findsOneWidget);
    await back(tester);
    await tester.pumpAndSettle();

    // /daruma/:id
    await tester.tap(find.byKey(const Key('home-daruma')));
    await tester.pumpAndSettle();
    expect(find.text('両目を入れる（満願）'), findsOneWidget);
    expect(find.textContaining('英単語20個'), findsWidgets);

    // /daruma/:id/complete
    await tester.tap(find.byKey(const Key('detail-complete')));
    await tester.pumpAndSettle();
    await traceEye(tester, const Key('complete-pad'), EyeSide.right);
    expect(find.text('満願'), findsWidgets);
    expect((await deps.repo.loadAll()).single.daruma.status, DarumaStatus.completed);

    // /share
    await tester.tap(find.byKey(const Key('complete-share')));
    await tester.pumpAndSettle();
    expect(find.text('共有'), findsOneWidget);
    await tester.tap(find.byKey(const Key('template-goldScreen')));
    await tester.pumpAndSettle();
    // PNG の生成は本物の非同期処理なので runAsync で待つ。
    final share = deps.share as FakeShareService;
    await tester.runAsync(() async {
      await tester.tap(find.byKey(const Key('share-button')));
      await tester.pump();
      for (var i = 0; i < 100 && share.shared.isEmpty; i++) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pumpAndSettle();
    expect(share.shared.single.$2, '満願。');
    expect(share.lastPng!.length, greaterThan(1000));
    await back(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('complete-home')));
    await tester.pumpAndSettle();

    // 満願のあとは現役がいないので、作成へ
    expect(find.byKey(const Key('home-create')), findsOneWidget);

    // /shelf
    await tester.tap(find.byKey(const Key('to-shelf')));
    await tester.pumpAndSettle();
    expect(find.text('棚'), findsOneWidget);
    expect(find.byKey(Key('shelf-${(await deps.repo.loadAll()).single.id}')), findsOneWidget);
    await tester.tap(find.byKey(const Key('shelf-poster')));
    await tester.pumpAndSettle();
    expect(find.textContaining('今年のだるま'), findsOneWidget);
    await back(tester);
    await tester.pumpAndSettle();
    await back(tester);
    await tester.pumpAndSettle();

    // /settings
    await tester.tap(find.byKey(const Key('to-settings')));
    await tester.pumpAndSettle();
    expect(find.text('設定'), findsOneWidget);
    await tester.tap(find.byKey(const Key('reminder-toggle')));
    await tester.pumpAndSettle();
    expect(deps.initialSettings.reminderEnabled, isFalse);
    await back(tester);
    await tester.pumpAndSettle();
  });

  testWidgets('試験日プリセットから本番の日を選べる', (tester) async {
    await pumpApp(tester, onboardingDone: true);
    await tester.tap(find.byKey(const Key('home-create')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('name-field')), '必勝');
    await tester.tap(find.byKey(const Key('deadline-preset')));
    await tester.pumpAndSettle();
    expect(find.text('試験日'), findsOneWidget);
    // 仮の JSON は空なので「見つかりません」
    expect(find.text('見つかりません'), findsOneWidget);
    await back(tester);
    await tester.pumpAndSettle();
    expect(find.text('だるまを作る'), findsOneWidget);
  });

  testWidgets('転倒中は横倒しの案内が出て、記録で起き上がる', (tester) async {
    await pumpApp(tester, onboardingDone: true);
    final container = ProviderScope.containerOf(tester.element(find.byType(NanakorobiApp)));
    final d = await container.read(darumaActionsProvider).openEye(const CreateDarumaForm(name: '走る'));
    await container.read(darumaActionsProvider).recordStep(d.id);
    clock = clock.add(const Duration(days: 3));
    container.read(todayProvider.notifier).refresh();
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fallen-banner')), findsOneWidget);
    await tester.tap(find.byKey(const Key('today-step')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('fallen-banner')), findsNothing);
    expect(find.text('起き上がった。台座に金の筋が1本。'), findsOneWidget);
    expect(container.read(lookProvider(d.id))!.goldLines, 1);
    expect(container.read(todayProvider), LocalDate.fromDateTime(clock));
  });
}
