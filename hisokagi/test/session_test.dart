import 'package:flutter_test/flutter_test.dart';
import 'package:hisokagi/core/room_code.dart';
import 'package:hisokagi/game/session.dart';
import 'package:hisokagi/scenario/model.dart';

void main() {
  const code = RoomCode(scenario: 1, players: 2, seed: 417);

  test('2台モード：合言葉を受け渡しながら最後まで進める', () {
    final a = GameSession(code: code, mode: PlayMode.linked, roles: {Role.a});
    final b = GameSession(code: code, mode: PlayMode.linked, roles: {Role.b});

    for (var i = 0; i < a.stages.length; i++) {
      final stage = a.stages[i];
      final solver = stage.inputRole == Role.a ? a : b;
      final waiter = stage.inputRole == Role.a ? b : a;
      expect(solver.isInputTurn, isTrue);
      expect(waiter.isInputTurn, isFalse);
      expect(waiter.currentIndex, i);

      expect(solver.submitAnswer('x'), SubmitResult.wrong);
      expect(solver.submitAnswer(stage.answer), SubmitResult.correct);

      // 解いた端末が出す合言葉を、相棒の端末が同じ計算で照合できる
      final word = solver.passphraseOf(i);
      expect(waiter.submitPassphrase('ちがう'), SubmitResult.wrong);
      expect(waiter.currentIndex, i);
      expect(waiter.submitPassphrase(word), SubmitResult.correct);
    }

    expect(a.isCleared, isTrue);
    expect(b.isCleared, isTrue);
    expect(a.finishedAt, isNotNull);
    expect(a.mistakes + b.mistakes, 5);
  });

  test('手帳には自分で解いた答えだけが残る', () {
    final a = GameSession(code: code, mode: PlayMode.solo, roles: {Role.a, Role.b});
    for (final s in a.stages) {
      a.switchRole(s.inputRole);
      a.submitAnswer(s.answer);
    }
    final linkedA =
        GameSession(code: code, mode: PlayMode.linked, roles: {Role.a});
    final linkedB =
        GameSession(code: code, mode: PlayMode.linked, roles: {Role.b});
    for (var i = 0; i < linkedA.stages.length; i++) {
      final s = linkedA.stages[i];
      final solver = s.inputRole == Role.a ? linkedA : linkedB;
      final waiter = s.inputRole == Role.a ? linkedB : linkedA;
      solver.submitAnswer(s.answer);
      waiter.submitPassphrase(solver.passphraseOf(i));
    }
    expect([for (final e in linkedA.notebookFor(Role.a)) e.stage], [0, 3, 4]);
    expect([for (final e in linkedB.notebookFor(Role.b)) e.stage], [1, 2]);
    // 1台モードでは全部見える
    expect(a.notebookFor(Role.b), hasLength(5));
  });

  test('1台モード：どちらの役で解いても全員が進む', () {
    final s = GameSession(code: code, mode: PlayMode.solo, roles: {Role.a, Role.b});
    expect(s.activeRole, Role.a);
    s.submitAnswer(s.stages[0].answer);
    expect(s.stageIndexOf(Role.a), 1);
    expect(s.stageIndexOf(Role.b), 1);
    // ステージ2はBが入れる。Aのままだと答えを入れる番ではない
    expect(s.isInputTurn, isFalse);
    s.switchRole(Role.b);
    expect(s.isInputTurn, isTrue);
  });

  test('ヒントは答えまでの3段で止まる', () {
    final s = GameSession(code: code, mode: PlayMode.linked, roles: {Role.a});
    for (var i = 0; i < 5; i++) {
      s.revealNextHint();
    }
    expect(s.hintLevel(Role.a, 0), hintAnswerLevel);
    expect(s.hintsUsed, hintAnswerLevel);
  });

  test('保存して読み戻せる', () {
    final s = GameSession(code: code, mode: PlayMode.linked, roles: {Role.b});
    s.submitPassphrase(s.passphraseOf(0));
    s.revealNextHint(); // ステージ2（index 1）のヒント1
    s.submitAnswer('1');
    final restored = GameSession.decode(s.encode())!;
    expect(restored.code, code);
    expect(restored.mode, PlayMode.linked);
    expect(restored.roles, {Role.b});
    expect(restored.currentIndex, s.currentIndex);
    expect(restored.mistakes, s.mistakes);
    expect(restored.hintLevel(Role.b, 1), 1);
    expect(restored.startedAt, s.startedAt);
  });

  test('壊れた保存データは読まない', () {
    expect(GameSession.decode('{'), isNull);
    expect(GameSession.decode('{"v":99}'), isNull);
  });
}
