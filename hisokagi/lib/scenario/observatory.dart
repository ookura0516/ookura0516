import '../core/rng.dart';
import 'model.dart';

/// シナリオ1「閉館後の天文台」（無料・2人用）。
///
/// 役A：ドームの中に閉じ込められた人。役B：外の管制室で観測ノートを見つけた人。
/// ステージは5つ。答えを入れる役は A → B → B → A → A。
class ObservatoryScenario extends ScenarioDef {
  const ObservatoryScenario();

  @override
  int get id => 1;

  @override
  String get title => '閉館後の天文台';

  @override
  String get tagline => 'ドームの中と管制室。ふたりで屋根を開けて、0時の流星群を見よう。';

  @override
  int get minutes => 30;

  @override
  bool get free => true;

  @override
  List<int> get playerCounts => const [2];

  static const roleA = RoleInfo(
    role: Role.a,
    name: 'ドームの中',
    place: '閉館したドームに閉じ込められた。扉も屋根も、古い仕掛けで動かない。',
  );

  static const roleB = RoleInfo(
    role: Role.b,
    name: '管制室',
    place: '外の管制室に入れた。机の上に、古い観測ノートが置いてある。',
  );

  @override
  List<RoleInfo> rolesFor(int players) => const [roleA, roleB];

  @override
  String prologue(Role role) => switch (role) {
        Role.a => '閉館のアナウンスに気づかず、プラネタリウムの席で眠ってしまった。'
            '目を覚ますと、ドームは真っ暗。扉は開かず、手元のスマホだけが光っている。\n\n'
            '今夜0時には、流星群がやってくる。管制室にいる相棒と声をかけあって、'
            'ここから屋根を開けよう。\n\n'
            'あなたの画面は、相棒には見えません。見えたものは、言葉で伝えてください。',
        _ => '待ち合わせの時間を過ぎても、相棒がドームから出てこない。'
            '裏口から入れた管制室には、古い観測ノートと、動かない計器が並んでいる。\n\n'
            '今夜0時には、流星群がやってくる。ドームの中の相棒と声をかけあって、'
            '屋根を開けよう。\n\n'
            'あなたの画面は、相棒には見えません。見えたものは、言葉で伝えてください。',
      };

  @override
  String ending(Role role) => switch (role) {
        Role.a => '重い歯車の音がして、ドームの屋根がゆっくりと割れていく。'
            '細い夜空の帯に、最初のひとすじが流れた。\n\n'
            'スマホの向こうで、相棒が息をのむのが聞こえる。'
            '同じ空を、ちがう場所から見ている。',
        _ => '計器の針がいっせいに動き、モニターにドームの上の空が映った。'
            '屋根のすきまから、星が次々にこぼれ落ちていく。\n\n'
            '「見えてる？」と聞くと、ドームの中から「見えてる」と返ってきた。',
      };

  // 記号の名前は、遊ぶ人が自分の言葉で伝えるので画面には出さない。
  static const symbols = ['○', '△', '□', '◇', '☆', '♡'];

  static const words = ['ほしぞら', 'みかづき', 'しんげつ', 'まんげつ', 'すいせい', 'わくせい'];

  static const _gridPool = 'あいうえおかきくけこさしすせそたちつてとなにぬねの'
      'はひふへほまみむめもやゆよらりるれろわをんがぎぐげござじずぜぞだでどばびぶべぼ';

  static const rowLabels = ['一', '二', '三', '四', '五'];

  @override
  List<StageInstance> build(int seed) {
    final door = _doorStage(seed);
    final cable = _cableStage(seed);
    final clock = _clockStage(seed);
    final cipher = _cipherStage(seed);
    final dome = _domeStage(
      doorAnswer: door.answer,
      cableAnswer: cable.answer,
      clockMinute: int.parse(clock.answer.split(':')[1]),
    );
    return [door, cable, clock, cipher, dome];
  }

  // ------------------------------------------------------------ 1. 星図の扉

