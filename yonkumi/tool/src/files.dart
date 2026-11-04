import 'dart:convert';
import 'dart:io';

import 'package:yonkumi/core/dictionary.dart';
import 'package:yonkumi/core/puzzle.dart';

/// 作問 CLI とテストが読むファイルの場所（yonkumi/ からの相対パス）。
class ToolPaths {
  const ToolPaths(this.root);

  /// yonkumi/ の場所。
  final String root;

  String get dictDir => '$root/tool/dict';
  String get puzzles => '$root/tool/puzzles/puzzles.json';
  String get asset => '$root/assets/puzzles.json';

  /// いまの作業場所から yonkumi/ を探す。
  static ToolPaths find() {
    var dir = Directory.current;
    for (var i = 0; i < 4; i++) {
      if (File('${dir.path}/tool/puzzles/puzzles.json').existsSync()) {
        return ToolPaths(dir.path);
      }
      if (File('${dir.path}/yonkumi/tool/puzzles/puzzles.json').existsSync()) {
        return ToolPaths('${dir.path}/yonkumi');
      }
      dir = dir.parent;
    }
    throw StateError('yonkumi/tool/puzzles/puzzles.json が見つかりません');
  }
}

/// tool/dict/ の JSON をすべて読み、1つの辞書にまとめる。
WordDictionary loadDictionary(ToolPaths paths) {
  final files =
      Directory(paths.dictDir)
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList()
        ..sort((a, b) => a.path.compareTo(b.path));
  var dict = const WordDictionary();
  for (final f in files) {
    final j = jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    dict = dict.merge(WordDictionary.fromJson(j));
  }
  return dict;
}

List<Puzzle> loadPuzzles(String path) {
  final j = jsonDecode(File(path).readAsStringSync()) as List;
  return [for (final p in j) Puzzle.fromJson(p as Map<String, dynamic>)];
}

Puzzle loadPuzzle(String path) => Puzzle.fromJson(
  jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>,
);
