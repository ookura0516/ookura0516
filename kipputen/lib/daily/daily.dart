/// 日替わりアプリの共通部品。
///
/// いずれ packages/ookura_daily に切り出す。そのときはこのフォルダをそのまま移し、
/// `import 'package:ookura_daily/daily.dart';` に置き換える。
/// このフォルダの中からアプリ固有のコード（lib/core など）は読まないこと。
library;

export 'daily_clock.dart';
export 'day.dart';
export 'result_image.dart';
export 'review_policy.dart';
export 'seeded_random.dart';
export 'streak.dart';
export 'widget_payload.dart';
