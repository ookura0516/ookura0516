// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $DarumasTable extends Darumas with TableInfo<$DarumasTable, DarumaRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DarumasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 12,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<DarumaColor, int> color =
      GeneratedColumn<int>(
        'color',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DarumaColor>($DarumasTable.$convertercolor);
  @override
  late final GeneratedColumnWithTypeConverter<EyeSide, int> eyeSide =
      GeneratedColumn<int>(
        'eye_side',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<EyeSide>($DarumasTable.$convertereyeSide);
  static const VerificationMeta _createdOnMeta = const VerificationMeta(
    'createdOn',
  );
  @override
  late final GeneratedColumn<String> createdOn = GeneratedColumn<String>(
    'created_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deadlineMeta = const VerificationMeta(
    'deadline',
  );
  @override
  late final GeneratedColumn<String> deadline = GeneratedColumn<String>(
    'deadline',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deadlineLabelMeta = const VerificationMeta(
    'deadlineLabel',
  );
  @override
  late final GeneratedColumn<String> deadlineLabel = GeneratedColumn<String>(
    'deadline_label',
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
  late final GeneratedColumnWithTypeConverter<DarumaStatus, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<DarumaStatus>($DarumasTable.$converterstatus);
  static const VerificationMeta _completedOnMeta = const VerificationMeta(
    'completedOn',
  );
  @override
  late final GeneratedColumn<String> completedOn = GeneratedColumn<String>(
    'completed_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _retiredOnMeta = const VerificationMeta(
    'retiredOn',
  );
  @override
  late final GeneratedColumn<String> retiredOn = GeneratedColumn<String>(
    'retired_on',
    aliasedName,
    true,
    type: DriftSqlType.string,
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
  late final GeneratedColumn<int> parentId = GeneratedColumn<int>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _seedMeta = const VerificationMeta('seed');
  @override
  late final GeneratedColumn<int> seed = GeneratedColumn<int>(
    'seed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    color,
    eyeSide,
    createdOn,
    deadline,
    deadlineLabel,
    dailyAction,
    status,
    completedOn,
    retiredOn,
    sizeRank,
    parentId,
    seed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'darumas';
  @override
  VerificationContext validateIntegrity(
    Insertable<DarumaRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_on')) {
      context.handle(
        _createdOnMeta,
        createdOn.isAcceptableOrUnknown(data['created_on']!, _createdOnMeta),
      );
    } else if (isInserting) {
      context.missing(_createdOnMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(
        _deadlineMeta,
        deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta),
      );
    }
    if (data.containsKey('deadline_label')) {
      context.handle(
        _deadlineLabelMeta,
        deadlineLabel.isAcceptableOrUnknown(
          data['deadline_label']!,
          _deadlineLabelMeta,
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
    if (data.containsKey('completed_on')) {
      context.handle(
        _completedOnMeta,
        completedOn.isAcceptableOrUnknown(
          data['completed_on']!,
          _completedOnMeta,
        ),
      );
    }
    if (data.containsKey('retired_on')) {
      context.handle(
        _retiredOnMeta,
        retiredOn.isAcceptableOrUnknown(data['retired_on']!, _retiredOnMeta),
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
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DarumaRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DarumaRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      color: $DarumasTable.$convertercolor.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}color'],
        )!,
      ),
      eyeSide: $DarumasTable.$convertereyeSide.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}eye_side'],
        )!,
      ),
      createdOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}created_on'],
      )!,
      deadline: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline'],
      ),
      deadlineLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deadline_label'],
      ),
      dailyAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}daily_action'],
      ),
      status: $DarumasTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      completedOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}completed_on'],
      ),
      retiredOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retired_on'],
      ),
      sizeRank: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_rank'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_id'],
      ),
      seed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seed'],
      )!,
    );
  }

  @override
  $DarumasTable createAlias(String alias) {
    return $DarumasTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DarumaColor, int, int> $convertercolor =
      const EnumIndexConverter<DarumaColor>(DarumaColor.values);
  static JsonTypeConverter2<EyeSide, int, int> $convertereyeSide =
      const EnumIndexConverter<EyeSide>(EyeSide.values);
  static JsonTypeConverter2<DarumaStatus, int, int> $converterstatus =
      const EnumIndexConverter<DarumaStatus>(DarumaStatus.values);
}

class DarumaRow extends DataClass implements Insertable<DarumaRow> {
  final int id;
  final String name;
  final DarumaColor color;
  final EyeSide eyeSide;
  final String createdOn;
  final String? deadline;
  final String? deadlineLabel;
  final String? dailyAction;
  final DarumaStatus status;
  final String? completedOn;
  final String? retiredOn;
  final int sizeRank;
  final int? parentId;
  final int seed;
  const DarumaRow({
    required this.id,
    required this.name,
    required this.color,
    required this.eyeSide,
    required this.createdOn,
    this.deadline,
    this.deadlineLabel,
    this.dailyAction,
    required this.status,
    this.completedOn,
    this.retiredOn,
    required this.sizeRank,
    this.parentId,
    required this.seed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    {
      map['color'] = Variable<int>($DarumasTable.$convertercolor.toSql(color));
    }
    {
      map['eye_side'] = Variable<int>(
        $DarumasTable.$convertereyeSide.toSql(eyeSide),
      );
    }
    map['created_on'] = Variable<String>(createdOn);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<String>(deadline);
    }
    if (!nullToAbsent || deadlineLabel != null) {
      map['deadline_label'] = Variable<String>(deadlineLabel);
    }
    if (!nullToAbsent || dailyAction != null) {
      map['daily_action'] = Variable<String>(dailyAction);
    }
    {
      map['status'] = Variable<int>(
        $DarumasTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || completedOn != null) {
      map['completed_on'] = Variable<String>(completedOn);
    }
    if (!nullToAbsent || retiredOn != null) {
      map['retired_on'] = Variable<String>(retiredOn);
    }
    map['size_rank'] = Variable<int>(sizeRank);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<int>(parentId);
    }
    map['seed'] = Variable<int>(seed);
    return map;
  }

