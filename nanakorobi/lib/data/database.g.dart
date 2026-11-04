// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DarumasTable extends Darumas with TableInfo<$DarumasTable, Daruma> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DarumasTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorIdMeta = const VerificationMeta(
    'colorId',
  );
  @override
  late final GeneratedColumn<int> colorId = GeneratedColumn<int>(
    'color_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EyeSide, String> eyeSide =
      GeneratedColumn<String>(
        'eye_side',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EyeSide>($DarumasTable.$convertereyeSide);
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
  late final GeneratedColumnWithTypeConverter<LocalDate, String> openedOn =
      GeneratedColumn<String>(
        'opened_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($DarumasTable.$converteropenedOn);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate?, String> deadline =
      GeneratedColumn<String>(
        'deadline',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<LocalDate?>($DarumasTable.$converterdeadlinen);
  static const VerificationMeta _deadlineNameMeta = const VerificationMeta(
    'deadlineName',
  );
  @override
  late final GeneratedColumn<String> deadlineName = GeneratedColumn<String>(
    'deadline_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlinePresetIdMeta = const VerificationMeta(
    'deadlinePresetId',
  );
  @override
  late final GeneratedColumn<String> deadlinePresetId = GeneratedColumn<String>(
    'deadline_preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dailyActionMeta = const VerificationMeta(
    'dailyAction',
  );
  @override
  late final GeneratedColumn<String> dailyAction = GeneratedColumn<String>(
    'daily_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DarumaStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DarumaStatus>($DarumasTable.$converterstatus);
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
  static const VerificationMeta _retiredAtMeta = const VerificationMeta(
    'retiredAt',
  );
  @override
  late final GeneratedColumn<DateTime> retiredAt = GeneratedColumn<DateTime>(
    'retired_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeRankMeta = const VerificationMeta(
    'sizeRank',
  );
  @override
  late final GeneratedColumn<int> sizeRank = GeneratedColumn<int>(
    'size_rank',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _askedAtDeadlineMeta = const VerificationMeta(
    'askedAtDeadline',
  );
  @override
  late final GeneratedColumn<bool> askedAtDeadline = GeneratedColumn<bool>(
    'asked_at_deadline',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("asked_at_deadline" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    colorId,
    eyeSide,
    createdAt,
    openedOn,
    deadline,
    deadlineName,
    deadlinePresetId,
    dailyAction,
    status,
    completedAt,
    retiredAt,
    sizeRank,
    parentId,
    seed,
    askedAtDeadline,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'darumas';
  @override
  VerificationContext validateIntegrity(
    Insertable<Daruma> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('color_id')) {
      context.handle(
        _colorIdMeta,
        colorId.isAcceptableOrUnknown(data['color_id']!, _colorIdMeta),
      );
    } else if (isInserting) {
      context.missing(_colorIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('deadline_name')) {
      context.handle(
        _deadlineNameMeta,
        deadlineName.isAcceptableOrUnknown(
          data['deadline_name']!,
          _deadlineNameMeta,
        ),
      );
    }
    if (data.containsKey('deadline_preset_id')) {
      context.handle(
        _deadlinePresetIdMeta,
        deadlinePresetId.isAcceptableOrUnknown(
          data['deadline_preset_id']!,
          _deadlinePresetIdMeta,
        ),
      );
    }
    if (data.containsKey('daily_action')) {
      context.handle(
        _dailyActionMeta,
        dailyAction.isAcceptableOrUnknown(
          data['daily_action']!,
          _dailyActionMeta,
        ),
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
    if (data.containsKey('retired_at')) {
      context.handle(
        _retiredAtMeta,
        retiredAt.isAcceptableOrUnknown(data['retired_at']!, _retiredAtMeta),
      );
    }
    if (data.containsKey('size_rank')) {
      context.handle(
        _sizeRankMeta,
        sizeRank.isAcceptableOrUnknown(data['size_rank']!, _sizeRankMeta),
      );
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('seed')) {
      context.handle(
        _seedMeta,
        seed.isAcceptableOrUnknown(data['seed']!, _seedMeta),
      );
    } else if (isInserting) {
      context.missing(_seedMeta);
    }
    if (data.containsKey('asked_at_deadline')) {
      context.handle(
        _askedAtDeadlineMeta,
        askedAtDeadline.isAcceptableOrUnknown(
          data['asked_at_deadline']!,
          _askedAtDeadlineMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Daruma map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Daruma(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      colorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color_id'],
      )!,
      eyeSide: $DarumasTable.$convertereyeSide.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}eye_side'],
        )!,
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      openedOn: $DarumasTable.$converteropenedOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}opened_on'],
        )!,
      ),
      deadline: $DarumasTable.$converterdeadlinen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}deadline'],
        ),
      ),
      deadlineName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline_name'],
      ),
      deadlinePresetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline_preset_id'],
      ),
      dailyAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_action'],
      ),
      status: $DarumasTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      ),
      retiredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}retired_at'],
      ),
      sizeRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_rank'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
      askedAtDeadline: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}asked_at_deadline'],
      )!,
    );
  }

  @override
  $DarumasTable createAlias(String alias) {
    return $DarumasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EyeSide, String, String> $convertereyeSide =
      const EnumNameConverter<EyeSide>(EyeSide.values);
  static TypeConverter<LocalDate, String> $converteropenedOn =
      const LocalDateConverter();
  static TypeConverter<LocalDate, String> $converterdeadline =
      const LocalDateConverter();
  static TypeConverter<LocalDate?, String?> $converterdeadlinen =
      NullAwareTypeConverter.wrap($converterdeadline);
  static JsonTypeConverter2<DarumaStatus, String, String> $converterstatus =
      const EnumNameConverter<DarumaStatus>(DarumaStatus.values);
}

