import 'package:flutter/material.dart';

import '../privacy_text.dart';
import '../theme.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('プライバシーポリシー')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
        children: [
          for (final (title, body) in privacySections) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: KipTheme.ink,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(body, style: const TextStyle(height: 1.6)),
            const SizedBox(height: 20),
          ],
          const Text(
            '最終更新：$privacyUpdated',
            style: TextStyle(color: KipTheme.inkDim, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
