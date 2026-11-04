import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:ookura_daily/ookura_daily_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/puzzle.dart';
import '../core/puzzle_bundle.dart';
import '../core/schedule.dart';
import '../core/tutorial.dart';
import '../game/daily_notice.dart';
import '../game/game_session.dart';
import '../game/play_log.dart';
import '../game/settings.dart';
import '../game/stats.dart';
import '../game/widget_data.dart';
import '../monetize/ad_service.dart';
import '../monetize/purchase_service.dart';

/// 無料で遊べるアーカイブの日数（今日を除く、さかのぼれる日数）。
const int kFreeArchiveDays = 7;

/// 遊ぶ1問と、それが第何日の問題か。
class PuzzleEntry {
  const PuzzleEntry({
    required this.day,
    required this.puzzle,
    this.date,
    this.rerun = false,
  });

  /// 第何日か。チュートリアルは 0。
  final int day;
  final Puzzle puzzle;
  final CivilDate? date;

  /// 問題が尽きて、過去の問題を出している日か。
  final bool rerun;

  bool get isTutorial => day == 0;
}

/// アプリ全体の状態。画面はここを見て描く。
class AppController extends ChangeNotifier with WidgetsBindingObserver {
  AppController({
    required SharedPreferences prefs,
    required this.bundle,
    required this.purchases,
    this.ads = const NoAdService(),
    this.notifications = const NoNotificationService(),
    this.widgets = const NoWidgetSink(),
    this.share = const SystemShareSheet(),
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now,
       settings = Settings(prefs),
       log = PlayLog(prefs),
       schedule = PuzzleSchedule(count: bundle.count) {
    purchases.addListener(notifyListeners);
  }

  final PuzzleBundle bundle;
  final PurchaseService purchases;
  final AdService ads;
  final NotificationService notifications;
  final DailyWidgetSink widgets;
  final ShareSheet share;
  final Settings settings;
  final PlayLog log;
  final PuzzleSchedule schedule;
  final DateTime Function() _now;

  final Map<int, GameSession> _sessions = {};
  Timer? _switchTimer;
  int? _lastDay;

  DailyClock get clock => bundle.clock;
  DateTime now() => _now();

  /// 今日は第何日か（日本時間の0時で替わる）。
  int get today => clock.dayNumberAt(now());

  // ── 起動 ──────────────────────────────

  /// 画面を出したあとに呼ぶ。広告・購入の準備、ウィジェットと通知の更新、
  /// 0時の切り替えの見張りを始める。
  Future<void> start() async {
    WidgetsBinding.instance.addObserver(this);
    _lastDay = today;
    _armSwitchTimer();
    await Future.wait([
      purchases.init().catchError((_) {}),
      ads.init().catchError((_) {}),
    ]);
    await refreshOutside();
  }

  @override
  void dispose() {
    _switchTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    purchases.removeListener(notifyListeners);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) checkDayChange();
  }

  void _armSwitchTimer() {
    _switchTimer?.cancel();
    final wait = clock.nextSwitchAfter(now()).difference(now());
    _switchTimer = Timer(wait + const Duration(seconds: 1), () {
      checkDayChange();
      _armSwitchTimer();
    });
  }

  /// 日付が替わっていたら、画面とウィジェットを今日に合わせる。
  void checkDayChange() {
    if (_lastDay == today) return;
    _lastDay = today;
    notifyListeners();
    refreshOutside();
  }

  /// ウィジェットと通知の予約を、いまの記録に合わせて書き直す。
  Future<void> refreshOutside() async {
    await widgets.write(
      widgetSnapshot(clock: clock, now: now(), streakDays: _streakDays),
    );
    if (settings.notify) {
      await notifications.replaceAll(
        planNotices(
          clock: clock,
          now: now(),
          hour: settings.notifyHour,
          todayDone: log.recordFor(today) != null,
        ),
      );
    }
  }

  // ── 問題 ──────────────────────────────

  PuzzleEntry get tutorial =>
      const PuzzleEntry(day: 0, puzzle: kTutorialPuzzle);

  /// 第 [day] 日の問題。まだ公開前、または問題がなければ null。
  PuzzleEntry? entryFor(int day) {
    if (day < 1 || day > today) return null;
    final number = schedule.puzzleFor(day);
    if (number == null) return null;
    try {
      return PuzzleEntry(
        day: day,
        puzzle: bundle.open(number, today: today),
        date: clock.dateOf(day),
        rerun: schedule.isRerun(day),
      );
    } on Object {
      return null;
    }
  }

  PuzzleEntry? get todayEntry => entryFor(today);

  /// 解いている途中の状態。記録があればそこから作り直す。
  GameSession sessionFor(PuzzleEntry e) {
    final cached = _sessions[e.day];
    if (cached != null && identical(cached.puzzle, e.puzzle)) return cached;
    final guesses = log.recordFor(e.day)?.guesses ?? log.progressFor(e.day);
    return _sessions[e.day] = GameSession(
      e.puzzle,
      guesses: guesses,
      seed: e.day * 31 + 7,
    );
  }

  /// 決定を押したあとに呼ぶ。途中なら保存、終わったら記録を残す。
  Future<void> afterSubmit(PuzzleEntry e, GameSession s) async {
    if (e.isTutorial) {
      if (s.finished) await settings.setTutorialDone();
      notifyListeners();
      return;
    }
    if (!s.finished) {
      await log.saveProgress(e.day, s.guesses);
    } else if (log.recordFor(e.day) == null) {
      await log.finish(
        PlayRecord(
          day: e.day,
          puzzle: e.puzzle.number,
          playedOnDay: today,
          guesses: s.guesses,
          cleared: s.cleared,
          mistakes: s.mistakes,
        ),
      );
      unawaited(refreshOutside());
    }
    notifyListeners();
  }

  /// チュートリアルを飛ばす。
  Future<void> skipTutorial() async {
    await settings.setTutorialDone();
    notifyListeners();
  }

  /// チュートリアルの解きかけを捨てる（もう一度遊ぶとき）。
  void resetTutorial() => _sessions.remove(0);

  // ── 記録と成績 ──────────────────────────

  PlayRecord? recordFor(int day) => log.recordFor(day);

  Iterable<int> get _streakDays => [
    for (final r in log.records)
      if (r.countsForStreak) r.day,
  ];

  StreakSummary get streak => computeStreak(_streakDays, today);

  PlayStats get stats => PlayStats.compute(
    log.records,
    today: today,
    puzzleOf: (r) => _puzzleOf(r),
  );

  Puzzle? _puzzleOf(PlayRecord r) {
    try {
      return bundle.open(r.puzzle, today: today);
    } on Object {
      return null;
    }
  }

  // ── アーカイブと購入 ──────────────────────

  /// アーカイブに並べる日（新しい順）。
  List<int> get archiveDays => [for (var d = today; d >= 1; d--) d];

  /// 無料では開けない日か。
  bool isLocked(int day) => !purchases.owned && today - day > kFreeArchiveDays;

  /// 広告を出すか（全問パックを持っていれば出さない）。
  bool get showAds => !purchases.owned;

  // ── 設定 ──────────────────────────────

  Future<void> setColorNames(bool v) async {
    await settings.setColorNames(v);
    notifyListeners();
  }

  /// 通知を入れる。許可が得られなければ false を返し、オフのまま。
  Future<bool> setNotify(bool on) async {
    if (on) {
      final ok = await notifications.requestPermission();
      if (!ok) {
        notifyListeners();
        return false;
      }
    }
    await settings.setNotify(on);
    if (on) {
      await refreshOutside();
    } else {
      await notifications.replaceAll(const []);
    }
    notifyListeners();
    return true;
  }

  Future<void> setNotifyHour(int hour) async {
    await settings.setNotifyHour(hour);
    await refreshOutside();
    notifyListeners();
  }
}
