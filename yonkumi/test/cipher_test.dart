import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:ookura_daily/ookura_daily.dart';
import 'package:yonkumi/core/puzzle.dart';
import 'package:yonkumi/core/puzzle_bundle.dart';
import 'package:yonkumi/core/puzzle_cipher.dart';
import 'package:yonkumi/core/schedule.dart';
import 'package:yonkumi/core/tutorial.dart';

void main() {
  const day = CivilDate(2026, 11, 4);

  group('簡易暗号', () {
    test('同じ日付なら元に戻る', () {
      const plain = '{"words":["橋","箸"]} 日本語もそのまま';
      final c = PuzzleCipher.encrypt(plain, day);
      expect(c, isNot(contains('橋')));
      expect(PuzzleCipher.decrypt(c, day), plain);
    });

    test('日付が違えば開けない', () {
      final c = PuzzleCipher.encrypt('秘密の問題', day);
      expect(
        () => PuzzleCipher.decrypt(c, day.addDays(1)),
        throwsFormatException,
      );
    });

    test('日付ごとに暗号文が変わる', () {
      expect(
        PuzzleCipher.encrypt('同じ文', day),
        isNot(PuzzleCipher.encrypt('同じ文', day.addDays(1))),
      );
    });

    test('壊れたデータは FormatException', () {
      expect(() => PuzzleCipher.decrypt('%%%', day), throwsFormatException);
    });
  });

  group('PuzzleBundle', () {
    const clock = DailyClock(firstDay: CivilDate(2026, 11, 1));
    final puzzles = [
      for (var n = 1; n <= 3; n++)
        Puzzle.fromJson({...kTutorialPuzzle.toJson(), 'number': n}),
    ];

    test('書き出して読み直せる', () {
      final b = PuzzleBundle.parse(PuzzleBundle.encode(puzzles, clock), clock);
      expect(b.count, 3);
      expect(b.open(2, today: 3).number, 2);
      expect(b.open(2, today: 3).words, kTutorialPuzzle.words);
    });

    test('公開前の問題は開かない', () {
      final b = PuzzleBundle.parse(PuzzleBundle.encode(puzzles, clock), clock);
      expect(() => b.open(3, today: 2), throwsStateError);
    });

    test('第1日がアプリと違うデータは読まない', () {
      const other = DailyClock(firstDay: CivilDate(2026, 12, 1));
      expect(
        () => PuzzleBundle.parse(PuzzleBundle.encode(puzzles, other), clock),
        throwsFormatException,
      );
    });

    test('収録したアセットは全問開けて、元の問題と同じ', () {
      final b = PuzzleBundle.parse(
        File('assets/puzzles.json').readAsStringSync(),
        kClock,
      );
      final source =
          jsonDecode(File('tool/puzzles/puzzles.json').readAsStringSync())
              as List;
      expect(b.count, source.length);
      expect(b.count, greaterThanOrEqualTo(60));
      for (var n = 1; n <= b.count; n++) {
        final p = b.open(n, today: b.count);
        final src = Puzzle.fromJson(source[n - 1] as Map<String, dynamic>);
        expect(p.number, n);
        expect(p.words, src.words, reason: '第$n問をビルドし直していない？');
      }
    });

    test('アセットに答えの語がそのまま入っていない', () {
      final raw = File('assets/puzzles.json').readAsStringSync();
      expect(raw, isNot(contains('金魚')));
      expect(raw, isNot(contains('groups')));
    });
  });
}
