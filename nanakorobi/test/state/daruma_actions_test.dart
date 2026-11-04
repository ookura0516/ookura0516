import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/rest_tickets.dart';
import 'package:nanakorobi/core/review_policy.dart';
import 'package:nanakorobi/core/strokes.dart';
import 'package:nanakorobi/model/models.dart';
import 'package:nanakorobi/services/reminder_service.dart';
import 'package:nanakorobi/services/review_service.dart';
import 'package:nanakorobi/services/widget_sync_service.dart';
import 'package:nanakorobi/state/app_deps.dart';
import 'package:nanakorobi/state/create_daruma.dart';
import 'package:nanakorobi/state/daruma_actions.dart';
import 'package:nanakorobi/state/providers.dart';

void main() {
  late DateTime clock;
  late AppDeps deps;
  late ProviderContainer container;

  DarumaActions actions() => container.read(darumaActionsProvider);
  RecordingWidgetSyncService widgets() => deps.widgetSync as RecordingWidgetSyncService;
  FakeReminderService reminders() => deps.reminders as FakeReminderService;

  void advanceDays(int n) {
    clock = clock.add(Duration(days: n));
    container.read(todayProvider.notifier).refresh();
  }

  setUp(() {
    clock = DateTime(2027, 1, 1, 9);
    deps = AppDeps.fake(now: () => clock);
    container = ProviderContainer(overrides: [appDepsProvider.overrideWithValue(deps)]);
    // 棚のストリームを生かしておく（画面が購読しているのと同じ状態にする）。
    container.listen(bundlesProvider, (_, _) {});
    addTearDown(container.dispose);
    addTearDown(deps.db.close);
  });

  /// DB の変更が providers に届くのを待つ。
  Future<void> settle() => pumpEventQueue(times: 50);

  Future<Daruma> open({LocalDate? deadline, String? presetId}) => actions().openEye(
        CreateDarumaForm(
          name: '合格',
          colorId: 0,
          deadline: deadline,
          deadlineName: deadline == null ? null : '共通テスト',
          deadlinePresetId: presetId,
          waypoints: const [WaypointInput(name: '模試', date: LocalDate(2027, 1, 10))],
          dailyAction: '英単語20個',
        ),
      );

  test('開眼→今日の一歩→転倒→起き上がりで金の筋が増え、取り消すと戻る', () async {
    final d = await open(deadline: const LocalDate(2027, 1, 16));
    expect(d.openedOn, const LocalDate(2027, 1, 1));
    expect(d.status, DarumaStatus.active);
    expect((await deps.repo.milestonesOf(d.id)).single.name, '模試');

    final r1 = await actions().recordStep(d.id, memo: 'はじめの一歩');
    expect(r1.strokes, 1);
    expect(r1.rose, isFalse);

    // 2日・3日が空白 → 4日は転倒中。記録すると起き上がり。
    advanceDays(3);
    await settle();
    var look = (await deps.repo.bundle(d.id))!;
    expect(container.read(lookProvider(d.id))!.fallen, isTrue);
    final r2 = await actions().recordStep(d.id);
    expect(r2.rose, isTrue);
    expect(r2.strokes, 2);
    look = (await deps.repo.bundle(d.id))!;
    expect(look.recoveries.single.fellAfter, const LocalDate(2027, 1, 1));
    expect(look.recoveries.single.roseOn, const LocalDate(2027, 1, 4));
    await settle();
    expect(container.read(lookProvider(d.id))!.goldLines, 1);
    expect(container.read(lookProvider(d.id))!.fallen, isFalse);

    await actions().undoStep(d.id);
    await settle();
    look = (await deps.repo.bundle(d.id))!;
    expect(look.recoveries, isEmpty);
    expect(look.checkins.length, 1);
    expect(container.read(lookProvider(d.id))!.fallen, isTrue);

    final m = await deps.metrics.load();
    expect(m['step_recorded'], 2);
    expect(m['rose'], 1);
    expect(m['step_undone'], 1);
    expect(m['eye_opened'], 1);
  });

  test('節目は筆の数で決まり、7日目で評価依頼が出る（365日3回まで）', () async {
    final d = await open();
    StepResult? last;
    for (var i = 0; i < 7; i++) {
      last = await actions().recordStep(d.id);
      advanceDays(1);
    }
    expect(last!.milestone, StrokeMilestone.day7);
    expect(await actions().maybeRequestReview(ReviewOccasion.milestone7), isTrue);
    expect((deps.review as FakeReviewService).requests, 1);
    expect(container.read(settingsProvider).reviewPromptedOn.length, 1);
    expect(await actions().maybeRequestReview(ReviewOccasion.completed), isTrue);
    expect(await actions().maybeRequestReview(ReviewOccasion.completed), isTrue);
    expect(await actions().maybeRequestReview(ReviewOccasion.completed), isFalse);
  });

  test('休み券：明日だけ宣言でき、月2枚。本番の日より後には使えない', () async {
    final d = await open(deadline: const LocalDate(2027, 1, 16));
    final tomorrow = const LocalDate(2027, 1, 2);
    expect(await actions().declareRest(d.id, tomorrow), RestDecision.ok);
    expect(await actions().declareRest(d.id, tomorrow), RestDecision.alreadyDeclared);
    expect(await actions().declareRest(d.id, const LocalDate(2027, 1, 1)), RestDecision.tooLate);
    expect(await actions().declareRest(d.id, const LocalDate(2027, 1, 3)), RestDecision.ok);
    expect(await actions().declareRest(d.id, const LocalDate(2027, 1, 5)), RestDecision.noTicketsLeft);
    expect(await actions().declareRest(d.id, const LocalDate(2027, 2, 5)), RestDecision.afterDeadline);
    // 休みの翌日は転んでいない
    advanceDays(2);
    await settle();
    expect(container.read(lookProvider(d.id))!.fallen, isFalse);
    expect(await actions().cancelRest(d.id, const LocalDate(2027, 1, 3)), isFalse);
  });

  test('満願と納め。納めたあとはひと回り大きいだるまを作れる', () async {
    final d = await open();
    await actions().complete(d.id);
    var b = (await deps.repo.bundle(d.id))!;
    expect(b.daruma.status, DarumaStatus.completed);
    expect(b.daruma.completedOn, const LocalDate(2027, 1, 1));
    await settle();
    expect(container.read(lookProvider(d.id))!.eyes, EyeState.both);

    final d2 = await open();
    await actions().retire(d2.id);
    b = (await deps.repo.bundle(d2.id))!;
    expect(b.daruma.status, DarumaStatus.retired);

    container.read(createDarumaProvider.notifier).startBigger(b.daruma);
    final form = container.read(createDarumaProvider);
    expect(form.sizeRank, 2);
    expect(form.parentId, d2.id);
    expect(form.name, '合格');
    final d3 = await actions().openEye(form);
    expect(d3.sizeRank, 2);
    expect(d3.parentId, d2.id);

    await settle();
    final shelf = container.read(shelfProvider);
    expect(shelf.active.single.id, d3.id);
    expect(shelf.completed.single.id, d.id);
    expect(shelf.retired.single.id, d2.id);
    expect(shelf.years, [2027]);
  });

  test('保存のたびにウィジェットへ14日分のタイムラインを書き、通知は設定がオンのときだけ予約する', () async {
    final d = await open(deadline: const LocalDate(2027, 1, 16), presetId: 'kyotsu_2027_main_day1');
    final snap = widgets().last!;
    expect(snap.look.darumaId, d.id);
    expect(snap.name, '合格');
    expect(snap.timeline.length, 14);
    expect(snap.timeline.first.daysLeft, 15);
    expect(snap.timeline.first.nextWaypointName, '模試');
    expect(snap.timeline.last.daysLeft, 2);
    expect(reminders().scheduled, isEmpty);
    expect((await deps.metrics.load())['preset_used'], 1);

    await container.read(settingsProvider.notifier).setReminder(enabled: true, minuteOfDay: 20 * 60);
    await actions().syncOutside();
    // 14日分（1/1〜1/14）。本番の日の分はアプリを開いたときの予約し直しで入る。
    expect(reminders().scheduled.length, 14);
    expect(reminders().scheduled.first.at, DateTime(2027, 1, 1, 20));
    expect(reminders().bodies.first, contains('あと15日'));
    expect(reminders().bodies.last, contains('あと2日'));

    advanceDays(15);
    await actions().syncOutside();
    expect(reminders().scheduled.length, 1);
    expect(reminders().bodies.single, contains('今日は共通テストの日'));

    await container.read(settingsProvider.notifier).setReminder(enabled: false);
    await actions().syncOutside();
    expect(reminders().scheduled, isEmpty);

    await actions().retire(d.id);
    expect(widgets().last, isNull);
  });

  test('JSON の書き出し・読み込みで同じ棚に戻る', () async {
    final d = await open(deadline: const LocalDate(2027, 1, 16));
    await actions().recordStep(d.id, memo: 'メモ');
    final json = await actions().exportJson();
    expect(json, contains('"version": 1'));

    await deps.repo.deleteDaruma(d.id);
    expect(await deps.repo.loadAll(), isEmpty);

    final result = await actions().importJson(json);
    expect(result.ok, isTrue);
    expect(result.darumas, 1);
    final b = (await deps.repo.bundle(d.id))!;
    expect(b.checkins.single.memo, 'メモ');
    expect(b.milestones.single.name, '模試');

    final bad = await actions().importJson('{"version": 9}');
    expect(bad.ok, isFalse);
  });

  test('今日は端末の日付で、日付の境界の設定に従う', () async {
    clock = DateTime(2027, 1, 2, 1, 30);
    container.read(todayProvider.notifier).refresh();
    expect(container.read(todayProvider), const LocalDate(2027, 1, 2));
    await container.read(settingsProvider.notifier).update((s) => s.copyWith(dayShiftHours: 3));
    expect(container.read(todayProvider), const LocalDate(2027, 1, 1));
  });
}
