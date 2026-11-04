import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/kigo.dart';
import '../../render/style.dart';
import '../app_controller.dart';
import '../theme.dart';
import '../widgets/common.dart';
import 'compose_screen.dart';
import 'haiku_detail_screen.dart';
import 'kigo_detail_screen.dart';

Future<void> openCompose(
  BuildContext context, {
  Kigo? theme,
  DateTime? composedOn,
}) => Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ComposeScreen(theme: theme, composedOn: composedOn),
  ),
);

/// ホーム。今日の兼題、連続日数、最近の句。
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppController>();
    final theme = app.todayTheme;
    final season = app.season;
    final palette = SeasonPalette.of(season);
    final term = app.solarTerm;
    final (nextTerm, nextAt) = app.upcomingSeasonChange;
    final streak = app.streak;

    return Scaffold(
      backgroundColor: palette.wash,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'タンザク',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontFamily: TanzakuTheme.haikuFont),
                ),
                const Spacer(),
                Text(
                  '今は${season.label}',
                  key: const Key('season-label'),
                  style: TextStyle(
                    color: palette.accent,
                    fontFamily: TanzakuTheme.haikuFont,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            Text(
              '${term.name}（次は${nextTerm.name}・${nextAt.month}月${nextAt.day}日）',
              style: const TextStyle(color: TanzakuTheme.inkDim, fontSize: 13),
            ),
            const SizedBox(height: 16),
            if (theme != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '今日の兼題',
                        style: TextStyle(color: TanzakuTheme.inkDim),
                      ),
                      const SizedBox(height: 4),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => KigoDetailScreen(kigo: theme),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              theme.word,
                              key: const Key('today-theme'),
                              style: const TextStyle(
                                fontFamily: TanzakuTheme.haikuFont,
                                fontSize: 34,
                                color: TanzakuTheme.ink,
                              ),
                            ),
                            Text(
                              '${theme.reading}　${theme.season.label}・${theme.category}・${theme.period}',
                              style: const TextStyle(
                                color: TanzakuTheme.inkDim,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              theme.description,
                              style: const TextStyle(fontSize: 16, height: 1.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: FilledButton(
                              key: const Key('compose-theme'),
                              onPressed: () =>
                                  openCompose(context, theme: theme),
                              child: const Text('この兼題で詠む'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton(
                              key: const Key('compose-free'),
                              onPressed: () => openCompose(context),
                              child: const Text('自由題で詠む'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Row(
                  children: [
                    Icon(
                      streak.composedToday
                          ? Icons.check_circle
                          : Icons.circle_outlined,
                      color: palette.accent,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '連続 ${streak.days} 日',
                            key: const Key('streak'),
                            style: const TextStyle(fontSize: 18),
                          ),
                          Text(
                            streak.composedToday
                                ? '今日はもう詠みました'
                                : '今日はまだ詠んでいません',
                            style: const TextStyle(color: TanzakuTheme.inkDim),
                          ),
                        ],
                      ),
                    ),
                    if (streak.canRevive)
                      TextButton(
                        key: const Key('revive'),
                        onPressed: () => openCompose(
                          context,
                          theme: app.themeFor(app.yesterday),
                          composedOn: app.yesterday,
                        ),
                        child: const Text('昨日の分を詠む'),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text('最近の句', style: TextStyle(color: TanzakuTheme.inkDim)),
            const SizedBox(height: 8),
            if (app.recent.isEmpty)
              const Text('まだ句がありません。今日の兼題で一句どうぞ。')
            else
              SizedBox(
                height: 120 * 1350 / 1080,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: app.recent.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final h = app.recent[i];
                    return TanzakuThumb(
                      key: Key('recent-${h.id}'),
                      haiku: h,
                      width: 120,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => HaikuDetailScreen(haikuId: h.id),
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
