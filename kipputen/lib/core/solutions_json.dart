import 'dart:convert';

import 'solver.dart';

/// JSON の形：
/// {"version":1,"target":10,"combos":{"1158":{"f":1,"s":[["8 ÷ (1 − 1 ÷ 5)",1]]}, ...}}
/// - combos のキーは数字を小さい順に並べたもの。解のない組み合わせは入れない
/// - f：その組み合わせが分数経由でしか解けないか
/// - s：[式, その解が分数経由でしか書けないか] の並び
String encodeSolutions(List<ComboSolutions> combos) {
  final map = <String, Object>{};
  for (final c in combos) {
    if (!c.solvable) continue;
    map[c.digits.join()] = {
      'f': c.needsFraction ? 1 : 0,
      's': [
        for (final s in c.solutions) [s.display, s.needsFraction ? 1 : 0],
      ],
    };
  }
  // 1組み合わせ1行にして、差分を読みやすくする。
  final b = StringBuffer('{"version":1,"target":$target,"combos":{\n');
  final keys = map.keys.toList()..sort();
  for (var i = 0; i < keys.length; i++) {
    b.write('${jsonEncode(keys[i])}:${jsonEncode(map[keys[i]])}');
    b.write(i == keys.length - 1 ? '\n' : ',\n');
  }
  b.write('}}\n');
  return b.toString();
}
