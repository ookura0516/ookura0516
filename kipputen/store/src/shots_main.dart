// ストア用のスクリーンショットを撮るための入口（Web で動かす）。手順は store/README.md。
//
// 日付は 2026年11月4日（今日の切符 4027）に固定し、図鑑と連続日数に見本の記録を入れる。
//   （なし）            今日の切符（まだ解いていない）
//   ?v=solved           今日の切符を1通り解いたところ
//   ?v=back&n=1225      切符の裏（全解・完）
//   ?v=share&n=1225     共有画像（全解の日の3枚の扇、式は★★★）
//   ?v=collection       硬券図鑑
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter/services.dart';
import 'package:kipputen/core/expr.dart';
import 'package:kipputen/core/puzzle_picker.dart';
import 'package:kipputen/core/solution_book.dart';
import 'package:kipputen/daily/daily.dart';
import 'package:kipputen/data/records.dart';
import 'package:kipputen/monetize/ad_service.dart';
import 'package:kipputen/monetize/purchase_service.dart';
import 'package:kipputen/ui/app_controller.dart';
import 'package:kipputen/ui/screens/home_shell.dart';
import 'package:kipputen/ui/screens/share_screen.dart';
import 'package:kipputen/ui/screens/solutions_screen.dart';
import 'package:kipputen/ui/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

final today = Day(2026, 11, 4);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SemanticsBinding.instance.ensureSemantics();
  final prefs = await SharedPreferences.getInstance();
  await prefs.clear();
  final book = SolutionBook.fromJson(
    await rootBundle.loadString(SolutionBook.assetPath),
  );
  final picker = PuzzlePicker(
    book,
    anniversaries: AnniversaryTable.fromJson(
      await rootBundle.loadString(AnniversaryTable.assetPath),
    ),
  );
  final records = Records(prefs);
  final app = AppController(
    book: book,
    picker: picker,
    records: records,
    purchases: PlaceholderPurchaseService(prefs),
    ads: const NoAdService(),
    clock: DailyClock.fixed(
      DailyClock.startOf(today).add(const Duration(hours: 12)),
    ),
  );

  // 見本の記録：12日続けて解いた。図鑑はおよそ7枚に1枚。
  for (var i = 1; i <= 12; i++) {
    final d = today.addDays(-i);
    final p = picker.forDay(d);
    records.plays[d.key] = PlayLog(
      day: d.key,
      number: p.number,
      seconds: 60 + i * 17,
      cleared: true,
    );
    await app.submit(
      p.number,
      parse(tokenize(book.solutionsFor(p.number).first.display)),
    );
  }
  for (var i = 0; i < book.solvableNumbers.length; i += 7) {
    final n = book.solvableNumbers[i];
    await app.submit(n, parse(tokenize(book.solutionsFor(n).first.display)));
  }
  for (final s in book.solutionsFor('1225').take(solutionCap)) {
    await app.submit('1225', parse(tokenize(s.display)));
  }
  await records.saveSolved();
  await records.savePlays();

  final q = Uri.base.queryParameters;
  final n = q['n'] ?? '1225';
  Widget home = const HomeShell();
  switch (q['v']) {
    case 'solved':
      await app.submit(
        '4027',
        parse(tokenize('7 × 2 − 4 + 0')),
        daily: true,
        seconds: 95,
      );
    case 'back':
      home = SolutionsScreen(number: n);
    case 'share':
      home = ShareScreen(
        number: n,
        day: today,
        serial: picker.forDay(today).serial,
      );
    case 'collection':
      home = const HomeShell(initialTab: 1);
  }
  runApp(
    ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: KipTheme.light,
        home: home,
      ),
    ),
  );
}
