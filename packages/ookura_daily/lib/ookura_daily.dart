/// 日替わりアプリの共通部品。
///
/// このファイルは Flutter に依存しない部分だけを出す（Dart の CLI からも使える）。
/// 画像・共有・ウィジェットは `ookura_daily_flutter.dart` を読み込む。
library;

export 'src/daily_clock.dart';
export 'src/emoji_grid.dart';
export 'src/streak.dart';
export 'src/widget_snapshot.dart';
