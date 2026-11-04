import 'dart:convert';

import 'canonical.dart';
import 'expr.dart';
import 'solver.dart';

/// 事前計算した全解（assets/solutions.json）を引く。
class SolutionBook {
  SolutionBook._(this._combos);

  /// [tool/generate_solutions.dart] の出力を読む。
  /// 正規形のキーは JSON に入れず、ここで式を読み直して作る（評価と同じ処理で作るので食い違わない）。
  factory SolutionBook.fromJson(String json) {
    final root = jsonDecode(json) as Map<String, dynamic>;
    final combos = <String, ComboSolutions>{};
    (root['combos'] as Map<String, dynamic>).forEach((k, v) {
      final m = v as Map<String, dynamic>;
      final sols = [
        for (final s in m['s'] as List)
          Solution(
            key: canonicalKey(parse(tokenize(s[0] as String))),
            display: s[0] as String,
            needsFraction: s[1] == 1,
          ),
      ];
      combos[k] = ComboSolutions(
        k.split('').map(int.parse).toList(),
        List.unmodifiable(sols),
      );
    });
    return SolutionBook._(combos);
  }

  static const assetPath = 'assets/solutions.json';

  final Map<String, ComboSolutions> _combos;

  /// 番号（「5839」）の全解。解がなければ空。
  List<Solution> solutionsFor(String number) =>
      _combos[comboKeyOf(number)]?.solutions ?? const [];

  bool isSolvable(String number) => _combos.containsKey(comboKeyOf(number));

  bool needsFraction(String number) =>
      _combos[comboKeyOf(number)]?.needsFraction ?? false;

  int get solvableComboCount => _combos.length;

  int get totalSolutionCount =>
      _combos.values.fold(0, (a, c) => a + c.solutions.length);

  List<String> get fractionOnlyCombos => [
    for (final e in _combos.entries)
      if (e.value.needsFraction) e.key,
  ];

  /// 解のある番号（0000〜9999）を小さい順に。
  late final List<String> solvableNumbers = [
    for (var i = 0; i < 10000; i++)
      if (isSolvable(formatNumber(i))) formatNumber(i),
  ];

  int get solvableNumberCount => solvableNumbers.length;

  /// 正解した式が、事前計算のどの解に当たるか。当たらなければ -1。
  int matchIndex(String number, Expr e) {
    final key = canonicalKey(e);
    final sols = solutionsFor(number);
    for (var i = 0; i < sols.length; i++) {
      if (sols[i].key == key) return i;
    }
    return -1;
  }
}

/// 0〜9999 を4桁の文字列に。
String formatNumber(int n) => n.toString().padLeft(4, '0');
