import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../daily/daily.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/ticket.dart';

/// 共有画像の下見と共有。式を「★★★」で隠すか見せるかを選べる。
class ShareScreen extends StatefulWidget {
  const ShareScreen({
    super.key,
    required this.number,
    required this.day,
    this.serial,
    this.caption,
  });

  final String number;
  final Day day;
  final int? serial;
  final String? caption;

  @override
  State<ShareScreen> createState() => _ShareScreenState();
}

class _ShareScreenState extends State<ShareScreen> {
  final _boundary = GlobalKey();
  bool _busy = false;

  Future<void> _share(AppController app) async {
    setState(() => _busy = true);
    try {
      final png = await captureBoundary(_boundary, app.settings.shareSize);
      if (png == null) return;
      final found = app.foundCount(widget.number);
      final goal = app.goalFor(widget.number);
      final head = widget.serial != null
          ? '今日の切符 ${widget.number}（No.${widget.serial}）'
          : '切符 ${widget.number}';
      await app.share.sharePng(png, text: '$head 解けた！ $found/$goal 通り #キップテン');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final s = app.settings;
    return Scaffold(
      appBar: AppBar(title: const Text('共有')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: AspectRatio(
                  aspectRatio: s.shareSize.aspect,
                  child: RepaintBoundary(
                    key: _boundary,
                    child: ShareCard(
                      number: widget.number,
                      day: widget.day,
                      serial: widget.serial,
                      caption: widget.caption,
                      hide: s.hideExpression,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            key: const Key('toggle-hide'),
            title: const Text('式を隠す（★★★）'),
            subtitle: const Text('オフにすると、解き方がそのまま載ります'),
            value: s.hideExpression,
            onChanged: (v) => app.updateSettings((s) => s.hideExpression = v),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<ResultImageSize>(
              segments: [
                for (final z in ResultImageSize.values)
                  ButtonSegment(value: z, label: Text(z.label)),
              ],
              selected: {s.shareSize},
              onSelectionChanged: (v) =>
                  app.updateSettings((s) => s.shareSize = v.first),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            key: const Key('do-share'),
            onPressed: _busy ? null : () => _share(app),
            icon: const Icon(Icons.ios_share),
            label: const Text('画像を共有'),
          ),
        ],
      ),
    );
  }
}

/// 共有画像の中身。全解の日は切符を3枚、扇に並べる。
class ShareCard extends StatelessWidget {
  const ShareCard({
    super.key,
    required this.number,
    required this.day,
    required this.hide,
    this.serial,
    this.caption,
  });

  final String number;
  final Day day;
  final int? serial;
  final String? caption;
  final bool hide;

  static const hiddenExpression = '★★★';

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final found = app.foundDisplays(number);
    final goal = app.goalFor(number);
    final all = app.recordOf(number)?.allFound ?? false;

    Widget ticket(String? expr) => Ticket(
      design: app.design,
      number: number,
      dateText: day.dotted,
      serial: serial,
      expression: expr == null
          ? null
          : '${hide ? hiddenExpression : expr} = 10',
      punch: 1,
      caption: caption,
    );

    final Widget body;
    if (all) {
      // 見つけた解を3枚に。解が3つ未満なら、同じ切符を重ねる。
      final exprs = [
        for (var i = 0; i < 3; i++)
          found.isEmpty ? null : found[i % found.length],
      ];
      body = TicketFan(
        key: const Key('share-fan'),
        tickets: [for (final e in exprs) ticket(e)],
      );
    } else {
      body = ticket(found.isEmpty ? null : found.last);
    }

    return Container(
      color: KipTheme.bg,
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            serial != null ? '今日の切符' : '切符',
            style: const TextStyle(
              color: KipTheme.ink,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            all ? '全 $goal 通り 見つけた' : '解けた！ ${found.length}/$goal 通り',
            style: const TextStyle(color: KipTheme.inkDim, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: FittedBox(child: SizedBox(width: 320, child: body)),
          ),
          const SizedBox(height: 16),
          const Text(
            'キップテン',
            style: TextStyle(
              color: KipTheme.inkDim,
              fontSize: 11,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }
}
