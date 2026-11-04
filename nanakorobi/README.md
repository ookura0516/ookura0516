# ナナコロビ

だるまに目を入れて、目標を始める。七転び八起きの目標帳。

目標ごとにだるまを1体持ち、指で片目を入れて「開眼」します。毎日の一歩を1タップで記録するとだるまに模様が1筆ずつ入り、記録のない日は転びますが模様は減りません。次の記録で起き上がって台座に金の筋が1本増えます。受験生向けに、試験日までの残り日数をホーム画面のウィジェットに出します。サーバーもアカウントも広告もありません。

- 設計：[docs/DESIGN.md](docs/DESIGN.md)（元の設計書と検証は Claude Docs）
- ストアに出す手順：[docs/STORE_RELEASE.md](docs/STORE_RELEASE.md)
- ウィジェットの組み込み：[docs/WIDGET_SETUP.md](docs/WIDGET_SETUP.md)
- ストア素材と掲載文：[store/README.md](store/README.md)、[store/listing_ja.md](store/listing_ja.md)
- プライバシーポリシー：[docs/PRIVACY_POLICY.md](docs/PRIVACY_POLICY.md)

## 動かす

```bash
flutter pub get
```

```bash
dart run build_runner build --delete-conflicting-outputs
```

```bash
flutter test
```

```bash
flutter run
```

生成物（`*.g.dart`、`*.freezed.dart`、`lib/l10n/app_localizations*.dart`）はリポジトリに入れてあるので、`build_runner` は型を変えたときだけで足ります。

## 状態

| 項目 | 状態 |
| --- | --- |
| コアロジック（日付の境界、転倒、起き上がり、筆の数、節目、残り日数） | できた。`test/core_test.dart` |
| DB（Drift）とメモリ版のリポジトリ | できた。`test/repository_test.dart` |
| だるまの描画（色、腹の文字、筆の順、金の筋、目、転倒、揺らぎ） | できた。`test/golden_painter_test.dart`（`--update-goldens` で絵を出せる） |
| 画面：初回説明 → 作成 → 開眼 → ホーム → 記録 → 両目 → 棚、試験日、設定 | できた。`test/flow_test.dart` で画面から通しで確認 |
| 試験日プリセット（共通テスト、英検、簿記、FP1級、TOEIC） | できた。公式ページで確認した日程だけ |
| 共有画像（1080×1350）、評価依頼 | コードはできた。実機では未確認 |
| Android ウィジェット（2×2、0時更新） | コードはできた。ビルドは GitHub Actions で確かめる。実機は未確認 |
| iOS ウィジェット（WidgetKit、ロック画面） | Swift と Xcode のターゲット（`tool/add_ios_widget_target.py`）はできた。ビルドは GitHub Actions で確かめる。実機は未確認（[docs/WIDGET_SETUP.md](docs/WIDGET_SETUP.md)） |
| CI（テスト、Android・iOS のビルド、ストアへのアップロード） | できた（`.github/workflows/nanakorobi.yml`。keshiin と同じ形） |
| アイコン・スプラッシュ・ストア素材・掲載文 | できた（[store/README.md](store/README.md)）。スクリーンショットは Web で撮ったもので、実機の画面ではない |
| プラス（買い切り）、休み券、通知、英語版 | まだ（2週間の判定後。[docs/STORE_RELEASE.md](docs/STORE_RELEASE.md) の 4） |
| 共有パッケージ（ookura_settings など）の組み込み | まだ（非公開パッケージのため、窓口だけ切って仮実装） |
| 実機での確認、ストアへの提出 | まだ |
