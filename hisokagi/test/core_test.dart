import 'package:flutter_test/flutter_test.dart';
import 'package:hisokagi/core/kana.dart';
import 'package:hisokagi/core/passphrase.dart';
import 'package:hisokagi/core/rng.dart';
import 'package:hisokagi/core/room_code.dart';

void main() {
  group('Rng', () {
    test('同じシードなら同じ列になる', () {
      final a = Rng(42);
      final b = Rng(42);
      expect(
        List.generate(20, (_) => a.nextU32()),
        List.generate(20, (_) => b.nextU32()),
      );
    });

    test('値が変わらない（変わると既存の部屋の謎が変わる）', () {
      // mulberry32(1) の最初の3つ。参照実装と同じ値。
      final r = Rng(1);
      expect([r.nextU32(), r.nextU32(), r.nextU32()],
          [2693262067, 11749833, 2265367787]);
      expect(Rng.mix(['obs', 'door', 7]), Rng.mix(['obs', 'door', 7]));
      expect(Rng.mix(['obs', 'door', 7]), isNot(Rng.mix(['obs', 'door', 8])));
    });

    test('shuffled は元のリストを変えず、要素を保つ', () {
      final src = List.generate(10, (i) => i);
      final out = Rng(3).shuffled(src);
      expect(src, List.generate(10, (i) => i));
      expect(out.toSet(), src.toSet());
    });
  });

  group('RoomCode', () {
    const known = {1};

    test('全シードで作成と読み取りが往復する', () {
      for (var seed = 0; seed <= 999; seed++) {
        final code = RoomCode(scenario: 1, players: 2, seed: seed);
        final (parsed, error) = RoomCode.parse(code.text, knownScenarios: known);
        expect(error, isNull, reason: code.text);
        expect(parsed, code);
      }
    });

    test('1桁の打ち間違いは必ず弾く', () {
      for (final seed in [0, 123, 999]) {
        final text = RoomCode(scenario: 1, players: 2, seed: seed).text;
        for (var i = 0; i < 6; i++) {
          for (var d = 0; d <= 9; d++) {
            final typo = text.replaceRange(i, i + 1, '$d');
            if (typo == text) continue;
            final (parsed, _) = RoomCode.parse(typo, knownScenarios: known);
            expect(parsed, isNull, reason: '$text → $typo');
          }
        }
      }
    });

    test('全角や空白まじりでも読める', () {
      final code = RoomCode(scenario: 1, players: 2, seed: 58);
      final spaced = '${code.text.substring(0, 3)} ${code.text.substring(3)}'
          .replaceAllMapped(RegExp(r'\d'),
              (m) => String.fromCharCode(m[0]!.codeUnitAt(0) + 0xFEE0));
      final (parsed, _) = RoomCode.parse(spaced, knownScenarios: known);
      expect(parsed, code);
    });

    test('読めない理由を返す', () {
      expect(RoomCode.parse('12345', knownScenarios: known).$2,
          RoomCodeError.length);
      final unknown = RoomCode(scenario: 5, players: 2, seed: 1).text;
      expect(RoomCode.parse(unknown, knownScenarios: known).$2,
          RoomCodeError.scenario);
    });
  });

  test('normalizeInput はゆれを吸収する', () {
    expect(normalizeInput(' ホシ ゾラ '), 'ほしぞら');
    expect(normalizeInput('１２３　４'), '1234');
    expect(normalizeInput('ABC'), 'abc');
  });

  group('合言葉', () {
    test('同じ部屋・同じステージなら同じ', () {
      final a = passphraseFor(scenario: 1, seed: 10, stage: 2);
      final b = passphraseFor(scenario: 1, seed: 10, stage: 2);
      expect(a, b);
      expect(passphraseWords, contains(a));
    });

    test('カタカナで入れても通る', () {
      expect(matchesPassphrase('サクラ', 'さくら'), isTrue);
      expect(matchesPassphrase('さくら ', 'さくら'), isTrue);
      expect(matchesPassphrase('みかん', 'さくら'), isFalse);
    });

    test('言葉はすべて3文字で重複がない', () {
      expect(passphraseWords.toSet().length, passphraseWords.length);
      for (final w in passphraseWords) {
        expect(w.length, 3, reason: w);
        expect(normalizeInput(w), w, reason: w);
      }
    });
  });
}
