import 'package:drift/drift.dart';

import '../core/day_slots.dart';
import 'db.dart';

/// 切手とシートの読み書き。画面はここを通してだけ DB に触る。
class StampRepository {
  StampRepository(this.db);

  final AppDatabase db;

  static String _monthPrefix(int year, int month) =>
      '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-';

  // ---- シート ----

  Future<SheetRow?> monthSheet(int year, int month) {
    return (db.select(db.sheets)..where(
          (s) =>
              s.kind.equals('month') &
              s.year.equals(year) &
              s.month.equals(month),
        ))
        .getSingleOrNull();
  }

  /// 月のシートが無ければ作る。
  Future<SheetRow> ensureMonthSheet(
    int year,
    int month, {
    String title = '',
  }) async {
    final found = await monthSheet(year, month);
    if (found != null) return found;
    final id = await db
        .into(db.sheets)
        .insert(
          SheetsCompanion.insert(
            kind: 'month',
            year: Value(year),
            month: Value(month),
            title: Value(title),
          ),
        );
    return (db.select(db.sheets)..where((s) => s.id.equals(id))).getSingle();
  }

  Future<void> renameSheet(int sheetId, String title) {
    return (db.update(db.sheets)..where((s) => s.id.equals(sheetId))).write(
      SheetsCompanion(title: Value(title)),
    );
  }

  Future<void> markCompleted(int sheetId, DateTime at) {
    return (db.update(db.sheets)..where((s) => s.id.equals(sheetId))).write(
      SheetsCompanion(completedAt: Value(at)),
    );
  }

  Future<void> clearCompleted(int sheetId) {
    return (db.update(db.sheets)..where((s) => s.id.equals(sheetId))).write(
      const SheetsCompanion(completedAt: Value(null)),
    );
  }

  Future<List<SheetRow>> monthSheets() {
    return (db.select(db.sheets)
          ..where((s) => s.kind.equals('month'))
          ..orderBy([
            (s) => OrderingTerm.desc(s.year),
            (s) => OrderingTerm.desc(s.month),
          ]))
        .get();
  }

  Future<List<SheetRow>> tripSheets() {
    return (db.select(db.sheets)
          ..where((s) => s.kind.equals('trip'))
          ..orderBy([(s) => OrderingTerm.desc(s.dateFrom)]))
        .get();
  }

  Future<SheetRow> createTripSheet(String title, Day from, Day to) async {
    final a = from <= to ? from : to;
    final b = from <= to ? to : from;
    final id = await db
        .into(db.sheets)
        .insert(
          SheetsCompanion.insert(
            kind: 'trip',
            title: Value(title),
            dateFrom: Value(a.iso),
            dateTo: Value(b.iso),
          ),
        );
    return (db.select(db.sheets)..where((s) => s.id.equals(id))).getSingle();
  }

  Future<void> deleteSheet(int sheetId) =>
      (db.delete(db.sheets)..where((s) => s.id.equals(sheetId))).go();

  // ---- 切手 ----

  static List<OrderingTerm Function($StampsTable)> get _order => [
    (t) => OrderingTerm.asc(t.date),
    (t) => OrderingTerm.asc(t.createdAt),
    (t) => OrderingTerm.asc(t.id),
  ];

  Future<List<StampRow>> stampsInMonth(int year, int month) {
    return (db.select(db.stamps)
          ..where((t) => t.date.like('${_monthPrefix(year, month)}%'))
          ..orderBy(_order))
        .get();
  }

  Future<List<StampRow>> stampsInRange(Day from, Day to) {
    return (db.select(db.stamps)
          ..where((t) => t.date.isBetweenValues(from.iso, to.iso))
          ..orderBy(_order))
        .get();
  }

  Future<List<StampRow>> allStamps() =>
      (db.select(db.stamps)..orderBy(_order)).get();

  Future<StampRow?> stampById(int id) =>
      (db.select(db.stamps)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// 切手がある日の集合。
  Future<Set<Day>> occupiedDays() async {
    final q = db.selectOnly(db.stamps, distinct: true)
      ..addColumns([db.stamps.date]);
    final rows = await q.get();
    return {for (final r in rows) Day.parse(r.read(db.stamps.date)!)};
  }

  /// 切手のある年月（新しい順）。
  Future<List<({int year, int month})>> monthsWithStamps() async {
    final days = await occupiedDays();
    final set = {for (final d in days) (year: d.year, month: d.month)};
    final list = set.toList()
      ..sort((a, b) => a.year != b.year ? b.year - a.year : b.month - a.month);
    return list;
  }

  Future<StampRow> addStamp({
    required Day day,
    required String imagePath,
    required String crop,
    required String shape,
    required String frameId,
    required Day postmarkDate,
    required String postmarkPlace,
    required String postmarkNote,
    required int postmarkSeed,
    String defaultSheetTitle = '',
    DateTime? now,
  }) async {
    final at = now ?? DateTime.now();
    return db.transaction(() async {
      final sheet = await ensureMonthSheet(
        day.year,
        day.month,
        title: defaultSheetTitle,
      );
      final id = await db
          .into(db.stamps)
          .insert(
            StampsCompanion.insert(
              date: day.iso,
              imagePath: imagePath,
              crop: crop,
              shape: Value(shape),
              frameId: frameId,
              postmarkDate: postmarkDate.iso,
              postmarkPlace: Value(postmarkPlace),
              postmarkNote: Value(postmarkNote),
              postmarkSeed: postmarkSeed,
              sheetId: sheet.id,
              createdAt: at,
            ),
          );
      if (postmarkPlace.trim().isNotEmpty) {
        await touchPlace(postmarkPlace.trim(), at);
      }
      return (await stampById(id))!;
    });
  }

  Future<void> updatePostmark(
    int id, {
    required Day date,
    required String place,
    required String note,
    required int seed,
    DateTime? now,
  }) async {
    await (db.update(db.stamps)..where((t) => t.id.equals(id))).write(
      StampsCompanion(
        postmarkDate: Value(date.iso),
        postmarkPlace: Value(place),
        postmarkNote: Value(note),
        postmarkSeed: Value(seed),
      ),
    );
    if (place.trim().isNotEmpty) {
      await touchPlace(place.trim(), now ?? DateTime.now());
    }
  }

  Future<void> updateFrame(int id, String frameId) =>
      (db.update(db.stamps)..where((t) => t.id.equals(id))).write(
        StampsCompanion(frameId: Value(frameId)),
      );

  Future<void> deleteStamp(int id) =>
      (db.delete(db.stamps)..where((t) => t.id.equals(id))).go();

  /// 月の中での通し番号（1から）。日付順、同じ日は作った順。
  Future<int> serialInMonth(StampRow s) async {
    final d = Day.parse(s.date);
    final list = await stampsInMonth(d.year, d.month);
    return list.indexWhere((x) => x.id == s.id) + 1;
  }

  // ---- 場所の履歴 ----

  Future<void> touchPlace(String place, DateTime at) {
    return db
        .into(db.placeHistory)
        .insertOnConflictUpdate(
          PlaceHistoryCompanion.insert(place: place, lastUsedAt: at),
        );
  }

  Future<List<String>> recentPlaces({int limit = 8}) async {
    final rows =
        await (db.select(db.placeHistory)
              ..orderBy([(p) => OrderingTerm.desc(p.lastUsedAt)])
              ..limit(limit))
            .get();
    return [for (final r in rows) r.place];
  }

  Future<List<PlaceHistoryRow>> allPlaces() => db.select(db.placeHistory).get();
  Future<List<SheetRow>> allSheets() => db.select(db.sheets).get();
}
