/// ホーム画面ウィジェットの1日分の表示。
///
/// 中身はアプリが決める文字列だけにして、この部品はアプリ固有の言葉を持たない。
class DailyWidgetEntry {
  const DailyWidgetEntry({
    required this.title,
    required this.status,
    required this.done,
    required this.streak,
  });

  /// 大きく出す見出し（例：「第12問」）。
  final String title;

  /// 状態の短い言葉（例：「未解決」）。
  final String status;

  /// その日の用事を済ませたか。ネイティブ側で色や点滅を変えるのに使う。
  final bool done;

  /// 連続日数。
  final int streak;

  Map<String, String> toMap(String prefix) => {
    '${prefix}title': title,
    '${prefix}status': status,
    '${prefix}done': done ? '1' : '0',
    '${prefix}streak': '$streak',
  };
}

/// ウィジェットに書き出す、今日と翌日の2日分の表示。
///
/// アプリを開かないまま日付が替わっても、ネイティブ側が [switchAt] を過ぎたら
/// [tomorrow] を出せるように、翌日分を先に書いておく。
class DailyWidgetSnapshot {
  const DailyWidgetSnapshot({
    required this.today,
    required this.tomorrow,
    required this.switchAt,
  });

  final DailyWidgetEntry today;
  final DailyWidgetEntry tomorrow;

  /// [tomorrow] に切り替える瞬間。
  final DateTime switchAt;

  /// 書き出すキーの頭につける文字。ネイティブ側もこの名前で読む。
  static const keyPrefix = 'ookura_daily.';
  static const todayPrefix = '${keyPrefix}today.';
  static const tomorrowPrefix = '${keyPrefix}tomorrow.';
  static const switchAtKey = '${keyPrefix}switch_at';

  /// ネイティブ側で読みやすいように、値はすべて文字列にする
  /// （Android の SharedPreferences では数値の型がずれやすい）。
  /// [switchAtKey] は UTC のエポックミリ秒。
  Map<String, String> toMap() => {
    ...today.toMap(todayPrefix),
    ...tomorrow.toMap(tomorrowPrefix),
    switchAtKey: '${switchAt.toUtc().millisecondsSinceEpoch}',
  };

  /// [now] の時点で出すべき1日分。ネイティブ側と同じ規則で、テストにも使う。
  DailyWidgetEntry entryAt(DateTime now) =>
      now.isBefore(switchAt) ? today : tomorrow;
}
