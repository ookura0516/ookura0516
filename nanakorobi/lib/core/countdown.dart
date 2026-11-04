import 'local_date.dart';

/// 残り日数と、ウィジェット用の先読みタイムライン。
///
/// 残り日数 = 本番の日の0時 − 今日の0時 を日単位で数える（当日は 0）。
class Countdown {
  const Countdown._();

  static int daysLeft(LocalDate target, LocalDate today) => target.difference(today);

  /// 今日以降の通過点を日付順に。今日は含む。
  static List<Waypoint> upcoming(Iterable<Waypoint> waypoints, LocalDate today) {
    final list = waypoints.where((w) => w.date >= today).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
    return list;
  }

  /// [from] から [days] 日分のエントリ。各日の0時に切り替える前提で、日ごとの値を前もって計算する。
  static List<TimelineEntry> timeline({
    required LocalDate from,
    int days = 14,
    LocalDate? deadline,
    Iterable<Waypoint> waypoints = const [],
  }) {
    final result = <TimelineEntry>[];
    for (var i = 0; i < days; i++) {
      final d = from.addDays(i);
      final next = upcoming(waypoints, d);
      result.add(
        TimelineEntry(
          date: d,
          daysLeft: deadline == null ? null : daysLeft(deadline, d),
          nextWaypointName: next.isEmpty ? null : next.first.name,
          nextWaypointDays: next.isEmpty ? null : daysLeft(next.first.date, d),
        ),
      );
    }
    return result;
  }
}

/// 通過点（模試、出願締切、二次など）。
class Waypoint {
  const Waypoint({required this.name, required this.date});

  final String name;
  final LocalDate date;

  @override
  bool operator ==(Object other) => other is Waypoint && other.name == name && other.date == date;

  @override
  int get hashCode => Object.hash(name, date);
}

class TimelineEntry {
  const TimelineEntry({
    required this.date,
    this.daysLeft,
    this.nextWaypointName,
    this.nextWaypointDays,
  });

  final LocalDate date;

  /// 本番がなければ null。当日は 0、過ぎると負。
  final int? daysLeft;
  final String? nextWaypointName;
  final int? nextWaypointDays;

  Map<String, Object?> toJson() => {
        'date': date.toIso(),
        'daysLeft': daysLeft,
        'nextWaypointName': nextWaypointName,
        'nextWaypointDays': nextWaypointDays,
      };

  factory TimelineEntry.fromJson(Map<String, Object?> json) => TimelineEntry(
        date: LocalDate.parse(json['date'] as String),
        daysLeft: json['daysLeft'] as int?,
        nextWaypointName: json['nextWaypointName'] as String?,
        nextWaypointDays: json['nextWaypointDays'] as int?,
      );

  @override
  bool operator ==(Object other) =>
      other is TimelineEntry &&
      other.date == date &&
      other.daysLeft == daysLeft &&
      other.nextWaypointName == nextWaypointName &&
      other.nextWaypointDays == nextWaypointDays;

  @override
  int get hashCode => Object.hash(date, daysLeft, nextWaypointName, nextWaypointDays);
}
