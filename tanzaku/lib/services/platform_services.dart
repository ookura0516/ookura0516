import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gal/gal.dart';
import 'package:home_widget/home_widget.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

// ------------------------------------------------------------ 共有と保存

/// 画像やファイルを共有シートに出す、写真に保存する、ファイルを選ぶ。
abstract class ShareSink {
  Future<void> shareImage(Uint8List png, String name, {String? text});
  Future<void> saveImage(Uint8List png, String name);
  Future<void> shareFile(Uint8List bytes, String name, String mimeType);

  /// JSON ファイルを選んで中身を返す。選ばなければ null。
  Future<String?> pickJsonText();
}

class PlatformShareSink implements ShareSink {
  Future<XFile> _temp(Uint8List bytes, String name, String mime) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    return XFile(file.path, mimeType: mime, name: name);
  }

  @override
  Future<void> shareImage(Uint8List png, String name, {String? text}) async {
    final f = await _temp(png, name, 'image/png');
    await SharePlus.instance.share(ShareParams(files: [f], text: text));
  }

  @override
  Future<void> saveImage(Uint8List png, String name) async {
    if (!await Gal.hasAccess()) await Gal.requestAccess();
    await Gal.putImageBytes(png, name: name.replaceAll('.png', ''));
  }

  @override
  Future<void> shareFile(Uint8List bytes, String name, String mimeType) async {
    final f = await _temp(bytes, name, mimeType);
    await SharePlus.instance.share(ShareParams(files: [f]));
  }

  @override
  Future<String?> pickJsonText() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (files.isEmpty) return null;
    return utf8.decode(await files.first.xFile.readAsBytes());
  }
}

// ------------------------------------------------------------ 評価依頼

abstract class ReviewPrompter {
  Future<void> request();
}

class InAppReviewPrompter implements ReviewPrompter {
  @override
  Future<void> request() async {
    final r = InAppReview.instance;
    if (await r.isAvailable()) await r.requestReview();
  }
}

// ------------------------------------------------------------ 通知

/// 兼題の通知。1日1回、内容は季語そのもの。
abstract class NotificationService {
  Future<bool> requestPermission();

  /// [items] の日付それぞれの [minutes]（0時からの分）に通知を入れる。前の予定は消す。
  Future<void> scheduleThemes(
    List<(DateTime date, String title, String body)> items,
    int minutes,
  );
  Future<void> cancelAll();

  /// 通知をタップしてアプリが起動したときの payload（tanzaku://compose）。
  Future<Uri?> launchLink();

  /// アプリを開いている間に通知をタップしたとき。
  Stream<Uri?> get taps;
}

class LocalNotificationService implements NotificationService {
  final _plugin = FlutterLocalNotificationsPlugin();
  final _taps = StreamController<Uri?>.broadcast();
  bool _ready = false;

  @override
  Stream<Uri?> get taps => _taps.stream;

  @override
  Future<Uri?> launchLink() async {
    try {
      await _init();
      final d = await _plugin.getNotificationAppLaunchDetails();
      if (d == null || !d.didNotificationLaunchApp) return null;
      return Uri.tryParse(d.notificationResponse?.payload ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> _init() async {
    if (_ready) return;
    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Tokyo'));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (r) =>
          _taps.add(Uri.tryParse(r.payload ?? '')),
    );
    _ready = true;
  }

  @override
  Future<bool> requestPermission() async {
    await _init();
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >();
      return await ios?.requestPermissions(alert: true, sound: true) ?? false;
    }
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ?? true;
  }

  @override
  Future<void> scheduleThemes(
    List<(DateTime, String, String)> items,
    int minutes,
  ) async {
    await _init();
    await _plugin.cancelAll();
    final now = tz.TZDateTime.now(tz.local);
    var id = 0;
    for (final (date, title, body) in items) {
      final at = tz.TZDateTime(
        tz.local,
        date.year,
        date.month,
        date.day,
        minutes ~/ 60,
        minutes % 60,
      );
      if (at.isBefore(now)) continue;
      await _plugin.zonedSchedule(
        id: id++,
        scheduledDate: at,
        title: title,
        body: body,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'theme',
            '今日の兼題',
            channelDescription: '1日1回、今日の季語をお知らせします',
            importance: Importance.defaultImportance,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'tanzaku://compose',
      );
    }
  }

  @override
  Future<void> cancelAll() async {
    await _init();
    await _plugin.cancelAll();
  }
}

// ------------------------------------------------------------ ホーム画面のウィジェット

/// ウィジェットに出す中身。翌日分も書いておき、ウィジェット側が日本時間の0時で切り替える。
class WidgetSnapshot {
  const WidgetSnapshot({
    required this.date,
    required this.kigo,
    required this.kigoReading,
    required this.season,
    required this.tomorrowDate,
    required this.tomorrowKigo,
    required this.tomorrowReading,
    required this.tomorrowSeason,
    required this.streak,
    required this.composedToday,
    required this.latestHaiku,
  });

  final String date;
  final String kigo;
  final String kigoReading;
  final String season;
  final String tomorrowDate;
  final String tomorrowKigo;
  final String tomorrowReading;
  final String tomorrowSeason;
  final int streak;
  final bool composedToday;
  final String latestHaiku;

  Map<String, Object> toMap() => {
    'date': date,
    'kigo': kigo,
    'kigo_reading': kigoReading,
    'season': season,
    'tomorrow_date': tomorrowDate,
    'tomorrow_kigo': tomorrowKigo,
    'tomorrow_reading': tomorrowReading,
    'tomorrow_season': tomorrowSeason,
    'streak': streak,
    'composed_today': composedToday,
    'latest_haiku': latestHaiku,
  };
}

abstract class HomeWidgetService {
  Future<void> update(WidgetSnapshot s);

  /// ウィジェットから開かれたときの URI（tanzaku://compose）。
  Future<Uri?> initialLaunch();
  Stream<Uri?> get clicks;
}

class HomeWidgetBridge implements HomeWidgetService {
  /// iOS の App Group（Xcode でウィジェットの target と本体の両方に付ける）。
  static const appGroupId = 'group.com.ookura.tanzaku';

  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    if (Platform.isIOS) await HomeWidget.setAppGroupId(appGroupId);
    _ready = true;
  }

  @override
  Future<void> update(WidgetSnapshot s) async {
    try {
      await _init();
      for (final e in s.toMap().entries) {
        await HomeWidget.saveWidgetData<Object>(e.key, e.value);
      }
      await HomeWidget.updateWidget(
        iOSName: 'TanzakuWidget',
        qualifiedAndroidName: 'com.ookura.tanzaku.TanzakuWidgetProvider',
      );
    } catch (e) {
      // ウィジェットを置いていない、iOS で target を足していない、など。アプリは止めない。
      debugPrint('widget update skipped: $e');
    }
  }

  @override
  Future<Uri?> initialLaunch() async {
    try {
      await _init();
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<Uri?> get clicks => HomeWidget.widgetClicked;
}
