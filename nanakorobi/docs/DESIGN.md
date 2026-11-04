# ナナコロビ 設計書（最小版）

だるまに目を入れて、目標を始める。毎日の一歩を1タップで記録するとだるまに模様が入り、記録のない日は転ぶが模様は減らず、次の記録で起き上がって台座に金の筋が増える（七転び八起き）。受験生向けに、試験日までの残り日数をホーム画面のウィジェットに出す。無料、広告なし。

- 元の設計書（全体）：[ナナコロビ（仮） 設計書](https://claude.ai/artifact/2ZwPSF3X5zUsBrGcPzcZnx)
- 作る前の検証と決定：[ナナコロビ（仮）作る前の検証](https://claude.ai/artifact/DbdNJjCpxwem8qYjjK4YQV)
- この文書は、そのうち **最小版（2週間で判定する範囲）** に入れたものと、コードの置き場所を書く

## 1. 決まっていること（2026-11-04）

| 項目 | 決定 |
| --- | --- |
| 先行アプリ「だるま目標管理」（iOS、2026-10-19）への姿勢 | 設計書どおり進める。差は「毎日の一歩で模様が入る」「転んでも減らない」「広告なし」。ストア文とスクリーンショット1枚目で前に出す |
| Google Play の製品版公開 | 権限あり。2週間は製品版の公開日から数える |
| 自作の「受験カウントダウン」（Play） | 別アプリのまま残し、その試験一覧と設定画面にナナコロビへの導線を置く |
| 毛筆フォント | Yuji Syuku（SIL OFL 1.1）。JIS 第1水準＋かなに絞って同梱（約 3 MB） |
| 最初に入れる目 | 左目（向かって右）。設定で変えられる |
| 1 日の境界 | 端末のローカル日付。0〜3 時の記録も当日扱い |
| パッケージ名 | `com.ookura.nanakorobi` |

## 2. 最小版の範囲

| 入れた | 入れていない（判定後） |
| --- | --- |
| 作成：腹の文字（2〜6字）、色 3 色、本番の日（日付入力＋同梱プリセット）、毎日の一歩 | プラス（IAP）、全 12 色、季節の背景、プリセット全件と jsDelivr 更新 |
| 開眼（指でなぞる 1 筆） | 通過点、休み券 |
| 今日の一歩（1 日 1 回、当日のみ取り消し、30 字メモ）、転ぶ・起き上がり・台座の金の筋 | 節目の演出（見た目は 7・21・50・100 で変わる。共有の促しは節目の日にカードを出すだけ）、通知 |
| Android 小ウィジェット（0 時更新）、iOS WidgetKit のコード（Xcode で組み込む） | iOS ロック画面の作り込み、Apple Watch |
| 共有画像 1 種（1080×1350）、評価依頼（7 日目の節目と両目の直後、各 1 回） | 共有テンプレ、年末ポスター、JSON の書き出し |
| 棚（現役・満願・納め）、両目、納める、ひと回り大きいだるま | 年での絞り込み |
| 日本語。英語の ARB キー | 英語版の仕上げ |

## 3. だるまの育ち方と七転び八起き

決まりはすべて `lib/core/rules.dart`（純関数）にあり、`test/core_test.dart` で確かめている。

| 出来事 | 決まり | コード |
| --- | --- | --- |
| 開眼 | 作成と同じ日。左右は設定（既定：左目＝向かって右） | `EyeScreen`、`EyeTrace` |
| 今日の一歩 | 1 日 1 回。その日のうちは取り消せる。筆の数＝step の件数 | `DarumaActions.recordStep` / `undoToday` |
| 筆の順番 | 眉（1〜6、7 で揃う）→ ひげ（8〜20、21 で揃う）→ 腹の文字の縁（22〜49、50 で金）→ 衣の模様（51〜99、100 で金彩） | `DarumaPainter` |
| 転ぶ | 最後に記録した日（なければ開眼日）が昨日より前なら転倒。模様は減らない | `Rules.isFallen` |
| 起き上がり | 転倒中の記録で 1 回。台座の金の筋＝回数 | `Rules.risesOnStep`、`recoveries` |
| 残り日数 | 本番の日の 0 時 − 今日の 0 時（日単位） | `Rules.daysLeft` |
| 両目（満願） | 本人の宣言。もう片方の目をなぞる | `DarumaActions.complete` |
| 納める | 片目のまま棚の「納め」段へ。消さない。同じ目標でひと回り大きいだるまを作れる | `DarumaActions.retire`、`/new?parent=` |

眉とひげの線は、だるまの `seed` を種にした決定的な乱数で少し揺らし、同じだるまはいつも同じ顔になる（`_Jitter`）。

## 4. 画面構成（go_router）

| パス | 画面 | 主な要素 |
| --- | --- | --- |
| `/onboarding` | 初回説明 | 3 枚（目を入れる → 毎日 1 筆 → 転んでも減らない）。最後に作成へ |
| `/` | ホーム | 現役のだるまを大きく。今日の一歩ボタン、筆の数・起き上がり回数・残り日数。転んでいれば横倒し。節目の日は共有カード |
| `/new` | だるま作成 | 腹の文字、色、本番の日（プリセットか日付）、毎日の一歩 |
| `/new/eye/:id` | 開眼 | なぞる 1 筆、開眼の演出、共有、ウィジェットの案内 |
| `/daruma/:id` | 記録 | カレンダー（記録した日・記録のない日）、ひとこと、目標の編集、満願・納める |
| `/daruma/:id/complete` | 両目 | もう片方の目をなぞる、満願の演出、共有 |
| `/shelf` | 棚 | 現役・満願・納めの 3 段、ひと回り大きいだるま |
| `/presets` | 試験日 | 同梱 JSON から今日以降のものを近い順に |
| `/settings` | 設定 | 目の左右、ウィジェットの置き方、評価、端末内カウンタ、ライセンス、プライバシー |

## 5. ウィジェット

[docs/WIDGET_SETUP.md](WIDGET_SETUP.md)。要点：Flutter が「だるまの絵（通常・転倒）」と日付の元データを書き、ウィジェット側（Kotlin / Swift）がその日の日付で残り日数と転倒を計算する。Android は 14 日分の 0 時を AlarmManager で予約、iOS は Timeline に 14 日分を入れる。記録はアプリ内でだけ。

## 6. データモデルと状態管理

Flutter、Riverpod（Notifier）、Drift、Freezed、go_router、CustomPainter、ARB（ja 先行、en キー）。サーバーもアカウントも持たず、外部 SDK は入れていない（最小版は IAP もない）。

| テーブル | 主な列 |
| --- | --- |
| `darumas` | id, name（腹の文字）, color, eye_side, created_on（開眼日）, deadline, deadline_label, daily_action, status（active / completed / retired）, completed_on, retired_on, size_rank, parent_id, seed |
| `checkins` | id, daruma_id, date（ローカル日付、daruma_id と date で一意）, kind（step / rest）, memo |
| `recoveries` | id, daruma_id, fell_after, rose_on |

- `lib/model/models.dart`：Freezed のモデル（Daruma, Checkin, Recovery, NewDaruma, DarumaDetail, DarumaLook）。`DarumaDetail.lookOn(today)` が描画の仕様 `DarumaLook` を作り、ホーム・ウィジェット・共有画像が同じものを描く
- `lib/data/database.dart`：Drift のテーブルと `AppDatabase`（`database.g.dart` は生成物。`dart run build_runner build`）
- `lib/data/repository.dart`：`DarumaRepository`（Drift 版と、テスト・Web 撮影用のメモリ版）
- `lib/state/providers.dart`：`todayProvider`（0 時に進む）、`activeDarumaProvider`、`shelfProvider`、`darumaDetailProvider`、`settingsProvider`
- `lib/state/actions.dart`：`DarumaActions`（作る、記録、取り消し、満願、納める、編集）。記録のあとは必ずウィジェットを書き直す
- `lib/services/`：`widget_sync.dart`（home_widget）、`share.dart`（share_plus）、`share_image.dart`（共有画像を Canvas で描く）、`review.dart`（in_app_review）

### 共有パッケージの窓口

ookura_settings の代わりに `SettingsStore`（`lib/state/settings.dart`、SharedPreferences）。ookura_iap・ookura_streak（休み券）は最小版で使わない。ookura_design・ookura_a11y は `lib/ui/theme.dart` と各画面の Semantics で代える。差し替えるときは `main.dart` の `ProviderScope` の overrides を変える。

## 7. 計測と判定

端末内カウンタだけ（`Counters`：created, opened, steps, rises, undo, completed, retired, shares, review_requests, widget_hints）。設定画面の「開発者へ送る」で任意に写すだけで、自動送信はしない。判定はストアのコンソールの数字で行う（[docs/STORE_RELEASE.md](STORE_RELEASE.md) の 3）。

## 8. 守っていること

- 配信中の「メクマデ 日めくりカウントダウン」と画面・文言・ストア説明を似せない。主役はだるまと毎日の記録で、残り日数は従
- 「高崎だるま」など地域団体商標の名前を使わない。眉は鶴、ひげは亀という特徴を、形を写さず自前の線で表す
- ご利益や効能をうたわない。目入れは一般的な風習として説明する（設定画面の文）
- 画像素材を持たない（だるまは CustomPainter）。アイコン・スプラッシュは SVG から生成

## 9. 試験日プリセットの確認元（2026-11-04 に各公式ページで確認）

| 試験 | 日付 | 確認元 |
| --- | --- | --- |
| 大学入学共通テスト 2027（本試験） | 2027-01-16（〜17） | https://www.dnc.ac.jp/kyotsu/shiken_jouhou/r9/ |
| 共通テスト 2027 追・再試験 | 2027-01-23（〜24） | 同上 |
| 英検 2026 年度 第 3 回 一次（本会場） | 2027-01-24 | https://www.eiken.or.jp/eiken/schedule/2026-examinee.html |
| 日商簿記 第 174 回 / 第 175 回 統一試験 | 2026-11-15 / 2027-02-28 | https://www.kentei.ne.jp/calendar_2026 |
| FP 技能検定 1 級 学科（きんざい） | 2027-01-24 | https://products.kinzai.or.jp/exam/exam-schedule/ |
| TOEIC L&R 公開テスト | 2026-12-19、2027-01-10、01-24、02-14、03-06、03-14 | https://www.iibc-global.org/toeic/test/lr/guide01/schedule.html |

FP 2 級・3 級は CBT（期間制）なので入れていない。都道府県別の公立高校入試は判定後に入れる。
