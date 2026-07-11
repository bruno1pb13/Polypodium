import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

export '../../l10n/app_localizations.dart';

/// Convenience accessor for the generated localizations.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

/// Localizations resolved from the device locale, for code that runs without
/// a [BuildContext] (database seeding, notifications, background isolates).
/// Falls back to English for unsupported languages.
AppLocalizations systemL10n() {
  final locale = ui.PlatformDispatcher.instance.locale;
  try {
    return lookupAppLocalizations(locale);
  } catch (_) {
    return lookupAppLocalizations(const ui.Locale('en'));
  }
}
