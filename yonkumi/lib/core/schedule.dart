import 'package:ookura_daily/ookura_daily.dart';

/// 第1問の日（日本時間）。リリース日に合わせて、出す前にここを変える。
/// 変えたら `dart run tool/yonkumi.dart build` で問題データを作り直す
/// （暗号の鍵が日付から決まるため）。
const CivilDate kFirstDay = CivilDate(2026, 11, 1);

/// ヨンクミの日替わり。日本時間の0時に次の番号へ進む。
const DailyClock kClock = DailyClock(firstDay: kFirstDay);

/// 「第N日」にどの問題を出すか。
///
/// 収録した問題があるうちは第N日に第N問。尽きたら、それまでの問題から
/// 日付で決まる1問を出す（全員が同じ日に同じ問題になる）。
class PuzzleSchedule {
  const PuzzleSchedule({required this.count});

  /// 収録した問題の数。
  final int count;

  /// 第 [day] 日に出す問題の番号。0 以下の日や、問題が1つもなければ null。
  int? puzzleFor(int day) {
    if (day < 1 || count < 1) return null;
    if (day <= count) return day;
    // 前の日と同じ問題が続かないように、尽きた日から順に決める。
    var prev = count;
    var result = prev;
    for (var d = count + 1; d <= day; d++) {
      result = _pick(d);
      if (count > 1 && result == prev) result = result % count + 1;
      prev = result;
    }
    return result;
  }

  /// 第 [day] 日が再出題か。
  bool isRerun(int day) => day > count;

  int _pick(int day) {
    var h = day * 0x9E3779B1;
    h = (h ^ (h >> 15)) & 0x7FFFFFFF;
    h = (h * 0x2C1B3C6D) & 0x7FFFFFFF;
    h ^= h >> 12;
    return h % count + 1;
  }
}
