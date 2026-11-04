/// だるまの大きさの段階。
///
/// 納めたあと、同じ目標で「ひと回り大きいだるま」を作れる（年ごとに大きくしていく習わし）。
/// 1 が最初の大きさ。5 で打ち止め。
class SizeRank {
  const SizeRank._();

  static const min = 1;
  static const max = 5;

  static int clamp(int rank) => rank.clamp(min, max);

  /// 親のだるまからひと回り大きい段階。
  static int next(int parentRank) => clamp(parentRank + 1);

  /// 棚で並べたときの相対的な大きさ。1 → 1.0、5 → 1.48。
  static double relativeScale(int rank) => 1.0 + 0.12 * (clamp(rank) - 1);

  /// 最大の段階を 1.0 としたときの比率（棚で枠に収めるときに使う）。
  static double fitScale(int rank) => relativeScale(rank) / relativeScale(max);
}
