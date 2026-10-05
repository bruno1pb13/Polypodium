import 'package:flutter/painting.dart';
import 'package:flutter_test/flutter_test.dart';

/// Renders the next pumps as if the user had picked [factor] as the system
/// font scale. Overflows show up as test failures on their own.
void setTextScale(WidgetTester tester, double factor) {
  tester.platformDispatcher.textScaleFactorTestValue = factor;
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
}

/// Checks the tap target and labelling guidelines on what is on screen.
Future<void> expectTapTargetGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
}

/// Text contrast guideline (WCAG AA: 4.5:1, 3:1 for large text).
///
/// The glass screens draw white text over `background.png`, which is mostly
/// transparent, so what shows through is the theme surface: near white in
/// the light theme, where white text can't meet the ratio without changing
/// the design. Screens using that style are checked with `AppTheme.dark`.
Future<void> expectReadableText(WidgetTester tester) =>
    expectLater(tester, meetsGuideline(textContrastGuideline));

/// Whether the leaf illustration of `background.png` gets drawn depends on
/// an earlier test having decoded it already. Call before pumping a screen
/// whose contrast is checked so the result doesn't depend on test order.
void clearImageCache() => PaintingBinding.instance.imageCache
  ..clear()
  ..clearLiveImages();

/// Matches semantics labels that still contain an emoji, i.e. a screen reader
/// would read out the emoji's Unicode name.
final emojiLabel =
    RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);
