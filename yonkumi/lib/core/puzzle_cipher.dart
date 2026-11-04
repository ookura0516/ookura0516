import 'dart:convert';
import 'dart:typed_data';

import 'package:ookura_daily/ookura_daily.dart';

/// 問題データの簡易暗号（日付で鍵を作る XOR）。
///
/// アセットを開いても、先の日の問題がそのままは読めないようにするためのもの。
/// 鍵の作り方はアプリに入っているので、本気で解析されれば読める。
/// 「うっかり見えてしまう」を防ぐのが目的で、秘密を守る暗号ではない。
class PuzzleCipher {
  const PuzzleCipher._();

  /// 復号できたかを確かめるための頭の印。
  static const _magic = 'YK1:';

  static String encrypt(String plain, CivilDate date) {
    final bytes = utf8.encode('$_magic$plain');
    return base64.encode(_xor(Uint8List.fromList(bytes), date));
  }

  /// 鍵の日付が違うなど、復号できなければ [FormatException]。
  static String decrypt(String cipher, CivilDate date) {
    final List<int> bytes;
    try {
      bytes = _xor(base64.decode(cipher), date);
    } on FormatException {
      throw const FormatException('問題データが壊れています');
    }
    final String text;
    try {
      text = utf8.decode(bytes);
    } on FormatException {
      throw const FormatException('この日付では開けません');
    }
    if (!text.startsWith(_magic)) {
      throw const FormatException('この日付では開けません');
    }
    return text.substring(_magic.length);
  }

  static Uint8List _xor(Uint8List data, CivilDate date) {
    var state = _seed('yonkumi|${date.toIso()}');
    final out = Uint8List(data.length);
    for (var i = 0; i < data.length; i++) {
      // xorshift32
      state ^= (state << 13) & 0xFFFFFFFF;
      state ^= state >> 17;
      state ^= (state << 5) & 0xFFFFFFFF;
      out[i] = data[i] ^ (state & 0xFF);
    }
    return out;
  }

  /// FNV-1a（32bit）。0 にならないようにする。
  static int _seed(String s) {
    var h = 0x811C9DC5;
    for (final b in utf8.encode(s)) {
      h ^= b;
      h = (h * 0x01000193) & 0xFFFFFFFF;
    }
    return h == 0 ? 0x9E3779B9 : h;
  }
}
