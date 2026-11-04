import 'package:in_app_review/in_app_review.dart';

/// 評価依頼。コア行動の直後（7日目の節目、両目）にだけ出す。
/// Apple は 365 日に 3 回まで。ここでは設定で「出した」を覚えて、1回だけにする。
abstract class ReviewService {
  Future<void> requestReview();
  Future<void> openStoreListing();
}

class NoReviewService implements ReviewService {
  const NoReviewService();

  @override
  Future<void> requestReview() async {}

  @override
  Future<void> openStoreListing() async {}
}

class InAppReviewService implements ReviewService {
  const InAppReviewService({this.appStoreId});

  /// App Store の数字の ID。iOS 版を出したら入れる。
  final String? appStoreId;

  @override
  Future<void> requestReview() async {
    final r = InAppReview.instance;
    if (await r.isAvailable()) await r.requestReview();
  }

  @override
  Future<void> openStoreListing() => InAppReview.instance.openStoreListing(appStoreId: appStoreId);
}
