import 'package:characters/characters.dart';

import 'kana.dart';

/// 音数の目安。[estimated] が true なら、読みの分からない漢字などを仮に数えた。
class MoraCount {
  const MoraCount(this.count, {this.estimated = false});
  final int count;
  final bool estimated;

  MoraCount operator +(MoraCount o) =>
      MoraCount(count + o.count, estimated: estimated || o.estimated);

  /// 「5音」「約7音」。
  String get label => estimated ? '約$count音' : '$count音';

  @override
  String toString() => label;
}

/// 小書きのかな。前の字とまとめて1音（拗音）。っ・ッ（促音）は1音として数えるので含めない。
const _smallKana = {
  'ぁ', 'ぃ', 'ぅ', 'ぇ', 'ぉ', 'ゃ', 'ゅ', 'ょ', 'ゎ', //
  'ァ', 'ィ', 'ゥ', 'ェ', 'ォ', 'ャ', 'ュ', 'ョ', 'ヮ', //
  'ㇰ',
  'ㇱ',
  'ㇲ',
  'ㇳ',
  'ㇴ',
  'ㇵ',
  'ㇶ',
  'ㇷ',
  'ㇸ',
  'ㇹ',
  'ㇺ',
  'ㇻ',
  'ㇼ',
  'ㇽ',
  'ㇾ',
  'ㇿ',
};

/// かなの範囲にあるが、音として数えない記号。
const _notMora = {'・', '゛', '゜', '゠', 'ヽ', 'ヾ', 'ゝ', 'ゞ', 'ヿ', 'ゟ'};

/// かなの音数（モーラ）。拗音は1つ、促音・長音・撥音も1つ。
int kanaMora(String kana) {
  var n = 0;
  for (final ch in kana.characters) {
    final c = ch.runes.first;
    if (_smallKana.contains(ch)) continue;
    if (_notMora.contains(ch)) continue;
    if (isKana(c)) n++;
  }
  return n;
}

/// 句の音数を数える。
///
/// - ひらがな・カタカナはモーラで数える
/// - 漢字は [readings]（季語の読みなど）にあればその読みで数える。最長一致
/// - 読みの分からない漢字は1文字2音として、目安（[MoraCount.estimated]）にする
/// - 英数字は1文字1音の目安。記号・空白・絵文字は数えない
/// 間違っていてもエラーにはしない。表示は常に「目安」。
class MoraCounter {
  MoraCounter(Map<String, String> readings)
    : _readings = {
        for (final e in readings.entries)
          if (e.key.runes.any(isKanji)) e.key: e.value,
      } {
    _maxLen = _readings.keys.fold(0, (m, s) => s.length > m ? s.length : m);
  }

  final Map<String, String> _readings;
  int _maxLen = 0;

  MoraCount count(String text) {
    var total = 0;
    var estimated = false;
    final chars = text.characters.toList();
    var i = 0;
    while (i < chars.length) {
      final ch = chars[i];
      final c = ch.runes.first;
      if (isKanji(c)) {
        // 辞書の最長一致（漢字で始まる語）
        String? reading;
        var used = 0;
        for (var len = _maxLen; len >= 1; len--) {
          if (i + len > chars.length) continue;
          final s = chars.sublist(i, i + len).join();
          final r = _readings[s];
          if (r != null) {
            reading = r;
            used = len;
            break;
          }
        }
        if (reading != null) {
          total += kanaMora(reading);
          i += used;
        } else {
          total += 2;
          estimated = true;
          i++;
        }
        continue;
      }
      if (ch == 'ゝ' || ch == 'ゞ' || ch == 'ヽ' || ch == 'ヾ') {
        total++;
      } else if (isKana(c) || ch == 'ー') {
        total += kanaMora(ch);
      } else if (RegExp(r'^[A-Za-z0-9Ａ-Ｚａ-ｚ０-９]$').hasMatch(ch)) {
        total++;
        estimated = true;
      }
      i++;
    }
    return MoraCount(total, estimated: estimated);
  }

  /// 上五・中七・下五のそれぞれ。
  List<MoraCount> countLines(List<String> lines) => [
    for (final l in lines) count(l),
  ];
}

/// 定型（5・7・5）との差の言い方。エラーではなく目安として出す。
String moraNote(List<MoraCount> lines) {
  final nonEmpty = lines.where((m) => m.count > 0).toList();
  if (nonEmpty.isEmpty) return '';
  final total = nonEmpty.fold(0, (s, m) => s + m.count);
  if (lines.length == 3 && nonEmpty.length == 3) {
    final target = [5, 7, 5];
    final diff = [for (var i = 0; i < 3; i++) lines[i].count - target[i]];
    if (diff.every((d) => d == 0)) return '五七五';
  }
  if (total > 17) return '字余り（目安）';
  if (total < 17) return '字足らず（目安）';
  return '十七音';
}
