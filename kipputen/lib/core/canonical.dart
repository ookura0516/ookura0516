import 'expr.dart';
import 'fraction.dart';

/// 交換法則と結合法則で同じになる式を1つにまとめるための形（正規形）。
///
/// - 足し算・引き算の連なりは「足す項の集まり」と「引く項の集まり」にする
///   例：a − (b − c) と (a + c) − b は、どちらも 足す{a, c}・引く{b}
/// - 掛け算・割り算の連なりは「掛ける因数の集まり」と「割る因数の集まり」にする
///   例：a ÷ (b ÷ c) と a × c ÷ b は、どちらも 掛ける{a, c}・割る{b}
/// - 集まりの中は並べ替えて比べる（交換法則）
///
/// 分配法則（a×(b+c) = a×b+a×c）や、×1・+0 の省略はまとめない。
sealed class Canon {
  const Canon();

  /// 比較用の文字列。同じ正規形なら同じ文字列になる。
  String get key;

  Frac get value;
}

class CNum extends Canon {
  const CNum(this.n);
  final int n;
  @override
  String get key => '$n';
  @override
  Frac get value => Frac(n);
}

/// 足す項 [pos] と引く項 [neg]。項は CNum か CProd。
class CSum extends Canon {
  CSum(List<Canon> pos, List<Canon> neg)
    : pos = _sorted(pos),
      neg = _sorted(neg);
  final List<Canon> pos;
  final List<Canon> neg;

  @override
  late final String key =
      'S(${pos.map((c) => c.key).join(',')}|${neg.map((c) => c.key).join(',')})';

  @override
  late final Frac value = neg.fold(
    pos.fold(Frac.zero, (a, c) => a + c.value),
    (a, c) => a - c.value,
  );
}

/// 掛ける因数 [num] と割る因数 [den]。因数は CNum か CSum。
class CProd extends Canon {
  CProd(List<Canon> num, List<Canon> den)
    : num = _sorted(num),
      den = _sorted(den);
  final List<Canon> num;
  final List<Canon> den;

  @override
  late final String key =
      'P(${num.map((c) => c.key).join(',')}|${den.map((c) => c.key).join(',')})';

  @override
  late final Frac value = den.fold(
    num.fold(Frac(1), (a, c) => a * c.value),
    (a, c) => a.div(c.value)!,
  );
}

List<Canon> _sorted(List<Canon> xs) =>
    List.unmodifiable([...xs]..sort((a, b) => a.key.compareTo(b.key)));

/// 式を正規形にする。0 で割る式は渡さないこと（値の計算で失敗する）。
Canon canonicalize(Expr e) {
  switch (e) {
    case NumExpr():
      return CNum(e.value);
    case BinExpr():
      final l = canonicalize(e.left);
      final r = canonicalize(e.right);
      switch (e.op) {
        case Op.add || Op.sub:
          final (lp, ln) = _sumParts(l);
          final (rp, rn) = _sumParts(r);
          return e.op == Op.add
              ? CSum([...lp, ...rp], [...ln, ...rn])
              : CSum([...lp, ...rn], [...ln, ...rp]);
        case Op.mul || Op.div:
          final (ln, ld) = _prodParts(l);
          final (rn, rd) = _prodParts(r);
          return e.op == Op.mul
              ? CProd([...ln, ...rn], [...ld, ...rd])
              : CProd([...ln, ...rd], [...ld, ...rn]);
      }
  }
}

(List<Canon>, List<Canon>) _sumParts(Canon c) =>
    c is CSum ? (c.pos, c.neg) : ([c], const []);

(List<Canon>, List<Canon>) _prodParts(Canon c) =>
    c is CProd ? (c.num, c.den) : ([c], const []);

String canonicalKey(Expr e) => canonicalize(e).key;

/// 正規形を、人が読む式にする。大きい項・因数を先に、引く項・割る因数を後ろに並べる。
/// 例：「8 ÷ (1 − 1 ÷ 5)」「(9 + 1) × 1 × 1」
String render(Canon c) => _render(c, inProduct: false);

String _render(Canon c, {required bool inProduct}) {
  switch (c) {
    case CNum():
      return '${c.n}';
    case CSum():
      final b = StringBuffer();
      final pos = _byValueDesc(c.pos, numbersFirst: false);
      final neg = _byValueDesc(c.neg, numbersFirst: false);
      b.write(pos.map((t) => _render(t, inProduct: false)).join(' + '));
      for (final t in neg) {
        b.write(' − ${_render(t, inProduct: false)}');
      }
      return inProduct ? '($b)' : b.toString();
    case CProd():
      final b = StringBuffer();
      final num = _byValueDesc(c.num, numbersFirst: true);
      final den = _byValueDesc(c.den, numbersFirst: true);
      b.write(num.map((t) => _render(t, inProduct: true)).join(' × '));
      for (final t in den) {
        b.write(' ÷ ${_render(t, inProduct: true)}');
      }
      return b.toString();
  }
}

/// 値の大きい順。掛け算では、括弧の付く因数を後ろに回す（「2 × (5 − 1)」）。
List<Canon> _byValueDesc(List<Canon> xs, {required bool numbersFirst}) =>
    [...xs]..sort((a, b) {
      if (numbersFirst) {
        final ka = a is CNum ? 0 : 1;
        final kb = b is CNum ? 0 : 1;
        if (ka != kb) return ka - kb;
      }
      final v = b.value.compareTo(a.value);
      return v != 0 ? v : a.key.compareTo(b.key);
    });
