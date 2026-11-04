import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/solution_book.dart';
import '../../core/special_numbers.dart';
import '../app_controller.dart';
import '../theme.dart';
import 'play_screen.dart';

/// 硬券図鑑。0000〜9999 を 100×100 のグリッドに並べる（行が上2桁、列が下2桁）。
/// 広告を出すのはこの画面の下だけ。
class CollectionScreen extends StatelessWidget {
  const CollectionScreen({super.key});

  static const cell = 9.0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final banner = app.showAds ? app.ads.banner() : null;
    return Scaffold(
      appBar: AppBar(title: const Text('硬券図鑑')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 4,
              spacing: 12,
              children: [
                Text(
                  '解いた切符 ${app.solvedCount} / ${app.collectibleCount}',
                  key: const Key('collection-count'),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: KipTheme.ink,
                  ),
                ),
                const _Legend(),
              ],
            ),
          ),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (var p = 0; p < 10; p++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      decoration: BoxDecoration(
                        color: app.pageComplete(p)
                            ? const Color(0xFFF3E3A6)
                            : KipTheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: KipTheme.line),
                      ),
                      child: Text(
                        '$p千番台${app.pageComplete(p) ? ' 完' : ''}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: KipTheme.ink,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ClipRect(
              child: InteractiveViewer(
                constrained: false,
                minScale: 0.3,
                maxScale: 6,
                boundaryMargin: const EdgeInsets.all(40),
                child: GestureDetector(
                  key: const Key('collection-grid'),
                  onTapUp: (d) {
                    final col = (d.localPosition.dx / cell).floor();
                    final row = (d.localPosition.dy / cell).floor();
                    if (col < 0 || col > 99 || row < 0 || row > 99) return;
                    showTicketSheet(context, formatNumber(row * 100 + col));
                  },
                  child: RepaintBoundary(
                    child: CustomPaint(
                      size: const Size(cell * 100, cell * 100),
                      painter: _GridPainter(app),
                    ),
                  ),
                ),
              ),
            ),
          ),
          TextButton.icon(
            key: const Key('pick-number'),
            icon: const Icon(Icons.dialpad),
            label: const Text('番号を入れて探す'),
            onPressed: () => _askNumber(context),
          ),
          if (banner != null) SafeArea(top: false, child: banner),
        ],
      ),
    );
  }

  Future<void> _askNumber(BuildContext context) async {
    final ctrl = TextEditingController();
    final n = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('番号（4桁）'),
        content: TextField(
          key: const Key('number-field'),
          controller: ctrl,
          autofocus: true,
          maxLength: 4,
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('やめる'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(ctrl.text),
            child: const Text('見る'),
          ),
        ],
      ),
    );
    if (n != null && RegExp(r'^\d{4}$').hasMatch(n) && context.mounted) {
      showTicketSheet(context, n);
    }
  }
}

/// 番号1枚の詳細。解があれば練習に進める。
Future<void> showTicketSheet(BuildContext context, String number) {
  final app = context.read<AppController>();
  final solvable = app.book.isSolvable(number);
  final rec = app.recordOf(number);
  final kinds = specialKinds(number, birthday: app.settings.birthday);
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheet) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              number,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: 8,
              ),
            ),
            if (kinds.isNotEmpty)
              Text(
                kinds.map((k) => k.label).join('・'),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: KipTheme.gold,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const SizedBox(height: 8),
            Text(
              !solvable
                  ? 'この番号では 10 を作れません'
                  : rec == null
                  ? 'まだ解いていません（解は ${app.solutionsFor(number).length} 通り）'
                  : '解いた ${rec.found.length}/${app.goalFor(number)} 通り'
                        '${rec.allFound ? '　完' : ''}\n初めて解いた日 ${_dotted(rec.firstSolvedAt)}',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            if (solvable)
              FilledButton(
                key: const Key('practice'),
                onPressed: () {
                  Navigator.of(sheet).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PlayScreen(number: number, daily: false),
                    ),
                  );
                },
                child: Text(rec == null ? 'この切符で遊ぶ' : '切符を見る・続きを探す'),
              ),
          ],
        ),
      ),
    ),
  );
}

String _dotted(String key) =>
    '${key.substring(0, 4)}.${key.substring(4, 6)}.${key.substring(6, 8)}';

class _Legend extends StatelessWidget {
  const _Legend();

  @override
  Widget build(BuildContext context) {
    Widget box(Color c, {Color? border}) => Container(
      width: 10,
      height: 10,
      margin: const EdgeInsets.only(left: 8, right: 3),
      decoration: BoxDecoration(
        color: c,
        border: border == null ? null : Border.all(color: border, width: 2),
      ),
    );
    const s = TextStyle(fontSize: 11, color: KipTheme.inkDim);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        box(KipTheme.accent),
        const Text('解いた', style: s),
        box(KipTheme.locked),
        const Text('解なし', style: s),
        box(KipTheme.surface, border: KipTheme.gold),
        const Text('特別', style: s),
      ],
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.app);

  final AppController app;

  @override
  void paint(Canvas canvas, Size size) {
    const c = CollectionScreen.cell;
    final none = Paint()..color = KipTheme.locked;
    final open = Paint()..color = KipTheme.surface;
    final done = Paint()..color = KipTheme.accent;
    final gold = Paint()
      ..color = KipTheme.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6;
    canvas.drawRect(Offset.zero & size, Paint()..color = KipTheme.line);
    for (var i = 0; i < 10000; i++) {
      final n = formatNumber(i);
      final r = Rect.fromLTWH(
        (i % 100) * c + 0.5,
        (i ~/ 100) * c + 0.5,
        c - 1,
        c - 1,
      );
      final solvable = app.book.isSolvable(n);
      canvas.drawRect(
        r,
        !solvable
            ? none
            : app.records.solved.containsKey(n)
            ? done
            : open,
      );
      if (solvable && app.isSpecialNumber(n)) {
        canvas.drawRect(r.deflate(0.8), gold);
      }
    }
  }

  @override
  // 図鑑の状態が変わると画面ごと作り直されるので、そのたびに描く。
  bool shouldRepaint(_GridPainter old) => true;
}
