import 'dictionary.dart';
import 'kana.dart';

/// 仕分けの軸の種類（設計書の「日本語ならではの一ひねり」）。
enum AxisType {
  reading('同じ読み'),
  kanji('同じ漢字'),
  season('季語の季節'),
  hidden('隠れた県名'),
  proverb('ことわざの穴'),
  counter('数え方'),
  origin('カタカナ語の元'),
  oPrefix('「お」が付く'),
  palindrome('回文'),
  list('へんな軸'),
  manual('そのほか');

  const AxisType(this.label);

  /// 成績の軸別集計に出す名前。
  final String label;

  static AxisType byName(String name) => AxisType.values.firstWhere(
    (t) => t.name == name,
    orElse: () => throw FormatException('知らない軸の種類です: $name'),
  );
}

/// 軸の中身。[type] と [value] の組で、どの語が当てはまるかを決める。
///
/// | type | value | 当てはまる語 |
/// | --- | --- | --- |
/// | reading | はし | 読みが value と同じ |
/// | kanji | 金 | 表記に value を含む |
/// | season | 冬 | 辞書の季語で、季節が value |
/// | hidden | 県名 | 読みに、辞書の隠し語リスト value のどれかを含む |
/// | proverb | 集まりの名前 | 辞書のその集まりのことわざの穴に入る語 |
/// | counter | 棹 | 辞書の数え方に value がある |
/// | origin | ドイツ語 | 辞書のカタカナ語の元が value |
/// | oPrefix | （空でよい） | 辞書の「前にお」の語 |
/// | palindrome | （空でよい） | 読みが3文字以上の回文 |
/// | list | 名前 | 辞書のリスト value に入っている |
/// | manual | 自由 | 自動では確かめない |
class AxisSpec {
  const AxisSpec(this.type, [this.value = '']);

  final AxisType type;
  final String value;

  /// 過去問との重複を見るときの鍵。
  String get key => '${type.name}:$value';

  factory AxisSpec.fromJson(Map<String, dynamic> j) => AxisSpec(
    AxisType.byName(j['type'] as String),
    j['value'] as String? ?? '',
  );

  Map<String, dynamic> toJson() => {
    'type': type.name,
    if (value.isNotEmpty) 'value': value,
  };

  /// 自動で当てはまりを確かめられるか。
  bool get checkable => type != AxisType.manual;

  /// [word]（読みは [reading]）がこの軸に当てはまるか。確かめられない軸は null。
  bool? matches(String word, String reading, WordDictionary dict) {
    final yomi = toHiragana(reading);
    switch (type) {
      case AxisType.reading:
        return yomi == toHiragana(value);
      case AxisType.kanji:
        return word.contains(value);
      case AxisType.season:
        return dict.kigo[word] == value;
      case AxisType.hidden:
        final list = dict.hidden[value];
        if (list == null) return null;
        return list.any((h) => yomi.contains(h));
      case AxisType.proverb:
        return dict.proverbAnswers(value).contains(word);
      case AxisType.counter:
        return dict.counters[word]?.contains(value) ?? false;
      case AxisType.origin:
        return dict.origins[word] == value;
      case AxisType.oPrefix:
        return dict.oWords.contains(word);
      case AxisType.palindrome:
        final r = yomi.runes.toList();
        return r.length >= 3 &&
            String.fromCharCodes(r.reversed) == String.fromCharCodes(r);
      case AxisType.list:
        final list = dict.lists[value];
        if (list == null) return null;
        return list.contains(word);
      case AxisType.manual:
        return null;
    }
  }

  @override
  bool operator ==(Object other) =>
      other is AxisSpec && other.type == type && other.value == value;

  @override
  int get hashCode => Object.hash(type, value);

  @override
  String toString() => key;
}
