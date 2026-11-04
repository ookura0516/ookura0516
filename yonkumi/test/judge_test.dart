import 'package:flutter_test/flutter_test.dart';
import 'package:yonkumi/core/tutorial.dart';
import 'package:yonkumi/game/game_session.dart';
import 'package:yonkumi/game/judge.dart';

void main() {
  const p = kTutorialPuzzle;
  final fruit = p.groups[0];
  final kami = p.groups[3];

  group('判定', () {
    test('組とぴったり同じなら正解', () {
      final j = judge(['もも', 'りんご', 'ぶどう', 'みかん'], p.groups);
      expect(j.verdict, Verdict.correct);
      expect(j.group, same(fruit));
    });

    test('3語が同じ組なら「あと1つ」', () {
      expect(
        judge(['りんご', 'みかん', 'ぶどう', '紙'], p.groups).verdict,
        Verdict.oneAway,
      );
    });

    test('2語ずつは外れ', () {
      expect(judge(['りんご', 'みかん', '紙', '髪'], p.groups).verdict, Verdict.wrong);
    });

    test('当てた組は候補から外す', () {
      final rest = p.groups.where((g) => g != fruit);
      expect(judge(fruit.words, rest).verdict, Verdict.wrong);
    });

    test('4語でなければエラー', () {
      expect(
        () => judge(['りんご', 'りんご', 'みかん', 'もも'], p.groups),
        throwsArgumentError,
      );
    });
  });

  group('GameSession', () {
    GameSession fresh() => GameSession(p, seed: 1);

    void pick(GameSession s, List<String> words) {
      s.deselectAll();
      for (final w in words) {
        s.toggle(w);
      }
    }

    test('選べるのは4語まで、もう一度押すと外れる', () {
      final s = fresh();
      for (final w in p.words.take(5)) {
        s.toggle(w);
      }
      expect(s.selected.length, 4);
      s.toggle(p.words.first);
      expect(s.selected.length, 3);
      expect(s.canSubmit, isFalse);
    });

    test('正解すると帯になり、盤から消える', () {
      final s = fresh();
      pick(s, fruit.words);
      expect(s.submit(), SubmitResult.correct);
      expect(s.solved, [fruit]);
      expect(s.board.length, 12);
      expect(s.board.any(fruit.words.contains), isFalse);
      expect(s.selected, isEmpty);
    });

    test('間違いは4回で終わり、残りの組を答えとして出す', () {
      final s = fresh();
      final wrongs = [
        ['りんご', 'みかん', 'ぶどう', '紙'],
        ['りんご', 'みかん', '紙', '髪'],
        ['りんご', '紙', '髪', '神'],
        ['もも', '紙', '髪', '神'],
      ];
      final results = <SubmitResult>[];
      for (final w in wrongs) {
        pick(s, w);
        results.add(s.submit());
      }
      expect(results.first, SubmitResult.oneAway);
      expect(results[1], SubmitResult.wrong);
      expect(results.last, SubmitResult.oneAway);
      expect(s.failed, isTrue);
      expect(s.finished, isTrue);
      expect(s.cleared, isFalse);
      expect(s.unsolved.length, 4);
      s.toggle('りんご');
      expect(s.selected, isEmpty, reason: '終わったあとは選べない');
    });

    test('同じ4語をもう一度決定しても間違いに数えない', () {
      final s = fresh();
      pick(s, ['りんご', 'みかん', '紙', '髪']);
      s.submit();
      pick(s, ['髪', '紙', 'みかん', 'りんご']);
      expect(s.submit(), SubmitResult.alreadyTried);
      expect(s.mistakes, 1);
      expect(s.guesses.length, 1);
    });

    test('全部当てればクリア、結果グリッドは決定の順', () {
      final s = fresh();
      pick(s, ['りんご', 'みかん', '紙', '髪']);
      s.submit();
      for (final g in [kami, ...p.groups.take(3)]) {
        pick(s, g.words);
        expect(s.submit(), SubmitResult.correct);
      }
      expect(s.cleared, isTrue);
      expect(s.mistakes, 1);
      // 1行目は盤の並び順なので、並べ替えて比べる。
      expect(s.gridRows.first.toList()..sort(), [1, 1, 4, 4]);
      expect(s.gridRows.skip(1), [
        [4, 4, 4, 4],
        [1, 1, 1, 1],
        [2, 2, 2, 2],
        [3, 3, 3, 3],
      ]);
    });

    test('決定の並びから同じ状態に戻せる', () {
      final s = fresh();
      pick(s, fruit.words);
      s.submit();
      pick(s, ['紙', '髪', '神', '富士山']);
      s.submit();
      final again = GameSession(p, guesses: s.guesses, seed: 9);
      expect(again.solved, s.solved);
      expect(again.mistakes, 1);
      expect(again.board.toSet(), s.board.toSet());
    });

    test('シャッフルしても語は変わらない', () {
      final s = fresh();
      final before = s.board.toSet();
      s.shuffle();
      expect(s.board.toSet(), before);
    });
  });
}