  StageInstance _doorStage(int seed) {
    final rng = Rng.forKey(['obs', 'door', seed]);
    final summer = rng.shuffled(List.generate(9, (i) => i + 1)).take(6).toList();
    final doorSymbols = rng.shuffled(List.generate(6, (i) => i)).take(4).toList();
    final isSummer = rng.nextBool();

    // 冬の表は、扉の答えが夏と同じにならないものを選ぶ。
    List<int> winter;
    String answerFor(List<int> map) =>
        doorSymbols.map((s) => map[s]).join();
    do {
      winter = rng.shuffled(List.generate(9, (i) => i + 1)).take(6).toList();
    } while (answerFor(winter) == answerFor(summer));

    final answer = answerFor(isSummer ? summer : winter);
    final season = isSummer ? '夏' : '冬';

    return StageInstance(
      title: '星図の扉',
      inputRole: Role.a,
      input: const DigitsInput(4),
      answer: answer,
      answerDisplay: answer,
      notebookLabel: '星図の扉の番号',
      views: {
        Role.a: StageView(
          intro: '出口の扉には、数字を4つ入れる錠がついている。'
              '扉の表面には、見たことのない記号が4つ彫られている。',
          panels: [
            SymbolRowPanel(
              title: '扉の記号（左から）',
              symbols: [for (final s in doorSymbols) symbols[s]],
              caption: '扉の上には「$seasonの扉」と彫られている。',
            ),
          ],
        ),
        Role.b: StageView(
          intro: '観測ノートの最初のページに、記号と数字の表がある。'
              'ドームの扉と関係があるのかもしれない。',
          panels: [
            TablePanel(
              title: '観測ノート：星図',
              headers: const ['記号', '夏の星図', '冬の星図'],
              rows: [
                for (var i = 0; i < 6; i++)
                  [symbols[i], '${summer[i]}', '${winter[i]}'],
              ],
              caption: '「扉は季節の星図で開く」と書き添えてある。',
            ),
          ],
        ),
      },
      hints: const {
        Role.a: [
          '扉の記号の形と順番を、管制室の相棒にそのまま伝えよう。',
          '相棒のノートには、夏と冬の2つの表がある。扉に彫られた季節も伝えよう。',
        ],
        Role.b: [
          '相棒の扉には4つの記号が並んでいる。形を聞いて、表で数字を探そう。',
          '表は夏と冬で数字がちがう。どちらの季節の扉か、相棒に聞こう。',
        ],
      },
    );
  }

  // ------------------------------------------------------------ 2. ケーブル

  static const cableRules = [
    '赤が1本もなければ、左から2本目を抜く。',
    '白が2本以上あれば、いちばん右の白を抜く。',
    'いちばん左が青なら、いちばん右のケーブルを抜く。',
    '黄がちょうど1本なら、その黄を抜く。',
    'どれにも当てはまらなければ、左から4本目を抜く。',
  ];

  /// 規則を上から順に当てはめ、抜くケーブルの位置（1始まり）を返す。
  static int cableToPull(List<CableColor> c) {
    int count(CableColor x) => c.where((e) => e == x).length;
    if (count(CableColor.red) == 0) return 2;
    if (count(CableColor.white) >= 2) {
      return c.lastIndexOf(CableColor.white) + 1;
    }
    if (c.first == CableColor.blue) return c.length;
    if (count(CableColor.yellow) == 1) {
      return c.indexOf(CableColor.yellow) + 1;
    }
    return 4;
  }

