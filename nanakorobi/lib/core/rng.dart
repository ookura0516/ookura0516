/// 決定的な32ビット乱数（xorshift32）。
///
/// 眉とひげの揺らぎに使う。だるまの seed から同じ列が出るので、同じだるまは
/// いつも同じ顔になる。Dart 標準の `Random(seed)` は SDK のバージョンで結果が
/// 変わらない保証がないので使わない（ひそかぎと同じ方針）。
class DeterministicRng {
  DeterministicRng(int seed) : _s = _nonZero(seed & 0xFFFFFFFF);

  int _s;

  static int _nonZero(int s) => s == 0 ? 0x9E3779B9 : s;

  int nextInt32() {
    var x = _s;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    _s = x;
    return x;
  }

  /// [0, 1)
  double nextDouble() => nextInt32() / 4294967296.0;

  /// [min, max)
  double nextRange(double min, double max) => min + (max - min) * nextDouble();

  /// [0, max)
  int nextInt(int max) => (nextDouble() * max).floor();

  /// -amount〜+amount の揺らぎ。
  double jitter(double amount) => nextRange(-amount, amount);
}
