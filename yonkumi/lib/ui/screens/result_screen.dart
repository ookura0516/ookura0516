import 'package:flutter/material.dart';
import 'package:ookura_daily/ookura_daily_flutter.dart';
import 'package:provider/provider.dart';

import '../../game/band.dart';
import '../../game/share_text.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/result_grid.dart';
import '../widgets/share_card.dart';
import 'archive_screen.dart';
import 'purchase_sheet.dart';

/// 結果：4色グリッド、回数、連続日数、共有、全組の解説。失敗でも答えを見せる。
class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.entry});

  final PuzzleEntry entry;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  ShareImageFormat _format = ShareImageFormat.portrait;
  bool _sharing = false;

  PuzzleEntry get entry => widget.entry;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final s = app.sessionFor(entry);
    final colorNames = app.settings.colorNames;
    final puzzle = entry.puzzle;
    final verdict = !s.cleared
        ? '残念、間違いが4回になりました'
        : s.mistakes == 0
        ? 'パーフェクト！'
        : 'クリア！（間違い${s.mistakes}回）';
    final banner = !entry.isTutorial && app.showAds
        ? app.ads.banner(context)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(entry.isTutorial ? '遊び方の問題の結果' : '第${entry.day}問の結果'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                Text(
                  verdict,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Center(
                  child: ResultGrid(rows: s.gridRows, colorNames: colorNames),
                ),
                const SizedBox(height: 8),
                Text(
                  [
                    '${s.guesses.length}回の決定',
                    if (!entry.isTutorial) '連続${app.streak.current}日',
                  ].join('・'),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: YonkumiTheme.inkDim),
                ),
                const SizedBox(height: 16),
                if (entry.isTutorial)
                  FilledButton(
                    onPressed: () async {
                      await app.skipTutorial();
                      if (context.mounted) {
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      }
                    },
                    child: const Text('今日の問題へ'),
                  )
                else
                  _shareSection(app, s.gridRows, s.cleared, s.mistakes),
                const SizedBox(height: 24),
                Text('答えと解説', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final g in puzzle.groups)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 40,
                            color: YonkumiTheme.band(g.difficulty),
                            alignment: Alignment.center,
                            child: Text(
                              Band.of(g.difficulty).name,
                              style: TextStyle(
                                color: YonkumiTheme.onBand(g.difficulty),
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    g.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  Text(g.words.join('・')),
                                  const SizedBox(height: 4),
                                  Text(
                                    g.note,
                                    style: const TextStyle(
                                      color: YonkumiTheme.inkDim,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (puzzle.decoys.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('ひっかけ', style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  for (final d in puzzle.decoys)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        '・${d.word}：${d.title}…ではなく、'
                        '${puzzle.groupOf(d.word).title}',
                      ),
                    ),
                ],
                if (!entry.isTutorial) ...[
                  const SizedBox(height: 24),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const ArchiveScreen()),
                    ),
                    child: const Text('ほかの日の問題（アーカイブ）'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: banner == null
          ? null
          : SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  banner,
                  TextButton(
                    onPressed: () => showPurchaseSheet(context),
                    child: const Text('広告を消す'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _shareSection(
    AppController app,
    List<List<int>> grid,
    bool cleared,
    int mistakes,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SegmentedButton<ShareImageFormat>(
          segments: const [
            ButtonSegment(value: ShareImageFormat.portrait, label: Text('縦長')),
            ButtonSegment(value: ShareImageFormat.square, label: Text('正方形')),
          ],
          selected: {_format},
          onSelectionChanged: (v) => setState(() => _format = v.first),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                key: const Key('share-image'),
                onPressed: _sharing
                    ? null
                    : () => _shareImage(app, grid, cleared, mistakes),
                icon: const Icon(Icons.image_outlined),
                label: const Text('画像で共有'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                key: const Key('share-text'),
                onPressed: () => app.share.shareText(
                  _text(app, grid, cleared, mistakes),
                  origin: _origin(),
                ),
                icon: const Icon(Icons.text_snippet_outlined),
                label: const Text('文字で共有'),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          '答えは入りません。$kHashtag',
          textAlign: TextAlign.center,
          style: TextStyle(color: YonkumiTheme.inkDim, fontSize: 12),
        ),
      ],
    );
  }

  String _text(
    AppController app,
    List<List<int>> grid,
    bool cleared,
    int mistakes,
  ) => shareText(
    day: entry.day,
    date: entry.date!,
    grid: grid,
    cleared: cleared,
    mistakes: mistakes,
    streak: app.streak.current,
    rerun: entry.rerun,
  );

  Future<void> _shareImage(
    AppController app,
    List<List<int>> grid,
    bool cleared,
    int mistakes,
  ) async {
    setState(() => _sharing = true);
    try {
      final png = await renderShareImage(
        ShareCard(
          format: _format,
          day: entry.day,
          date: entry.date!,
          grid: grid,
          cleared: cleared,
          mistakes: mistakes,
          streak: app.streak.current,
          colorNames: app.settings.colorNames,
        ),
        format: _format,
      );
      await app.share.sharePng(
        png,
        fileName: 'yonkumi_${entry.day}_${_format.name}.png',
        text: _text(app, grid, cleared, mistakes),
        origin: _origin(),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('画像を作れませんでした')));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  /// iPad の共有シートの出どころ。
  Rect? _origin() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null) return null;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
