# ナナコロビ（仮）

だるまに目を入れて、目標を始める。毎日の一歩で模様が入る目標帳。

目標を1つ決めると、だるまが1体できます。指で片目をなぞって「開眼」し、毎日の一歩を1タップで記録するとだるまに1筆ずつ模様が入ります。記録のない日はだるまが転びますが模様は減らず、次の記録で起き上がって台座に金の筋が1本増えます（七転び八起き）。達成したらもう片方の目を入れて両目になり、棚に並びます。試験日のような期限がある目標は、ウィジェットに残り日数が出ます。サーバーもアカウントも持たず、広告もありません。

- 設計：[docs/DESIGN.md](docs/DESIGN.md)
- ウィジェット（iOS WidgetKit・Android Glance）の実装手順：[docs/WIDGETS.md](docs/WIDGETS.md)
- ストアの設定手順（プラスの商品、署名、プライバシー、審査メモ）：[docs/STORE_SETUP.md](docs/STORE_SETUP.md)
- ストア素材（アイコン、スクリーンショット、掲載文、プライバシーポリシー）：[store/README.md](store/README.md)
- スタック：Flutter 3.47 / Riverpod（Notifier）/ Drift / Freezed / go_router / CustomPainter / ARB（ja 先行、en も同じキー）

## 動かす

```bash
flutter pub get
```

```bash
flutter test
```

```bash
flutter run
```

Freezed と Drift の生成コード（`*.freezed.dart`、`*.g.dart`）はコミットしてあります。モデルやテーブルを変えたときだけ作り直します。ARB の生成コード（`lib/l10n/generated/`）は `flutter pub get` のたびに作られます。

```bash
dart run build_runner build --delete-conflicting-outputs
```

## 状態

| 項目 | 状態 |
| --- | --- |
| だるま作成（目標名 2〜6字、色、本番の日、通過点 最大3、毎日の一歩） | できた。画面のテスト済み |
| 開眼（指でなぞる1筆、先に入れる目の左右は設定） | できた。なぞりの判定をテスト済み |
| ホーム（今日の一歩、当日の取り消し、30字メモ、筆の数・起き上がり回数・残り日数、転倒中の横倒し） | できた |
| 転ぶ・起き上がり・台座の金の筋、休み券（月2枚、前日までの宣言） | できた。純関数のテスト済み（`test/core/`） |
| 節目（7・21・50・100筆）で見た目が変わり、その日だけ共有を促す | できた |
| 両目（満願）と納め、同じ目標でひと回り大きいだるま | できた |
| 棚（現役・満願・納めの3段、年で絞り込み） | できた |
| 試験日プリセット（同梱 JSON 109件、jsDelivr から更新、失敗時は同梱版） | できた。日程は公式発表を確認できたものだけ（下の表）。兵庫県の公立高校入試は公式の日程 PDF を開けず未収録 |
| ウィジェット：Dart 側（WidgetSyncService、14日分のタイムライン、0時で進む設計） | できた |
| ウィジェット：ネイティブ側（iOS 小・中・ロック画面、Android 小・中） | ソースはできた（iOS は `ios/NanakorobiWidget/`、Android は Glance と home_widget の 0 時予約）。この環境には Xcode も Android SDK もなく、ビルドは未確認。Xcode でのターゲット追加は [docs/WIDGETS.md](docs/WIDGETS.md) |
| 共有画像（1080×1350 と 1:1、テンプレ5種、年末の棚ポスター、ストアリンクなし） | できた。PNG の大きさをテスト済み |
| リマインド通知（既定オフ、1日1回、14日分を日ごとの本文で予約） | コードはできた。実機での確認はまだ |
| プラス（¥600、非消耗型、現役無制限・全12色・ポスター・全テンプレ・JSON 書き出し/読み込み） | コードとテストはできた。ストアの商品登録はまだ（[docs/STORE_SETUP.md](docs/STORE_SETUP.md)） |
| 計測（端末内カウンタ）と評価依頼（7日目の節目と両目の直後、365日3回まで） | できた |
| 共有パッケージ ookura_iap・ookura_settings・ookura_streak・ookura_design・ookura_a11y の組み込み | まだ（非公開のため、窓口と仮実装で動く。下の表） |
| 毛筆体フォント | できた。Yuji Syuku（SIL OFL 1.1）を同梱し、腹の文字と共有画像で使う |
| 英語版 | ARB の en キーまで。文言の見直しと切り替えの導線はまだ |
| アイコン・スプラッシュ・ストア素材 | できた（[store/README.md](store/README.md)）。スクリーンショットは Flutter のテスト実行で画面を組み立てて描いたもので、実機の画面ではない |
| リリース設定（版 1.0.0+1、Android の署名、権限、iOS の App Group・エンタイトルメント・暗号の申告） | できた。署名鍵、ストアの商品登録、プライバシーポリシーの公開 URL は人の作業（[docs/STORE_SETUP.md](docs/STORE_SETUP.md)） |
| 実機での確認 | まだ（この環境は Linux で、iOS/Android のビルドは未確認） |
| Apple Watch・Live Activity | 後回し |

