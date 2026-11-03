import 'package:flutter_test/flutter_test.dart';
import 'package:hisokagi/scenario/model.dart';
import 'package:hisokagi/scenario/observatory.dart';

void main() {
  const scenario = ObservatoryScenario();

  test('同じシードなら、2台で同じ謎と答えになる', () {
    for (var seed = 0; seed <= 999; seed += 37) {
      final x = scenario.build(seed);
      final y = scenario.build(seed);
      expect([for (final s in x) s.answer], [for (final s in y) s.answer]);
    }
  });

  test('シードが変われば答えも変わる', () {
    final answers = {
      for (var seed = 0; seed < 100; seed++)
        scenario.build(seed).map((s) => s.answer).join('|'),
    };
    expect(answers.length, greaterThan(95));
  });

  group('全シードで謎が成り立つ', () {
    for (var seed = 0; seed <= 999; seed++) {
      test('seed $seed', () {
        final stages = scenario.build(seed);
        expect(stages, hasLength(5));
        expect([for (final s in stages) s.inputRole],
            [Role.a, Role.b, Role.b, Role.a, Role.a]);

        for (final s in stages) {
          expect(s.check(s.answer), isTrue, reason: s.title);
          expect(s.views.keys.toSet(), {Role.a, Role.b});
          expect(s.hints[Role.a], hasLength(2));
          expect(s.hints[Role.b], hasLength(2));
        }

        // 1. 扉：4桁、記号は4つとも別、季節の表を取り違えると答えが変わる
        final door = stages[0];
        expect(door.answer, matches(RegExp(r'^[1-9]{4}$')));
        final symbolsShown =
            (door.views[Role.a]!.panels.first as SymbolRowPanel).symbols;
        expect(symbolsShown.toSet(), hasLength(4));
        final table = door.views[Role.b]!.panels.first as TablePanel;
        final isSummer =
            door.views[Role.a]!.panels.first.caption!.contains('夏');
        String read(int col) => symbolsShown
            .map((sym) => table.rows.firstWhere((r) => r[0] == sym)[col])
            .join();
        expect(read(isSummer ? 1 : 2), door.answer);
        expect(read(isSummer ? 2 : 1), isNot(door.answer));

        // 2. ケーブル：B の画面の色に規則を当てはめた位置
        final cable = stages[1];
        final colors =
            (cable.views[Role.b]!.panels.first as CablePanel).colors;
        expect(colors, hasLength(5));
        expect(cable.answer,
            '${ObservatoryScenario.cableToPull(colors)}');

        // 3. 時計：12時間表記、5分きざみ
        final clock = stages[2];
        final m = RegExp(r'^(\d{1,2}):(\d{2})$').firstMatch(clock.answer)!;
        final hour = int.parse(m[1]!);
        final minute = int.parse(m[2]!);
        expect(hour, inInclusiveRange(1, 12));
        expect(minute % 5, 0);
        expect(minute, lessThan(60));

        // 4. 暗号：壁の印の場所を表で読むと答えになる
        final cipher = stages[3];
        final marks =
            (cipher.views[Role.a]!.panels.first as ListPanel).items;
        final grid = cipher.views[Role.b]!.panels.first as GridPanel;
        final spelled = marks.map((mark) {
          final parts = mark.split('の');
          final row = grid.rowLabels.indexOf(parts[0]);
          final col = int.parse(parts[1]) - 1;
          return grid.cells[row][col];
        }).join();
        expect(spelled, cipher.answer);
        expect(ObservatoryScenario.words, contains(cipher.answer));
        expect(marks.toSet(), hasLength(4));

        // 5. ドーム：扉の右端・ケーブル位置・分の十の位
        expect(stages[4].answer,
            '${door.answer[3]}${cable.answer}${minute ~/ 10}');
      });
    }
  });

  test('ケーブルの規則は上から順に当てはめる', () {
    const r = CableColor.red, b = CableColor.blue, y = CableColor.yellow;
    const g = CableColor.green, w = CableColor.white;
    expect(ObservatoryScenario.cableToPull([b, b, y, g, w]), 2); // 赤なし
    expect(ObservatoryScenario.cableToPull([r, w, g, w, g]), 4); // 右端の白
    expect(ObservatoryScenario.cableToPull([b, r, g, g, g]), 5); // 左端が青
    expect(ObservatoryScenario.cableToPull([r, g, y, g, g]), 3); // 黄が1本
    expect(ObservatoryScenario.cableToPull([r, g, g, y, y]), 4); // それ以外
  });

  test('時計の答えの入力は、ゆれを吸収しない正規形で照合する', () {
    final clock = scenario.build(0)[2];
    expect(clock.check(clock.answer), isTrue);
    expect(clock.check('${clock.answer}0'), isFalse);
  });
}