  StageInstance _cableStage(int seed) {
    final rng = Rng.forKey(['obs', 'cable', seed]);
    final colors = List.generate(5, (_) => rng.pick(CableColor.values));
    final pull = cableToPull(colors);

    return StageInstance(
      title: '望遠鏡のケーブル',
      inputRole: Role.b,
      input: const CableChoiceInput(),
      answer: '$pull',
      answerDisplay: '左から$pull本目（${colors[pull - 1].label}）',
      notebookLabel: '抜いたケーブル（左から何本目）',
      views: {
        Role.a: const StageView(
          intro: '扉を出ると、望遠鏡の台座に古い取扱説明書が貼ってある。'
              '「動かないときは、ケーブルを1本だけ抜くこと」。',
          panels: [
            ListPanel(
              title: '取扱説明書：ケーブルの抜き方',
              items: cableRules,
              caption: '上から順に確かめ、最初に当てはまった1つだけを使う。',
            ),
          ],
        ),
        Role.b: StageView(
          intro: '管制室の計器盤に、望遠鏡につながるケーブルが5本ささっている。'
              'どれかを抜けば、望遠鏡が動きそうだ。',
          panels: [
            CablePanel(
              title: '計器盤のケーブル',
              colors: colors,
              caption: 'まちがったケーブルを抜くと火花が散る。抜く前に相棒に確かめよう。',
            ),
          ],
        ),
      },
      hints: const {
        Role.a: [
          '相棒の計器盤にはケーブルが5本ある。色を左から順に聞こう。',
          '規則は上から順に確かめる。最初に当てはまったものだけを使い、残りは無視する。',
        ],
        Role.b: [
          '5本の色を左から順に、相棒に伝えよう。',
          '相棒の説明書の規則は上から順に使う。1つ当てはまったら、そこで決まり。',
        ],
      },
      waitingNote: '相棒の計器盤でケーブルが抜かれると、合言葉が出ます。',
    );
  }

  // ------------------------------------------------------------ 3. 時計

  StageInstance _clockStage(int seed) {
    final rng = Rng.forKey(['obs', 'clock', seed]);
    final shownHour = rng.nextInt(12) + 1;
    final shownMinute = rng.nextInt(12) * 5;
    final drift = (rng.nextInt(5) + 1) * 5;
    final isFast = rng.nextBool();
    final later = rng.nextInt(4) + 1;

    var total = (shownHour % 12) * 60 +
        shownMinute +
        (isFast ? -drift : drift) +
        later * 60;
    total %= 720;
    if (total < 0) total += 720;
    final hour = total ~/ 60 == 0 ? 12 : total ~/ 60;
    final minute = total % 60;

    return StageInstance(
      title: '止まった時計',
      inputRole: Role.b,
      input: const TimeInput(),
      answer: TimeInput.format(hour, minute),
      answerDisplay: '$hour時${minute.toString().padLeft(2, '0')}分',
      notebookLabel: '屋根を開ける時刻',
      views: {
        Role.a: StageView(
          intro: 'ドームの壁に、針の止まった時計がかかっている。'
              '裏返すと、色あせた貼り紙があった。',
          panels: [
            ClockPanel(
              title: 'ドームの時計',
              hour: shownHour,
              minute: shownMinute,
            ),
            TextPanel(
              title: '時計の裏の貼り紙',
              body: isFast ? 'この時計は 進んでいます。' : 'この時計は 遅れています。',
            ),
          ],
        ),
        Role.b: StageView(
          intro: '屋根の開閉には、時刻の入力が要るらしい。'
              'ノートの端に、走り書きのメモがある。',
          panels: [
            TextPanel(
              title: '観測ノートのメモ',
              body: 'ドームの時計は $drift分 ずれている。\n'
                  '屋根を開けるのは、正しい時刻の ちょうど$later時間後。',
              caption: '計器盤の時刻は、12時間表記で入れる。',
            ),
          ],
        ),
      },
      hints: const {
        Role.a: [
          '時計の針が何時何分を指しているか、相棒に伝えよう。長い針が分。',
          '時計の裏の貼り紙（進んでいる／遅れている）も相棒に伝えよう。',
        ],
        Role.b: [
          '相棒の時計の時刻を聞いて、ずれを直してから時間を足そう。',
          '進んでいる時計なら引く、遅れている時計なら足す。12時を過ぎたら1時に戻る。',
        ],
      },
      waitingNote: '相棒が計器盤に時刻を入れると、合言葉が出ます。',
    );
  }

  // ------------------------------------------------------------ 4. 暗号

