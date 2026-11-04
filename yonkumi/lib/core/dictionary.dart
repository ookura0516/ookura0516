/// ことわざの穴：[text] の穴に入る語が [answer]。
///
/// 「ことわざの穴」の軸は、穴の位置がそろったことわざの集まり（[theme]）ごとに
/// 決める。どの語もどこかのことわざには入ってしまうので、集まりで絞る。
class Proverb {
  const Proverb(this.theme, this.text, this.answer);

  /// 集まりの名前（例：「AにB」）。軸の value と同じにする。
  final String theme;

  /// ことわざ全体（例：「猫に小判」）。
  final String text;
  final String answer;
}

/// 作問の検証と候補出しに使う辞書。
///
/// アプリには入れない（作問 CLI とテストだけが読む）。中身は tool/dict/ の JSON。
class WordDictionary {
  const WordDictionary({
    this.readings = const {},
    this.kigo = const {},
    this.counters = const {},
    this.origins = const {},
    this.oWords = const {},
    this.proverbs = const [],
    this.hidden = const {},
    this.lists = const {},
  });

  /// 語 → 読み（ひらがな）。
  final Map<String, String> readings;

  /// 季語 → 季節（春・夏・秋・冬・新年）。
  final Map<String, String> kigo;

  /// 語 → 数え方（複数あれば全部）。
  final Map<String, List<String>> counters;

  /// カタカナ語 → 元の言語（例：ドイツ語）。
  final Map<String, String> origins;

  /// 前に「お」を付けると別の言葉になる語（「化け」→「お化け」）。
  /// 丁寧にするだけの「お」（お茶・お金）は入れない。
  final Set<String> oWords;

  /// ことわざ。JSON では `{"集まり": [["ことわざ", "穴の語"], ...]}`。
  final List<Proverb> proverbs;

  /// 隠し語のリスト（例：「県名」→ 都道府県名の読み）。
  final Map<String, List<String>> hidden;

  /// へんな軸のための、名前つきの語のリスト（例：「山手線の駅」）。
  final Map<String, Set<String>> lists;

  /// 集まり [theme] のことわざの穴に入る語。
  Set<String> proverbAnswers(String theme) => {
    for (final p in proverbs)
      if (p.theme == theme) p.answer,
  };

  /// 集まりの名前。
  Set<String> get proverbThemes => {for (final p in proverbs) p.theme};

  factory WordDictionary.fromJson(Map<String, dynamic> j) {
    Map<String, String> strMap(String k) =>
        Map<String, String>.from(j[k] as Map? ?? const {});
    return WordDictionary(
      readings: strMap('readings'),
      kigo: {
        for (final e in (j['kigo'] as Map? ?? const {}).entries)
          for (final w in e.value as List) w as String: e.key as String,
      },
      counters: _invertMulti(j['counters'] as Map? ?? const {}),
      origins: {
        for (final e in (j['origins'] as Map? ?? const {}).entries)
          for (final w in e.value as List) w as String: e.key as String,
      },
      oWords: Set<String>.from(j['o_words'] as List? ?? const []),
      proverbs: [
        for (final e in (j['proverbs'] as Map? ?? const {}).entries)
          for (final p in e.value as List)
            Proverb(e.key as String, (p as List)[0] as String, p[1] as String),
      ],
      hidden: {
        for (final e in (j['hidden'] as Map? ?? const {}).entries)
          e.key as String: List<String>.from(e.value as List),
      },
      lists: {
        for (final e in (j['lists'] as Map? ?? const {}).entries)
          e.key as String: Set<String>.from(e.value as List),
      },
    );
  }

  /// 複数の辞書を1つにまとめる（後のものが優先）。
  WordDictionary merge(WordDictionary o) => WordDictionary(
    readings: {...readings, ...o.readings},
    kigo: {...kigo, ...o.kigo},
    counters: {
      ...counters,
      for (final e in o.counters.entries)
        e.key: {...?counters[e.key], ...e.value}.toList(),
    },
    origins: {...origins, ...o.origins},
    oWords: {...oWords, ...o.oWords},
    proverbs: [...proverbs, ...o.proverbs],
    hidden: {...hidden, ...o.hidden},
    lists: {
      ...lists,
      for (final e in o.lists.entries) e.key: {...?lists[e.key], ...e.value},
    },
  );
}

/// 「数え方 → 語の並び」を「語 → 数え方の並び」にする。
Map<String, List<String>> _invertMulti(Map raw) {
  final all = <String, List<String>>{};
  for (final e in raw.entries) {
    for (final w in e.value as List) {
      (all[w as String] ??= []).add(e.key as String);
    }
  }
  return all;
}
