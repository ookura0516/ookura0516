import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/session.dart';
import '../app_controller.dart';
import '../theme.dart';

class EndingScreen extends StatelessWidget {
  const EndingScreen({super.key, required this.session});

  final GameSession session;

  static String _duration(Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    return '$m分${s.toString().padLeft(2, '0')}秒';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: Container(
        decoration: HisokagiTheme.sky,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const SizedBox(height: 24),
              Text('クリア',
                  textAlign: TextAlign.center,
                  style: text.displaySmall?.copyWith(
                      color: HisokagiTheme.star, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              for (final role in session.sortedRoles)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(session.roleInfo(role).name,
                            style: text.titleSmall
                                ?.copyWith(color: HisokagiTheme.star)),
                        const SizedBox(height: 8),
                        Text(session.scenario.ending(role),
                            style: const TextStyle(height: 1.9)),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _row('かかった時間', _duration(session.elapsed)),
                      _row('見たヒント', '${session.hintsUsed}回'),
                      _row('まちがえた回数', '${session.mistakes}回'),
                      _row('部屋番号', session.code.display),
                    ],
                  ),
                ),
              ),
              if (session.mode == PlayMode.linked)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('時間とヒントは、この端末の記録です。',
                      textAlign: TextAlign.center,
                      style: text.bodySmall
                          ?.copyWith(color: HisokagiTheme.textDim)),
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () async {
                  await context.read<AppController>().discard();
                  if (context.mounted) {
                    Navigator.popUntil(context, (r) => r.isFirst);
                  }
                },
                child: const Text('タイトルにもどる'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Expanded(
                child: Text(label,
                    style: const TextStyle(color: HisokagiTheme.textDim))),
            Text(value, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
}
