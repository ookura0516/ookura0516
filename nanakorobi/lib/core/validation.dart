/// 入力の決まり。
class Limits {
  const Limits._();

  /// 腹の文字は 2〜6 字。
  static const nameMin = 2;
  static const nameMax = 6;

  /// メモは 30 字。
  static const memoMax = 30;

  /// 通過点は最大 3。
  static const waypointsMax = 3;

  /// 腹の文字のプリセット。
  static const namePresets = ['合格', '必勝', '家内安全', '無病息災'];

  static bool nameOk(String name) {
    final n = name.trim();
    final len = n.runes.length;
    return len >= nameMin && len <= nameMax && !n.contains(RegExp(r'\s'));
  }

  static bool memoOk(String memo) => memo.runes.length <= memoMax;
}
