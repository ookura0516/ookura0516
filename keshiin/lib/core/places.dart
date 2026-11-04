import 'dart:math' as math;

/// 市区町村の代表座標。
class Municipality {
  const Municipality({
    required this.code,
    required this.pref,
    required this.city,
    required this.lat,
    required this.lng,
  });

  final String code;
  final String pref;

  /// 「札幌市中央区」「府中市」など。
  final String city;
  final double lat;
  final double lng;

  @override
  String toString() => '$pref$city';
}

/// 2点間の大円距離（km）。
double haversineKm(double lat1, double lng1, double lat2, double lng2) {
  const r = 6371.0;
  double rad(double d) => d * math.pi / 180;
  final dLat = rad(lat2 - lat1);
  final dLng = rad(lng2 - lng1);
  final a =
      math.pow(math.sin(dLat / 2), 2) +
      math.cos(rad(lat1)) *
          math.cos(rad(lat2)) *
          math.pow(math.sin(dLng / 2), 2);
  return 2 * r * math.asin(math.min(1, math.sqrt(a)));
}

/// 端末内の表から、最も近い市区町村を引く。通信しない。
///
/// 約1,900件なので、緯度経度を1度の格子に分けて近くの格子だけを調べる。
class MunicipalityIndex {
  MunicipalityIndex(this.items) {
    for (final m in items) {
      _grid.putIfAbsent(_key(m.lat.floor(), m.lng.floor()), () => []).add(m);
    }
  }

  /// assets/data/municipalities.csv（code,pref,city,lat,lng）を読む。
  factory MunicipalityIndex.parseCsv(String csv) {
    final out = <Municipality>[];
    for (final line in csv.split('\n').skip(1)) {
      final t = line.trim();
      if (t.isEmpty) continue;
      final f = t.split(',');
      if (f.length < 5) continue;
      out.add(
        Municipality(
          code: f[0],
          pref: f[1],
          city: f[2],
          lat: double.parse(f[3]),
          lng: double.parse(f[4]),
        ),
      );
    }
    return MunicipalityIndex(out);
  }

  final List<Municipality> items;
  final Map<int, List<Municipality>> _grid = {};

  static int _key(int lat, int lng) => (lat + 90) * 1000 + (lng + 180);

  /// 日本の陸地から [maxKm] 以上離れていたら「国内ではない」とみなす。
  /// 離島の代表点は島の中にあるので、40km あれば国内の写真はほぼ拾える。
  static const double defaultMaxKm = 40;

  /// 最も近い市区町村と距離。[maxKm] より遠ければ null（海外または海の上）。
  ({Municipality place, double km})? nearest(
    double lat,
    double lng, {
    double maxKm = defaultMaxKm,
  }) {
    if (lat.isNaN || lng.isNaN) return null;
    Municipality? best;
    var bestKm = double.infinity;
    // 1度はおよそ 90〜111km。周り1マスまで見れば 40km の範囲は漏れない。
    final la = lat.floor();
    final ln = lng.floor();
    for (var dy = -1; dy <= 1; dy++) {
      for (var dx = -1; dx <= 1; dx++) {
        final cell = _grid[_key(la + dy, ln + dx)];
        if (cell == null) continue;
        for (final m in cell) {
          final d = haversineKm(lat, lng, m.lat, m.lng);
          if (d < bestKm) {
            bestKm = d;
            best = m;
          }
        }
      }
    }
    if (best == null || bestKm > maxKm) return null;
    return (place: best, km: bestKm);
  }

  /// 格子を使わず全件を調べる（テストで [nearest] と突き合わせる用）。
  ({Municipality place, double km}) nearestBruteForce(double lat, double lng) {
    Municipality? best;
    var bestKm = double.infinity;
    for (final m in items) {
      final d = haversineKm(lat, lng, m.lat, m.lng);
      if (d < bestKm) {
        bestKm = d;
        best = m;
      }
    }
    return (place: best!, km: bestKm);
  }
}

/// 消印に入れる場所の表記。市区町村まで（都道府県と町名は入れない）。
String postmarkPlaceName(Municipality m) => m.city;