  DarumasCompanion toCompanion(bool nullToAbsent) {
    return DarumasCompanion(
      id: Value(id),
      name: Value(name),
      color: Value(color),
      eyeSide: Value(eyeSide),
      createdOn: Value(createdOn),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      deadlineLabel: deadlineLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(deadlineLabel),
      dailyAction: dailyAction == null && nullToAbsent
          ? const Value.absent()
          : Value(dailyAction),
      status: Value(status),
      completedOn: completedOn == null && nullToAbsent
          ? const Value.absent()
          : Value(completedOn),
      retiredOn: retiredOn == null && nullToAbsent
          ? const Value.absent()
          : Value(retiredOn),
      sizeRank: Value(sizeRank),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      seed: Value(seed),
    );
  }

  factory DarumaRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DarumaRow(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      color: $DarumasTable.$convertercolor.fromJson(
        serializer.fromJson<int>(json['color']),
      ),
      eyeSide: $DarumasTable.$convertereyeSide.fromJson(
        serializer.fromJson<int>(json['eyeSide']),
      ),
      createdOn: serializer.fromJson<String>(json['createdOn']),
      deadline: serializer.fromJson<String?>(json['deadline']),
      deadlineLabel: serializer.fromJson<String?>(json['deadlineLabel']),
      dailyAction: serializer.fromJson<String?>(json['dailyAction']),
      status: $DarumasTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      completedOn: serializer.fromJson<String?>(json['completedOn']),
      retiredOn: serializer.fromJson<String?>(json['retiredOn']),
      sizeRank: serializer.fromJson<int>(json['sizeRank']),
      parentId: serializer.fromJson<int?>(json['parentId']),
      seed: serializer.fromJson<int>(json['seed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'color': serializer.toJson<int>(
        $DarumasTable.$convertercolor.toJson(color),
      ),
      'eyeSide': serializer.toJson<int>(
        $DarumasTable.$convertereyeSide.toJson(eyeSide),
      ),
      'createdOn': serializer.toJson<String>(createdOn),
      'deadline': serializer.toJson<String?>(deadline),
      'deadlineLabel': serializer.toJson<String?>(deadlineLabel),
      'dailyAction': serializer.toJson<String?>(dailyAction),
      'status': serializer.toJson<int>(
        $DarumasTable.$converterstatus.toJson(status),
      ),
      'completedOn': serializer.toJson<String?>(completedOn),
      'retiredOn': serializer.toJson<String?>(retiredOn),
      'sizeRank': serializer.toJson<int>(sizeRank),
      'parentId': serializer.toJson<int?>(parentId),
      'seed': serializer.toJson<int>(seed),
    };
  }