`flutter analyze` と `flutter test`（66件）は通ります。

## 共有パッケージの差し替え

ひそかぎの `NoAdService` と同じく、窓口（抽象クラス）だけ切って仮実装にしてあります。共有パッケージが手元にある環境では、`lib/main.dart` で組み立てている実装を差し替えます。

| パッケージ | 窓口 | 仮実装 | 差し替え方 |
| --- | --- | --- | --- |
| ookura_iap | `PlusService`（`lib/services/plus_service.dart`） | `StorePlusService`（in_app_purchase を直接使う。購入状態は端末に保存）、テスト用 `FakePlusService` | ookura_iap のアダプタで `PlusService` を実装し、`lib/main.dart` の `plus` を差し替える。商品 ID は `plusProductId` |
| ookura_settings | `SettingsStore`（`lib/services/settings_store.dart`） | `PrefsSettingsStore`（shared_preferences に JSON）、`MemorySettingsStore` | `SettingsStore` を実装して `lib/main.dart` の `settingsStore` を差し替える。設定の形は `AppSettings`（`lib/model/models.dart`） |
| ookura_streak | `RestTickets`（`lib/core/rest_tickets.dart`） | 休み券の決まり（月2枚、前日までの宣言、取り消し）を純関数で | 判定を ookura_streak に置き換え、`test/core/rest_tickets_test.dart` を通す |
| ookura_design | `NanakorobiTheme`（`lib/ui/theme.dart`） | 和紙の生成りと墨、朱と金の ThemeData | テーマを ookura_design のものに差し替える。だるまの色は `lib/core/daruma_colors.dart` で別に持つ |
| ookura_a11y | `A11y`（`lib/ui/a11y.dart`） | 「視覚効果を減らす」の判定と最小タップ領域 | ookura_a11y のユーティリティに差し替える |

## 毛筆体フォント

腹の文字（縦書き）と共有画像には **Yuji Syuku**（Kinuta Font Factory、Version 3.002、SIL Open Font License 1.1、TTF 7.8 MB）を使います。`assets/fonts/YujiSyuku-Regular.ttf` を family `NanakorobiBrush` で登録し、`NanakorobiTheme.brushFontFamily` から参照しています。ライセンス全文は `assets/fonts/OFL.txt` に同梱し、設定 → ライセンスに表示します。Regular の1ウェイトだけなので、太字の指定はせず、筆の線の太さは描画側で出します。

検討した候補（どれも SIL OFL 1.1。大きさは Google Fonts の TTF、2026-11-04 時点）：

| 書体 | 印象 | TTF | 備考 |
| --- | --- | --- | --- |
| Yuji Syuku（Kinuta Font Factory） | 楷書寄りの筆文字。縁起文字に合い、読みやすい | 7.8 MB | 採用 |
| Yuji Boku | 墨のかすれが強い筆文字 | 7.8 MB | 迫力はあるが小さい字でつぶれやすい |
| Yuji Mai | 舞うような行書 | 7.8 MB | 「合格」「必勝」には柔らかすぎるかもしれない |
| Zen Antique | 古風な明朝 | 5.5 MB | 毛筆感は弱いが軽い |
| Kaisei Decol | 装飾の付いた明朝 | 4.2 MB | 同上 |

