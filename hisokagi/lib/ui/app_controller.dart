import 'dart:math';

import 'package:flutter/foundation.dart';

import '../core/room_code.dart';
import '../game/services.dart';
import '../game/session.dart';
import '../monetize/ad_service.dart';
import '../monetize/purchase_service.dart';
import '../scenario/model.dart';
import '../scenario/registry.dart';

enum HintUnlock {
  /// 開いてよい。
  granted,

  /// 広告を途中で閉じた。
  skipped,
}

/// アプリ全体の状態。遊んでいる部屋を1つだけ持ち、変わるたびに端末に保存する。
class AppController extends ChangeNotifier {
  AppController({
    required this.store,
    required this.purchases,
    this.ads = const NoAdService(),
  }) {
    _session = store.load();
    _session?.addListener(_save);
    purchases.addListener(notifyListeners);
  }

  final SessionStore store;
  final PurchaseService purchases;
  final AdService ads;
  GameSession? _session;

  GameSession? get session => _session;

  /// 「つづきから」を出すか。
  bool get canResume => _session != null && !_session!.isCleared;

  // ------------------------------------------------------------ 課金と広告

  bool get hasPass => purchases.hasPass;

  /// 有料シナリオがあるか。パスの説明にだけ使う。
  bool get hasPaidScenarios => scenarios.any((s) => !s.free);

  /// 起動後に呼ぶ。画面の表示は待たせない。
  Future<void> initMonetization() async {
    await purchases.init();
    if (!hasPass) await ads.init();
  }

  /// 部屋をつくれるか。有料シナリオは、部屋をつくる人だけがパスを持っていればよい。
  /// 部屋にはいる人と、有料シナリオの部屋のヒントは無料。
  bool canCreate(ScenarioDef scenario) => scenario.free || hasPass;

  /// ヒント2と答えに広告が要るか。
  bool hintNeedsAd(GameSession s, int nextLevel) =>
      nextLevel >= 2 && s.scenario.free && !hasPass;

  /// ヒントを1段開けてよいか。広告を出せない（通信がない等）ときは、遊びを止めないよう開く。
  Future<HintUnlock> unlockHint(GameSession s, int nextLevel) async {
    if (!hintNeedsAd(s, nextLevel)) return HintUnlock.granted;
    final outcome = await ads.showRewarded();
    return outcome == RewardOutcome.skipped
        ? HintUnlock.skipped
        : HintUnlock.granted;
  }

  /// クリア画面からタイトルに戻るとき。全画面広告はここでだけ出す。
  Future<void> afterClear() async {
    if (!hasPass) await ads.showInterstitial();
  }

  // ------------------------------------------------------------ 部屋

  /// 新しい部屋の番号を作る。シードは毎回ランダム。
  static RoomCode newRoomCode(ScenarioDef scenario, {Random? random}) {
    final r = random ?? Random();
    return RoomCode(scenario: scenario.id, players: 2, seed: r.nextInt(1000));
  }

  GameSession start({
    required RoomCode code,
    required PlayMode mode,
    required Set<Role> roles,
  }) {
    _session?.removeListener(_save);
    final s = GameSession(code: code, mode: mode, roles: roles);
    _session = s..addListener(_save);
    _save();
    notifyListeners();
    return s;
  }

  Future<void> discard() async {
    _session?.removeListener(_save);
    _session = null;
    await store.clear();
    notifyListeners();
  }

  void _save() {
    final s = _session;
    if (s != null) store.save(s);
  }

  @override
  void dispose() {
    purchases.removeListener(notifyListeners);
    super.dispose();
  }
}