  DarumaRow copyWith({
    int? id,
    String? name,
    DarumaColor? color,
    EyeSide? eyeSide,
    String? createdOn,
    Value<String?> deadline = const Value.absent(),
    Value<String?> deadlineLabel = const Value.absent(),
    Value<String?> dailyAction = const Value.absent(),
    DarumaStatus? status,
    Value<String?> completedOn = const Value.absent(),
    Value<String?> retiredOn = const Value.absent(),
    int? sizeRank,
    Value<int?> parentId = const Value.absent(),
    int? seed,
  }) => DarumaRow(
    id: id ?? this.id,
    name: name ?? this.name,
    color: color ?? this.color,
    eyeSide: eyeSide ?? this.eyeSide,
    createdOn: createdOn ?? this.createdOn,
    deadline: deadline.present ? deadline.value : this.deadline,
    deadlineLabel: deadlineLabel.present
        ? deadlineLabel.value
        : this.deadlineLabel,
    dailyAction: dailyAction.present ? dailyAction.value : this.dailyAction,
    status: status ?? this.status,
    completedOn: completedOn.present ? completedOn.value : this.completedOn,
    retiredOn: retiredOn.present ? retiredOn.value : this.retiredOn,
    sizeRank: sizeRank ?? this.sizeRank,
    parentId: parentId.present ? parentId.value : this.parentId,
    seed: seed ?? this.seed,
  );
  DarumaRow copyWithCompanion(DarumasCompanion data) {
    return DarumaRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      color: data.color.present ? data.color.value : this.color,
      eyeSide: data.eyeSide.present ? data.eyeSide.value : this.eyeSide,
      createdOn: data.createdOn.present ? data.createdOn.value : this.createdOn,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      deadlineLabel: data.deadlineLabel.present
          ? data.deadlineLabel.value
          : this.deadlineLabel,
      dailyAction: data.dailyAction.present
          ? data.dailyAction.value
          : this.dailyAction,
      status: data.status.present ? data.status.value : this.status,
      completedOn: data.completedOn.present
          ? data.completedOn.value
          : this.completedOn,
      retiredOn: data.retiredOn.present ? data.retiredOn.value : this.retiredOn,
      sizeRank: data.sizeRank.present ? data.sizeRank.value : this.sizeRank,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      seed: data.seed.present ? data.seed.value : this.seed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DarumaRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('eyeSide: $eyeSide, ')
          ..write('createdOn: $createdOn, ')
          ..write('deadline: $deadline, ')
          ..write('deadlineLabel: $deadlineLabel, ')
          ..write('dailyAction: $dailyAction, ')
          ..write('status: $status, ')
          ..write('completedOn: $completedOn, ')
          ..write('retiredOn: $retiredOn, ')
          ..write('sizeRank: $sizeRank, ')
          ..write('parentId: $parentId, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    color,
    eyeSide,
    createdOn,
    deadline,
    deadlineLabel,
    dailyAction,
    status,
    completedOn,
    retiredOn,
    sizeRank,
    parentId,
    seed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DarumaRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.color == this.color &&
          other.eyeSide == this.eyeSide &&
          other.createdOn == this.createdOn &&
          other.deadline == this.deadline &&
          other.deadlineLabel == this.deadlineLabel &&
          other.dailyAction == this.dailyAction &&
          other.status == this.status &&
          other.completedOn == this.completedOn &&
          other.retiredOn == this.retiredOn &&
          other.sizeRank == this.sizeRank &&
          other.parentId == this.parentId &&
          other.seed == this.seed);
}

class DarumasCompanion extends UpdateCompanion<DarumaRow> {
  final Value<int> id;
  final Value<String> name;
  final Value<DarumaColor> color;
  final Value<EyeSide> eyeSide;
  final Value<String> createdOn;
  final Value<String?> deadline;
  final Value<String?> deadlineLabel;
  final Value<String?> dailyAction;
  final Value<DarumaStatus> status;
  final Value<String?> completedOn;
  final Value<String?> retiredOn;
  final Value<int> sizeRank;
  final Value<int?> parentId;
  final Value<int> seed;
  const DarumasCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.color = const Value.absent(),
    this.eyeSide = const Value.absent(),
    this.createdOn = const Value.absent(),
    this.deadline = const Value.absent(),
    this.deadlineLabel = const Value.absent(),
    this.dailyAction = const Value.absent(),
    this.status = const Value.absent(),
    this.completedOn = const Value.absent(),
    this.retiredOn = const Value.absent(),
    this.sizeRank = const Value.absent(),
    this.parentId = const Value.absent(),
    this.seed = const Value.absent(),
  });
  DarumasCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DarumaColor color,
    required EyeSide eyeSide,
    required String createdOn,
    this.deadline = const Value.absent(),
    this.deadlineLabel = const Value.absent(),
    this.dailyAction = const Value.absent(),
    required DarumaStatus status,
    this.completedOn = const Value.absent(),
    this.retiredOn = const Value.absent(),
    this.sizeRank = const Value.absent(),
    this.parentId = const Value.absent(),
    this.seed = const Value.absent(),
  }) : name = Value(name),
       color = Value(color),
       eyeSide = Value(eyeSide),
       createdOn = Value(createdOn),
       status = Value(status);
  static Insertable<DarumaRow> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? color,
    Expression<int>? eyeSide,
    Expression<String>? createdOn,
    Expression<String>? deadline,
    Expression<String>? deadlineLabel,
    Expression<String>? dailyAction,
    Expression<int>? status,
    Expression<String>? completedOn,
    Expression<String>? retiredOn,
    Expression<int>? sizeRank,
    Expression<int>? parentId,
    Expression<int>? seed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (color != null) 'color': color,
      if (eyeSide != null) 'eye_side': eyeSide,
      if (createdOn != null) 'created_on': createdOn,
      if (deadline != null) 'deadline': deadline,
      if (deadlineLabel != null) 'deadline_label': deadlineLabel,
      if (dailyAction != null) 'daily_action': dailyAction,
      if (status != null) 'status': status,
      if (completedOn != null) 'completed_on': completedOn,
      if (retiredOn != null) 'retired_on': retiredOn,
      if (sizeRank != null) 'size_rank': sizeRank,
      if (parentId != null) 'parent_id': parentId,
      if (seed != null) 'seed': seed,
    });
  }

  DarumasCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DarumaColor>? color,
    Value<EyeSide>? eyeSide,
    Value<String>? createdOn,
    Value<String?>? deadline,
    Value<String?>? deadlineLabel,
    Value<String?>? dailyAction,
    Value<DarumaStatus>? status,
    Value<String?>? completedOn,
    Value<String?>? retiredOn,
    Value<int>? sizeRank,
    Value<int?>? parentId,
    Value<int>? seed,
  }) {
    return DarumasCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      eyeSide: eyeSide ?? this.eyeSide,
      createdOn: createdOn ?? this.createdOn,
      deadline: deadline ?? this.deadline,
      deadlineLabel: deadlineLabel ?? this.deadlineLabel,
      dailyAction: dailyAction ?? this.dailyAction,
      status: status ?? this.status,
      completedOn: completedOn ?? this.completedOn,
      retiredOn: retiredOn ?? this.retiredOn,
      sizeRank: sizeRank ?? this.sizeRank,
      parentId: parentId ?? this.parentId,
      seed: seed ?? this.seed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(
        $DarumasTable.$convertercolor.toSql(color.value),
      );
    }
    if (eyeSide.present) {
      map['eye_side'] = Variable<int>(
        $DarumasTable.$convertereyeSide.toSql(eyeSide.value),
      );
    }
    if (createdOn.present) {
      map['created_on'] = Variable<String>(createdOn.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<String>(deadline.value);
    }
    if (deadlineLabel.present) {
      map['deadline_label'] = Variable<String>(deadlineLabel.value);
    }
    if (dailyAction.present) {
      map['daily_action'] = Variable<String>(dailyAction.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $DarumasTable.$converterstatus.toSql(status.value),
      );
    }
    if (completedOn.present) {
      map['completed_on'] = Variable<String>(completedOn.value);
    }
    if (retiredOn.present) {
      map['retired_on'] = Variable<String>(retiredOn.value);
    }
    if (sizeRank.present) {
      map['size_rank'] = Variable<int>(sizeRank.value);
    }
    if (parentId.present) {
      map['parent_id'] = Variable<int>(parentId.value);
    }
    if (seed.present) {
      map['seed'] = Variable<int>(seed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DarumasCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('color: $color, ')
          ..write('eyeSide: $eyeSide, ')
          ..write('createdOn: $createdOn, ')
          ..write('deadline: $deadline, ')
          ..write('deadlineLabel: $deadlineLabel, ')
          ..write('dailyAction: $dailyAction, ')
          ..write('status: $status, ')
          ..write('completedOn: $completedOn, ')
          ..write('retiredOn: $retiredOn, ')
          ..write('sizeRank: $sizeRank, ')
          ..write('parentId: $parentId, ')
          ..write('seed: $seed')
          ..write(')'))
        .toString();
  }
}