  StageInstance _cipherStage(int seed) {
    final rng = Rng.forKey(['obs', 'cipher', seed]);
    final word = rng.pick(words);
    final pool = _gridPool.split('');
    final cells = List.generate(5, (_) => List.generate(5, (_) => rng.pick(pool)));
    final spots = rng.shuffled(List.generate(25, (i) => i)).take(4).toList();
    final letters = word.split('');
    for (var i = 0; i < 4; i++) {
      cells[spots[i] ~/ 5][spots[i] % 5] = letters[i];
    }
    final marks = [
      for (final s in spots) '${rowLabels[s ~/ 5]}の${s % 5 + 1}',
    ];

    return StageInstance(
      title: '暗号の観測ノート',
      inputRole: Role.a,
      input: const KanaInput(4),
      answer: word,
      answerDisplay: word,
      notebookLabel: 'ドームの合言葉',
      views: {
        Role.a: StageView(
          intro: '制御盤の前の壁に、ひっかいたような印が4つ並んでいる。'
              '制御盤は「合言葉を入れよ」と光っている。',
          panels: [
            ListPanel(title: '壁の印（上から順に）', items: marks),
          ],
        ),
        Role.b: StageView(
          intro: 'ノートの真ん中のページに、文字がぎっしり並んだ表がある。',
          panels: [
            GridPanel(
              title: '観測ノート：文字の表',
              rowLabels: rowLabels,
              colLabels: const ['1', '2', '3', '4', '5'],
              cells: cells,
              caption: 'たての行は 一〜五、横の列は 左から1〜5。',
            ),
          ],
        ),
      },
      hints: const {
        Role.a: [
          '壁の印は、相棒の表の場所を表している。1つずつ読み上げよう。',
          '「三の2」は、相棒の表の「三」の行の左から2番目。4文字そろうと、星にまつわる言葉になる。',
        ],
        Role.b: [
          '相棒の壁の印は、あなたの表の場所を指している。',
          '「三の2」なら「三」の行の左から2番目の文字。4文字を順に相棒に伝えよう。',
        ],
      },
    );
  }

  // ------------------------------------------------------------ 5. ドーム

  StageInstance _domeStage({
    required String doorAnswer,
    required String cableAnswer,
    required int clockMinute,
  }) {
    final code = '${doorAnswer[doorAnswer.length - 1]}$cableAnswer${clockMinute ~/ 10}';
    return StageInstance(
      title: 'ドームを開く',
      inputRole: Role.a,
      input: const DigitsInput(3),
      answer: code,
      answerDisplay: code,
      notebookLabel: '屋根の番号',
      views: {
        Role.a: const StageView(
          intro: '制御盤のふたが開き、3けたのダイヤルが現れた。'
              'あたりを探しても、番号の手がかりはどこにもない。',
          panels: [
            TextPanel(
              title: '制御盤',
              body: '「屋根を開く番号を入れよ」\n\n'
                  'あなたの手帳には、ここまでにあなたが解いた答えが残っている。',
            ),
          ],
        ),
        Role.b: const StageView(
          intro: 'ノートの最後のページに、屋根の番号の作り方が書いてある。',
          panels: [
            ListPanel(
              title: '観測ノート：屋根を開く番号（3けた）',
              items: [
                '1けた目：星図の扉の番号の、いちばん右の数字',
                '2けた目：抜いたケーブルが、左から何本目だったか',
                '3けた目：屋根を開ける時刻の「分」の、十の位（7時25分なら 2）',
              ],
              caption: '手帳には、それぞれが解いた答えだけが残っている。',
            ),
          ],
        ),
      },
      hints: const {
        Role.a: [
          '番号の作り方は、管制室のノートにある。相棒に読んでもらおう。',
          '1けた目はあなたの手帳（星図の扉の番号）、2けた目と3けた目は相棒の手帳にある。',
        ],
        Role.b: [
          '番号の作り方を、相棒に読み上げよう。',
          '2けた目と3けた目は、あなたの手帳の答えから作れる。1けた目は相棒の手帳にある。',
        ],
      },
      waitingNote: '相棒が屋根の番号を入れると、合言葉が出ます。',
    );
  }
}
