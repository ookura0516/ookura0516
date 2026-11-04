// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $HaikuTable extends Haiku with TableInfo<$HaikuTable, HaikuRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HaikuTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maegakiMeta = const VerificationMeta(
    'maegaki',
  );
  @override
  late final GeneratedColumn<String> maegaki = GeneratedColumn<String>(
    'maegaki',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _kigoIdMeta = const VerificationMeta('kigoId');
  @override
  late final GeneratedColumn<int> kigoId = GeneratedColumn<int>(
    'kigo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _composedOnMeta = const VerificationMeta(
    'composedOn',
  );
  @override
  late final GeneratedColumn<DateTime> composedOn = GeneratedColumn<DateTime>(
    'composed_on',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _themeKigoIdMeta = const VerificationMeta(
    'themeKigoId',
  );
  @override
  late final GeneratedColumn<int> themeKigoId = GeneratedColumn<int>(
    'theme_kigo_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _favoriteMeta = const VerificationMeta(
    'favorite',
  );
  @override
  late final GeneratedColumn<bool> favorite = GeneratedColumn<bool>(
    'favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    body,
    maegaki,
    kigoId,
    season,
    composedOn,
    themeKigoId,
    memo,
    favorite,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'haiku';
  @override
  VerificationContext validateIntegrity(
    Insertable<HaikuRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('maegaki')) {
      context.handle(
        _maegakiMeta,
        maegaki.isAcceptableOrUnknown(data['maegaki']!, _maegakiMeta),
      );
    }
    if (data.containsKey('kigo_id')) {
      context.handle(
        _kigoIdMeta,
        kigoId.isAcceptableOrUnknown(data['kigo_id']!, _kigoIdMeta),
      );
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    }
    if (data.containsKey('composed_on')) {
      context.handle(
        _composedOnMeta,
        composedOn.isAcceptableOrUnknown(data['composed_on']!, _composedOnMeta),
      );
    } else if (isInserting) {
      context.missing(_composedOnMeta);
    }
    if (data.containsKey('theme_kigo_id')) {
      context.handle(
        _themeKigoIdMeta,
        themeKigoId.isAcceptableOrUnknown(
          data['theme_kigo_id']!,
          _themeKigoIdMeta,
        ),
      );
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('favorite')) {
      context.handle(
        _favoriteMeta,
        favorite.isAcceptableOrUnknown(data['favorite']!, _favoriteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HaikuRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HaikuRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      maegaki: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}maegaki'],
      )!,
      kigoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kigo_id'],
      ),
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      composedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}composed_on'],
      )!,
      themeKigoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}theme_kigo_id'],
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      )!,
      favorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}favorite'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $HaikuTable createAlias(String alias) {
    return $HaikuTable(attachedDatabase, alias);
  }
}

class HaikuRow extends DataClass implements Insertable<HaikuRow> {
  final int id;
  final String body;
  final String maegaki;
  final int? kigoId;

  /// 新年・春・夏・秋・冬。季語がなければ空（無季）。
  final String season;

  /// 詠んだ日（時刻なし）。
  final DateTime composedOn;

