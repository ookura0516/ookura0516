import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/local_date.dart';
import '../core/rules.dart';
import '../l10n/app_localizations.dart';
import '../model/models.dart';
import '../services/share_image.dart';
import '../state/actions.dart';
import '../state/providers.dart';

enum ShareMoment { open, milestone, complete }

String formatDate(LocalDate d) =>
    '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')}';

/// 共有画像を作って共有シートを出す。ストアリンクは入れない。
Future<void> shareDaruma(
  BuildContext context,
  WidgetRef ref,
  DarumaDetail detail, {
  required ShareMoment moment,
}) async {
  final l = L10n.of(context);
  final today = ref.read(todayProvider);
  final days = Rules.daysSinceOpened(detail.daruma.createdOn, today);
  final look = detail.lookOn(today).copyWith(fallen: false);
  final completedOn = detail.daruma.completedOn;
  final strings = ShareCardStrings(
    appName: l.appName,
    progress: l.shareProgress(days, detail.riseCount),
    completed: completedOn == null ? null : l.shareCompletedOn(formatDate(completedOn)),
  );
  final text = switch (moment) {
    ShareMoment.open => l.shareTextOpen(detail.daruma.name),
    ShareMoment.milestone => l.shareTextMilestone(days, detail.riseCount),
    ShareMoment.complete => l.shareTextComplete,
  };
  final png = await renderShareCard(look, strings);
  final ok = await ref.read(shareProvider).shareImage(
        png,
        fileName: 'nanakorobi_${detail.daruma.id}_${today.toIso()}.png',
        text: text,
      );
  if (ok) {
    await ref.read(actionsProvider).countShare();
  } else if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.shareUnavailable)));
  }
}

Future<void> showWidgetHint(BuildContext context) {
  final l = L10n.of(context);
  final isIos = Theme.of(context).platform == TargetPlatform.iOS;
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l.widgetHintTitle),
      content: Text(isIos ? l.widgetHintIos : l.widgetHintAndroid),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.ok)),
      ],
    ),
  );
}
