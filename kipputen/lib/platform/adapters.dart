import 'dart:typed_data';

import 'package:home_widget/home_widget.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:share_plus/share_plus.dart';

import '../daily/daily.dart';

/// 共有シートへ渡す窓口。テストでは記録するだけのものに差し替える。
abstract class ShareService {
  Future<void> sharePng(List<int> png, {required String text});
}

class SharePlusService implements ShareService {
  const SharePlusService();

  @override
  Future<void> sharePng(List<int> png, {required String text}) async {
    await SharePlus.instance.share(
      ShareParams(
        text: text,
        files: [
          XFile.fromData(
            Uint8List.fromList(png),
            mimeType: 'image/png',
            name: 'kipputen.png',
          ),
        ],
      ),
    );
  }
}

/// 評価依頼。
abstract class ReviewService {
  Future<void> request();
}

class InAppReviewService implements ReviewService {
  const InAppReviewService();

  @override
  Future<void> request() async {
    final r = InAppReview.instance;
    if (await r.isAvailable()) await r.requestReview();
  }
}

class NoReviewService implements ReviewService {
  const NoReviewService();
  @override
  Future<void> request() async {}
}

/// home_widget に書く。Android は KipputenWidgetProvider、iOS は KipputenWidget。
class HomeWidgetSink implements WidgetSink {
  const HomeWidgetSink();

  static const androidName = 'KipputenWidgetProvider';
  static const iOSName = 'KipputenWidget';

  /// iOS のアプリグループ。Xcode でウィジェットの target を作るときに同じ名前を使う。
  static const appGroupId = 'group.com.ookura.kipputen';

  @override
  Future<void> save(Map<String, Object> data) async {
    await HomeWidget.setAppGroupId(appGroupId);
    for (final e in data.entries) {
      await HomeWidget.saveWidgetData<String>(e.key, '${e.value}');
    }
  }

  @override
  Future<void> refresh({required List<DateTime> at}) async {
    await HomeWidget.updateWidget(androidName: androidName, iOSName: iOSName);
    try {
      await HomeWidget.scheduleWidgetUpdates(at, androidName: androidName);
    } catch (_) {
      // ウィジェットを置いていない端末では予約できない。置いたときに描き直される。
    }
  }
}
