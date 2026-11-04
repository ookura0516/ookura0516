import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/day_slots.dart';
import '../../data/db.dart';
import '../../render/sheet_painter.dart';
import '../theme.dart';
import '../widgets/stamp_view.dart';

/// 月のシート全体（共有画像と同じ見た目）と共有。
class MonthSheetScreen extends StatefulWidget {
  const MonthSheetScreen({super.key, required this.year, required this.month});

  final int year;
  final int month;

  @override
  State<MonthSheetScreen> createState() => _MonthSheetScreenState();
}

class _MonthSheetScreenState extends State<MonthSheetScreen> {
  late final Future<MonthData> _future = context.read<AppState>().loadMonth(
    widget.year,
    widget.month,
  );
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.year}年${widget.month}月のシート')),
      body: FutureBuilder<MonthData>(
        future: _future,
        builder: (context, snap) {
          final m = snap.data;
          if (m == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Material(elevation: 2, child: MonthSheetPicture(data: m)),
              const SizedBox(height: 16),
              FilledButton.icon(
                key: const Key('share-month'),
                onPressed: _busy
                    ? null
                    : () async {
                        final app = context.read<AppState>();
                        setState(() => _busy = true);
                        try {
                          await app.share(await app.renderMonthShare(m));
                        } finally {
                          if (mounted) setState(() => _busy = false);
                        }
                      },
                icon: const Icon(Icons.ios_share),
                label: const Text('シートを共有（1080×1350）'),
              ),
              const SizedBox(height: 8),
              Text(
                kNotPostageNotice,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// 旅の小型シート。
class TripSheetScreen extends StatefulWidget {
  const TripSheetScreen({super.key, required this.sheet});

  final SheetRow sheet;

  @override
  State<TripSheetScreen> createState() => _TripSheetScreenState();
}

class _TripSheetScreenState extends State<TripSheetScreen> {
  late final Future<TripSheetVisual> _future = _load();

  Future<TripSheetVisual> _load() async {
    final app = context.read<AppState>();
    final from = Day.parse(widget.sheet.dateFrom!),
        to = Day.parse(widget.sheet.dateTo!);
    final list = await app.loadRange(from, to);
    return TripSheetVisual(
      title: widget.sheet.title,
      from: from,
      to: to,
      stamps: [for (final e in list) await app.visualFor(e)],
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.read<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sheet.title.isEmpty ? '旅のシート' : widget.sheet.title),
        actions: [
          IconButton(
            tooltip: '削除',
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final nav = Navigator.of(context);
              await app.deleteTrip(widget.sheet);
              nav.pop();
            },
          ),
        ],
      ),
      body: FutureBuilder<TripSheetVisual>(
        future: _future,
        builder: (context, snap) {
          final v = snap.data;
          if (v == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Material(
                elevation: 2,
                child: AspectRatio(
                  aspectRatio: 1080 / 1350,
                  child: CustomPaint(
                    painter: PicturePainter((c, s) => paintTripSheet(c, s, v)),
                  ),
                ),
              ),
              if (v.stamps.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('この期間の切手はまだありません。'),
                ),
              if (v.stamps.length > 12)
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text('小型シートには最初の12枚が入ります。'),
                ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () async =>
                    app.share(await app.renderTripShare(widget.sheet)),
                icon: const Icon(Icons.ios_share),
                label: const Text('小型シートを共有'),
              ),
            ],
          );
        },
      ),
    );
  }
}
