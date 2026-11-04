import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/core/widget_snapshot.dart';

void main() {
  group('日付からマス', () {
    test('1〜30日は順にマス、31日は欄外', () {
      expect(cellIndexForDay(1), 0);
      expect(cellIndexForDay(5), 4);
      expect(cellIndexForDay(6), 5);
      expect(cellIndexForDay(30), 29);
      expect(cellIndexForDay(31), isNull);
    });

    test('5列×6行の位置', () {
      expect(cellPosition(0), (row: 0, col: 0));
      expect(cellPosition(4), (row: 0, col: 4));
      expect(cellPosition(5), (row: 1, col: 0));
      expect(cellPosition(29), (row: 5, col: 4));
      expect(() => cellPosition(30), throwsRangeError);
    });

    test('その月に無い日のマスは null', () {
      expect(dayForCell(27, 2026, 2), 28);
      expect(dayForCell(28, 2026, 2), isNull); // 2026年2月は28日まで
      expect(dayForCell(28, 2028, 2), 29); // うるう年
      expect(dayForCell(29, 2026, 4), 30);
    });

    test('同じ日の2枚目以降と31日は欄外', () {
      final p = placeInMonth([
        (day: const Day(2026, 12, 1), order: 0),
        (day: const Day(2026, 12, 1), order: 1),
        (day: const Day(2026, 12, 2), order: 2),
        (day: const Day(2026, 12, 31), order: 3),
      ]);
      expect(p, [
        const InCell(0),
        const Margin(),
        const InCell(1),
        const Margin(),
      ]);
    });

    test('並び順のキーが小さいものがマスに入る（入力の順番によらない）', () {
      final p = placeInMonth([
        (day: const Day(2026, 12, 3), order: 5),
        (day: const Day(2026, 12, 3), order: 2),
      ]);
      expect(p, [const Margin(), const InCell(2)]);
    });
  });

  group('撮影日で振り分ける', () {
    const today = Day(2026, 11, 4);

    test('撮影日のマスへ。撮影日が無ければ代わりの日', () {
      final a = assignPhotosToDays(
        captureDates: [
          DateTime(2026, 11, 2, 23, 59),
          null,
          DateTime(2026, 10, 31, 0, 1),
        ],
        occupied: {},
        today: today,
        fallback: const Day(2026, 11, 3),
      );
      expect(a.map((x) => x.day), [
        const Day(2026, 11, 2),
        const Day(2026, 11, 3),
        const Day(2026, 10, 31),
      ]);
      expect(a.map((x) => x.fromCaptureDate), [true, false, true]);
      expect(a.any((x) => x.skipped), isFalse);
    });

    test('すでに貼ってある日・同じ日の2枚目は飛ばす（失敗にしない）', () {
      final a = assignPhotosToDays(
        captureDates: [
          DateTime(2026, 11, 1),
          DateTime(2026, 11, 2),
          DateTime(2026, 11, 2, 18),
        ],
        occupied: {const Day(2026, 11, 1)},
        today: today,
        fallback: today,
      );
      expect(a.map((x) => x.skipped), [true, false, true]);
    });

    test('1日に複数枚が使えるなら飛ばさない', () {
      final a = assignPhotosToDays(
        captureDates: [DateTime(2026, 11, 1), DateTime(2026, 11, 1)],
        occupied: {const Day(2026, 11, 1)},
        today: today,
        fallback: today,
        allowMultiple: true,
      );
      expect(a.every((x) => !x.skipped), isTrue);
    });

    test('未来の撮影日（時計のずれたカメラ）は今日に寄せる', () {
      final a = assignPhotosToDays(
        captureDates: [DateTime(2027, 1, 1)],
        occupied: {},
        today: today,
        fallback: today,
      );
      expect(a.single.day, today);
    });

    test('途切れた日があっても、あとから空欄を埋められる', () {
      final a = assignPhotosToDays(
        captureDates: [DateTime(2026, 9, 10)],
        occupied: {const Day(2026, 11, 1), const Day(2026, 11, 4)},
        today: today,
        fallback: today,
      );
      expect(a.single.day, const Day(2026, 9, 10));
      expect(a.single.skipped, isFalse);
    });
  });

  group('埋まり具合', () {
    test('分母はマスの数（その月の日数、最大30）', () {
      expect(fillCount({1, 2, 3}, 2026, 11), (filled: 3, total: 30));
      expect(fillCount({1, 31}, 2026, 12), (filled: 1, total: 30));
      expect(fillCount({}, 2026, 2), (filled: 0, total: 28));
    });

    test('31日は欄外なので、30日まで埋まれば完成', () {
      final all = {for (var d = 1; d <= 30; d++) d};
      expect(isMonthComplete(all, 2026, 12), isTrue);
      expect(isMonthComplete(all..remove(15), 2026, 12), isFalse);
      expect(
        isMonthComplete({for (var d = 1; d <= 28; d++) d}, 2026, 2),
        isTrue,
      );
    });
  });

  group('Day', () {
    test('文字列との往復と比較', () {
      expect(Day.parse('2026-03-09'), const Day(2026, 3, 9));
      expect(const Day(2026, 3, 9).iso, '2026-03-09');
      expect(const Day(2026, 3, 9).dotted, '2026.03.09');
      expect(const Day(2026, 12, 31).addDays(1), const Day(2027, 1, 1));
      expect(const Day(2026, 1, 1) < const Day(2026, 1, 2), isTrue);
    });
  });

  group('ウィジェットの内容', () {
    test('今日の空欄と埋まり具合', () {
      final s = snapshotFor(const Day(2026, 11, 4), {1, 2});
      expect(s.countLabel, '2／30');
      expect(s.todayEmpty, isTrue);
      expect(s.grid.split('\n').first, '■■□◇□');
      expect(s.grid.split('\n').length, 6);
    });

    test('2月は無い日を・で示す', () {
      final s = snapshotFor(const Day(2026, 2, 28), {28});
      expect(s.todayEmpty, isFalse);
      expect(s.grid.split('\n').last, '□□■・・');
    });
  });
}
