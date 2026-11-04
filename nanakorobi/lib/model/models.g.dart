// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Daruma _$DarumaFromJson(Map<String, dynamic> json) => _Daruma(
  id: json['id'] as String,
  name: json['name'] as String,
  colorId: (json['color_id'] as num).toInt(),
  eyeSide: $enumDecode(_$EyeSideEnumMap, json['eye_side']),
  createdAt: DateTime.parse(json['created_at'] as String),
  openedOn: LocalDate.fromJson(json['opened_on'] as String),
  deadline: json['deadline'] == null
      ? null
      : LocalDate.fromJson(json['deadline'] as String),
  deadlineName: json['deadline_name'] as String?,
  deadlinePresetId: json['deadline_preset_id'] as String?,
  dailyAction: json['daily_action'] as String?,
  status: $enumDecode(_$DarumaStatusEnumMap, json['status']),
  completedAt: json['completed_at'] == null
      ? null
      : DateTime.parse(json['completed_at'] as String),
  retiredAt: json['retired_at'] == null
      ? null
      : DateTime.parse(json['retired_at'] as String),
  sizeRank: (json['size_rank'] as num?)?.toInt() ?? 1,
  parentId: json['parent_id'] as String?,
  seed: (json['seed'] as num).toInt(),
  askedAtDeadline: json['asked_at_deadline'] as bool? ?? false,
);

Map<String, dynamic> _$DarumaToJson(_Daruma instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'color_id': instance.colorId,
  'eye_side': _$EyeSideEnumMap[instance.eyeSide]!,
  'created_at': instance.createdAt.toIso8601String(),
  'opened_on': instance.openedOn.toJson(),
  'deadline': instance.deadline?.toJson(),
  'deadline_name': instance.deadlineName,
  'deadline_preset_id': instance.deadlinePresetId,
  'daily_action': instance.dailyAction,
  'status': _$DarumaStatusEnumMap[instance.status]!,
  'completed_at': instance.completedAt?.toIso8601String(),
  'retired_at': instance.retiredAt?.toIso8601String(),
  'size_rank': instance.sizeRank,
  'parent_id': instance.parentId,
  'seed': instance.seed,
  'asked_at_deadline': instance.askedAtDeadline,
};

const _$EyeSideEnumMap = {EyeSide.left: 'left', EyeSide.right: 'right'};

const _$DarumaStatusEnumMap = {
  DarumaStatus.active: 'active',
  DarumaStatus.completed: 'completed',
  DarumaStatus.retired: 'retired',
};

_Milestone _$MilestoneFromJson(Map<String, dynamic> json) => _Milestone(
  id: json['id'] as String,
  darumaId: json['daruma_id'] as String,
  name: json['name'] as String,
  date: LocalDate.fromJson(json['date'] as String),
  presetId: json['preset_id'] as String?,
);

Map<String, dynamic> _$MilestoneToJson(_Milestone instance) =>
    <String, dynamic>{
      'id': instance.id,
      'daruma_id': instance.darumaId,
      'name': instance.name,
      'date': instance.date.toJson(),
      'preset_id': instance.presetId,
    };

