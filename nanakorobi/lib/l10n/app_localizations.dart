import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of L10n
/// returned by `L10n.of(context)`.
///
/// Applications need to include `L10n.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: L10n.localizationsDelegates,
///   supportedLocales: L10n.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the L10n.supportedLocales
/// property.
abstract class L10n {
  L10n(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static L10n of(BuildContext context) {
    return Localizations.of<L10n>(context, L10n)!;
  }

  static const LocalizationsDelegate<L10n> delegate = _L10nDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
  ];

  /// No description provided for @appName.
  ///
  /// In ja, this message translates to:
  /// **'ナナコロビ'**
  String get appName;

  /// No description provided for @tagline.
  ///
  /// In ja, this message translates to:
  /// **'だるまに目を入れて、目標を始める。'**
  String get tagline;

  /// No description provided for @onboarding1Title.
  ///
  /// In ja, this message translates to:
  /// **'だるまに目を入れて、目標を始める'**
  String get onboarding1Title;

  /// No description provided for @onboarding1Body.
  ///
  /// In ja, this message translates to:
  /// **'目標を1つ決めて、指で片目を入れます。試験日のような本番の日は、残り日数がウィジェットに出ます。'**
  String get onboarding1Body;

  /// No description provided for @onboarding2Title.
  ///
  /// In ja, this message translates to:
  /// **'毎日1タップで、模様が1筆増える'**
  String get onboarding2Title;

  /// No description provided for @onboarding2Body.
  ///
  /// In ja, this message translates to:
  /// **'今日の一歩を記録すると、だるまに眉、ひげ、金の模様が1筆ずつ入っていきます。'**
  String get onboarding2Body;

  /// No description provided for @onboarding3Title.
  ///
  /// In ja, this message translates to:
  /// **'転んでも、減らない'**
  String get onboarding3Title;

  /// No description provided for @onboarding3Body.
  ///
  /// In ja, this message translates to:
  /// **'記録のない日はだるまが転びます。模様は減りません。次の記録で起き上がり、台座に金の筋が1本増えます。七転び八起きです。'**
  String get onboarding3Body;

  /// No description provided for @onboardingNext.
  ///
  /// In ja, this message translates to:
  /// **'次へ'**
  String get onboardingNext;

  /// No description provided for @onboardingStart.
  ///
  /// In ja, this message translates to:
  /// **'だるまを作る'**
  String get onboardingStart;

  /// No description provided for @newTitle.
  ///
  /// In ja, this message translates to:
  /// **'だるまを作る'**
  String get newTitle;

  /// No description provided for @nameLabel.
  ///
  /// In ja, this message translates to:
  /// **'腹の文字（2〜6字）'**
  String get nameLabel;

  /// No description provided for @nameHint.
  ///
  /// In ja, this message translates to:
  /// **'合格、必勝、英語 など'**
  String get nameHint;

  /// No description provided for @nameError.
  ///
  /// In ja, this message translates to:
  /// **'2〜6字で入れてください'**
  String get nameError;

  /// No description provided for @colorLabel.
  ///
  /// In ja, this message translates to:
  /// **'色'**
  String get colorLabel;

  /// No description provided for @colorRed.
  ///
  /// In ja, this message translates to:
  /// **'赤'**
  String get colorRed;

  /// No description provided for @colorWhite.
  ///
  /// In ja, this message translates to:
  /// **'白'**
  String get colorWhite;

  /// No description provided for @colorBlack.
  ///
  /// In ja, this message translates to:
  /// **'黒'**
  String get colorBlack;

  /// No description provided for @colorNote.
  ///
  /// In ja, this message translates to:
  /// **'赤は厄除け、白は祝い事、黒は黒字と言われます（由来は産地や店で違います）。'**
  String get colorNote;

  /// No description provided for @deadlineLabel.
  ///
  /// In ja, this message translates to:
  /// **'本番の日（任意）'**
  String get deadlineLabel;

  /// No description provided for @deadlineNone.
  ///
  /// In ja, this message translates to:
  /// **'なし'**
  String get deadlineNone;

  /// No description provided for @pickFromPresets.
  ///
  /// In ja, this message translates to:
  /// **'試験日から選ぶ'**
  String get pickFromPresets;

