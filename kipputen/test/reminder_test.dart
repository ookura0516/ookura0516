import 'package:flutter_test/flutter_test.dart';
import 'package:kipputen/core/expr.dart';
import 'package:kipputen/daily/daily.dart';

import 'helpers.dart';

void main() {
  final day = Day(2026, 11, 4); // 4027。時計は JST の正午

  test('初期はオフで、何も予約しない', () async {
    final h = await makeHarness(day);
    await h.app.scheduleReminders();
    expect(h.reminders.scheduled, isEmpty);
  });

  test('オンにすると許可を求め、7日分を予約する。文面は4桁', () async {
    final h = await makeHarness(day);
    expect(await h.app.setNotify(true), isTrue);
    expect(h.reminders.asked, 1);
    final s = h.reminders.scheduled;
    // 正午を過ぎているので、今日の 8:00 は出さない。明日から6日分。
    expect(s.length, 6);
    final tomorrow = s[Reminder.idFor(day.addDays(1))]!;
    expect(tomorrow.at, DateTime.utc(2026, 11, 4, 23)); // 11/5 8:00 JST
    expect(tomorrow.body, '今日は ${h.app.picker.forDay(day.addDays(1)).number}');
  });

  test('時刻を変えると、今日の分も（まだ先なら）予約する', () async {
    final h = await makeHarness(day);
    await h.app.setNotify(true);
    await h.app.setNotifyTime(21 * 60);
    final s = h.reminders.scheduled;
    expect(s.length, 7);
    expect(s[Reminder.idFor(day)]!.body, '今日は 4027');
    expect(s[Reminder.idFor(day)]!.at, DateTime.utc(2026, 11, 4, 12));
  });

  test('今日の切符を解いたら、今日の分は取り消す', () async {
    final h = await makeHarness(day);
    await h.app.setNotify(true);
    await h.app.setNotifyTime(21 * 60);
    await h.app.submit('4027', parse(tokenize('7 × 2 − 4 + 0')), daily: true);
    expect(h.reminders.scheduled.containsKey(Reminder.idFor(day)), isFalse);
    expect(h.reminders.scheduled.length, 6);
  });

  test('許可されなければオフのまま', () async {
    final h = await makeHarness(day);
    h.reminders.allow = false;
    expect(await h.app.setNotify(false), isTrue); // オフにするのは許可なしでよい
    expect(await h.app.setNotify(true), isFalse);
    expect(h.app.settings.notify, isFalse);
    expect(h.reminders.scheduled, isEmpty);
  });
}
