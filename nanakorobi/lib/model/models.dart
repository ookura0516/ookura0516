import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/countdown.dart';
import '../core/local_date.dart';
import '../core/strokes.dart';

part 'models.freezed.dart';
part 'models.g.dart';

/// 開眼で先に入れる目。[left] はだるまの左目（向かって右）。既定は左目。
enum EyeSide { left, right }

enum DarumaStatus {
  /// 現役。
  active,

  /// 満願（両目）。
  completed,

  /// 納めた（片目のまま棚へ）。
  retired,
}

enum CheckinKind {
  /// 今日の一歩。
  step,

  /// 休み券。
  rest,
}

enum EyeState { none, one, both }

enum WidgetStyle { paper, plain }

/// だるま（1体＝1目標）。
@freezed
abstract class Daruma with _$Daruma {
  const Daruma._();

  const factory Daruma({
    required String id,

    /// 腹の文字（2〜6字）。
    required String name,
    required int colorId,
    required EyeSide eyeSide,
    required DateTime createdAt,

    /// 開眼日（端末のローカル日付）。
    required LocalDate openedOn,

    /// 本番の日。
    LocalDate? deadline,
    String? deadlineName,
    String? deadlinePresetId,

    /// 毎日の一歩。
    String? dailyAction,
    required DarumaStatus status,
    DateTime? completedAt,
    DateTime? retiredAt,
    @Default(1) int sizeRank,

    /// 「ひと回り大きいだるま」のやり直し元。
    String? parentId,

    /// 眉とひげの揺らぎの種。
    required int seed,

    /// 期限日に1回だけ「叶った？」と聞いたか。
    @Default(false) bool askedAtDeadline,
  }) = _Daruma;

  factory Daruma.fromJson(Map<String, dynamic> json) => _$DarumaFromJson(json);

  bool get isActive => status == DarumaStatus.active;

  /// 満願の日（端末ローカル）。
  LocalDate? get completedOn {
    final t = completedAt;
    return t == null ? null : LocalDate.fromDateTime(t);
  }

  LocalDate? get retiredOn {
    final t = retiredAt;
    return t == null ? null : LocalDate.fromDateTime(t);
  }

  /// 棚の年の絞り込みに使う年（開眼した年）。
  int get year => openedOn.year;
}

/// 通過点（模試、出願締切、二次など）。だるまあたり最大3件。
@freezed
abstract class Milestone with _$Milestone {
  const Milestone._();

  const factory Milestone({
    required String id,
    required String darumaId,
    required String name,
    required LocalDate date,
    String? presetId,
  }) = _Milestone;

  factory Milestone.fromJson(Map<String, dynamic> json) => _$MilestoneFromJson(json);

  Waypoint get waypoint => Waypoint(name: name, date: date);
}

/// 1日1件の記録。
@freezed
abstract class Checkin with _$Checkin {
  const factory Checkin({
    required String id,
    required String darumaId,

    /// 端末のローカル日付。darumaId と合わせて一意。
    required LocalDate date,
    required CheckinKind kind,

    /// 30字のメモ（任意）。
    String? memo,
    required DateTime createdAt,
  }) = _Checkin;

  factory Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);
}

/// 起き上がり。件数＝台座の金の筋の本数。
@freezed
abstract class Recovery with _$Recovery {
  const factory Recovery({
    required String id,
    required String darumaId,

    /// 転ぶ前に最後に記録した日。
    required LocalDate fellAfter,

    /// 起き上がった日。
    required LocalDate roseOn,
  }) = _Recovery;

  factory Recovery.fromJson(Map<String, dynamic> json) => _$RecoveryFromJson(json);
}

/// 描画仕様。画面・ウィジェット・共有画像はすべてこれから描く。
@freezed
abstract class DarumaLook with _$DarumaLook {
  const DarumaLook._();

  const factory DarumaLook({
    required String darumaId,
    required String text,
    required int colorId,
    required int seed,

    /// 筆の数（step の件数）。
    required int strokes,

    /// 台座の金の筋＝起き上がり回数。
    required int goldLines,
    required EyeSide firstEye,
    required EyeState eyes,
    required int sizeRank,
    required bool fallen,
    required DarumaStatus status,
    LocalDate? openedOn,
    LocalDate? completedOn,
    int? daysLeft,
    String? deadlineName,
    @Default(0) int streak,
    @Default(false) bool recordedToday,
    @Default(0) int daysSinceOpened,
  }) = _DarumaLook;

  factory DarumaLook.fromJson(Map<String, dynamic> json) => _$DarumaLookFromJson(json);

  StrokeMilestone? get milestone => StrokeMilestone.highest(strokes);

  /// 50筆：腹の文字が金になる。
  bool get goldText => strokes >= StrokeMilestone.day50.strokes;

