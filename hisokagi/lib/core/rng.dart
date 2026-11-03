/// 決定的な32ビット乱数（mulberry32）。
///
/// 2台の端末が同じ部屋番号から同じ謎を作るために使う。Dart標準の
/// `Random(seed)` はSDKのバージョンが違うと同じ結果になる保証がないので使わない。
class Rng {
  Rng(int seed) : _state = seed & _mask;

  /// 文字列のラベルと数値を混ぜて、用途ごとに別の乱数列を作る。
  factory Rng.forKey(List<Object> parts) => Rng(mix(parts));

  static const int _mask = 0xFFFFFFFF;
  int _state;

  int nextU32() {
    _state = (_state + 0x6D2B79F5) & _mask;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & _mask;
    return (t ^ (t >>> 14)) & _mask;
  }

  /// 0以上 [n] 未満の整数。
  int nextInt(int n) {
    assert(n > 0);
    return nextU32() % n;
  }

  bool nextBool() => nextU32() & 1 == 1;

  T pick<T>(List<T> items) => items[nextInt(items.length)];

  /// [items] を並べ替えた新しいリスト（Fisher–Yates）。
  List<T> shuffled<T>(List<T> items) {
    final list = List<T>.of(items);
    for (var i = list.length - 1; i > 0; i--) {
      final j = nextInt(i + 1);
      final tmp = list[i];
      list[i] = list[j];
      list[j] = tmp;
    }
    return list;
  }

  static int _imul(int a, int b) => (a * b) & _mask;

  /// FNV-1a で文字列と数値を32ビットにまとめる。
  static int mix(List<Object> parts) {
    var h = 0x811C9DC5;
    for (final part in parts) {
      for (final unit in part.toString().codeUnits) {
        h ^= unit & 0xFF;
        h = _imul(h, 0x01000193);
        h ^= unit >>> 8;
        h = _imul(h, 0x01000193);
      }
      h ^= 0x1F; // 区切り
      h = _imul(h, 0x01000193);
    }
    return h;
  }
}
