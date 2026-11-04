import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/kigo.dart';
import '../core/mora.dart';
import '../core/review_policy.dart';
import '../core/season.dart';
import '../core/streak.dart';
import '../core/theme_picker.dart';
import '../data/database.dart';
import '../data/repository.dart';
import '../render/style.dart';
import '../services/platform_services.dart';
import '../services/purchase_service.dart';
import '../services/settings_store.dart';

/// 詠みかけの句を調べた結果。
class DraftAnalysis {
  const DraftAnalysis({
    required this.lines,
    required this.mora,
    required this.detection,
  });

  final List<String> lines;
  final List<MoraCount> mora;
  final KigoDetection detection;

  String get body => joinLines(lines);
  Kigo? get kigo => detection.primary;

  /// 空白・改行を除いて、`lines.join('\n')` の中の季語の位置。
  List<(int, int)> get kigoRanges => [
    for (final h in detection.hits) (h.start, h.end),
  ];

  bool get isEmpty => lines.every((l) => l.trim().isEmpty);

  String get note => moraNote(mora);
  MoraCount get total => mora.fold(const MoraCount(0), (a, b) => a + b);
}

/// 3行を本文にする。後ろの空行は落とす。
String joinLines(List<String> lines) {
  final l = [for (final s in lines) s.trim()];
  while (l.isNotEmpty && l.last.isEmpty) {
    l.removeLast();
  }
  return l.join('\n');
}

List<String> splitLines(String body) {
  final l = body.split('\n');
  while (l.length < 3) {
    l.add('');
  }
  if (l.length > 3) return [l[0], l[1], l.sublist(2).join('')];
  return l;
}

