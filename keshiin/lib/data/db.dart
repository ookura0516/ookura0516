import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'db.g.dart';

/// 切手1枚（設計書「データモデル」）。
///
/// 日付は 'YYYY-MM-DD' の文字列で持つ。時刻やタイムゾーンで日がずれないように。
@DataClassName('StampRow')
class Stamps extends Table {
  @override
  String get tableName => 'stamp';

  IntColumn get id => integer().autoIncrement()();

  /// 貼った日。シートのマスを決める。
  TextColumn get date => text()();

  /// アプリ内にコピーした元画像（長辺2400px）。アプリの書類フォルダからの相対パス。
  TextColumn get imagePath => text()();

  /// トリミングの矩形。元画像に対する割合で「左,上,幅,高さ」。
  TextColumn get crop => text()();

  /// 'square' か 'portrait'。設計書にない列（トリミングの縦横を後から描き直すため）。
  TextColumn get shape => text().withDefault(const Constant('square'))();
  TextColumn get frameId => text()();
  TextColumn get postmarkDate => text()();
  TextColumn get postmarkPlace => text().withDefault(const Constant(''))();
  TextColumn get postmarkNote => text().withDefault(const Constant(''))();

  /// 消印の位置・角度・かすれを決める乱数のシード。
  IntColumn get postmarkSeed => integer()();
  IntColumn get sheetId => integer().references(Sheets, #id)();
  DateTimeColumn get createdAt => dateTime()();
}

/// シート。月のシート（month）と旅の小型シート（trip）。
@DataClassName('SheetRow')
class Sheets extends Table {
  @override
  String get tableName => 'sheet';

  IntColumn get id => integer().autoIncrement()();

  /// 'month' か 'trip'
  TextColumn get kind => text()();
  IntColumn get year => integer().nullable()();
  IntColumn get month => integer().nullable()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get dateFrom => text().nullable()();
  TextColumn get dateTo => text().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
}

/// 消印の場所の候補。
@DataClassName('PlaceHistoryRow')
class PlaceHistory extends Table {
  @override
  String get tableName => 'place_history';

  TextColumn get place => text()();
  DateTimeColumn get lastUsedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {place};
}

@DriftDatabase(tables: [Stamps, Sheets, PlaceHistory])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  /// 端末の書類フォルダに keshiin.sqlite を作る。
  factory AppDatabase.open() => AppDatabase(driftDatabase(name: 'keshiin'));

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
