import 'package:freezed_annotation/freezed_annotation.dart';

import '../core/local_date.dart';
import '../core/rules.dart';

part 'models.freezed.dart';

/// だるまの色。無料は赤・白・黒の3色（プラスで12色に広げる）。
enum DarumaColor { red, white, black }

/// 最初に入れる目。既定は左目（向かって右）。合格祈願で右目を先に入れる地域もある。
enum EyeSide { left, right }

enum DarumaStatus {
  /// 現役。
  active,

  /// 満願（両目）。
  completed,

  /// 納め（片目のまま）。
  retired,
}

enum CheckinKind { step, rest }

@freezed
abstract class Daruma with _$Daruma {
  const Daruma._();

  const factory Daruma({
    required int id,

    /// 腹に入る文字（2〜6字）。
    required String name,
    required DarumaColor color,
    required EyeSide eyeSide,

    /// 開眼した日。
    required LocalDate createdOn,

    /// 本番の日（任意）。
    LocalDate? deadline,

    /// 本番の名前（「共通テスト」など。ウィジェットの見出し）。
    String? deadlineLabel,

    /// 毎日の一歩（任意）。
    String? dailyAction,
    @Default(DarumaStatus.active) DarumaStatus status,
    LocalDate? completedOn,
    LocalDate? retiredOn,

    /// 大きさの段階。ひと回り大きいだるまで +1。
    @Default(1) int sizeRank,

    /// やり直し元のだるま。
    int? parentId,

    /// 眉とひげの揺らぎの種。
    @Default(0) int seed,
  }) = _Daruma;

  bool get isActive => status == DarumaStatus.active;
  bool get hasBothEyes => status == DarumaStatus.completed;
}

@freezed
abstract class Checkin with _$Checkin {
  const factory Checkin({
    required int id,
    required int darumaId,
    required LocalDate date,
    @Default(CheckinKind.step) CheckinKind kind,
    String? memo,
  }) = _Checkin;
}

@freezed
abstract class Recovery with _$Recovery {
  const factory Recovery({
    required int id,
    required int darumaId,

    /// 最後に記録した日（転ぶ前）。
    required LocalDate fellAfter,

    /// 起き上がった日。
    required LocalDate roseOn,
  }) = _Recovery;
}

/// 新しいだるまの入力。
@freezed
abstract class NewDaruma with _$NewDaruma {
  const factory NewDaruma({
    required String name,
    required DarumaColor color,
    required EyeSide eyeSide,
    LocalDate? deadline,
    String? deadlineLabel,
    String? dailyAction,
    int? parentId,
    @Default(1) int sizeRank,
  }) = _NewDaruma;
}

/// だるま1体と、その記録。
@freezed
abstract class DarumaDetail with _$DarumaDetail {
  const DarumaDetail._();

  const factory DarumaDetail({
    required Daruma daruma,
    required List<Checkin> checkins,
    required List<Recovery> recoveries,
  }) = _DarumaDetail;

  /// 筆の数（今日の一歩の件数）。
  int get brushCount => checkins.where((c) => c.kind == CheckinKind.step).length;

  /// 起き上がり回数（台座の金の筋）。
  int get riseCount => recoveries.length;

  /// 最後に一歩を記録した日。
  LocalDate? get lastStepOn {
    LocalDate? last;
    for (final c in checkins) {
      if (c.kind != CheckinKind.step) continue;
      if (last == null || c.date.isAfter(last)) last = c.date;
    }
    return last;
  }

  Checkin? checkinOn(LocalDate date) {
    for (final c in checkins) {
      if (c.date == date) return c;
    }
    return null;
  }

  bool isFallenOn(LocalDate today) => daruma.isActive &&
      Rules.isFallen(today: today, createdOn: daruma.createdOn, lastStepOn: lastStepOn);

  int? daysLeftOn(LocalDate today) {
    final d = daruma.deadline;
    return d == null ? null : Rules.daysLeft(d, today);
  }

  /// 描画の仕様。
  DarumaLook lookOn(LocalDate today) => DarumaLook(
        color: daruma.color,
        text: daruma.name,
        brushCount: brushCount,
        goldStripes: riseCount,
        openedEyes: switch (daruma.status) {
          DarumaStatus.completed => 2,
          _ => 1,
        },
        eyeSide: daruma.eyeSide,
        sizeRank: daruma.sizeRank,
        fallen: isFallenOn(today),
        seed: daruma.seed,
      );
}

/// 描画の仕様。ウィジェットと共有画像も同じ [DarumaLook] から描く。
@freezed
abstract class DarumaLook with _$DarumaLook {
  const DarumaLook._();

  const factory DarumaLook({
    required DarumaColor color,
    required String text,
    @Default(0) int brushCount,
    @Default(0) int goldStripes,

    /// 入っている目の数。0＝まだ、1＝片目、2＝両目。
    @Default(1) int openedEyes,
    @Default(EyeSide.left) EyeSide eyeSide,
    @Default(1) int sizeRank,
    @Default(false) bool fallen,
    @Default(0) int seed,
  }) = _DarumaLook;

  bool get browsComplete => brushCount >= Rules.browsMilestone;
  bool get beardComplete => brushCount >= Rules.beardMilestone;
  bool get goldText => brushCount >= Rules.goldTextMilestone;
  bool get goldRobe => brushCount >= Rules.goldRobeMilestone;
}
