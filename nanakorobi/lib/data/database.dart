import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../model/models.dart';

part 'database.g.dart';

/// だるま（1体＝1目標）。日付は 'YYYY-MM-DD' の文字列（端末のローカル日付）。
@DataClassName('DarumaRow')
class Darumas extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 12)();
  IntColumn get color => intEnum<DarumaColor>()();
  IntColumn get eyeSide => intEnum<EyeSide>()();
  TextColumn get createdOn => text()();
  TextColumn get deadline => text().nullable()();
  TextColumn get deadlineLabel => text().nullable()();
  TextColumn get dailyAction => text().nullable()();
  IntColumn get status => intEnum<DarumaStatus>()();
  TextColumn get completedOn => text().nullable()();
  TextColumn get retiredOn => text().nullable()();
  IntColumn get sizeRank => integer().withDefault(const Constant(1))();
  IntColumn get parentId => integer().nullable()();
  IntColumn get seed => integer().withDefault(const Constant(0))();
}

/// 1日1件の記録。だるまと日付で一意。
@DataClassName('CheckinRow')
class Checkins extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get darumaId => integer().references(Darumas, #id)();
  TextColumn get date => text()();
  IntColumn get kind => intEnum<CheckinKind>()();
  TextColumn get memo => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {darumaId, date},
      ];
}

/// 起き上がり。件数＝台座の金の筋。
@DataClassName('RecoveryRow')
class Recoveries extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get darumaId => integer().references(Darumas, #id)();
  TextColumn get fellAfter => text()();
  TextColumn get roseOn => text()();
}

@DriftDatabase(tables: [Darumas, Checkins, Recoveries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.executor);

  /// 端末のアプリ領域に 'nanakorobi' という名前で開く。
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'nanakorobi'));

  @override
  int get schemaVersion => 1;
}
