import 'package:flutter_test/flutter_test.dart';
import 'package:keshiin/core/places.dart';
import 'package:keshiin/core/rng.dart';

import 'fakes.dart';

void main() {
  final idx = loadMunicipalities();

  test('全国の市区町村（政令市の区を含む）約1,900件を内蔵している', () {
    expect(idx.items.length, inInclusiveRange(1850, 1950));
    expect(idx.items.map((m) => m.code).toSet().length, idx.items.length);
    expect(idx.items.map((m) => m.pref).toSet().length, 47);
  });

  test('代表点の上で引くと、その市区町村が返る', () {
    for (final m in idx.items) {
      final hit = idx.nearest(m.lat, m.lng)!;
      expect(hit.km, closeTo(0, 1e-6), reason: '$m');
    }
  });

  test('よく知られた場所', () {
    expect(idx.nearest(26.2124, 127.6809)!.place.city, '那覇市');
    expect(idx.nearest(34.9858, 135.7588)!.place.city, startsWith('京都市'));
    expect(idx.nearest(35.3192, 139.5467)!.place.city, '鎌倉市');
    expect(idx.nearest(43.0621, 141.3544)!.place.city, startsWith('札幌市'));
    expect(idx.nearest(24.3448, 124.1572)!.place.pref, '沖縄県'); // 石垣島
  });

  test('海外や海の真ん中は「国内ではない」（null）', () {
    expect(idx.nearest(48.8566, 2.3522), isNull); // パリ
    expect(idx.nearest(37.5665, 126.9780), isNull); // ソウル
    expect(idx.nearest(30.0, 140.0), isNull); // 太平洋
    expect(idx.nearest(0, 0), isNull);
  });

  test('格子を使った検索と全件の検索が一致する', () {
    final r = SeededRng(42);
    var compared = 0;
    for (var i = 0; i < 3000; i++) {
      final lat = r.range(24, 46);
      final lng = r.range(122, 146);
      final fast = idx.nearest(lat, lng);
      final slow = idx.nearestBruteForce(lat, lng);
      if (slow.km <= MunicipalityIndex.defaultMaxKm) {
        expect(fast, isNotNull, reason: '$lat,$lng');
        expect(fast!.place.code, slow.place.code, reason: '$lat,$lng');
        compared++;
      } else {
        expect(fast, isNull);
      }
    }
    expect(compared, greaterThan(300));
  });

  test('距離の計算', () {
    // 東京駅〜大阪駅 はおよそ 400km
    expect(haversineKm(35.6812, 139.7671, 34.7025, 135.4959), closeTo(403, 5));
  });

  test('場所の表記は市区町村まで', () {
    final m = idx.items.firstWhere((m) => m.city == '鎌倉市');
    expect(postmarkPlaceName(m), '鎌倉市');
  });
}
