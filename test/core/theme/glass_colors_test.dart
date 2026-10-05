import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/theme/app_theme.dart';

double _contrast(Color a, Color b) {
  final la = a.computeLuminance(), lb = b.computeLuminance();
  final (hi, lo) = la > lb ? (la, lb) : (lb, la);
  return (hi + 0.05) / (lo + 0.05);
}

void main() {
  test('both app themes register their glass colors', () {
    expect(AppTheme.light.extension<GlassColors>(), GlassColors.light);
    expect(AppTheme.dark.extension<GlassColors>(), GlassColors.dark);
  });

  test('dark keeps the original white-on-dark values', () {
    const glass = GlassColors.dark;
    expect(glass.fg, Colors.white);
    expect(glass.fgMuted, Colors.white70);
    expect(glass.fgSubtle, Colors.white60);
    expect(glass.fgFaint, Colors.white54);
    expect(glass.outline, Colors.white24);
    expect(glass.divider, Colors.white10);
    expect(glass.glassFill, Colors.black.withValues(alpha: 0.35));
    expect(glass.glassBorder, Colors.white.withValues(alpha: 0.1));
    expect(glass.tint(0.05), Colors.white.withValues(alpha: 0.05));
    expect(glass.fgAlpha(0.3), Colors.white.withValues(alpha: 0.3));
    expect(glass.scrim(0.5), Colors.black.withValues(alpha: 0.5));
    expect(glass.shadow(Colors.black45), Colors.black45);
  });

  test('light foregrounds are readable over the light surface', () {
    const glass = GlassColors.light;
    final surface = AppTheme.light.colorScheme.surface;
    // What a glass card shows: its light fill over the surface.
    final card = Color.alphaBlend(glass.glassFill, surface);

    for (final background in [surface, card]) {
      for (final fg in [
        glass.fg,
        glass.fgMuted,
        glass.fgSubtle,
        glass.fgFaint,
        glass.fgAlpha(0.3),
      ]) {
        expect(_contrast(Color.alphaBlend(fg, background), background),
            greaterThanOrEqualTo(4.5),
            reason: '$fg over $background');
      }
    }
    expect(glass.shadow(Colors.black45), Colors.transparent);
  });

  testWidgets('context.glass falls back by brightness without the extension',
      (tester) async {
    late GlassColors light, dark;
    await tester.pumpWidget(MaterialApp(
      theme: ThemeData(),
      home: Builder(builder: (context) {
        light = context.glass;
        return Theme(
          data: ThemeData(brightness: Brightness.dark),
          child: Builder(builder: (context) {
            dark = context.glass;
            return const SizedBox();
          }),
        );
      }),
    ));
    expect(light, GlassColors.light);
    expect(dark, GlassColors.dark);
  });
}
