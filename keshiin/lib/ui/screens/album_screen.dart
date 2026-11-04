import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/banned_words.dart';
import '../../core/day_slots.dart';
import '../../data/db.dart';
import '../../monetize/purchase_service.dart';
import '../widgets/paywall.dart';
import 'month_sheet_screen.dart';

/// アルバム：月ごとのシートの一覧と、旅の小型シート。
class AlbumScreen extends StatefulWidget {
  const AlbumScreen({super.key});

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumData {
  _AlbumData(this.months, this.trips);
  final List<MonthData> months;
  final List<SheetRow> trips;
}

class _AlbumScreenState extends State<AlbumScreen> {
  Future<_AlbumData>? _future;
  int _rev = -1;

  Future<_AlbumData> _load(AppState app) async {
    final list = await app.repo.monthsWithStamps();
    final months = [for (final m in list) await app.loadMonth(m.year, m.month)];
    return _AlbumData(months, await app.tripSheets());
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    if (_rev != app.revision || _future == null) {
      _rev = app.revision;
      _future = _load(app);
    }
    return Scaffold(
      appBar: AppBar(title: const Text('アルバム')),
      body: FutureBuilder<_AlbumData>(
        future: _future,
        builder: (context, snap) {
          final data = snap.data;
          if (data == null) {
            return const Center(child: CircularProgressIndicator());
          }
          final years = {for (final m in data.months) m.year}.toList()
            ..sort((a, b) => b - a);
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('月のシート', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              if (data.months.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text('まだ切手がありません。シートの空欄をタップして、1枚目を貼りましょう。'),
                ),
              for (final m in data.months)
                Card(
                  child: ListTile(
                    key: Key('album-month-${m.year}-${m.month}'),
                    leading: const Icon(Icons.grid_view),
                    title: Text(
                      '${m.year}年${m.month}月${m.title.isEmpty ? '' : '　${m.title}'}',
                    ),
                    subtitle: Text(
                      '${m.count.filled}／${m.count.total}${m.complete ? '　完' : ''}'
                      '${m.margin.isEmpty ? '' : '　欄外${m.margin.length}枚'}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MonthSheetScreen(year: m.year, month: m.month),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Text(
                    '旅の小型シート',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Spacer(),
                  TextButton.icon(
                    key: const Key('new-trip'),
                    onPressed: () => _newTrip(context),
                    icon: const Icon(Icons.add),
                    label: const Text('作る'),
                  ),
                ],
              ),
              if (data.trips.isEmpty) const Text('旅行の日付をまとめて、記念の小型シートにできます。'),
              for (final t in data.trips)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.luggage_outlined),
                    title: Text(t.title.isEmpty ? '旅のシート' : t.title),
                    subtitle: Text(
                      '${Day.parse(t.dateFrom!).dotted} – ${Day.parse(t.dateTo!).dotted}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TripSheetScreen(sheet: t),
                      ),
                    ),
                  ),
                ),
              if (years.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text('年間ポスター', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final y in years)
                      OutlinedButton.icon(
                        key: Key('poster-$y'),
                        onPressed: () => _poster(context, y),
                        icon: const Icon(Icons.calendar_view_month),
                        label: Text('$y年'),
                      ),
                  ],
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Future<void> _poster(BuildContext context, int year) async {
    final app = context.read<AppState>();
    if (!await showPaywall(context, Premium.yearPoster)) return;
    final f = await app.renderYearPoster(year);
    if (f != null) await app.share(f);
  }

  Future<void> _newTrip(BuildContext context) async {
    final app = context.read<AppState>();
    if (!await showPaywall(context, Premium.tripSheet)) return;
    if (!context.mounted) return;
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: app.today.toDateTime(),
      helpText: '旅の日付',
    );
    if (range == null || !context.mounted) return;
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => const _TripTitleDialog(),
    );
    if (title == null) return;
    final err = await app.createTrip(
      title,
      Day.fromDateTime(range.start),
      Day.fromDateTime(range.end),
    );
    if (err != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
    }
  }
}

class _TripTitleDialog extends StatefulWidget {
  const _TripTitleDialog();

  @override
  State<_TripTitleDialog> createState() => _TripTitleDialogState();
}

class _TripTitleDialogState extends State<_TripTitleDialog> {
  final _c = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('シートの名前'),
      content: TextField(
        key: const Key('trip-title'),
        controller: _c,
        maxLength: 16,
        decoration: InputDecoration(hintText: '「秋の京都」など', errorText: _error),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('やめる'),
        ),
        FilledButton(
          onPressed: () {
            final c = checkSheetTitle(_c.text);
            if (!c.ok) {
              setState(() => _error = c.reason);
              return;
            }
            Navigator.pop(context, _c.text.trim());
          },
          child: const Text('作る'),
        ),
      ],
    );
  }
}
