import 'dart:async';

import 'package:drift/drift.dart';

import '../core/local_date.dart';
import '../model/models.dart';
import 'database.dart';

/// だるまと記録の読み書き。
///
/// 画面は [watchAll] で全部をまとめて受け取り、Look の計算は core の純関数に任せる。
class DarumaRepository {
  DarumaRepository(this.db);

  final AppDatabase db;

  // ------------------------------------------------------------ 読む

  Future<List<Daruma>> allDarumas() =>
      (db.select(db.darumas)..orderBy([(t) => OrderingTerm.asc(t.createdAt)])).get();

  Future<Daruma?> find(String id) =>
      (db.select(db.darumas)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Checkin>> checkinsOf(String darumaId) =>
      (db.select(db.checkins)..where((t) => t.darumaId.equals(darumaId))).get();

  Future<List<Recovery>> recoveriesOf(String darumaId) =>
      (db.select(db.recoveries)..where((t) => t.darumaId.equals(darumaId))).get();

  Future<List<Milestone>> milestonesOf(String darumaId) =>
      (db.select(db.milestones)..where((t) => t.darumaId.equals(darumaId))).get();

  Future<DarumaBundle?> bundle(String id) async {
    final d = await find(id);
    if (d == null) return null;
    return DarumaBundle(
      daruma: d,
      checkins: _sortedCheckins(await checkinsOf(id)),
      recoveries: await recoveriesOf(id),
      milestones: _sortedMilestones(await milestonesOf(id)),
    );
  }

  Future<List<DarumaBundle>> loadAll() async {
    final darumas = await allDarumas();
    final checkins = await db.select(db.checkins).get();
    final recoveries = await db.select(db.recoveries).get();
    final milestones = await db.select(db.milestones).get();
    return [
      for (final d in darumas)
        DarumaBundle(
          daruma: d,
          checkins: _sortedCheckins(checkins.where((c) => c.darumaId == d.id).toList()),
          recoveries: recoveries.where((r) => r.darumaId == d.id).toList(),
          milestones: _sortedMilestones(milestones.where((m) => m.darumaId == d.id).toList()),
        ),
    ];
  }

  /// 4つのテーブルのどれかが変わるたびに全部を読み直す。
  ///
  /// `async*` で tableUpdates を包むと購読の解除が終わらない（drift の Stream.multi と
  /// pipe の組み合わせ）ので、自前の StreamController で解除を待たずに切る。
  Stream<List<DarumaBundle>> watchAll() {
    late final StreamController<List<DarumaBundle>> controller;
    StreamSubscription<Set<TableUpdate>>? sub;
    var reloading = false;
    var dirty = false;

    Future<void> reload() async {
      if (reloading) {
        dirty = true;
        return;
      }
      reloading = true;
      try {
        do {
          dirty = false;
          final all = await loadAll();
          if (!controller.isClosed) controller.add(all);
        } while (dirty && !controller.isClosed);
      } catch (e, s) {
        if (!controller.isClosed) controller.addError(e, s);
      } finally {
        reloading = false;
      }
    }

    controller = StreamController<List<DarumaBundle>>(
      onListen: () {
        reload();
        sub = db.tableUpdates().listen((_) => reload());
      },
      onCancel: () {
        sub?.cancel();
        sub = null;
      },
    );
    return controller.stream;
  }

  static List<Checkin> _sortedCheckins(List<Checkin> list) =>
      list..sort((a, b) => a.date.compareTo(b.date));

  static List<Milestone> _sortedMilestones(List<Milestone> list) =>
      list..sort((a, b) => a.date.compareTo(b.date));

  // ------------------------------------------------------------ 書く

  Future<void> insertDaruma(Daruma d, {List<Milestone> milestones = const []}) =>
      db.transaction(() async {
        await db.into(db.darumas).insert(d.toInsertable());
        for (final m in milestones) {
          await db.into(db.milestones).insert(m.toInsertable());
        }
      });

  Future<void> updateDaruma(Daruma d) => db.update(db.darumas).replace(d.toInsertable());

  Future<void> replaceMilestones(String darumaId, List<Milestone> milestones) =>
      db.transaction(() async {
        await (db.delete(db.milestones)..where((t) => t.darumaId.equals(darumaId))).go();
        for (final m in milestones) {
          await db.into(db.milestones).insert(m.toInsertable());
        }
      });

  /// 同じ日の記録があれば置き換える。
  Future<void> upsertCheckin(Checkin c) => db.transaction(() async {
        await (db.delete(db.checkins)
              ..where((t) => t.darumaId.equals(c.darumaId) & t.date.equals(c.date.toIso())))
            .go();
        await db.into(db.checkins).insert(c.toInsertable());
      });

  Future<void> deleteCheckin({required String darumaId, required LocalDate date}) =>
      (db.delete(db.checkins)
            ..where((t) => t.darumaId.equals(darumaId) & t.date.equals(date.toIso())))
          .go();

  Future<void> insertRecovery(Recovery r) => db.into(db.recoveries).insert(r.toInsertable());

  /// 今日の一歩を記録し、転倒中なら起き上がり（Recovery）も同時に保存する。
  Future<void> recordStep({required Checkin checkin, Recovery? recovery}) =>
      db.transaction(() async {
        await upsertCheckin(checkin);
        if (recovery != null) await insertRecovery(recovery);
      });

  /// 当日の取り消し。その記録で起き上がっていたなら、起き上がりも取り消す。
  Future<void> undoStep({required String darumaId, required LocalDate date}) =>
      db.transaction(() async {
        await deleteCheckin(darumaId: darumaId, date: date);
        await (db.delete(db.recoveries)
              ..where((t) => t.darumaId.equals(darumaId) & t.roseOn.equals(date.toIso())))
            .go();
      });

  /// 読み込み（プラス）。同じ id は置き換える。
  Future<void> importBundles(Iterable<DarumaBundle> bundles) => db.transaction(() async {
        for (final b in bundles) {
          await db.into(db.darumas).insertOnConflictUpdate(b.daruma.toInsertable());
          await (db.delete(db.checkins)..where((t) => t.darumaId.equals(b.id))).go();
          await (db.delete(db.recoveries)..where((t) => t.darumaId.equals(b.id))).go();
          await (db.delete(db.milestones)..where((t) => t.darumaId.equals(b.id))).go();
          for (final c in b.checkins) {
            await db.into(db.checkins).insert(c.toInsertable());
          }
          for (final r in b.recoveries) {
            await db.into(db.recoveries).insert(r.toInsertable());
          }
          for (final m in b.milestones) {
            await db.into(db.milestones).insert(m.toInsertable());
          }
        }
      });

  Future<void> deleteDaruma(String id) =>
      (db.delete(db.darumas)..where((t) => t.id.equals(id))).go();
}

extension DarumaRepositoryMaintenance on DarumaRepository {
  /// 全部消す（読み込み前の入れ替えや、ストア素材の撮影で使う）。記録は外部キーで一緒に消える。
  Future<void> deleteAll() => db.delete(db.darumas).go();
}