  /// No description provided for @pickDate.
  ///
  /// In ja, this message translates to:
  /// **'日付を選ぶ'**
  String get pickDate;

  /// No description provided for @clearDeadline.
  ///
  /// In ja, this message translates to:
  /// **'外す'**
  String get clearDeadline;

  /// No description provided for @deadlineNameLabel.
  ///
  /// In ja, this message translates to:
  /// **'本番の名前'**
  String get deadlineNameLabel;

  /// No description provided for @deadlineNameHint.
  ///
  /// In ja, this message translates to:
  /// **'共通テスト、志望校の入試 など'**
  String get deadlineNameHint;

  /// No description provided for @dailyActionLabel.
  ///
  /// In ja, this message translates to:
  /// **'毎日の一歩（任意）'**
  String get dailyActionLabel;

  /// No description provided for @dailyActionHint.
  ///
  /// In ja, this message translates to:
  /// **'英単語20個、走った、飲まなかった'**
  String get dailyActionHint;

  /// No description provided for @toEye.
  ///
  /// In ja, this message translates to:
  /// **'開眼へ'**
  String get toEye;

  /// No description provided for @activeExistsTitle.
  ///
  /// In ja, this message translates to:
  /// **'現役のだるまは1体まで'**
  String get activeExistsTitle;

  /// No description provided for @activeExistsBody.
  ///
  /// In ja, this message translates to:
  /// **'いまのだるまを満願にするか納めると、次のだるまを作れます。'**
  String get activeExistsBody;

  /// No description provided for @eyeTitle.
  ///
  /// In ja, this message translates to:
  /// **'開眼'**
  String get eyeTitle;

  /// No description provided for @eyeInstructionLeft.
  ///
  /// In ja, this message translates to:
  /// **'向かって右の目を、指でなぞって入れます'**
  String get eyeInstructionLeft;

  /// No description provided for @eyeInstructionRight.
  ///
  /// In ja, this message translates to:
  /// **'向かって左の目を、指でなぞって入れます'**
  String get eyeInstructionRight;

  /// No description provided for @eyeDone.
  ///
  /// In ja, this message translates to:
  /// **'開眼。今日から始まります。'**
  String get eyeDone;

  /// No description provided for @eyeShare.
  ///
  /// In ja, this message translates to:
  /// **'共有する'**
  String get eyeShare;

  /// No description provided for @eyeWidgetHint.
  ///
  /// In ja, this message translates to:
  /// **'ウィジェットを置く'**
  String get eyeWidgetHint;

  /// No description provided for @eyeStart.
  ///
  /// In ja, this message translates to:
  /// **'はじめる'**
  String get eyeStart;

  /// No description provided for @widgetHintTitle.
  ///
  /// In ja, this message translates to:
  /// **'ウィジェットの置き方'**
  String get widgetHintTitle;

  /// No description provided for @widgetHintAndroid.
  ///
  /// In ja, this message translates to:
  /// **'ホーム画面を長押し →「ウィジェット」→ ナナコロビ を選びます。残り日数は毎日0時に進みます。'**
  String get widgetHintAndroid;

  /// No description provided for @widgetHintIos.
  ///
  /// In ja, this message translates to:
  /// **'ホーム画面を長押し →「＋」→ ナナコロビ を選びます。'**
  String get widgetHintIos;

  /// No description provided for @ok.
  ///
  /// In ja, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @homeToday.
  ///
  /// In ja, this message translates to:
  /// **'今日の一歩'**
  String get homeToday;

  /// No description provided for @homeDoneToday.
  ///
  /// In ja, this message translates to:
  /// **'今日の一歩、済み'**
  String get homeDoneToday;

  /// No description provided for @homeUndo.
  ///
  /// In ja, this message translates to:
  /// **'取り消す'**
  String get homeUndo;

  /// No description provided for @homeMemoHint.
  ///
  /// In ja, this message translates to:
  /// **'ひとこと（30字まで）'**
  String get homeMemoHint;

  /// No description provided for @homeMemoSave.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get homeMemoSave;

  /// No description provided for @homeBrushes.
  ///
  /// In ja, this message translates to:
  /// **'筆 {n}本'**
  String homeBrushes(int n);

  /// No description provided for @homeRises.
  ///
  /// In ja, this message translates to:
  /// **'起き上がり {n}回'**
  String homeRises(int n);

