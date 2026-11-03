import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../game/session.dart';
import '../../scenario/model.dart';
import '../../scenario/registry.dart';
import '../app_controller.dart';
import '../theme.dart';
import 'ready_screen.dart';

enum ScenarioPurpose { create, solo }

class ScenarioScreen extends StatelessWidget {
  const ScenarioScreen({super.key, required this.purpose});

  final ScenarioPurpose purpose;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('シナリオをえらぶ')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          for (final s in scenarios)
            Card(
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _choose(context, s),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(s.title,
                              style: text.titleLarge
                                  ?.copyWith(color: HisokagiTheme.star)),
                        ),
                        if (s.free) const Chip(label: Text('無料')),
                      ]),
                      const SizedBox(height: 8),
                      Text(s.tagline, style: const TextStyle(height: 1.6)),
                      const SizedBox(height: 8),
                      Text(
                          '${s.playerCounts.map((p) => '$p人').join('・')}　約${s.minutes}分',
                          style: text.bodySmall
                              ?.copyWith(color: HisokagiTheme.textDim)),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          Card(
            color: HisokagiTheme.bg,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Text('追加シナリオと3〜4人用は準備中です。',
                  style: text.bodyMedium?.copyWith(color: HisokagiTheme.textDim)),
            ),
          ),
        ],
      ),
    );
  }

  void _choose(BuildContext context, ScenarioDef scenario) {
    final app = context.read<AppController>();
    final code = AppController.newRoomCode(scenario);
    final solo = purpose == ScenarioPurpose.solo;
    final session = app.start(
      code: code,
      mode: solo ? PlayMode.solo : PlayMode.linked,
      roles: solo
          ? {for (final r in scenario.rolesFor(code.players)) r.role}
          : {Role.a},
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ReadyScreen(
          session: session,
          purpose: solo ? ReadyPurpose.solo : ReadyPurpose.created,
        ),
      ),
    );
  }
}
