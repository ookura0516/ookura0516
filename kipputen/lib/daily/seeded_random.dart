/// 日付を種にした決定的な乱数（mulberry32）。端末や Dart の版で結果が変わらない。
///
/// dart:math の Random は実装が変わりうるので、出題には使わない。
/// 掛け算は16bitずつに分けて行い、Web（JavaScript の数）でも同じ値になるようにする。
class SeededRandom {
  SeededRandom(int seed) : _s = seed & 0xFFFFFFFF;

  /// 文字列（「kipputen:20261104」など）から種を作る（FNV-1a 32bit）。
  factory SeededRandom.fromString(String s) {
    var h = 0x811C9DC5;
    for (final c in s.codeUnits) {
      h ^= c;
      h = _imul(h, 0x01000193);
    }
    return SeededRandom(h);
  }

  int _s;

  /// 0 以上 2^32 未満。
  int nextUint32() {
    _s = (_s + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _s;
    t = _imul(t ^ (t >> 15), t | 1);
    t ^= (t + _imul(t ^ (t >> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >> 14)) & 0xFFFFFFFF;
  }

  /// 0 以上 [max] 未満。
  int nextInt(int max) => nextUint32() % max;

  static int _imul(int a, int b) {
    // 32bit の掛け算（下位32bit）。上下16bitに分けて桁あふれを避ける。
    final ah = (a >> 16) & 0xFFFF, al = a & 0xFFFF;
    final bh = (b >> 16) & 0xFFFF, bl = b & 0xFFFF;
    return (al * bl + (((ah * bl + al * bh) & 0xFFFF) << 16)) & 0xFFFFFFFF;
  }
}
