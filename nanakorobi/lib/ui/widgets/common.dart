import 'package:flutter/material.dart';

import '../../core/daruma_colors.dart';
import '../../core/entitlements.dart';
import '../../l10n/generated/app_localizations.dart';
import '../theme.dart';

/// 筆の数・起き上がり・残り日数のタイル。
class StatTile extends StatelessWidget {
  const StatTile({super.key, required this.label, required this.value, this.emphasis = false});

  final String label;
  final String value;
  final bool emphasis;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: (emphasis ? t.headlineSmall : t.titleLarge)?.copyWith(
            fontWeight: FontWeight.bold,
            color: emphasis ? NanakorobiTheme.vermilion : NanakorobiTheme.ink,
          ),
        ),
        Text(label, style: t.bodySmall?.copyWith(color: NanakorobiTheme.inkDim)),
      ],
    );
  }
}

String colorName(AppLocalizations l, int id) => switch (id) {
      0 => l.colorName0,
      1 => l.colorName1,
      2 => l.colorName2,
      3 => l.colorName3,
      4 => l.colorName4,
      5 => l.colorName5,
      6 => l.colorName6,
      7 => l.colorName7,
      8 => l.colorName8,
      9 => l.colorName9,
      10 => l.colorName10,
      _ => l.colorName11,
    };

String colorNote(AppLocalizations l, int id) => switch (id) {
      0 => l.colorNote0,
      1 => l.colorNote1,
      2 => l.colorNote2,
      3 => l.colorNote3,
      4 => l.colorNote4,
      5 => l.colorNote5,
      6 => l.colorNote6,
      7 => l.colorNote7,
      8 => l.colorNote8,
      9 => l.colorNote9,
      10 => l.colorNote10,
      _ => l.colorNote11,
    };

/// 12色の選択。無料は赤・白・黒、残りはプラス。
class ColorPicker extends StatelessWidget {
  const ColorPicker({
    super.key,
    required this.selected,
    required this.hasPlus,
    required this.onSelect,
    required this.onLocked,
  });

  final int selected;
  final bool hasPlus;
  final void Function(int id) onSelect;
  final VoidCallback onLocked;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        for (final c in DarumaColor.values)
          _ColorDot(
            color: c,
            name: colorName(l, c.id),
            selected: c.id == selected,
            locked: !Entitlements.colorAllowed(colorId: c.id, hasPlus: hasPlus),
            onTap: () => Entitlements.colorAllowed(colorId: c.id, hasPlus: hasPlus) ? onSelect(c.id) : onLocked(),
          ),
      ],
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.name,
    required this.selected,
    required this.locked,
    required this.onTap,
  });

  final DarumaColor color;
  final String name;
  final bool selected;
  final bool locked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: locked ? '$name (${AppLocalizations.of(context).plusName})' : name,
      child: InkWell(
        key: ValueKey('color-${color.id}'),
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(color.body),
            border: Border.all(
              color: selected ? NanakorobiTheme.ink : Color(color.shade).withValues(alpha: 0.6),
              width: selected ? 3 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: locked
              ? Icon(Icons.lock_outline, size: 18, color: color.isLight ? NanakorobiTheme.ink : Colors.white)
              : null,
        ),
      ),
    );
  }
}

/// 画面の下に置く主ボタン。
class BottomAction extends StatelessWidget {
  const BottomAction({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 12), child: child),
      );
}
