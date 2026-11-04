import 'dart:convert';

import 'package:home_widget/home_widget.dart';

import '../model/models.dart';

/// ウィジェットへの書き込み。
///
/// 保存のたびに App Group（iOS）と SharedPreferences（Android）へ、DarumaLook と
/// 14日分の残り日数（WidgetSnapshot の JSON）を書き、更新を要求する。
/// ネイティブ側（WidgetKit / Glance）の実装手順は docs/WIDGETS.md。
abstract class WidgetSyncService {
  /// [snapshot] が null なら「だるまなし」の表示にする。
  Future<void> sync(WidgetSnapshot? snapshot);
}

class HomeWidgetSyncService implements WidgetSyncService {
  const HomeWidgetSyncService();

  /// iOS の App Group。Xcode で Runner と Widget Extension の両方に付ける。
  static const appGroupId = 'group.com.ookura.nanakorobi';

  /// JSON を入れるキー。ネイティブ側はこのキーを読む。
  static const snapshotKey = 'nanakorobi_snapshot';

  static const iOSWidgetName = 'NanakorobiWidget';
  static const androidWidgetName = 'NanakorobiWidgetReceiver';
  static const androidQualifiedName = 'com.ookura.nanakorobi.NanakorobiWidgetReceiver';

  @override
  Future<void> sync(WidgetSnapshot? snapshot) async {
    try {
      await HomeWidget.setAppGroupId(appGroupId);
      await HomeWidget.saveWidgetData<String>(
        snapshotKey,
        snapshot == null ? null : jsonEncode(snapshot.toJson()),
      );
      await HomeWidget.updateWidget(
        iOSName: iOSWidgetName,
        androidName: androidWidgetName,
        qualifiedAndroidName: androidQualifiedName,
      );
      // Android：各日の 0 時（端末のタイムゾーン）に描き直す。iOS は WidgetKit のタイムラインが進めるので何もしない。
      // 翌日分の表示は JSON に入っているので、Doze で遅れても日付で正しい行を選べる。
      final midnights = snapshot == null
          ? <DateTime>[]
          : [for (final e in snapshot.timeline.skip(1)) e.date.toDateTime()];
      if (midnights.isEmpty) {
        await HomeWidget.cancelScheduledWidgetUpdates(qualifiedAndroidName: androidQualifiedName);
      } else {
        await HomeWidget.scheduleWidgetUpdates(midnights, qualifiedAndroidName: androidQualifiedName);
      }
    } catch (_) {
      // ウィジェットが置かれていない、または未対応の環境。アプリは止めない。
    }
  }
}

class RecordingWidgetSyncService implements WidgetSyncService {
  final List<WidgetSnapshot?> synced = [];

  WidgetSnapshot? get last => synced.isEmpty ? null : synced.last;

  @override
  Future<void> sync(WidgetSnapshot? snapshot) async => synced.add(snapshot);
}
