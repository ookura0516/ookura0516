import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../l10n/app_localizations.dart';
import '../../model/models.dart';
import '../../state/providers.dart';
import '../share_flow.dart';
import '../theme.dart';

/// 設定：目の左右、ウィジェットの置き方、評価、端末内カウンタ、ライセンス、プライバシー。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _showCounters(BuildContext context, AppSettings s) async {
    final l = L10n.of(context);
    final text = s.counters.entries.map((e) => '${e.key}=${e.value}').join('\n');
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l.settingsCounters),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.settingsCountersBody, style: const TextStyle(color: NanakorobiTheme.inkDim)),
              const SizedBox(height: 12),
              Text(text, style: const TextStyle(fontFamily: 'monospace')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.settingsCopied)));
              }
            },
            child: Text(l.settingsCopy),
          ),
          TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = L10n.of(context);
    final settings = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
          children: [
            Card(
              child: Column(
                children: [
                  ListTile(title: Text(l.settingsEyeSide, style: const TextStyle(fontWeight: FontWeight.bold))),
                  RadioGroup<EyeSide>(
                    groupValue: settings.defaultEyeSide,
                    onChanged: (v) {
                      if (v != null) ref.read(settingsProvider.notifier).setDefaultEyeSide(v);
                    },
                    child: Column(
                      children: [
                        RadioListTile<EyeSide>(value: EyeSide.left, title: Text(l.eyeSideLeft)),
                        RadioListTile<EyeSide>(value: EyeSide.right, title: Text(l.eyeSideRight)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.widgets_outlined),
                    title: Text(l.settingsWidget),
                    onTap: () => showWidgetHint(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.shelves),
                    title: Text(l.settingsShelf),
                    onTap: () => context.push('/shelf'),
                  ),
                  ListTile(
                    leading: const Icon(Icons.star_outline),
                    title: Text(l.settingsRate),
                    onTap: () => ref.read(reviewProvider).openStoreListing(),
                  ),
                  ListTile(
                    leading: const Icon(Icons.outbox_outlined),
                    title: Text(l.settingsCounters),
                    onTap: () => _showCounters(context, settings),
                  ),
                  ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(l.settingsLicenses),
                    subtitle: Text(l.settingsFontLicense, style: const TextStyle(fontSize: 12)),
                    onTap: () => showLicensePage(context: context, applicationName: l.appName),
                  ),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.settingsPrivacy, style: const TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 6),
                    Text(l.settingsPrivacyBody, style: const TextStyle(height: 1.6)),
                    const SizedBox(height: 12),
                    Text(l.settingsAbout, style: const TextStyle(height: 1.6, color: NanakorobiTheme.inkDim)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            FutureBuilder<PackageInfo>(
              future: PackageInfo.fromPlatform(),
              builder: (context, snap) => Text(
                l.settingsVersion(snap.data == null ? '' : '${snap.data!.version} (${snap.data!.buildNumber})'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: NanakorobiTheme.inkDim, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
