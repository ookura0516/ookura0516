import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/data/database.dart';
import 'package:nanakorobi/data/repository.dart';
import 'package:nanakorobi/model/models.dart';

Daruma daruma(String id, {DarumaStatus status = DarumaStatus.active, int sizeRank = 1}) => Daruma(
      id: id,
      name: '合格',
      colorId: 0,
      eyeSide: EyeSide.left,
      createdAt: DateTime(2027, 1, 1, 9),
      openedOn: const LocalDate(2027, 1, 1),
      deadline: const LocalDate(2027, 1, 16),
      deadlineName: '共通テスト',
      dailyAction: '英単語20個',
      status: status,
      sizeRank: sizeRank,
      seed: 7,
    );

Checkin checkin(String darumaId, int day, {CheckinKind kind = CheckinKind.step, String? memo}) =>
    Checkin(
      id: '$darumaId-$day',
      darumaId: darumaId,
      date: LocalDate(2027, 1, day),
      kind: kind,
      memo: memo,
      createdAt: DateTime(2027, 1, day, 20, 30),
    );

void main() {
  late AppDatabase db;
  late DarumaRepository repo;

  setUp(() {
    db = AppDatabase.memory();
    repo = DarumaRepository(db);
  });

  tearDown(() => db.close());

  test('だるまと通過点を保存して読める。日付は文字列で往復する', () async {
    await repo.insertDaruma(
      daruma('a'),
      milestones: const [
        Milestone(id: 'm1', darumaId: 'a', name: '模試', date: LocalDate(2027, 1, 10)),
        Milestone(id: 'm2', darumaId: 'a', name: '出願', date: LocalDate(2027, 1, 5)),
      ],
    );
    final b = (await repo.bundle('a'))!;
    expect(b.daruma, daruma('a'));
    expect(b.milestones.map((m) => m.name), ['出願', '模試']);
    expect(b.daruma.deadline, const LocalDate(2027, 1, 16));
    expect(b.daruma.createdAt, DateTime(2027, 1, 1, 9));
  });

  test('記録は1日1件。同じ日は置き換え、当日の取り消しで起き上がりも消える', () async {
    await repo.insertDaruma(daruma('a'));
    await repo.recordStep(checkin: checkin('a', 2));
    await repo.recordStep(checkin: checkin('a', 2, memo: 'あとから'));
    var b = (await repo.bundle('a'))!;
    expect(b.checkins.length, 1);
    expect(b.checkins.single.memo, 'あとから');

    await repo.recordStep(
      checkin: checkin('a', 5),
      recovery: const Recovery(id: 'r1', darumaId: 'a', fellAfter: LocalDate(2027, 1, 2), roseOn: LocalDate(2027, 1, 5)),
    );
    b = (await repo.bundle('a'))!;
    expect(b.recoveries.length, 1);

    await repo.undoStep(darumaId: 'a', date: const LocalDate(2027, 1, 5));
    b = (await repo.bundle('a'))!;
    expect(b.checkins.map((c) => c.date.day), [2]);
    expect(b.recoveries, isEmpty);
  });

  test('watchAll はどのテーブルの変更でも流れる', () async {
    await repo.insertDaruma(daruma('a'));
    final events = <int>[];
    final sub = repo.watchAll().listen((bundles) => events.add(bundles.single.checkins.length));
    await Future<void>.delayed(const Duration(milliseconds: 20));
    await repo.upsertCheckin(checkin('a', 3, kind: CheckinKind.rest));
    await Future<void>.delayed(const Duration(milliseconds: 50));
    await sub.cancel();
    expect(events.first, 0);
    expect(events.last, 1);
  });

  test('だるまを消すと記録も消える。読み込みは同じ id を置き換える', () async {
    await repo.insertDaruma(daruma('a'));
    await repo.upsertCheckin(checkin('a', 2));
    await repo.deleteDaruma('a');
    expect(await repo.loadAll(), isEmpty);
    expect(await db.select(db.checkins).get(), isEmpty);

    await repo.insertDaruma(daruma('b'));
    await repo.upsertCheckin(checkin('b', 2));
    await repo.importBundles([
      DarumaBundle(
        daruma: daruma('b', status: DarumaStatus.completed, sizeRank: 2),
        checkins: [checkin('b', 3), checkin('b', 4)],
      ),
      DarumaBundle(daruma: daruma('c')),
    ]);
    final all = await repo.loadAll();
    expect(all.length, 2);
    final b = all.firstWhere((x) => x.id == 'b');
    expect(b.daruma.status, DarumaStatus.completed);
    expect(b.daruma.sizeRank, 2);
    expect(b.checkins.map((c) => c.date.day), [3, 4]);
  });

  test('updateDaruma で状態を変えられる', () async {
    await repo.insertDaruma(daruma('a'));
    final d = (await repo.find('a'))!;
    await repo.updateDaruma(d.copyWith(status: DarumaStatus.retired, retiredAt: DateTime(2027, 2, 1)));
    expect((await repo.find('a'))!.status, DarumaStatus.retired);
    expect((await repo.find('a'))!.retiredOn, const LocalDate(2027, 2, 1));
  });
}
