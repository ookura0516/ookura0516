import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/app_state.dart';
import '../../core/banned_words.dart';
import '../../core/crop.dart';
import '../../core/day_slots.dart';
import '../../core/frames.dart';
import '../../core/postmark_jitter.dart';
import '../../monetize/purchase_service.dart';
import '../../render/postmark_painter.dart';
import '../../render/stamp_painter.dart';
import '../theme.dart';
import '../widgets/paywall.dart';

/// 切手を作る：写真を選ぶ→トリミング→フレーム→消印→保存。
///
/// 写真を選んだあとは、そのまま「保存」を押せば切手になる（3タップ）。
/// 日付と場所は写真から自動で入り、直すのは任意。
class CreateStampScreen extends StatefulWidget {
  const CreateStampScreen({super.key, this.target});

  /// シートでタップしたマスの日。写真に撮影日があればそちらを優先する。
  final Day? target;

  @override
  State<CreateStampScreen> createState() => _CreateStampScreenState();
}

class _CreateStampScreenState extends State<CreateStampScreen> {
  StampDraft? _draft;
  ui.Image? _photo;
  int _step = 0;
  bool _busy = false;
  bool _saved = false;
  String? _error;
  List<String> _history = const [];
  final _place = TextEditingController();
  final _note = TextEditingController();

  // トリミングの操作
  CropRect? _cropAtStart;
  Offset _focalStart = Offset.zero;

  late final AppState _app;

  @override
  void initState() {
    super.initState();
    _app = context.read<AppState>();
    WidgetsBinding.instance.addPostFrameCallback((_) => _pick());
  }

  @override
  void dispose() {
    final d = _draft;
    if (d != null && !_saved) _app.discardDraft(d);
    _place.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    final photos = await _app.services.photos.pick();
    if (!mounted) return;
    if (photos.isEmpty) {
      Navigator.pop(context);
      return;
    }
    setState(() => _busy = true);
    try {
      final d = await _app.startDraft(photos.first, target: widget.target);
      final history = await _app.recentPlaces();
      final img = await _app.photoLoader.load(d.imagePath);
      if (!mounted) {
        _app.discardDraft(d);
        return;
      }
      setState(() {
        _draft = d;
        _photo = img;
        _history = history;
        _place.text = d.postmarkPlace;
        _busy = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = '写真を読めませんでした';
      });
    }
  }

