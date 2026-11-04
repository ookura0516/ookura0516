import 'package:flutter/material.dart';

import '../../core/kigo.dart';
import '../../render/style.dart';
import '../theme.dart';
import 'home_screen.dart';

class KigoDetailScreen extends StatelessWidget {
  const KigoDetailScreen({super.key, required this.kigo});
  final Kigo kigo;

  @override
  Widget build(BuildContext context) {
    final p = SeasonPalette.of(kigo.season);
    return Scaffold(
      appBar: AppBar(title: Text(kigo.word)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          Text(
            kigo.word,
            style: const TextStyle(
              fontFamily: TanzakuTheme.haikuFont,
              fontSize: 36,
            ),
          ),
          Text(
            kigo.reading,
            style: const TextStyle(color: TanzakuTheme.inkDim, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '${kigo.season.label}・${kigo.period}・${kigo.category}',
            style: TextStyle(color: p.accent, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Text(
            kigo.description,
            style: const TextStyle(fontSize: 17, height: 1.6),
          ),
          if (kigo.aliases.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('別の書き方', style: TextStyle(color: TanzakuTheme.inkDim)),
            Text(kigo.aliases.join('、'), style: const TextStyle(fontSize: 16)),
          ],
          if (kigo.examples.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('例句', style: TextStyle(color: TanzakuTheme.inkDim)),
            for (final e in kigo.examples)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Text('${e.text}　${e.author}', style: TanzakuTheme.haiku),
              ),
          ],
          const SizedBox(height: 24),
          FilledButton(
            key: const Key('compose-with-kigo'),
            onPressed: () => openCompose(context, theme: kigo),
            child: const Text('この季語で詠む'),
          ),
        ],
      ),
    );
  }
}