class $CheckinsTable extends Checkins
    with TableInfo<$CheckinsTable, CheckinRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CheckinsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _darumaIdMeta = const VerificationMeta(
    'darumaId',
  );
  @override
  late final GeneratedColumn<int> darumaId = GeneratedColumn<int>(
    'daruma_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES darumas (id)',
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
  @override
  late final GeneratedColumnWithTypeConverter<CheckinKind, int> kind =
      GeneratedColumn<int>(
        'kind',
        aliasedName,
        false,
        type: DriftSqlType.int,
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
  @override
  List<GeneratedColumn> get $columns => [id, darumaId, date, kind, memo];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'checkins';
  @override
  VerificationContext validateIntegrity(
    Insertable<CheckinRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daruma_id')) {
      context.handle(
        _darumaIdMeta,
        darumaId.isAcceptableOrUnknown(data['daruma_id']!, _darumaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_darumaIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
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
  CheckinRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CheckinRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      darumaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daruma_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      kind: $CheckinsTable.$converterkind.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}kind'],
        )!,
      ),
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
    );
  }

  @override
  $CheckinsTable createAlias(String alias) {
    return $CheckinsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<CheckinKind, int, int> $converterkind =
      const EnumIndexConverter<CheckinKind>(CheckinKind.values);
}

class CheckinRow extends DataClass implements Insertable<CheckinRow> {
  final int id;
  final int darumaId;
  final String date;
  final CheckinKind kind;
  final String? memo;
  const CheckinRow({
    required this.id,
    required this.darumaId,
    required this.date,
    required this.kind,
    this.memo,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daruma_id'] = Variable<int>(darumaId);
    map['date'] = Variable<String>(date);
    {
      map['kind'] = Variable<int>($CheckinsTable.$converterkind.toSql(kind));
    }
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    return map;
  }

  CheckinsCompanion toCompanion(bool nullToAbsent) {
    return CheckinsCompanion(
      id: Value(id),
      darumaId: Value(darumaId),
      date: Value(date),
      kind: Value(kind),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
    );
  }

  factory CheckinRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CheckinRow(
      id: serializer.fromJson<int>(json['id']),
      darumaId: serializer.fromJson<int>(json['darumaId']),
      date: serializer.fromJson<String>(json['date']),
      kind: $CheckinsTable.$converterkind.fromJson(
        serializer.fromJson<int>(json['kind']),
      ),
      memo: serializer.fromJson<String?>(json['memo']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'darumaId': serializer.toJson<int>(darumaId),
      'date': serializer.toJson<String>(date),
      'kind': serializer.toJson<int>(
        $CheckinsTable.$converterkind.toJson(kind),
      ),
      'memo': serializer.toJson<String?>(memo),
    };
  }

  CheckinRow copyWith({
    int? id,
    int? darumaId,
    String? date,
    CheckinKind? kind,
    Value<String?> memo = const Value.absent(),
  }) => CheckinRow(
    id: id ?? this.id,
    darumaId: darumaId ?? this.darumaId,
    date: date ?? this.date,
    kind: kind ?? this.kind,
    memo: memo.present ? memo.value : this.memo,
  );
  CheckinRow copyWithCompanion(CheckinsCompanion data) {
    return CheckinRow(
      id: data.id.present ? data.id.value : this.id,
      darumaId: data.darumaId.present ? data.darumaId.value : this.darumaId,
      date: data.date.present ? data.date.value : this.date,
      kind: data.kind.present ? data.kind.value : this.kind,
      memo: data.memo.present ? data.memo.value : this.memo,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CheckinRow(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('date: $date, ')
          ..write('kind: $kind, ')
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, darumaId, date, kind, memo);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CheckinRow &&
          other.id == this.id &&
          other.darumaId == this.darumaId &&
          other.date == this.date &&
          other.kind == this.kind &&
          other.memo == this.memo);
}

class CheckinsCompanion extends UpdateCompanion<CheckinRow> {
  final Value<int> id;
  final Value<int> darumaId;
  final Value<String> date;
  final Value<CheckinKind> kind;
  final Value<String?> memo;
  const CheckinsCompanion({
    this.id = const Value.absent(),
    this.darumaId = const Value.absent(),
    this.date = const Value.absent(),
    this.kind = const Value.absent(),
    this.memo = const Value.absent(),
  });
  CheckinsCompanion.insert({
    this.id = const Value.absent(),
    required int darumaId,
    required String date,
    required CheckinKind kind,
    this.memo = const Value.absent(),
  }) : darumaId = Value(darumaId),
       date = Value(date),
       kind = Value(kind);
  static Insertable<CheckinRow> custom({
    Expression<int>? id,
    Expression<int>? darumaId,
    Expression<String>? date,
    Expression<int>? kind,
    Expression<String>? memo,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darumaId != null) 'daruma_id': darumaId,
      if (date != null) 'date': date,
      if (kind != null) 'kind': kind,
      if (memo != null) 'memo': memo,
    });
  }

