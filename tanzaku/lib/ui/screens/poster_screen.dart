import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/japanese_date.dart';
import '../../data/database.dart';
import '../../render/image_export.dart';
import '../../render/poster_painter.dart';
import '../app_controller.dart';
import '../theme.dart';

const posterSize = Size(1080, 1350);

/// 月の十句ポスター（すずり）。その月の句から10句を選んで1枚に組む。
class PosterScreen extends StatefulWidget {
  const PosterScreen({super.key, required this.year, required this.month});
  final int year;
  final int month;

  @override
  State<PosterScreen> createState() => _PosterScreenState();
}

class _PosterScreenState extends State<PosterScreen> {
  late int _year = widget.year;
  late int _month = widget.month;
  final _selected = <int>{};
  bool _picked = false;

  List<HaikuRow> _ofMonth(AppController app) => app.haiku
      .where((h) => h.composedOn.year == _year && h.composedOn.month == _month)
      .toList()
      .reversed
      .toList();

  /// 最初はお気に入りを先に、日付順で10句。
  void _autoPick(List<HaikuRow> list) {
    final fav = list.where((h) => h.favorite);
    final rest = list.where((h) => !h.favorite);
    _selected
      ..clear()
      ..addAll([...fav, ...rest].take(10).map((h) => h.id));
    _picked = true;
  }

  void _shift(int delta) {
    setState(() {
      final d = DateTime(_year, _month + delta);
      _year = d.year;
      _month = d.month;
      _picked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final list = _ofMonth(app);
    if (!_picked) _autoPick(list);
    final chosen = list
        .where((h) => _selected.contains(h.id))
        .map((h) => h.body)
        .toList();
    final painter = PosterPainter(
      year: _year,
      month: _month,
      haiku: chosen,
      style: app.lastStyle,
      gago: app.gago,
    );
    return Scaffold(
      appBar: AppBar(title: Text('${wafuMonth(_month)}の十句')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _shift(-1),
                icon: const Icon(Icons.chevron_left),
                tooltip: '前の月',
              ),
              Text(
                '$_year年$_month月（${list.length}句）',
                style: const TextStyle(fontSize: 16),
              ),
              IconButton(
                onPressed: () => _shift(1),
                icon: const Icon(Icons.chevron_right),
                tooltip: '次の月',
              ),
            ],
          ),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 440),
              child: AspectRatio(
                aspectRatio: posterSize.width / posterSize.height,
                child: CustomPaint(painter: painter),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: chosen.isEmpty
                      ? null
                      : () async {
                          final png = await renderPng(painter, posterSize);
                          await app.share.saveImage(
                            png,
                            'tanzaku_$_year${_month}_ten.png',
                          );
                        },
                  child: const Text('保存'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  onPressed: chosen.isEmpty
                      ? null
                      : () async {
                          final png = await renderPng(painter, posterSize);
                          await app.share.shareImage(
                            png,
                            'tanzaku_$_year${_month}_ten.png',
                            text: '#タンザク ${wafuMonth(_month)}の十句',
                          );
                        },
                  child: const Text('共有'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            '載せる句（${_selected.length}/10）',
            style: const TextStyle(color: TanzakuTheme.inkDim),
          ),
          if (list.isEmpty)
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text('この月の句はまだありません'),
            ),
          for (final h in list)
            CheckboxListTile(
              value: _selected.contains(h.id),
              title: Text(
                h.body.replaceAll('\n', '　'),
                style: TanzakuTheme.haiku,
              ),
              subtitle: Text('${h.composedOn.day}日${h.favorite ? '　★' : ''}'),
              onChanged: (v) => setState(() {
                if (v == true && _selected.length < 10) {
                  _selected.add(h.id);
                } else {
                  _selected.remove(h.id);
                }
              }),
            ),
        ],
      ),
    );
  }
}
