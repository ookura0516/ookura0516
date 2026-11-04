/// シードから決まる乱数（mulberry32）。端末や Dart の版が変わっても同じ列になる。
///
/// 消印の位置・角度・かすれはこのシードだけから決める。シードを保存すれば、
/// 同じ切手は何度描いても同じ見た目になる。
class SeededRng {
  SeededRng(int seed) : _state = seed & 0xFFFFFFFF;

  int _state;

  /// 0 以上 2^32 未満
  int nextUint32() {
    _state = (_state + 0x6D2B79F5) & 0xFFFFFFFF;
    var t = _state;
    t = _imul(t ^ (t >>> 15), t | 1);
    t ^= (t + _imul(t ^ (t >>> 7), t | 61)) & 0xFFFFFFFF;
    return (t ^ (t >>> 14)) & 0xFFFFFFFF;
  }

  /// [0, 1)
  double nextDouble() => nextUint32() / 4294967296.0;

  /// [min, max)
  double range(double min, double max) => min + (max - min) * nextDouble();

  static int _imul(int a, int b) => (a * b) & 0xFFFFFFFF;
}
