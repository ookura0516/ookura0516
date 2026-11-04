import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local_date.dart';
import '../core/rules.dart';
import '../data/repository.dart';
import '../model/models.dart';
import 'providers.dart';

/// 今日の一歩を記録した結果。
class StepResult {
  const StepResult({
    required this.brushCount,
    required this.rose,
    this.milestone,
    this.alreadyDone = false,
  });

  /// 記録後の筆の数。
  final int brushCount;

  /// 転んでいたところから起き上がった（台座の金の筋が1本増えた）。
  final bool rose;

  /// この筆で到達した節目（7・21・50・100）。なければ null。
  final int? milestone;

  /// 今日はもう記録してあった。
  final bool alreadyDone;
}

/// だるまへの操作。記録のあとは必ずウィジェットを更新する。
class DarumaActions {
  DarumaActions(this._ref);

  final Ref _ref;

  DarumaRepository get _repo => _ref.read(repositoryProvider);
  LocalDate get _today => _ref.read(todayProvider);
  SettingsNotifier get _settings => _ref.read(settingsProvider.notifier);

  /// 作る。無料は現役1体まで（[ActiveDarumaExists]）。
  Future<Daruma> create(NewDaruma input) async {
    final d = await _repo.create(input, today: _today);
    await _settings.increment(Counters.created);
    await syncWidget();
    return d;
  }

  /// 開眼した（なぞり終えた）。作成と同じ日なので保存するものはなく、カウンタだけ。
  Future<void> markOpened() => _settings.increment(Counters.opened);

  Future<StepResult> recordStep(DarumaDetail d, {String? memo}) async {
    final today = _today;
    if (d.checkinOn(today) != null) {
      return StepResult(brushCount: d.brushCount, rose: false, alreadyDone: true);
    }
    final rose = Rules.risesOnStep(
      today: today,
      createdOn: d.daruma.createdOn,
      lastStepOn: d.lastStepOn,
    );
    await _repo.addCheckin(darumaId: d.daruma.id, date: today, memo: _cleanMemo(memo));
    if (rose) {
      await _repo.addRecovery(
        darumaId: d.daruma.id,
        fellAfter: d.lastStepOn ?? d.daruma.createdOn,
        roseOn: today,
      );
      await _settings.increment(Counters.rises);
    }
    await _settings.increment(Counters.steps);
    final count = d.brushCount + 1;
    await syncWidget();
    return StepResult(
      brushCount: count,
      rose: rose,
      milestone: Rules.isMilestone(count) ? count : null,
    );
  }

  /// 今日の記録を取り消す（当日だけ）。起き上がりも一緒に戻す。
  Future<void> undoToday(DarumaDetail d) async {
    final today = _today;
    final c = d.checkinOn(today);
    if (c == null) return;
    await _repo.removeCheckin(c.id);
    for (final r in d.recoveries) {
      if (r.roseOn == today) await _repo.removeRecovery(r.id);
    }
    await _settings.increment(Counters.undo);
    await syncWidget();
  }

  Future<void> setTodayMemo(DarumaDetail d, String? memo) async {
    final c = d.checkinOn(_today);
    if (c == null) return;
    await _repo.updateMemo(c.id, _cleanMemo(memo));
  }

  /// 両目（満願）。
  Future<void> complete(DarumaDetail d) async {
    await _repo.updateDaruma(
      d.daruma.copyWith(status: DarumaStatus.completed, completedOn: _today),
    );
    await _settings.increment(Counters.completed);
    await syncWidget();
  }

  /// 納める（片目のまま棚へ）。
  Future<void> retire(DarumaDetail d) async {
    await _repo.updateDaruma(
      d.daruma.copyWith(status: DarumaStatus.retired, retiredOn: _today),
    );
    await _settings.increment(Counters.retired);
    await syncWidget();
  }

  Future<void> updateGoal(
    Daruma d, {
    required LocalDate? deadline,
    required String? deadlineLabel,
    required String? dailyAction,
  }) async {
    await _repo.updateDaruma(d.copyWith(
      deadline: deadline,
      deadlineLabel: _clean(deadlineLabel),
      dailyAction: _clean(dailyAction),
    ));
    await syncWidget();
  }

  Future<void> countShare() => _settings.increment(Counters.shares);

  /// 現役のだるまをウィジェットに書き出す。
  Future<void> syncWidget() async {
    final active = await _repo.activeDetail();
    await _ref.read(widgetSyncProvider).sync(active, _today);
  }

  static String? _cleanMemo(String? memo) {
    final m = _clean(memo);
    if (m == null) return null;
    final runes = m.runes.toList();
    return runes.length > Rules.memoMaxLength
        ? String.fromCharCodes(runes.take(Rules.memoMaxLength))
        : m;
  }

  static String? _clean(String? s) {
    final t = s?.trim();
    return (t == null || t.isEmpty) ? null : t;
  }
}

final actionsProvider = Provider<DarumaActions>((ref) => DarumaActions(ref));
