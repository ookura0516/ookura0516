import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/backup.dart';
import '../core/countdown.dart';
import '../core/fall.dart';
import '../core/ids.dart';
import '../core/local_date.dart';
import '../core/look_builder.dart';
import '../core/reminder_planner.dart';
import '../core/rest_tickets.dart';
import '../core/review_policy.dart';
import '../core/strokes.dart';
import '../core/validation.dart';
import '../l10n/generated/app_localizations.dart';
import '../model/models.dart';
import '../services/reminder_service.dart';
import '../services/settings_store.dart';
import 'app_deps.dart';
import 'create_daruma.dart';
import 'providers.dart';

/// 今日の一歩の結果。画面の演出に使う。
class StepResult {
  const StepResult({required this.strokes, required this.rose, this.milestone});

  final int strokes;

  /// 転倒中からの起き上がりだった（金の筋が1本増えた）。
  final bool rose;

  /// ちょうど節目に達した。
  final StrokeMilestone? milestone;
}

class ImportResult {
  const ImportResult({required this.darumas, this.error});

  final int darumas;
  final String? error;

  bool get ok => error == null;
}

/// だるまへの操作。記録の書き込みと、それに伴う計測・ウィジェット・通知の更新をまとめる。
class DarumaActions {
  DarumaActions(this._ref);

  final Ref _ref;

  AppDeps get _deps => _ref.read(appDepsProvider);
  LocalDate get _today => _ref.read(todayProvider);

  // ------------------------------------------------------------ 作成・開眼

  /// 開眼して保存する。開眼日は今日。
  Future<Daruma> openEye(CreateDarumaForm form) async {
    final now = _deps.now();
    final id = newId();
    final daruma = Daruma(
      id: id,
      name: form.name.trim(),
      colorId: form.colorId,
      eyeSide: form.eyeSide,
      createdAt: now,
      openedOn: _today,
      deadline: form.deadline,
      deadlineName: form.deadlineName,
      deadlinePresetId: form.deadlinePresetId,
      dailyAction: form.dailyAction.trim().isEmpty ? null : form.dailyAction.trim(),
      status: DarumaStatus.active,
      sizeRank: form.sizeRank,
      parentId: form.parentId,
      seed: newSeed(),
    );
    await _deps.repo.insertDaruma(
      daruma,
      milestones: [
        for (final w in form.waypoints)
          Milestone(id: newId(), darumaId: id, name: w.name, date: w.date, presetId: w.presetId),
      ],
    );
    await _deps.metrics.increment(MetricKeys.darumaCreated);
    await _deps.metrics.increment(MetricKeys.eyeOpened);
    if (form.deadlinePresetId != null) await _deps.metrics.increment(MetricKeys.presetUsed);
    await syncOutside();
    return daruma;
  }

  // ------------------------------------------------------------ 今日の一歩

  Future<StepResult> recordStep(String darumaId, {String? memo}) async {
    final b = await _deps.repo.bundle(darumaId);
    if (b == null) throw StateError('だるまがない: $darumaId');
    final today = _today;
    final rose = FallJudge.wouldRise(
      openedOn: b.daruma.openedOn,
      today: today,
      stepDates: b.stepDates,
      restDates: b.restDates,
    );
    final trimmed = memo?.trim();
    await _deps.repo.recordStep(
      checkin: Checkin(
        id: newId(),
        darumaId: darumaId,
        date: today,
        kind: CheckinKind.step,
        memo: trimmed == null || trimmed.isEmpty ? null : _clip(trimmed),
        createdAt: _deps.now(),
      ),
      recovery: rose
          ? Recovery(
              id: newId(),
              darumaId: darumaId,
              fellAfter: FallJudge.lastStepDay(openedOn: b.daruma.openedOn, today: today, stepDates: b.stepDates),
              roseOn: today,
            )
          : null,
    );
    final strokes = b.stepDates.where((d) => d <= today).length + 1;
    final milestone = StrokeMilestone.reachedAt(strokes);
    await _deps.metrics.increment(MetricKeys.stepRecorded);
    if (rose) await _deps.metrics.increment(MetricKeys.rose);
    if (milestone != null) {
      await _deps.metrics.increment(switch (milestone) {
        StrokeMilestone.day7 => MetricKeys.milestone7,
        StrokeMilestone.day21 => MetricKeys.milestone21,
        StrokeMilestone.day50 => MetricKeys.milestone50,
        StrokeMilestone.day100 => MetricKeys.milestone100,
      });
    }
    await syncOutside();
    return StepResult(strokes: strokes, rose: rose, milestone: milestone);
  }

