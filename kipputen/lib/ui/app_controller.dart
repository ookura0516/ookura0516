import 'package:flutter/foundation.dart';

import '../core/expr.dart';
import '../core/judge.dart';
import '../core/puzzle_picker.dart';
import '../core/solution_book.dart';
import '../core/solver.dart';
import '../core/special_numbers.dart';
import '../daily/daily.dart';
import '../data/records.dart';
import '../monetize/ad_service.dart';
import '../monetize/products.dart';
import '../monetize/purchase_service.dart';
import '../platform/adapters.dart';
import 'ticket_design.dart';

/// 全解探しで数える上限。解が多い日は5つで「完」。
const int solutionCap = 5;

/// 正解を出したときの結果。
class SubmitResult {
  const SubmitResult(
    this.judgement, {
    this.firstSolve = false,
    this.newlyFound = false,
    this.completed = false,
  });

  final Judgement judgement;

  /// この番号を初めて解いた。
  final bool firstSolve;

  /// まだ見つけていない解だった。
  final bool newlyFound;

  /// これで全解（上限5つ）がそろった。
  final bool completed;
}

/// アプリ全体の状態。
class AppController extends ChangeNotifier {
  AppController({
    required this.book,
    required this.picker,
    required this.records,
    required this.purchases,
    this.ads = const NoAdService(),
    DailyClock? clock,
    this.widgets = const WidgetExporter(NoWidgetSink()),
    this.review = const NoReviewService(),
    this.share = const SharePlusService(),
    this.reminders = const NoReminderService(),
  }) : clock = clock ?? DailyClock() {
    purchases.addListener(notifyListeners);
    _firstUseDay = records.plays.keys.isEmpty
        ? this.clock.today
        : Day.parse((records.plays.keys.toList()..sort()).first);
  }

  final SolutionBook book;
  final PuzzlePicker picker;
  final Records records;
  final PurchaseService purchases;
  final AdService ads;
  final DailyClock clock;
  final WidgetExporter widgets;
  final ReviewService review;
  final ShareService share;
  final ReminderService reminders;
  late final Day _firstUseDay;

  Settings get settings => records.settings;

  // ------------------------------------------------------------ 今日

  Day get today => clock.today;

  DailyPuzzle get todayPuzzle => picker.forDay(today);

  bool solvedToday() => records.plays[today.key]?.cleared ?? false;

  /// 今日の切符を開いた。初回なら記録を作る。
  void openToday() {
    final p = todayPuzzle;
    if (!records.plays.containsKey(p.day.key)) {
      records.plays[p.day.key] = PlayLog(day: p.day.key, number: p.number);
      records.savePlays();
    }
  }

  Streak get streak => Streak.compute(records.clearedDays, today);

  // ------------------------------------------------------------ 解く

  List<Solution> solutionsFor(String number) => book.solutionsFor(number);

  /// 全解探しの目標数（解の数。ただし5つまで）。
  int goalFor(String number) {
    final n = book.solutionsFor(number).length;
    return n < solutionCap ? n : solutionCap;
  }

  SolvedRecord? recordOf(String number) => records.solved[number];

  int foundCount(String number) => records.solved[number]?.found.length ?? 0;

  int remaining(String number) {
    final r = goalFor(number) - foundCount(number);
    return r < 0 ? 0 : r;
  }

  /// 見つけた解の式（見つけた順）。
  List<String> foundDisplays(String number) {
    final r = records.solved[number];
    if (r == null) return const [];
    return [for (final k in r.found) r.displays[k] ?? k];
  }

  /// 式を判定して記録する。[daily] は今日の切符として解いたか、[seconds] は開いてからの秒数。
  Future<SubmitResult> submit(
    String number,
    Expr e, {
    String? inputText,
    bool daily = false,
    int? seconds,
  }) async {
    final j = judge(book, number, e, inputText: inputText);
    if (!j.isCorrect) return SubmitResult(j);

    var rec = records.solved[number];
    final firstSolve = rec == null;
    rec ??= records.solved[number] = SolvedRecord(
      number: number,
      firstSolvedAt: today.key,
    );
    final newlyFound = !rec.found.contains(j.key);
    var completed = false;
    if (newlyFound) {
      rec.found.add(j.key!);
      rec.displays[j.key!] = j.display!;
      if (!rec.allFound && rec.found.length >= goalFor(number)) {
        rec.allFound = completed = true;
      }
      if (j.isNewSolution) {
        records.newSolutionLog.add('$number: ${j.display}');
        await records.saveNewSolutions();
      }
    }
    await records.saveSolved();

    if (daily) {
      final log = records.plays[today.key] ??= PlayLog(
        day: today.key,
        number: number,
      );
      if (!log.cleared) {
        log.cleared = true;
        log.seconds = seconds;
        await records.savePlays();
        await exportWidget();
        await scheduleReminders();
      }
    }

    if (completed && _isFirstEverComplete()) await _maybeAskReview();
    if (firstSolve && _pageJustCompleted(number)) await _maybeAskReview();

    notifyListeners();
    return SubmitResult(
      j,
      firstSolve: firstSolve,
      newlyFound: newlyFound,
      completed: completed,
    );
  }

