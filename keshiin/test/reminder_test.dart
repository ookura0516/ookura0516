import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/day_slots.dart';
import 'package:keshiin/core/reminder.dart';
import 'package:keshiin/platform/services.dart';

import 'data_test.dart' show jpegWithExif;
import 'fakes.dart';

void main() {
  group('予約する日', () {
    const t = ReminderTime(20, 0);

    test('今日の時刻の前なら今日から、14日ぶん', () {
      final plan = reminderSchedule(
        now: DateTime(2026, 11, 4, 9),
        time: t,
        filled: {},
      );
      expect(plan.length, reminderHorizonDays);
      expect(plan.first.at, DateTime(2026, 11, 4, 20));
      expect(plan.last.day, const Day(2026, 11, 17));
    });

    test('今日の時刻を過ぎていたら明日から', () {
      final plan = reminderSchedule(
        now: DateTime(2026, 11, 4, 20, 0),
        time: t,
        filled: {},
      );
      expect(plan.first.day, const Day(2026, 11, 5));
      expect(plan.length, reminderHorizonDays - 1);
    });

    test('切手を貼った日は知らせない（1日1回まで）', () {
      final plan = reminderSchedule(
        now: DateTime(2026, 11, 4, 9),
        time: t,
        filled: {const Day(2026, 11, 4), const Day(2026, 11, 6)},
      );
      final days = plan.map((p) => p.day).toList();
      expect(days, isNot(contains(const Day(2026, 11, 4))));
      expect(days, isNot(contains(const Day(2026, 11, 6))));
      expect(days.toSet().length, days.length);
    });

    test('月・年をまたぐ', () {
      final plan = reminderSchedule(
        now: DateTime(2026, 12, 30, 9),
        time: t,
        filled: {},
      );
      expect(plan.map((p) => p.day), contains(const Day(2027, 1, 2)));
    });

    test('通知の id は日ごとに違う', () {
      expect(
        reminderId(const Day(2026, 11, 4)),
        isNot(reminderId(const Day(2026, 11, 5))),
      );
      expect(
        reminderId(const Day(2026, 12, 31)),
        isNot(reminderId(const Day(2027, 1, 1))),
      );
    });

    test('時刻の保存形式', () {
      expect(ReminderTime.parse('7:05'), const ReminderTime(7, 5));
      expect(const ReminderTime(7, 5).encode(), '7:05');
      expect(ReminderTime.parse('25:00'), ReminderTime.defaultTime);
      expect(ReminderTime.parse(null), ReminderTime.defaultTime);
    });

    test('文面は「今日の切手を貼る？」だけ', () {
      expect(reminderBody, '今日の切手を貼る？');
    });
  });

  group('アプリの状態', () {
    test('初期はオフで、何も予約しない', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      expect(h.app.settings.reminderOn, isFalse);
      await h.app.refreshWidget();
      expect(h.reminders.scheduled, isEmpty);
      expect(h.reminders.permissionAsks, 0);
    });

    test('オンにすると許可を求めて予約し、今日貼ると今日の分が消える', () async {
      final h = await Harness.create(); // 2026-11-04 9:30
      addTearDown(h.close);
      expect(await h.app.setReminder(on: true), isTrue);
      expect(h.reminders.permissionAsks, 1);
      expect(h.reminders.scheduled.first, DateTime(2026, 11, 4, 20));

      final d = await h.app.startDraft(PickedPhoto(jpegWithExif()));
      await h.app.saveDraft(d);
      expect(h.reminders.scheduled.first, DateTime(2026, 11, 5, 20));
    });

    test('許可されなければオフのまま', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      h.reminders.grant = false;
      expect(await h.app.setReminder(on: true), isFalse);
      expect(h.app.settings.reminderOn, isFalse);
      expect(h.reminders.scheduled, isEmpty);
    });

    test('時刻を変えると予約し直す。オフで全部取り消す', () async {
      final h = await Harness.create();
      addTearDown(h.close);
      await h.app.setReminder(on: true, time: const ReminderTime(7, 30));
      expect(h.reminders.scheduled.first, DateTime(2026, 11, 5, 7, 30));
      await h.app.setReminder(on: false);
      expect(h.reminders.scheduled, isEmpty);
    });
  });

  testWidgets('設定でリマインダーをオンにできる。通知から開くと写真の選択を開く', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    await pumpApp(tester, h);
    await tester.tap(find.byKey(const Key('tab-settings')));
    await tester.pumpAndSettle();
    final sw = find.byKey(const Key('reminder-switch'));
    await tester.ensureVisible(sw);
    await tester.pumpAndSettle();
    await tester.tap(sw);
    await tester.pumpAndSettle();
    expect(h.app.settings.reminderOn, isTrue);
    expect(h.reminders.scheduled, isNotEmpty);
    expect(find.text('20:00'), findsOneWidget);

    h.reminders.controller.add(Uri.parse('keshiin://create'));
    await tester.pumpAndSettle();
    expect(find.text('切手を作る'), findsOneWidget);
    expect(h.photos.calls, 1);
  });

  testWidgets('通知が許可されないと、そう知らせる', (tester) async {
    final h = await Harness.create();
    addTearDown(h.close);
    h.reminders.grant = false;
    await pumpApp(tester, h);
    await tester.tap(find.byKey(const Key('tab-settings')));
    await tester.pumpAndSettle();
    final sw = find.byKey(const Key('reminder-switch'));
    await tester.ensureVisible(sw);
    await tester.pumpAndSettle();
    await tester.tap(sw);
    await tester.pumpAndSettle();
    expect(find.textContaining('通知が許可されていません'), findsOneWidget);
    expect(h.app.settings.reminderOn, isFalse);
  });
}