日本語フォントは1書体でアプリが 4〜8 MB 増えるので、同梱は Yuji Syuku の1書体だけにします。書体を替えるときは、TTF を `assets/fonts/` に置き換えて `pubspec.yaml` の `fonts` と `assets/fonts/OFL.txt` を差し替えます。

## 試験日プリセットの確認元

`assets/presets/exam_dates.json` の 109 件は、主催団体の公式ページの本文を開いて日付を確認できたものだけを入れています（確認日 2026-11-04）。更新分は jsDelivr（このリポジトリの `main` ブランチの同梱 JSON）から取り、取得に失敗しても同梱版で動きます。日程を直すときは JSON の `updated_on` を進めてください。いまの既定ブランチは `main` ではないので、`main` を作るか、`lib/services/presets_service.dart` の `remoteUrl` を配信元のブランチかタグに合わせてください（jsDelivr の参照名にスラッシュは使えません）。

確認できず入れていない日程：

- 兵庫県公立高校入試（教育委員会の日程 PDF の本文を開けなかった。二次情報では 2027-03-11）
- 2027年の税理士・社会保険労務士・宅地建物取引士・行政書士・司法書士・中小企業診断士（例年の公告が 2027 年春以降で未公告）
- 情報処理技術者試験の 2027 年度（新制度で日程未公表）、英検・漢検・数検・TOEIC の 2027 年度（未発表）
- 私立中学入試は、協会が「入試開始日」を定めている東京（2/1 以降）と近畿（1/16 以降）だけ。神奈川・千葉・埼玉は学校ごとの一覧しかなく、統一の開始日の記述がなかった

