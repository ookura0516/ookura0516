import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../daily/daily.dart';

/// 解いた番号1つの記録（図鑑はここから描く）。
class SolvedRecord {
  SolvedRecord({
    required this.number,
    required this.firstSolvedAt,
    List<String>? found,
    Map<String, String>? displays,
    this.allFound = false,
  }) : found = found ?? [],
       displays = displays ?? {};

  final String number;

  /// 初めて解いた日（「20261104」）。
  final String firstSolvedAt;

  /// 見つけた解の正規形のキー（見つけた順）。
  final List<String> found;

  /// 見つけた解の、画面に出す式（キー → 式）。
  final Map<String, String> displays;

  bool allFound;

  Map<String, Object> toJson() => {
    'n': number,
    'first': firstSolvedAt,
    'found': found,
    'disp': displays,
    'all': allFound,
  };

  factory SolvedRecord.fromJson(Map<String, dynamic> j) => SolvedRecord(
    number: j['n'] as String,
    firstSolvedAt: j['first'] as String,
    found: [...(j['found'] as List).cast<String>()],
    displays: (j['disp'] as Map).cast<String, String>(),
    allFound: j['all'] as bool? ?? false,
  );
}

/// 日替わりで遊んだ1日の記録。
class PlayLog {
  PlayLog({
    required this.day,
    required this.number,
    this.seconds,
    this.cleared = false,
  });

  final String day;
  final String number;

  /// 初めて正解するまでの秒数。
  int? seconds;
  bool cleared;

  Map<String, Object?> toJson() => {
    'd': day,
    'n': number,
    's': seconds,
    'c': cleared,
  };

  factory PlayLog.fromJson(Map<String, dynamic> j) => PlayLog(
    day: j['d'] as String,
    number: j['n'] as String,
    seconds: j['s'] as int?,
    cleared: j['c'] as bool? ?? false,
  );
}

/// 設定。
class Settings {
  Settings({
    this.showTimer = false,
    this.birthday,
    this.design = 'standard',
    this.hideExpression = true,
    this.shareSize = ResultImageSize.portrait,
  });

  /// タイマーを出すか。初期はオフ（焦らせない）。
  bool showTimer;

  /// 誕生日（「0516」）。図鑑で金縁にする。
  String? birthday;

  /// 硬券のデザイン。
  String design;

  /// 共有画像で式を「★★★」で隠すか。
  bool hideExpression;

  ResultImageSize shareSize;

  Map<String, Object?> toJson() => {
    'timer': showTimer,
    'bday': birthday,
    'design': design,
    'hide': hideExpression,
    'size': shareSize.name,
  };

  factory Settings.fromJson(Map<String, dynamic> j) => Settings(
    showTimer: j['timer'] as bool? ?? false,
    birthday: j['bday'] as String?,
    design: j['design'] as String? ?? 'standard',
    hideExpression: j['hide'] as bool? ?? true,
    shareSize: ResultImageSize.values.firstWhere(
      (s) => s.name == j['size'],
      orElse: () => ResultImageSize.portrait,
    ),
  );
}

/// 端末に保存する記録。サーバーには何も送らない。
///
/// 設計書は drift（SQLite）だが、初版は記録が小さい（最大 8,147 番号＋日ごとの記録）ので
/// ひそかぎと同じ shared_preferences に JSON で持つ。テーブルの形（solved / play_log）は設計書に合わせた。
class Records {
  Records(this._prefs) {
    final s = _prefs.getString(_solvedKey);
    if (s != null) {
      for (final j in jsonDecode(s) as List) {
        final r = SolvedRecord.fromJson(j as Map<String, dynamic>);
        solved[r.number] = r;
      }
    }
    final p = _prefs.getString(_playKey);
    if (p != null) {
      for (final j in jsonDecode(p) as List) {
        final r = PlayLog.fromJson(j as Map<String, dynamic>);
        plays[r.day] = r;
      }
    }
    final st = _prefs.getString(_settingsKey);
    settings = st == null
        ? Settings()
        : Settings.fromJson(jsonDecode(st) as Map<String, dynamic>);
    final n = _prefs.getString(_newKey);
    if (n != null) {
      newSolutionLog.addAll((jsonDecode(n) as List).cast<String>());
    }
    reviewAsks.addAll(
      (_prefs.getStringList(_reviewKey) ?? const []).map(DateTime.parse),
    );
  }

  static const _solvedKey = 'kipputen.solved.v1';
  static const _playKey = 'kipputen.play_log.v1';
  static const _settingsKey = 'kipputen.settings.v1';
  static const _newKey = 'kipputen.new_solutions.v1';
  static const _reviewKey = 'kipputen.review_asks.v1';

  final SharedPreferences _prefs;

  final Map<String, SolvedRecord> solved = {};
  final Map<String, PlayLog> plays = {};
  late Settings settings;

  /// 事前計算に当たらなかった正解（「番号: 式」）。正規化の取りこぼしを後で調べるため。
  final List<String> newSolutionLog = [];

  /// 評価依頼を出した時刻。
  final List<DateTime> reviewAsks = [];

  Future<void> saveSolved() => _prefs.setString(
    _solvedKey,
    jsonEncode([for (final r in solved.values) r.toJson()]),
  );

  Future<void> savePlays() => _prefs.setString(
    _playKey,
    jsonEncode([for (final r in plays.values) r.toJson()]),
  );

  Future<void> saveSettings() =>
      _prefs.setString(_settingsKey, jsonEncode(settings.toJson()));

  Future<void> saveNewSolutions() =>
      _prefs.setString(_newKey, jsonEncode(newSolutionLog));

  Future<void> saveReviewAsks() => _prefs.setStringList(_reviewKey, [
    for (final t in reviewAsks) t.toIso8601String(),
  ]);

  Iterable<Day> get clearedDays =>
      plays.values.where((p) => p.cleared).map((p) => Day.parse(p.day));
}
