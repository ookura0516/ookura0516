import 'package:shared_preferences/shared_preferences.dart';

/// 端末に残す設定。
class Settings {
  Settings(this._prefs);

  final SharedPreferences _prefs;

  static const _tutorial = 'yonkumi.tutorial_done';
  static const _colorNames = 'yonkumi.color_names';
  static const _notify = 'yonkumi.notify';
  static const _notifyHour = 'yonkumi.notify_hour';

  /// 初回のチュートリアル問を終えたか。
  bool get tutorialDone => _prefs.getBool(_tutorial) ?? false;
  Future<void> setTutorialDone() => _prefs.setBool(_tutorial, true);

  /// 帯とグリッドに色名（柿・紅・栗・墨）を出す（色覚対応）。
  bool get colorNames => _prefs.getBool(_colorNames) ?? false;
  Future<void> setColorNames(bool v) => _prefs.setBool(_colorNames, v);

  /// 1日1回の通知。初期はオフ。
  bool get notify => _prefs.getBool(_notify) ?? false;
  Future<void> setNotify(bool v) => _prefs.setBool(_notify, v);

  /// 通知の時刻（日本時間の時）。
  int get notifyHour => _prefs.getInt(_notifyHour) ?? 8;
  Future<void> setNotifyHour(int h) => _prefs.setInt(_notifyHour, h);
}
