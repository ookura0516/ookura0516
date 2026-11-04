import 'package:drift/drift.dart';

part 'database.g.dart';

/// 句。text は3行を改行でつないだもの。
@DataClassName('HaikuRow')
class Haiku extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get body => text().named('text')();
  TextColumn get maegaki => text().withDefault(const Constant(''))();
  IntColumn get kigoId => integer().nullable()();

  /// 新年・春・夏・秋・冬。季語がなければ空（無季）。
  TextColumn get season => text().withDefault(const Constant(''))();

  /// 詠んだ日（時刻なし）。
  DateTimeColumn get composedOn => dateTime()();

  /// 兼題で詠んだときの季語。
  IntColumn get themeKigoId => integer().nullable()();
  TextColumn get memo => text().withDefault(const Constant(''))();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// 推敲の履歴。前の版を残す（1句につき最大20件）。
@DataClassName('HaikuRevisionRow')
class HaikuRevision extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get haikuId =>
      integer().references(Haiku, #id, onDelete: KeyAction.cascade)();
  TextColumn get body => text().named('text')();
  DateTimeColumn get savedAt => dateTime()();
}

/// 歳時記（アセットの JSON から初回に入れる）。
@DataClassName('KigoRow')
class KigoTable extends Table {
  @override
  String get tableName => 'kigo';

  IntColumn get id => integer()();
  TextColumn get word => text()();
  TextColumn get reading => text()();
  TextColumn get season => text()();
  TextColumn get category => text()();

  /// 「初冬」など。
  TextColumn get period => text().withDefault(const Constant(''))();

  /// 時期の始まりと終わり（MMDD の4桁。1107 なら11月7日）。
  IntColumn get startDay => integer()();
  IntColumn get endDay => integer()();
  TextColumn get description => text()();

  /// 別表記（JSON の配列）。
  TextColumn get aliases => text().withDefault(const Constant('[]'))();

  /// 例句（JSON の配列）。
  TextColumn get examples => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// その日の兼題（履歴とストリーク計算用）。
@DataClassName('ThemeLogRow')
class ThemeLog extends Table {
  DateTimeColumn get date => dateTime()();
  IntColumn get kigoId => integer()();

  @override
  Set<Column> get primaryKey => {date};
}

@DriftDatabase(tables: [Haiku, HaikuRevision, KigoTable, ThemeLog])
class TanzakuDatabase extends _$TanzakuDatabase {
  TanzakuDatabase(super.e);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
