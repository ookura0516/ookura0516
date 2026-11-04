import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/router.dart';
import '../../core/entitlements.dart';
import '../../model/models.dart';
import '../../services/plus_service.dart';
import '../../state/app_deps.dart';
import '../../state/daruma_actions.dart';
import '../../state/providers.dart';
import '../theme.dart';
import '../widgets/l10n_ext.dart';

/// 設定：通知、目の左右、ウィジェットの見た目、データの書き出し・読み込み、購入の復元。
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  Future<void> _toggleReminder(BuildContext context, WidgetRef ref, bool on) async {
    if (on) {
      final granted = await ref.read(appDepsProvider).reminders.requestPermission();
      if (!granted) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.reminderPermissionDenied)));
        }
        return;
      }
    }
    await ref.read(settingsProvider.notifier).setReminder(enabled: on);
  }

  Future<void> _pickTime(BuildContext context, WidgetRef ref) async {
    final s = ref.read(settingsProvider);
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
    );
    if (picked == null) return;
    await ref.read(settingsProvider.notifier).setReminder(
          enabled: s.reminderEnabled,
          minuteOfDay: picked.hour * 60 + picked.minute,
        );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final json = await ref.read(darumaActionsProvider).exportJson();
    await ref.read(appDepsProvider).backupFiles.exportJson(json, fileName: 'nanakorobi_backup.json');
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final text = await ref.read(appDepsProvider).backupFiles.pickJson();
    if (text == null) return;
    final result = await ref.read(darumaActionsProvider).importJson(text);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.ok ? l.importDone(result.darumas) : l.importFailed(result.error!))),
    );
  }

  Future<void> _shareMetrics(BuildContext context, WidgetRef ref) async {
    final m = await ref.read(appDepsProvider).metrics.load();
    final lines = (m.entries.toList()..sort((a, b) => a.key.compareTo(b.key))).map((e) => '${e.key}: ${e.value}');
    if (!context.mounted) return;
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.metricsTitle),
        content: SingleChildScrollView(child: Text(lines.isEmpty ? '—' : lines.join('\n'))),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text(context.l10n.close))],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(settingsProvider);
    final plus = ref.watch(plusProvider);
    final active = ref.watch(activeDarumasProvider);
    final t = Theme.of(context).textTheme;
    final notifier = ref.read(settingsProvider.notifier);

    Widget section(String title) => Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
          child: Text(title, style: t.titleSmall?.copyWith(color: NanakorobiTheme.inkDim)),
        );

    final timeLabel = MaterialLocalizations.of(context).formatTimeOfDay(
      TimeOfDay(hour: s.reminderHour, minute: s.reminderMinute),
      alwaysUse24HourFormat: true,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsTitle)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          section(l.reminderSection),
          SwitchListTile(
            key: const Key('reminder-toggle'),
            title: Text(l.reminderToggle),
            value: s.reminderEnabled,
            onChanged: (v) => _toggleReminder(context, ref, v),
          ),
          ListTile(
            key: const Key('reminder-time'),
            title: Text(l.reminderTime),
            trailing: Text(timeLabel, style: t.titleMedium),
            enabled: s.reminderEnabled,
            onTap: () => _pickTime(context, ref),
          ),
          section(l.eyeSideSection),
          RadioGroup<EyeSide>(
            groupValue: s.eyeSideDefault,
            onChanged: (v) => notifier.setEyeSideDefault(v!),
            child: Column(
              children: [
                RadioListTile<EyeSide>(key: const Key('eye-left'), value: EyeSide.left, title: Text(l.eyeLeft)),
                RadioListTile<EyeSide>(key: const Key('eye-right'), value: EyeSide.right, title: Text(l.eyeRight)),
              ],
            ),
          ),
          section(l.widgetSection),
          ListTile(
            title: Text(l.widgetStyleLabel),
            trailing: SegmentedButton<WidgetStyle>(
              segments: [
                ButtonSegment(value: WidgetStyle.paper, label: Text(l.widgetStylePaper)),
                ButtonSegment(value: WidgetStyle.plain, label: Text(l.widgetStylePlain)),
              ],
              selected: {s.widgetStyle},
              onSelectionChanged: (v) => notifier.setWidgetStyle(v.first),
            ),
          ),
          if (active.length > 1)
            ListTile(
              title: Text(l.widgetDarumaLabel),
              trailing: DropdownButton<String?>(
                value: active.any((b) => b.id == s.widgetDarumaId) ? s.widgetDarumaId : null,
                items: [
                  DropdownMenuItem<String?>(value: null, child: Text(l.widgetDarumaAuto)),
                  for (final b in active) DropdownMenuItem<String?>(value: b.id, child: Text(b.daruma.name)),
                ],
                onChanged: notifier.setWidgetDaruma,
              ),
            ),
          ListTile(
            leading: const Icon(Icons.widgets_outlined),
            title: Text(l.eyeWidgetGuideTitle),
            subtitle: Text(l.widgetGuideShort),
          ),
          section(l.dayBoundaryLabel),
          RadioGroup<int>(
            groupValue: s.dayShiftHours,
            onChanged: (v) => notifier.update((x) => x.copyWith(dayShiftHours: v!)),
            child: Column(
              children: [
                RadioListTile<int>(value: 0, title: Text(l.dayBoundaryStandard)),
                RadioListTile<int>(value: 3, title: Text(l.dayBoundaryShift)),
              ],
            ),
          ),
          section(l.dataSection),
          ListTile(
            key: const Key('export-json'),
            leading: const Icon(Icons.upload_file_outlined),
            title: Text(l.exportJson),
            enabled: Entitlements.canExport(plus.hasPlus),
            onTap: () => _export(context, ref),
          ),
          ListTile(
            key: const Key('import-json'),
            leading: const Icon(Icons.download_outlined),
            title: Text(l.importJson),
            enabled: Entitlements.canExport(plus.hasPlus),
            onTap: () => _import(context, ref),
          ),
          if (!plus.hasPlus)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(l.dataPlusOnly, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
            ),
          section(l.purchaseSection),
          ListTile(
            key: const Key('settings-paywall'),
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(plus.hasPlus ? l.plusActive : l.openPaywall),
            onTap: () => context.push(Routes.paywallFrom(PaywallEntry.settings.name)),
          ),
          ListTile(
            key: const Key('settings-restore'),
            leading: const Icon(Icons.restore),
            title: Text(l.restorePurchase),
            subtitle: plus.status == PlusStatus.nothingToRestore
                ? Text(l.paywallNothingToRestore)
                : plus.status == PlusStatus.restored
                    ? Text(l.paywallRestored)
                    : null,
            onTap: () => ref.read(plusProvider.notifier).restore(),
          ),
          section(l.aboutSection),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: Text(l.aboutCustomTitle),
            subtitle: Text(l.aboutCustomBody),
            isThreeLine: true,
          ),
          ListTile(
            key: const Key('metrics'),
            leading: const Icon(Icons.bar_chart_outlined),
            title: Text(l.metricsTitle),
            subtitle: Text(l.metricsBody),
            onTap: () => _shareMetrics(context, ref),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(l.licensesLabel),
            onTap: () => showLicensePage(context: context, applicationName: l.appName),
          ),
        ],
      ),
    );
  }
}