  /// 兼題で詠んだときの季語。
  final int? themeKigoId;
  final String memo;
  final bool favorite;
  final DateTime createdAt;
  final DateTime updatedAt;
  const HaikuRow({
    required this.id,
    required this.body,
    required this.maegaki,
    this.kigoId,
    required this.season,
    required this.composedOn,
    this.themeKigoId,
    required this.memo,
    required this.favorite,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['text'] = Variable<String>(body);
    map['maegaki'] = Variable<String>(maegaki);
    if (!nullToAbsent || kigoId != null) {
      map['kigo_id'] = Variable<int>(kigoId);
    }
    map['season'] = Variable<String>(season);
    map['composed_on'] = Variable<DateTime>(composedOn);
    if (!nullToAbsent || themeKigoId != null) {
      map['theme_kigo_id'] = Variable<int>(themeKigoId);
    }
    map['memo'] = Variable<String>(memo);
    map['favorite'] = Variable<bool>(favorite);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  HaikuCompanion toCompanion(bool nullToAbsent) {
    return HaikuCompanion(
      id: Value(id),
      body: Value(body),
      maegaki: Value(maegaki),
      kigoId: kigoId == null && nullToAbsent
          ? const Value.absent()
          : Value(kigoId),
      season: Value(season),
      composedOn: Value(composedOn),
      themeKigoId: themeKigoId == null && nullToAbsent
          ? const Value.absent()
          : Value(themeKigoId),
      memo: Value(memo),
      favorite: Value(favorite),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory HaikuRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HaikuRow(
      id: serializer.fromJson<int>(json['id']),
      body: serializer.fromJson<String>(json['body']),
      maegaki: serializer.fromJson<String>(json['maegaki']),
      kigoId: serializer.fromJson<int?>(json['kigoId']),
      season: serializer.fromJson<String>(json['season']),
      composedOn: serializer.fromJson<DateTime>(json['composedOn']),
      themeKigoId: serializer.fromJson<int?>(json['themeKigoId']),
      memo: serializer.fromJson<String>(json['memo']),
      favorite: serializer.fromJson<bool>(json['favorite']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'body': serializer.toJson<String>(body),
      'maegaki': serializer.toJson<String>(maegaki),
      'kigoId': serializer.toJson<int?>(kigoId),
      'season': serializer.toJson<String>(season),
      'composedOn': serializer.toJson<DateTime>(composedOn),
      'themeKigoId': serializer.toJson<int?>(themeKigoId),
      'memo': serializer.toJson<String>(memo),
      'favorite': serializer.toJson<bool>(favorite),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  HaikuRow copyWith({
    int? id,
    String? body,
    String? maegaki,
    Value<int?> kigoId = const Value.absent(),
    String? season,
    DateTime? composedOn,
    Value<int?> themeKigoId = const Value.absent(),
    String? memo,
    bool? favorite,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => HaikuRow(
    id: id ?? this.id,
    body: body ?? this.body,
    maegaki: maegaki ?? this.maegaki,
    kigoId: kigoId.present ? kigoId.value : this.kigoId,
    season: season ?? this.season,
    composedOn: composedOn ?? this.composedOn,
    themeKigoId: themeKigoId.present ? themeKigoId.value : this.themeKigoId,
    memo: memo ?? this.memo,
    favorite: favorite ?? this.favorite,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  HaikuRow copyWithCompanion(HaikuCompanion data) {
    return HaikuRow(
      id: data.id.present ? data.id.value : this.id,
      body: data.body.present ? data.body.value : this.body,
      maegaki: data.maegaki.present ? data.maegaki.value : this.maegaki,
      kigoId: data.kigoId.present ? data.kigoId.value : this.kigoId,
      season: data.season.present ? data.season.value : this.season,
      composedOn: data.composedOn.present
          ? data.composedOn.value
          : this.composedOn,
      themeKigoId: data.themeKigoId.present
          ? data.themeKigoId.value
          : this.themeKigoId,
      memo: data.memo.present ? data.memo.value : this.memo,
      favorite: data.favorite.present ? data.favorite.value : this.favorite,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HaikuRow(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('maegaki: $maegaki, ')
          ..write('kigoId: $kigoId, ')
          ..write('season: $season, ')
          ..write('composedOn: $composedOn, ')
          ..write('themeKigoId: $themeKigoId, ')
          ..write('memo: $memo, ')
          ..write('favorite: $favorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    body,
    maegaki,
    kigoId,
    season,
    composedOn,
    themeKigoId,
    memo,
    favorite,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HaikuRow &&
          other.id == this.id &&
          other.body == this.body &&
          other.maegaki == this.maegaki &&
          other.kigoId == this.kigoId &&
          other.season == this.season &&
          other.composedOn == this.composedOn &&
          other.themeKigoId == this.themeKigoId &&
          other.memo == this.memo &&
          other.favorite == this.favorite &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class HaikuCompanion extends UpdateCompanion<HaikuRow> {
  final Value<int> id;
  final Value<String> body;
  final Value<String> maegaki;
  final Value<int?> kigoId;
  final Value<String> season;
  final Value<DateTime> composedOn;
  final Value<int?> themeKigoId;
  final Value<String> memo;
  final Value<bool> favorite;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const HaikuCompanion({
    this.id = const Value.absent(),
    this.body = const Value.absent(),
    this.maegaki = const Value.absent(),
    this.kigoId = const Value.absent(),
    this.season = const Value.absent(),
    this.composedOn = const Value.absent(),
    this.themeKigoId = const Value.absent(),
    this.memo = const Value.absent(),
    this.favorite = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  HaikuCompanion.insert({
    this.id = const Value.absent(),
    required String body,
    this.maegaki = const Value.absent(),
    this.kigoId = const Value.absent(),
    this.season = const Value.absent(),
    required DateTime composedOn,
    this.themeKigoId = const Value.absent(),
    this.memo = const Value.absent(),
    this.favorite = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : body = Value(body),
       composedOn = Value(composedOn),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<HaikuRow> custom({
    Expression<int>? id,
    Expression<String>? body,
    Expression<String>? maegaki,
    Expression<int>? kigoId,
    Expression<String>? season,
    Expression<DateTime>? composedOn,
    Expression<int>? themeKigoId,
    Expression<String>? memo,
    Expression<bool>? favorite,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (body != null) 'text': body,
      if (maegaki != null) 'maegaki': maegaki,
      if (kigoId != null) 'kigo_id': kigoId,
      if (season != null) 'season': season,
      if (composedOn != null) 'composed_on': composedOn,
      if (themeKigoId != null) 'theme_kigo_id': themeKigoId,
      if (memo != null) 'memo': memo,
      if (favorite != null) 'favorite': favorite,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  HaikuCompanion copyWith({
    Value<int>? id,
    Value<String>? body,
    Value<String>? maegaki,
    Value<int?>? kigoId,
    Value<String>? season,
    Value<DateTime>? composedOn,
    Value<int?>? themeKigoId,
    Value<String>? memo,
    Value<bool>? favorite,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return HaikuCompanion(
      id: id ?? this.id,
      body: body ?? this.body,
      maegaki: maegaki ?? this.maegaki,
      kigoId: kigoId ?? this.kigoId,
      season: season ?? this.season,
      composedOn: composedOn ?? this.composedOn,
      themeKigoId: themeKigoId ?? this.themeKigoId,
      memo: memo ?? this.memo,
      favorite: favorite ?? this.favorite,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (maegaki.present) {
      map['maegaki'] = Variable<String>(maegaki.value);
    }
    if (kigoId.present) {
      map['kigo_id'] = Variable<int>(kigoId.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (composedOn.present) {
      map['composed_on'] = Variable<DateTime>(composedOn.value);
    }
    if (themeKigoId.present) {
      map['theme_kigo_id'] = Variable<int>(themeKigoId.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (favorite.present) {
      map['favorite'] = Variable<bool>(favorite.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HaikuCompanion(')
          ..write('id: $id, ')
          ..write('body: $body, ')
          ..write('maegaki: $maegaki, ')
          ..write('kigoId: $kigoId, ')
          ..write('season: $season, ')
          ..write('composedOn: $composedOn, ')
          ..write('themeKigoId: $themeKigoId, ')
          ..write('memo: $memo, ')
          ..write('favorite: $favorite, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $HaikuRevisionTable extends HaikuRevision
    with TableInfo<$HaikuRevisionTable, HaikuRevisionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HaikuRevisionTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _haikuIdMeta = const VerificationMeta(
    'haikuId',
  );
  @override
  late final GeneratedColumn<int> haikuId = GeneratedColumn<int>(
    'haiku_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES haiku (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'text',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _savedAtMeta = const VerificationMeta(
    'savedAt',
  );
  @override
  late final GeneratedColumn<DateTime> savedAt = GeneratedColumn<DateTime>(
    'saved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, haikuId, body, savedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'haiku_revision';
  @override
  VerificationContext validateIntegrity(
    Insertable<HaikuRevisionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('haiku_id')) {
      context.handle(
        _haikuIdMeta,
        haikuId.isAcceptableOrUnknown(data['haiku_id']!, _haikuIdMeta),
      );
    } else if (isInserting) {
      context.missing(_haikuIdMeta);
    }
    if (data.containsKey('text')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['text']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('saved_at')) {
      context.handle(
        _savedAtMeta,
        savedAt.isAcceptableOrUnknown(data['saved_at']!, _savedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_savedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  HaikuRevisionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HaikuRevisionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      haikuId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}haiku_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}text'],
      )!,
      savedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}saved_at'],
      )!,
    );
  }

  @override
  $HaikuRevisionTable createAlias(String alias) {
    return $HaikuRevisionTable(attachedDatabase, alias);
  }
}

class HaikuRevisionRow extends DataClass
    implements Insertable<HaikuRevisionRow> {
  final int id;
  final int haikuId;
  final String body;
  final DateTime savedAt;
  const HaikuRevisionRow({
    required this.id,
    required this.haikuId,
    required this.body,
    required this.savedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['haiku_id'] = Variable<int>(haikuId);
    map['text'] = Variable<String>(body);
    map['saved_at'] = Variable<DateTime>(savedAt);
    return map;
  }

  HaikuRevisionCompanion toCompanion(bool nullToAbsent) {
    return HaikuRevisionCompanion(
      id: Value(id),
      haikuId: Value(haikuId),
      body: Value(body),
      savedAt: Value(savedAt),
    );
  }

  factory HaikuRevisionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HaikuRevisionRow(
      id: serializer.fromJson<int>(json['id']),
      haikuId: serializer.fromJson<int>(json['haikuId']),
      body: serializer.fromJson<String>(json['body']),
      savedAt: serializer.fromJson<DateTime>(json['savedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'haikuId': serializer.toJson<int>(haikuId),
      'body': serializer.toJson<String>(body),
      'savedAt': serializer.toJson<DateTime>(savedAt),
    };
  }

  HaikuRevisionRow copyWith({
    int? id,
    int? haikuId,
    String? body,
    DateTime? savedAt,
  }) => HaikuRevisionRow(
    id: id ?? this.id,
    haikuId: haikuId ?? this.haikuId,
    body: body ?? this.body,
    savedAt: savedAt ?? this.savedAt,
  );
  HaikuRevisionRow copyWithCompanion(HaikuRevisionCompanion data) {
    return HaikuRevisionRow(
      id: data.id.present ? data.id.value : this.id,
      haikuId: data.haikuId.present ? data.haikuId.value : this.haikuId,
      body: data.body.present ? data.body.value : this.body,
      savedAt: data.savedAt.present ? data.savedAt.value : this.savedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HaikuRevisionRow(')
          ..write('id: $id, ')
          ..write('haikuId: $haikuId, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, haikuId, body, savedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HaikuRevisionRow &&
          other.id == this.id &&
          other.haikuId == this.haikuId &&
          other.body == this.body &&
          other.savedAt == this.savedAt);
}

class HaikuRevisionCompanion extends UpdateCompanion<HaikuRevisionRow> {
  final Value<int> id;
  final Value<int> haikuId;
  final Value<String> body;
  final Value<DateTime> savedAt;
  const HaikuRevisionCompanion({
    this.id = const Value.absent(),
    this.haikuId = const Value.absent(),
    this.body = const Value.absent(),
    this.savedAt = const Value.absent(),
  });
  HaikuRevisionCompanion.insert({
    this.id = const Value.absent(),
    required int haikuId,
    required String body,
    required DateTime savedAt,
  }) : haikuId = Value(haikuId),
       body = Value(body),
       savedAt = Value(savedAt);
  static Insertable<HaikuRevisionRow> custom({
    Expression<int>? id,
    Expression<int>? haikuId,
    Expression<String>? body,
    Expression<DateTime>? savedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (haikuId != null) 'haiku_id': haikuId,
      if (body != null) 'text': body,
      if (savedAt != null) 'saved_at': savedAt,
    });
  }

  HaikuRevisionCompanion copyWith({
    Value<int>? id,
    Value<int>? haikuId,
    Value<String>? body,
    Value<DateTime>? savedAt,
  }) {
    return HaikuRevisionCompanion(
      id: id ?? this.id,
      haikuId: haikuId ?? this.haikuId,
      body: body ?? this.body,
      savedAt: savedAt ?? this.savedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (haikuId.present) {
      map['haiku_id'] = Variable<int>(haikuId.value);
    }
    if (body.present) {
      map['text'] = Variable<String>(body.value);
    }
    if (savedAt.present) {
      map['saved_at'] = Variable<DateTime>(savedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HaikuRevisionCompanion(')
          ..write('id: $id, ')
          ..write('haikuId: $haikuId, ')
          ..write('body: $body, ')
          ..write('savedAt: $savedAt')
          ..write(')'))
        .toString();
  }
}

class $KigoTableTable extends KigoTable
    with TableInfo<$KigoTableTable, KigoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $KigoTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _wordMeta = const VerificationMeta('word');
  @override
  late final GeneratedColumn<String> word = GeneratedColumn<String>(
    'word',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _readingMeta = const VerificationMeta(
    'reading',
  );
  @override
  late final GeneratedColumn<String> reading = GeneratedColumn<String>(
    'reading',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _seasonMeta = const VerificationMeta('season');
  @override
  late final GeneratedColumn<String> season = GeneratedColumn<String>(
    'season',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _periodMeta = const VerificationMeta('period');
  @override
  late final GeneratedColumn<String> period = GeneratedColumn<String>(
    'period',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDayMeta = const VerificationMeta(
    'startDay',
  );
  @override
  late final GeneratedColumn<int> startDay = GeneratedColumn<int>(
    'start_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endDayMeta = const VerificationMeta('endDay');
  @override
  late final GeneratedColumn<int> endDay = GeneratedColumn<int>(
    'end_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _aliasesMeta = const VerificationMeta(
    'aliases',
  );
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
    'aliases',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _examplesMeta = const VerificationMeta(
    'examples',
  );
  @override
  late final GeneratedColumn<String> examples = GeneratedColumn<String>(
    'examples',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    word,
    reading,
    season,
    category,
    period,
    startDay,
    endDay,
    description,
    aliases,
    examples,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'kigo';
  @override
  VerificationContext validateIntegrity(
    Insertable<KigoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('word')) {
      context.handle(
        _wordMeta,
        word.isAcceptableOrUnknown(data['word']!, _wordMeta),
      );
    } else if (isInserting) {
      context.missing(_wordMeta);
    }
    if (data.containsKey('reading')) {
      context.handle(
        _readingMeta,
        reading.isAcceptableOrUnknown(data['reading']!, _readingMeta),
      );
    } else if (isInserting) {
      context.missing(_readingMeta);
    }
    if (data.containsKey('season')) {
      context.handle(
        _seasonMeta,
        season.isAcceptableOrUnknown(data['season']!, _seasonMeta),
      );
    } else if (isInserting) {
      context.missing(_seasonMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('period')) {
      context.handle(
        _periodMeta,
        period.isAcceptableOrUnknown(data['period']!, _periodMeta),
      );
    }
    if (data.containsKey('start_day')) {
      context.handle(
        _startDayMeta,
        startDay.isAcceptableOrUnknown(data['start_day']!, _startDayMeta),
      );
    } else if (isInserting) {
      context.missing(_startDayMeta);
    }
    if (data.containsKey('end_day')) {
      context.handle(
        _endDayMeta,
        endDay.isAcceptableOrUnknown(data['end_day']!, _endDayMeta),
      );
    } else if (isInserting) {
      context.missing(_endDayMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('aliases')) {
      context.handle(
        _aliasesMeta,
        aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta),
      );
    }
    if (data.containsKey('examples')) {
      context.handle(
        _examplesMeta,
        examples.isAcceptableOrUnknown(data['examples']!, _examplesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  KigoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return KigoRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      word: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}word'],
      )!,
      reading: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reading'],
      )!,
      season: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}season'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      period: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}period'],
      )!,
      startDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_day'],
      )!,
      endDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_day'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      aliases: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}aliases'],
      )!,
      examples: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}examples'],
      )!,
    );
  }

  @override
  $KigoTableTable createAlias(String alias) {
    return $KigoTableTable(attachedDatabase, alias);
  }
}

class KigoRow extends DataClass implements Insertable<KigoRow> {
  final int id;
  final String word;
  final String reading;
  final String season;
  final String category;

  /// 「初冬」など。
  final String period;

  /// 時期の始まりと終わり（MMDD の4桁。1107 なら11月7日）。
  final int startDay;
  final int endDay;
  final String description;

  /// 別表記（JSON の配列）。
  final String aliases;

  /// 例句（JSON の配列）。
  final String examples;
  const KigoRow({
    required this.id,
    required this.word,
    required this.reading,
    required this.season,
    required this.category,
    required this.period,
    required this.startDay,
    required this.endDay,
    required this.description,
    required this.aliases,
    required this.examples,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['word'] = Variable<String>(word);
    map['reading'] = Variable<String>(reading);
    map['season'] = Variable<String>(season);
    map['category'] = Variable<String>(category);
    map['period'] = Variable<String>(period);
    map['start_day'] = Variable<int>(startDay);
    map['end_day'] = Variable<int>(endDay);
    map['description'] = Variable<String>(description);
    map['aliases'] = Variable<String>(aliases);
    map['examples'] = Variable<String>(examples);
    return map;
  }

  KigoTableCompanion toCompanion(bool nullToAbsent) {
    return KigoTableCompanion(
      id: Value(id),
      word: Value(word),
      reading: Value(reading),
      season: Value(season),
      category: Value(category),
      period: Value(period),
      startDay: Value(startDay),
      endDay: Value(endDay),
      description: Value(description),
      aliases: Value(aliases),
      examples: Value(examples),
    );
  }

  factory KigoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return KigoRow(
      id: serializer.fromJson<int>(json['id']),
      word: serializer.fromJson<String>(json['word']),
      reading: serializer.fromJson<String>(json['reading']),
      season: serializer.fromJson<String>(json['season']),
      category: serializer.fromJson<String>(json['category']),
      period: serializer.fromJson<String>(json['period']),
      startDay: serializer.fromJson<int>(json['startDay']),
      endDay: serializer.fromJson<int>(json['endDay']),
      description: serializer.fromJson<String>(json['description']),
      aliases: serializer.fromJson<String>(json['aliases']),
      examples: serializer.fromJson<String>(json['examples']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'word': serializer.toJson<String>(word),
      'reading': serializer.toJson<String>(reading),
      'season': serializer.toJson<String>(season),
      'category': serializer.toJson<String>(category),
      'period': serializer.toJson<String>(period),
      'startDay': serializer.toJson<int>(startDay),
      'endDay': serializer.toJson<int>(endDay),
      'description': serializer.toJson<String>(description),
      'aliases': serializer.toJson<String>(aliases),
      'examples': serializer.toJson<String>(examples),
    };
  }

  KigoRow copyWith({
    int? id,
    String? word,
    String? reading,
    String? season,
    String? category,
    String? period,
    int? startDay,
    int? endDay,
    String? description,
    String? aliases,
    String? examples,
  }) => KigoRow(
    id: id ?? this.id,
    word: word ?? this.word,
    reading: reading ?? this.reading,
    season: season ?? this.season,
    category: category ?? this.category,
    period: period ?? this.period,
    startDay: startDay ?? this.startDay,
    endDay: endDay ?? this.endDay,
    description: description ?? this.description,
    aliases: aliases ?? this.aliases,
    examples: examples ?? this.examples,
  );
  KigoRow copyWithCompanion(KigoTableCompanion data) {
    return KigoRow(
      id: data.id.present ? data.id.value : this.id,
      word: data.word.present ? data.word.value : this.word,
      reading: data.reading.present ? data.reading.value : this.reading,
      season: data.season.present ? data.season.value : this.season,
      category: data.category.present ? data.category.value : this.category,
      period: data.period.present ? data.period.value : this.period,
      startDay: data.startDay.present ? data.startDay.value : this.startDay,
      endDay: data.endDay.present ? data.endDay.value : this.endDay,
      description: data.description.present
          ? data.description.value
          : this.description,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      examples: data.examples.present ? data.examples.value : this.examples,
    );
  }

  @override
  String toString() {
    return (StringBuffer('KigoRow(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('season: $season, ')
          ..write('category: $category, ')
          ..write('period: $period, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('description: $description, ')
          ..write('aliases: $aliases, ')
          ..write('examples: $examples')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    word,
    reading,
    season,
    category,
    period,
    startDay,
    endDay,
    description,
    aliases,
    examples,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is KigoRow &&
          other.id == this.id &&
          other.word == this.word &&
          other.reading == this.reading &&
          other.season == this.season &&
          other.category == this.category &&
          other.period == this.period &&
          other.startDay == this.startDay &&
          other.endDay == this.endDay &&
          other.description == this.description &&
          other.aliases == this.aliases &&
          other.examples == this.examples);
}

class KigoTableCompanion extends UpdateCompanion<KigoRow> {
  final Value<int> id;
  final Value<String> word;
  final Value<String> reading;
  final Value<String> season;
  final Value<String> category;
  final Value<String> period;
  final Value<int> startDay;
  final Value<int> endDay;
  final Value<String> description;
  final Value<String> aliases;
  final Value<String> examples;
  const KigoTableCompanion({
    this.id = const Value.absent(),
    this.word = const Value.absent(),
    this.reading = const Value.absent(),
    this.season = const Value.absent(),
    this.category = const Value.absent(),
    this.period = const Value.absent(),
    this.startDay = const Value.absent(),
    this.endDay = const Value.absent(),
    this.description = const Value.absent(),
    this.aliases = const Value.absent(),
    this.examples = const Value.absent(),
  });
  KigoTableCompanion.insert({
    this.id = const Value.absent(),
    required String word,
    required String reading,
    required String season,
    required String category,
    this.period = const Value.absent(),
    required int startDay,
    required int endDay,
    required String description,
    this.aliases = const Value.absent(),
    this.examples = const Value.absent(),
  }) : word = Value(word),
       reading = Value(reading),
       season = Value(season),
       category = Value(category),
       startDay = Value(startDay),
       endDay = Value(endDay),
       description = Value(description);
  static Insertable<KigoRow> custom({
    Expression<int>? id,
    Expression<String>? word,
    Expression<String>? reading,
    Expression<String>? season,
    Expression<String>? category,
    Expression<String>? period,
    Expression<int>? startDay,
    Expression<int>? endDay,
    Expression<String>? description,
    Expression<String>? aliases,
    Expression<String>? examples,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (word != null) 'word': word,
      if (reading != null) 'reading': reading,
      if (season != null) 'season': season,
      if (category != null) 'category': category,
      if (period != null) 'period': period,
      if (startDay != null) 'start_day': startDay,
      if (endDay != null) 'end_day': endDay,
      if (description != null) 'description': description,
      if (aliases != null) 'aliases': aliases,
      if (examples != null) 'examples': examples,
    });
  }

  KigoTableCompanion copyWith({
    Value<int>? id,
    Value<String>? word,
    Value<String>? reading,
    Value<String>? season,
    Value<String>? category,
    Value<String>? period,
    Value<int>? startDay,
    Value<int>? endDay,
    Value<String>? description,
    Value<String>? aliases,
    Value<String>? examples,
  }) {
    return KigoTableCompanion(
      id: id ?? this.id,
      word: word ?? this.word,
      reading: reading ?? this.reading,
      season: season ?? this.season,
      category: category ?? this.category,
      period: period ?? this.period,
      startDay: startDay ?? this.startDay,
      endDay: endDay ?? this.endDay,
      description: description ?? this.description,
      aliases: aliases ?? this.aliases,
      examples: examples ?? this.examples,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (word.present) {
      map['word'] = Variable<String>(word.value);
    }
    if (reading.present) {
      map['reading'] = Variable<String>(reading.value);
    }
    if (season.present) {
      map['season'] = Variable<String>(season.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (period.present) {
      map['period'] = Variable<String>(period.value);
    }
    if (startDay.present) {
      map['start_day'] = Variable<int>(startDay.value);
    }
    if (endDay.present) {
      map['end_day'] = Variable<int>(endDay.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (examples.present) {
      map['examples'] = Variable<String>(examples.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('KigoTableCompanion(')
          ..write('id: $id, ')
          ..write('word: $word, ')
          ..write('reading: $reading, ')
          ..write('season: $season, ')
          ..write('category: $category, ')
          ..write('period: $period, ')
          ..write('startDay: $startDay, ')
          ..write('endDay: $endDay, ')
          ..write('description: $description, ')
          ..write('aliases: $aliases, ')
          ..write('examples: $examples')
          ..write(')'))
        .toString();
  }
}

class $ThemeLogTable extends ThemeLog
    with TableInfo<$ThemeLogTable, ThemeLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ThemeLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kigoIdMeta = const VerificationMeta('kigoId');
  @override
  late final GeneratedColumn<int> kigoId = GeneratedColumn<int>(
    'kigo_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [date, kigoId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'theme_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<ThemeLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('kigo_id')) {
      context.handle(
        _kigoIdMeta,
        kigoId.isAcceptableOrUnknown(data['kigo_id']!, _kigoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_kigoIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  ThemeLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ThemeLogRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      kigoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kigo_id'],
      )!,
    );
  }

  @override
  $ThemeLogTable createAlias(String alias) {
    return $ThemeLogTable(attachedDatabase, alias);
  }
}

class ThemeLogRow extends DataClass implements Insertable<ThemeLogRow> {
  final DateTime date;
  final int kigoId;
  const ThemeLogRow({required this.date, required this.kigoId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<DateTime>(date);
    map['kigo_id'] = Variable<int>(kigoId);
    return map;
  }

  ThemeLogCompanion toCompanion(bool nullToAbsent) {
    return ThemeLogCompanion(date: Value(date), kigoId: Value(kigoId));
  }

  factory ThemeLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ThemeLogRow(
      date: serializer.fromJson<DateTime>(json['date']),
      kigoId: serializer.fromJson<int>(json['kigoId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<DateTime>(date),
      'kigoId': serializer.toJson<int>(kigoId),
    };
  }

  ThemeLogRow copyWith({DateTime? date, int? kigoId}) =>
      ThemeLogRow(date: date ?? this.date, kigoId: kigoId ?? this.kigoId);
  ThemeLogRow copyWithCompanion(ThemeLogCompanion data) {
    return ThemeLogRow(
      date: data.date.present ? data.date.value : this.date,
      kigoId: data.kigoId.present ? data.kigoId.value : this.kigoId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ThemeLogRow(')
          ..write('date: $date, ')
          ..write('kigoId: $kigoId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(date, kigoId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ThemeLogRow &&
          other.date == this.date &&
          other.kigoId == this.kigoId);
}

class ThemeLogCompanion extends UpdateCompanion<ThemeLogRow> {
  final Value<DateTime> date;
  final Value<int> kigoId;
  final Value<int> rowid;
  const ThemeLogCompanion({
    this.date = const Value.absent(),
    this.kigoId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ThemeLogCompanion.insert({
    required DateTime date,
    required int kigoId,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       kigoId = Value(kigoId);
  static Insertable<ThemeLogRow> custom({
    Expression<DateTime>? date,
    Expression<int>? kigoId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (kigoId != null) 'kigo_id': kigoId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ThemeLogCompanion copyWith({
    Value<DateTime>? date,
    Value<int>? kigoId,
    Value<int>? rowid,
  }) {
    return ThemeLogCompanion(
      date: date ?? this.date,
      kigoId: kigoId ?? this.kigoId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (kigoId.present) {
      map['kigo_id'] = Variable<int>(kigoId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ThemeLogCompanion(')
          ..write('date: $date, ')
          ..write('kigoId: $kigoId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$TanzakuDatabase extends GeneratedDatabase {
  _$TanzakuDatabase(QueryExecutor e) : super(e);
  $TanzakuDatabaseManager get managers => $TanzakuDatabaseManager(this);
  late final $HaikuTable haiku = $HaikuTable(this);
  late final $HaikuRevisionTable haikuRevision = $HaikuRevisionTable(this);
  late final $KigoTableTable kigoTable = $KigoTableTable(this);
  late final $ThemeLogTable themeLog = $ThemeLogTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    haiku,
    haikuRevision,
    kigoTable,
    themeLog,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'haiku',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('haiku_revision', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$HaikuTableCreateCompanionBuilder = HaikuCompanion Function({
  Value<int> id,
  required String body,
  Value<String> maegaki,
  Value<int?> kigoId,
  Value<String> season,
  required DateTime composedOn,
  Value<int?> themeKigoId,
  Value<String> memo,
  Value<bool> favorite,
  required DateTime createdAt,
  required DateTime updatedAt,
});
typedef $$HaikuTableUpdateCompanionBuilder = HaikuCompanion Function({
  Value<int> id,
  Value<String> body,
  Value<String> maegaki,
  Value<int?> kigoId,
  Value<String> season,
  Value<DateTime> composedOn,
  Value<int?> themeKigoId,
  Value<String> memo,
  Value<bool> favorite,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
});

final class $$HaikuTableReferences
    extends BaseReferences<_$TanzakuDatabase, $HaikuTable, HaikuRow> {
  $$HaikuTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$HaikuRevisionTable, List<HaikuRevisionRow>>
  _haikuRevisionRefsTable(_$TanzakuDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.haikuRevision,
        aliasName: 'haiku__id__haiku_revision__haiku_id',
      );

  $$HaikuRevisionTableProcessedTableManager get haikuRevisionRefs {
    final manager = $$HaikuRevisionTableTableManager(
      $_db,
      $_db.haikuRevision,
    ).filter((f) => f.haikuId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_haikuRevisionRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$HaikuTableFilterComposer
    extends Composer<_$TanzakuDatabase, $HaikuTable> {
  $$HaikuTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get maegaki => $composableBuilder(
    column: $table.maegaki,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kigoId => $composableBuilder(
    column: $table.kigoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get composedOn => $composableBuilder(
    column: $table.composedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get themeKigoId => $composableBuilder(
    column: $table.themeKigoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> haikuRevisionRefs(
    Expression<bool> Function($$HaikuRevisionTableFilterComposer f) f,
  ) {
    final $$HaikuRevisionTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.haikuRevision,
      getReferencedColumn: (t) => t.haikuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaikuRevisionTableFilterComposer(
            $db: $db,
            $table: $db.haikuRevision,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HaikuTableOrderingComposer
    extends Composer<_$TanzakuDatabase, $HaikuTable> {
  $$HaikuTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get maegaki => $composableBuilder(
    column: $table.maegaki,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kigoId => $composableBuilder(
    column: $table.kigoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get composedOn => $composableBuilder(
    column: $table.composedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get themeKigoId => $composableBuilder(
    column: $table.themeKigoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get favorite => $composableBuilder(
    column: $table.favorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HaikuTableAnnotationComposer
    extends Composer<_$TanzakuDatabase, $HaikuTable> {
  $$HaikuTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get maegaki =>
      $composableBuilder(column: $table.maegaki, builder: (column) => column);

  GeneratedColumn<int> get kigoId =>
      $composableBuilder(column: $table.kigoId, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<DateTime> get composedOn => $composableBuilder(
    column: $table.composedOn,
    builder: (column) => column,
  );

  GeneratedColumn<int> get themeKigoId => $composableBuilder(
    column: $table.themeKigoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<bool> get favorite =>
      $composableBuilder(column: $table.favorite, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> haikuRevisionRefs<T extends Object>(
    Expression<T> Function($$HaikuRevisionTableAnnotationComposer a) f,
  ) {
    final $$HaikuRevisionTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.haikuRevision,
      getReferencedColumn: (t) => t.haikuId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaikuRevisionTableAnnotationComposer(
            $db: $db,
            $table: $db.haikuRevision,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$HaikuTableTableManager
    extends
        RootTableManager<
          _$TanzakuDatabase,
          $HaikuTable,
          HaikuRow,
          $$HaikuTableFilterComposer,
          $$HaikuTableOrderingComposer,
          $$HaikuTableAnnotationComposer,
          $$HaikuTableCreateCompanionBuilder,
          $$HaikuTableUpdateCompanionBuilder,
          (HaikuRow, $$HaikuTableReferences),
          HaikuRow,
          PrefetchHooks Function({bool haikuRevisionRefs})
        > {
  $$HaikuTableTableManager(_$TanzakuDatabase db, $HaikuTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HaikuTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HaikuTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HaikuTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String> maegaki = const Value.absent(),
                Value<int?> kigoId = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<DateTime> composedOn = const Value.absent(),
                Value<int?> themeKigoId = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => HaikuCompanion(
                id: id,
                body: body,
                maegaki: maegaki,
                kigoId: kigoId,
                season: season,
                composedOn: composedOn,
                themeKigoId: themeKigoId,
                memo: memo,
                favorite: favorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String body,
                Value<String> maegaki = const Value.absent(),
                Value<int?> kigoId = const Value.absent(),
                Value<String> season = const Value.absent(),
                required DateTime composedOn,
                Value<int?> themeKigoId = const Value.absent(),
                Value<String> memo = const Value.absent(),
                Value<bool> favorite = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => HaikuCompanion.insert(
                id: id,
                body: body,
                maegaki: maegaki,
                kigoId: kigoId,
                season: season,
                composedOn: composedOn,
                themeKigoId: themeKigoId,
                memo: memo,
                favorite: favorite,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HaikuTable, HaikuRow>(table),
                  $$HaikuTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({haikuRevisionRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (haikuRevisionRefs) db.haikuRevision,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (haikuRevisionRefs)
                    await $_getPrefetchedDataByColumns<
                      HaikuRow,
                      $HaikuTable,
                      HaikuRevisionRow,
                      $HaikuRevisionTable
                    >(
                      currentTable: table,
                      referencedTable: $$HaikuTableReferences
                          ._haikuRevisionRefsTable(db),
                      managerFromTypedResult: (p0) => $$HaikuTableReferences(
                        db,
                        table,
                        p0,
                      ).haikuRevisionRefs,
                      currentColumn: 'id',
                      referencedColumn: 'haiku_id',
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$HaikuTableProcessedTableManager =
    ProcessedTableManager<
      _$TanzakuDatabase,
      $HaikuTable,
      HaikuRow,
      $$HaikuTableFilterComposer,
      $$HaikuTableOrderingComposer,
      $$HaikuTableAnnotationComposer,
      $$HaikuTableCreateCompanionBuilder,
      $$HaikuTableUpdateCompanionBuilder,
      (HaikuRow, $$HaikuTableReferences),
      HaikuRow,
      PrefetchHooks Function({bool haikuRevisionRefs})
    >;
typedef $$HaikuRevisionTableCreateCompanionBuilder =
    HaikuRevisionCompanion Function({
      Value<int> id,
      required int haikuId,
      required String body,
      required DateTime savedAt,
    });
typedef $$HaikuRevisionTableUpdateCompanionBuilder =
    HaikuRevisionCompanion Function({
      Value<int> id,
      Value<int> haikuId,
      Value<String> body,
      Value<DateTime> savedAt,
    });

final class $$HaikuRevisionTableReferences
    extends
        BaseReferences<
          _$TanzakuDatabase,
          $HaikuRevisionTable,
          HaikuRevisionRow
        > {
  $$HaikuRevisionTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $HaikuTable _haikuIdTable(_$TanzakuDatabase db) =>
      db.haiku.createAlias('haiku_revision__haiku_id__haiku__id');

  $$HaikuTableProcessedTableManager get haikuId {
    final $_column = $_itemColumn<int>('haiku_id')!;

    final manager = $$HaikuTableTableManager(
      $_db,
      $_db.haiku,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_haikuIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$HaikuRevisionTableFilterComposer
    extends Composer<_$TanzakuDatabase, $HaikuRevisionTable> {
  $$HaikuRevisionTableFilterComposer({
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

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$HaikuTableFilterComposer get haikuId {
    final $$HaikuTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haikuId,
      referencedTable: $db.haiku,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaikuTableFilterComposer(
            $db: $db,
            $table: $db.haiku,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HaikuRevisionTableOrderingComposer
    extends Composer<_$TanzakuDatabase, $HaikuRevisionTable> {
  $$HaikuRevisionTableOrderingComposer({
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

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get savedAt => $composableBuilder(
    column: $table.savedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$HaikuTableOrderingComposer get haikuId {
    final $$HaikuTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haikuId,
      referencedTable: $db.haiku,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaikuTableOrderingComposer(
            $db: $db,
            $table: $db.haiku,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HaikuRevisionTableAnnotationComposer
    extends Composer<_$TanzakuDatabase, $HaikuRevisionTable> {
  $$HaikuRevisionTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get savedAt =>
      $composableBuilder(column: $table.savedAt, builder: (column) => column);

  $$HaikuTableAnnotationComposer get haikuId {
    final $$HaikuTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.haikuId,
      referencedTable: $db.haiku,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$HaikuTableAnnotationComposer(
            $db: $db,
            $table: $db.haiku,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$HaikuRevisionTableTableManager
    extends
        RootTableManager<
          _$TanzakuDatabase,
          $HaikuRevisionTable,
          HaikuRevisionRow,
          $$HaikuRevisionTableFilterComposer,
          $$HaikuRevisionTableOrderingComposer,
          $$HaikuRevisionTableAnnotationComposer,
          $$HaikuRevisionTableCreateCompanionBuilder,
          $$HaikuRevisionTableUpdateCompanionBuilder,
          (HaikuRevisionRow, $$HaikuRevisionTableReferences),
          HaikuRevisionRow,
          PrefetchHooks Function({bool haikuId})
        > {
  $$HaikuRevisionTableTableManager(
    _$TanzakuDatabase db,
    $HaikuRevisionTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HaikuRevisionTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HaikuRevisionTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HaikuRevisionTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> haikuId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> savedAt = const Value.absent(),
              }) => HaikuRevisionCompanion(
                id: id,
                haikuId: haikuId,
                body: body,
                savedAt: savedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int haikuId,
                required String body,
                required DateTime savedAt,
              }) => HaikuRevisionCompanion.insert(
                id: id,
                haikuId: haikuId,
                body: body,
                savedAt: savedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HaikuRevisionTable, HaikuRevisionRow>(table),
                  $$HaikuRevisionTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({haikuId = false}) {
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
                    if (haikuId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.haikuId,
                        referencedTable: $$HaikuRevisionTableReferences
                            ._haikuIdTable(db),
                        referencedColumn: $$HaikuRevisionTableReferences
                            ._haikuIdTable(db)
                            .id,
                      ) as T;
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

typedef $$HaikuRevisionTableProcessedTableManager =
    ProcessedTableManager<
      _$TanzakuDatabase,
      $HaikuRevisionTable,
      HaikuRevisionRow,
      $$HaikuRevisionTableFilterComposer,
      $$HaikuRevisionTableOrderingComposer,
      $$HaikuRevisionTableAnnotationComposer,
      $$HaikuRevisionTableCreateCompanionBuilder,
      $$HaikuRevisionTableUpdateCompanionBuilder,
      (HaikuRevisionRow, $$HaikuRevisionTableReferences),
      HaikuRevisionRow,
      PrefetchHooks Function({bool haikuId})
    >;
typedef $$KigoTableTableCreateCompanionBuilder = KigoTableCompanion Function({
  Value<int> id,
  required String word,
  required String reading,
  required String season,
  required String category,
  Value<String> period,
  required int startDay,
  required int endDay,
  required String description,
  Value<String> aliases,
  Value<String> examples,
});
typedef $$KigoTableTableUpdateCompanionBuilder = KigoTableCompanion Function({
  Value<int> id,
  Value<String> word,
  Value<String> reading,
  Value<String> season,
  Value<String> category,
  Value<String> period,
  Value<int> startDay,
  Value<int> endDay,
  Value<String> description,
  Value<String> aliases,
  Value<String> examples,
});

class $$KigoTableTableFilterComposer
    extends Composer<_$TanzakuDatabase, $KigoTableTable> {
  $$KigoTableTableFilterComposer({
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

  ColumnFilters<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnFilters(column),
  );
}

class $$KigoTableTableOrderingComposer
    extends Composer<_$TanzakuDatabase, $KigoTableTable> {
  $$KigoTableTableOrderingComposer({
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

  ColumnOrderings<String> get word => $composableBuilder(
    column: $table.word,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reading => $composableBuilder(
    column: $table.reading,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get season => $composableBuilder(
    column: $table.season,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get period => $composableBuilder(
    column: $table.period,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startDay => $composableBuilder(
    column: $table.startDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endDay => $composableBuilder(
    column: $table.endDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get aliases => $composableBuilder(
    column: $table.aliases,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get examples => $composableBuilder(
    column: $table.examples,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$KigoTableTableAnnotationComposer
    extends Composer<_$TanzakuDatabase, $KigoTableTable> {
  $$KigoTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get word =>
      $composableBuilder(column: $table.word, builder: (column) => column);

  GeneratedColumn<String> get reading =>
      $composableBuilder(column: $table.reading, builder: (column) => column);

  GeneratedColumn<String> get season =>
      $composableBuilder(column: $table.season, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get period =>
      $composableBuilder(column: $table.period, builder: (column) => column);

  GeneratedColumn<int> get startDay =>
      $composableBuilder(column: $table.startDay, builder: (column) => column);

  GeneratedColumn<int> get endDay =>
      $composableBuilder(column: $table.endDay, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get examples =>
      $composableBuilder(column: $table.examples, builder: (column) => column);
}

class $$KigoTableTableTableManager
    extends
        RootTableManager<
          _$TanzakuDatabase,
          $KigoTableTable,
          KigoRow,
          $$KigoTableTableFilterComposer,
          $$KigoTableTableOrderingComposer,
          $$KigoTableTableAnnotationComposer,
          $$KigoTableTableCreateCompanionBuilder,
          $$KigoTableTableUpdateCompanionBuilder,
          (
            KigoRow,
            BaseReferences<_$TanzakuDatabase, $KigoTableTable, KigoRow>,
          ),
          KigoRow,
          PrefetchHooks Function()
        > {
  $$KigoTableTableTableManager(_$TanzakuDatabase db, $KigoTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$KigoTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$KigoTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$KigoTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> word = const Value.absent(),
                Value<String> reading = const Value.absent(),
                Value<String> season = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> period = const Value.absent(),
                Value<int> startDay = const Value.absent(),
                Value<int> endDay = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> aliases = const Value.absent(),
                Value<String> examples = const Value.absent(),
              }) => KigoTableCompanion(
                id: id,
                word: word,
                reading: reading,
                season: season,
                category: category,
                period: period,
                startDay: startDay,
                endDay: endDay,
                description: description,
                aliases: aliases,
                examples: examples,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String word,
                required String reading,
                required String season,
                required String category,
                Value<String> period = const Value.absent(),
                required int startDay,
                required int endDay,
                required String description,
                Value<String> aliases = const Value.absent(),
                Value<String> examples = const Value.absent(),
              }) => KigoTableCompanion.insert(
                id: id,
                word: word,
                reading: reading,
                season: season,
                category: category,
                period: period,
                startDay: startDay,
                endDay: endDay,
                description: description,
                aliases: aliases,
                examples: examples,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$KigoTableTable, KigoRow>(table),
                  BaseReferences<_$TanzakuDatabase, $KigoTableTable, KigoRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$KigoTableTableProcessedTableManager =
    ProcessedTableManager<
      _$TanzakuDatabase,
      $KigoTableTable,
      KigoRow,
      $$KigoTableTableFilterComposer,
      $$KigoTableTableOrderingComposer,
      $$KigoTableTableAnnotationComposer,
      $$KigoTableTableCreateCompanionBuilder,
      $$KigoTableTableUpdateCompanionBuilder,
      (KigoRow, BaseReferences<_$TanzakuDatabase, $KigoTableTable, KigoRow>),
      KigoRow,
      PrefetchHooks Function()
    >;
typedef $$ThemeLogTableCreateCompanionBuilder = ThemeLogCompanion Function({
  required DateTime date,
  required int kigoId,
  Value<int> rowid,
});
typedef $$ThemeLogTableUpdateCompanionBuilder = ThemeLogCompanion Function({
  Value<DateTime> date,
  Value<int> kigoId,
  Value<int> rowid,
});

class $$ThemeLogTableFilterComposer
    extends Composer<_$TanzakuDatabase, $ThemeLogTable> {
  $$ThemeLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kigoId => $composableBuilder(
    column: $table.kigoId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ThemeLogTableOrderingComposer
    extends Composer<_$TanzakuDatabase, $ThemeLogTable> {
  $$ThemeLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kigoId => $composableBuilder(
    column: $table.kigoId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ThemeLogTableAnnotationComposer
    extends Composer<_$TanzakuDatabase, $ThemeLogTable> {
  $$ThemeLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get kigoId =>
      $composableBuilder(column: $table.kigoId, builder: (column) => column);
}

class $$ThemeLogTableTableManager
    extends
        RootTableManager<
          _$TanzakuDatabase,
          $ThemeLogTable,
          ThemeLogRow,
          $$ThemeLogTableFilterComposer,
          $$ThemeLogTableOrderingComposer,
          $$ThemeLogTableAnnotationComposer,
          $$ThemeLogTableCreateCompanionBuilder,
          $$ThemeLogTableUpdateCompanionBuilder,
          (
            ThemeLogRow,
            BaseReferences<_$TanzakuDatabase, $ThemeLogTable, ThemeLogRow>,
          ),
          ThemeLogRow,
          PrefetchHooks Function()
        > {
  $$ThemeLogTableTableManager(_$TanzakuDatabase db, $ThemeLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ThemeLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ThemeLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ThemeLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<DateTime> date = const Value.absent(),
            Value<int> kigoId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => ThemeLogCompanion(date: date, kigoId: kigoId, rowid: rowid),
          createCompanionCallback:
              ({
                required DateTime date,
                required int kigoId,
                Value<int> rowid = const Value.absent(),
              }) => ThemeLogCompanion.insert(
                date: date,
                kigoId: kigoId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ThemeLogTable, ThemeLogRow>(table),
                  BaseReferences<
                    _$TanzakuDatabase,
                    $ThemeLogTable,
                    ThemeLogRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ThemeLogTableProcessedTableManager =
    ProcessedTableManager<
      _$TanzakuDatabase,
      $ThemeLogTable,
      ThemeLogRow,
      $$ThemeLogTableFilterComposer,
      $$ThemeLogTableOrderingComposer,
      $$ThemeLogTableAnnotationComposer,
      $$ThemeLogTableCreateCompanionBuilder,
      $$ThemeLogTableUpdateCompanionBuilder,
      (
        ThemeLogRow,
        BaseReferences<_$TanzakuDatabase, $ThemeLogTable, ThemeLogRow>,
      ),
      ThemeLogRow,
      PrefetchHooks Function()
    >;

class $TanzakuDatabaseManager {
  final _$TanzakuDatabase _db;
  $TanzakuDatabaseManager(this._db);
  $$HaikuTableTableManager get haiku =>
      $$HaikuTableTableManager(_db, _db.haiku);
  $$HaikuRevisionTableTableManager get haikuRevision =>
      $$HaikuRevisionTableTableManager(_db, _db.haikuRevision);
  $$KigoTableTableTableManager get kigoTable =>
      $$KigoTableTableTableManager(_db, _db.kigoTable);
  $$ThemeLogTableTableManager get themeLog =>
      $$ThemeLogTableTableManager(_db, _db.themeLog);
}