  /// 100筆：衣に金彩が入る。
  bool get goldRobe => strokes >= StrokeMilestone.day100.strokes;

  int get riseCount => goldLines;
}

/// 設定（ookura_settings の代わり。README「共有パッケージの差し替え」）。
@freezed
abstract class AppSettings with _$AppSettings {
  const AppSettings._();

  const factory AppSettings({
    /// リマインド通知。既定オフ。
    @Default(false) bool reminderEnabled,

    /// 通知時刻（0時からの分）。既定 20:00。
    @Default(20 * 60) int reminderMinuteOfDay,
    @Default(EyeSide.left) EyeSide eyeSideDefault,
    @Default(WidgetStyle.paper) WidgetStyle widgetStyle,
    @Default(false) bool onboardingDone,

    /// 評価依頼を出した日。365日3回まで。
    @Default(<LocalDate>[]) List<LocalDate> reviewPromptedOn,

    /// ウィジェットに出すだるま（プラスで複数あるとき）。null なら最初の現役。
    String? widgetDarumaId,

    /// 日付の境界（0〜3時を前日扱いにするなら 3）。仮置きは 0。
    @Default(0) int dayShiftHours,
  }) = _AppSettings;

  factory AppSettings.fromJson(Map<String, dynamic> json) => _$AppSettingsFromJson(json);

  int get reminderHour => reminderMinuteOfDay ~/ 60;
  int get reminderMinute => reminderMinuteOfDay % 60;
  DayBoundary get dayBoundary => DayBoundary(shiftHours: dayShiftHours);
}

/// 試験日プリセット（同梱 JSON と jsDelivr の更新分）。
@freezed
abstract class ExamPreset with _$ExamPreset {
  const ExamPreset._();

  const factory ExamPreset({
    required String id,
    required String name,
    required LocalDate date,

    /// 区分：university / highschool / juniorhigh / certification
    required String kind,
    String? region,
    required String sourceUrl,
    required String sourceOrg,
    required LocalDate updatedOn,
    @Default('') String note,
  }) = _ExamPreset;

  factory ExamPreset.fromJson(Map<String, dynamic> json) => _$ExamPresetFromJson(json);
}

@freezed
abstract class PresetCatalog with _$PresetCatalog {
  const PresetCatalog._();

  const factory PresetCatalog({
    required int version,
    required LocalDate updatedOn,
    required List<ExamPreset> presets,
  }) = _PresetCatalog;

  factory PresetCatalog.fromJson(Map<String, dynamic> json) => _$PresetCatalogFromJson(json);

  static const empty = PresetCatalog(version: 0, updatedOn: LocalDate(2000, 1, 1), presets: []);
}

/// ウィジェットへ渡す JSON（App Group / SharedPreferences）。
@freezed
abstract class WidgetSnapshot with _$WidgetSnapshot {
  const factory WidgetSnapshot({
    required DarumaLook look,
    required String name,
    String? deadlineName,

    /// 今日から14日分。各日の0時に切り替える。
    required List<TimelineEntry> timeline,
    required DateTime generatedAt,
    required WidgetStyle style,
  }) = _WidgetSnapshot;

  factory WidgetSnapshot.fromJson(Map<String, dynamic> json) => _$WidgetSnapshotFromJson(json);
}

/// JSON の書き出し・読み込み（プラス）。1ファイルに全部入れる。
@freezed
abstract class BackupData with _$BackupData {
  const factory BackupData({
    required int version,
    required DateTime exportedAt,
    required List<Daruma> darumas,
    required List<Milestone> milestones,
    required List<Checkin> checkins,
    required List<Recovery> recoveries,
    AppSettings? settings,
  }) = _BackupData;

  factory BackupData.fromJson(Map<String, dynamic> json) => _$BackupDataFromJson(json);
}

/// だるま1体の、描画と判定に必要な全部。
class DarumaBundle {
  const DarumaBundle({
    required this.daruma,
    this.checkins = const [],
    this.recoveries = const [],
    this.milestones = const [],
  });

  final Daruma daruma;
  final List<Checkin> checkins;
  final List<Recovery> recoveries;
  final List<Milestone> milestones;

  String get id => daruma.id;

  Iterable<LocalDate> get stepDates =>
      checkins.where((c) => c.kind == CheckinKind.step).map((c) => c.date);

  Iterable<LocalDate> get restDates =>
      checkins.where((c) => c.kind == CheckinKind.rest).map((c) => c.date);

  Checkin? checkinOn(LocalDate d) {
    for (final c in checkins) {
      if (c.date == d) return c;
    }
    return null;
  }

  List<Waypoint> get waypoints => milestones.map((m) => m.waypoint).toList();
}