  /// No description provided for @homeDaysSince.
  ///
  /// In ja, this message translates to:
  /// **'開眼から {n}日目'**
  String homeDaysSince(int n);

  /// No description provided for @homeDaysLeft.
  ///
  /// In ja, this message translates to:
  /// **'{label}まで あと{n}日'**
  String homeDaysLeft(String label, int n);

  /// No description provided for @homeDaysLeftToday.
  ///
  /// In ja, this message translates to:
  /// **'{label}は今日'**
  String homeDaysLeftToday(String label);

  /// No description provided for @homeDaysLeftPassed.
  ///
  /// In ja, this message translates to:
  /// **'{label}から {n}日'**
  String homeDaysLeftPassed(String label, int n);

  /// No description provided for @homeDeadlineDefault.
  ///
  /// In ja, this message translates to:
  /// **'本番'**
  String get homeDeadlineDefault;

  /// No description provided for @homeFallen.
  ///
  /// In ja, this message translates to:
  /// **'転んでいます。今日の一歩で起き上がります。'**
  String get homeFallen;

  /// No description provided for @homeRose.
  ///
  /// In ja, this message translates to:
  /// **'起き上がった。台座に金の筋が1本増えました。'**
  String get homeRose;

  /// No description provided for @homeStepRecorded.
  ///
  /// In ja, this message translates to:
  /// **'1筆、入りました。'**
  String get homeStepRecorded;

  /// No description provided for @homeMilestone7.
  ///
  /// In ja, this message translates to:
  /// **'7日目。眉が揃いました。'**
  String get homeMilestone7;

  /// No description provided for @homeMilestone21.
  ///
  /// In ja, this message translates to:
  /// **'21日目。ひげが揃いました。'**
  String get homeMilestone21;

  /// No description provided for @homeMilestone50.
  ///
  /// In ja, this message translates to:
  /// **'50日目。腹の文字が金になりました。'**
  String get homeMilestone50;

  /// No description provided for @homeMilestone100.
  ///
  /// In ja, this message translates to:
  /// **'100日目。衣に金彩が入りました。'**
  String get homeMilestone100;

  /// No description provided for @homeShareMilestone.
  ///
  /// In ja, this message translates to:
  /// **'節目を共有する'**
  String get homeShareMilestone;

  /// No description provided for @homeRecords.
  ///
  /// In ja, this message translates to:
  /// **'記録'**
  String get homeRecords;

  /// No description provided for @homeNoDaruma.
  ///
  /// In ja, this message translates to:
  /// **'だるまがいません'**
  String get homeNoDaruma;

  /// No description provided for @homeCreate.
  ///
  /// In ja, this message translates to:
  /// **'だるまを作る'**
  String get homeCreate;

  /// No description provided for @homeShelf.
  ///
  /// In ja, this message translates to:
  /// **'棚'**
  String get homeShelf;

  /// No description provided for @homeSettings.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get homeSettings;

  /// No description provided for @detailTitle.
  ///
  /// In ja, this message translates to:
  /// **'記録'**
  String get detailTitle;

  /// No description provided for @detailDeadline.
  ///
  /// In ja, this message translates to:
  /// **'本番の日'**
  String get detailDeadline;

  /// No description provided for @detailDailyAction.
  ///
  /// In ja, this message translates to:
  /// **'毎日の一歩'**
  String get detailDailyAction;

  /// No description provided for @detailEdit.
  ///
  /// In ja, this message translates to:
  /// **'目標を編集'**
  String get detailEdit;

  /// No description provided for @detailComplete.
  ///
  /// In ja, this message translates to:
  /// **'両目を入れる（満願）'**
  String get detailComplete;

  /// No description provided for @detailRetire.
  ///
  /// In ja, this message translates to:
  /// **'納める'**
  String get detailRetire;

  /// No description provided for @detailMemos.
  ///
  /// In ja, this message translates to:
  /// **'ひとこと'**
  String get detailMemos;

  /// No description provided for @retireConfirmTitle.
  ///
  /// In ja, this message translates to:
  /// **'納めますか？'**
  String get retireConfirmTitle;

