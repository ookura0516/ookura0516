import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/session.dart';
import '../../scenario/model.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/panels.dart';
import 'ending_screen.dart';
import 'pass_screen.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({super.key, required this.session});

  final GameSession session;

  @override
  State<PlayScreen> createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  final _answer = TextEditingController();
  final _pass = TextEditingController();
  int? _cable;
  int _hour = 12;
  int _minute = 0;
  String _stageKey = '';

  /// 1台モードで役を切り替えたときの目隠し。
  bool _curtain = false;

  GameSession get s => widget.session;

  /// 入力欄の文字は大きく字間を空けるが、案内の文字は普通の大きさにする。
  static const _hintStyle = TextStyle(
      fontSize: 16, letterSpacing: 0, color: HisokagiTheme.textDim);

  @override
  void initState() {
    super.initState();
    _curtain = s.mode == PlayMode.solo;
  }

  @override
  void dispose() {
    _answer.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _resetInputsIfStageChanged() {
    final key = '${s.activeRole.name}:${s.currentIndex}';
    if (key == _stageKey) return;
    _stageKey = key;
    _answer.clear();
    _pass.clear();
    _cable = null;
    _hour = 12;
    _minute = 0;
  }

  void _snack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _rawAnswer(StageInstance stage) => switch (stage.input) {
        TimeInput() => TimeInput.format(_hour, _minute),
        CableChoiceInput() => _cable?.toString() ?? '',
        _ => _answer.text,
      };

  Future<void> _submitAnswer() async {
    final stage = s.currentStage!;
    final raw = _rawAnswer(stage);
    if (raw.isEmpty) return;
    final index = s.currentIndex;
    if (s.submitAnswer(raw) == SubmitResult.wrong) {
      _snack(stage.input is CableChoiceInput
          ? '火花が散った。ちがうケーブルだったようだ。'
          : '反応がない。ちがうようだ。');
      return;
    }
    FocusScope.of(context).unfocus();
    if (s.mode == PlayMode.linked) {
      await _showPassphrase(index);
    } else {
      _snack('正解！');
    }
    _goEndingIfCleared();
  }

  void _submitPassphrase() {
    if (s.submitPassphrase(_pass.text) == SubmitResult.wrong) {
      _snack('合言葉がちがうようだ。相棒にもう一度聞いてみよう。');
      return;
    }
    FocusScope.of(context).unfocus();
    _snack('合言葉が通じた。');
    _goEndingIfCleared();
  }

  void _goEndingIfCleared() {
    if (!mounted || !s.isClearedFor(s.activeRole)) return;
    if (s.mode == PlayMode.solo && !s.isCleared) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => EndingScreen(session: s)),
    );
  }

  Future<void> _showPassphrase(int stage) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        title: const Text('正解！', textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('相棒に、この合言葉を伝えてください。', textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              s.passphraseOf(stage),
              key: const Key('passphrase'),
              style: const TextStyle(
                  fontSize: 40,
                  color: HisokagiTheme.star,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 6),
            ),
            const SizedBox(height: 12),
            const Text('あとから手帳でも見られます。',
                style: TextStyle(color: HisokagiTheme.textDim, fontSize: 12)),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('伝えた'),
          ),
        ],
      ),
    );
  }

  Future<void> _switchRole(Role role) async {
    if (role == s.activeRole) return;
    setState(() => _curtain = true);
    s.switchRole(role);
  }

  // ------------------------------------------------------------ シート

  void _openNotebook() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (c) {
        final entries = s.notebookFor(s.activeRole);
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              Text('手帳', style: Theme.of(c).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (entries.isEmpty)
                const Text('まだ何も書いていない。',
                    style: TextStyle(color: HisokagiTheme.textDim)),
              for (final e in entries)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(e.label),
                  subtitle: s.mode == PlayMode.linked
                      ? Text('相棒への合言葉：${s.passphraseOf(e.stage)}')
                      : null,
                  trailing: Text(e.value,
                      style: const TextStyle(
                          fontSize: 20, color: HisokagiTheme.star)),
                ),
            ],
          ),
        );
      },
    );
  }

  void _openHints() {
    final app = context.read<AppController>();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (c) => ListenableBuilder(
        listenable: s,
        builder: (c, _) {
          final stage = s.currentStage;
          if (stage == null) return const SizedBox.shrink();
          final level = s.hintLevel(s.activeRole, s.currentIndex);
          final hints = stage.hints[s.activeRole]!;
          final needsAd = app.hintNeedsAd(s, level + 1);
          final next = switch (level) {
            0 => 'ヒント1を見る',
            1 => needsAd ? '広告を見て ヒント2を開く' : 'ヒント2を見る',
            2 => needsAd ? '広告を見て 答えを開く' : '答えを見る',
            _ => null,
          };
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('ヒント：${stage.title}',
                      style: Theme.of(c).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  for (var i = 0; i < level && i < hints.length; i++)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text('ヒント${i + 1}：${hints[i]}',
                            style: const TextStyle(height: 1.6)),
                      ),
                    ),
                  if (level >= hintAnswerLevel)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Text('答え：${stage.answerDisplay}',
                            style: const TextStyle(
                                fontSize: 18, color: HisokagiTheme.star)),
                      ),
                    ),
                  if (next != null) ...[
                    const SizedBox(height: 12),
                    OutlinedButton(
                      key: const Key('next-hint'),
                      onPressed: () async {
                        final unlock = await app.unlockHint(s, level + 1);
                        if (unlock == HintUnlock.skipped) {
                          if (c.mounted) {
                            ScaffoldMessenger.of(c).showSnackBar(const SnackBar(
                                content: Text('広告を最後まで見ると、ヒントが開きます。')));
                          }
                          return;
                        }
                        s.revealNextHint();
                      },
                      child: Text(next),
                    ),
                    if (needsAd)
                      TextButton(
                        onPressed: () {
                          Navigator.pop(c);
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const PassScreen()));
                        },
                        child: const Text('ひそかぎパスなら、広告なしで開きます'),
                      ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _quit() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        content: const Text('この部屋をやめますか？つづきは消えます。'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('つづける')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('やめる')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await context.read<AppController>().discard();
    if (mounted) Navigator.popUntil(context, (r) => r.isFirst);
  }

  // ------------------------------------------------------------ 画面

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: s,
      builder: (context, _) {
        _resetInputsIfStageChanged();
        final stage = s.currentStage;
        return Scaffold(
          appBar: AppBar(
            title: Text(stage == null
                ? s.scenario.title
                : '${s.currentIndex + 1}/${s.stages.length}　${stage.title}'),
            actions: [
              IconButton(
                tooltip: '手帳',
                icon: const Icon(Icons.menu_book_outlined),
                onPressed: _openNotebook,
              ),
              IconButton(
                tooltip: 'ヒント',
                icon: const Icon(Icons.lightbulb_outline),
                onPressed: stage == null ? null : _openHints,
              ),
              PopupMenuButton<String>(
                onSelected: (v) {
                  if (v == 'quit') _quit();
                },
                itemBuilder: (_) => [
                  PopupMenuItem(
                    enabled: false,
                    child: Text('部屋番号 ${s.code.display}'),
                  ),
                  const PopupMenuItem(value: 'quit', child: Text('この部屋をやめる')),
                ],
              ),
            ],
          ),
          body: _curtain ? _curtainView() : _stageView(stage),
        );
      },
    );
  }

  Widget _curtainView() {
    final info = s.roleInfo(s.activeRole);
    return Container(
      decoration: HisokagiTheme.sky,
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('「${info.name}」の番です',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: HisokagiTheme.star)),
          const SizedBox(height: 16),
          const Text('ほかの人は、画面を見ないでください。',
              textAlign: TextAlign.center),
          const SizedBox(height: 32),
          FilledButton(
            key: const Key('curtain-open'),
            onPressed: () => setState(() => _curtain = false),
            child: const Text('見る'),
          ),
        ],
      ),
    );
  }

  Widget _stageView(StageInstance? stage) {
    if (stage == null) {
      // 自分の分は終わり、1台モードでほかの役が残っているとき
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text('この役のステージはすべて終わりました。',
              style: Theme.of(context).textTheme.titleMedium),
        ),
      );
    }
    final view = stage.views[s.activeRole]!;
    final canPickCable = s.isInputTurn && stage.input is CableChoiceInput;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      children: [
        if (s.mode == PlayMode.solo) _roleSwitcher(),
        if (s.currentIndex == 0) _prologue(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(view.intro,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8)),
        ),
        for (final p in view.panels)
          PanelView(
            panel: p,
            selectedCable: canPickCable ? _cable : null,
            onCableSelected:
                canPickCable && p is CablePanel ? (i) => setState(() => _cable = i) : null,
          ),
        const SizedBox(height: 16),
        if (s.isInputTurn)
          _answerArea(stage)
        else if (s.mode == PlayMode.linked)
          _passphraseArea(stage)
        else
          _soloWaitArea(stage),
      ],
    );
  }

  Widget _roleSwitcher() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: SegmentedButton<Role>(
        segments: [
          for (final r in s.sortedRoles)
            ButtonSegment(value: r, label: Text(s.roleInfo(r).name)),
        ],
        selected: {s.activeRole},
        onSelectionChanged: (v) => _switchRole(v.first),
      ),
    );
  }

  Widget _prologue() {
    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: const Text('はじまり'),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        children: [
          Text(s.scenario.prologue(s.activeRole),
              style: const TextStyle(height: 1.8)),
        ],
      ),
    );
  }

  Widget _answerArea(StageInstance stage) {
    final input = stage.input;
    final field = switch (input) {
      DigitsInput(:final length) => TextField(
          key: const Key('answer'),
          controller: _answer,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          maxLength: length,
          style: const TextStyle(fontSize: 30, letterSpacing: 10),
          decoration: InputDecoration(
              hintText: '数字$lengthけた', hintStyle: _hintStyle, counterText: ''),
          onSubmitted: (_) => _submitAnswer(),
        ),
      KanaInput(:final length) => TextField(
          key: const Key('answer'),
          controller: _answer,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 26, letterSpacing: 6),
          decoration:
              InputDecoration(hintText: 'ひらがな$length文字', hintStyle: _hintStyle),
          onSubmitted: (_) => _submitAnswer(),
        ),
      TimeInput() => Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DropdownButton<int>(
              key: const Key('answer-hour'),
              value: _hour,
              items: [
                for (var h = 1; h <= 12; h++)
                  DropdownMenuItem(value: h, child: Text('$h', style: const TextStyle(fontSize: 24))),
              ],
              onChanged: (v) => setState(() => _hour = v!),
            ),
            const Text(' 時  ', style: TextStyle(fontSize: 20)),
            DropdownButton<int>(
              key: const Key('answer-minute'),
              value: _minute,
              items: [
                for (var m = 0; m < 60; m += 5)
                  DropdownMenuItem(
                      value: m,
                      child: Text(m.toString().padLeft(2, '0'),
                          style: const TextStyle(fontSize: 24))),
              ],
              onChanged: (v) => setState(() => _minute = v!),
            ),
            const Text(' 分', style: TextStyle(fontSize: 20)),
          ],
        ),
      CableChoiceInput() => Text(
          _cable == null ? '抜くケーブルをタップして選ぶ' : '左から$_cable本目を選んでいる',
          textAlign: TextAlign.center,
          style: const TextStyle(color: HisokagiTheme.textDim),
        ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('あなたが答えを入れる番です。',
            textAlign: TextAlign.center,
            style: TextStyle(color: HisokagiTheme.star)),
        const SizedBox(height: 12),
        field,
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('submit-answer'),
          onPressed: input is CableChoiceInput && _cable == null
              ? null
              : _submitAnswer,
          child: Text(input is CableChoiceInput ? 'このケーブルを抜く' : '答える'),
        ),
      ],
    );
  }

  Widget _passphraseArea(StageInstance stage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          stage.waitingNote ?? '相棒が答えを入れると、相棒の画面に合言葉が出ます。',
          textAlign: TextAlign.center,
          style: const TextStyle(color: HisokagiTheme.textDim, height: 1.6),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('passphrase-input'),
          controller: _pass,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 24, letterSpacing: 6),
          decoration: const InputDecoration(
              hintText: '相棒から聞いた合言葉', hintStyle: _hintStyle),
          onSubmitted: (_) => _submitPassphrase(),
        ),
        const SizedBox(height: 12),
        FilledButton(
          key: const Key('submit-passphrase'),
          onPressed: _submitPassphrase,
          child: const Text('合言葉を入れる'),
        ),
      ],
    );
  }

  Widget _soloWaitArea(StageInstance stage) {
    final name = s.roleInfo(stage.inputRole).name;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('このステージの答えは「$name」の画面で入れます。',
            textAlign: TextAlign.center,
            style: const TextStyle(color: HisokagiTheme.textDim)),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () => _switchRole(stage.inputRole),
          child: Text('「$name」に交代する'),
        ),
      ],
    );
  }
}