  /// 取り消しは当日だけ。
  Future<void> undoStep(String darumaId) async {
    await _deps.repo.undoStep(darumaId: darumaId, date: _today);
    await _deps.metrics.increment(MetricKeys.stepUndone);
    await syncOutside();
  }

  Future<void> setMemo(String darumaId, LocalDate date, String memo) async {
    final b = await _deps.repo.bundle(darumaId);
    final c = b?.checkinOn(date);
    if (c == null || c.kind != CheckinKind.step) return;
    final t = memo.trim();
    await _deps.repo.upsertCheckin(c.copyWith(memo: t.isEmpty ? null : _clip(t)));
  }

  static String _clip(String s) =>
      s.runes.length <= Limits.memoMax ? s : String.fromCharCodes(s.runes.take(Limits.memoMax));

  // ------------------------------------------------------------ 休み券

  Future<RestDecision> declareRest(String darumaId, LocalDate forDate) async {
    final b = await _deps.repo.bundle(darumaId);
    if (b == null) return RestDecision.tooLate;
    final decision = RestTickets.canDeclare(
      today: _today,
      forDate: forDate,
      restDates: b.restDates,
      deadline: b.daruma.deadline,
    );
    if (decision != RestDecision.ok) return decision;
    await _deps.repo.upsertCheckin(
      Checkin(id: newId(), darumaId: darumaId, date: forDate, kind: CheckinKind.rest, createdAt: _deps.now()),
    );
    await _deps.metrics.increment(MetricKeys.restDeclared);
    await syncOutside();
    return RestDecision.ok;
  }

  Future<bool> cancelRest(String darumaId, LocalDate forDate) async {
    if (!RestTickets.canCancel(today: _today, forDate: forDate)) return false;
    await _deps.repo.deleteCheckin(darumaId: darumaId, date: forDate);
    await syncOutside();
    return true;
  }

  // ------------------------------------------------------------ 満願・納め・変更

  /// 両目を入れる（満願）。
  Future<void> complete(String darumaId) async {
    final d = await _deps.repo.find(darumaId);
    if (d == null) return;
    await _deps.repo.updateDaruma(d.copyWith(status: DarumaStatus.completed, completedAt: _deps.now()));
    await _deps.metrics.increment(MetricKeys.completed);
    await syncOutside();
  }

  /// 納める（削除ではなく棚の「納め」段へ）。
  Future<void> retire(String darumaId) async {
    final d = await _deps.repo.find(darumaId);
    if (d == null) return;
    await _deps.repo.updateDaruma(d.copyWith(status: DarumaStatus.retired, retiredAt: _deps.now()));
    await _deps.metrics.increment(MetricKeys.retired);
    await syncOutside();
  }

  Future<void> markAskedAtDeadline(String darumaId) async {
    final d = await _deps.repo.find(darumaId);
    if (d == null) return;
    await _deps.repo.updateDaruma(d.copyWith(askedAtDeadline: true));
  }

  Future<void> updateGoal(
    String darumaId, {
    LocalDate? deadline,
    bool clearDeadline = false,
    String? deadlineName,
    String? deadlinePresetId,
    String? dailyAction,
    List<WaypointInput>? waypoints,
  }) async {
    final d = await _deps.repo.find(darumaId);
    if (d == null) return;
    await _deps.repo.updateDaruma(
      d.copyWith(
        deadline: clearDeadline ? null : (deadline ?? d.deadline),
        deadlineName: clearDeadline ? null : (deadlineName ?? d.deadlineName),
        deadlinePresetId: clearDeadline ? null : (deadlinePresetId ?? d.deadlinePresetId),
        dailyAction: dailyAction == null ? d.dailyAction : (dailyAction.trim().isEmpty ? null : dailyAction.trim()),
      ),
    );
    if (waypoints != null) {
      await _deps.repo.replaceMilestones(darumaId, [
        for (final w in waypoints.take(Limits.waypointsMax))
          Milestone(id: newId(), darumaId: darumaId, name: w.name, date: w.date, presetId: w.presetId),
      ]);
    }
    await syncOutside();
  }

