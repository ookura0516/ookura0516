# ストアに出すまでの手順

コードとストア素材はできています。ここに書いてあるのは、手元の Mac と各ストアの管理画面で人がやる作業です。上から順に進めてください。判定の数字と記録表は、検証ドキュメント「ナナコロビ（仮）作る前の検証」の「決定後の次の一手」にあります。

## 0. 手元で動かす

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter analyze && flutter test
```

```bash
flutter run
```

実機で確かめること（この環境では Android SDK も Xcode もなく、実機では未確認）：

- [ ] 作成 → 開眼（なぞり） → 今日の一歩 → 取り消し → 記録画面 → 両目 → 棚
- [ ] 日付を翌々日にして開くと転んでいる。記録すると起き上がって台座に金の筋
- [ ] 腹の文字が毛筆体（YujiSyuku）で出る。6字でも台座にかからない
- [ ] 共有で画像 1 枚（1080×1350）が共有シートに出る
- [ ] ウィジェット（[docs/WIDGET_SETUP.md](WIDGET_SETUP.md) の確認項目）
- [ ] 低価格端末でだるまの描画がもたつかない（転倒・起き上がりの演出）

## 1. Google Play（先に出す）

### 署名

1. 鍵を作る（既存の鍵があればそれを使う）

```bash
keytool -genkey -v -keystore ~/keys/nanakorobi-upload.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. `android/key.properties` を作る（Git には入らない）

```
storePassword=...
keyPassword=...
keyAlias=upload
storeFile=/Users/<you>/keys/nanakorobi-upload.jks
```

3. ビルドする

```bash
flutter build appbundle --release
```

`build/app/outputs/bundle/release/app-release.aab` ができる。`key.properties` がないとデバッグ鍵で署名される（Play にはアップロードできない）。

### Play Console

1. アプリを作る：名前「ナナコロビ」、既定の言語 日本語、アプリ（ゲームではない）、無料
2. **アプリの設定**
   - プライバシーポリシー：[docs/PRIVACY_POLICY.md](PRIVACY_POLICY.md) を公開 URL に置いてその URL を入れる
   - 広告：含まない
   - アプリのアクセス権：制限なし（ログインなし）
   - コンテンツのレーティング：IARC の質問にすべて「いいえ」（暴力・性的・薬物・ギャンブル・ユーザー間の交流・位置情報なし）
   - ターゲット ユーザー：13 歳以上（子ども向けには設計していない）
   - ニュースアプリ：いいえ
   - データ セーフティ：**データを収集しない、共有しない**。暗号化・削除の項目は「該当なし」。外部 SDK は入っていない
   - 政府アプリ：いいえ。金融機能：なし。健康：なし
3. **メインのストアの掲載情報**：[store/listing_ja.md](../store/listing_ja.md) のとおり。アイコン `store/icon_512.png`、フィーチャーグラフィック `store/feature_graphic.png`、スクリーンショット `store/screens/android/`
4. **製品版 → 新しいリリース**：AAB をアップロード。リリースノート（日本語）：

```
初版。だるまに片目を入れて目標を始め、毎日1タップで模様が増えます。転んでも減りません。試験日までの残り日数はホーム画面のウィジェットに。
```

5. 国：日本（必要なら全世界）。審査に出す
6. 公開されたら、[Play の検索順位の記録](#3-公開後の記録)を始める

### 自作アプリからの導線（9a）

- 受験カウントダウン（Play）の試験一覧の下と設定画面に、検証ドキュメントの文言でリンクを置く。UTM 付きリンクは [store/listing_ja.md](../store/listing_ja.md) の末尾
- 一問一答シリーズの結果画面には、最小版が公開されてから出す（iOS 版が出るまでは Android のアプリだけ）

## 2. App Store（8 日目以降）

1. Xcode で Widget Extension を足す（[docs/WIDGET_SETUP.md](WIDGET_SETUP.md)）
2. App Store Connect でアプリを作る（Bundle ID `com.ookura.nanakorobi`）。サブタイトル・プロモーションテキスト・キーワードは [store/listing_ja.md](../store/listing_ja.md)
3. App のプライバシー：**データを収集しない**
4. 年齢制限：4+
5. 審査メモ（英語）に書くこと
   - A goal journal based on the Japanese daruma custom: paint one eye to start, log once a day, paint the other eye when done. No account, no server, no ads, no in-app purchase in this version
   - The home-screen widget shows the days left; the app itself is where you log
   - The brush font (Yuji Syuku) is under the SIL Open Font License
6. `flutter build ipa --release` → Transporter または Xcode でアップロード → TestFlight → 審査
7. iOS 版が出たら、`lib/main.dart` の `InAppReviewService(appStoreId: '...')` に App Store の数字の ID を入れる（設定の「このアプリを評価する」が App Store を開くため）

## 3. 公開後の記録

毎朝、Play Console の前々日分までを検証ドキュメントの記録表に写す。

| 見る数字 | 場所 |
| --- | --- |
| インストール数（合計・検索経由） | Play Console → ストアの掲載情報の獲得 |
| 検索語別のストア訪問数と転換率 | 同上の内訳 |
| 検索順位（受験カウントダウン／だるま／合格 だるま／目標 アプリ） | Play アプリとウェブで、シークレットで毎日同じ時刻に手で確認 |
| 7 日維持率 | Play Console → ユーザーの獲得 → 維持率 |
| 送客のストア到達数 | 同「ストアの掲載情報の獲得」の UTM 別 |
| 1 日目アンインストール率、クラッシュ率 | Play Console の統計、Android vitals |

14 日目に 1 回だけ判定する（型：1 日 20 インストール、または「受験カウントダウン」で 3 位以内。副判定：7 日維持率 25%、送客タップ率 2%、「だるま」「合格 だるま」で 1 位）。

## 4. 判定後に作るもの（設計書の初版の範囲のうち、最小版で外したもの）

- プラス（買い切り ¥600、非消耗型）：現役のだるま無制限、全 12 色、季節の背景、年末の棚ポスター、共有テンプレ全種、JSON の書き出し・読み込み
- 通過点（最大 3）、休み券（月 2 枚・前日宣言）、節目の演出（21・50・100 日の共有の促し）、リマインド通知
- 試験日プリセットの全件化と jsDelivr からの更新、都道府県別の公立高校入試
- iOS のロック画面ウィジェットの作り込み、Apple Watch・Live Activity
- 英語版（ARB の en キーは入れてある）
