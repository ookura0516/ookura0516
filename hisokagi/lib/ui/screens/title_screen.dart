import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../app_controller.dart';
import '../theme.dart';
import 'how_to_screen.dart';
import 'join_screen.dart';
import 'pass_screen.dart';
import 'play_screen.dart';
import 'scenario_screen.dart';

class TitleScreen extends StatelessWidget {
  const TitleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final text = Theme.of(context).textTheme;

    Future<void> startNew(Widget screen) async {
      if (app.canResume) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (c) => AlertDialog(
            content: const Text('遊びかけの部屋があります。新しく始めると、その部屋のつづきは消えます。'),
            actions: [
              TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('やめる')),
              TextButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('新しく始める')),
            ],
          ),
        );
        if (ok != true || !context.mounted) return;
      }
      await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    }

    return Scaffold(
      body: Container(
        decoration: HisokagiTheme.sky,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(flex: 2),
                Text('ひそかぎ',
                    textAlign: TextAlign.center,
                    style: text.displayMedium?.copyWith(
                        color: HisokagiTheme.star,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 6)),
                const SizedBox(height: 12),
                Text('スマホを持ち寄って、声で解く。\nふたりの協力謎解き',
                    textAlign: TextAlign.center,
                    style: text.titleMedium
                        ?.copyWith(color: HisokagiTheme.textDim, height: 1.6)),
                const Spacer(flex: 2),
                if (app.canResume) ...[
                  FilledButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => PlayScreen(session: app.session!)),
                    ),
                    child: Text('つづきから（部屋 ${app.session!.code.display}）'),
                  ),
                  const SizedBox(height: 24),
                ],
                FilledButton(
                  onPressed: () => startNew(
                      const ScenarioScreen(purpose: ScenarioPurpose.create)),
                  child: const Text('部屋をつくる'),
                ),
                const SizedBox(height: 12),
                FilledButton.tonal(
                  style: FilledButton.styleFrom(minimumSize: const Size(0, 52)),
                  onPressed: () => startNew(const JoinScreen()),
                  child: const Text('部屋にはいる'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => startNew(
                      const ScenarioScreen(purpose: ScenarioPurpose.solo)),
                  child: const Text('1台で遊ぶ（交代しながら）'),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const HowToScreen())),
                  child: const Text('遊びかた'),
                ),
                TextButton(
                  key: const Key('open-pass'),
                  onPressed: () => Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const PassScreen())),
                  child: Text(app.hasPass ? 'ひそかぎパス（有効）' : 'ひそかぎパス・購入の復元'),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
