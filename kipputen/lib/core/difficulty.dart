import 'solution_book.dart';

/// 出題の難易度帯。解の数と、分数を経由する必要があるかで分ける。
enum Band {
  /// 解が7通り以上。
  easy('やさしい'),

  /// 解が3〜6通り。
  normal('ふつう'),

  /// 解が1〜2通り（分数なしで解ける）。
  hard('むずかしい'),

  /// どの解も途中で分数を経由する（4組み合わせ・54番号）。
  fraction('分数の難問');

  const Band(this.label);
  final String label;

  static Band of(SolutionBook book, String number) {
    if (book.needsFraction(number)) return fraction;
    final n = book.solutionsFor(number).length;
    if (n <= 2) return hard;
    if (n <= 6) return normal;
    return easy;
  }

  /// 曜日（1=月 … 7=日）ごとの帯。月曜は易しく、金曜は分数経由の難問。
  static Band forWeekday(int weekday) => switch (weekday) {
    DateTime.monday => easy,
    DateTime.tuesday => normal,
    DateTime.wednesday => normal,
    DateTime.thursday => hard,
    DateTime.friday => fraction,
    DateTime.saturday => hard,
    _ => normal,
  };

  /// 帯の番号を使い切ったときに代わりに使う帯（近い順）。
  List<Band> get fallbacks => switch (this) {
    easy => [normal, hard],
    normal => [easy, hard],
    hard => [normal, easy],
    fraction => [hard, normal],
  };
}