  Future<void> _save() async {
    final d = _draft;
    if (d == null || _busy) return;
    d.postmarkPlace = _place.text.trim();
    d.postmarkNote = _note.text.trim();
    setState(() => _busy = true);
    var r = await _app.saveDraft(d);
    if (r is NeedsPremium && mounted) {
      setState(() => _busy = false);
      final ok = await showPaywall(context, r.feature);
      if (!ok || !mounted) return;
      setState(() => _busy = true);
      r = await _app.saveDraft(d);
    }
    if (!mounted) return;
    setState(() => _busy = false);
    switch (r) {
      case Saved():
        _saved = true;
        Navigator.pop(context, r);
      case Rejected(:final message):
        setState(() => _error = message);
      case NeedsPremium():
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final d = _draft;
    return Scaffold(
      appBar: AppBar(
        title: const Text('切手を作る'),
        actions: [
          if (d != null)
            TextButton(
              key: const Key('save-stamp'),
              onPressed: _busy ? null : _save,
              child: const Text('保存'),
            ),
        ],
      ),
      body: d == null
          ? Center(
              child: _error != null
                  ? Text(_error!)
                  : const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('写真を選んでください'),
                      ],
                    ),
            )
          : _editor(context, d),
    );
  }

  Widget _editor(BuildContext context, StampDraft d) {
    final fontId = context.select<AppState, String>((a) => a.fontId);
    final visual = StampVisual(
      photo: _photo,
      crop: d.crop,
      shape: d.shape,
      frame: frameById(d.frameId),
      postmark: PostmarkData(
        date: d.effectivePostmarkDate,
        place: _place.text.trim(),
        note: _note.text.trim(),
        seed: d.seed,
        fontId: fontId,
      ),
    );
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, c) {
                final size = Size(c.maxWidth, c.maxHeight);
                return GestureDetector(
                  key: const Key('crop-area'),
                  onScaleStart: _step == 0
                      ? (s) {
                          _cropAtStart = d.crop;
                          _focalStart = s.localFocalPoint;
                        }
                      : null,
                  onScaleUpdate: _step == 0 ? (s) => _onCrop(d, size, s) : null,
                  child: CustomPaint(
                    painter: StampPainter(visual, withPostmark: _step != 0),
                    child: const SizedBox.expand(),
                  ),
                );
              },
            ),
          ),
        ),
        _dayRow(context, d),
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _error!,
              key: const Key('create-error'),
              style: const TextStyle(color: KeshiinTheme.accent),
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: SegmentedButton<int>(
            segments: const [
              ButtonSegment(
                value: 0,
                label: Text('トリミング'),
                icon: Icon(Icons.crop),
              ),
              ButtonSegment(
                value: 1,
                label: Text('フレーム'),
                icon: Icon(Icons.filter_frames_outlined),
              ),
              ButtonSegment(
                value: 2,
                label: Text('消印'),
                icon: Icon(Icons.radio_button_unchecked),
              ),
            ],
            selected: {_step},
            showSelectedIcon: false,
            onSelectionChanged: (s) => setState(() => _step = s.first),
          ),
        ),
        SizedBox(
          height: 190,
          child: switch (_step) {
            0 => _cropPanel(d),
            1 => _framePanel(d),
            _ => _postmarkPanel(d),
          },
        ),
      ],
    );
  }

  void _onCrop(StampDraft d, Size size, ScaleUpdateDetails s) {
    final start = _cropAtStart;
    if (start == null) return;
    final g = StampGeometry.fit(
      Offset.zero & size,
      d.shape,
      frameById(d.frameId),
    );
    final iw = d.imageWidth.toDouble(), ih = d.imageHeight.toDouble();
    final max = CropRect.centered(iw, ih, d.shape.aspect);
    // 拡大：幅と高さを同じ割合で縮める（縦横比は保つ）。
    final z = s.scale.clamp(0.2, 8.0);
    var w = (start.width / z).clamp(max.width * 0.15, max.width);
    var h = w * (max.height / max.width);
    // 移動：画面の1px が元画像の何割にあたるか。
    final cover = math.max(
      g.windowBounds.width / (w * iw),
      g.windowBounds.height / (h * ih),
    );
    final delta = s.localFocalPoint - _focalStart;
    final cx = start.left + start.width / 2 - delta.dx / cover / iw;
    final cy = start.top + start.height / 2 - delta.dy / cover / ih;
    setState(() {
      d.crop = CropRect(cx - w / 2, cy - h / 2, w, h).clamped();
    });
  }

  Widget _dayRow(BuildContext context, StampDraft d) {
    final note = d.dayFromPhoto ? '撮影日' : '撮影日が読めなかったので選んだ日';
    return ListTile(
      dense: true,
      leading: const Icon(Icons.event),
      title: Text(
        '${d.day.year}年${d.day.month}月${d.day.day}日のマスに貼る',
        key: const Key('draft-day'),
      ),
      subtitle: Text(note),
      trailing: TextButton(
        onPressed: () async {
          final picked = await showDatePicker(
            context: context,
            initialDate: d.day.toDateTime(),
            firstDate: DateTime(2000),
            lastDate: _app.today.toDateTime(),
          );
          if (picked != null) {
            setState(() {
              d.day = Day.fromDateTime(picked);
              _error = null;
            });
          }
        },
        child: const Text('日を変える'),
      ),
    );
  }

  Widget _cropPanel(StampDraft d) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SegmentedButton<StampShape>(
            segments: const [
              ButtonSegment(value: StampShape.square, label: Text('正方形')),
              ButtonSegment(value: StampShape.portrait, label: Text('縦長')),
            ],
            selected: {d.shape},
            onSelectionChanged: (s) => setState(() => d.setShape(s.first)),
          ),
          const SizedBox(height: 12),
          const Text('写真を指で動かす・広げると、切手に入る範囲を変えられます。'),
          TextButton(
            onPressed: () => setState(() => d.setShape(d.shape)),
            child: const Text('中央に戻す'),
          ),
        ],
      ),
    );
  }

  Widget _framePanel(StampDraft d) {
    final app = context.watch<AppState>();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          for (final f in allFrames)
            Padding(
              padding: const EdgeInsets.all(6),
              child: InkWell(
                key: Key('frame-${f.id}'),
                onTap: () => setState(() {
                  d.frameId = f.id;
                  _error = null;
                }),
                child: Container(
                  width: 104,
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: d.frameId == f.id
                          ? KeshiinTheme.ink
                          : KeshiinTheme.line,
                      width: d.frameId == f.id ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: CustomPaint(
                          painter: StampPainter(
                            StampVisual(
                              photo: _photo,
                              crop: d.crop,
                              shape: d.shape,
                              frame: f,
                            ),
                            withPostmark: false,
                          ),
                          child: const SizedBox.expand(),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(f.name, style: const TextStyle(fontSize: 12)),
                      if (f.premium && !app.unlocked(Premium.extraFrames))
                        const Text(
                          '記念',
                          style: TextStyle(
                            fontSize: 10,
                            color: KeshiinTheme.accent,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _postmarkPanel(StampDraft d) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                key: const Key('postmark-place'),
                controller: _place,
                maxLength: 12,
                decoration: InputDecoration(
                  labelText: '場所（市区町村や「家」など）',
                  counterText: '',
                  helperText: d.placeFromPhoto ? '写真の位置から' : null,
                ),
                onChanged: (_) => setState(() => _error = null),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              key: const Key('reroll'),
              tooltip: '押し直す',
              onPressed: () => setState(
                () => d.seed = newPostmarkSeed(DateTime.now()) ^ d.seed,
              ),
              icon: const Icon(Icons.refresh),
            ),
          ],
        ),
        if (_history.isNotEmpty)
          Wrap(
            spacing: 6,
            children: [
              for (final h in _history)
                ActionChip(
                  label: Text(h),
                  onPressed: () => setState(() => _place.text = h),
                ),
            ],
          ),
        const SizedBox(height: 8),
        TextField(
          key: const Key('postmark-note'),
          controller: _note,
          maxLength: 10,
          decoration: const InputDecoration(
            labelText: '一言（任意）',
            counterText: '',
          ),
          onChanged: (v) => setState(() {
            final c = checkPostmarkNote(v);
            _error = c.ok ? null : c.reason;
          }),
        ),
        TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: d.effectivePostmarkDate.toDateTime(),
              firstDate: DateTime(2000),
              lastDate: _app.today.toDateTime(),
            );
            if (picked != null) {
              setState(() => d.postmarkDate = Day.fromDateTime(picked));
            }
          },
          child: Text('消印の日付：${d.effectivePostmarkDate.dotted}'),
        ),
      ],
    );
  }
}