| 確認元 | URL | 入れた日程 |
| --- | --- | --- |
| 公益財団法人 日本数学検定協会 | https://www.su-gaku.net/suken/schedule/ | 数検 第469回（準1〜11級） |
| IIBC（国際ビジネスコミュニケーション協会） | https://www.iibc-global.org/toeic/test/lr/guide01/schedule.html | TOEIC L&R 公開テスト 2026年12月6日 |
| 公認会計士・監査審査会（金融庁） | https://www.fsa.go.jp/cpaaob/kouninkaikeishi-shiken/information.html | 3件（公認会計士 令和9年 第I回短答式試験 ほか）|
| IIBC | https://www.iibc-global.org/toeic/test/lr/guide01/schedule.html | 6件（TOEIC L&R 公開テスト 2026年12月19日 ほか）|
| 日本FP協会／金融財政事情研究会 | https://www.jafp.or.jp/exam/schedule/ | 2級・3級FP技能検定 2027年1月（CBT） |
| 大学入試センター | https://www.dnc.ac.jp/kyotsu/shiken_jouhou/r9/ | 4件（大学入学共通テスト 1日目 ほか）|
| 大阪私立中学校高等学校連合会 | https://www.osaka-shigaku.gr.jp/news/ | 関西 私立中学 統一入試日（解禁日） |
| 日本数学検定協会 | https://www.su-gaku.net/suken/schedule/ | 4件（数検 第470回（2〜11級） ほか）|
| 公益財団法人 日本英語検定協会 | https://www.eiken.or.jp/eiken/schedule/2026-examinee.html | 英検 2026年度第3回 一次試験（本会場） |
| 一般社団法人 金融財政事情研究会 | https://products.kinzai.or.jp/exam/exam-schedule/ | 1級FP技能検定 学科試験 2027年1月（きんざい） |
| 厚生労働省 | https://www.mhlw.go.jp/kouseiroudoushou/shikaku_shiken/index.html | 21件（第120回 歯科医師国家試験 ほか）|
| 公益財団法人 社会福祉振興・試験センター | https://www.sssc.or.jp/kaigo/tetsuzuki.html | 第39回 介護福祉士国家試験（筆記） |
| 東京都生活文化局（東京私立中学高等学校協会の定めを掲載） | https://www.metro.tokyo.lg.jp/information/press/2026/10/2026100712 | 東京都 私立中学 入試開始日 |
| 社会福祉振興・試験センター | https://www.sssc.or.jp/seishin/tetsuzuki.html | 第29回 精神保健福祉士国家試験 |
| 社会福祉振興・試験センター | https://www.sssc.or.jp/shakai/tetsuzuki.html | 第39回 社会福祉士国家試験 |
| 公益財団法人 日本漢字能力検定協会 | https://www.kanken.or.jp/kanken/individual/pbt/schedule/ | 漢検 2026年度第3回（公開会場） |
| 千葉県教育委員会 | https://www.pref.chiba.lg.jp/kyouiku/shidou/nyuushi/koukou/r9/r9nyushinittei.html | 千葉県公立高校 一般入学者選抜 本検査 |
| 群馬県教育委員会 | https://www.pref.gunma.jp/site/kyouiku/742234.html | 群馬県公立高校 全日制課程選抜 本検査（学力検査） |
| 神奈川県教育委員会 | https://www.pref.kanagawa.jp/docs/dc4/nyusen/nyusen/r9/r9nyusen-nittei.html | 神奈川県公立高校 共通選抜 共通検査（学力検査等） |
| 長崎県教育委員会 | https://www.pref.nagasaki.lg.jp/fs/2/4/1/8/2/_/__8_5______.pdf | 長崎県公立高校 一般選抜 学力検査 |
| 福井県教育委員会 | https://www.pref.fukui.lg.jp/doc/koukou/nyugaku/r9zissiyoukou.html | 福井県立高校 一般入学者選抜 学力検査 |
| 京都府教育委員会 | https://www.kyoto-be.ne.jp/koukyou/cms/wp-content/uploads/2026/04/002%EF%BC%88%E5%BA%83%E5%A0%B1%E8%B3%87%E6%96%99%EF%BC%89%E5%85%AC%E7%AB%8B%E9%AB%98%E7%AD%89%E5%AD%A6%E6%A0%A1%E5%85%A5%E5%AD%A6%E8%80%85%E9%81%B8%E6%8A%9C%E3%81%AB%E3%81%A4%E3%81%84%E3%81%A6.pdf | 京都府公立高校 前期選抜 統一学力検査 |
| 東京都教育委員会 | https://www.metro.tokyo.lg.jp/information/press/2026/05/2026052829 | 東京都立高校 一般入試（学力検査に基づく選抜 第一次募集・分割前期募集） |
| 愛知県教育委員会 | https://www.pref.aichi.jp/uploaded/attachment/612084.pdf | 愛知県公立高校 一般選抜 学力検査 |
| 広島県教育委員会 | https://www.pref.hiroshima.lg.jp/uploaded/attachment/668828.pdf | 広島県公立高校 一次選抜 学力検査・自己表現等 |
| 奈良県教育委員会 | https://www.pref.nara.lg.jp/documents/5972/r9_nyuusinittei.pdf | 奈良県立高校 一次選抜 学力検査 |
| 栃木県教育委員会 | https://www.pref.tochigi.lg.jp/m04/documents/20250610161236.pdf | 栃木県立高校 一般選抜 学力検査（本検査） |
| 国立大学協会 | https://www.janu.jp/cms/wp-content/uploads/2026/06/nyuushi_2027.pdf | 2件（国公立大学 二次試験 前期日程（初日） ほか）|
| 茨城県教育委員会 | https://kyoiku.pref.ibaraki.jp/wp-content/uploads/2026/07/R9_HS_leaflet.pdf | 茨城県立高校 一般入学 学力検査 |
| 新潟県教育委員会 | https://www.pref.niigata.lg.jp/uploaded/attachment/513719.pdf | 新潟県公立高校 一般選抜 本検査1日目（学力検査） |
| 埼玉県教育委員会 | https://www.pref.saitama.lg.jp/f2208/news/page/news2025052203.html | 埼玉県公立高校 入学者選抜 学力検査 |
| 日本商工会議所 | https://www.kentei.ne.jp/calendar_2026 | 日商簿記検定 第175回 統一試験 |
| 日本英語検定協会 | https://www.eiken.or.jp/eiken/schedule/2026-examinee.html | 2件（英検 2026年度第3回 二次試験 A日程 ほか）|
| 佐賀県教育委員会 | https://www.pref.saga.lg.jp/kyouiku/kiji003119218/3_119218_389544_up_7eamtra8.pdf | 佐賀県立高校 一般選抜 学力検査 |
| 福島県教育委員会 | https://www.pref.fukushima.lg.jp/uploaded/attachment/765508.pdf | 福島県立高校 前期選抜（学力検査） |
| 岐阜県教育委員会 | https://www.pref.gifu.lg.jp/uploaded/attachment/490454.pdf | 岐阜県立高校 第一次選抜 検査（学力検査） |
| 北海道教育委員会 | https://www.dokyoi.pref.hokkaido.lg.jp/hk/gks/184082.html | 北海道立高校 一般入学者選抜（学力検査） |
| 鹿児島県教育委員会 | https://www.pref.kagoshima.jp/ba05/kyoiku-bunka/school/koukou/nyushi/r4/r9nittei.html | 鹿児島県公立高校 一般入学者選抜 学力検査 |
| 高知県教育委員会 | https://www.pref.kochi.lg.jp/doc/2026011400217/ | 高知県公立高校 A日程 学力検査 |
| 宮城県教育委員会 | https://www.pref.miyagi.jp/soshiki/kyou-kikaku/happyou251224-2.html | 宮城県公立高校 第一次募集（学力検査） |
| 宮崎県教育委員会 | https://www.pref.miyazaki.lg.jp/kokokyoiku/kyoikukosodate/kyoiku/20260519170532.html | 宮崎県立高校 一般入学者選抜 学力検査 |
| 大分県教育委員会 | https://www.pref.oita.jp/uploaded/life/2334294_4701521_misc.pdf | 大分県立高校 一般入学者選抜 学力検査（第一志願） |
| 沖縄県教育委員会 | https://www.pref.okinawa.lg.jp/kyoiku/gakko/1008883/1008887/1041122.html | 沖縄県立高校 一般選抜 学力検査 |
| 滋賀県教育委員会 | https://www.pref.shiga.lg.jp/documents/16947/20260907215036.pdf | 滋賀県立高校 一次募集 学力検査 |
| 島根県教育委員会 | https://www.pref.shimane.lg.jp/education/kyoiku/senbatsu/senbatsu_info/index.data/R9_kihonhoushin.pdf | 島根県公立高校 一般選抜 学力検査 |
| 静岡県教育委員会 | https://www.pref.shizuoka.jp/_res/projects/default_project/_page_/001/082/226/260910upjissiyouryou.pdf | 静岡県公立高校 一般選抜 学力検査 |
| 徳島県教育委員会 | https://nyuushi.tokushima-ec.ed.jp/file/2139 | 徳島県公立高校 一般選抜 学力検査 |
| 山梨県教育委員会 | https://www.pref.yamanashi.jp/documents/84777/r9kihonziko.pdf | 山梨県公立高校 後期募集 学力検査 |
| 秋田県教育委員会 | https://www.pref.akita.lg.jp/pages/archive/99375 | 秋田県公立高校 1次募集（学力検査） |
| 青森県教育委員会 | https://www.pref.aomori.lg.jp/soshiki/kyoiku/e-gakyo/files/R9motomeru_zenntai.pdf | 青森県立高校 入学者選抜（学力検査） |
| 愛媛県教育委員会 | https://ehime-kyoiku.esnet.ed.jp/file/2835 | 愛媛県立高校 一般入学者選抜 学力検査 |
| 岩手県教育委員会 | https://www.pref.iwate.jp/kyouikubunka/kyouiku/gakkou/senbatsu/1086539.html | 岩手県立高校 一次募集（一般入試）本検査 |
| 熊本県教育委員会 | https://www.pref.kumamoto.jp/uploaded/life/270083_837341_misc.pdf | 熊本県立高校 後期（一般）選抜 学力検査 |
| 鳥取県教育委員会 | https://www.pref.tottori.lg.jp/secure/1422417/R09_nyuugakusya_houshin.pdf | 鳥取県立高校 一般入学者選抜 学力検査 |
| 山形県教育委員会 | https://www.pref.yamagata.jp/documents/49031/r09sennbatsujissiyoukou.pdf | 山形県公立高校 後期（一般）選抜 学力検査 |
| 公立大学協会（文科省サイト掲載版） | https://www.mext.go.jp/content/20260928-mxt_daigakuc02-000052178_5-9-1.pdf | 公立大学 中期日程（開始日） |
| 福岡県教育委員会 | https://www.pref.fukuoka.lg.jp/site/kyouiku/kennittei.html | 福岡県立高校 一般入学者選抜 学力検査 |
| 石川県教育委員会 | https://www.pref.ishikawa.lg.jp/kyoiku/gakkou/senbatu/documents/r9housin.pdf | 石川県公立高校 一般入学 学力検査 |
| 香川県教育委員会 | https://www.pref.kagawa.lg.jp/documents/15088/yoko9.pdf | 香川県公立高校 一般選抜 学力検査 |
| 三重県教育委員会 | https://www.pref.mie.lg.jp/KOKOKYO/HP/m0204200392.htm | 三重県立高校 後期選抜（学力検査） |
| 長野県教育委員会 | https://www.pref.nagano.lg.jp/kyoiku/koko/saiyo-nyuushi/shiken/ko/r9/documents/r9senbatsu_gaiyo.pdf | 長野県公立高校 後期選抜（一般選抜）学力検査 |
| 岡山県教育委員会 | https://www.pref.okayama.jp/uploaded/life/1015516_9804789_misc.pdf | 岡山県立高校 一般入学者選抜 学力検査 |
| 富山県教育委員会 | https://www.pref.toyama.jp/documents/56046/r9nittei.pdf | 富山県立高校 一般選抜 学力検査 |
| 山口県教育委員会 | https://www.pref.yamaguchi.lg.jp/uploaded/life/353652_683067_misc.pdf | 山口県公立高校 第一次募集 学力検査 |
| 大阪府教育委員会 | https://www.pref.osaka.lg.jp/documents/9134/p42_shiryo4.pdf | 大阪府公立高校 一般入学者選抜 学力検査 |
| 和歌山県教育委員会 | https://www.pref.wakayama.lg.jp/prefg/500200/d00221979_d/fil/09nyuusinittei.pdf | 和歌山県立高校 一般選抜 学力検査 |
| 一般社団法人 全国保育士養成協議会 | https://www.hoyokyo.or.jp/exam/ | 保育士試験 令和9年前期 筆記試験 |
| 全国保育士養成協議会 | https://www.hoyokyo.or.jp/exam/ | 3件（保育士試験 令和9年前期 実技試験 ほか）|
| 法務省 司法試験委員会 | https://www.moj.go.jp/content/001468199.pdf | 令和9年 司法試験 |
| 法務省 司法試験委員会 | https://www.moj.go.jp/content/001469347.pdf | 2件（令和9年 司法試験予備試験 短答式 ほか）|
| 日本FP協会 | https://www.jafp.or.jp/exam/schedule/ | 1級FP技能検定 実技試験 2027年9月（日本FP協会） |

## 仮置きした未決事項

- 名前：ナナコロビ（仮）。Flutter のパッケージ名は `nanakorobi`、Bundle ID / パッケージ名は `com.ookura.nanakorobi`
- プラスの価格：¥600（¥480〜730 で未決）
- 無料の色：赤・白・黒
- 0〜3時の記録は当日扱い（設定で「前日の記録」に切り替えられる）
- 開眼で先に入れる目：左目（向かって右）。設定で変えられる
- 毛筆体フォント：Yuji Syuku に決定（同梱済み）