  CheckinsCompanion copyWith({
    Value<int>? id,
    Value<int>? darumaId,
    Value<String>? date,
    Value<CheckinKind>? kind,
    Value<String?>? memo,
  }) {
    return CheckinsCompanion(
      id: id ?? this.id,
      darumaId: darumaId ?? this.darumaId,
      date: date ?? this.date,
      kind: kind ?? this.kind,
      memo: memo ?? this.memo,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (darumaId.present) {
      map['daruma_id'] = Variable<int>(darumaId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (kind.present) {
      map['kind'] = Variable<int>(
        $CheckinsTable.$converterkind.toSql(kind.value),
      );
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
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
          ..write('memo: $memo')
          ..write(')'))
        .toString();
  }
}

class $RecoveriesTable extends Recoveries
    with TableInfo<$RecoveriesTable, RecoveryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecoveriesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _darumaIdMeta = const VerificationMeta(
    'darumaId',
  );
  @override
  late final GeneratedColumn<int> darumaId = GeneratedColumn<int>(
    'daruma_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES darumas (id)',
    ),
  );
  static const VerificationMeta _fellAfterMeta = const VerificationMeta(
    'fellAfter',
  );
  @override
  late final GeneratedColumn<String> fellAfter = GeneratedColumn<String>(
    'fell_after',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roseOnMeta = const VerificationMeta('roseOn');
  @override
  late final GeneratedColumn<String> roseOn = GeneratedColumn<String>(
    'rose_on',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, darumaId, fellAfter, roseOn];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recoveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecoveryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('daruma_id')) {
      context.handle(
        _darumaIdMeta,
        darumaId.isAcceptableOrUnknown(data['daruma_id']!, _darumaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_darumaIdMeta);
    }
    if (data.containsKey('fell_after')) {
      context.handle(
        _fellAfterMeta,
        fellAfter.isAcceptableOrUnknown(data['fell_after']!, _fellAfterMeta),
      );
    } else if (isInserting) {
      context.missing(_fellAfterMeta);
    }
    if (data.containsKey('rose_on')) {
      context.handle(
        _roseOnMeta,
        roseOn.isAcceptableOrUnknown(data['rose_on']!, _roseOnMeta),
      );
    } else if (isInserting) {
      context.missing(_roseOnMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecoveryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecoveryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      darumaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}daruma_id'],
      )!,
      fellAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}fell_after'],
      )!,
      roseOn: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rose_on'],
      )!,
    );
  }

  @override
  $RecoveriesTable createAlias(String alias) {
    return $RecoveriesTable(attachedDatabase, alias);
  }
}

