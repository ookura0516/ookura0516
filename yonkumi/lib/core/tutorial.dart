import 'axis.dart';
import 'puzzle.dart';

/// 初回だけ出す、軸がやさしい固定の問題。成績と連続日数には数えない。
const Puzzle kTutorialPuzzle = Puzzle(
  number: 0,
  groups: [
    PuzzleGroup(
      title: '果物',
      axis: AxisSpec(AxisType.manual, '果物'),
      words: ['りんご', 'みかん', 'ぶどう', 'もも'],
      difficulty: 1,
      note: 'まずは素直な仲間から。',
    ),
    PuzzleGroup(
      title: '「山」の字を含む',
      axis: AxisSpec(AxisType.kanji, '山'),
      words: ['富士山', '山道', '火山', '登山'],
      difficulty: 2,
      note: '同じ漢字が入っている語をまとめる軸。',
    ),
    PuzzleGroup(
      title: '冬の季語',
      axis: AxisSpec(AxisType.season, '冬'),
      words: ['こたつ', '雪だるま', '木枯らし', '白菜'],
      difficulty: 3,
      note: '俳句で冬を表す言葉。',
    ),
    PuzzleGroup(
      title: '「かみ」と読む',
      axis: AxisSpec(AxisType.reading, 'かみ'),
      words: ['紙', '髪', '神', '上'],
      difficulty: 4,
      note: '字は違っても、読みはどれも「かみ」。',
    ),
  ],
  readings: {
    'りんご': 'りんご',
    'みかん': 'みかん',
    'ぶどう': 'ぶどう',
    'もも': 'もも',
    '富士山': 'ふじさん',
    '山道': 'やまみち',
    '火山': 'かざん',
    '登山': 'とざん',
    'こたつ': 'こたつ',
    '雪だるま': 'ゆきだるま',
    '木枯らし': 'こがらし',
    '白菜': 'はくさい',
    '紙': 'かみ',
    '髪': 'かみ',
    '神': 'かみ',
    '上': 'かみ',
  },
  decoys: [
    Decoy(word: 'みかん', title: '冬の季語', axis: AxisSpec(AxisType.season, '冬')),
  ],
);
