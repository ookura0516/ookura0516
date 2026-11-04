import 'kigo.dart';
import 'season.dart';

/// 日替わり兼題を選ぶ。
///
/// 同じ日には全員が同じ季語になるよう、日付と歳時記だけで決める（端末ごとの履歴は使わない）。
/// 1. 「今の季節」（二十四節気）の季語のうち、時期がその日を含むものを候補にする
/// 2. 候補の中に、その日だけの季語（時期が3日以内：元日、大晦日など）があればそれを優先する
/// 3. 候補を id 順に並べ、日の通し番号を素数倍した位置の語を取る。候補が変わらなければ
///    候補の数だけの日数、同じ語は出ない
Kigo? pickDailyTheme(DateTime date, List<Kigo> all) {
  if (all.isEmpty) return null;
  final day = DateTime.utc(date.year, date.month, date.day);
  final season = seasonOf(day);
  var pool = all.where((k) => k.season == season && k.inSeasonOn(day)).toList();
  if (pool.isEmpty) pool = all.where((k) => k.season == season).toList();
  if (pool.isEmpty) pool = List.of(all);

  final special = pool.where((k) => _spanDays(k) <= 3).toList();
  if (special.isNotEmpty) pool = special;

  pool.sort((a, b) => a.id.compareTo(b.id));
  final n = dayNumber(day);
  return pool[(n * 7919 + 13) % pool.length];
}

/// 2000年1月1日からの日数。
int dayNumber(DateTime date) => DateTime.utc(
  date.year,
  date.month,
  date.day,
).difference(DateTime.utc(2000, 1, 1)).inDays;

int _spanDays(Kigo k) {
  final s = k.start.key;
  final e = k.end.key;
  // 年をまたがない短い期間だけを数える（だいたいでよい）。
  if (s > e) return 365;
  final sd = DateTime.utc(2001, k.start.month, k.start.day);
  final ed = DateTime.utc(2001, k.end.month, k.end.day);
  return ed.difference(sd).inDays + 1;
}

/// 日本時間の今日（時刻なし）。兼題とウィジェットは日本時間の0時で切り替える。
DateTime jstToday([DateTime? now]) {
  final t = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 9));
  return DateTime(t.year, t.month, t.day);
}
