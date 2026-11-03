import 'package:shared_preferences/shared_preferences.dart';

import 'session.dart';

/// 遊びかけの部屋を端末に保存する。サーバーには何も送らない。
class SessionStore {
  SessionStore(this._prefs);

  static const _key = 'hisokagi.session';
  final SharedPreferences _prefs;

  static Future<SessionStore> open() async =>
      SessionStore(await SharedPreferences.getInstance());

  GameSession? load() {
    final raw = _prefs.getString(_key);
    return raw == null ? null : GameSession.decode(raw);
  }

  Future<void> save(GameSession session) =>
      _prefs.setString(_key, session.encode());

  Future<void> clear() => _prefs.remove(_key);
}
