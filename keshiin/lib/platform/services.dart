import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:geocoding/geocoding.dart';
import 'package:home_widget/home_widget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../core/widget_snapshot.dart';

/// 選んだ写真。
class PickedPhoto {
  const PickedPhoto(this.bytes, {this.name = ''});
  final Uint8List bytes;
  final String name;
}

/// 写真の選択。権限の要らない OS のピッカーを使い、写真ライブラリ全体へのアクセスは求めない。
abstract class PhotoSource {
  Future<List<PickedPhoto>> pick({bool multiple = false});
}

class SystemPhotoSource implements PhotoSource {
  final _picker = ImagePicker();

  @override
  Future<List<PickedPhoto>> pick({bool multiple = false}) async {
    // requestFullMetadata: false で、iOS の写真ライブラリの権限を求めない（PHPicker）。
    // Android は Photo Picker を使う。どちらも権限ダイアログは出ない。
    final files = multiple
        ? await _picker.pickMultiImage(requestFullMetadata: false)
        : [
            ?await _picker.pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            ),
          ];
    return [
      for (final f in files) PickedPhoto(await f.readAsBytes(), name: f.name),
    ];
  }
}

/// 海外の写真の地名。通信できるときだけ OS の逆ジオコーディングを使う。
abstract class OverseasGeocoder {
  Future<String?> placeName(double lat, double lng);
}

class SystemOverseasGeocoder implements OverseasGeocoder {
  @override
  Future<String?> placeName(double lat, double lng) async {
    try {
      final list = await Geocoding(
        locale: const Locale('ja', 'JP'),
      ).placemarkFromCoordinates(lat, lng).timeout(const Duration(seconds: 6));
      if (list.isEmpty) return null;
      final p = list.first;
      for (final s in [
        p.locality,
        p.subAdministrativeArea,
        p.administrativeArea,
        p.country,
      ]) {
        if (s != null && s.trim().isNotEmpty) return s.trim();
      }
      return null;
    } catch (_) {
      // 通信できない・OS が答えない。場所は空のままにし、履歴から選んでもらう。
      return null;
    }
  }
}

abstract class Sharer {
  Future<void> shareFiles(List<String> paths, {String? text});
}

class SystemSharer implements Sharer {
  @override
  Future<void> shareFiles(List<String> paths, {String? text}) async {
    await SharePlus.instance.share(
      ShareParams(files: [for (final p in paths) XFile(p)], text: text),
    );
  }
}

/// ホーム画面のウィジェット。
abstract class WidgetBridge {
  Future<void> publish(WidgetSnapshot today, WidgetSnapshot tomorrow);

  /// ウィジェットから開かれたときの URI（keshiin://create など）。
  Stream<Uri?> get launches;
  Future<Uri?> initialLaunch();
}

class HomeWidgetBridge implements WidgetBridge {
  static const appGroupId = 'group.com.ookura.keshiin';
  static const androidProvider = 'KeshiinWidgetProvider';
  static const iosKind = 'KeshiinWidget';

  bool _ready = false;

  Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    await HomeWidget.setAppGroupId(appGroupId);
  }

  @override
  Future<void> publish(WidgetSnapshot today, WidgetSnapshot tomorrow) async {
    try {
      await _init();
      final data = {...today.toMap('today_'), ...tomorrow.toMap('next_')};
      for (final e in data.entries) {
        await HomeWidget.saveWidgetData(e.key, e.value);
      }
      await HomeWidget.updateWidget(
        androidName: androidProvider,
        iOSName: iosKind,
      );
    } catch (_) {
      // ウィジェットが無い端末・テスト環境では何もしない。
    }
  }

  @override
  Stream<Uri?> get launches => HomeWidget.widgetClicked;

  @override
  Future<Uri?> initialLaunch() async {
    try {
      return await HomeWidget.initiallyLaunchedFromHomeWidget();
    } catch (_) {
      return null;
    }
  }
}

abstract class ReviewPrompter {
  Future<void> request();
}

class SystemReviewPrompter implements ReviewPrompter {
  @override
  Future<void> request() async {
    try {
      final r = InAppReview.instance;
      if (await r.isAvailable()) await r.requestReview();
    } catch (_) {}
  }
}

/// 端末の機能をまとめたもの。テストでは偽物に差し替える。
class PlatformServices {
  PlatformServices({
    required this.photos,
    required this.geocoder,
    required this.sharer,
    required this.widgets,
    required this.review,
  });

  factory PlatformServices.system() => PlatformServices(
    photos: SystemPhotoSource(),
    geocoder: SystemOverseasGeocoder(),
    sharer: SystemSharer(),
    widgets: HomeWidgetBridge(),
    review: SystemReviewPrompter(),
  );

  final PhotoSource photos;
  final OverseasGeocoder geocoder;
  final Sharer sharer;
  final WidgetBridge widgets;
  final ReviewPrompter review;
}