/// アプリ全体の状態。句はすべて手元（SQLite）にあり、起動時に読み込んで持っておく。
class AppController extends ChangeNotifier {
  AppController({
    required this.repo,
    required this.dictionary,
    required Map<String, String> extraReadings,
    required this.settings,
    required this.purchases,
    required this.share,
    required this.notifications,
    required this.widgets,
    required this.review,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now,
       mora = MoraCounter({...extraReadings, ...dictionary.readings}) {
    purchases.addListener(notifyListeners);
  }

  final HaikuRepository repo;
  final KigoDictionary dictionary;
  final MoraCounter mora;
  final SettingsStore settings;
  final PurchaseService purchases;
  final ShareSink share;
  final NotificationService notifications;
  final HomeWidgetService widgets;
  final ReviewPrompter review;
  final DateTime Function() _clock;

  List<HaikuRow> _haiku = const [];
  List<HaikuRow> get haiku => _haiku;

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    _haiku = await repo.allHaiku();
    _loaded = true;
    notifyListeners();
    unawaited(_afterChange(rescheduleNotifications: true));
  }

  // ------------------------------------------------------------ 日付と季節

  DateTime get now => _clock();

  /// 日本時間の今日。
  DateTime get today => jstToday(_clock());
  DateTime get yesterday => DateTime(today.year, today.month, today.day - 1);

  Season get season => seasonOf(today);
  SolarTerm get solarTerm => currentSolarTerm(today);
  (SolarTerm, DateTime) get upcomingSeasonChange => nextSeasonChange(today);

  Kigo? themeFor(DateTime date) => pickDailyTheme(date, dictionary.entries);
  Kigo? get todayTheme => themeFor(today);

  StreakInfo get streak =>
      computeStreak(_haiku.map((h) => h.composedOn), today);

  List<HaikuRow> get recent => _haiku.take(10).toList();

  // ------------------------------------------------------------ 句

  DraftAnalysis analyze(List<String> lines) {
    final body = lines.map((l) => l.trim()).join('\n');
    return DraftAnalysis(
      lines: lines,
      mora: mora.countLines(lines),
      detection: dictionary.detect(body),
    );
  }

  /// 句の本文から季語の位置を出す（短冊の色分け用）。
  DraftAnalysis analyzeBody(String body) => analyze(splitLines(body));

  Future<HaikuRow> addHaiku({
    required List<String> lines,
    String maegaki = '',
    Kigo? theme,
    DateTime? composedOn,
  }) async {
    final a = analyze(lines);
    final k = a.kigo;
    final day = composedOn ?? today;
    final row = await repo.addHaiku(
      body: a.body,
      maegaki: maegaki.trim(),
      kigoId: k?.id,
      season: k?.season.label ?? '',
      composedOn: day,
      themeKigoId: theme?.id,
    );
    if (theme != null) await repo.logTheme(day, theme.id);
    await _reload();
    return row;
  }

  /// 推敲。前の版は履歴に残る。
  Future<HaikuRow> revise(
    int id, {
    required List<String> lines,
    String? maegaki,
  }) async {
    final a = analyze(lines);
    final k = a.kigo;
    final row = await repo.updateHaiku(
      id,
      body: a.body,
      maegaki: maegaki?.trim(),
      kigoId: k?.id,
      clearKigo: k == null,
      season: k?.season.label ?? '',
    );
    await _reload();
    return row;
  }

  Future<void> setMemo(int id, String memo) async {
    await repo.updateHaiku(id, memo: memo);
    await _reload();
  }

  Future<void> toggleFavorite(HaikuRow h) async {
    await repo.setFavorite(h.id, !h.favorite);
    await _reload();
  }

  Future<void> delete(int id) async {
    await repo.deleteHaiku(id);
    await _reload();
  }

  HaikuRow? haikuById(int id) {
    for (final h in _haiku) {
      if (h.id == id) return h;
    }
    return null;
  }

  Future<void> _reload() async {
    _haiku = await repo.allHaiku();
    notifyListeners();
    await _afterChange();
  }

  // ------------------------------------------------------------ 購入

  bool get hasSuzuri => purchases.hasSuzuri;

  /// 前回の見た目。すずりがなければ無料の範囲に戻す。
  TanzakuStyle get lastStyle {
    final s = settings.style;
    return hasSuzuri ? s : s.freeOnly;
  }

  Future<void> rememberStyle(TanzakuStyle s) => settings.setStyle(s);

  // ------------------------------------------------------------ 設定

  String get gago => settings.gago;

  Future<void> setGago(String v) async {
    await settings.setGago(v);
    notifyListeners();
  }

  bool get notifyEnabled => settings.notifyEnabled;
  int get notifyMinutes => settings.notifyMinutes;

  /// 通知を入れる。許可が得られなければ false。
  Future<bool> setNotify(bool enabled, {int? minutes}) async {
    if (minutes != null) await settings.setNotifyMinutes(minutes);
    if (enabled) {
      final ok = await notifications.requestPermission();
      if (!ok) {
        await settings.setNotifyEnabled(false);
        notifyListeners();
        return false;
      }
    }
    await settings.setNotifyEnabled(enabled);
    await _scheduleNotifications();
    notifyListeners();
    return true;
  }

  Future<void> _scheduleNotifications() async {
    if (!settings.notifyEnabled) {
      await notifications.cancelAll();
      return;
    }
    // 季語は日ごとに変わるので、14日分を1件ずつ入れる。起動のたびに入れ直す。
    final items = <(DateTime, String, String)>[];
    for (var i = 0; i < 14; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      final k = themeFor(d);
      if (k == null) continue;
      items.add((
        d,
        '今日の兼題　${k.word}',
        '${k.reading}（${k.season.label}・${k.category}）',
      ));
    }
    await notifications.scheduleThemes(items, settings.notifyMinutes);
  }

  // ------------------------------------------------------------ 書き出し

  Future<String> exportJson() => repo.exportJson();

  /// 読み込んだ句の数。ファイルが違えば [ImportException]。
  Future<int> importJson(String json) async {
    final int n;
    try {
      n = await repo.importJson(json);
    } on ImportException {
      rethrow;
    } catch (_) {
      throw const ImportException('ファイルの中身が読めませんでした');
    }
    await _reload();
    return n;
  }

  // ------------------------------------------------------------ 評価依頼

  /// 短冊を保存・共有した直後に呼ぶ。
  Future<void> afterTanzakuSaved() async {
    final count = _haiku.length;
    final t = _clock();
    if (!shouldAskForReview(
      haikuCount: count,
      askedAt: settings.reviewAskedAt,
      askedMilestones: settings.reviewMilestones,
      now: t,
    )) {
      return;
    }
    await settings.recordReview(t, count);
    try {
      await review.request();
    } catch (_) {}
  }

  // ------------------------------------------------------------ ウィジェット

  WidgetSnapshot widgetSnapshot() {
    String ymd(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final t = today;
    final tomorrow = DateTime(t.year, t.month, t.day + 1);
    final k = themeFor(t);
    final k2 = themeFor(tomorrow);
    final s = streak;
    return WidgetSnapshot(
      date: ymd(t),
      kigo: k?.word ?? '',
      kigoReading: k?.reading ?? '',
      season: k?.season.label ?? '',
      tomorrowDate: ymd(tomorrow),
      tomorrowKigo: k2?.word ?? '',
      tomorrowReading: k2?.reading ?? '',
      tomorrowSeason: k2?.season.label ?? '',
      // 明日のぶんは、今日詠んでいれば続いている日数をそのまま出す。
      streak: s.days,
      composedToday: s.composedToday,
      latestHaiku: _haiku.isEmpty
          ? ''
          : _haiku.first.body.replaceAll('\n', '　'),
    );
  }

  Future<void> _afterChange({bool rescheduleNotifications = false}) async {
    try {
      await widgets.update(widgetSnapshot());
      if (rescheduleNotifications) await _scheduleNotifications();
    } catch (e) {
      debugPrint('background update failed: $e');
    }
  }

  @override
  void dispose() {
    purchases.removeListener(notifyListeners);
    super.dispose();
  }
}
