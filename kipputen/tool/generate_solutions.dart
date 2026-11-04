// 全解の事前計算。数字の組み合わせ715通りについて、10になる式を全部探し、
// 交換法則・結合法則で同じになるものをまとめて assets/solutions.json に書き出す。
//
//   dart run tool/generate_solutions.dart
//
// 実行時の探索はしない。アプリはこの JSON を読むだけ。
// test/solutions_asset_test.dart が、この JSON と計算結果が一致することを確かめる。
import 'dart:io';

import 'package:kipputen/core/solution_book.dart';
import 'package:kipputen/core/solutions_json.dart';
import 'package:kipputen/core/solver.dart';

void main(List<String> args) {
  final out = File(args.isNotEmpty ? args.first : 'assets/solutions.json');
  final combos = [for (final c in allCombos()) solveCombo(c)];
  final json = encodeSolutions(combos);
  out.writeAsStringSync(json);

  final book = SolutionBook.fromJson(json);
  stdout
    ..writeln('組み合わせ: ${combos.length}')
    ..writeln('解のある組み合わせ: ${book.solvableComboCount}')
    ..writeln('解のある番号（0000〜9999）: ${book.solvableNumberCount}')
    ..writeln('分数を経由しないと解けない組み合わせ: ${book.fractionOnlyCombos.join(', ')}')
    ..writeln('本質的に違う解の総数: ${book.totalSolutionCount}')
    ..writeln(
      '${out.path}: ${(out.lengthSync() / 1024).toStringAsFixed(1)} KB',
    );
}
