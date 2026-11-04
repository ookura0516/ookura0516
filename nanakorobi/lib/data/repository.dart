import 'dart:async';
import 'dart:math';

import 'package:drift/drift.dart';

import '../core/local_date.dart';
import '../model/models.dart';
import 'database.dart';

/// 無料は現役のだるま1体まで（プラスで無制限）。
class ActiveDarumaExists implements Exception {
  const ActiveDarumaExists();
}

/// だるまと記録の保存先。Drift（端末のDB）と、テスト・Web撮影用のメモリ版がある。
abstract class DarumaRepository {
  /// 現役のだるま（無料は1体）。変化があるたびに流れる。
  Stream<DarumaDetail?> watchActive();
  Future<DarumaDetail?> activeDetail();

  Stream<DarumaDetail?> watchDetail(int id);
  Future<DarumaDetail?> detail(int id);

  /// 棚：全部のだるま（作った順）。
  Stream<List<Daruma>> watchAll();
  Future<List<Daruma>> all();

  Future<Daruma> create(NewDaruma input, {required LocalDate today});
  Future<void> updateDaruma(Daruma daruma);

  Future<Checkin> addCheckin({
    required int darumaId,
    required LocalDate date,
    CheckinKind kind = CheckinKind.step,
    String? memo,
  });
  Future<void> updateMemo(int checkinId, String? memo);
  Future<void> removeCheckin(int checkinId);

  Future<Recovery> addRecovery({
    required int darumaId,
    required LocalDate fellAfter,
    required LocalDate roseOn,
  });
  Future<void> removeRecovery(int recoveryId);
}

int newSeed([Random? random]) => (random ?? Random()).nextInt(1 << 30);

/// 最初に1回、そのあと [changes] が流れるたびに [fetch] し直して流す。
/// 購読をやめたら [changes] の購読もやめる（async* だと cancel が返らない）。
Stream<T> _refetchOn<T>(Stream<void> changes, Future<T> Function() fetch) {
  late StreamController<T> controller;
  StreamSubscription<void>? sub;
  var chain = Future<void>.value();
  void push() {
    chain = chain.then((_) async {
      if (controller.isClosed) return;
      try {
        controller.add(await fetch());
      } catch (e, st) {
        controller.addError(e, st);
      }
    });
  }

  controller = StreamController<T>(
    onListen: () {
      push();
      sub = changes.listen((_) => push());
    },
    onCancel: () async {
      await sub?.cancel();
      await controller.close();
    },
  );
  return controller.stream;
}

// ---------------------------------------------------------------- Drift

class DriftDarumaRepository implements DarumaRepository {
  DriftDarumaRepository(this.db);

  final AppDatabase db;

  Stream<void> get _changes => db.tableUpdates(TableUpdateQuery.onAllTables(db.allTables));

  @override
  Stream<DarumaDetail?> watchActive() => _refetchOn(_changes, activeDetail);

  @override
  Future<DarumaDetail?> activeDetail() async {
    final row = await (db.select(db.darumas)
          ..where((t) => t.status.equalsValue(DarumaStatus.active))
          ..orderBy([(t) => OrderingTerm.desc(t.id)])
          ..limit(1))
        .getSingleOrNull();
    if (row == null) return null;
    return _detailOf(row);
  }

  @override
  Stream<DarumaDetail?> watchDetail(int id) => _refetchOn(_changes, () => detail(id));

  @override
  Future<DarumaDetail?> detail(int id) async {
    final row = await (db.select(db.darumas)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) return null;
    return _detailOf(row);
  }

