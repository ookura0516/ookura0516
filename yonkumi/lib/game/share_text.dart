import 'package:ookura_daily/ookura_daily.dart';

import 'band.dart';

/// 公式のハッシュタグ。
const String kHashtag = '#ヨンクミ';

/// 文字だけの結果（絵文字の四角）。答えは含めない。
String shareText({
  required int day,
  required CivilDate date,
  required List<List<int>> grid,
  required bool cleared,
  required int mistakes,
  required int streak,
  bool rerun = false,
}) {
  final head = 'ヨンクミ 第$day問（${date.month}/${date.day}）${rerun ? '再' : ''}';
  final result = cleared
      ? (mistakes == 0 ? 'パーフェクト' : '間違い $mistakes/4')
      : '間違い 4/4・あと${4 - _solvedRows(grid)}組';
  return [
    head,
    emojiGrid(grid, Band.emojiPalette),
    '$result・連続$streak日',
    kHashtag,
  ].join('\n');
}

int _solvedRows(List<List<int>> grid) =>
    grid.where((r) => r.length == 4 && r.toSet().length == 1).length;
