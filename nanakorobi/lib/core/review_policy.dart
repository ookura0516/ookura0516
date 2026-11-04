import 'local_date.dart';

/// 評価依頼を出す場面。7日目の節目と両目の直後だけ。開眼直後とオンボーディング中には出さない。
enum ReviewOccasion { milestone7, completed }

class ReviewPromptPolicy {
  const ReviewPromptPolicy._();

  /// 365日に3回まで（ストアの上限に合わせる）。
  static const maxPerYear = 3;

  static bool shouldPrompt({
    required ReviewOccasion occasion,
    required LocalDate today,
    required Iterable<LocalDate> promptedOn,
  }) {
    final recent = promptedOn.where((d) => today.difference(d) < 365 && d <= today).length;
    return recent < maxPerYear;
  }
}
