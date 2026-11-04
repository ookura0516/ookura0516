import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../core/local_date.dart';
import '../model/models.dart';

part 'database.g.dart';

/// LocalDate は 'yyyy-MM-dd' の文字列で保存する（端末のローカル日付）。
class LocalDateConverter extends TypeConverter<LocalDate, String> {
  const LocalDateConverter();

  @override
  LocalDate fromSql(String fromDb) => LocalDate.parse(fromDb);

  @override
  String toSql(LocalDate value) => value.toIso();
}

@UseRowClass(Daruma, generateInsertable: true)
class Darumas extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get colorId => integer()();
  TextColumn get eyeSide => textEnum<EyeSide>()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get openedOn => text().map(const LocalDateConverter())();
  TextColumn get deadline => text().map(const LocalDateConverter()).nullable()();
  TextColumn get deadlineName => text().nullable()();
  TextColumn get deadlinePresetId => text().nullable()();
  TextColumn get dailyAction => text().nullable()();
  TextColumn get status => textEnum<DarumaStatus>()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  DateTimeColumn get retiredAt => dateTime().nullable()();
  IntColumn get sizeRank => integer().withDefault(const Constant(1))();
  TextColumn get parentId => text().nullable()();
  IntColumn get seed => integer()();
  BoolColumn get askedAtDeadline => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Milestone, generateInsertable: true)
class Milestones extends Table {
  TextColumn get id => text()();
  TextColumn get darumaId => text().references(Darumas, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get presetId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@UseRowClass(Checkin, generateInsertable: true)
class Checkins extends Table {
  TextColumn get id => text()();
  TextColumn get darumaId => text().references(Darumas, #id, onDelete: KeyAction.cascade)();
  TextColumn get date => text().map(const LocalDateConverter())();
  TextColumn get kind => textEnum<CheckinKind>()();
  TextColumn get memo => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
        {darumaId, date},
      ];
}

@UseRowClass(Recovery, generateInsertable: true)
class Recoveries extends Table {
  TextColumn get id => text()();
  TextColumn get darumaId => text().references(Darumas, #id, onDelete: KeyAction.cascade)();
  TextColumn get fellAfter => text().map(const LocalDateConverter())();
  TextColumn get roseOn => text().map(const LocalDateConverter())();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Darumas, Milestones, Checkins, Recoveries])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 端末のファイルに保存する（drift_flutter）。
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'nanakorobi'));

  /// テスト用。
  factory AppDatabase.memory() => AppDatabase(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}
