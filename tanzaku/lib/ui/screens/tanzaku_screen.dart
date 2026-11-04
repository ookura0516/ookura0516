import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../render/image_export.dart';
import '../../render/style.dart';
import '../../render/tanzaku_painter.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';

/// 短冊。縦書きのプレビューと、書体・和紙・落款・日付の切り替え、保存・共有。
class TanzakuScreen extends StatefulWidget {
  const TanzakuScreen({super.key, required this.haikuId});
  final int haikuId;

  @override
  State<TanzakuScreen> createState() => _TanzakuScreenState();
}

class _TanzakuScreenState extends State<TanzakuScreen> {
  late TanzakuStyle _style;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _style = context.read<AppController>().lastStyle;
  }

  Future<void> _set(
    TanzakuStyle next, {
    required bool premium,
    String reason = '',
  }) async {
    final app = context.read<AppController>();
    if (premium && !await ensureSuzuri(context, reason: reason)) return;
    if (!mounted) return;
    setState(() => _style = next);
    await app.rememberStyle(next);
  }

  TanzakuContent _content(AppController app) {
    final h = app.haikuById(widget.haikuId)!;
    final a = app.analyzeBody(h.body);
    return TanzakuContent(
      lines: splitLines(h.body),
      maegaki: h.maegaki,
      gago: app.gago,
      date: h.composedOn,
      kigoRanges: a.kigoRanges,
      season: app.dictionary.byId(h.kigoId)?.season,
    );
  }

  Future<void> _export({required bool save}) async {
    final app = context.read<AppController>();
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      final png = await renderPng(
        TanzakuPainter(content: _content(app), style: _style),
        _style.form.imageSize,
      );
      final name = 'tanzaku_${widget.haikuId}_${_style.form.name}.png';
      if (save) {
        await app.share.saveImage(png, name);
        messenger.showSnackBar(const SnackBar(content: Text('写真に保存しました')));
      } else {
        final k = app.dictionary.byId(
          app.haikuById(widget.haikuId)?.themeKigoId,
        );
        await app.share.shareImage(
          png,
          name,
          text: k == null ? null : '#タンザク兼題 ${k.word}',
        );
      }
      await app.afterTanzakuSaved();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('うまくいきませんでした（$e）')));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final h = app.haikuById(widget.haikuId);
    if (h == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('この句は削除されました')),
      );
    }
    final locked = !app.hasSuzuri;
    final size = _style.form.imageSize;
    return Scaffold(
      appBar: AppBar(title: const Text('短冊')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 460),
                child: AspectRatio(
                  aspectRatio: size.width / size.height,
                  child: Semantics(
                    image: true,
                    label: '短冊のプレビュー：${h.body.replaceAll('\n', ' ')}',
                    child: CustomPaint(
                      key: const Key('tanzaku-preview'),
                      painter: TanzakuPainter(
                        content: _content(app),
                        style: _style,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const Key('save-image'),
                    onPressed: _busy ? null : () => _export(save: true),
                    icon: const Icon(Icons.download),
                    label: const Text('保存'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const Key('share-image'),
                    onPressed: _busy ? null : () => _export(save: false),
                    icon: const Icon(Icons.ios_share),
                    label: const Text('共有'),
                  ),
                ),
              ],
            ),
            if (app.gago.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: 12),
                child: Text(
                  '設定で雅号を入れると、落款（印）が付きます。',
                  style: TextStyle(color: TanzakuTheme.inkDim),
                ),
              ),
            const SizedBox(height: 20),
            _Section('形', [
              for (final f in TanzakuForm.values)
                ChoiceChip(
                  label: LockedLabel(f.label, locked: locked && f.premium),
                  selected: _style.form == f,
                  onSelected: (_) => _set(
                    _style.copyWith(form: f),
                    premium: f.premium,
                    reason: '色紙の形はすずりで使えます。',
                  ),
                ),
            ]),
            _Section('書体', [
              for (final f in TanzakuFont.values)
                ChoiceChip(
                  key: Key('font-${f.name}'),
                  label: LockedLabel(f.label, locked: locked && f.premium),
                  selected: _style.font == f,
                  onSelected: (_) => _set(
                    _style.copyWith(font: f),
                    premium: f.premium,
                    reason: '書体の追加はすずりで使えます。',
                  ),
                ),
            ]),
            _Section('和紙', [
              for (final w in Washi.values)
                ChoiceChip(
                  avatar: CircleAvatar(backgroundColor: w.paper, radius: 8),
                  label: LockedLabel(w.label, locked: locked && w.premium),
                  selected: _style.washi == w,
                  onSelected: (_) => _set(
                    _style.copyWith(washi: w),
                    premium: w.premium,
                    reason: '和紙の追加はすずりで使えます。',
                  ),
                ),
            ]),
            _Section('落款・日付', [
              FilterChip(
                key: const Key('toggle-seal'),
                label: const Text('落款'),
                selected: _style.showSeal,
                onSelected: (v) =>
                    _set(_style.copyWith(showSeal: v), premium: false),
              ),
              FilterChip(
                key: const Key('toggle-date'),
                label: const Text('日付'),
                selected: _style.showDate,
                onSelected: (v) =>
                    _set(_style.copyWith(showDate: v), premium: false),
              ),
            ]),
            if (_style.showSeal)
              _Section('落款の形', [
                for (final shape in SealShape.values)
                  ChoiceChip(
                    label: LockedLabel(
                      shape == SealShape.square ? '角印' : '丸印',
                      locked: locked && shape != SealShape.square,
                    ),
                    selected: _style.seal.shape == shape,
                    onSelected: (_) =>
                        _setSeal(_style.seal.copyWith(shape: shape)),
                  ),
                for (final carve in SealCarve.values)
                  ChoiceChip(
                    label: LockedLabel(
                      carve == SealCarve.hakubun ? '白文' : '朱文',
                      locked: locked && carve != SealCarve.hakubun,
                    ),
                    selected: _style.seal.carve == carve,
                    onSelected: (_) =>
                        _setSeal(_style.seal.copyWith(carve: carve)),
                  ),
                for (final c in SealStyle.colors)
                  ChoiceChip(
                    label: CircleAvatar(backgroundColor: c, radius: 9),
                    selected: _style.seal.color == c,
                    onSelected: (_) => _setSeal(_style.seal.copyWith(color: c)),
                  ),
              ]),
          ],
        ),
      ),
    );
  }

  void _setSeal(SealStyle s) => _set(
    _style.copyWith(seal: s),
    premium: s.premium,
    reason: '落款のカスタムはすずりで使えます。',
  );
}

class _Section extends StatelessWidget {
  const _Section(this.title, this.children);
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(color: TanzakuTheme.inkDim)),
        const SizedBox(height: 6),
        Wrap(spacing: 8, runSpacing: 6, children: children),
      ],
    ),
  );
}
