import 'package:flutter/material.dart';

import '../../game/session.dart';
import '../theme.dart';
import 'play_screen.dart';

enum ReadyPurpose { created, joined, solo }

/// 部屋番号と役を確かめてから始める画面。
class ReadyScreen extends StatelessWidget {
  const ReadyScreen({super.key, required this.session, required this.purpose});

  final GameSession session;
  final ReadyPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: Text(session.scenario.title)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (purpose == ReadyPurpose.created) ...[
            const Text('相棒に、この部屋番号を伝えてください。',
                textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  session.code.display,
                  key: const Key('room-code'),
                  textAlign: TextAlign.center,
                  style: text.displaySmall?.copyWith(
                      color: HisokagiTheme.star,
                      letterSpacing: 8,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text('相棒は「部屋にはいる」から番号を入れます。',
                textAlign: TextAlign.center,
                style: text.bodySmall?.copyWith(color: HisokagiTheme.textDim)),
            const SizedBox(height: 24),
          ],
          if (purpose == ReadyPurpose.solo) ...[
            const Text(
              '1台を交代で使います。画面の上で役を切り替えられます。'
              '切り替えるときは、もうひとりは画面を見ないようにしましょう。',
              style: TextStyle(height: 1.6),
            ),
            const SizedBox(height: 16),
          ],
          Text(purpose == ReadyPurpose.solo ? '役' : 'あなたの役',
              style: text.titleSmall?.copyWith(color: HisokagiTheme.textDim)),
          const SizedBox(height: 4),
          for (final role in session.sortedRoles)
            Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Text(session.roleInfo(role).name,
                    style: text.titleLarge?.copyWith(color: HisokagiTheme.star)),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(session.roleInfo(role).place,
                      style: const TextStyle(height: 1.6)),
                ),
              ),
            ),
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('start'),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => PlayScreen(session: session)),
            ),
            child: const Text('はじめる'),
          ),
        ],
      ),
    );
  }
}
