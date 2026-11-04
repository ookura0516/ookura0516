import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/database.dart';
import 'package:nanakorobi/data/repository.dart';
import 'package:nanakorobi/model/models.dart';

void main() {
  final today = LocalDate(2026, 11, 13);

  for (final (name, make) in <(String, DarumaRepository Function())>[
    ('メモリ', MemoryDarumaRepository.new),
    ('Drift', () => DriftDarumaRepository(AppDatabase(NativeDatabase.memory()))),
  ]) {
    group('$name のリポジトリ', () {
      test('作って、記録して、起き上がって、満願にする', () async {
        final repo = make();
        expect(await repo.activeDetail(), isNull);

        final d = await repo.create(
          const NewDaruma(
            name: '合格',
            color: DarumaColor.red,
            eyeSide: EyeSide.left,
            deadlineLabel: '共通テスト',
          ).copyWith(deadline: LocalDate(2027, 1, 16)),
          today: today,
        );
        expect(d.id, greaterThan(0));
        expect(d.createdOn, today);
        expect(d.deadline, LocalDate(2027, 1, 16));
        expect(d.status, DarumaStatus.active);

        // 無料は現役1体まで。
        expect(
          () => repo.create(
            const NewDaruma(name: '必勝', color: DarumaColor.white, eyeSide: EyeSide.left),
            today: today,
          ),
          throwsA(isA<ActiveDarumaExists>()),
        );

        await repo.addCheckin(darumaId: d.id, date: today, memo: '英単語20個');
        await repo.addCheckin(darumaId: d.id, date: today.addDays(1));
        await repo.addCheckin(darumaId: d.id, date: today.addDays(4));
        await repo.addRecovery(darumaId: d.id, fellAfter: today.addDays(1), roseOn: today.addDays(4));

        final detail = (await repo.activeDetail())!;
        expect(detail.brushCount, 3);
        expect(detail.riseCount, 1);
        expect(detail.checkinOn(today)!.memo, '英単語20個');
        expect(detail.lastStepOn, today.addDays(4));

        // メモの書き換えと取り消し。
        final c = detail.checkinOn(today.addDays(4))!;
        await repo.updateMemo(c.id, '模試');
        expect((await repo.detail(d.id))!.checkinOn(today.addDays(4))!.memo, '模試');
        await repo.removeCheckin(c.id);
        await repo.removeRecovery(detail.recoveries.single.id);
        final after = (await repo.detail(d.id))!;
        expect(after.brushCount, 2);
        expect(after.riseCount, 0);

        // 満願にすると現役がいなくなり、棚には残る。
        await repo.updateDaruma(after.daruma.copyWith(
          status: DarumaStatus.completed,
          completedOn: today.addDays(60),
        ));
        expect(await repo.activeDetail(), isNull);
        final all = await repo.all();
        expect(all.single.status, DarumaStatus.completed);
        expect(all.single.completedOn, today.addDays(60));

        // 次のだるまを作れる。
        final next = await repo.create(
          NewDaruma(
            name: '必勝',
            color: DarumaColor.black,
            eyeSide: EyeSide.right,
            parentId: d.id,
            sizeRank: 2,
          ),
          today: today.addDays(61),
        );
        expect(next.parentId, d.id);
        expect(next.sizeRank, 2);
        expect((await repo.all()).length, 2);
      });

      test('同じ日に2件は入らない', () async {
        final repo = make();
        final d = await repo.create(
          const NewDaruma(name: '走る', color: DarumaColor.red, eyeSide: EyeSide.left),
          today: today,
        );
        await repo.addCheckin(darumaId: d.id, date: today);
        expect(() => repo.addCheckin(darumaId: d.id, date: today), throwsA(anything));
      });

      test('変化が流れてくる', () async {
        final repo = make();
        final seen = <int?>[];
        final sub = repo.watchActive().listen((d) => seen.add(d?.brushCount));
        await Future<void>.delayed(const Duration(milliseconds: 50));
        final d = await repo.create(
          const NewDaruma(name: '英語', color: DarumaColor.red, eyeSide: EyeSide.left),
          today: today,
        );
        await Future<void>.delayed(const Duration(milliseconds: 50));
        await repo.addCheckin(darumaId: d.id, date: today);
        await Future<void>.delayed(const Duration(milliseconds: 100));
        await sub.cancel();
        expect(seen.first, isNull);
        expect(seen.last, 1);
      });
    });
  }
}
