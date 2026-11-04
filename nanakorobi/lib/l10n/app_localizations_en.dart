// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class L10nEn extends L10n {
  L10nEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Nanakorobi';

  @override
  String get tagline => 'Paint one eye on your daruma, and begin.';

  @override
  String get onboarding1Title => 'Paint one eye, and begin';

  @override
  String get onboarding1Body =>
      'Pick one goal and paint the first eye with your finger. If it has a date, the days left show on your home screen widget.';

  @override
  String get onboarding2Title => 'One tap a day adds a brush stroke';

  @override
  String get onboarding2Body =>
      'Each day you log your step, your daruma gains eyebrows, a beard and gold patterns, one stroke at a time.';

  @override
  String get onboarding3Title => 'Fall down, lose nothing';

  @override
  String get onboarding3Body =>
      'Miss a day and the daruma tips over. The strokes stay. Your next log sets it upright and adds a gold stripe to the stand. Fall seven times, stand up eight.';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingStart => 'Make a daruma';

  @override
  String get newTitle => 'Make a daruma';

  @override
  String get nameLabel => 'Belly word (2–6 characters)';

  @override
  String get nameHint => 'PASS, WIN, RUN…';

  @override
  String get nameError => 'Use 2 to 6 characters';

  @override
  String get colorLabel => 'Color';

  @override
  String get colorRed => 'Red';

  @override
  String get colorWhite => 'White';

  @override
  String get colorBlack => 'Black';

  @override
  String get colorNote =>
      'Red wards off bad luck, white is for celebrations, black is for business (meanings vary by region).';

  @override
  String get deadlineLabel => 'The big day (optional)';

  @override
  String get deadlineNone => 'None';

  @override
  String get pickFromPresets => 'Pick an exam date';

  @override
  String get pickDate => 'Pick a date';

  @override
  String get clearDeadline => 'Clear';

  @override
  String get deadlineNameLabel => 'Name of the day';

  @override
  String get deadlineNameHint => 'Entrance exam, TOEIC…';

  @override
  String get dailyActionLabel => 'Daily step (optional)';

  @override
  String get dailyActionHint => '20 words, a run, no drink';

  @override
  String get toEye => 'Paint the eye';

  @override
  String get activeExistsTitle => 'One active daruma at a time';

  @override
  String get activeExistsBody =>
      'Complete or retire the current daruma to make a new one.';

  @override
  String get eyeTitle => 'First eye';

  @override
  String get eyeInstructionLeft =>
      'Trace the eye on the right with your finger';

  @override
  String get eyeInstructionRight =>
      'Trace the eye on the left with your finger';

  @override
  String get eyeDone => 'Eye painted. It starts today.';

  @override
  String get eyeShare => 'Share';

  @override
  String get eyeWidgetHint => 'Add the widget';

  @override
  String get eyeStart => 'Start';

  @override
  String get widgetHintTitle => 'Adding the widget';

  @override
  String get widgetHintAndroid =>
      'Long-press the home screen → Widgets → Nanakorobi. The days left advance at midnight every day.';

  @override
  String get widgetHintIos => 'Long-press the home screen → “+” → Nanakorobi.';

  @override
  String get ok => 'OK';

  @override
  String get homeToday => 'Today\'s step';

  @override
  String get homeDoneToday => 'Today\'s step is done';

  @override
  String get homeUndo => 'Undo';

  @override
  String get homeMemoHint => 'A note (up to 30 characters)';

  @override
  String get homeMemoSave => 'Save';

  @override
  String homeBrushes(int n) {
    return '$n strokes';
  }

  @override
  String homeRises(int n) {
    return 'Stood up $n times';
  }

  @override
  String homeDaysSince(int n) {
    return 'Day $n';
  }

  @override
  String homeDaysLeft(String label, int n) {
    return '$n days to $label';
  }

  @override
  String homeDaysLeftToday(String label) {
    return '$label is today';
  }

  @override
  String homeDaysLeftPassed(String label, int n) {
    return '$n days since $label';
  }

  @override
  String get homeDeadlineDefault => 'the big day';

  @override
  String get homeFallen => 'It has tipped over. Today\'s step sets it upright.';

  @override
  String get homeRose => 'Upright again. One more gold stripe on the stand.';

  @override
  String get homeStepRecorded => 'One stroke added.';

  @override
  String get homeMilestone7 => 'Day 7. The eyebrows are complete.';

  @override
  String get homeMilestone21 => 'Day 21. The beard is complete.';

  @override
  String get homeMilestone50 => 'Day 50. The belly word turned gold.';

  @override
  String get homeMilestone100 => 'Day 100. Gold on the robe.';

  @override
  String get homeShareMilestone => 'Share this milestone';

  @override
  String get homeRecords => 'Log';

  @override
  String get homeNoDaruma => 'No daruma yet';

  @override
  String get homeCreate => 'Make a daruma';

  @override
  String get homeShelf => 'Shelf';

  @override
  String get homeSettings => 'Settings';

  @override
  String get detailTitle => 'Log';

  @override
  String get detailDeadline => 'The big day';

  @override
  String get detailDailyAction => 'Daily step';

  @override
  String get detailEdit => 'Edit goal';

  @override
  String get detailComplete => 'Paint the second eye';

  @override
  String get detailRetire => 'Retire';

  @override
  String get detailMemos => 'Notes';

  @override
  String get retireConfirmTitle => 'Retire this daruma?';

  @override
  String get retireConfirmBody =>
      'It stays on the shelf with one eye. Nothing is deleted. You can start again with a bigger daruma for the same goal.';

  @override
  String get retire => 'Retire';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get calendarStep => 'Logged';

  @override
  String get calendarMissed => 'Missed';

  @override
  String monthTitle(int y, int m) {
    return '$m/$y';
  }

  @override
  String get completeTitle => 'Second eye';

  @override
  String get completeInstruction => 'Trace the other eye with your finger';

  @override
  String get completeDone => 'Both eyes painted. Congratulations.';

  @override
  String get completeShare => 'Share';

  @override
  String get toShelf => 'To the shelf';

  @override
  String get shelfTitle => 'Shelf';

  @override
  String get shelfActive => 'Active';

  @override
  String get shelfCompleted => 'Completed';

  @override
  String get shelfRetired => 'Retired';

  @override
  String get shelfEmpty => 'No daruma yet';

  @override
  String get shelfNew => 'Make a new daruma';

  @override
  String get shelfBigger => 'Try again with a bigger daruma';

  @override
  String shelfOpenedOn(String date) {
    return 'Started $date';
  }

  @override
  String shelfCompletedOn(String date) {
    return 'Completed $date';
  }

  @override
  String shelfRetiredOn(String date) {
    return 'Retired $date';
  }

  @override
  String get presetsTitle => 'Pick an exam date';

  @override
  String presetsUpdated(String date) {
    return 'Dates checked on $date on each organizer\'s official site. They can change, so check your admission ticket too.';
  }

  @override
  String presetsDaysLeft(int n) {
    return '$n days';
  }

  @override
  String get presetsEmpty => 'No upcoming exam dates. Pick a date instead.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEyeSide => 'Eye to paint first';

  @override
  String get eyeSideLeft => 'Left eye (on the right as you look)';

  @override
  String get eyeSideRight => 'Right eye (on the left as you look)';

  @override
  String get settingsWidget => 'Adding the widget';

  @override
  String get settingsRate => 'Rate this app';

  @override
  String get settingsShelf => 'Shelf';

  @override
  String get settingsCounters => 'Send to the developer (on-device counts)';

  @override
  String get settingsCountersBody =>
      'These counts stay on your device and are never sent automatically.';

  @override
  String get settingsCopy => 'Copy';

  @override
  String get settingsCopied => 'Copied';

  @override
  String get settingsLicenses => 'Licenses';

  @override
  String get settingsFontLicense =>
      'Brush font: Yuji Syuku (SIL Open Font License 1.1)';

  @override
  String get settingsPrivacy => 'Privacy';

  @override
  String get settingsPrivacyBody =>
      'This app sends nothing to a server. Your log and settings stay on the device. No ads.';

  @override
  String settingsVersion(String v) {
    return 'Version $v';
  }

  @override
  String get settingsAbout =>
      'Painting a daruma\'s eyes is a Japanese custom: one eye when you make a wish, the other when it comes true. This app turns it into a goal journal. It promises no luck.';

  @override
  String shareProgress(int days, int rises) {
    return 'Day $days · stood up $rises times';
  }

  @override
  String shareCompletedOn(String date) {
    return 'Completed $date';
  }

  @override
  String shareTextOpen(String name) {
    return 'My “$name” daruma has its first eye.';
  }

  @override
  String shareTextMilestone(int days, int rises) {
    return 'Day $days. Stood up $rises times.';
  }

  @override
  String get shareTextComplete => 'Both eyes painted.';

  @override
  String get shareUnavailable => 'Sharing is not available on this device';
}