  Future<DarumaDetail> _detailOf(DarumaRow row) async {
    final checkins = await (db.select(db.checkins)
          ..where((t) => t.darumaId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
    final recoveries = await (db.select(db.recoveries)
          ..where((t) => t.darumaId.equals(row.id))
          ..orderBy([(t) => OrderingTerm.asc(t.roseOn)]))
        .get();
    return DarumaDetail(
      daruma: _toDaruma(row),
      checkins: checkins.map(_toCheckin).toList(),
      recoveries: recoveries.map(_toRecovery).toList(),
    );
  }

  @override
  Stream<List<Daruma>> watchAll() => _refetchOn(_changes, all);

  @override
  Future<List<Daruma>> all() async {
    final rows = await (db.select(db.darumas)..orderBy([(t) => OrderingTerm.asc(t.id)])).get();
    return rows.map(_toDaruma).toList();
  }

  @override
  Future<Daruma> create(NewDaruma input, {required LocalDate today}) async {
    return db.transaction(() async {
      final active = await (db.select(db.darumas)
            ..where((t) => t.status.equalsValue(DarumaStatus.active)))
          .get();
      if (active.isNotEmpty) throw const ActiveDarumaExists();
      final id = await db.into(db.darumas).insert(
            DarumasCompanion.insert(
              name: input.name.trim(),
              color: input.color,
              eyeSide: input.eyeSide,
              createdOn: today.toIso(),
              deadline: Value(input.deadline?.toIso()),
              deadlineLabel: Value(input.deadlineLabel),
              dailyAction: Value(input.dailyAction),
              status: DarumaStatus.active,
              sizeRank: Value(input.sizeRank),
              parentId: Value(input.parentId),
              seed: Value(newSeed()),
            ),
          );
      final row = await (db.select(db.darumas)..where((t) => t.id.equals(id))).getSingle();
      return _toDaruma(row);
    });
  }

  @override
  Future<void> updateDaruma(Daruma d) async {
    await (db.update(db.darumas)..where((t) => t.id.equals(d.id))).write(
      DarumasCompanion(
        name: Value(d.name),
        color: Value(d.color),
        eyeSide: Value(d.eyeSide),
        createdOn: Value(d.createdOn.toIso()),
        deadline: Value(d.deadline?.toIso()),
        deadlineLabel: Value(d.deadlineLabel),
        dailyAction: Value(d.dailyAction),
        status: Value(d.status),
        completedOn: Value(d.completedOn?.toIso()),
        retiredOn: Value(d.retiredOn?.toIso()),
        sizeRank: Value(d.sizeRank),
        parentId: Value(d.parentId),
        seed: Value(d.seed),
      ),
    );
  }

  @override
  Future<Checkin> addCheckin({
    required int darumaId,
    required LocalDate date,
    CheckinKind kind = CheckinKind.step,
    String? memo,
  }) async {
    final id = await db.into(db.checkins).insert(
          CheckinsCompanion.insert(
            darumaId: darumaId,
            date: date.toIso(),
            kind: kind,
            memo: Value(memo),
          ),
        );
    return Checkin(id: id, darumaId: darumaId, date: date, kind: kind, memo: memo);
  }

  @override
  Future<void> updateMemo(int checkinId, String? memo) async {
    await (db.update(db.checkins)..where((t) => t.id.equals(checkinId)))
        .write(CheckinsCompanion(memo: Value(memo)));
  }

  @override
  Future<void> removeCheckin(int checkinId) async {
    await (db.delete(db.checkins)..where((t) => t.id.equals(checkinId))).go();
  }

  @override
  Future<Recovery> addRecovery({
    required int darumaId,
    required LocalDate fellAfter,
    required LocalDate roseOn,
  }) async {
    final id = await db.into(db.recoveries).insert(
          RecoveriesCompanion.insert(
            darumaId: darumaId,
            fellAfter: fellAfter.toIso(),
            roseOn: roseOn.toIso(),
          ),
        );
    return Recovery(id: id, darumaId: darumaId, fellAfter: fellAfter, roseOn: roseOn);
  }

  @override
  Future<void> removeRecovery(int recoveryId) async {
    await (db.delete(db.recoveries)..where((t) => t.id.equals(recoveryId))).go();
  }

  static Daruma _toDaruma(DarumaRow r) => Daruma(
        id: r.id,
        name: r.name,
        color: r.color,
        eyeSide: r.eyeSide,
        createdOn: LocalDate.parse(r.createdOn),
        deadline: LocalDate.tryParse(r.deadline),
        deadlineLabel: r.deadlineLabel,
        dailyAction: r.dailyAction,
        status: r.status,
        completedOn: LocalDate.tryParse(r.completedOn),
        retiredOn: LocalDate.tryParse(r.retiredOn),
        sizeRank: r.sizeRank,
        parentId: r.parentId,
        seed: r.seed,
      );

  static Checkin _toCheckin(CheckinRow r) => Checkin(
        id: r.id,
        darumaId: r.darumaId,
        date: LocalDate.parse(r.date),
        kind: r.kind,
        memo: r.memo,
      );

  static Recovery _toRecovery(RecoveryRow r) => Recovery(
        id: r.id,
        darumaId: r.darumaId,
        fellAfter: LocalDate.parse(r.fellAfter),
        roseOn: LocalDate.parse(r.roseOn),
      );
}

// ---------------------------------------------------------------- メモリ

/// テストと Web 撮影用。アプリを閉じると消える。
class MemoryDarumaRepository implements DarumaRepository {
  MemoryDarumaRepository({Random? random}) : _random = random ?? Random(1);

  final Random _random;
  final List<Daruma> _darumas = [];
  final List<Checkin> _checkins = [];
  final List<Recovery> _recoveries = [];
  final _changes = StreamController<void>.broadcast();
  int _nextId = 1;

  void _notify() => _changes.add(null);

  @override
  Stream<DarumaDetail?> watchActive() => _refetchOn(_changes.stream, activeDetail);

  @override
  Future<DarumaDetail?> activeDetail() async {
    final active = _darumas.where((d) => d.isActive).toList();
    if (active.isEmpty) return null;
    return _detailOf(active.last);
  }

  @override
  Stream<DarumaDetail?> watchDetail(int id) => _refetchOn(_changes.stream, () => detail(id));

  @override
  Future<DarumaDetail?> detail(int id) async {
    for (final d in _darumas) {
      if (d.id == id) return _detailOf(d);
    }
    return null;
  }

  DarumaDetail _detailOf(Daruma d) => DarumaDetail(
        daruma: d,
        checkins: _checkins.where((c) => c.darumaId == d.id).toList()
          ..sort((a, b) => a.date.compareTo(b.date)),
        recoveries: _recoveries.where((r) => r.darumaId == d.id).toList()
          ..sort((a, b) => a.roseOn.compareTo(b.roseOn)),
      );

  @override
  Stream<List<Daruma>> watchAll() => _refetchOn(_changes.stream, all);

  @override
  Future<List<Daruma>> all() async => List.unmodifiable(_darumas);

  @override
  Future<Daruma> create(NewDaruma input, {required LocalDate today}) async {
    if (_darumas.any((d) => d.isActive)) throw const ActiveDarumaExists();
    final d = Daruma(
      id: _nextId++,
      name: input.name.trim(),
      color: input.color,
      eyeSide: input.eyeSide,
      createdOn: today,
      deadline: input.deadline,
      deadlineLabel: input.deadlineLabel,
      dailyAction: input.dailyAction,
      sizeRank: input.sizeRank,
      parentId: input.parentId,
      seed: newSeed(_random),
    );
    _darumas.add(d);
    _notify();
    return d;
  }

  @override
  Future<void> updateDaruma(Daruma daruma) async {
    final i = _darumas.indexWhere((d) => d.id == daruma.id);
    if (i >= 0) _darumas[i] = daruma;
    _notify();
  }

  @override
  Future<Checkin> addCheckin({
    required int darumaId,
    required LocalDate date,
    CheckinKind kind = CheckinKind.step,
    String? memo,
  }) async {
    if (_checkins.any((c) => c.darumaId == darumaId && c.date == date)) {
      throw StateError('checkin exists: $darumaId $date');
    }
    final c = Checkin(id: _nextId++, darumaId: darumaId, date: date, kind: kind, memo: memo);
    _checkins.add(c);
    _notify();
    return c;
  }

  @override
  Future<void> updateMemo(int checkinId, String? memo) async {
    final i = _checkins.indexWhere((c) => c.id == checkinId);
    if (i >= 0) _checkins[i] = _checkins[i].copyWith(memo: memo);
    _notify();
  }

  @override
  Future<void> removeCheckin(int checkinId) async {
    _checkins.removeWhere((c) => c.id == checkinId);
    _notify();
  }

  @override
  Future<Recovery> addRecovery({
    required int darumaId,
    required LocalDate fellAfter,
    required LocalDate roseOn,
  }) async {
    final r = Recovery(id: _nextId++, darumaId: darumaId, fellAfter: fellAfter, roseOn: roseOn);
    _recoveries.add(r);
    _notify();
    return r;
  }

  @override
  Future<void> removeRecovery(int recoveryId) async {
    _recoveries.removeWhere((r) => r.id == recoveryId);
    _notify();
  }
}
