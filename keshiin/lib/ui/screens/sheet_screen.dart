import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/day_slots.dart';
import '../theme.dart';
import '../widgets/sheet_grid.dart';
import '../widgets/stamp_view.dart';
import 'create_stamp_screen.dart';
import 'month_sheet_screen.dart';
import 'stamp_detail_screen.dart';

/// 今月のシート（過去の月にも戻れる）。
class SheetScreen extends StatefulWidget {
  const SheetScreen({super.key, this.animate = true});

  final bool animate;

  @override
  State<SheetScreen> createState() => _SheetScreenState();
}

class _SheetScreenState extends State<SheetScreen> {
  late int _year;
  late int _month;
  Future<MonthData>? _future;
  int _rev = -1;

  @override
  void initState() {
    super.initState();
    final t = context.read<AppState>().today;
    _year = t.year;
    _month = t.month;
  }

  void _shift(int delta) {
    final d = DateTime(_year, _month + delta);
    setState(() {
      _year = d.year;
      _month = d.month;
      _rev = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_rev != app.revision || _future == null) {
      _rev = app.revision;
      _future = app.loadMonth(_year, _month);
    }
    final today = app.today;
    final isThisMonth = today.year == _year && today.month == _month;
    final canGoNext = DateTime(
      _year,
      _month + 1,
    ).isBefore(DateTime(today.year, today.month + 1));

    return Scaffold(
      appBar: AppBar(
        title: Text(isThisMonth ? '今月のシート' : '$_year年$_month月のシート'),
        actions: [
          IconButton(
            key: const Key('bulk-import'),
            tooltip: '写真をまとめて貼る',
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: () => bulkImportFlow(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        key: const Key('create-stamp'),
        onPressed: () =>
            openCreate(context, target: isThisMonth ? today : null),
        icon: const Icon(Icons.add_photo_alternate_outlined),
        label: const Text('切手を作る'),
      ),
      body: FutureBuilder<MonthData>(
        future: _future,
        builder: (context, snap) {
          final m = snap.data;
          if (m == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final count = m.count;
          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 96),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    IconButton(
                      key: const Key('prev-month'),
                      tooltip: '前の月',
                      onPressed: () => _shift(-1),
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            '$_year年$_month月',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          if (m.title.isNotEmpty)
                            Text(
                              m.title,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      key: const Key('next-month'),
                      tooltip: '次の月',
                      onPressed: canGoNext ? () => _shift(1) : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${count.filled}／${count.total}',
                        key: const Key('fill-count'),
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (m.complete) ...[
                        const SizedBox(width: 8),
                        const Chip(
                          label: Text('完'),
                          visualDensity: VisualDensity.compact,
                        ),
                      ],
                      const Spacer(),
                      TextButton.icon(
                        key: const Key('open-month-sheet'),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                MonthSheetScreen(year: _year, month: _month),
                          ),
                        ),
                        icon: const Icon(Icons.ios_share, size: 18),
                        label: const Text('シートを共有'),
                      ),
                    ],
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: KeshiinTheme.card,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: KeshiinTheme.line),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: SheetGrid(
                      data: m,
                      today: today,
                      animate: widget.animate,
                      onEmpty: (day) => _onEmpty(day, today),
                      onStamp: (e) => _openDetail(e),
                    ),
                  ),
                ),
                if (m.margin.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text('欄外', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 4),
                  SizedBox(
                    height: 110,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        for (final e in m.margin)
                          InkWell(
                            key: Key('margin-${e.row.id}'),
                            onTap: () => _openDetail(e),
                            child: SizedBox(
                              width: 84,
                              child: StampView(entry: e),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Text(
                  '過去の日の空欄にも、その日の写真を貼れます。途切れても大丈夫。\n$kNotPostageNotice',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onEmpty(Day day, Day today) {
    if (day > today) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('まだ先の日です')));
      return;
    }
    openCreate(context, target: day);
  }

  void _openDetail(StampEntry e) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => StampDetailScreen(stampId: e.row.id)),
    );
  }
}

/// 切手を作る画面を開き、保存されたらシートの完成などを知らせる。
Future<void> openCreate(BuildContext context, {Day? target}) async {
  final result = await Navigator.push<Saved>(
    context,
    MaterialPageRoute(builder: (_) => CreateStampScreen(target: target)),
  );
  if (result == null || !context.mounted) return;
  final d = Day.parse(result.row.date);
  if (result.completedMonth) {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('シートが完成しました'),
        content: Text('${d.year}年${d.month}月のマスがすべて埋まりました。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('あとで'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      MonthSheetScreen(year: d.year, month: d.month),
                ),
              );
            },
            child: const Text('シートを見る'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${d.month}月${d.day}日に貼りました')));
  }
}

/// 写真をまとめて選び、撮影日で振り分けて貼る。
Future<void> bulkImportFlow(BuildContext context) async {
  final app = context.read<AppState>();
  final photos = await app.services.photos.pick(multiple: true);
  if (photos.isEmpty || !context.mounted) return;
  final r = await app.bulkImport(photos);
  if (!context.mounted) return;
  final skipped = r.skipped > 0 ? '（すでに貼ってある日の${r.skipped}枚は飛ばしました）' : '';
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text('${r.saved}枚を撮影日のマスに貼りました$skipped')));
}
