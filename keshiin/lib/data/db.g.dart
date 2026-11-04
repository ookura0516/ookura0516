// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $SheetsTable extends Sheets with TableInfo<$SheetsTable, SheetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SheetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _monthMeta = const VerificationMeta('month');
  @override
  late final GeneratedColumn<int> month = GeneratedColumn<int>(
    'month',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _dateFromMeta = const VerificationMeta(
    'dateFrom',
  );
  @override
  late final GeneratedColumn<String> dateFrom = GeneratedColumn<String>(
    'date_from',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateToMeta = const VerificationMeta('dateTo');
  @override
  late final GeneratedColumn<String> dateTo = GeneratedColumn<String>(
    'date_to',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    kind,
    year,
    month,
    title,
    dateFrom,
    dateTo,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sheet';
  @override
  VerificationContext validateIntegrity(
    Insertable<SheetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('month')) {
      context.handle(
        _monthMeta,
        month.isAcceptableOrUnknown(data['month']!, _monthMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('date_from')) {
      context.handle(
        _dateFromMeta,
        dateFrom.isAcceptableOrUnknown(data['date_from']!, _dateFromMeta),
      );
    }
    if (data.containsKey('date_to')) {
      context.handle(
        _dateToMeta,
        dateTo.isAcceptableOrUnknown(data['date_to']!, _dateToMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SheetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SheetRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      month: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}month'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      dateFrom: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_from'],
      ),
      dateTo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date_to'],
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
    );
  }

  @override
  $SheetsTable createAlias(String alias) {
    return $SheetsTable(attachedDatabase, alias);
  }
}

class SheetRow extends DataClass implements Insertable<SheetRow> {
  final int id;

  /// 'month' か 'trip'
  final String kind;
  final int? year;
  final int? month;
  final String title;
  final String? dateFrom;
  final String? dateTo;
  final DateTime? completedAt;
  const SheetRow({
    required this.id,
    required this.kind,
    this.year,
    this.month,
    required this.title,
    this.dateFrom,
    this.dateTo,
    this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || month != null) {
      map['month'] = Variable<int>(month);
    }
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || dateFrom != null) {
      map['date_from'] = Variable<String>(dateFrom);
    }
    if (!nullToAbsent || dateTo != null) {
      map['date_to'] = Variable<String>(dateTo);
    }
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<DateTime>(completedAt);
    }
    return map;
  }

  SheetsCompanion toCompanion(bool nullToAbsent) {
    return SheetsCompanion(
      id: Value(id),
      kind: Value(kind),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      month: month == null && nullToAbsent
          ? const Value.absent()
          : Value(month),
      title: Value(title),
      dateFrom: dateFrom == null && nullToAbsent
          ? const Value.absent()
          : Value(dateFrom),
      dateTo: dateTo == null && nullToAbsent
          ? const Value.absent()
          : Value(dateTo),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
    );
  }

  factory SheetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SheetRow(
      id: serializer.fromJson<int>(json['id']),
      kind: serializer.fromJson<String>(json['kind']),
      year: serializer.fromJson<int?>(json['year']),
      month: serializer.fromJson<int?>(json['month']),
      title: serializer.fromJson<String>(json['title']),
      dateFrom: serializer.fromJson<String?>(json['dateFrom']),
      dateTo: serializer.fromJson<String?>(json['dateTo']),
      completedAt: serializer.fromJson<DateTime?>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'kind': serializer.toJson<String>(kind),
      'year': serializer.toJson<int?>(year),
      'month': serializer.toJson<int?>(month),
      'title': serializer.toJson<String>(title),
      'dateFrom': serializer.toJson<String?>(dateFrom),
      'dateTo': serializer.toJson<String?>(dateTo),
      'completedAt': serializer.toJson<DateTime?>(completedAt),
    };
  }

  SheetRow copyWith({
    int? id,
    String? kind,
    Value<int?> year = const Value.absent(),
    Value<int?> month = const Value.absent(),
    String? title,
    Value<String?> dateFrom = const Value.absent(),
    Value<String?> dateTo = const Value.absent(),
    Value<DateTime?> completedAt = const Value.absent(),
  }) => SheetRow(
    id: id ?? this.id,
    kind: kind ?? this.kind,
    year: year.present ? year.value : this.year,
    month: month.present ? month.value : this.month,
    title: title ?? this.title,
    dateFrom: dateFrom.present ? dateFrom.value : this.dateFrom,
    dateTo: dateTo.present ? dateTo.value : this.dateTo,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
  );
  SheetRow copyWithCompanion(SheetsCompanion data) {
    return SheetRow(
      id: data.id.present ? data.id.value : this.id,
      kind: data.kind.present ? data.kind.value : this.kind,
      year: data.year.present ? data.year.value : this.year,
      month: data.month.present ? data.month.value : this.month,
      title: data.title.present ? data.title.value : this.title,
      dateFrom: data.dateFrom.present ? data.dateFrom.value : this.dateFrom,
      dateTo: data.dateTo.present ? data.dateTo.value : this.dateTo,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SheetRow(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('title: $title, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, kind, year, month, title, dateFrom, dateTo, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SheetRow &&
          other.id == this.id &&
          other.kind == this.kind &&
          other.year == this.year &&
          other.month == this.month &&
          other.title == this.title &&
          other.dateFrom == this.dateFrom &&
          other.dateTo == this.dateTo &&
          other.completedAt == this.completedAt);
}

class SheetsCompanion extends UpdateCompanion<SheetRow> {
  final Value<int> id;
  final Value<String> kind;
  final Value<int?> year;
  final Value<int?> month;
  final Value<String> title;
  final Value<String?> dateFrom;
  final Value<String?> dateTo;
  final Value<DateTime?> completedAt;
  const SheetsCompanion({
    this.id = const Value.absent(),
    this.kind = const Value.absent(),
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.title = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  SheetsCompanion.insert({
    this.id = const Value.absent(),
    required String kind,
    this.year = const Value.absent(),
    this.month = const Value.absent(),
    this.title = const Value.absent(),
    this.dateFrom = const Value.absent(),
    this.dateTo = const Value.absent(),
    this.completedAt = const Value.absent(),
  }) : kind = Value(kind);
  static Insertable<SheetRow> custom({
    Expression<int>? id,
    Expression<String>? kind,
    Expression<int>? year,
    Expression<int>? month,
    Expression<String>? title,
    Expression<String>? dateFrom,
    Expression<String>? dateTo,
    Expression<DateTime>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (kind != null) 'kind': kind,
      if (year != null) 'year': year,
      if (month != null) 'month': month,
      if (title != null) 'title': title,
      if (dateFrom != null) 'date_from': dateFrom,
      if (dateTo != null) 'date_to': dateTo,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  SheetsCompanion copyWith({
    Value<int>? id,
    Value<String>? kind,
    Value<int?>? year,
    Value<int?>? month,
    Value<String>? title,
    Value<String?>? dateFrom,
    Value<String?>? dateTo,
    Value<DateTime?>? completedAt,
  }) {
    return SheetsCompanion(
      id: id ?? this.id,
      kind: kind ?? this.kind,
      year: year ?? this.year,
      month: month ?? this.month,
      title: title ?? this.title,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (month.present) {
      map['month'] = Variable<int>(month.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (dateFrom.present) {
      map['date_from'] = Variable<String>(dateFrom.value);
    }
    if (dateTo.present) {
      map['date_to'] = Variable<String>(dateTo.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SheetsCompanion(')
          ..write('id: $id, ')
          ..write('kind: $kind, ')
          ..write('year: $year, ')
          ..write('month: $month, ')
          ..write('title: $title, ')
          ..write('dateFrom: $dateFrom, ')
          ..write('dateTo: $dateTo, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

class $StampsTable extends Stamps with TableInfo<$StampsTable, StampRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StampsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cropMeta = const VerificationMeta('crop');
  @override
  late final GeneratedColumn<String> crop = GeneratedColumn<String>(
    'crop',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _shapeMeta = const VerificationMeta('shape');
  @override
  late final GeneratedColumn<String> shape = GeneratedColumn<String>(
    'shape',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('square'),
  );
  static const VerificationMeta _frameIdMeta = const VerificationMeta(
    'frameId',
  );
  @override
  late final GeneratedColumn<String> frameId = GeneratedColumn<String>(
    'frame_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postmarkDateMeta = const VerificationMeta(
    'postmarkDate',
  );
  @override
  late final GeneratedColumn<String> postmarkDate = GeneratedColumn<String>(
    'postmark_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _postmarkPlaceMeta = const VerificationMeta(
    'postmarkPlace',
  );
  @override
  late final GeneratedColumn<String> postmarkPlace = GeneratedColumn<String>(
    'postmark_place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postmarkNoteMeta = const VerificationMeta(
    'postmarkNote',
  );
  @override
  late final GeneratedColumn<String> postmarkNote = GeneratedColumn<String>(
    'postmark_note',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _postmarkSeedMeta = const VerificationMeta(
    'postmarkSeed',
  );
  @override
  late final GeneratedColumn<int> postmarkSeed = GeneratedColumn<int>(
    'postmark_seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sheetIdMeta = const VerificationMeta(
    'sheetId',
  );
  @override
  late final GeneratedColumn<int> sheetId = GeneratedColumn<int>(
    'sheet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sheet (id)',
    ),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    imagePath,
    crop,
    shape,
    frameId,
    postmarkDate,
    postmarkPlace,
    postmarkNote,
    postmarkSeed,
    sheetId,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stamp';
  @override
  VerificationContext validateIntegrity(
    Insertable<StampRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    } else if (isInserting) {
      context.missing(_imagePathMeta);
    }
    if (data.containsKey('crop')) {
      context.handle(
        _cropMeta,
        crop.isAcceptableOrUnknown(data['crop']!, _cropMeta),
      );
    } else if (isInserting) {
      context.missing(_cropMeta);
    }
    if (data.containsKey('shape')) {
      context.handle(
        _shapeMeta,
        shape.isAcceptableOrUnknown(data['shape']!, _shapeMeta),
      );
    }
    if (data.containsKey('frame_id')) {
      context.handle(
        _frameIdMeta,
        frameId.isAcceptableOrUnknown(data['frame_id']!, _frameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_frameIdMeta);
    }
    if (data.containsKey('postmark_date')) {
      context.handle(
        _postmarkDateMeta,
        postmarkDate.isAcceptableOrUnknown(
          data['postmark_date']!,
          _postmarkDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postmarkDateMeta);
    }
    if (data.containsKey('postmark_place')) {
      context.handle(
        _postmarkPlaceMeta,
        postmarkPlace.isAcceptableOrUnknown(
          data['postmark_place']!,
          _postmarkPlaceMeta,
        ),
      );
    }
    if (data.containsKey('postmark_note')) {
      context.handle(
        _postmarkNoteMeta,
        postmarkNote.isAcceptableOrUnknown(
          data['postmark_note']!,
          _postmarkNoteMeta,
        ),
      );
    }
    if (data.containsKey('postmark_seed')) {
      context.handle(
        _postmarkSeedMeta,
        postmarkSeed.isAcceptableOrUnknown(
          data['postmark_seed']!,
          _postmarkSeedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_postmarkSeedMeta);
    }
    if (data.containsKey('sheet_id')) {
      context.handle(
        _sheetIdMeta,
        sheetId.isAcceptableOrUnknown(data['sheet_id']!, _sheetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sheetIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StampRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StampRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      )!,
      crop: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}crop'],
      )!,
      shape: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shape'],
      )!,
      frameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frame_id'],
      )!,
      postmarkDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postmark_date'],
      )!,
      postmarkPlace: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postmark_place'],
      )!,
      postmarkNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}postmark_note'],
      )!,
      postmarkSeed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}postmark_seed'],
      )!,
      sheetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sheet_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $StampsTable createAlias(String alias) {
    return $StampsTable(attachedDatabase, alias);
  }
}

class StampRow extends DataClass implements Insertable<StampRow> {
  final int id;

  /// 貼った日。シートのマスを決める。
  final String date;

  /// アプリ内にコピーした元画像（長辺2400px）。アプリの書類フォルダからの相対パス。
  final String imagePath;

  /// トリミングの矩形。元画像に対する割合で「左,上,幅,高さ」。
  final String crop;

  /// 'square' か 'portrait'。設計書にない列（トリミングの縦横を後から描き直すため）。
  final String shape;
  final String frameId;
  final String postmarkDate;
  final String postmarkPlace;
  final String postmarkNote;

  /// 消印の位置・角度・かすれを決める乱数のシード。
  final int postmarkSeed;
  final int sheetId;
  final DateTime createdAt;
  const StampRow({
    required this.id,
    required this.date,
    required this.imagePath,
    required this.crop,
    required this.shape,
    required this.frameId,
    required this.postmarkDate,
    required this.postmarkPlace,
    required this.postmarkNote,
    required this.postmarkSeed,
    required this.sheetId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['image_path'] = Variable<String>(imagePath);
    map['crop'] = Variable<String>(crop);
    map['shape'] = Variable<String>(shape);
    map['frame_id'] = Variable<String>(frameId);
    map['postmark_date'] = Variable<String>(postmarkDate);
    map['postmark_place'] = Variable<String>(postmarkPlace);
    map['postmark_note'] = Variable<String>(postmarkNote);
    map['postmark_seed'] = Variable<int>(postmarkSeed);
    map['sheet_id'] = Variable<int>(sheetId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  StampsCompanion toCompanion(bool nullToAbsent) {
    return StampsCompanion(
      id: Value(id),
      date: Value(date),
      imagePath: Value(imagePath),
      crop: Value(crop),
      shape: Value(shape),
      frameId: Value(frameId),
      postmarkDate: Value(postmarkDate),
      postmarkPlace: Value(postmarkPlace),
      postmarkNote: Value(postmarkNote),
      postmarkSeed: Value(postmarkSeed),
      sheetId: Value(sheetId),
      createdAt: Value(createdAt),
    );
  }

  factory StampRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StampRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      imagePath: serializer.fromJson<String>(json['imagePath']),
      crop: serializer.fromJson<String>(json['crop']),
      shape: serializer.fromJson<String>(json['shape']),
      frameId: serializer.fromJson<String>(json['frameId']),
      postmarkDate: serializer.fromJson<String>(json['postmarkDate']),
      postmarkPlace: serializer.fromJson<String>(json['postmarkPlace']),
      postmarkNote: serializer.fromJson<String>(json['postmarkNote']),
      postmarkSeed: serializer.fromJson<int>(json['postmarkSeed']),
      sheetId: serializer.fromJson<int>(json['sheetId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'imagePath': serializer.toJson<String>(imagePath),
      'crop': serializer.toJson<String>(crop),
      'shape': serializer.toJson<String>(shape),
      'frameId': serializer.toJson<String>(frameId),
      'postmarkDate': serializer.toJson<String>(postmarkDate),
      'postmarkPlace': serializer.toJson<String>(postmarkPlace),
      'postmarkNote': serializer.toJson<String>(postmarkNote),
      'postmarkSeed': serializer.toJson<int>(postmarkSeed),
      'sheetId': serializer.toJson<int>(sheetId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  StampRow copyWith({
    int? id,
    String? date,
    String? imagePath,
    String? crop,
    String? shape,
    String? frameId,
    String? postmarkDate,
    String? postmarkPlace,
    String? postmarkNote,
    int? postmarkSeed,
    int? sheetId,
    DateTime? createdAt,
  }) => StampRow(
    id: id ?? this.id,
    date: date ?? this.date,
    imagePath: imagePath ?? this.imagePath,
    crop: crop ?? this.crop,
    shape: shape ?? this.shape,
    frameId: frameId ?? this.frameId,
    postmarkDate: postmarkDate ?? this.postmarkDate,
    postmarkPlace: postmarkPlace ?? this.postmarkPlace,
    postmarkNote: postmarkNote ?? this.postmarkNote,
    postmarkSeed: postmarkSeed ?? this.postmarkSeed,
    sheetId: sheetId ?? this.sheetId,
    createdAt: createdAt ?? this.createdAt,
  );
  StampRow copyWithCompanion(StampsCompanion data) {
    return StampRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      crop: data.crop.present ? data.crop.value : this.crop,
      shape: data.shape.present ? data.shape.value : this.shape,
      frameId: data.frameId.present ? data.frameId.value : this.frameId,
      postmarkDate: data.postmarkDate.present
          ? data.postmarkDate.value
          : this.postmarkDate,
      postmarkPlace: data.postmarkPlace.present
          ? data.postmarkPlace.value
          : this.postmarkPlace,
      postmarkNote: data.postmarkNote.present
          ? data.postmarkNote.value
          : this.postmarkNote,
      postmarkSeed: data.postmarkSeed.present
          ? data.postmarkSeed.value
          : this.postmarkSeed,
      sheetId: data.sheetId.present ? data.sheetId.value : this.sheetId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StampRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('imagePath: $imagePath, ')
          ..write('crop: $crop, ')
          ..write('shape: $shape, ')
          ..write('frameId: $frameId, ')
          ..write('postmarkDate: $postmarkDate, ')
          ..write('postmarkPlace: $postmarkPlace, ')
          ..write('postmarkNote: $postmarkNote, ')
          ..write('postmarkSeed: $postmarkSeed, ')
          ..write('sheetId: $sheetId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    imagePath,
    crop,
    shape,
    frameId,
    postmarkDate,
    postmarkPlace,
    postmarkNote,
    postmarkSeed,
    sheetId,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StampRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.imagePath == this.imagePath &&
          other.crop == this.crop &&
          other.shape == this.shape &&
          other.frameId == this.frameId &&
          other.postmarkDate == this.postmarkDate &&
          other.postmarkPlace == this.postmarkPlace &&
          other.postmarkNote == this.postmarkNote &&
          other.postmarkSeed == this.postmarkSeed &&
          other.sheetId == this.sheetId &&
          other.createdAt == this.createdAt);
}

class StampsCompanion extends UpdateCompanion<StampRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> imagePath;
  final Value<String> crop;
  final Value<String> shape;
  final Value<String> frameId;
  final Value<String> postmarkDate;
  final Value<String> postmarkPlace;
  final Value<String> postmarkNote;
  final Value<int> postmarkSeed;
  final Value<int> sheetId;
  final Value<DateTime> createdAt;
  const StampsCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.crop = const Value.absent(),
    this.shape = const Value.absent(),
    this.frameId = const Value.absent(),
    this.postmarkDate = const Value.absent(),
    this.postmarkPlace = const Value.absent(),
    this.postmarkNote = const Value.absent(),
    this.postmarkSeed = const Value.absent(),
    this.sheetId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  StampsCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String imagePath,
    required String crop,
    this.shape = const Value.absent(),
    required String frameId,
    required String postmarkDate,
    this.postmarkPlace = const Value.absent(),
    this.postmarkNote = const Value.absent(),
    required int postmarkSeed,
    required int sheetId,
    required DateTime createdAt,
  }) : date = Value(date),
       imagePath = Value(imagePath),
       crop = Value(crop),
       frameId = Value(frameId),
       postmarkDate = Value(postmarkDate),
       postmarkSeed = Value(postmarkSeed),
       sheetId = Value(sheetId),
       createdAt = Value(createdAt);
  static Insertable<StampRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? imagePath,
    Expression<String>? crop,
    Expression<String>? shape,
    Expression<String>? frameId,
    Expression<String>? postmarkDate,
    Expression<String>? postmarkPlace,
    Expression<String>? postmarkNote,
    Expression<int>? postmarkSeed,
    Expression<int>? sheetId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (imagePath != null) 'image_path': imagePath,
      if (crop != null) 'crop': crop,
      if (shape != null) 'shape': shape,
      if (frameId != null) 'frame_id': frameId,
      if (postmarkDate != null) 'postmark_date': postmarkDate,
      if (postmarkPlace != null) 'postmark_place': postmarkPlace,
      if (postmarkNote != null) 'postmark_note': postmarkNote,
      if (postmarkSeed != null) 'postmark_seed': postmarkSeed,
      if (sheetId != null) 'sheet_id': sheetId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  StampsCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? imagePath,
    Value<String>? crop,
    Value<String>? shape,
    Value<String>? frameId,
    Value<String>? postmarkDate,
    Value<String>? postmarkPlace,
    Value<String>? postmarkNote,
    Value<int>? postmarkSeed,
    Value<int>? sheetId,
    Value<DateTime>? createdAt,
  }) {
    return StampsCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      imagePath: imagePath ?? this.imagePath,
      crop: crop ?? this.crop,
      shape: shape ?? this.shape,
      frameId: frameId ?? this.frameId,
      postmarkDate: postmarkDate ?? this.postmarkDate,
      postmarkPlace: postmarkPlace ?? this.postmarkPlace,
      postmarkNote: postmarkNote ?? this.postmarkNote,
      postmarkSeed: postmarkSeed ?? this.postmarkSeed,
      sheetId: sheetId ?? this.sheetId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (crop.present) {
      map['crop'] = Variable<String>(crop.value);
    }
    if (shape.present) {
      map['shape'] = Variable<String>(shape.value);
    }
    if (frameId.present) {
      map['frame_id'] = Variable<String>(frameId.value);
    }
    if (postmarkDate.present) {
      map['postmark_date'] = Variable<String>(postmarkDate.value);
    }
    if (postmarkPlace.present) {
      map['postmark_place'] = Variable<String>(postmarkPlace.value);
    }
    if (postmarkNote.present) {
      map['postmark_note'] = Variable<String>(postmarkNote.value);
    }
    if (postmarkSeed.present) {
      map['postmark_seed'] = Variable<int>(postmarkSeed.value);
    }
    if (sheetId.present) {
      map['sheet_id'] = Variable<int>(sheetId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StampsCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('imagePath: $imagePath, ')
          ..write('crop: $crop, ')
          ..write('shape: $shape, ')
          ..write('frameId: $frameId, ')
          ..write('postmarkDate: $postmarkDate, ')
          ..write('postmarkPlace: $postmarkPlace, ')
          ..write('postmarkNote: $postmarkNote, ')
          ..write('postmarkSeed: $postmarkSeed, ')
          ..write('sheetId: $sheetId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaceHistoryTable extends PlaceHistory
    with TableInfo<$PlaceHistoryTable, PlaceHistoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaceHistoryTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _placeMeta = const VerificationMeta('place');
  @override
  late final GeneratedColumn<String> place = GeneratedColumn<String>(
    'place',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastUsedAtMeta = const VerificationMeta(
    'lastUsedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsedAt = GeneratedColumn<DateTime>(
    'last_used_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [place, lastUsedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'place_history';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaceHistoryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('place')) {
      context.handle(
        _placeMeta,
        place.isAcceptableOrUnknown(data['place']!, _placeMeta),
      );
    } else if (isInserting) {
      context.missing(_placeMeta);
    }
    if (data.containsKey('last_used_at')) {
      context.handle(
        _lastUsedAtMeta,
        lastUsedAt.isAcceptableOrUnknown(
          data['last_used_at']!,
          _lastUsedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastUsedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {place};
  @override
  PlaceHistoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaceHistoryRow(
      place: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}place'],
      )!,
      lastUsedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used_at'],
      )!,
    );
  }

  @override
  $PlaceHistoryTable createAlias(String alias) {
    return $PlaceHistoryTable(attachedDatabase, alias);
  }
}

class PlaceHistoryRow extends DataClass implements Insertable<PlaceHistoryRow> {
  final String place;
  final DateTime lastUsedAt;
  const PlaceHistoryRow({required this.place, required this.lastUsedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['place'] = Variable<String>(place);
    map['last_used_at'] = Variable<DateTime>(lastUsedAt);
    return map;
  }

  PlaceHistoryCompanion toCompanion(bool nullToAbsent) {
    return PlaceHistoryCompanion(
      place: Value(place),
      lastUsedAt: Value(lastUsedAt),
    );
  }

  factory PlaceHistoryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaceHistoryRow(
      place: serializer.fromJson<String>(json['place']),
      lastUsedAt: serializer.fromJson<DateTime>(json['lastUsedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'place': serializer.toJson<String>(place),
      'lastUsedAt': serializer.toJson<DateTime>(lastUsedAt),
    };
  }

  PlaceHistoryRow copyWith({String? place, DateTime? lastUsedAt}) =>
      PlaceHistoryRow(
        place: place ?? this.place,
        lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      );
  PlaceHistoryRow copyWithCompanion(PlaceHistoryCompanion data) {
    return PlaceHistoryRow(
      place: data.place.present ? data.place.value : this.place,
      lastUsedAt: data.lastUsedAt.present
          ? data.lastUsedAt.value
          : this.lastUsedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaceHistoryRow(')
          ..write('place: $place, ')
          ..write('lastUsedAt: $lastUsedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(place, lastUsedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaceHistoryRow &&
          other.place == this.place &&
          other.lastUsedAt == this.lastUsedAt);
}

class PlaceHistoryCompanion extends UpdateCompanion<PlaceHistoryRow> {
  final Value<String> place;
  final Value<DateTime> lastUsedAt;
  final Value<int> rowid;
  const PlaceHistoryCompanion({
    this.place = const Value.absent(),
    this.lastUsedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlaceHistoryCompanion.insert({
    required String place,
    required DateTime lastUsedAt,
    this.rowid = const Value.absent(),
  }) : place = Value(place),
       lastUsedAt = Value(lastUsedAt);
  static Insertable<PlaceHistoryRow> custom({
    Expression<String>? place,
    Expression<DateTime>? lastUsedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (place != null) 'place': place,
      if (lastUsedAt != null) 'last_used_at': lastUsedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlaceHistoryCompanion copyWith({
    Value<String>? place,
    Value<DateTime>? lastUsedAt,
    Value<int>? rowid,
  }) {
    return PlaceHistoryCompanion(
      place: place ?? this.place,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (place.present) {
      map['place'] = Variable<String>(place.value);
    }
    if (lastUsedAt.present) {
      map['last_used_at'] = Variable<DateTime>(lastUsedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaceHistoryCompanion(')
          ..write('place: $place, ')
          ..write('lastUsedAt: $lastUsedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SheetsTable sheets = $SheetsTable(this);
  late final $StampsTable stamps = $StampsTable(this);
  late final $PlaceHistoryTable placeHistory = $PlaceHistoryTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    sheets,
    stamps,
    placeHistory,
  ];
}

typedef $$SheetsTableCreateCompanionBuilder =
    SheetsCompanion Function({
      Value<int> id,
      required String kind,
      Value<int?> year,
      Value<int?> month,
      Value<String> title,
      Value<String?> dateFrom,
      Value<String?> dateTo,
      Value<DateTime?> completedAt,
    });
typedef $$SheetsTableUpdateCompanionBuilder =
    SheetsCompanion Function({
      Value<int> id,
      Value<String> kind,
      Value<int?> year,
      Value<int?> month,
      Value<String> title,
      Value<String?> dateFrom,
      Value<String?> dateTo,
      Value<DateTime?> completedAt,
    });

final class $$SheetsTableReferences
    extends BaseReferences<_$AppDatabase, $SheetsTable, SheetRow> {
  $$SheetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$StampsTable, List<StampRow>> _stampsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.stamps,
    aliasName: 'sheet__id__stamp__sheet_id',
  );

  $$StampsTableProcessedTableManager get stampsRefs {
    final manager = $$StampsTableTableManager(
      $_db,
      $_db.stamps,
    ).filter((f) => f.sheetId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_stampsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SheetsTableFilterComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateFrom => $composableBuilder(
    column: $table.dateFrom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dateTo => $composableBuilder(
    column: $table.dateTo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> stampsRefs(
    Expression<bool> Function($$StampsTableFilterComposer f) f,
  ) {
    final $$StampsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableFilterComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetsTableOrderingComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get month => $composableBuilder(
    column: $table.month,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateFrom => $composableBuilder(
    column: $table.dateFrom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dateTo => $composableBuilder(
    column: $table.dateTo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SheetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SheetsTable> {
  $$SheetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<int> get month =>
      $composableBuilder(column: $table.month, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get dateFrom =>
      $composableBuilder(column: $table.dateFrom, builder: (column) => column);

  GeneratedColumn<String> get dateTo =>
      $composableBuilder(column: $table.dateTo, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  Expression<T> stampsRefs<T extends Object>(
    Expression<T> Function($$StampsTableAnnotationComposer a) f,
  ) {
    final $$StampsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.stamps,
      getReferencedColumn: (t) => t.sheetId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StampsTableAnnotationComposer(
            $db: $db,
            $table: $db.stamps,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SheetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SheetsTable,
          SheetRow,
          $$SheetsTableFilterComposer,
          $$SheetsTableOrderingComposer,
          $$SheetsTableAnnotationComposer,
          $$SheetsTableCreateCompanionBuilder,
          $$SheetsTableUpdateCompanionBuilder,
          (SheetRow, $$SheetsTableReferences),
          SheetRow,
          PrefetchHooks Function({bool stampsRefs})
        > {
  $$SheetsTableTableManager(_$AppDatabase db, $SheetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SheetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SheetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SheetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<int?> month = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> dateFrom = const Value.absent(),
                Value<String?> dateTo = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SheetsCompanion(
                id: id,
                kind: kind,
                year: year,
                month: month,
                title: title,
                dateFrom: dateFrom,
                dateTo: dateTo,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String kind,
                Value<int?> year = const Value.absent(),
                Value<int?> month = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> dateFrom = const Value.absent(),
                Value<String?> dateTo = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
              }) => SheetsCompanion.insert(
                id: id,
                kind: kind,
                year: year,
                month: month,
                title: title,
                dateFrom: dateFrom,
                dateTo: dateTo,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SheetsTable, SheetRow>(table),
                  $$SheetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({stampsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (stampsRefs) db.stamps],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (stampsRefs)
                    await $_getPrefetchedDataByColumns<
                      SheetRow,
                      $SheetsTable,
                      StampRow,
                      $StampsTable
                    >(
                      currentTable: table,
                      referencedTable: $$SheetsTableReferences._stampsRefsTable(
                        db,
                      ),
                      managerFromTypedResult: (p0) =>
                          $$SheetsTableReferences(db, table, p0).stampsRefs,
                      currentColumn: 'id',
                      referencedColumn: 'sheet_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$SheetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SheetsTable,
      SheetRow,
      $$SheetsTableFilterComposer,
      $$SheetsTableOrderingComposer,
      $$SheetsTableAnnotationComposer,
      $$SheetsTableCreateCompanionBuilder,
      $$SheetsTableUpdateCompanionBuilder,
      (SheetRow, $$SheetsTableReferences),
      SheetRow,
      PrefetchHooks Function({bool stampsRefs})
    >;
typedef $$StampsTableCreateCompanionBuilder =
    StampsCompanion Function({
      Value<int> id,
      required String date,
      required String imagePath,
      required String crop,
      Value<String> shape,
      required String frameId,
      required String postmarkDate,
      Value<String> postmarkPlace,
      Value<String> postmarkNote,
      required int postmarkSeed,
      required int sheetId,
      required DateTime createdAt,
    });
typedef $$StampsTableUpdateCompanionBuilder =
    StampsCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> imagePath,
      Value<String> crop,
      Value<String> shape,
      Value<String> frameId,
      Value<String> postmarkDate,
      Value<String> postmarkPlace,
      Value<String> postmarkNote,
      Value<int> postmarkSeed,
      Value<int> sheetId,
      Value<DateTime> createdAt,
    });

final class $$StampsTableReferences
    extends BaseReferences<_$AppDatabase, $StampsTable, StampRow> {
  $$StampsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SheetsTable _sheetIdTable(_$AppDatabase db) =>
      db.sheets.createAlias('stamp__sheet_id__sheet__id');

  $$SheetsTableProcessedTableManager get sheetId {
    final $_column = $_itemColumn<int>('sheet_id')!;

    final manager = $$SheetsTableTableManager(
      $_db,
      $_db.sheets,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sheetIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StampsTableFilterComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get crop => $composableBuilder(
    column: $table.crop,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frameId => $composableBuilder(
    column: $table.frameId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postmarkDate => $composableBuilder(
    column: $table.postmarkDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postmarkPlace => $composableBuilder(
    column: $table.postmarkPlace,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get postmarkNote => $composableBuilder(
    column: $table.postmarkNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get postmarkSeed => $composableBuilder(
    column: $table.postmarkSeed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SheetsTableFilterComposer get sheetId {
    final $$SheetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableFilterComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableOrderingComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get crop => $composableBuilder(
    column: $table.crop,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shape => $composableBuilder(
    column: $table.shape,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frameId => $composableBuilder(
    column: $table.frameId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postmarkDate => $composableBuilder(
    column: $table.postmarkDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postmarkPlace => $composableBuilder(
    column: $table.postmarkPlace,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get postmarkNote => $composableBuilder(
    column: $table.postmarkNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get postmarkSeed => $composableBuilder(
    column: $table.postmarkSeed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SheetsTableOrderingComposer get sheetId {
    final $$SheetsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableOrderingComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StampsTable> {
  $$StampsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get crop =>
      $composableBuilder(column: $table.crop, builder: (column) => column);

  GeneratedColumn<String> get shape =>
      $composableBuilder(column: $table.shape, builder: (column) => column);

  GeneratedColumn<String> get frameId =>
      $composableBuilder(column: $table.frameId, builder: (column) => column);

  GeneratedColumn<String> get postmarkDate => $composableBuilder(
    column: $table.postmarkDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postmarkPlace => $composableBuilder(
    column: $table.postmarkPlace,
    builder: (column) => column,
  );

  GeneratedColumn<String> get postmarkNote => $composableBuilder(
    column: $table.postmarkNote,
    builder: (column) => column,
  );

  GeneratedColumn<int> get postmarkSeed => $composableBuilder(
    column: $table.postmarkSeed,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SheetsTableAnnotationComposer get sheetId {
    final $$SheetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sheetId,
      referencedTable: $db.sheets,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SheetsTableAnnotationComposer(
            $db: $db,
            $table: $db.sheets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StampsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StampsTable,
          StampRow,
          $$StampsTableFilterComposer,
          $$StampsTableOrderingComposer,
          $$StampsTableAnnotationComposer,
          $$StampsTableCreateCompanionBuilder,
          $$StampsTableUpdateCompanionBuilder,
          (StampRow, $$StampsTableReferences),
          StampRow,
          PrefetchHooks Function({bool sheetId})
        > {
  $$StampsTableTableManager(_$AppDatabase db, $StampsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StampsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StampsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StampsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> imagePath = const Value.absent(),
                Value<String> crop = const Value.absent(),
                Value<String> shape = const Value.absent(),
                Value<String> frameId = const Value.absent(),
                Value<String> postmarkDate = const Value.absent(),
                Value<String> postmarkPlace = const Value.absent(),
                Value<String> postmarkNote = const Value.absent(),
                Value<int> postmarkSeed = const Value.absent(),
                Value<int> sheetId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => StampsCompanion(
                id: id,
                date: date,
                imagePath: imagePath,
                crop: crop,
                shape: shape,
                frameId: frameId,
                postmarkDate: postmarkDate,
                postmarkPlace: postmarkPlace,
                postmarkNote: postmarkNote,
                postmarkSeed: postmarkSeed,
                sheetId: sheetId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String imagePath,
                required String crop,
                Value<String> shape = const Value.absent(),
                required String frameId,
                required String postmarkDate,
                Value<String> postmarkPlace = const Value.absent(),
                Value<String> postmarkNote = const Value.absent(),
                required int postmarkSeed,
                required int sheetId,
                required DateTime createdAt,
              }) => StampsCompanion.insert(
                id: id,
                date: date,
                imagePath: imagePath,
                crop: crop,
                shape: shape,
                frameId: frameId,
                postmarkDate: postmarkDate,
                postmarkPlace: postmarkPlace,
                postmarkNote: postmarkNote,
                postmarkSeed: postmarkSeed,
                sheetId: sheetId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$StampsTable, StampRow>(table),
                  $$StampsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sheetId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sheetId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sheetId,
                                referencedTable: $$StampsTableReferences
                                    ._sheetIdTable(db),
                                referencedColumn: $$StampsTableReferences
                                    ._sheetIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StampsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StampsTable,
      StampRow,
      $$StampsTableFilterComposer,
      $$StampsTableOrderingComposer,
      $$StampsTableAnnotationComposer,
      $$StampsTableCreateCompanionBuilder,
      $$StampsTableUpdateCompanionBuilder,
      (StampRow, $$StampsTableReferences),
      StampRow,
      PrefetchHooks Function({bool sheetId})
    >;
typedef $$PlaceHistoryTableCreateCompanionBuilder =
    PlaceHistoryCompanion Function({
      required String place,
      required DateTime lastUsedAt,
      Value<int> rowid,
    });
typedef $$PlaceHistoryTableUpdateCompanionBuilder =
    PlaceHistoryCompanion Function({
      Value<String> place,
      Value<DateTime> lastUsedAt,
      Value<int> rowid,
    });

class $$PlaceHistoryTableFilterComposer
    extends Composer<_$AppDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaceHistoryTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get place => $composableBuilder(
    column: $table.place,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaceHistoryTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaceHistoryTable> {
  $$PlaceHistoryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get place =>
      $composableBuilder(column: $table.place, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsedAt => $composableBuilder(
    column: $table.lastUsedAt,
    builder: (column) => column,
  );
}

class $$PlaceHistoryTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaceHistoryTable,
          PlaceHistoryRow,
          $$PlaceHistoryTableFilterComposer,
          $$PlaceHistoryTableOrderingComposer,
          $$PlaceHistoryTableAnnotationComposer,
          $$PlaceHistoryTableCreateCompanionBuilder,
          $$PlaceHistoryTableUpdateCompanionBuilder,
          (
            PlaceHistoryRow,
            BaseReferences<_$AppDatabase, $PlaceHistoryTable, PlaceHistoryRow>,
          ),
          PlaceHistoryRow,
          PrefetchHooks Function()
        > {
  $$PlaceHistoryTableTableManager(_$AppDatabase db, $PlaceHistoryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaceHistoryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaceHistoryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaceHistoryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> place = const Value.absent(),
                Value<DateTime> lastUsedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlaceHistoryCompanion(
                place: place,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String place,
                required DateTime lastUsedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlaceHistoryCompanion.insert(
                place: place,
                lastUsedAt: lastUsedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlaceHistoryTable, PlaceHistoryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlaceHistoryTable,
                    PlaceHistoryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaceHistoryTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaceHistoryTable,
      PlaceHistoryRow,
      $$PlaceHistoryTableFilterComposer,
      $$PlaceHistoryTableOrderingComposer,
      $$PlaceHistoryTableAnnotationComposer,
      $$PlaceHistoryTableCreateCompanionBuilder,
      $$PlaceHistoryTableUpdateCompanionBuilder,
      (
        PlaceHistoryRow,
        BaseReferences<_$AppDatabase, $PlaceHistoryTable, PlaceHistoryRow>,
      ),
      PlaceHistoryRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SheetsTableTableManager get sheets =>
      $$SheetsTableTableManager(_db, _db.sheets);
  $$StampsTableTableManager get stamps =>
      $$StampsTableTableManager(_db, _db.stamps);
  $$PlaceHistoryTableTableManager get placeHistory =>
      $$PlaceHistoryTableTableManager(_db, _db.placeHistory);
}
