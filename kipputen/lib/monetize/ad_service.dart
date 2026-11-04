import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// 広告の窓口。出すのは図鑑画面の下のバナーだけ。全画面広告は使わない。
///
/// いまの実装は [PlaceholderAdService]（仮）。本番では google_mobile_ads の BannerAd を返す実装に
/// 差し替える。広告ユニット ID はまだ入れていない。
abstract class AdService {
  Future<void> init();

  /// バナー。出さないときは null。
  Widget? banner();
}

/// 広告を出さない。
class NoAdService implements AdService {
  const NoAdService();
  @override
  Future<void> init() async {}
  @override
  Widget? banner() => null;
}

/// 仮のバナー枠。デバッグビルドでだけ、バナーの大きさ（320×50）の枠を出す。
/// リリースビルドでは何も出さない（ID がないので）。
class PlaceholderAdService implements AdService {
  const PlaceholderAdService({this.visible = kDebugMode});

  final bool visible;

  @override
  Future<void> init() async {}

  @override
  Widget? banner() => visible ? const PlaceholderBanner() : null;
}

class PlaceholderBanner extends StatelessWidget {
  const PlaceholderBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ad-banner'),
      height: 50,
      width: 320,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0x14000000),
        border: Border.all(color: const Color(0x33000000)),
      ),
      child: const Text(
        '広告枠（仮）',
        style: TextStyle(fontSize: 12, color: Color(0x99000000)),
      ),
    );
  }
}
