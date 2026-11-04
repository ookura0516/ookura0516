import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:tanzaku/data/database.dart';
import 'package:tanzaku/data/repository.dart';

import 'helpers.dart';

void main() {
  late TanzakuDatabase db;
  late HaikuRepository repo;
  var clock = DateTime(2026, 11, 4, 10);

  setUp(() {
    db = memoryDb();
    clock = DateTime(2026, 11, 4, 10);
    repo = HaikuRepository(db, clock: () => clock);
  });
  tearDown(() => db.close());

  test('歳時記を入れて読み戻すと同じ', () async {
    await repo.seedKigo(dictionary.entries);
    expect(await repo.kigoCount(), 150);
    final back = await repo.loadKigo();
    expect(
      [for (final k in back) k.toJson()],
      [for (final k in dictionary.entries) k.toJson()],
    );
    // 入れ直しても重ならない
    await repo.seedKigo(dictionary.entries);
    expect(await repo.kigoCount(), 150);
  });

  test('句を足して、新しい順に読む', () async {
    await repo.addHaiku(body: 'a', composedOn: DateTime(2026, 11, 1));
    await repo.addHaiku(body: 'b', composedOn: DateTime(2026, 11, 3, 23, 59));
    final all = await repo.allHaiku();
    expect(all.map((h) => h.body), ['b', 'a']);
    expect(all.first.composedOn, DateTime(2026, 11, 3));
  });

  test('推敲すると前の版が履歴に残る。最大20件', () async {
    final h = await repo.addHaiku(body: '版0', composedOn: clock);
    for (var i = 1; i <= 25; i++) {
      clock = clock.add(const Duration(minutes: 1));
      await repo.updateHaiku(h.id, body: '版$i');
    }
    final revs = await repo.revisions(h.id);
    expect(revs.length, maxRevisions);
    expect(revs.first.body, '版24');
    expect(revs.last.body, '版5');
    expect((await repo.haikuById(h.id))!.body, '版25');
  });

  test('本文が変わらなければ履歴は増えない', () async {
    final h = await repo.addHaiku(body: '同じ', composedOn: clock);
    await repo.updateHaiku(h.id, body: '同じ', memo: 'メモ');
    expect(await repo.revisions(h.id), isEmpty);
    expect((await repo.haikuById(h.id))!.memo, 'メモ');
  });

  test('お気に入りと削除', () async {
    final h = await repo.addHaiku(body: 'x', composedOn: clock);
    await repo.setFavorite(h.id, true);
    expect((await repo.haikuById(h.id))!.favorite, isTrue);
    await repo.updateHaiku(h.id, body: 'y');
    await repo.deleteHaiku(h.id);
    expect(await repo.allHaiku(), isEmpty);
    expect(await repo.revisions(h.id), isEmpty);
  });

  test('兼題の記録は1日1件', () async {
    await repo.logTheme(DateTime(2026, 11, 4, 9), 5);
    await repo.logTheme(DateTime(2026, 11, 4, 20), 6);
    final log = await repo.themeLog();
    expect(log.length, 1);
    expect(log.single.kigoId, 5);
  });

  test('JSON に書き出して、別の端末で読み込む', () async {
    final h = await repo.addHaiku(
      body: '古池や\n蛙飛びこむ\n水の音',
      maegaki: '深川にて',
      kigoId: 36,
      season: '春',
      composedOn: clock,
      themeKigoId: 36,
    );
    await repo.updateHaiku(h.id, body: '古池や\n蛙飛び込む\n水の音', memo: '推敲した');
    await repo.setFavorite(h.id, true);
    await repo.addHaiku(body: '二句目', composedOn: DateTime(2026, 10, 1));
    await repo.logTheme(clock, 36);
    final json = await repo.exportJson();
    expect((jsonDecode(json) as Map)['app'], 'tanzaku');

    final db2 = memoryDb();
    final repo2 = HaikuRepository(db2);
    expect(await repo2.importJson(json), 2);
    final all = await repo2.allHaiku();
    expect(all.map((h) => h.body), ['古池や\n蛙飛び込む\n水の音', '二句目']);
    final first = all.first;
    expect(first.maegaki, '深川にて');
    expect(first.memo, '推敲した');
    expect(first.favorite, isTrue);
    expect(first.kigoId, 36);
    expect((await repo2.revisions(first.id)).single.body, '古池や\n蛙飛びこむ\n水の音');
    expect((await repo2.themeLog()).single.kigoId, 36);

    // 同じファイルをもう一度読んでも重ならない
    expect(await repo2.importJson(json), 0);
    expect((await repo2.allHaiku()).length, 2);
    await db2.close();
  });

  test('違うファイルは読み込まない', () async {
    expect(() => repo.importJson('not json'), throwsA(isA<ImportException>()));
    expect(
      () => repo.importJson('{"app":"other"}'),
      throwsA(isA<ImportException>()),
    );
    expect(
      () => repo.importJson('{"app":"tanzaku","format":99}'),
      throwsA(isA<ImportException>()),
    );
  });
}