  /// No description provided for @retireConfirmBody.
  ///
  /// In ja, this message translates to:
  /// **'片目のまま棚に残ります。消えません。同じ目標で、ひと回り大きいだるまをまた作れます。'**
  String get retireConfirmBody;

  /// No description provided for @retire.
  ///
  /// In ja, this message translates to:
  /// **'納める'**
  String get retire;

  /// No description provided for @cancel.
  ///
  /// In ja, this message translates to:
  /// **'キャンセル'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In ja, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @calendarStep.
  ///
  /// In ja, this message translates to:
  /// **'記録した日'**
  String get calendarStep;

  /// No description provided for @calendarMissed.
  ///
  /// In ja, this message translates to:
  /// **'記録のない日'**
  String get calendarMissed;

  /// No description provided for @monthTitle.
  ///
  /// In ja, this message translates to:
  /// **'{y}年{m}月'**
  String monthTitle(int y, int m);

  /// No description provided for @completeTitle.
  ///
  /// In ja, this message translates to:
  /// **'満願'**
  String get completeTitle;

  /// No description provided for @completeInstruction.
  ///
  /// In ja, this message translates to:
  /// **'もう片方の目を、指でなぞって入れます'**
  String get completeInstruction;

  /// No description provided for @completeDone.
  ///
  /// In ja, this message translates to:
  /// **'満願。おめでとうございます。'**
  String get completeDone;

  /// No description provided for @completeShare.
  ///
  /// In ja, this message translates to:
  /// **'共有する'**
  String get completeShare;

  /// No description provided for @toShelf.
  ///
  /// In ja, this message translates to:
  /// **'棚へ'**
  String get toShelf;

  /// No description provided for @shelfTitle.
  ///
  /// In ja, this message translates to:
  /// **'棚'**
  String get shelfTitle;

  /// No description provided for @shelfActive.
  ///
  /// In ja, this message translates to:
  /// **'現役'**
  String get shelfActive;

  /// No description provided for @shelfCompleted.
  ///
  /// In ja, this message translates to:
  /// **'満願'**
  String get shelfCompleted;

  /// No description provided for @shelfRetired.
  ///
  /// In ja, this message translates to:
  /// **'納め'**
  String get shelfRetired;

  /// No description provided for @shelfEmpty.
  ///
  /// In ja, this message translates to:
  /// **'まだだるまがいません'**
  String get shelfEmpty;

  /// No description provided for @shelfNew.
  ///
  /// In ja, this message translates to:
  /// **'新しいだるまを作る'**
  String get shelfNew;

  /// No description provided for @shelfBigger.
  ///
  /// In ja, this message translates to:
  /// **'ひと回り大きいだるまで、もう一度'**
  String get shelfBigger;

  /// No description provided for @shelfOpenedOn.
  ///
  /// In ja, this message translates to:
  /// **'開眼 {date}'**
  String shelfOpenedOn(String date);

  /// No description provided for @shelfCompletedOn.
  ///
  /// In ja, this message translates to:
  /// **'満願 {date}'**
  String shelfCompletedOn(String date);

  /// No description provided for @shelfRetiredOn.
  ///
  /// In ja, this message translates to:
  /// **'納め {date}'**
  String shelfRetiredOn(String date);

  /// No description provided for @presetsTitle.
  ///
  /// In ja, this message translates to:
  /// **'試験日を選ぶ'**
  String get presetsTitle;

  /// No description provided for @presetsUpdated.
  ///
  /// In ja, this message translates to:
  /// **'日程は {date} に各団体の公式ページで確認したものです。変更されることがあるので、受験票や公式サイトでも確かめてください。'**
  String presetsUpdated(String date);

  /// No description provided for @presetsDaysLeft.
  ///
  /// In ja, this message translates to:
  /// **'あと{n}日'**
  String presetsDaysLeft(int n);

  /// No description provided for @presetsEmpty.
  ///
  /// In ja, this message translates to:
  /// **'これから先の試験日がありません。日付を選んで入れてください。'**
  String get presetsEmpty;

  /// No description provided for @settingsTitle.
  ///
  /// In ja, this message translates to:
  /// **'設定'**
  String get settingsTitle;

  /// No description provided for @settingsEyeSide.
  ///
  /// In ja, this message translates to:
  /// **'最初に入れる目'**
  String get settingsEyeSide;

