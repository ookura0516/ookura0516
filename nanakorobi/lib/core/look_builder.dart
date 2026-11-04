import '../model/models.dart';
import 'countdown.dart';
import 'fall.dart';
import 'local_date.dart';

/// Daruma と記録から描画仕様（DarumaLook）を作る純関数。
///
/// 画面・ウィジェット・共有画像はすべてこの結果から描く。
DarumaLook buildLook({
  required Daruma daruma,
  required Iterable<Checkin> checkins,
  required Iterable<Recovery> recoveries,
  required LocalDate today,
}) {
  final steps = checkins
      .where((c) => c.kind == CheckinKind.step && c.date <= today)
      .map((c) => c.date)
      .toList();
  final rests = checkins.where((c) => c.kind == CheckinKind.rest).map((c) => c.date).toList();
  final strokes = steps.length;
  final active = daruma.status == DarumaStatus.active;

  final fallen = active &&
      FallJudge.isFallen(
        openedOn: daruma.openedOn,
        today: today,
        stepDates: steps,
        restDates: rests,
      );

  final eyes = switch (daruma.status) {
    DarumaStatus.active => EyeState.one,
    DarumaStatus.completed => EyeState.both,
    DarumaStatus.retired => EyeState.one,
  };

  final deadline = daruma.deadline;

  return DarumaLook(
    darumaId: daruma.id,
    text: daruma.name,
    colorId: daruma.colorId,
    seed: daruma.seed,
    strokes: strokes,
    goldLines: recoveries.length,
    firstEye: daruma.eyeSide,
    eyes: eyes,
    sizeRank: daruma.sizeRank,
    fallen: fallen,
    status: daruma.status,
    openedOn: daruma.openedOn,
    completedOn: daruma.completedOn,
    daysLeft: deadline == null || !active ? null : Countdown.daysLeft(deadline, today),
    deadlineName: daruma.deadlineName,
    streak: active ? FallJudge.streak(today: today, stepDates: steps, restDates: rests) : 0,
    recordedToday: steps.contains(today),
    daysSinceOpened: today.difference(daruma.openedOn),
  );
}

DarumaLook buildLookFromBundle(DarumaBundle b, LocalDate today) => buildLook(
      daruma: b.daruma,
      checkins: b.checkins,
      recoveries: b.recoveries,
      today: today,
    );
