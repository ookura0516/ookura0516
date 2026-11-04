/// 評価依頼を出すかどうか（設計書：短冊を保存した直後。10句目・30句目・100句目。
/// 初回は出さない。365日に3回まで）。
const reviewMilestones = {10, 30, 100};

bool shouldAskForReview({
  required int haikuCount,
  required List<DateTime> askedAt,
  required Set<int> askedMilestones,
  required DateTime now,
}) {
  if (!reviewMilestones.contains(haikuCount)) return false;
  if (askedMilestones.contains(haikuCount)) return false;
  final yearAgo = now.subtract(const Duration(days: 365));
  final recent = askedAt.where((t) => t.isAfter(yearAgo)).length;
  return recent < 3;
}