  /// No description provided for @eyeSideLeft.
  ///
  /// In ja, this message translates to:
  /// **'左目（向かって右）'**
  String get eyeSideLeft;

  /// No description provided for @eyeSideRight.
  ///
  /// In ja, this message translates to:
  /// **'右目（向かって左）'**
  String get eyeSideRight;

  /// No description provided for @settingsWidget.
  ///
  /// In ja, this message translates to:
  /// **'ウィジェットの置き方'**
  String get settingsWidget;

  /// No description provided for @settingsRate.
  ///
  /// In ja, this message translates to:
  /// **'このアプリを評価する'**
  String get settingsRate;

  /// No description provided for @settingsShelf.
  ///
  /// In ja, this message translates to:
  /// **'棚'**
  String get settingsShelf;

  /// No description provided for @settingsCounters.
  ///
  /// In ja, this message translates to:
  /// **'開発者へ送る（端末内の数）'**
  String get settingsCounters;

  /// No description provided for @settingsCountersBody.
  ///
  /// In ja, this message translates to:
  /// **'この数は端末の中だけにあり、自動では送られません。感想と一緒に送ってもらえると助かります。'**
  String get settingsCountersBody;

  /// No description provided for @settingsCopy.
  ///
  /// In ja, this message translates to:
  /// **'コピー'**
  String get settingsCopy;

  /// No description provided for @settingsCopied.
  ///
  /// In ja, this message translates to:
  /// **'コピーしました'**
  String get settingsCopied;

  /// No description provided for @settingsLicenses.
  ///
  /// In ja, this message translates to:
  /// **'ライセンス'**
  String get settingsLicenses;

  /// No description provided for @settingsFontLicense.
  ///
  /// In ja, this message translates to:
  /// **'毛筆フォント: Yuji Syuku（SIL Open Font License 1.1）'**
  String get settingsFontLicense;

  /// No description provided for @settingsPrivacy.
  ///
  /// In ja, this message translates to:
  /// **'プライバシー'**
  String get settingsPrivacy;

  /// No description provided for @settingsPrivacyBody.
  ///
  /// In ja, this message translates to:
  /// **'このアプリはサーバーに何も送りません。記録と設定は端末の中だけに保存されます。広告はありません。'**
  String get settingsPrivacyBody;

  /// No description provided for @settingsVersion.
  ///
  /// In ja, this message translates to:
  /// **'バージョン {v}'**
  String settingsVersion(String v);

  /// No description provided for @settingsAbout.
  ///
  /// In ja, this message translates to:
  /// **'だるまの目入れは、願いを込めて片目を入れ、叶ったらもう片方を入れる風習です。このアプリはそれを目標帳にしたもので、ご利益を約束するものではありません。'**
  String get settingsAbout;

  /// No description provided for @shareProgress.
  ///
  /// In ja, this message translates to:
  /// **'開眼から{days}日・起き上がり{rises}回'**
  String shareProgress(int days, int rises);

  /// No description provided for @shareCompletedOn.
  ///
  /// In ja, this message translates to:
  /// **'満願 {date}'**
  String shareCompletedOn(String date);

  /// No description provided for @shareTextOpen.
  ///
  /// In ja, this message translates to:
  /// **'「{name}」のだるま、開眼。'**
  String shareTextOpen(String name);

  /// No description provided for @shareTextMilestone.
  ///
  /// In ja, this message translates to:
  /// **'{days}日目。起き上がり{rises}回。'**
  String shareTextMilestone(int days, int rises);

  /// No description provided for @shareTextComplete.
  ///
  /// In ja, this message translates to:
  /// **'満願。'**
  String get shareTextComplete;

  /// No description provided for @shareUnavailable.
  ///
  /// In ja, this message translates to:
  /// **'この端末では共有できません'**
  String get shareUnavailable;
}

class _L10nDelegate extends LocalizationsDelegate<L10n> {
  const _L10nDelegate();

  @override
  Future<L10n> load(Locale locale) {
    return SynchronousFuture<L10n>(lookupL10n(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja'].contains(locale.languageCode);

  @override
  bool shouldReload(_L10nDelegate old) => false;
}

L10n lookupL10n(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return L10nEn();
    case 'ja':
      return L10nJa();
  }

  throw FlutterError(
    'L10n.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
