import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../core/local_date.dart';
import '../../l10n/generated/app_localizations.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);

  /// 2027年1月16日 / Jan 16, 2027
  String formatDate(LocalDate d) =>
      DateFormat.yMMMd(Localizations.localeOf(this).toString()).format(d.toDateTime());

  /// 1/16
  String formatShortDate(LocalDate d) =>
      DateFormat.Md(Localizations.localeOf(this).toString()).format(d.toDateTime());
}
