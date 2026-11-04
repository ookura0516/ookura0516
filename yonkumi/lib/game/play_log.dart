import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// 1日分の遊んだ記録。結果グリッドは [guesses] から作り直すので、画像は残さない。
class PlayRecord {
  const PlayRecord({
    required this.day,
    required this.puzzle,
    required this.playedOnDay,
    required this.guesses,
    required this.cleared,
    required this.mistakes,
  });

  /// 第何日の問題か（アーカイブの番号）。
  final int day;

  /// 出した問題の番号（再出題なら [day] と違う）。
  final int puzzle;

  /// 解き終えたのが第何日だったか。[day] と同じならその日のうちに遊んだ。
  final int playedOnDay;

  final List<List<String>> guesses;
  final bool cleared;
  final int mistakes;

  /// 間違いなしでクリア。
  bool get perfect => cleared && mistakes == 0;

  /// 連続日数に数えるか。その日の問題をその日に解き終えたら、
  /// 正解でも失敗でも数える（設計書：失敗で連続を切らない）。
  bool get countsForStreak => playedOnDay == day;

  factory PlayRecord.fromJson(Map<String, dynamic> j) => PlayRecord(
    day: j['day'] as int,
    puzzle: j['puzzle'] as int,
    playedOnDay: j['playedOn'] as int,
    guesses: [
      for (final g in j['guesses'] as List) List<String>.from(g as List),
    ],
    cleared: j['cleared'] as bool,
    mistakes: j['mistakes'] as int,
  );

  Map<String, dynamic> toJson() => {
    'day': day,
    'puzzle': puzzle,
    'playedOn': playedOnDay,
    'guesses': guesses,
    'cleared': cleared,
    'mistakes': mistakes,
  };
}

/// 遊んだ記録と、解きかけの状態を端末に保存する。サーバーには送らない。
class PlayLog {
  PlayLog(this._prefs) {
    _load();
  }

  static const _recordsKey = 'yonkumi.records.v1';
  static const _progressKey = 'yonkumi.progress.v1';

  final SharedPreferences _prefs;
  final Map<int, PlayRecord> _records = {};
  final Map<int, List<List<String>>> _progress = {};

  void _load() {
    final raw = _prefs.getString(_recordsKey);
    if (raw != null) {
      try {
        for (final r in jsonDecode(raw) as List) {
          final rec = PlayRecord.fromJson(r as Map<String, dynamic>);
          _records[rec.day] = rec;
        }
      } on Object {
        // 壊れていたら読み飛ばす（起動できないよりよい）。
      }
    }
    final p = _prefs.getString(_progressKey);
    if (p != null) {
      try {
        for (final e in (jsonDecode(p) as Map<String, dynamic>).entries) {
          _progress[int.parse(e.key)] = [
            for (final g in e.value as List) List<String>.from(g as List),
          ];
        }
      } on Object {
        // 同上
      }
    }
  }

  Iterable<PlayRecord> get records => _records.values;

  PlayRecord? recordFor(int day) => _records[day];

  /// 解きかけの決定の並び。
  List<List<String>> progressFor(int day) => _progress[day] ?? const [];

  Future<void> saveProgress(int day, List<List<String>> guesses) {
    _progress[day] = guesses;
    return _saveProgress();
  }

  /// 解き終えた記録を残す。同じ日の記録がすでにあれば、最初のものを残す。
  Future<void> finish(PlayRecord record) async {
    _progress.remove(record.day);
    _records.putIfAbsent(record.day, () => record);
    await _prefs.setString(
      _recordsKey,
      jsonEncode([for (final r in _records.values) r.toJson()]),
    );
    await _saveProgress();
  }

  Future<void> _saveProgress() => _prefs.setString(
    _progressKey,
    jsonEncode({for (final e in _progress.entries) '${e.key}': e.value}),
  );
}
