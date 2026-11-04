/// 季節と二十四節気。
///
/// 俳句の季節は暦（二十四節気）で切り替わる。立春から春、立夏から夏、立秋から秋、
/// 立冬から冬。新年（1月1日〜7日、松の内）は冬の中に別の季節として置く。
library;

enum Season {
  newYear('新年'),
  spring('春'),
  summer('夏'),
  autumn('秋'),
  winter('冬');

  const Season(this.label);
  final String label;

  static Season fromLabel(String s) => Season.values.firstWhere(
    (e) => e.label == s,
    orElse: () => throw FormatException('季節が不明です: $s'),
  );
}

/// 二十四節気の1つ。[month] 月 [day] 日（日本時間のおおよそ）に始まる。
class SolarTerm {
  const SolarTerm(this.name, this.month, this.day);
  final String name;
  final int month;
  final int day;

  DateTime dateIn(int year) => DateTime(year, month, day);

  @override
  String toString() => '$name($month/$day)';
}

/// 21世紀の簡易計算式の定数（月, 名前, C）。
/// 日 = floor(Y * 0.2422 + C) - floor(L / 4)。Y は西暦の下2桁、L は1・2月の節気では Y-1、それ以外は Y。
/// 2000〜2099年でおおむね ±1日。俳句の季節の切り替えには十分。
const _terms = <(int, String, double)>[
  (1, '小寒', 5.4055),
  (1, '大寒', 20.12),
  (2, '立春', 3.87),
  (2, '雨水', 18.73),
  (3, '啓蟄', 5.63),
  (3, '春分', 20.646),
  (4, '清明', 4.81),
  (4, '穀雨', 20.1),
  (5, '立夏', 5.52),
  (5, '小満', 21.04),
  (6, '芒種', 5.678),
  (6, '夏至', 21.37),
  (7, '小暑', 7.108),
  (7, '大暑', 22.83),
  (8, '立秋', 7.5),
  (8, '処暑', 23.13),
  (9, '白露', 7.646),
  (9, '秋分', 23.042),
  (10, '寒露', 8.318),
  (10, '霜降', 23.438),
  (11, '立冬', 7.438),
  (11, '小雪', 22.36),
  (12, '大雪', 7.18),
  (12, '冬至', 21.94),
];

/// [year] 年の二十四節気（小寒から冬至まで、日付順）。
List<SolarTerm> solarTermsOf(int year) {
  final y = year % 100;
  return [
    for (final (month, name, c) in _terms)
      SolarTerm(
        name,
        month,
        (y * 0.2422 + c).floor() - ((month <= 2 ? y - 1 : y) / 4).floor(),
      ),
  ];
}

/// [date] の時点で始まっている二十四節気。
SolarTerm currentSolarTerm(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  final terms = solarTermsOf(d.year);
  SolarTerm? found;
  for (final t in terms) {
    if (!t.dateIn(d.year).isAfter(d)) found = t;
  }
  // 1月の小寒より前は、前の年の冬至。
  return found ?? solarTermsOf(d.year - 1).last;
}

/// [date] の「今の季節」。
Season seasonOf(DateTime date) {
  if (date.month == 1 && date.day <= 7) return Season.newYear;
  final terms = {for (final t in solarTermsOf(date.year)) t.name: t};
  final d = DateTime(date.year, date.month, date.day);
  bool reached(String name) => !terms[name]!.dateIn(date.year).isAfter(d);
  if (reached('立冬')) return Season.winter;
  if (reached('立秋')) return Season.autumn;
  if (reached('立夏')) return Season.summer;
  if (reached('立春')) return Season.spring;
  return Season.winter;
}

/// [date] から見て次に季節が変わる節気（立春・立夏・立秋・立冬）とその日付。
(SolarTerm, DateTime) nextSeasonChange(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  for (final year in [d.year, d.year + 1]) {
    for (final t in solarTermsOf(year)) {
      if (!t.name.startsWith('立')) continue;
      final at = t.dateIn(year);
      if (at.isAfter(d)) return (t, at);
    }
  }
  throw StateError('unreachable');
}
