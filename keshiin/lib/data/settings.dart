import 'package:shared_preferences/shared_preferences.dart';

import '../core/frames.dart';
import '../core/reminder.dart';

/// 端末に保存する設定。
class AppSettings {
  AppSettings(this._prefs);

  final SharedPreferences _prefs;

  static const _kTitle = 'keshiin.sheetTitle';
  static const _kFont = 'keshiin.postmarkFont';
  static const _kFrame = 'keshiin.lastFrame';
  static const _kShape = 'keshiin.lastShape';
  static const _kReviews = 'keshiin.reviewPrompts';
  static const _kSaved = 'keshiin.savedCount';
  static const _kNoticeSeen = 'keshiin.noticeSeen';
  static const _kReminderOn = 'keshiin.reminder.on';
  static const _kReminderTime = 'keshiin.reminder.time';

  /// リマインダー。初期はオフ（設計書）。
  bool get reminderOn => _prefs.getBool(_kReminderOn) ?? false;
  Future<void> setReminderOn(bool v) => _prefs.setBool(_kReminderOn, v);

  ReminderTime get reminderTime =>
      ReminderTime.parse(_prefs.getString(_kReminderTime));
  Future<void> setReminderTime(ReminderTime t) =>
      _prefs.setString(_kReminderTime, t.encode());

  /// 新しい月のシートに付ける名前（「2026 日常」など）。
  String get sheetTitle => _prefs.getString(_kTitle) ?? '';
  Future<void> setSheetTitle(String v) => _prefs.setString(_kTitle, v);

  String get postmarkFontId =>
      _prefs.getString(_kFont) ?? postmarkFonts.first.id;
  Future<void> setPostmarkFontId(String v) => _prefs.setString(_kFont, v);

  String get lastFrameId => _prefs.getString(_kFrame) ?? defaultFrameId;
  Future<void> setLastFrameId(String v) => _prefs.setString(_kFrame, v);

  StampShape get lastShape => StampShape.parse(_prefs.getString(_kShape) ?? '');
  Future<void> setLastShape(StampShape v) => _prefs.setString(_kShape, v.name);

  /// これまでに保存した切手の数（評価依頼の判定に使う）。
  int get savedCount => _prefs.getInt(_kSaved) ?? 0;
  Future<void> setSavedCount(int v) => _prefs.setInt(_kSaved, v);

  bool get noticeSeen => _prefs.getBool(_kNoticeSeen) ?? false;
  Future<void> setNoticeSeen() => _prefs.setBool(_kNoticeSeen, true);

  /// 評価依頼を出した日時（ミリ秒）。365日に3回までの判定に使う。
  List<DateTime> get reviewPrompts => [
    for (final s in _prefs.getStringList(_kReviews) ?? const <String>[])
      DateTime.fromMillisecondsSinceEpoch(int.parse(s)),
  ];
  Future<void> addReviewPrompt(DateTime at) => _prefs.setStringList(_kReviews, [
    ...(_prefs.getStringList(_kReviews) ?? const <String>[]),
    '${at.millisecondsSinceEpoch}',
  ]);
}

/// 評価依頼を出してよいか。365日に3回まで（共通の技術方針）。
bool canAskReview(List<DateTime> past, DateTime now) {
  final recent = past.where((t) => now.difference(t).inDays < 365).length;
  return recent < 3;
}
