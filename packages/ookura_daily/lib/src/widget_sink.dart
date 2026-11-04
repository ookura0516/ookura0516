import 'dart:io';

import 'package:home_widget/home_widget.dart';

import 'widget_snapshot.dart';

/// ウィジェット用データの書き出し先。テストでは差し替える。
abstract class DailyWidgetSink {
  Future<void> write(DailyWidgetSnapshot snapshot);
}

/// 何もしない。ウィジェットのない環境（テスト・Web）で使う。
class NoWidgetSink implements DailyWidgetSink {
  const NoWidgetSink();

  @override
  Future<void> write(DailyWidgetSnapshot snapshot) async {}
}

/// home_widget で iOS（App Group の UserDefaults）と Android
/// （SharedPreferences）に書き、ウィジェットを描き直させる。
///
/// 日付の切り替えは、iOS ではネイティブ側のタイムライン（切り替え時刻に
/// 翌日分の項目を置く）で、Android では切り替え時刻にウィジェットの更新を
/// 予約して行う（アプリを開かなくても0時に進む）。
class HomeWidgetSink implements DailyWidgetSink {
  const HomeWidgetSink({this.appGroupId, this.iOSName, this.androidName});

  /// iOS の App Group ID（例：`group.com.example.app`）。
  final String? appGroupId;

  /// iOS のウィジェットの kind。
  final String? iOSName;

  /// Android の AppWidgetProvider のクラス名。
  final String? androidName;

  @override
  Future<void> write(DailyWidgetSnapshot snapshot) async {
    try {
      final group = appGroupId;
      if (group != null) await HomeWidget.setAppGroupId(group);
      for (final e in snapshot.toMap().entries) {
        await HomeWidget.saveWidgetData<String>(e.key, e.value);
      }
      await HomeWidget.updateWidget(iOSName: iOSName, androidName: androidName);
      if (androidName != null && Platform.isAndroid) {
        await HomeWidget.scheduleWidgetUpdates([
          snapshot.switchAt,
          snapshot.switchAt.add(const Duration(minutes: 5)),
        ], androidName: androidName);
      }
    } catch (_) {
      // ウィジェットを置いていない、App Group が未設定などで失敗しても、
      // アプリの動作は止めない。
    }
  }
}
