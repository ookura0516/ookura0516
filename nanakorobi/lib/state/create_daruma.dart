import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local_date.dart';
import '../core/size_rank.dart';
import '../core/validation.dart';
import '../model/models.dart';
import 'providers.dart';

/// 通過点の入力。
class WaypointInput {
  const WaypointInput({required this.name, required this.date, this.presetId});

  final String name;
  final LocalDate date;
  final String? presetId;
}

/// 作成フォーム→開眼→保存までの一時状態。
class CreateDarumaForm {
  const CreateDarumaForm({
    this.name = '',
    this.colorId = 0,
    this.deadline,
    this.deadlineName,
    this.deadlinePresetId,
    this.waypoints = const [],
    this.dailyAction = '',
    this.parentId,
    this.sizeRank = SizeRank.min,
    this.eyeSide = EyeSide.left,
  });

  final String name;
  final int colorId;
  final LocalDate? deadline;
  final String? deadlineName;
  final String? deadlinePresetId;
  final List<WaypointInput> waypoints;
  final String dailyAction;

  /// 「ひと回り大きいだるま」のやり直し元。
  final String? parentId;
  final int sizeRank;
  final EyeSide eyeSide;

  bool get nameOk => Limits.nameOk(name);
  bool get canProceed => nameOk && waypoints.length <= Limits.waypointsMax;
  bool get isBigger => parentId != null;

  CreateDarumaForm copyWith({
    String? name,
    int? colorId,
    LocalDate? deadline,
    bool clearDeadline = false,
    String? deadlineName,
    String? deadlinePresetId,
    List<WaypointInput>? waypoints,
    String? dailyAction,
    String? parentId,
    int? sizeRank,
    EyeSide? eyeSide,
  }) =>
      CreateDarumaForm(
        name: name ?? this.name,
        colorId: colorId ?? this.colorId,
        deadline: clearDeadline ? null : (deadline ?? this.deadline),
        deadlineName: clearDeadline ? null : (deadlineName ?? this.deadlineName),
        deadlinePresetId: clearDeadline ? null : (deadlinePresetId ?? this.deadlinePresetId),
        waypoints: waypoints ?? this.waypoints,
        dailyAction: dailyAction ?? this.dailyAction,
        parentId: parentId ?? this.parentId,
        sizeRank: sizeRank ?? this.sizeRank,
        eyeSide: eyeSide ?? this.eyeSide,
      );
}

class CreateDarumaNotifier extends Notifier<CreateDarumaForm> {
  @override
  CreateDarumaForm build() =>
      CreateDarumaForm(eyeSide: ref.watch(settingsProvider.select((s) => s.eyeSideDefault)));

  void reset() => state = CreateDarumaForm(eyeSide: ref.read(settingsProvider).eyeSideDefault);

  /// 納めたあと、同じ目標でひと回り大きいだるまを作る。
  void startBigger(Daruma parent) => state = CreateDarumaForm(
        name: parent.name,
        colorId: parent.colorId,
        dailyAction: parent.dailyAction ?? '',
        parentId: parent.id,
        sizeRank: SizeRank.next(parent.sizeRank),
        eyeSide: ref.read(settingsProvider).eyeSideDefault,
      );

  void setName(String v) => state = state.copyWith(name: v);
  void setColor(int id) => state = state.copyWith(colorId: id);
  void setDailyAction(String v) => state = state.copyWith(dailyAction: v);
  void setEyeSide(EyeSide side) => state = state.copyWith(eyeSide: side);

  void setDeadline(LocalDate? date, {String? name, String? presetId}) => state = date == null
      ? state.copyWith(clearDeadline: true)
      : state.copyWith(deadline: date, deadlineName: name ?? '', deadlinePresetId: presetId);

  void setDeadlineFromPreset(ExamPreset p) =>
      setDeadline(p.date, name: p.name, presetId: p.id);

  bool addWaypoint(WaypointInput w) {
    if (state.waypoints.length >= Limits.waypointsMax) return false;
    state = state.copyWith(waypoints: [...state.waypoints, w]);
    return true;
  }

  void removeWaypoint(int index) => state = state.copyWith(
        waypoints: [
          for (var i = 0; i < state.waypoints.length; i++)
            if (i != index) state.waypoints[i],
        ],
      );
}

final createDarumaProvider =
    NotifierProvider<CreateDarumaNotifier, CreateDarumaForm>(CreateDarumaNotifier.new);
