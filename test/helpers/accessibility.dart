import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/theme/app_theme.dart';

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

/// Both app themes, for checks that have to hold in light and dark.
final appThemes = [('light', AppTheme.light), ('dark', AppTheme.dark)];

/// Text contrast guideline (WCAG AA: 4.5:1, 3:1 for large text).
///
/// The glass screens draw over `background.png`, which is mostly transparent,
/// so what shows through is the theme surface; their foregrounds come from
/// [GlassColors] so they contrast with it in either theme.
Future<void> expectReadableText(WidgetTester tester) =>
    expectLater(tester, meetsGuideline(textContrastGuideline));

/// Decodes `background.png` for real and repaints, so the contrast check
/// sees the leaf illustration as a device shows it. Without this, whether it
/// gets drawn depends on an earlier test having decoded it already.
Future<void> paintBackground(WidgetTester tester) async {
  await tester.runAsync(() => precacheImage(
        const AssetImage('assets/images/background.png'),
        tester.element(find.byType(Scaffold).first),
      ));
  await tester.pumpAndSettle();
}

/// Matches semantics labels that still contain an emoji, i.e. a screen reader
/// would read out the emoji's Unicode name.
final emojiLabel =
    RegExp(r'[\u{1F300}-\u{1FAFF}\u{2600}-\u{27BF}]', unicode: true);
