import 'local_date.dart';

/// だるまの育ち方と七転び八起きの決まり。UI と DB から切り離した純関数。
///
/// - 1日1回の記録（今日の一歩）で筆が1つ増える。筆の数は減らない
/// - 記録のない日が1日あると転ぶ。転んだあとの記録で起き上がり、台座の金の筋が1本増える
/// - 節目は 7・21・50・100 筆
/// - 日付はすべて端末のローカル日付（[LocalDate]）。0〜3時の記録も当日扱い（仮置き）
class Rules {
  Rules._();

  /// 節目の筆の数。
  static const int browsMilestone = 7;
  static const int beardMilestone = 21;
  static const int goldTextMilestone = 50;
  static const int goldRobeMilestone = 100;
  static const List<int> milestones = [
    browsMilestone,
    beardMilestone,
    goldTextMilestone,
    goldRobeMilestone,
  ];

  /// 転倒しているか。
  ///
  /// 最後に記録した日（まだ1度も記録がなければ開眼した日）が「昨日より前」なら転倒。
  /// 開眼した日と翌日は、記録がなくても転ばない。
  static bool isFallen({
    required LocalDate today,
    required LocalDate createdOn,
    required LocalDate? lastStepOn,
  }) {
    final anchor = lastStepOn ?? createdOn;
    return today.difference(anchor) > 1;
  }

  /// 記録の空白が何日あるか（転倒の表示用。転んだ回数ではない）。
  static int missedDays({
    required LocalDate today,
    required LocalDate createdOn,
    required LocalDate? lastStepOn,
  }) {
    final anchor = lastStepOn ?? createdOn;
    final gap = today.difference(anchor) - 1;
    return gap < 0 ? 0 : gap;
  }

  /// 今日の一歩を記録したときに起き上がるか（＝記録の前に転倒していたか）。
  static bool risesOnStep({
    required LocalDate today,
    required LocalDate createdOn,
    required LocalDate? lastStepOn,
  }) =>
      isFallen(today: today, createdOn: createdOn, lastStepOn: lastStepOn);

  /// 残り日数。本番の日の0時 − 今日の0時。0 なら今日が本番、負なら過ぎている。
  static int daysLeft(LocalDate deadline, LocalDate today) => deadline.difference(today);

  /// 開眼からの日数（開眼の日を1日目と数える）。
  static int daysSinceOpened(LocalDate createdOn, LocalDate today) =>
      today.difference(createdOn) + 1;

  /// 筆の数で到達している節目（0 ならまだ）。
  static int reachedMilestone(int brushCount) {
    var reached = 0;
    for (final m in milestones) {
      if (brushCount >= m) reached = m;
    }
    return reached;
  }

  /// 次の節目。全部越えていれば null。
  static int? nextMilestone(int brushCount) {
    for (final m in milestones) {
      if (brushCount < m) return m;
    }
    return null;
  }

  /// この筆で節目に到達したか（共有を促す日）。
  static bool isMilestone(int brushCount) => milestones.contains(brushCount);

  /// 腹の文字として使える長さ（2〜6字）。
  static bool isValidName(String name) {
    final n = name.trim().runes.length;
    return n >= 2 && n <= 6;
  }

  static const int memoMaxLength = 30;
}
