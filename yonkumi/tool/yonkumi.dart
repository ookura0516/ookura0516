// ヨンクミの作問 CLI。yonkumi/ で `dart run tool/yonkumi.dart <コマンド>`。
//
//   validate             収録した問題をすべて検証する
//   check <file.json>    下書きの1問を、収録済みの問題と合わせて検証する
//   build                検証してから、暗号化したアセットを書き出す
//   candidates <種類>    辞書から軸の候補を出す（reading, kanji, season, ...）
//   axes <語>            語が当てはまる軸をすべて出す（ミスリードを組む用）
//   summary              軸の種類と難易度の内訳
import 'dart:io';

import 'package:yonkumi/core/axis.dart';
import 'package:yonkumi/core/puzzle.dart';
import 'package:yonkumi/core/puzzle_bundle.dart';
import 'package:yonkumi/core/schedule.dart';
import 'package:yonkumi/core/validator.dart';

import 'src/files.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    _usage();
    exit(64);
  }
  final paths = ToolPaths.find();
  final dict = loadDictionary(paths);
  final validator = PuzzleValidator(dict);
  switch (args.first) {
    case 'validate':
      final puzzles = loadPuzzles(paths.puzzles);
      exit(_report(validator.validateAll(puzzles), puzzles.length));
    case 'check':
      if (args.length < 2) {
        _usage();
        exit(64);
      }
      final draft = loadPuzzle(args[1]);
      final all = loadPuzzles(
        paths.puzzles,
      ).where((p) => p.number < draft.number).toList();
      exit(_report(validator.validate(draft, previous: all), 1));
    case 'build':
      final puzzles = loadPuzzles(paths.puzzles);
      final issues = validator.validateAll(puzzles);
      if (_report(issues, puzzles.length) != 0) {
        stderr.writeln('エラーがあるので書き出しません');
        exit(1);
      }
      File(paths.asset).writeAsStringSync(PuzzleBundle.encode(puzzles, kClock));
      final last = kClock.dateOf(puzzles.length);
      stdout.writeln(
        '${paths.asset} に${puzzles.length}問を書き出しました'
        '（第1問 ${kClock.firstDay}〜第${puzzles.length}問 $last）',
      );
    case 'candidates':
      if (args.length < 2) {
        stdout.writeln('種類：${AxisType.values.map((t) => t.name).join(', ')}');
        exit(64);
      }
      final type = AxisType.byName(args[1]);
      final used = _usedAxes(loadPuzzles(paths.puzzles));
      final found = AxisCandidates(dict).generate(type);
      final keys = found.keys.toList()
        ..sort((a, b) => found[b]!.length.compareTo(found[a]!.length));
      for (final a in keys) {
        final n = used[a.key] ?? 0;
        stdout.writeln(
          '${a.key}（${found[a]!.length}語${n > 0 ? '・使用$n回' : ''}）'
          '：${found[a]!.join('・')}',
        );
      }
    case 'axes':
      if (args.length < 2) {
        _usage();
        exit(64);
      }
      for (final w in args.skip(1)) {
        final axes = AxisCandidates(dict).axesOf(w);
        stdout.writeln('$w：${axes.isEmpty ? '（辞書になし）' : axes.join(', ')}');
      }
    case 'summary':
      final puzzles = loadPuzzles(paths.puzzles);
      final byType = <AxisType, List<int>>{};
      for (final p in puzzles) {
        for (final g in p.groups) {
          (byType[g.tag] ??= []).add(g.difficulty);
        }
      }
      stdout.writeln(
        '${puzzles.length}問（ミスリード ${puzzles.fold<int>(0, (s, p) => s + p.decoys.length)}個）',
      );
      for (final t in AxisType.values) {
        final d = byType[t];
        if (d == null) continue;
        final avg = d.reduce((a, b) => a + b) / d.length;
        stdout.writeln(
          '  ${t.label.padRight(8, '　')} ${d.length}組'
          '（平均の難易度 ${avg.toStringAsFixed(1)}）',
        );
      }
    default:
      _usage();
      exit(64);
  }
}

int _report(List<Issue> issues, int count) {
  for (final i in issues) {
    (i.isError ? stderr : stdout).writeln(i);
  }
  final errors = issues.where((i) => i.isError).length;
  final warns = issues.length - errors;
  stdout.writeln('$count問を検証：エラー$errors件・注意$warns件');
  return errors == 0 ? 0 : 1;
}

Map<String, int> _usedAxes(List<Puzzle> puzzles) {
  final out = <String, int>{};
  for (final p in puzzles) {
    for (final g in p.groups) {
      out[g.axis.key] = (out[g.axis.key] ?? 0) + 1;
    }
  }
  return out;
}

void _usage() {
  stdout.writeln('''
使い方：dart run tool/yonkumi.dart <コマンド>
  validate             収録した問題をすべて検証する
  check <file.json>    下書きの1問を検証する
  build                検証してから assets/puzzles.json を書き出す
  candidates <種類>    辞書から軸の候補を出す
  axes <語>...         語が当てはまる軸をすべて出す
  summary              軸の種類と難易度の内訳''');
}