class RecoveryRow extends DataClass implements Insertable<RecoveryRow> {
  final int id;
  final int darumaId;
  final String fellAfter;
  final String roseOn;
  const RecoveryRow({
    required this.id,
    required this.darumaId,
    required this.fellAfter,
    required this.roseOn,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['daruma_id'] = Variable<int>(darumaId);
    map['fell_after'] = Variable<String>(fellAfter);
    map['rose_on'] = Variable<String>(roseOn);
    return map;
  }

  RecoveriesCompanion toCompanion(bool nullToAbsent) {
    return RecoveriesCompanion(
      id: Value(id),
      darumaId: Value(darumaId),
      fellAfter: Value(fellAfter),
      roseOn: Value(roseOn),
    );
  }

  factory RecoveryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecoveryRow(
      id: serializer.fromJson<int>(json['id']),
      darumaId: serializer.fromJson<int>(json['darumaId']),
      fellAfter: serializer.fromJson<String>(json['fellAfter']),
      roseOn: serializer.fromJson<String>(json['roseOn']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'darumaId': serializer.toJson<int>(darumaId),
      'fellAfter': serializer.toJson<String>(fellAfter),
      'roseOn': serializer.toJson<String>(roseOn),
    };
  }

  RecoveryRow copyWith({
    int? id,
    int? darumaId,
    String? fellAfter,
    String? roseOn,
  }) => RecoveryRow(
    id: id ?? this.id,
    darumaId: darumaId ?? this.darumaId,
    fellAfter: fellAfter ?? this.fellAfter,
    roseOn: roseOn ?? this.roseOn,
  );
  RecoveryRow copyWithCompanion(RecoveriesCompanion data) {
    return RecoveryRow(
      id: data.id.present ? data.id.value : this.id,
      darumaId: data.darumaId.present ? data.darumaId.value : this.darumaId,
      fellAfter: data.fellAfter.present ? data.fellAfter.value : this.fellAfter,
      roseOn: data.roseOn.present ? data.roseOn.value : this.roseOn,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecoveryRow(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('fellAfter: $fellAfter, ')
          ..write('roseOn: $roseOn')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, darumaId, fellAfter, roseOn);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecoveryRow &&
          other.id == this.id &&
          other.darumaId == this.darumaId &&
          other.fellAfter == this.fellAfter &&
          other.roseOn == this.roseOn);
}

class RecoveriesCompanion extends UpdateCompanion<RecoveryRow> {
  final Value<int> id;
  final Value<int> darumaId;
  final Value<String> fellAfter;
  final Value<String> roseOn;
  const RecoveriesCompanion({
    this.id = const Value.absent(),
    this.darumaId = const Value.absent(),
    this.fellAfter = const Value.absent(),
    this.roseOn = const Value.absent(),
  });
  RecoveriesCompanion.insert({
    this.id = const Value.absent(),
    required int darumaId,
    required String fellAfter,
    required String roseOn,
  }) : darumaId = Value(darumaId),
       fellAfter = Value(fellAfter),
       roseOn = Value(roseOn);
  static Insertable<RecoveryRow> custom({
    Expression<int>? id,
    Expression<int>? darumaId,
    Expression<String>? fellAfter,
    Expression<String>? roseOn,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (darumaId != null) 'daruma_id': darumaId,
      if (fellAfter != null) 'fell_after': fellAfter,
      if (roseOn != null) 'rose_on': roseOn,
    });
  }

  RecoveriesCompanion copyWith({
    Value<int>? id,
    Value<int>? darumaId,
    Value<String>? fellAfter,
    Value<String>? roseOn,
  }) {
    return RecoveriesCompanion(
      id: id ?? this.id,
      darumaId: darumaId ?? this.darumaId,
      fellAfter: fellAfter ?? this.fellAfter,
      roseOn: roseOn ?? this.roseOn,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (darumaId.present) {
      map['daruma_id'] = Variable<int>(darumaId.value);
    }
    if (fellAfter.present) {
      map['fell_after'] = Variable<String>(fellAfter.value);
    }
    if (roseOn.present) {
      map['rose_on'] = Variable<String>(roseOn.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecoveriesCompanion(')
          ..write('id: $id, ')
          ..write('darumaId: $darumaId, ')
          ..write('fellAfter: $fellAfter, ')
          ..write('roseOn: $roseOn')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DarumasTable darumas = $DarumasTable(this);
  late final $CheckinsTable checkins = $CheckinsTable(this);
  late final $RecoveriesTable recoveries = $RecoveriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    darumas,
    checkins,
    recoveries,
  ];
}

typedef $$DarumasTableCreateCompanionBuilder =
    DarumasCompanion Function({
      Value<int> id,
      required String name,
      required DarumaColor color,
      required EyeSide eyeSide,
      required String createdOn,
      Value<String?> deadline,
      Value<String?> deadlineLabel,
      Value<String?> dailyAction,
      required DarumaStatus status,
      Value<String?> completedOn,
      Value<String?> retiredOn,
      Value<int> sizeRank,
      Value<int?> parentId,
      Value<int> seed,
    });
typedef $$DarumasTableUpdateCompanionBuilder =
    DarumasCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DarumaColor> color,
      Value<EyeSide> eyeSide,
      Value<String> createdOn,
      Value<String?> deadline,
      Value<String?> deadlineLabel,
      Value<String?> dailyAction,
      Value<DarumaStatus> status,
      Value<String?> completedOn,
      Value<String?> retiredOn,
      Value<int> sizeRank,
      Value<int?> parentId,
      Value<int> seed,
    });

final class $$DarumasTableReferences
    extends BaseReferences<_$AppDatabase, $DarumasTable, DarumaRow> {
  $$DarumasTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$CheckinsTable, List<CheckinRow>>
  _checkinsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.checkins,
    aliasName: 'darumas__id__checkins__daruma_id',
  );

  $$CheckinsTableProcessedTableManager get checkinsRefs {
    final manager = $$CheckinsTableTableManager(
      $_db,
      $_db.checkins,
    ).filter((f) => f.darumaId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_checkinsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RecoveriesTable, List<RecoveryRow>>
  _recoveriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.recoveries,
    aliasName: 'darumas__id__recoveries__daruma_id',
  );

  $$RecoveriesTableProcessedTableManager get recoveriesRefs {
    final manager = $$RecoveriesTableTableManager(
      $_db,
      $_db.recoveries,
    ).filter((f) => f.darumaId.id.sqlEquals($_itemColumn<int>('id')!));

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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DarumaColor, DarumaColor, int> get color =>
      $composableBuilder(
        column: $table.color,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<EyeSide, EyeSide, int> get eyeSide =>
      $composableBuilder(
        column: $table.eyeSide,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deadlineLabel => $composableBuilder(
    column: $table.deadlineLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DarumaStatus, DarumaStatus, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retiredOn => $composableBuilder(
    column: $table.retiredOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeRank => $composableBuilder(
    column: $table.sizeRank,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seed => $composableBuilder(
    column: $table.seed,
    builder: (column) => ColumnFilters(column),
  );

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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eyeSide => $composableBuilder(
    column: $table.eyeSide,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get createdOn => $composableBuilder(
    column: $table.createdOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadline => $composableBuilder(
    column: $table.deadline,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deadlineLabel => $composableBuilder(
    column: $table.deadlineLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retiredOn => $composableBuilder(
    column: $table.retiredOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeRank => $composableBuilder(
    column: $table.sizeRank,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seed => $composableBuilder(
    column: $table.seed,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DarumaColor, int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EyeSide, int> get eyeSide =>
      $composableBuilder(column: $table.eyeSide, builder: (column) => column);

  GeneratedColumn<String> get createdOn =>
      $composableBuilder(column: $table.createdOn, builder: (column) => column);

  GeneratedColumn<String> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<String> get deadlineLabel => $composableBuilder(
    column: $table.deadlineLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dailyAction => $composableBuilder(
    column: $table.dailyAction,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<DarumaStatus, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get completedOn => $composableBuilder(
    column: $table.completedOn,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retiredOn =>
      $composableBuilder(column: $table.retiredOn, builder: (column) => column);

  GeneratedColumn<int> get sizeRank =>
      $composableBuilder(column: $table.sizeRank, builder: (column) => column);

  GeneratedColumn<int> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<int> get seed =>
      $composableBuilder(column: $table.seed, builder: (column) => column);

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
          DarumaRow,
          $$DarumasTableFilterComposer,
          $$DarumasTableOrderingComposer,
          $$DarumasTableAnnotationComposer,
          $$DarumasTableCreateCompanionBuilder,
          $$DarumasTableUpdateCompanionBuilder,
          (DarumaRow, $$DarumasTableReferences),
          DarumaRow,
          PrefetchHooks Function({bool checkinsRefs, bool recoveriesRefs})
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
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DarumaColor> color = const Value.absent(),
                Value<EyeSide> eyeSide = const Value.absent(),
                Value<String> createdOn = const Value.absent(),
                Value<String?> deadline = const Value.absent(),
                Value<String?> deadlineLabel = const Value.absent(),
                Value<String?> dailyAction = const Value.absent(),
                Value<DarumaStatus> status = const Value.absent(),
                Value<String?> completedOn = const Value.absent(),
                Value<String?> retiredOn = const Value.absent(),
                Value<int> sizeRank = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> seed = const Value.absent(),
              }) => DarumasCompanion(
                id: id,
                name: name,
                color: color,
                eyeSide: eyeSide,
                createdOn: createdOn,
                deadline: deadline,
                deadlineLabel: deadlineLabel,
                dailyAction: dailyAction,
                status: status,
                completedOn: completedOn,
                retiredOn: retiredOn,
                sizeRank: sizeRank,
                parentId: parentId,
                seed: seed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DarumaColor color,
                required EyeSide eyeSide,
                required String createdOn,
                Value<String?> deadline = const Value.absent(),
                Value<String?> deadlineLabel = const Value.absent(),
                Value<String?> dailyAction = const Value.absent(),
                required DarumaStatus status,
                Value<String?> completedOn = const Value.absent(),
                Value<String?> retiredOn = const Value.absent(),
                Value<int> sizeRank = const Value.absent(),
                Value<int?> parentId = const Value.absent(),
                Value<int> seed = const Value.absent(),
              }) => DarumasCompanion.insert(
                id: id,
                name: name,
                color: color,
                eyeSide: eyeSide,
                createdOn: createdOn,
                deadline: deadline,
                deadlineLabel: deadlineLabel,
                dailyAction: dailyAction,
                status: status,
                completedOn: completedOn,
                retiredOn: retiredOn,
                sizeRank: sizeRank,
                parentId: parentId,
                seed: seed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$DarumasTable, DarumaRow>(table),
                  $$DarumasTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({checkinsRefs = false, recoveriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (checkinsRefs) db.checkins,
                    if (recoveriesRefs) db.recoveries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (checkinsRefs)
                        await $_getPrefetchedDataByColumns<
                          DarumaRow,
                          $DarumasTable,
                          CheckinRow,
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
                          DarumaRow,
                          $DarumasTable,
                          RecoveryRow,
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
      DarumaRow,
      $$DarumasTableFilterComposer,
      $$DarumasTableOrderingComposer,
      $$DarumasTableAnnotationComposer,
      $$DarumasTableCreateCompanionBuilder,
      $$DarumasTableUpdateCompanionBuilder,
      (DarumaRow, $$DarumasTableReferences),
      DarumaRow,
      PrefetchHooks Function({bool checkinsRefs, bool recoveriesRefs})
    >;
typedef $$CheckinsTableCreateCompanionBuilder =
    CheckinsCompanion Function({
      Value<int> id,
      required int darumaId,
      required String date,
      required CheckinKind kind,
      Value<String?> memo,
    });
typedef $$CheckinsTableUpdateCompanionBuilder =
    CheckinsCompanion Function({
      Value<int> id,
      Value<int> darumaId,
      Value<String> date,
      Value<CheckinKind> kind,
      Value<String?> memo,
    });

final class $$CheckinsTableReferences
    extends BaseReferences<_$AppDatabase, $CheckinsTable, CheckinRow> {
  $$CheckinsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DarumasTable _darumaIdTable(_$AppDatabase db) =>
      db.darumas.createAlias('checkins__daruma_id__darumas__id');

  $$DarumasTableProcessedTableManager get darumaId {
    final $_column = $_itemColumn<int>('daruma_id')!;

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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<CheckinKind, CheckinKind, int> get kind =>
      $composableBuilder(
        column: $table.kind,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
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
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<CheckinKind, int> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

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
          CheckinRow,
          $$CheckinsTableFilterComposer,
          $$CheckinsTableOrderingComposer,
          $$CheckinsTableAnnotationComposer,
          $$CheckinsTableCreateCompanionBuilder,
          $$CheckinsTableUpdateCompanionBuilder,
          (CheckinRow, $$CheckinsTableReferences),
          CheckinRow,
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
                Value<int> id = const Value.absent(),
                Value<int> darumaId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<CheckinKind> kind = const Value.absent(),
                Value<String?> memo = const Value.absent(),
              }) => CheckinsCompanion(
                id: id,
                darumaId: darumaId,
                date: date,
                kind: kind,
                memo: memo,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int darumaId,
                required String date,
                required CheckinKind kind,
                Value<String?> memo = const Value.absent(),
              }) => CheckinsCompanion.insert(
                id: id,
                darumaId: darumaId,
                date: date,
                kind: kind,
                memo: memo,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$CheckinsTable, CheckinRow>(table),
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
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.darumaId,
                                referencedTable: $$CheckinsTableReferences
                                    ._darumaIdTable(db),
                                referencedColumn: $$CheckinsTableReferences
                                    ._darumaIdTable(db)
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

typedef $$CheckinsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CheckinsTable,
      CheckinRow,
      $$CheckinsTableFilterComposer,
      $$CheckinsTableOrderingComposer,
      $$CheckinsTableAnnotationComposer,
      $$CheckinsTableCreateCompanionBuilder,
      $$CheckinsTableUpdateCompanionBuilder,
      (CheckinRow, $$CheckinsTableReferences),
      CheckinRow,
      PrefetchHooks Function({bool darumaId})
    >;
typedef $$RecoveriesTableCreateCompanionBuilder =
    RecoveriesCompanion Function({
      Value<int> id,
      required int darumaId,
      required String fellAfter,
      required String roseOn,
    });
typedef $$RecoveriesTableUpdateCompanionBuilder =
    RecoveriesCompanion Function({
      Value<int> id,
      Value<int> darumaId,
      Value<String> fellAfter,
      Value<String> roseOn,
    });

final class $$RecoveriesTableReferences
    extends BaseReferences<_$AppDatabase, $RecoveriesTable, RecoveryRow> {
  $$RecoveriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DarumasTable _darumaIdTable(_$AppDatabase db) =>
      db.darumas.createAlias('recoveries__daruma_id__darumas__id');

  $$DarumasTableProcessedTableManager get darumaId {
    final $_column = $_itemColumn<int>('daruma_id')!;

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
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fellAfter => $composableBuilder(
    column: $table.fellAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get roseOn => $composableBuilder(
    column: $table.roseOn,
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

class $$RecoveriesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecoveriesTable> {
  $$RecoveriesTableOrderingComposer({
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
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get fellAfter =>
      $composableBuilder(column: $table.fellAfter, builder: (column) => column);

  GeneratedColumn<String> get roseOn =>
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
          RecoveryRow,
          $$RecoveriesTableFilterComposer,
          $$RecoveriesTableOrderingComposer,
          $$RecoveriesTableAnnotationComposer,
          $$RecoveriesTableCreateCompanionBuilder,
          $$RecoveriesTableUpdateCompanionBuilder,
          (RecoveryRow, $$RecoveriesTableReferences),
          RecoveryRow,
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
                Value<int> id = const Value.absent(),
                Value<int> darumaId = const Value.absent(),
                Value<String> fellAfter = const Value.absent(),
                Value<String> roseOn = const Value.absent(),
              }) => RecoveriesCompanion(
                id: id,
                darumaId: darumaId,
                fellAfter: fellAfter,
                roseOn: roseOn,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int darumaId,
                required String fellAfter,
                required String roseOn,
              }) => RecoveriesCompanion.insert(
                id: id,
                darumaId: darumaId,
                fellAfter: fellAfter,
                roseOn: roseOn,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecoveriesTable, RecoveryRow>(table),
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
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.darumaId,
                                referencedTable: $$RecoveriesTableReferences
                                    ._darumaIdTable(db),
                                referencedColumn: $$RecoveriesTableReferences
                                    ._darumaIdTable(db)
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

typedef $$RecoveriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecoveriesTable,
      RecoveryRow,
      $$RecoveriesTableFilterComposer,
      $$RecoveriesTableOrderingComposer,
      $$RecoveriesTableAnnotationComposer,
      $$RecoveriesTableCreateCompanionBuilder,
      $$RecoveriesTableUpdateCompanionBuilder,
      (RecoveryRow, $$RecoveriesTableReferences),
      RecoveryRow,
      PrefetchHooks Function({bool darumaId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DarumasTableTableManager get darumas =>
      $$DarumasTableTableManager(_db, _db.darumas);
  $$CheckinsTableTableManager get checkins =>
      $$CheckinsTableTableManager(_db, _db.checkins);
  $$RecoveriesTableTableManager get recoveries =>
      $$RecoveriesTableTableManager(_db, _db.recoveries);
}
