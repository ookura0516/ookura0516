import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../core/local_date.dart';
import '../model/models.dart';
import '../paint/daruma_painter.dart';

/// ホーム画面ウィジェットへの書き出し。
///
/// 記録のたびに、だるまの絵（通常・転倒）と残り日数の元データを書く。
/// 日数の計算と「転んでいるか」の判定はウィジェット側（Kotlin / Swift）が
/// 日付から行うので、アプリを開かなくても 0 時に進む。
abstract class WidgetSyncService {
  Future<void> sync(DarumaDetail? detail, LocalDate today);
}

class NoWidgetSync implements WidgetSyncService {
  const NoWidgetSync();

  @override
  Future<void> sync(DarumaDetail? detail, LocalDate today) async {}
}

/// home_widget で書き出す。キーは Android（NanakorobiWidgetProvider.kt）と
/// iOS（NanakorobiWidget.swift）が同じ名前で読む。
class HomeWidgetSync implements WidgetSyncService {
  const HomeWidgetSync();

  static const appGroupId = 'group.com.ookura.nanakorobi';
  static const androidProvider = 'NanakorobiWidgetProvider';
  static const androidQualified = 'com.ookura.nanakorobi.NanakorobiWidgetProvider';
  static const iosWidget = 'NanakorobiWidget';

  // 書き出すキー。
  static const keyHas = 'nk_has';
  static const keyName = 'nk_name';
  static const keyLabel = 'nk_label';
  static const keyDeadline = 'nk_deadline'; // epoch day、なければ -1
  static const keyCreated = 'nk_created';
  static const keyLastStep = 'nk_last_step'; // epoch day、なければ -1
  static const keyBrush = 'nk_brush';
  static const keyRises = 'nk_rises';
  static const keyEyes = 'nk_eyes';
  static const keySynced = 'nk_synced';
  static const keyImageUp = 'nk_img_up';
  static const keyImageFallen = 'nk_img_fallen';

  static Future<void> init() async {
    if (Platform.isIOS) await HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<void> sync(DarumaDetail? detail, LocalDate today) async {
    try {
      if (detail == null) {
        await HomeWidget.saveWidgetData<bool>(keyHas, false);
        await _update();
        return;
      }
      final d = detail.daruma;
      final look = detail.lookOn(today).copyWith(fallen: false);
      await HomeWidget.renderFlutterWidget(
        _DarumaImage(look),
        key: keyImageUp,
        logicalSize: const Size(300, 380),
        pixelRatio: 2,
      );
      await HomeWidget.renderFlutterWidget(
        _DarumaImage(look.copyWith(fallen: true)),
        key: keyImageFallen,
        logicalSize: const Size(300, 380),
        pixelRatio: 2,
      );
      await HomeWidget.saveWidgetData<String>(keyName, d.name);
      await HomeWidget.saveWidgetData<String>(keyLabel, d.deadlineLabel ?? '');
      await HomeWidget.saveWidgetData<int>(keyDeadline, d.deadline?.epochDay ?? -1);
      await HomeWidget.saveWidgetData<int>(keyCreated, d.createdOn.epochDay);
      await HomeWidget.saveWidgetData<int>(keyLastStep, detail.lastStepOn?.epochDay ?? -1);
      await HomeWidget.saveWidgetData<int>(keyBrush, detail.brushCount);
      await HomeWidget.saveWidgetData<int>(keyRises, detail.riseCount);
      await HomeWidget.saveWidgetData<int>(keyEyes, look.openedEyes);
      await HomeWidget.saveWidgetData<int>(keySynced, today.epochDay);
      await HomeWidget.saveWidgetData<bool>(keyHas, true);
      await _update();
      await _scheduleMidnights();
    } catch (e, st) {
      // ウィジェットが置かれていない端末でも記録を止めない。
      debugPrint('widget sync failed: $e\n$st');
    }
  }

  Future<void> _update() => HomeWidget.updateWidget(
        androidName: androidProvider,
        qualifiedAndroidName: androidQualified,
        iOSName: iosWidget,
      );

  /// Android：これから14日分の 0 時（端末のタイムゾーン）に更新を予約する。
  /// iOS は WidgetKit の Timeline（NanakorobiWidget.swift）が同じことをする。
  Future<void> _scheduleMidnights() async {
    if (!Platform.isAndroid) return;
    final now = DateTime.now();
    final times = [
      for (var i = 1; i <= 14; i++) DateTime(now.year, now.month, now.day + i, 0, 0, 5),
    ];
    await HomeWidget.scheduleWidgetUpdates(
      times,
      androidName: androidProvider,
      qualifiedAndroidName: androidQualified,
    );
  }
}

class _DarumaImage extends StatelessWidget {
  const _DarumaImage(this.look);

  final DarumaLook look;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 380,
      child: CustomPaint(painter: DarumaPainter(look)),
    );
  }
}
