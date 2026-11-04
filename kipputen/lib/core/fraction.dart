/// 既約分数。式の評価はすべてこれで行い、浮動小数点は使わない。
///
/// 4つの1桁の数を四則でつなぐだけなので、分子・分母は小さい（|値| < 10^5 程度）。
class Frac implements Comparable<Frac> {
  const Frac._(this.num, this.den);

  /// [den] は 0 以外。符号は分子に寄せ、約分して持つ。
  factory Frac(int num, [int den = 1]) {
    if (den == 0) throw ArgumentError('分母が 0');
    if (den < 0) {
      num = -num;
      den = -den;
    }
    final g = _gcd(num.abs(), den);
    return Frac._(num ~/ g, den ~/ g);
  }

  static const zero = Frac._(0, 1);

  final int num;
  final int den;

  bool get isInteger => den == 1;
  bool get isZero => num == 0;

  Frac operator +(Frac o) => Frac(num * o.den + o.num * den, den * o.den);
  Frac operator -(Frac o) => Frac(num * o.den - o.num * den, den * o.den);
  Frac operator *(Frac o) => Frac(num * o.num, den * o.den);

  /// 0 で割るときは null。
  Frac? div(Frac o) => o.num == 0 ? null : Frac(num * o.den, den * o.num);

  @override
  bool operator ==(Object other) =>
      other is Frac && other.num == num && other.den == den;

  @override
  int get hashCode => Object.hash(num, den);

  @override
  int compareTo(Frac o) => (num * o.den).compareTo(o.num * den);

  /// 「7」「-3」「7/3」。
  @override
  String toString() => den == 1 ? '$num' : '$num/$den';

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a == 0 ? 1 : a;
  }
}
