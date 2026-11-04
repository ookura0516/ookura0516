import 'package:flutter/material.dart';

/// 広告の窓口。
///
/// 出すのは結果画面の下のバナー1枚だけ（設計書：問題画面・全画面広告・
/// リワード広告は使わない）。本番の AdMob に替えるときは、この型を実装した
/// クラスを作って main.dart で差し替える（手順は README）。
abstract class AdService {
  Future<void> init();

  /// 結果画面の下に出すバナー。出せないときは null。
  Widget? banner(BuildContext context);
}

/// 広告を出さない（テスト用）。
class NoAdService implements AdService {
  const NoAdService();

  @override
  Future<void> init() async {}

  @override
  Widget? banner(BuildContext context) => null;
}

/// 仮の広告。広告 ID もネットワークも使わず、バナーの場所と大きさだけを示す。
class PlaceholderAdService implements AdService {
  const PlaceholderAdService();

  @override
  Future<void> init() async {}

  @override
  Widget? banner(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      key: const Key('ad-banner'),
      height: 50,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Text(
        '広告（仮）',
        style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 12),
      ),
    );
  }
}
