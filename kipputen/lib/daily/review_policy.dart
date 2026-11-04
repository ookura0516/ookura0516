/// 評価依頼を出してよいか。コア行動の直後にだけ呼ぶ。
///
/// - 初回起動の日（[firstUseDay] が今日）は出さない
/// - 直近365日に [maxPerYear] 回まで
class ReviewPolicy {
  const ReviewPolicy({this.maxPerYear = 3});

  final int maxPerYear;

  bool shouldAsk({
    required List<DateTime> pastAsks,
    required DateTime now,
    required bool isFirstUseDay,
  }) {
    if (isFirstUseDay) return false;
    final since = now.subtract(const Duration(days: 365));
    return pastAsks.where((t) => t.isAfter(since)).length < maxPerYear;
  }
}