class DarumasCompanion extends UpdateCompanion<Daruma> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> colorId;
  final Value<EyeSide> eyeSide;
  final Value<DateTime> createdAt;
  final Value<LocalDate> openedOn;
  final Value<LocalDate?> deadline;
  final Value<String?> deadlineName;
  final Value<String?> deadlinePresetId;
  final Value<String?> dailyAction;
  final Value<DarumaStatus> status;
  final Value<DateTime?> completedAt;
  final Value<DateTime?> retiredAt;
  final Value<int> sizeRank;
  final Value<String?> parentId;
  final Value<int> seed;
  final Value<bool> askedAtDeadline;
  final Value<int> rowid;
  const DarumasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.colorId = const Value.absent(),
    this.eyeSide = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.openedOn = const Value.absent(),
    this.deadline = const Value.absent(),
    this.deadlineName = const Value.absent(),
    this.deadlinePresetId = const Value.absent(),
    this.dailyAction = const Value.absent(),
    this.status = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.sizeRank = const Value.absent(),
    this.parentId = const Value.absent(),
    this.seed = const Value.absent(),
    this.askedAtDeadline = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DarumasCompanion.insert({
    required String id,
    required String name,
    required int colorId,
    required EyeSide eyeSide,
    required DateTime createdAt,
    required LocalDate openedOn,
    this.deadline = const Value.absent(),
    this.deadlineName = const Value.absent(),
    this.deadlinePresetId = const Value.absent(),
    this.dailyAction = const Value.absent(),
    required DarumaStatus status,
    this.completedAt = const Value.absent(),
    this.retiredAt = const Value.absent(),
    this.sizeRank = const Value.absent(),
    this.parentId = const Value.absent(),
    required int seed,
    this.askedAtDeadline = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       colorId = Value(colorId),
       eyeSide = Value(eyeSide),
       createdAt = Value(createdAt),
       openedOn = Value(openedOn),
       status = Value(status),
       seed = Value(seed);
  static Insertable<Daruma> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? colorId,
    Expression<String>? eyeSide,
    Expression<DateTime>? createdAt,
    Expression<String>? openedOn,
    Expression<String>? deadline,
    Expression<String>? deadlineName,
    Expression<String>? deadlinePresetId,
    Expression<String>? dailyAction,
    Expression<String>? status,
    Expression<DateTime>? completedAt,
    Expression<DateTime>? retiredAt,
    Expression<int>? sizeRank,
    Expression<String>? parentId,
    Expression<int>? seed,
    Expression<bool>? askedAtDeadline,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (colorId != null) 'color_id': colorId,
      if (eyeSide != null) 'eye_side': eyeSide,
      if (createdAt != null) 'created_at': createdAt,
      if (openedOn != null) 'opened_on': openedOn,
      if (deadline != null) 'deadline': deadline,
      if (deadlineName != null) 'deadline_name': deadlineName,
      if (deadlinePresetId != null) 'deadline_preset_id': deadlinePresetId,
      if (dailyAction != null) 'daily_action': dailyAction,
      if (status != null) 'status': status,
      if (completedAt != null) 'completed_at': completedAt,
      if (retiredAt != null) 'retired_at': retiredAt,
      if (sizeRank != null) 'size_rank': sizeRank,
      if (parentId != null) 'parent_id': parentId,
      if (seed != null) 'seed': seed,
      if (askedAtDeadline != null) 'asked_at_deadline': askedAtDeadline,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DarumasCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? colorId,
    Value<EyeSide>? eyeSide,
    Value<DateTime>? createdAt,
    Value<LocalDate>? openedOn,
    Value<LocalDate?>? deadline,
    Value<String?>? deadlineName,
    Value<String?>? deadlinePresetId,
    Value<String?>? dailyAction,
    Value<DarumaStatus>? status,
    Value<DateTime?>? completedAt,
    Value<DateTime?>? retiredAt,
    Value<int>? sizeRank,
    Value<String?>? parentId,
    Value<int>? seed,
    Value<bool>? askedAtDeadline,
    Value<int>? rowid,
  }) {
    return DarumasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      colorId: colorId ?? this.colorId,
      eyeSide: eyeSide ?? this.eyeSide,
      createdAt: createdAt ?? this.createdAt,
      openedOn: openedOn ?? this.openedOn,
      deadline: deadline ?? this.deadline,
      deadlineName: deadlineName ?? this.deadlineName,
      deadlinePresetId: deadlinePresetId ?? this.deadlinePresetId,
      dailyAction: dailyAction ?? this.dailyAction,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
      retiredAt: retiredAt ?? this.retiredAt,
      sizeRank: sizeRank ?? this.sizeRank,
      parentId: parentId ?? this.parentId,
      seed: seed ?? this.seed,
      askedAtDeadline: askedAtDeadline ?? this.askedAtDeadline,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (colorId.present) {
      map['color_id'] = Variable<int>(colorId.value);
    }
    if (eyeSide.present) {
      map['eye_side'] = Variable<String>(
        $DarumasTable.$convertereyeSide.toSql(eyeSide.value),
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (openedOn.present) {
      map['opened_on'] = Variable<String>(
        $DarumasTable.$converteropenedOn.toSql(openedOn.value),
      );
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(
        $DarumasTable.$converterdeadlinen.toSql(deadline.value),
      );
    }
    if (deadlineName.present) {
      map['deadline_name'] = Variable<String>(deadlineName.value);
    }
    if (deadlinePresetId.present) {
      map['deadline_preset_id'] = Variable<String>(deadlinePresetId.value);
    }
    if (dailyAction.present) {
      map['daily_action'] = Variable<String>(dailyAction.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $DarumasTable.$converterstatus.toSql(status.value),
      );
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (retiredAt.present) {
      map['retired_at'] = Variable<DateTime>(retiredAt.value);
    }
    if (sizeRank.present) {
      map['size_rank'] = Variable<int>(sizeRank.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    if (askedAtDeadline.present) {
      map['asked_at_deadline'] = Variable<bool>(askedAtDeadline.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DarumasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('colorId: $colorId, ')
          ..write('eyeSide: $eyeSide, ')
          ..write('createdAt: $createdAt, ')
          ..write('openedOn: $openedOn, ')
          ..write('deadline: $deadline, ')
          ..write('deadlineName: $deadlineName, ')
          ..write('deadlinePresetId: $deadlinePresetId, ')
          ..write('dailyAction: $dailyAction, ')
          ..write('status: $status, ')
          ..write('completedAt: $completedAt, ')
          ..write('retiredAt: $retiredAt, ')
          ..write('sizeRank: $sizeRank, ')
          ..write('parentId: $parentId, ')
          ..write('seed: $seed, ')
          ..write('askedAtDeadline: $askedAtDeadline, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$DarumaInsertable implements Insertable<Daruma> {
  Daruma _object;
  _$DarumaInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return DarumasCompanion(
      id: Value(_object.id),
      name: Value(_object.name),
      colorId: Value(_object.colorId),
      eyeSide: Value(_object.eyeSide),
      createdAt: Value(_object.createdAt),
      openedOn: Value(_object.openedOn),
      deadline: Value(_object.deadline),
      deadlineName: Value(_object.deadlineName),
      deadlinePresetId: Value(_object.deadlinePresetId),
      dailyAction: Value(_object.dailyAction),
      status: Value(_object.status),
      completedAt: Value(_object.completedAt),
      retiredAt: Value(_object.retiredAt),
      sizeRank: Value(_object.sizeRank),
      parentId: Value(_object.parentId),
      seed: Value(_object.seed),
      askedAtDeadline: Value(_object.askedAtDeadline),
    ).toColumns(false);
  }
}

extension DarumaToInsertable on Daruma {
  _$DarumaInsertable toInsertable() {
    return _$DarumaInsertable(this);
  }
}

class $MilestonesTable extends Milestones
    with TableInfo<$MilestonesTable, Milestone> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MilestonesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _darumaIdMeta = const VerificationMeta(
    'darumaId',
  );
  @override
  late final GeneratedColumn<String> darumaId = GeneratedColumn<String>(
    'daruma_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES darumas (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($MilestonesTable.$converterdate);
  static const VerificationMeta _presetIdMeta = const VerificationMeta(
    'presetId',
  );
  @override
  late final GeneratedColumn<String> presetId = GeneratedColumn<String>(
    'preset_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, darumaId, name, date, presetId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'milestones';
  @override
  VerificationContext validateIntegrity(
    Insertable<Milestone> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daruma_id')) {
      context.handle(
        _darumaIdMeta,
        darumaId.isAcceptableOrUnknown(data['daruma_id']!, _darumaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_darumaIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('preset_id')) {
      context.handle(
        _presetIdMeta,
        presetId.isAcceptableOrUnknown(data['preset_id']!, _presetIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Milestone map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Milestone(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      darumaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daruma_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: $MilestonesTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      presetId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preset_id'],
      ),
    );
  }

  @override
  $MilestonesTable createAlias(String alias) {
    return $MilestonesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter();
}

class MilestonesCompanion extends UpdateCompanion<Milestone> {
  final Value<String> id;
  final Value<String> darumaId;
  final Value<String> name;
  final Value<LocalDate> date;
  final Value<String?> presetId;
  final Value<int> rowid;
  const MilestonesCompanion({
    this.id = const Value.absent(),
    this.darumaId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.presetId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MilestonesCompanion.insert({
    required String id,
    required String darumaId,
    required String name,
    required LocalDate date,
    this.presetId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       darumaId = Value(darumaId),
       name = Value(name),
       date = Value(date);
  static Insertable<Milestone> custom({
    Expression<String>? id,
    Expression<String>? darumaId,
    Expression<String>? name,
    Expression<String>? date,
    Expression<String>? presetId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darumaId != null) 'daruma_id': darumaId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (presetId != null) 'preset_id': presetId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MilestonesCompanion copyWith({
    Value<String>? id,
    Value<String>? darumaId,
    Value<String>? name,
    Value<LocalDate>? date,
    Value<String?>? presetId,
    Value<int>? rowid,
  }) {
    return MilestonesCompanion(
      id: id ?? this.id,
      darumaId: darumaId ?? this.darumaId,
      name: name ?? this.name,
      date: date ?? this.date,
      presetId: presetId ?? this.presetId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (darumaId.present) {
      map['daruma_id'] = Variable<String>(darumaId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $MilestonesTable.$converterdate.toSql(date.value),
      );
    }
    if (presetId.present) {
      map['preset_id'] = Variable<String>(presetId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MilestonesCompanion(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('presetId: $presetId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$MilestoneInsertable implements Insertable<Milestone> {
  Milestone _object;
  _$MilestoneInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return MilestonesCompanion(
      id: Value(_object.id),
      darumaId: Value(_object.darumaId),
      name: Value(_object.name),
      date: Value(_object.date),
      presetId: Value(_object.presetId),
    ).toColumns(false);
  }
}

extension MilestoneToInsertable on Milestone {
  _$MilestoneInsertable toInsertable() {
    return _$MilestoneInsertable(this);
  }
}

class $CheckinsTable extends Checkins with TableInfo<$CheckinsTable, Checkin> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _darumaIdMeta = const VerificationMeta(
    'darumaId',
  );
  @override
  late final GeneratedColumn<String> darumaId = GeneratedColumn<String>(
    'daruma_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES darumas (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> date =
      GeneratedColumn<String>(
        'date',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($CheckinsTable.$converterdate);
  @override
  late final GeneratedColumnWithTypeConverter<CheckinKind, String> kind =
      GeneratedColumn<String>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<CheckinKind>($CheckinsTable.$converterkind);
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
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
    darumaId,
    date,
    kind,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<Checkin> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daruma_id')) {
      context.handle(
        _darumaIdMeta,
        darumaId.isAcceptableOrUnknown(data['daruma_id']!, _darumaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_darumaIdMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
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
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {darumaId, date},
  ];
  @override
  Checkin map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Checkin(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      darumaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daruma_id'],
      )!,
      date: $CheckinsTable.$converterdate.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}date'],
        )!,
      ),
      kind: $CheckinsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}kind'],
        )!,
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterdate =
      const LocalDateConverter();
  static JsonTypeConverter2<CheckinKind, String, String> $converterkind =
      const EnumNameConverter<CheckinKind>(CheckinKind.values);
}

class CheckinsCompanion extends UpdateCompanion<Checkin> {
  final Value<String> id;
  final Value<String> darumaId;
  final Value<LocalDate> date;
  final Value<CheckinKind> kind;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.darumaId = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CheckinsCompanion.insert({
    required String id,
    required String darumaId,
    required LocalDate date,
    required CheckinKind kind,
    this.memo = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       darumaId = Value(darumaId),
       date = Value(date),
       kind = Value(kind),
       createdAt = Value(createdAt);
  static Insertable<Checkin> custom({
    Expression<String>? id,
    Expression<String>? darumaId,
    Expression<String>? date,
    Expression<String>? kind,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darumaId != null) 'daruma_id': darumaId,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CheckinsCompanion copyWith({
    Value<String>? id,
    Value<String>? darumaId,
    Value<LocalDate>? date,
    Value<CheckinKind>? kind,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      darumaId: darumaId ?? this.darumaId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (darumaId.present) {
      map['daruma_id'] = Variable<String>(darumaId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(
        $CheckinsTable.$converterdate.toSql(date.value),
      );
    }
    if (kind.present) {
      map['kind'] = Variable<String>(
        $CheckinsTable.$converterkind.toSql(kind.value),
      );
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CheckinsCompanion(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$CheckinInsertable implements Insertable<Checkin> {
  Checkin _object;
  _$CheckinInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(_object.id),
      darumaId: Value(_object.darumaId),
      date: Value(_object.date),
      kind: Value(_object.kind),
      memo: Value(_object.memo),
      createdAt: Value(_object.createdAt),
    ).toColumns(false);
  }
}

extension CheckinToInsertable on Checkin {
  _$CheckinInsertable toInsertable() {
    return _$CheckinInsertable(this);
  }
}

class $RecoveriesTable extends Recoveries
    with TableInfo<$RecoveriesTable, Recovery> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _darumaIdMeta = const VerificationMeta(
    'darumaId',
  );
  @override
  late final GeneratedColumn<String> darumaId = GeneratedColumn<String>(
    'daruma_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES darumas (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> fellAfter =
      GeneratedColumn<String>(
        'fell_after',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($RecoveriesTable.$converterfellAfter);
  @override
  late final GeneratedColumnWithTypeConverter<LocalDate, String> roseOn =
      GeneratedColumn<String>(
        'rose_on',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<LocalDate>($RecoveriesTable.$converterroseOn);
  @override
  List<GeneratedColumn> get $columns => [id, darumaId, fellAfter, roseOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recoveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<Recovery> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('daruma_id')) {
      context.handle(
        _darumaIdMeta,
        darumaId.isAcceptableOrUnknown(data['daruma_id']!, _darumaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_darumaIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Recovery map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Recovery(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      darumaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daruma_id'],
      )!,
      fellAfter: $RecoveriesTable.$converterfellAfter.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}fell_after'],
        )!,
      ),
      roseOn: $RecoveriesTable.$converterroseOn.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}rose_on'],
        )!,
      ),
    );
  }

  @override
  $RecoveriesTable createAlias(String alias) {
    return $RecoveriesTable(attachedDatabase, alias);
  }

  static TypeConverter<LocalDate, String> $converterfellAfter =
      const LocalDateConverter();
  static TypeConverter<LocalDate, String> $converterroseOn =
      const LocalDateConverter();
}

class RecoveriesCompanion extends UpdateCompanion<Recovery> {
  final Value<String> id;
  final Value<String> darumaId;
  final Value<LocalDate> fellAfter;
  final Value<LocalDate> roseOn;
  final Value<int> rowid;
  const RecoveriesCompanion({
    this.id = const Value.absent(),
    this.darumaId = const Value.absent(),
    this.fellAfter = const Value.absent(),
    this.roseOn = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecoveriesCompanion.insert({
    required String id,
    required String darumaId,
    required LocalDate fellAfter,
    required LocalDate roseOn,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       darumaId = Value(darumaId),
       fellAfter = Value(fellAfter),
       roseOn = Value(roseOn);
  static Insertable<Recovery> custom({
    Expression<String>? id,
    Expression<String>? darumaId,
    Expression<String>? fellAfter,
    Expression<String>? roseOn,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darumaId != null) 'daruma_id': darumaId,
      if (fellAfter != null) 'fell_after': fellAfter,
      if (roseOn != null) 'rose_on': roseOn,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecoveriesCompanion copyWith({
    Value<String>? id,
    Value<String>? darumaId,
    Value<LocalDate>? fellAfter,
    Value<LocalDate>? roseOn,
    Value<int>? rowid,
  }) {
    return RecoveriesCompanion(
      id: id ?? this.id,
      darumaId: darumaId ?? this.darumaId,
      fellAfter: fellAfter ?? this.fellAfter,
      roseOn: roseOn ?? this.roseOn,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (darumaId.present) {
      map['daruma_id'] = Variable<String>(darumaId.value);
    }
    if (fellAfter.present) {
      map['fell_after'] = Variable<String>(
        $RecoveriesTable.$converterfellAfter.toSql(fellAfter.value),
      );
    }
    if (roseOn.present) {
      map['rose_on'] = Variable<String>(
        $RecoveriesTable.$converterroseOn.toSql(roseOn.value),
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveriesCompanion(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('fellAfter: $fellAfter, ')
          ..write('roseOn: $roseOn, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class _$RecoveryInsertable implements Insertable<Recovery> {
  Recovery _object;
  _$RecoveryInsertable(this._object);
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    return RecoveriesCompanion(
      id: Value(_object.id),
      darumaId: Value(_object.darumaId),
      fellAfter: Value(_object.fellAfter),
      roseOn: Value(_object.roseOn),
    ).toColumns(false);
  }
}

extension RecoveryToInsertable on Recovery {
  _$RecoveryInsertable toInsertable() {
    return _$RecoveryInsertable(this);
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DarumasTable darumas = $DarumasTable(this);
  late final $MilestonesTable milestones = $MilestonesTable(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final $RecoveriesTable recoveries = $RecoveriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    darumas,
    milestones,
    checkins,
    recoveries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'darumas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('milestones', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'darumas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('checkins', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'darumas',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('recoveries', kind: UpdateKind.delete)],
    ),
  ]);
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$DarumasTableCreateCompanionBuilder = DarumasCompanion Function({
  required String id,
  required String name,
  required int colorId,
  required EyeSide eyeSide,
  required DateTime createdAt,
  required LocalDate openedOn,
  Value<LocalDate?> deadline,
  Value<String?> deadlineName,
  Value<String?> deadlinePresetId,
  Value<String?> dailyAction,
  required DarumaStatus status,
  Value<DateTime?> completedAt,
  Value<DateTime?> retiredAt,
  Value<int> sizeRank,
  Value<String?> parentId,
  required int seed,
  Value<bool> askedAtDeadline,
  Value<int> rowid,
});
typedef $$DarumasTableUpdateCompanionBuilder = DarumasCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int> colorId,
  Value<EyeSide> eyeSide,
  Value<DateTime> createdAt,
  Value<LocalDate> openedOn,
  Value<LocalDate?> deadline,
  Value<String?> deadlineName,
  Value<String?> deadlinePresetId,
  Value<String?> dailyAction,
  Value<DarumaStatus> status,
  Value<DateTime?> completedAt,
  Value<DateTime?> retiredAt,
  Value<int> sizeRank,
  Value<String?> parentId,
  Value<int> seed,
  Value<bool> askedAtDeadline,
  Value<int> rowid,
});

final class $$DarumasTableReferences
    extends BaseReferences<_$AppDatabase, $DarumasTable, Daruma> {
  $$DarumasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MilestonesTable, List<Milestone>>
  _milestonesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.milestones,
    aliasName: 'darumas__id__milestones__daruma_id',
  );

  $$MilestonesTableProcessedTableManager get milestonesRefs {
    final manager = $$MilestonesTableTableManager(
      $_db,
      $_db.milestones,
    ).filter((f) => f.darumaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_milestonesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$CheckinsTable, List<Checkin>> _checkinsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.checkins,
    aliasName: 'darumas__id__checkins__daruma_id',
  );

  $$CheckinsTableProcessedTableManager get checkinsRefs {
    final manager = $$CheckinsTableTableManager(
      $_db,
      $_db.checkins,
    ).filter((f) => f.darumaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkinsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecoveriesTable, List<Recovery>>
  _recoveriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recoveries,
    aliasName: 'darumas__id__recoveries__daruma_id',
  );

  $$RecoveriesTableProcessedTableManager get recoveriesRefs {
    final manager = $$RecoveriesTableTableManager(
      $_db,
      $_db.recoveries,
    ).filter((f) => f.darumaId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_recoveriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DarumasTableFilterComposer
    extends Composer<_$AppDatabase, $DarumasTable> {
  $$DarumasTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EyeSide, EyeSide, String> get eyeSide =>
      $composableBuilder(
        column: $table.eyeSide,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get openedOn =>
      $composableBuilder(
        column: $table.openedOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate?, LocalDate, String> get deadline =>
      $composableBuilder(
        column: $table.deadline,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get deadlineName => $composableBuilder(
    column: $table.deadlineName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadlinePresetId => $composableBuilder(
    column: $table.deadlinePresetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DarumaStatus, DarumaStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeRank => $composableBuilder(
    column: $table.sizeRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get askedAtDeadline => $composableBuilder(
    column: $table.askedAtDeadline,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> milestonesRefs(
    Expression<bool> Function($$MilestonesTableFilterComposer f) f,
  ) {
    final $$MilestonesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableFilterComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> checkinsRefs(
    Expression<bool> Function($$CheckinsTableFilterComposer f) f,
  ) {
    final $$CheckinsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkins,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckinsTableFilterComposer(
            $db: $db,
            $table: $db.checkins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> recoveriesRefs(
    Expression<bool> Function($$RecoveriesTableFilterComposer f) f,
  ) {
    final $$RecoveriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recoveries,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecoveriesTableFilterComposer(
            $db: $db,
            $table: $db.recoveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DarumasTableOrderingComposer
    extends Composer<_$AppDatabase, $DarumasTable> {
  $$DarumasTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get colorId => $composableBuilder(
    column: $table.colorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eyeSide => $composableBuilder(
    column: $table.eyeSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get openedOn => $composableBuilder(
    column: $table.openedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineName => $composableBuilder(
    column: $table.deadlineName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlinePresetId => $composableBuilder(
    column: $table.deadlinePresetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get retiredAt => $composableBuilder(
    column: $table.retiredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeRank => $composableBuilder(
    column: $table.sizeRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get askedAtDeadline => $composableBuilder(
    column: $table.askedAtDeadline,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DarumasTableAnnotationComposer
    extends Composer<_$AppDatabase, $DarumasTable> {
  $$DarumasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get colorId =>
      $composableBuilder(column: $table.colorId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EyeSide, String> get eyeSide =>
      $composableBuilder(column: $table.eyeSide, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get openedOn =>
      $composableBuilder(column: $table.openedOn, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate?, String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get deadlineName => $composableBuilder(
    column: $table.deadlineName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deadlinePresetId => $composableBuilder(
    column: $table.deadlinePresetId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DarumaStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get retiredAt =>
      $composableBuilder(column: $table.retiredAt, builder: (column) => column);

  GeneratedColumn<int> get sizeRank =>
      $composableBuilder(column: $table.sizeRank, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

  GeneratedColumn<bool> get askedAtDeadline => $composableBuilder(
    column: $table.askedAtDeadline,
    builder: (column) => column,
  );

  Expression<T> milestonesRefs<T extends Object>(
    Expression<T> Function($$MilestonesTableAnnotationComposer a) f,
  ) {
    final $$MilestonesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.milestones,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MilestonesTableAnnotationComposer(
            $db: $db,
            $table: $db.milestones,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> checkinsRefs<T extends Object>(
    Expression<T> Function($$CheckinsTableAnnotationComposer a) f,
  ) {
    final $$CheckinsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.checkins,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CheckinsTableAnnotationComposer(
            $db: $db,
            $table: $db.checkins,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> recoveriesRefs<T extends Object>(
    Expression<T> Function($$RecoveriesTableAnnotationComposer a) f,
  ) {
    final $$RecoveriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.recoveries,
      getReferencedColumn: (t) => t.darumaId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RecoveriesTableAnnotationComposer(
            $db: $db,
            $table: $db.recoveries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DarumasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DarumasTable,
          Daruma,
          $$DarumasTableFilterComposer,
          $$DarumasTableOrderingComposer,
          $$DarumasTableAnnotationComposer,
          $$DarumasTableCreateCompanionBuilder,
          $$DarumasTableUpdateCompanionBuilder,
          (Daruma, $$DarumasTableReferences),
          Daruma,
          PrefetchHooks Function({
            bool milestonesRefs,
            bool checkinsRefs,
            bool recoveriesRefs,
          })
        > {
  $$DarumasTableTableManager(_$AppDatabase db, $DarumasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DarumasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DarumasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DarumasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> colorId = const Value.absent(),
                Value<EyeSide> eyeSide = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<LocalDate> openedOn = const Value.absent(),
                Value<LocalDate?> deadline = const Value.absent(),
                Value<String?> deadlineName = const Value.absent(),
                Value<String?> deadlinePresetId = const Value.absent(),
                Value<String?> dailyAction = const Value.absent(),
                Value<DarumaStatus> status = const Value.absent(),
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> sizeRank = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<int> seed = const Value.absent(),
                Value<bool> askedAtDeadline = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DarumasCompanion(
                id: id,
                name: name,
                colorId: colorId,
                eyeSide: eyeSide,
                createdAt: createdAt,
                openedOn: openedOn,
                deadline: deadline,
                deadlineName: deadlineName,
                deadlinePresetId: deadlinePresetId,
                dailyAction: dailyAction,
                status: status,
                completedAt: completedAt,
                retiredAt: retiredAt,
                sizeRank: sizeRank,
                parentId: parentId,
                seed: seed,
                askedAtDeadline: askedAtDeadline,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int colorId,
                required EyeSide eyeSide,
                required DateTime createdAt,
                required LocalDate openedOn,
                Value<LocalDate?> deadline = const Value.absent(),
                Value<String?> deadlineName = const Value.absent(),
                Value<String?> deadlinePresetId = const Value.absent(),
                Value<String?> dailyAction = const Value.absent(),
                required DarumaStatus status,
                Value<DateTime?> completedAt = const Value.absent(),
                Value<DateTime?> retiredAt = const Value.absent(),
                Value<int> sizeRank = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                required int seed,
                Value<bool> askedAtDeadline = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DarumasCompanion.insert(
                id: id,
                name: name,
                colorId: colorId,
                eyeSide: eyeSide,
                createdAt: createdAt,
                openedOn: openedOn,
                deadline: deadline,
                deadlineName: deadlineName,
                deadlinePresetId: deadlinePresetId,
                dailyAction: dailyAction,
                status: status,
                completedAt: completedAt,
                retiredAt: retiredAt,
                sizeRank: sizeRank,
                parentId: parentId,
                seed: seed,
                askedAtDeadline: askedAtDeadline,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DarumasTable, Daruma>(table),
                  $$DarumasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                milestonesRefs = false,
                checkinsRefs = false,
                recoveriesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (milestonesRefs) db.milestones,
                    if (checkinsRefs) db.checkins,
                    if (recoveriesRefs) db.recoveries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (milestonesRefs)
                        await $_getPrefetchedDataByColumns<
                          Daruma,
                          $DarumasTable,
                          Milestone,
                          $MilestonesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DarumasTableReferences
                              ._milestonesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DarumasTableReferences(
                                db,
                                table,
                                p0,
                              ).milestonesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'daruma_id',
                          typedResults: items,
                        ),
                      if (checkinsRefs)
                        await $_getPrefetchedDataByColumns<
                          Daruma,
                          $DarumasTable,
                          Checkin,
                          $CheckinsTable
                        >(
                          currentTable: table,
                          referencedTable: $$DarumasTableReferences
                              ._checkinsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DarumasTableReferences(
                                db,
                                table,
                                p0,
                              ).checkinsRefs,
                          currentColumn: 'id',
                          referencedColumn: 'daruma_id',
                          typedResults: items,
                        ),
                      if (recoveriesRefs)
                        await $_getPrefetchedDataByColumns<
                          Daruma,
                          $DarumasTable,
                          Recovery,
                          $RecoveriesTable
                        >(
                          currentTable: table,
                          referencedTable: $$DarumasTableReferences
                              ._recoveriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DarumasTableReferences(
                                db,
                                table,
                                p0,
                              ).recoveriesRefs,
                          currentColumn: 'id',
                          referencedColumn: 'daruma_id',
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DarumasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DarumasTable,
      Daruma,
      $$DarumasTableFilterComposer,
      $$DarumasTableOrderingComposer,
      $$DarumasTableAnnotationComposer,
      $$DarumasTableCreateCompanionBuilder,
      $$DarumasTableUpdateCompanionBuilder,
      (Daruma, $$DarumasTableReferences),
      Daruma,
      PrefetchHooks Function({
        bool milestonesRefs,
        bool checkinsRefs,
        bool recoveriesRefs,
      })
    >;
typedef $$MilestonesTableCreateCompanionBuilder = MilestonesCompanion Function({
  required String id,
  required String darumaId,
  required String name,
  required LocalDate date,
  Value<String?> presetId,
  Value<int> rowid,
});
typedef $$MilestonesTableUpdateCompanionBuilder = MilestonesCompanion Function({
  Value<String> id,
  Value<String> darumaId,
  Value<String> name,
  Value<LocalDate> date,
  Value<String?> presetId,
  Value<int> rowid,
});

final class $$MilestonesTableReferences
    extends BaseReferences<_$AppDatabase, $MilestonesTable, Milestone> {
  $$MilestonesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DarumasTable _darumaIdTable(_$AppDatabase db) =>
      db.darumas.createAlias('milestones__daruma_id__darumas__id');

  $$DarumasTableProcessedTableManager get darumaId {
    final $_column = $_itemColumn<String>('daruma_id')!;

    final manager = $$DarumasTableTableManager(
      $_db,
      $_db.darumas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_darumaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MilestonesTableFilterComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnFilters(column),
  );

  $$DarumasTableFilterComposer get darumaId {
    final $$DarumasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableFilterComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableOrderingComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get presetId => $composableBuilder(
    column: $table.presetId,
    builder: (column) => ColumnOrderings(column),
  );

  $$DarumasTableOrderingComposer get darumaId {
    final $$DarumasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableOrderingComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MilestonesTable> {
  $$MilestonesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get presetId =>
      $composableBuilder(column: $table.presetId, builder: (column) => column);

  $$DarumasTableAnnotationComposer get darumaId {
    final $$DarumasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableAnnotationComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MilestonesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MilestonesTable,
          Milestone,
          $$MilestonesTableFilterComposer,
          $$MilestonesTableOrderingComposer,
          $$MilestonesTableAnnotationComposer,
          $$MilestonesTableCreateCompanionBuilder,
          $$MilestonesTableUpdateCompanionBuilder,
          (Milestone, $$MilestonesTableReferences),
          Milestone,
          PrefetchHooks Function({bool darumaId})
        > {
  $$MilestonesTableTableManager(_$AppDatabase db, $MilestonesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MilestonesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MilestonesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MilestonesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> darumaId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<String?> presetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion(
                id: id,
                darumaId: darumaId,
                name: name,
                date: date,
                presetId: presetId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String darumaId,
                required String name,
                required LocalDate date,
                Value<String?> presetId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MilestonesCompanion.insert(
                id: id,
                darumaId: darumaId,
                name: name,
                date: date,
                presetId: presetId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MilestonesTable, Milestone>(table),
                  $$MilestonesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({darumaId = false}) {
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
                    if (darumaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.darumaId,
                        referencedTable: $$MilestonesTableReferences
                            ._darumaIdTable(db),
                        referencedColumn: $$MilestonesTableReferences
                            ._darumaIdTable(db)
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

typedef $$MilestonesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MilestonesTable,
      Milestone,
      $$MilestonesTableFilterComposer,
      $$MilestonesTableOrderingComposer,
      $$MilestonesTableAnnotationComposer,
      $$MilestonesTableCreateCompanionBuilder,
      $$MilestonesTableUpdateCompanionBuilder,
      (Milestone, $$MilestonesTableReferences),
      Milestone,
      PrefetchHooks Function({bool darumaId})
    >;
typedef $$CheckinsTableCreateCompanionBuilder = CheckinsCompanion Function({
  required String id,
  required String darumaId,
  required LocalDate date,
  required CheckinKind kind,
  Value<String?> memo,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$CheckinsTableUpdateCompanionBuilder = CheckinsCompanion Function({
  Value<String> id,
  Value<String> darumaId,
  Value<LocalDate> date,
  Value<CheckinKind> kind,
  Value<String?> memo,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$CheckinsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckinsTable, Checkin> {
  $$CheckinsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DarumasTable _darumaIdTable(_$AppDatabase db) =>
      db.darumas.createAlias('checkins__daruma_id__darumas__id');

  $$DarumasTableProcessedTableManager get darumaId {
    final $_column = $_itemColumn<String>('daruma_id')!;

    final manager = $$DarumasTableTableManager(
      $_db,
      $_db.darumas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_darumaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CheckinsTableFilterComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get date =>
      $composableBuilder(
        column: $table.date,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<CheckinKind, CheckinKind, String> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DarumasTableFilterComposer get darumaId {
    final $$DarumasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableFilterComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinsTableOrderingComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DarumasTableOrderingComposer get darumaId {
    final $$DarumasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableOrderingComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CheckinsTable> {
  $$CheckinsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckinKind, String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DarumasTableAnnotationComposer get darumaId {
    final $$DarumasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableAnnotationComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CheckinsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CheckinsTable,
          Checkin,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (Checkin, $$CheckinsTableReferences),
          Checkin,
          PrefetchHooks Function({bool darumaId})
        > {
  $$CheckinsTableTableManager(_$AppDatabase db, $CheckinsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CheckinsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CheckinsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CheckinsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> darumaId = const Value.absent(),
                Value<LocalDate> date = const Value.absent(),
                Value<CheckinKind> kind = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion(
                id: id,
                darumaId: darumaId,
                date: date,
                kind: kind,
                memo: memo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String darumaId,
                required LocalDate date,
                required CheckinKind kind,
                Value<String?> memo = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => CheckinsCompanion.insert(
                id: id,
                darumaId: darumaId,
                date: date,
                kind: kind,
                memo: memo,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckinsTable, Checkin>(table),
                  $$CheckinsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({darumaId = false}) {
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
                    if (darumaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.darumaId,
                        referencedTable: $$CheckinsTableReferences
                            ._darumaIdTable(db),
                        referencedColumn: $$CheckinsTableReferences
                            ._darumaIdTable(db)
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

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      Checkin,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (Checkin, $$CheckinsTableReferences),
      Checkin,
      PrefetchHooks Function({bool darumaId})
    >;
typedef $$RecoveriesTableCreateCompanionBuilder = RecoveriesCompanion Function({
  required String id,
  required String darumaId,
  required LocalDate fellAfter,
  required LocalDate roseOn,
  Value<int> rowid,
});
typedef $$RecoveriesTableUpdateCompanionBuilder = RecoveriesCompanion Function({
  Value<String> id,
  Value<String> darumaId,
  Value<LocalDate> fellAfter,
  Value<LocalDate> roseOn,
  Value<int> rowid,
});

final class $$RecoveriesTableReferences
    extends BaseReferences<_$AppDatabase, $RecoveriesTable, Recovery> {
  $$RecoveriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DarumasTable _darumaIdTable(_$AppDatabase db) =>
      db.darumas.createAlias('recoveries__daruma_id__darumas__id');

  $$DarumasTableProcessedTableManager get darumaId {
    final $_column = $_itemColumn<String>('daruma_id')!;

    final manager = $$DarumasTableTableManager(
      $_db,
      $_db.darumas,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_darumaIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RecoveriesTableFilterComposer
    extends Composer<_$AppDatabase, $RecoveriesTable> {
  $$RecoveriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get fellAfter =>
      $composableBuilder(
        column: $table.fellAfter,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<LocalDate, LocalDate, String> get roseOn =>
      $composableBuilder(
        column: $table.roseOn,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  $$DarumasTableFilterComposer get darumaId {
    final $$DarumasTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableFilterComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecoveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoveriesTable> {
  $$RecoveriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fellAfter => $composableBuilder(
    column: $table.fellAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get roseOn => $composableBuilder(
    column: $table.roseOn,
    builder: (column) => ColumnOrderings(column),
  );

  $$DarumasTableOrderingComposer get darumaId {
    final $$DarumasTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableOrderingComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecoveriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecoveriesTable> {
  $$RecoveriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get fellAfter =>
      $composableBuilder(column: $table.fellAfter, builder: (column) => column);

  GeneratedColumnWithTypeConverter<LocalDate, String> get roseOn =>
      $composableBuilder(column: $table.roseOn, builder: (column) => column);

  $$DarumasTableAnnotationComposer get darumaId {
    final $$DarumasTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.darumaId,
      referencedTable: $db.darumas,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DarumasTableAnnotationComposer(
            $db: $db,
            $table: $db.darumas,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RecoveriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecoveriesTable,
          Recovery,
          $$RecoveriesTableFilterComposer,
          $$RecoveriesTableOrderingComposer,
          $$RecoveriesTableAnnotationComposer,
          $$RecoveriesTableCreateCompanionBuilder,
          $$RecoveriesTableUpdateCompanionBuilder,
          (Recovery, $$RecoveriesTableReferences),
          Recovery,
          PrefetchHooks Function({bool darumaId})
        > {
  $$RecoveriesTableTableManager(_$AppDatabase db, $RecoveriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecoveriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecoveriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecoveriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> darumaId = const Value.absent(),
                Value<LocalDate> fellAfter = const Value.absent(),
                Value<LocalDate> roseOn = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecoveriesCompanion(
                id: id,
                darumaId: darumaId,
                fellAfter: fellAfter,
                roseOn: roseOn,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String darumaId,
                required LocalDate fellAfter,
                required LocalDate roseOn,
                Value<int> rowid = const Value.absent(),
              }) => RecoveriesCompanion.insert(
                id: id,
                darumaId: darumaId,
                fellAfter: fellAfter,
                roseOn: roseOn,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecoveriesTable, Recovery>(table),
                  $$RecoveriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({darumaId = false}) {
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
                    if (darumaId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.darumaId,
                        referencedTable: $$RecoveriesTableReferences
                            ._darumaIdTable(db),
                        referencedColumn: $$RecoveriesTableReferences
                            ._darumaIdTable(db)
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

typedef $$RecoveriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveriesTable,
      Recovery,
      $$RecoveriesTableFilterComposer,
      $$RecoveriesTableOrderingComposer,
      $$RecoveriesTableAnnotationComposer,
      $$RecoveriesTableCreateCompanionBuilder,
      $$RecoveriesTableUpdateCompanionBuilder,
      (Recovery, $$RecoveriesTableReferences),
      Recovery,
      PrefetchHooks Function({bool darumaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DarumasTableTableManager get darumas =>
      $$DarumasTableTableManager(_db, _db.darumas);
  $$MilestonesTableTableManager get milestones =>
      $$MilestonesTableTableManager(_db, _db.milestones);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
  $$RecoveriesTableTableManager get recoveries =>
      $$RecoveriesTableTableManager(_db, _db.recoveries);
}
