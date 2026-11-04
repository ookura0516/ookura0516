import 'package:flutter_test/flutter_test.dart';
import 'package:nanakorobi/core/backup.dart';
import 'package:nanakorobi/core/local_date.dart';
import 'package:nanakorobi/core/look_builder.dart';
import 'package:nanakorobi/core/strokes.dart';
import 'package:nanakorobi/model/models.dart';

Daruma daruma({
  DarumaStatus status = DarumaStatus.active,
  LocalDate? deadline,
  DateTime? completedAt,
  int sizeRank = 1,
}) =>
    Daruma(
      id: 'd1',
      name: '合格',
      colorId: 0,
      eyeSide: EyeSide.left,
      createdAt: DateTime(2027, 1, 1, 9),
      openedOn: const LocalDate(2027, 1, 1),
      deadline: deadline,
      deadlineName: deadline == null ? null : '共通テスト',
      status: status,
      completedAt: completedAt,
      sizeRank: sizeRank,
      seed: 42,
    );

Checkin step(int day, {CheckinKind kind = CheckinKind.step}) => Checkin(
      id: 'c$day',
      darumaId: 'd1',
      date: LocalDate(2027, 1, day),
      kind: kind,
      createdAt: DateTime(2027, 1, day, 20),
    );

void main() {
  group('LookBuilder', () {
    test('筆の数・金の筋・目・残り日数・転倒がそろう', () {
      final look = buildLook(
        daruma: daruma(deadline: const LocalDate(2027, 1, 16)),
        checkins: [step(1), step(2), step(3), step(5, kind: CheckinKind.rest), step(6), step(9)],
        recoveries: [
          const Recovery(
            id: 'r1',
            darumaId: 'd1',
            fellAfter: LocalDate(2027, 1, 6),
            roseOn: LocalDate(2027, 1, 9),
          ),
        ],
        today: const LocalDate(2027, 1, 9),
      );
      expect(look.strokes, 5);
      expect(look.goldLines, 1);
      expect(look.riseCount, 1);
      expect(look.eyes, EyeState.one);
      expect(look.firstEye, EyeSide.left);
      expect(look.fallen, isFalse);
      expect(look.recordedToday, isTrue);
      expect(look.daysLeft, 7);
      expect(look.deadlineName, '共通テスト');
      expect(look.daysSinceOpened, 8);
      expect(look.streak, 1);
      expect(look.milestone, isNull);
    });

    test('空白の翌日は転倒中。今日の記録はまだ', () {
      final look = buildLook(
        daruma: daruma(),
        checkins: [step(1), step(2)],
        recoveries: const [],
        today: const LocalDate(2027, 1, 4),
      );
      expect(look.fallen, isTrue);
      expect(look.recordedToday, isFalse);
      expect(look.strokes, 2);
    });

    test('満願は両目で、転倒も残り日数もない', () {
      final look = buildLook(
        daruma: daruma(
          status: DarumaStatus.completed,
          deadline: const LocalDate(2027, 1, 16),
          completedAt: DateTime(2027, 1, 20, 12),
        ),
        checkins: [step(1)],
        recoveries: const [],
        today: const LocalDate(2027, 2, 1),
      );
      expect(look.eyes, EyeState.both);
      expect(look.fallen, isFalse);
      expect(look.daysLeft, isNull);
      expect(look.completedOn, const LocalDate(2027, 1, 20));
    });

    test('納めは片目のまま', () {
      final look = buildLook(
        daruma: daruma(status: DarumaStatus.retired),
        checkins: const [],
        recoveries: const [],
        today: const LocalDate(2027, 3, 1),
      );
      expect(look.eyes, EyeState.one);
      expect(look.fallen, isFalse);
    });

    test('節目と金の文字・金彩', () {
      final many = List.generate(100, (i) => step(1).copyWith(id: 'x$i', date: const LocalDate(2027, 1, 1).addDays(i)));
      final look = buildLook(
        daruma: daruma(),
        checkins: many,
        recoveries: const [],
        today: const LocalDate(2027, 4, 10),
      );
      expect(look.strokes, 100);
      expect(look.milestone, StrokeMilestone.day100);
      expect(look.goldText, isTrue);
      expect(look.goldRobe, isTrue);
    });

    test('DarumaLook は JSON に往復できる（ウィジェットへ渡す）', () {
      final look = buildLook(
        daruma: daruma(deadline: const LocalDate(2027, 1, 16)),
        checkins: [step(1)],
        recoveries: const [],
        today: const LocalDate(2027, 1, 2),
      );
      final back = DarumaLook.fromJson(look.toJson());
      expect(back, look);
      expect(look.toJson()['days_left'], 14);
    });
  });

  group('バックアップ', () {
    test('書き出して読み込むと同じになる', () {
      final bundle = DarumaBundle(
        daruma: daruma(deadline: const LocalDate(2027, 1, 16)),
        checkins: [step(1), step(2)],
        recoveries: const [
          Recovery(id: 'r1', darumaId: 'd1', fellAfter: LocalDate(2027, 1, 2), roseOn: LocalDate(2027, 1, 5)),
        ],
        milestones: const [
          Milestone(id: 'm1', darumaId: 'd1', name: '模試', date: LocalDate(2027, 1, 10)),
        ],
      );
      final data = BackupCodec.fromBundles(
        [bundle],
        exportedAt: DateTime(2027, 1, 6, 10),
        settings: const AppSettings(reminderEnabled: true),
      );
      final text = BackupCodec.encode(data);
      final back = BackupCodec.decode(text);
      expect(back.darumas.single, bundle.daruma);
      expect(back.checkins, bundle.checkins);
      expect(back.recoveries, bundle.recoveries);
      expect(back.milestones, bundle.milestones);
      expect(back.settings?.reminderEnabled, isTrue);
      final bundles = BackupCodec.toBundles(back);
      expect(bundles.single.checkins.length, 2);
    });

    test('版が違う・形が違うときは読まない', () {
      expect(() => BackupCodec.decode('[]'), throwsFormatException);
      expect(() => BackupCodec.decode('{"version": 99}'), throwsFormatException);
      expect(() => BackupCodec.decode('not json'), throwsFormatException);
    });
  });
}
