import 'package:in_app_review/in_app_review.dart';

/// ストアの評価依頼。出す場面は core の ReviewPromptPolicy が決める。
abstract class ReviewService {
  Future<void> requestReview();
}

class InAppReviewService implements ReviewService {
  const InAppReviewService();

  @override
  Future<void> requestReview() async {
    try {
      final review = InAppReview.instance;
      if (await review.isAvailable()) await review.requestReview();
    } catch (_) {
      // 出せなくても遊びを止めない。
    }
  }
}

class FakeReviewService implements ReviewService {
  int requests = 0;

  @override
  Future<void> requestReview() async => requests++;
}