  // ------------------------------------------------------------ 図鑑

  int get solvedCount => records.solved.length;

  int get collectibleCount => book.solvableNumberCount;

  bool isSpecialNumber(String number) =>
      isSpecial(number, birthday: settings.birthday);

  /// 図鑑の1ページ（千の位が同じ1,000番号）。解のある番号を全部解いたか。
  bool pageComplete(int page) {
    for (var i = page * 1000; i < page * 1000 + 1000; i++) {
      final n = formatNumber(i);
      if (book.isSolvable(n) && !records.solved.containsKey(n)) return false;
    }
    return true;
  }

  bool _pageJustCompleted(String number) => pageComplete(int.parse(number[0]));

  bool _isFirstEverComplete() =>
      records.solved.values.where((r) => r.allFound).length == 1;

  Future<void> _maybeAskReview() async {
    final now = clock.nowUtc;
    if (!const ReviewPolicy().shouldAsk(
      pastAsks: records.reviewAsks,
      now: now,
      isFirstUseDay: _firstUseDay == today,
    )) {
      return;
    }
    records.reviewAsks.add(now);
    await records.saveReviewAsks();
    await review.request();
  }

  // ------------------------------------------------------------ 成績

  /// 日替わりで解いた日の平均秒数。まだなら null。
  int? get averageSeconds {
    final s = [
      for (final p in records.plays.values)
        if (p.cleared && p.seconds != null) p.seconds!,
    ];
    if (s.isEmpty) return null;
    return s.reduce((a, b) => a + b) ~/ s.length;
  }

  int get dailyClearedCount =>
      records.plays.values.where((p) => p.cleared).length;

  // ------------------------------------------------------------ 設定・購入

  TicketDesign get design {
    final d = TicketDesign.byId(settings.design);
    return d.pack && !owns(Product.designPack) ? TicketDesign.standard : d;
  }

  bool owns(Product p) => purchases.owns(p);

  bool get showAds => !owns(Product.removeAds);

  Future<void> updateSettings(void Function(Settings s) change) async {
    change(settings);
    await records.saveSettings();
    notifyListeners();
  }

  Future<void> initServices() async {
    await purchases.init();
    if (showAds) await ads.init();
    await exportWidget();
    await scheduleReminders();
  }

  // ------------------------------------------------------------ 通知

  /// 先に予約しておく日数。アプリを開くたびに予約し直すので、開かない日が続くと止まる。
  static const reminderDays = 7;

  /// これから出す通知。今日の分は、まだ解いていなくて時刻が過ぎていないときだけ。
  Map<int, Reminder> plannedReminders() {
    if (!settings.notify) return const {};
    final out = <int, Reminder>{};
    for (var i = 0; i < reminderDays; i++) {
      final d = today.addDays(i);
      final at = DailyClock.startOf(
        d,
      ).add(Duration(minutes: settings.notifyMinutes));
      if (!at.isAfter(clock.nowUtc)) continue;
      if (records.plays[d.key]?.cleared ?? false) continue;
      out[Reminder.idFor(d)] = Reminder(
        at: at,
        title: 'キップテン',
        body: '今日は ${picker.forDay(d).number}',
      );
    }
    return out;
  }

  Future<void> scheduleReminders() async {
    try {
      await reminders.replaceAll(plannedReminders());
    } catch (e) {
      debugPrint('reminder schedule failed: $e');
    }
  }

  /// 通知をオンにする。許可されなければオフのまま false を返す。
  Future<bool> setNotify(bool on) async {
    if (on && !await reminders.requestPermission()) return false;
    await updateSettings((s) => s.notify = on);
    await scheduleReminders();
    return true;
  }

  Future<void> setNotifyTime(int minutes) async {
    await updateSettings((s) => s.notifyMinutes = minutes);
    await scheduleReminders();
  }

  // ------------------------------------------------------------ ウィジェット

  /// 今日と明日の分を書き出し、JST 0時に描き直すよう予約する。
  Future<void> exportWidget() async {
    final t = today;
    final days = [t, t.addDays(1)];
    try {
      await widgets.export(
        [
          for (final d in days)
            WidgetDay(
              day: d,
              title: picker.forDay(d).number,
              done: records.plays[d.key]?.cleared ?? false,
            ),
        ],
        switchAt: [
          DailyClock.startOf(t.addDays(1)),
          DailyClock.startOf(t.addDays(2)),
        ],
      );
    } catch (e) {
      // ウィジェットの書き出しに失敗しても遊びは止めない。
      debugPrint('widget export failed: $e');
    }
  }

  @override
  void dispose() {
    purchases.removeListener(notifyListeners);
    super.dispose();
  }
}
