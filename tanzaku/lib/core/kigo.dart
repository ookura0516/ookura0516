import 'dart:convert';

import 'kana.dart';
import 'month_day.dart';
import 'season.dart';

/// 歳時記の分類。
const kigoCategories = ['時候', '天文', '地理', '生活', '行事', '動物', '植物'];

class KigoExample {
  const KigoExample(this.text, this.author);
  final String text;
  final String author;

  Map<String, Object?> toJson() => {'text': text, 'author': author};
  factory KigoExample.fromJson(Map<String, Object?> j) =>
      KigoExample(j['text'] as String, j['author'] as String);
}

/// 季語1語。
class Kigo {
  const Kigo({
    required this.id,
    required this.word,
    required this.reading,
    required this.season,
    required this.category,
    required this.period,
    required this.start,
    required this.end,
    required this.description,
    this.aliases = const [],
    this.examples = const [],
  });

  final int id;
  final String word;

  /// ひらがなの読み。
  final String reading;
  final Season season;
  final String category;

  /// 「初冬」「三春」など。
  final String period;

  /// 季語の時期（日替わり兼題に使う）。年をまたぐことがある。
  final MonthDay start;
  final MonthDay end;
  final String description;

  /// 別表記（旧仮名、かな書き、傍題）。
  final List<String> aliases;
  final List<KigoExample> examples;

  bool inSeasonOn(DateTime date) => MonthDay.of(date).within(start, end);

  factory Kigo.fromJson(Map<String, Object?> j) => Kigo(
    id: j['id'] as int,
    word: j['word'] as String,
    reading: j['reading'] as String,
    season: Season.fromLabel(j['season'] as String),
    category: j['category'] as String,
    period: j['period'] as String,
    start: MonthDay.parse(j['start'] as String),
    end: MonthDay.parse(j['end'] as String),
    description: j['description'] as String,
    aliases: [for (final a in (j['aliases'] as List? ?? const [])) a as String],
    examples: [
      for (final e in (j['examples'] as List? ?? const []))
        KigoExample.fromJson((e as Map).cast<String, Object?>()),
    ],
  );

  Map<String, Object?> toJson() => {
    'id': id,
    'word': word,
    'reading': reading,
    'season': season.label,
    'category': category,
    'period': period,
    'start': start.toString(),
    'end': end.toString(),
    'description': description,
    'aliases': aliases,
    'examples': [for (final e in examples) e.toJson()],
  };

  @override
  String toString() => 'Kigo($id $word)';
}

/// 句の中で見つかった季語。
class KigoHit {
  const KigoHit(this.kigo, this.start, this.length, this.surface);
  final Kigo kigo;

  /// 空白と改行を除いた本文の中の位置ではなく、元の文字列（UTF-16）での位置。
  final int start;
  final int length;

  /// 句の中での書き方（別表記のこともある）。
  final String surface;

  int get end => start + length;
}

class KigoDetection {
  const KigoDetection(this.hits);
  final List<KigoHit> hits;

  /// 見つかった季語（重複なし、出てきた順）。
  List<Kigo> get kigo {
    final seen = <int>{};
    return [
      for (final h in hits)
        if (seen.add(h.kigo.id)) h.kigo,
    ];
  }

  /// 主となる季語（最初のもの）。
  Kigo? get primary => hits.isEmpty ? null : hits.first.kigo;

  /// 季重なり（違う季語が2つ以上）。
  bool get kigasanari => kigo.length >= 2;

  bool get isEmpty => hits.isEmpty;
}

/// 歳時記。季語の検索と、句からの季語の検出をする。
class KigoDictionary {
  KigoDictionary(List<Kigo> entries) : entries = List.unmodifiable(entries) {
    for (final k in entries) {
      _byId[k.id] = k;
      void add(String surface) {
        if (surface.isEmpty) return;
        _surfaces.putIfAbsent(surface, () => k);
      }

      add(k.word);
      for (final a in k.aliases) {
        add(a);
      }
      // 読み（かな書き）も3音以上なら拾う。2音以下は他の語の一部に紛れやすい。
      if (k.reading.runes.length >= 3) add(k.reading);
    }
    _maxLen = _surfaces.keys.fold(0, (m, s) => s.length > m ? s.length : m);
  }

  factory KigoDictionary.fromJsonString(String json) {
    final data = jsonDecode(json) as Map<String, Object?>;
    return KigoDictionary([
      for (final e in data['kigo'] as List)
        Kigo.fromJson((e as Map).cast<String, Object?>()),
    ]);
  }

  final List<Kigo> entries;
  final _byId = <int, Kigo>{};
  final _surfaces = <String, Kigo>{};
  int _maxLen = 0;

  Kigo? byId(int? id) => id == null ? null : _byId[id];

  /// 表記と読みの対応（音数の目安に使う）。読みが分かるのは見出し語だけ。
  Map<String, String> get readings => {
    for (final k in entries) k.word: k.reading,
  };

  /// 辞書との最長一致で季語を探す。左から順に、その位置で始まる一番長い語を取る。
  /// 空白・改行は飛ばしてつなげて照合する（行をまたぐ季語も拾う）。
  KigoDetection detect(String text) {
    // 空白を除いた文字と、元の位置の対応。
    final chars = <String>[];
    final pos = <int>[];
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (ch.trim().isEmpty) continue;
      chars.add(ch);
      pos.add(i);
    }
    final hits = <KigoHit>[];
    var i = 0;
    while (i < chars.length) {
      KigoHit? best;
      final maxLen = (_maxLen < chars.length - i) ? _maxLen : chars.length - i;
      for (var len = maxLen; len >= 1; len--) {
        final s = chars.sublist(i, i + len).join();
        final k = _surfaces[s] ?? _surfaces[toHiragana(s)];
        if (k != null) {
          final startPos = pos[i];
          final endPos = pos[i + len - 1] + 1;
          best = KigoHit(k, startPos, endPos - startPos, s);
          break;
        }
      }
      if (best != null) {
        hits.add(best);
        i += best.surface.length;
      } else {
        i++;
      }
    }
    return KigoDetection(hits);
  }

  /// 語・読み・別表記で検索する。前方一致を先に、部分一致を後に並べる。
  List<Kigo> search(String query, {Season? season}) {
    final q = toHiragana(query.trim());
    final pool = season == null
        ? entries
        : entries.where((k) => k.season == season).toList();
    if (q.isEmpty) return pool;
    final prefix = <Kigo>[];
    final partial = <Kigo>[];
    for (final k in pool) {
      final keys = [k.word, k.reading, ...k.aliases.map(toHiragana)];
      if (keys.any((s) => s.startsWith(q))) {
        prefix.add(k);
      } else if (keys.any((s) => s.contains(q)) || k.description.contains(q)) {
        partial.add(k);
      }
    }
    return [...prefix, ...partial];
  }
}
