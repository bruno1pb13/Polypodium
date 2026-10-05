import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Foreground and glass colours for the screens drawn over the background
/// image.
///
/// The dark values are the original white-on-dark glass look. In the light
/// theme what shows through the (mostly transparent) background is a near
/// white surface, so foregrounds switch to a dark ink, glass panes become
/// light and the darkening scrims and text shadows turn light or go away.
@immutable
class GlassColors extends ThemeExtension<GlassColors> {
  const GlassColors({
    required this.fg,
    required this.fgMuted,
    required this.fgSubtle,
    required this.fgFaint,
    required this.outline,
    required this.divider,
    required this.glassFill,
    required this.glassBorder,
    required this.danger,
    required this.warning,
    required this.sheet,
    required this.menu,
    required this.tintBase,
    required this.scrimBase,
    required this.scrimStrength,
    required this.minTextAlpha,
    required this.castsShadows,
  });

  static const _ink = Color(0xFF1B2A1F);

  static const dark = GlassColors(
    fg: Colors.white,
    fgMuted: Colors.white70,
    fgSubtle: Colors.white60,
    fgFaint: Colors.white54,
    outline: Colors.white24,
    divider: Colors.white10,
    glassFill: Color.from(alpha: 0.35, red: 0, green: 0, blue: 0),
    glassBorder: Color.from(alpha: 0.1, red: 1, green: 1, blue: 1),
    danger: Colors.redAccent,
    warning: Colors.orangeAccent,
    sheet: Color(0xFF1A1A1A),
    menu: Color(0xFF1E1E1E),
    tintBase: Colors.white,
    scrimBase: Colors.black,
    scrimStrength: 1,
    minTextAlpha: 0,
    castsShadows: true,
  );

  static const light = GlassColors(
    fg: _ink,
    fgMuted: Color(0xCC1B2A1F), // 0.80
    fgSubtle: Color(0xB81B2A1F), // 0.72
    fgFaint: Color(0xAD1B2A1F), // 0.68
    outline: Color(0x521B2A1F), // 0.32
    divider: Color(0x1F1B2A1F), // 0.12
    glassFill: Color(0x9EFFFFFF), // white, 0.62
    glassBorder: Color(0x241B2A1F), // 0.14
    danger: Color(0xFFB3261E),
    warning: Color(0xFFB45309),
    sheet: Color(0xFFF4F7F1),
    menu: Colors.white,
    tintBase: _ink,
    scrimBase: Colors.white,
    scrimStrength: 1.6,
    minTextAlpha: 0.68,
    castsShadows: false,
  );

  /// Primary text and icons (white in dark).
  final Color fg;

  /// Secondary text (white70 in dark).
  final Color fgMuted;

  /// Tertiary text and icons (white60 in dark).
  final Color fgSubtle;

  /// Least prominent text that still has to be read (white54 in dark).
  final Color fgFaint;

  /// Borders of inputs, chips and outlined buttons (white24 in dark).
  final Color outline;

  /// Dividers inside glass cards (white10 in dark).
  final Color divider;

  /// Background of a glass card while transparency is on.
  final Color glassFill;

  /// Hairline border of a glass card while transparency is on.
  final Color glassBorder;

  /// Error accents on glass (field errors).
  final Color danger;

  /// Warning accents on glass (pending sync).
  final Color warning;

  /// Opaque background of the picker bottom sheets.
  final Color sheet;

  /// Background of dropdown menus opened from glass forms.
  final Color menu;

  /// Base of [tint]: the foreground hue used for low alpha overlays.
  final Color tintBase;

  /// Base of [scrim]: the hue that darkens (dark) or lightens (light).
  final Color scrimBase;

  /// Multiplies the alpha of [scrim] so light panes keep enough body.
  final double scrimStrength;

  /// Lowest alpha [fgAlpha] uses, so faded text stays readable.
  final double minTextAlpha;

  /// Whether [shadow] keeps the shadow colour or drops it.
  final bool castsShadows;

  /// Low alpha foreground overlay for fills, borders and decorative icons.
  Color tint(double alpha) => tintBase.withValues(alpha: alpha);

  /// Foreground text at a custom [alpha] (hints, placeholders).
  Color fgAlpha(double alpha) =>
      tintBase.withValues(alpha: math.max(alpha, minTextAlpha));

  /// Overlay behind glass content: dark in the dark theme, light otherwise.
  Color scrim(double alpha) =>
      scrimBase.withValues(alpha: math.min(alpha * scrimStrength, 1.0));

  /// [color] for text and icon shadows, which only help white foregrounds.
  Color shadow(Color color) => castsShadows ? color : Colors.transparent;

  @override
  GlassColors copyWith({
    Color? fg,
    Color? fgMuted,
    Color? fgSubtle,
    Color? fgFaint,
    Color? outline,
    Color? divider,
    Color? glassFill,
    Color? glassBorder,
    Color? danger,
    Color? warning,
    Color? sheet,
    Color? menu,
    Color? tintBase,
    Color? scrimBase,
    double? scrimStrength,
    double? minTextAlpha,
    bool? castsShadows,
  }) =>
      GlassColors(
        fg: fg ?? this.fg,
        fgMuted: fgMuted ?? this.fgMuted,
        fgSubtle: fgSubtle ?? this.fgSubtle,
        fgFaint: fgFaint ?? this.fgFaint,
        outline: outline ?? this.outline,
        divider: divider ?? this.divider,
        glassFill: glassFill ?? this.glassFill,
        glassBorder: glassBorder ?? this.glassBorder,
        danger: danger ?? this.danger,
        warning: warning ?? this.warning,
        sheet: sheet ?? this.sheet,
        menu: menu ?? this.menu,
        tintBase: tintBase ?? this.tintBase,
        scrimBase: scrimBase ?? this.scrimBase,
        scrimStrength: scrimStrength ?? this.scrimStrength,
        minTextAlpha: minTextAlpha ?? this.minTextAlpha,
        castsShadows: castsShadows ?? this.castsShadows,
      );

  @override
  GlassColors lerp(GlassColors? other, double t) {
    if (other == null) return this;
    return GlassColors(
      fg: Color.lerp(fg, other.fg, t)!,
      fgMuted: Color.lerp(fgMuted, other.fgMuted, t)!,
      fgSubtle: Color.lerp(fgSubtle, other.fgSubtle, t)!,
      fgFaint: Color.lerp(fgFaint, other.fgFaint, t)!,
      outline: Color.lerp(outline, other.outline, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      glassFill: Color.lerp(glassFill, other.glassFill, t)!,
      glassBorder: Color.lerp(glassBorder, other.glassBorder, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      menu: Color.lerp(menu, other.menu, t)!,
      tintBase: Color.lerp(tintBase, other.tintBase, t)!,
      scrimBase: Color.lerp(scrimBase, other.scrimBase, t)!,
      scrimStrength: scrimStrength + (other.scrimStrength - scrimStrength) * t,
      minTextAlpha: minTextAlpha + (other.minTextAlpha - minTextAlpha) * t,
      castsShadows: t < 0.5 ? castsShadows : other.castsShadows,
    );
  }
}

extension GlassColorsX on BuildContext {
  /// The [GlassColors] of the current theme, falling back to the defaults
  /// for its brightness when the theme doesn't register them.
  GlassColors get glass {
    final theme = Theme.of(this);
    return theme.extension<GlassColors>() ??
        (theme.brightness == Brightness.dark
            ? GlassColors.dark
            : GlassColors.light);
  }
}
