import 'canonical.dart';
import 'expr.dart';
import 'fraction.dart';

/// 目標の数。
const int target = 10;

/// 本質的に違う解の1つ。
class Solution {
  const Solution({
    required this.key,
    required this.display,
    required this.needsFraction,
  });

  /// 正規形の比較用文字列。
  final String key;

  /// 画面に出す式。
  final String display;

  /// この解のどの書き方でも、途中に分数が出るか。
  final bool needsFraction;
}

/// 数字の組み合わせ1つ（並び順は問わない）の全解。
class ComboSolutions {
  const ComboSolutions(this.digits, this.solutions);

  /// 小さい順。
  final List<int> digits;
  final List<Solution> solutions;

  bool get solvable => solutions.isNotEmpty;

  /// 解はあるが、どの解も途中で分数を経由する。
  bool get needsFraction =>
      solutions.isNotEmpty && solutions.every((s) => s.needsFraction);
}

/// [digits] の4つ（何個でもよい）を全部1回ずつ使い、四則と括弧で [goal] になる式を全部探す。
///
/// 二項演算の木を全部つくり、値が [goal] のものを正規形でまとめる。
/// 数字の連結・累乗・平方根・階乗・単項のマイナスは使わない。
ComboSolutions solveCombo(List<int> digits, {int goal = target}) {
  final goalFrac = Frac(goal);
  final found = <String, _Acc>{};

  void search(List<_Node> nodes) {
    if (nodes.length == 1) {
      final n = nodes.single;
      if (n.value == goalFrac) {
        final canon = canonicalize(n.expr);
        final acc = found.putIfAbsent(canon.key, () => _Acc(canon));
        // 1つでも分数を経由しない書き方があれば、その解は「整数だけで解ける」。
        if (!n.frac) acc.needsFraction = false;
      }
      return;
    }
    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        final rest = [
          for (var k = 0; k < nodes.length; k++)
            if (k != i && k != j) nodes[k],
        ];
        final a = nodes[i];
        final b = nodes[j];
        for (final (op, l, r) in [
          (Op.add, a, b),
          (Op.sub, a, b),
          (Op.sub, b, a),
          (Op.mul, a, b),
          (Op.div, a, b),
          (Op.div, b, a),
        ]) {
          final v = op.apply(l.value, r.value);
          if (v == null) continue;
          search([
            ...rest,
            _Node(
              BinExpr(op, l.expr, r.expr),
              v,
              l.frac || r.frac || !v.isInteger,
            ),
          ]);
        }
      }
    }
  }

  search([for (final d in digits) _Node(NumExpr(d), Frac(d), false)]);

  final sols =
      found.values
          .map(
            (a) => Solution(
              key: a.canon.key,
              display: render(a.canon),
              needsFraction: a.needsFraction,
            ),
          )
          .toList()
        ..sort((a, b) {
          // 整数だけで解ける解を先に、そのあと式の短い順。
          if (a.needsFraction != b.needsFraction) {
            return a.needsFraction ? 1 : -1;
          }
          final l = a.display.length.compareTo(b.display.length);
          return l != 0 ? l : a.display.compareTo(b.display);
        });
  return ComboSolutions(([...digits]..sort()), sols);
}

class _Node {
  const _Node(this.expr, this.value, this.frac);
  final Expr expr;
  final Frac value;
  final bool frac;
}

class _Acc {
  _Acc(this.canon);
  final Canon canon;
  bool needsFraction = true;
}

/// 0〜9 から重複を許して4つ選ぶ組み合わせ（715通り）を、小さい順の数字で列挙する。
Iterable<List<int>> allCombos() sync* {
  for (var a = 0; a <= 9; a++) {
    for (var b = a; b <= 9; b++) {
      for (var c = b; c <= 9; c++) {
        for (var d = c; d <= 9; d++) {
          yield [a, b, c, d];
        }
      }
    }
  }
}

/// 「5839」→「3589」（組み合わせの見出し）。
String comboKeyOf(String number) {
  final ds = number.split('')..sort();
  return ds.join();
}
