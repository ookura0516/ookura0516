import 'package:flutter/material.dart';

import '../../core/puzzle.dart';
import '../../game/band.dart';
import '../theme.dart';

/// 語のタイル。長い語は枠に収まるように縮める（7文字まで）。
class WordTile extends StatelessWidget {
  const WordTile({
    super.key,
    required this.word,
    required this.selected,
    required this.onTap,
  });

  final String word;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: word,
      excludeSemantics: true,
      child: Material(
        color: selected ? YonkumiTheme.tileSelected : YonkumiTheme.tile,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          key: ValueKey('tile-$word'),
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: selected ? YonkumiTheme.surface : YonkumiTheme.ink,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 4列のタイル。
class TileGrid extends StatelessWidget {
  const TileGrid({
    super.key,
    required this.words,
    required this.selected,
    required this.onTap,
  });

  final List<String> words;
  final Set<String> selected;
  final ValueChanged<String>? onTap;

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[
      for (var i = 0; i < words.length; i += 4)
        words.sublist(i, (i + 4).clamp(0, words.length)),
    ];
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: SizedBox(
              height: 72,
              child: Row(
                children: [
                  for (var i = 0; i < 4; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(
                      child: i < row.length
                          ? WordTile(
                              word: row[i],
                              selected: selected.contains(row[i]),
                              onTap: onTap == null
                                  ? null
                                  : () => onTap!(row[i]),
                            )
                          : const SizedBox(),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

/// 当てた組の帯。軸の名前と4語を出す。
class SolvedBand extends StatelessWidget {
  const SolvedBand({
    super.key,
    required this.group,
    required this.colorNames,
    this.revealed = false,
  });

  final PuzzleGroup group;
  final bool colorNames;

  /// 当てられずに答えとして見せている帯。
  final bool revealed;

  @override
  Widget build(BuildContext context) {
    final bg = YonkumiTheme.band(group.difficulty);
    final fg = YonkumiTheme.onBand(group.difficulty);
    final band = Band.of(group.difficulty);
    return Semantics(
      label:
          '${band.name}の組（${band.label}）：${group.title}。'
          '${group.words.join('、')}${revealed ? '（答え）' : ''}',
      excludeSemantics: true,
      child: Container(
        key: ValueKey('band-${group.difficulty}'),
        height: 72,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: revealed ? bg.withValues(alpha: 0.55) : bg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            if (colorNames)
              Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  border: Border.all(color: fg),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  band.name,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w700),
                ),
              ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      group.title,
                      style: TextStyle(
                        color: fg,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      group.words.join('・'),
                      style: TextStyle(color: fg, fontSize: 15),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 残りの間違え回数（●）。
class MistakesLeft extends StatelessWidget {
  const MistakesLeft({super.key, required this.left, required this.max});

  final int left;
  final int max;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'あと$left回まちがえられます',
      excludeSemantics: true,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('のこり', style: TextStyle(color: YonkumiTheme.inkDim)),
          const SizedBox(width: 8),
          for (var i = 0; i < max; i++)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Icon(
                i < left ? Icons.circle : Icons.circle_outlined,
                size: 14,
                color: YonkumiTheme.ink,
              ),
            ),
        ],
      ),
    );
  }
}
