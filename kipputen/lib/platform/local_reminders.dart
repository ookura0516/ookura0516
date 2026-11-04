import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

import '../daily/reminder.dart';

/// flutter_local_notifications で、端末の中だけで通知を予約する（サーバーは使わない）。
///
/// Android は正確なアラームの権限を使わず、おおよその時刻で出す（数分ずれることがある）。
class LocalReminderService implements ReminderService {
  LocalReminderService();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'daily',
      '今日の切符',
      channelDescription: '1日1回、今日の4桁をお知らせします',
      icon: 'ic_stat_ticket',
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_stat_ticket'),
        // 許可は設定で通知をオンにしたときに求める（起動時には出さない）。
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> replaceAll(Map<int, Reminder> reminders) async {
    await init();
    await _plugin.cancelAll();
    for (final e in reminders.entries) {
      await _plugin.zonedSchedule(
        id: e.key,
        scheduledDate: tz.TZDateTime.from(e.value.at, tz.UTC),
        notificationDetails: _details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        title: e.value.title,
        body: e.value.body,
      );
    }
  }
}