_Checkin _$CheckinFromJson(Map<String, dynamic> json) => _Checkin(
  id: json['id'] as String,
  darumaId: json['daruma_id'] as String,
  date: LocalDate.fromJson(json['date'] as String),
  kind: $enumDecode(_$CheckinKindEnumMap, json['kind']),
  memo: json['memo'] as String?,
  createdAt: DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$CheckinToJson(_Checkin instance) => <String, dynamic>{
  'id': instance.id,
  'daruma_id': instance.darumaId,
  'date': instance.date.toJson(),
  'kind': _$CheckinKindEnumMap[instance.kind]!,
  'memo': instance.memo,
  'created_at': instance.createdAt.toIso8601String(),
};

const _$CheckinKindEnumMap = {
  CheckinKind.step: 'step',
  CheckinKind.rest: 'rest',
};

_Recovery _$RecoveryFromJson(Map<String, dynamic> json) => _Recovery(
  id: json['id'] as String,
  darumaId: json['daruma_id'] as String,
  fellAfter: LocalDate.fromJson(json['fell_after'] as String),
  roseOn: LocalDate.fromJson(json['rose_on'] as String),
);

Map<String, dynamic> _$RecoveryToJson(_Recovery instance) => <String, dynamic>{
  'id': instance.id,
  'daruma_id': instance.darumaId,
  'fell_after': instance.fellAfter.toJson(),
  'rose_on': instance.roseOn.toJson(),
};

_DarumaLook _$DarumaLookFromJson(Map<String, dynamic> json) => _DarumaLook(
  darumaId: json['daruma_id'] as String,
  text: json['text'] as String,
  colorId: (json['color_id'] as num).toInt(),
  seed: (json['seed'] as num).toInt(),
  strokes: (json['strokes'] as num).toInt(),
  goldLines: (json['gold_lines'] as num).toInt(),
  firstEye: $enumDecode(_$EyeSideEnumMap, json['first_eye']),
  eyes: $enumDecode(_$EyeStateEnumMap, json['eyes']),
  sizeRank: (json['size_rank'] as num).toInt(),
  fallen: json['fallen'] as bool,
  status: $enumDecode(_$DarumaStatusEnumMap, json['status']),
  openedOn: json['opened_on'] == null
      ? null
      : LocalDate.fromJson(json['opened_on'] as String),
  completedOn: json['completed_on'] == null
      ? null
      : LocalDate.fromJson(json['completed_on'] as String),
  daysLeft: (json['days_left'] as num?)?.toInt(),
  deadlineName: json['deadline_name'] as String?,
  streak: (json['streak'] as num?)?.toInt() ?? 0,
  recordedToday: json['recorded_today'] as bool? ?? false,
  daysSinceOpened: (json['days_since_opened'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$DarumaLookToJson(_DarumaLook instance) =>
    <String, dynamic>{
      'daruma_id': instance.darumaId,
      'text': instance.text,
      'color_id': instance.colorId,
      'seed': instance.seed,
      'strokes': instance.strokes,
      'gold_lines': instance.goldLines,
      'first_eye': _$EyeSideEnumMap[instance.firstEye]!,
      'eyes': _$EyeStateEnumMap[instance.eyes]!,
      'size_rank': instance.sizeRank,
      'fallen': instance.fallen,
      'status': _$DarumaStatusEnumMap[instance.status]!,
      'opened_on': instance.openedOn?.toJson(),
      'completed_on': instance.completedOn?.toJson(),
      'days_left': instance.daysLeft,
      'deadline_name': instance.deadlineName,
      'streak': instance.streak,
      'recorded_today': instance.recordedToday,
      'days_since_opened': instance.daysSinceOpened,
    };

const _$EyeStateEnumMap = {
  EyeState.none: 'none',
  EyeState.one: 'one',
  EyeState.both: 'both',
};

_AppSettings _$AppSettingsFromJson(Map<String, dynamic> json) => _AppSettings(
  reminderEnabled: json['reminder_enabled'] as bool? ?? false,
  reminderMinuteOfDay:
      (json['reminder_minute_of_day'] as num?)?.toInt() ?? 20 * 60,
  eyeSideDefault:
      $enumDecodeNullable(_$EyeSideEnumMap, json['eye_side_default']) ??
      EyeSide.left,
  widgetStyle:
      $enumDecodeNullable(_$WidgetStyleEnumMap, json['widget_style']) ??
      WidgetStyle.paper,
  onboardingDone: json['onboarding_done'] as bool? ?? false,
  reviewPromptedOn:
      (json['review_prompted_on'] as List<dynamic>?)
          ?.map((e) => LocalDate.fromJson(e as String))
          .toList() ??
      const <LocalDate>[],
  widgetDarumaId: json['widget_daruma_id'] as String?,
  dayShiftHours: (json['day_shift_hours'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$AppSettingsToJson(_AppSettings instance) =>
    <String, dynamic>{
      'reminder_enabled': instance.reminderEnabled,
      'reminder_minute_of_day': instance.reminderMinuteOfDay,
      'eye_side_default': _$EyeSideEnumMap[instance.eyeSideDefault]!,
      'widget_style': _$WidgetStyleEnumMap[instance.widgetStyle]!,
      'onboarding_done': instance.onboardingDone,
      'review_prompted_on': instance.reviewPromptedOn
          .map((e) => e.toJson())
          .toList(),
      'widget_daruma_id': instance.widgetDarumaId,
      'day_shift_hours': instance.dayShiftHours,
    };

const _$WidgetStyleEnumMap = {
  WidgetStyle.paper: 'paper',
  WidgetStyle.plain: 'plain',
};

_ExamPreset _$ExamPresetFromJson(Map<String, dynamic> json) => _ExamPreset(
  id: json['id'] as String,
  name: json['name'] as String,
  date: LocalDate.fromJson(json['date'] as String),
  kind: json['kind'] as String,
  region: json['region'] as String?,
  sourceUrl: json['source_url'] as String,
  sourceOrg: json['source_org'] as String,
  updatedOn: LocalDate.fromJson(json['updated_on'] as String),
  note: json['note'] as String? ?? '',
);

Map<String, dynamic> _$ExamPresetToJson(_ExamPreset instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'date': instance.date.toJson(),
      'kind': instance.kind,
      'region': instance.region,
      'source_url': instance.sourceUrl,
      'source_org': instance.sourceOrg,
      'updated_on': instance.updatedOn.toJson(),
      'note': instance.note,
    };

_PresetCatalog _$PresetCatalogFromJson(Map<String, dynamic> json) =>
    _PresetCatalog(
      version: (json['version'] as num).toInt(),
      updatedOn: LocalDate.fromJson(json['updated_on'] as String),
      presets: (json['presets'] as List<dynamic>)
          .map((e) => ExamPreset.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$PresetCatalogToJson(_PresetCatalog instance) =>
    <String, dynamic>{
      'version': instance.version,
      'updated_on': instance.updatedOn.toJson(),
      'presets': instance.presets.map((e) => e.toJson()).toList(),
    };

_WidgetSnapshot _$WidgetSnapshotFromJson(Map<String, dynamic> json) =>
    _WidgetSnapshot(
      look: DarumaLook.fromJson(json['look'] as Map<String, dynamic>),
      name: json['name'] as String,
      deadlineName: json['deadline_name'] as String?,
      timeline: (json['timeline'] as List<dynamic>)
          .map((e) => TimelineEntry.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      style: $enumDecode(_$WidgetStyleEnumMap, json['style']),
    );

Map<String, dynamic> _$WidgetSnapshotToJson(_WidgetSnapshot instance) =>
    <String, dynamic>{
      'look': instance.look.toJson(),
      'name': instance.name,
      'deadline_name': instance.deadlineName,
      'timeline': instance.timeline.map((e) => e.toJson()).toList(),
      'generated_at': instance.generatedAt.toIso8601String(),
      'style': _$WidgetStyleEnumMap[instance.style]!,
    };

_BackupData _$BackupDataFromJson(Map<String, dynamic> json) => _BackupData(
  version: (json['version'] as num).toInt(),
  exportedAt: DateTime.parse(json['exported_at'] as String),
  darumas: (json['darumas'] as List<dynamic>)
      .map((e) => Daruma.fromJson(e as Map<String, dynamic>))
      .toList(),
  milestones: (json['milestones'] as List<dynamic>)
      .map((e) => Milestone.fromJson(e as Map<String, dynamic>))
      .toList(),
  checkins: (json['checkins'] as List<dynamic>)
      .map((e) => Checkin.fromJson(e as Map<String, dynamic>))
      .toList(),
  recoveries: (json['recoveries'] as List<dynamic>)
      .map((e) => Recovery.fromJson(e as Map<String, dynamic>))
      .toList(),
  settings: json['settings'] == null
      ? null
      : AppSettings.fromJson(json['settings'] as Map<String, dynamic>),
);

Map<String, dynamic> _$BackupDataToJson(_BackupData instance) =>
    <String, dynamic>{
      'version': instance.version,
      'exported_at': instance.exportedAt.toIso8601String(),
      'darumas': instance.darumas.map((e) => e.toJson()).toList(),
      'milestones': instance.milestones.map((e) => e.toJson()).toList(),
      'checkins': instance.checkins.map((e) => e.toJson()).toList(),
      'recoveries': instance.recoveries.map((e) => e.toJson()).toList(),
      'settings': instance.settings?.toJson(),
    };
