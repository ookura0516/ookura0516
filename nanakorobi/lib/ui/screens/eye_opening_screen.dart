import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../model/models.dart';
import '../../services/settings_store.dart';
import '../../state/create_daruma.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../daruma/daruma_view.dart';
import '../theme.dart';
import '../widgets/eye_trace_pad.dart';
import '../widgets/l10n_ext.dart';
import 'share_screen.dart';

/// 開眼：指でなぞる1筆。開眼の演出、共有の促し（任意）、ウィジェット設置の案内。
class EyeOpeningScreen extends ConsumerStatefulWidget {
  const EyeOpeningScreen({super.key});

  @override
  ConsumerState<EyeOpeningScreen> createState() => _EyeOpeningScreenState();
}

class _EyeOpeningScreenState extends ConsumerState<EyeOpeningScreen> {
  Daruma? _saved;
  var _saving = false;

  DarumaLook _preview(CreateDarumaForm f, {required EyeState eyes}) => DarumaLook(
        darumaId: _saved?.id ?? 'preview',
        text: f.name.trim(),
        colorId: f.colorId,
        seed: _saved?.seed ?? 1,
        strokes: 0,
        goldLines: 0,
        firstEye: f.eyeSide,
        eyes: eyes,
        sizeRank: f.sizeRank,
        fallen: false,
        status: DarumaStatus.active,
        openedOn: ref.read(todayProvider),
      );

  Future<void> _onTraced() async {
    if (_saving || _saved != null) return;
    setState(() => _saving = true);
    final form = ref.read(createDarumaProvider);
    final d = await ref.read(darumaActionsProvider).openEye(form);
    await ref.read(darumaActionsProvider).count(MetricKeys.widgetGuideShown);
    if (!mounted) return;
    setState(() {
      _saved = d;
      _saving = false;
    });
  }

  void _finish() {
    ref.read(createDarumaProvider.notifier).reset();
    context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final form = ref.watch(createDarumaProvider);
    final t = Theme.of(context).textTheme;
    final saved = _saved;

    return PopScope(
      canPop: saved == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _finish();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(l.eyeTitle), automaticallyImplyLeading: saved == null),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          children: [
            Text(
              saved == null ? l.eyeInstruction : l.eyeDone,
              textAlign: TextAlign.center,
              style: t.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              saved == null ? l.eyeTraceHint : l.eyeDoneBody,
              textAlign: TextAlign.center,
              style: t.bodyMedium?.copyWith(color: NanakorobiTheme.inkDim),
            ),
            const SizedBox(height: 12),
            Center(
              child: SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.78,
                child: saved == null
                    ? EyeTracePad(
                        key: const Key('eye-pad'),
                        look: _preview(form, eyes: EyeState.none),
                        targetEye: form.eyeSide,
                        enabled: !_saving,
                        onTraced: _onTraced,
                        semanticsLabel: l.eyeInstruction,
                      )
                    : DarumaView(
                        key: const Key('eye-done-view'),
                        look: _preview(form, eyes: EyeState.one),
                        semanticsLabel: l.eyeDone,
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (saved == null)
              Text(l.eyeCustomNote, textAlign: TextAlign.center, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim))
            else ...[
              Card(
                child: ListTile(
                  leading: const Icon(Icons.widgets_outlined),
                  title: Text(l.eyeWidgetGuideTitle),
                  subtitle: Text(l.eyeWidgetGuideBody),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const Key('eye-share'),
                onPressed: () => context.push(Routes.shareFor(id: saved.id, occasion: ShareOccasion.eye.name)),
                icon: const Icon(Icons.ios_share),
                label: Text(l.eyeShare),
              ),
              const SizedBox(height: 8),
              FilledButton(key: const Key('eye-home'), onPressed: _finish, child: Text(l.goHome)),
            ],
          ],
        ),
      ),
    );
  }
}
