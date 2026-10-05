import 'package:flutter/material.dart';

/// Chart colors resolved for the current surface. Series hues come from the
/// validated data-viz palette (light/dark steps); ink and grid follow the
/// glassmorphism or Material surface the card renders on.
class InsightPalette {
  final Color growth;
  final Color health;
  final Color water;
  final Color ink;
  final Color inkSoft;
  final Color grid;
  final Color ring;
  final Color tooltipBg;
  final Color tooltipInk;

  const InsightPalette({
    required this.growth,
    required this.health,
    required this.water,
    required this.ink,
    required this.inkSoft,
    required this.grid,
    required this.ring,
    required this.tooltipBg,
    required this.tooltipInk,
  });

  factory InsightPalette.of(BuildContext context, bool transparent) {
    final scheme = Theme.of(context).colorScheme;
    final dark = transparent || Theme.of(context).brightness == Brightness.dark;

    if (transparent) {
      return const InsightPalette(
        growth: Color(0xFF199E70),
        health: Color(0xFF9085E9),
        water: Color(0xFF3987E5),
        ink: Colors.white,
        inkSoft: Colors.white60,
        grid: Color(0x1AFFFFFF),
        ring: Color(0xFF1A1A19),
        tooltipBg: Color(0xE6262624),
        tooltipInk: Colors.white,
      );
    }

    return InsightPalette(
      growth: dark ? const Color(0xFF199E70) : const Color(0xFF1BAF7A),
      health: dark ? const Color(0xFF9085E9) : const Color(0xFF4A3AA7),
      water: dark ? const Color(0xFF3987E5) : const Color(0xFF2A78D6),
      ink: scheme.onSurfaceVariant,
      inkSoft: scheme.onSurfaceVariant.withValues(alpha: 0.7),
      grid: scheme.onSurfaceVariant.withValues(alpha: 0.12),
      ring: scheme.surfaceContainerHighest,
      tooltipBg: const Color(0xE6262624),
      tooltipInk: Colors.white,
    );
  }
}
