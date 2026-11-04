import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../core/reminder_planner.dart';

/// リマインド通知。既定オフ。オンにすると1日1回、指定時刻。
///
/// 通知文の残り日数は配信時に正しくなるよう、14日分を日ごとの本文で予約し、
/// アプリを開くたびに予約し直す（ReminderPlanner）。
abstract class ReminderService {
  Future<bool> requestPermission();

  /// それまでの予約をすべて消してから入れ直す。
  Future<void> schedule(List<ReminderEntry> entries, {required ReminderTexts texts});

  Future<void> cancelAll();
}

/// 通知文（画面の言語で作る）。
class ReminderTexts {
  const ReminderTexts({required this.title, required this.body});

  final String Function(ReminderEntry entry) title;
  final String Function(ReminderEntry entry) body;
}

class LocalReminderService implements ReminderService {
  LocalReminderService({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const channelId = 'nanakorobi_reminder';
  static const channelName = 'Reminder';

  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;

  Future<void> _init() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
    _initialized = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      return await android.requestNotificationsPermission() ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      return await ios.requestPermissions(alert: true, badge: false, sound: true) ?? false;
    }
    return false;
  }

  @override
  Future<void> schedule(List<ReminderEntry> entries, {required ReminderTexts texts}) async {
    await _init();
    await _plugin.cancelAll();
    const details = NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: DarwinNotificationDetails(),
    );
    for (final e in entries) {
      // 端末ローカルの時刻を UTC の瞬間に直して予約する（日本には夏時間がない）。
      final at = tz.TZDateTime.from(e.at.toUtc(), tz.UTC);
      await _plugin.zonedSchedule(
        id: e.notificationId,
        title: texts.title(e),
        body: texts.body(e),
        scheduledDate: at,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }
}

class FakeReminderService implements ReminderService {
  FakeReminderService({this.granted = true});

  bool granted;
  List<ReminderEntry> scheduled = [];
  List<String> bodies = [];
  int cancels = 0;

  @override
  Future<bool> requestPermission() async => granted;

  @override
  Future<void> schedule(List<ReminderEntry> entries, {required ReminderTexts texts}) async {
    scheduled = List.of(entries);
    bodies = [for (final e in entries) texts.body(e)];
  }

  @override
  Future<void> cancelAll() async {
    cancels++;
    scheduled = [];
    bodies = [];
  }
}
