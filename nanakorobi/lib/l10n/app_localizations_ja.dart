// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class L10nJa extends L10n {
  L10nJa([String locale = 'ja']) : super(locale);

  @override
  String get appName => 'ナナコロビ';

  @override
  String get tagline => 'だるまに目を入れて、目標を始める。';

  @override
  String get onboarding1Title => 'だるまに目を入れて、目標を始める';

  @override
  String get onboarding1Body =>
      '目標を1つ決めて、指で片目を入れます。試験日のような本番の日は、残り日数がウィジェットに出ます。';

  @override
  String get onboarding2Title => '毎日1タップで、模様が1筆増える';

  @override
  String get onboarding2Body => '今日の一歩を記録すると、だるまに眉、ひげ、金の模様が1筆ずつ入っていきます。';

  @override
  String get onboarding3Title => '転んでも、減らない';

  @override
  String get onboarding3Body =>
      '記録のない日はだるまが転びます。模様は減りません。次の記録で起き上がり、台座に金の筋が1本増えます。七転び八起きです。';

  @override
  String get onboardingNext => '次へ';

  @override
  String get onboardingStart => 'だるまを作る';

  @override
  String get newTitle => 'だるまを作る';

  @override
  String get nameLabel => '腹の文字（2〜6字）';

  @override
  String get nameHint => '合格、必勝、英語 など';

  @override
  String get nameError => '2〜6字で入れてください';

  @override
  String get colorLabel => '色';

  @override
  String get colorRed => '赤';

  @override
  String get colorWhite => '白';

  @override
  String get colorBlack => '黒';

  @override
  String get colorNote => '赤は厄除け、白は祝い事、黒は黒字と言われます（由来は産地や店で違います）。';

  @override
  String get deadlineLabel => '本番の日（任意）';

  @override
  String get deadlineNone => 'なし';

  @override
  String get pickFromPresets => '試験日から選ぶ';

  @override
  String get pickDate => '日付を選ぶ';

  @override
  String get clearDeadline => '外す';

  @override
  String get deadlineNameLabel => '本番の名前';

  @override
  String get deadlineNameHint => '共通テスト、志望校の入試 など';

  @override
  String get dailyActionLabel => '毎日の一歩（任意）';

  @override
  String get dailyActionHint => '英単語20個、走った、飲まなかった';

  @override
  String get toEye => '開眼へ';

  @override
  String get activeExistsTitle => '現役のだるまは1体まで';

  @override
  String get activeExistsBody => 'いまのだるまを満願にするか納めると、次のだるまを作れます。';

  @override
  String get eyeTitle => '開眼';

  @override
  String get eyeInstructionLeft => '向かって右の目を、指でなぞって入れます';

  @override
  String get eyeInstructionRight => '向かって左の目を、指でなぞって入れます';

  @override
  String get eyeDone => '開眼。今日から始まります。';

  @override
  String get eyeShare => '共有する';

  @override
  String get eyeWidgetHint => 'ウィジェットを置く';

  @override
  String get eyeStart => 'はじめる';

  @override
  String get widgetHintTitle => 'ウィジェットの置き方';

  @override
  String get widgetHintAndroid =>
      'ホーム画面を長押し →「ウィジェット」→ ナナコロビ を選びます。残り日数は毎日0時に進みます。';

  @override
  String get widgetHintIos => 'ホーム画面を長押し →「＋」→ ナナコロビ を選びます。';

  @override
  String get ok => 'OK';

  @override
  String get homeToday => '今日の一歩';

  @override
  String get homeDoneToday => '今日の一歩、済み';

  @override
  String get homeUndo => '取り消す';

  @override
  String get homeMemoHint => 'ひとこと（30字まで）';

  @override
  String get homeMemoSave => '保存';

  @override
  String homeBrushes(int n) {
    return '筆 $n本';
  }

  @override
  String homeRises(int n) {
    return '起き上がり $n回';
  }

  @override
  String homeDaysSince(int n) {
    return '開眼から $n日目';
  }

  @override
  String homeDaysLeft(String label, int n) {
    return '$labelまで あと$n日';
  }

  @override
  String homeDaysLeftToday(String label) {
    return '$labelは今日';
  }

  @override
  String homeDaysLeftPassed(String label, int n) {
    return '$labelから $n日';
  }

  @override
  String get homeDeadlineDefault => '本番';

  @override
  String get homeFallen => '転んでいます。今日の一歩で起き上がります。';

  @override
  String get homeRose => '起き上がった。台座に金の筋が1本増えました。';

  @override
  String get homeStepRecorded => '1筆、入りました。';

  @override
  String get homeMilestone7 => '7日目。眉が揃いました。';

  @override
  String get homeMilestone21 => '21日目。ひげが揃いました。';

  @override
  String get homeMilestone50 => '50日目。腹の文字が金になりました。';

  @override
  String get homeMilestone100 => '100日目。衣に金彩が入りました。';

  @override
  String get homeShareMilestone => '節目を共有する';

  @override
  String get homeRecords => '記録';

  @override
  String get homeNoDaruma => 'だるまがいません';

  @override
  String get homeCreate => 'だるまを作る';

  @override
  String get homeShelf => '棚';

  @override
  String get homeSettings => '設定';

  @override
  String get detailTitle => '記録';

  @override
  String get detailDeadline => '本番の日';

  @override
  String get detailDailyAction => '毎日の一歩';

  @override
  String get detailEdit => '目標を編集';

  @override
  String get detailComplete => '両目を入れる（満願）';

  @override
  String get detailRetire => '納める';

  @override
  String get detailMemos => 'ひとこと';

  @override
  String get retireConfirmTitle => '納めますか？';

  @override
  String get retireConfirmBody => '片目のまま棚に残ります。消えません。同じ目標で、ひと回り大きいだるまをまた作れます。';

  @override
  String get retire => '納める';

  @override
  String get cancel => 'キャンセル';

  @override
  String get save => '保存';

  @override
  String get calendarStep => '記録した日';

  @override
  String get calendarMissed => '記録のない日';

  @override
  String monthTitle(int y, int m) {
    return '$y年$m月';
  }

  @override
  String get completeTitle => '満願';

  @override
  String get completeInstruction => 'もう片方の目を、指でなぞって入れます';

  @override
  String get completeDone => '満願。おめでとうございます。';

  @override
  String get completeShare => '共有する';

  @override
  String get toShelf => '棚へ';

  @override
  String get shelfTitle => '棚';

  @override
  String get shelfActive => '現役';

  @override
  String get shelfCompleted => '満願';

  @override
  String get shelfRetired => '納め';

  @override
  String get shelfEmpty => 'まだだるまがいません';

  @override
  String get shelfNew => '新しいだるまを作る';

  @override
  String get shelfBigger => 'ひと回り大きいだるまで、もう一度';

  @override
  String shelfOpenedOn(String date) {
    return '開眼 $date';
  }

  @override
  String shelfCompletedOn(String date) {
    return '満願 $date';
  }

  @override
  String shelfRetiredOn(String date) {
    return '納め $date';
  }

  @override
  String get presetsTitle => '試験日を選ぶ';

  @override
  String presetsUpdated(String date) {
    return '日程は $date に各団体の公式ページで確認したものです。変更されることがあるので、受験票や公式サイトでも確かめてください。';
  }

  @override
  String presetsDaysLeft(int n) {
    return 'あと$n日';
  }

  @override
  String get presetsEmpty => 'これから先の試験日がありません。日付を選んで入れてください。';

  @override
  String get settingsTitle => '設定';

  @override
  String get settingsEyeSide => '最初に入れる目';

  @override
  String get eyeSideLeft => '左目（向かって右）';

  @override
  String get eyeSideRight => '右目（向かって左）';

  @override
  String get settingsWidget => 'ウィジェットの置き方';

  @override
  String get settingsRate => 'このアプリを評価する';

  @override
  String get settingsShelf => '棚';

  @override
  String get settingsCounters => '開発者へ送る（端末内の数）';

  @override
  String get settingsCountersBody =>
      'この数は端末の中だけにあり、自動では送られません。感想と一緒に送ってもらえると助かります。';

  @override
  String get settingsCopy => 'コピー';

  @override
  String get settingsCopied => 'コピーしました';

  @override
  String get settingsLicenses => 'ライセンス';

  @override
  String get settingsFontLicense =>
      '毛筆フォント: Yuji Syuku（SIL Open Font License 1.1）';

  @override
  String get settingsPrivacy => 'プライバシー';

  @override
  String get settingsPrivacyBody =>
      'このアプリはサーバーに何も送りません。記録と設定は端末の中だけに保存されます。広告はありません。';

  @override
  String settingsVersion(String v) {
    return 'バージョン $v';
  }

  @override
  String get settingsAbout =>
      'だるまの目入れは、願いを込めて片目を入れ、叶ったらもう片方を入れる風習です。このアプリはそれを目標帳にしたもので、ご利益を約束するものではありません。';

  @override
  String shareProgress(int days, int rises) {
    return '開眼から$days日・起き上がり$rises回';
  }

  @override
  String shareCompletedOn(String date) {
    return '満願 $date';
  }

  @override
  String shareTextOpen(String name) {
    return '「$name」のだるま、開眼。';
  }

  @override
  String shareTextMilestone(int days, int rises) {
    return '$days日目。起き上がり$rises回。';
  }

  @override
  String get shareTextComplete => '満願。';

  @override
  String get shareUnavailable => 'この端末では共有できません';
}