  // ------------------------------------------------------------ 評価・計測

  /// 評価依頼を出してよければ出す。7日目の節目と両目の直後だけ呼ぶ。
  Future<bool> maybeRequestReview(ReviewOccasion occasion) async {
    final settings = _ref.read(settingsProvider);
    if (!ReviewPromptPolicy.shouldPrompt(
      occasion: occasion,
      today: _today,
      promptedOn: settings.reviewPromptedOn,
    )) {
      return false;
    }
    await _ref.read(settingsProvider.notifier).addReviewPrompt(_today);
    await _deps.metrics.increment(MetricKeys.reviewPrompted);
    await _deps.review.requestReview();
    return true;
  }

  Future<void> count(String key) => _deps.metrics.increment(key);

  // ------------------------------------------------------------ ウィジェットと通知

  /// 保存のたびに呼ぶ。ウィジェットに DarumaLook と14日分のタイムラインを書き、通知を予約し直す。
  Future<void> syncOutside() async {
    final all = await _deps.repo.loadAll();
    final settings = _ref.read(settingsProvider);
    final today = _today;
    final active = all.where((b) => b.daruma.isActive).toList();
    DarumaBundle? target;
    for (final b in active) {
      if (b.id == settings.widgetDarumaId) target = b;
    }
    target ??= active.isEmpty ? null : active.first;

    if (target == null) {
      await _deps.widgetSync.sync(null);
      await _deps.reminders.cancelAll();
      return;
    }
    final look = buildLookFromBundle(target, today);
    await _deps.widgetSync.sync(
      WidgetSnapshot(
        look: look,
        name: target.daruma.name,
        deadlineName: target.daruma.deadlineName,
        timeline: Countdown.timeline(
          from: today,
          deadline: target.daruma.deadline,
          waypoints: target.waypoints,
        ),
        generatedAt: _deps.now(),
        style: settings.widgetStyle,
      ),
    );

    if (!settings.reminderEnabled) {
      await _deps.reminders.cancelAll();
      return;
    }
    final l = lookupAppLocalizations(_deps.locale);
    final name = target.daruma.deadlineName ?? '';
    await _deps.reminders.schedule(
      ReminderPlanner.plan(
        now: _deps.now(),
        today: today,
        minuteOfDay: settings.reminderMinuteOfDay,
        deadline: target.daruma.deadline,
      ),
      texts: ReminderTexts(
        title: (_) => l.appName,
        body: (e) {
          final days = e.daysLeft;
          if (days == null) return l.reminderBodyPlain;
          if (days == 0) return l.reminderBodyDeadlineToday(name);
          return l.reminderBodyWithDeadline(name, days);
        },
      ),
    );
  }

  // ------------------------------------------------------------ 書き出し・読み込み（プラス）

  Future<String> exportJson() async {
    final all = await _deps.repo.loadAll();
    final text = BackupCodec.encode(
      BackupCodec.fromBundles(all, exportedAt: _deps.now(), settings: _ref.read(settingsProvider)),
    );
    await _deps.metrics.increment(MetricKeys.exported);
    return text;
  }

  Future<ImportResult> importJson(String text) async {
    final BackupData data;
    try {
      data = BackupCodec.decode(text);
    } on FormatException catch (e) {
      return ImportResult(darumas: 0, error: e.message);
    } catch (e) {
      return ImportResult(darumas: 0, error: e.toString());
    }
    final bundles = BackupCodec.toBundles(data);
    await _deps.repo.importBundles(bundles);
    await _deps.metrics.increment(MetricKeys.imported);
    await syncOutside();
    return ImportResult(darumas: bundles.length);
  }
}

final darumaActionsProvider = Provider<DarumaActions>(DarumaActions.new);
