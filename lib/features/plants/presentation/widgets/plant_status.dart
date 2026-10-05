import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/plant_model.dart';
import '../../../../core/theme/glass_colors.dart';

/// Shared visual language for plant status: the colour says how urgent it is,
/// the emoji ([EntryType.emoji]) says what it is about. Used by the home list
/// badges and the plant detail screen so both read the same way.
enum StatusTone {
  danger(Color(0xFFDC2626), Color(0xFFFCA5A5), Color(0xFFB91C1C)),
  warning(Color(0xFFD97706), Color(0xFFFCD34D), Color(0xFF92400E)),
  positive(Color(0xFF0D9488), Color(0xFF5EEAD4), Color(0xFF115E59)),
  neutral(Color(0xFF64748B), Color(0xFFCBD5E1), Color(0xFF475569));

  const StatusTone(this.base, this.onDark, this.onLight);

  final Color base;
  final Color onDark;
  final Color onLight;

  /// Text/icon colour with enough contrast for the current surface: dark in
  /// the dark theme, light (glass or opaque) in the light theme.
  Color foreground(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? onDark : onLight;

  /// Pest/chlorosis severity (1–3, null = unknown): only severe is urgent.
  static StatusTone forSeverity(int? severity) =>
      severity == 3 ? StatusTone.danger : StatusTone.warning;
}

typedef PlantStatusBadge = ({String emoji, String label, StatusTone tone});

/// Badges for the home list, most urgent first. A plant that is no longer
/// active only shows its lifecycle status.
List<PlantStatusBadge> plantListStatuses(
  AppLocalizations l10n,
  PlantWithSpecies pws,
  PlantAlertStatus alerts,
) {
  final status = pws.plant.status;
  if (!pws.plant.isActive) {
    return [
      (
        emoji: status.emoji,
        label: status.label(l10n),
        tone: StatusTone.neutral,
      ),
    ];
  }
  final statuses = <PlantStatusBadge>[
    if (pws.needsWatering)
      (
        emoji: EntryType.irrigation.emoji,
        label: l10n.waterBadge,
        tone: StatusTone.danger,
      ),
    if (pws.needsPesticideReapplication)
      (
        emoji: EntryType.pesticide.emoji,
        label: l10n.pesticideReapplyBadge,
        tone: StatusTone.danger,
      ),
    if (alerts.hasActivePest)
      (
        emoji: EntryType.pest.emoji,
        label: l10n.pestBadge,
        tone: StatusTone.forSeverity(alerts.pestSeverity),
      ),
    if (alerts.hasActiveChlorosis)
      (
        emoji: EntryType.chlorosis.emoji,
        label: l10n.entryTypeChlorosis,
        tone: StatusTone.forSeverity(alerts.chlorosisSeverity),
      ),
    if (pws.pesticideUnderActiveControl && !pws.needsPesticideReapplication)
      (
        emoji: EntryType.pesticide.emoji,
        label: l10n.pesticideActiveControlBadge,
        tone: StatusTone.positive,
      ),
  ];
  // Stable grouping by urgency, keeping the order above within each tone.
  return [
    for (final tone in StatusTone.values)
      ...statuses.where((s) => s.tone == tone),
  ];
}

/// Compact pill: emoji + label tinted by [tone].
class PlantStatusChip extends StatelessWidget {
  final String? emoji;
  final String label;
  final StatusTone tone;

  const PlantStatusChip({
    super.key,
    this.emoji,
    required this.label,
    required this.tone,
  });

  PlantStatusChip.fromStatus(PlantStatusBadge status, {super.key})
      : emoji = status.emoji,
        label = status.label,
        tone = status.tone;

  @override
  Widget build(BuildContext context) {
    final fg = tone.foreground(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        // Over a scrim so the leaf illustration behind doesn't wash it out.
        color: Color.alphaBlend(
            tone.base.withValues(alpha: 0.18), context.glass.scrim(0.35)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: tone.base.withValues(alpha: 0.45)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // The label already says what the emoji shows.
          if (emoji != null) ...[
            ExcludeSemantics(
              child: Text(emoji!, style: const TextStyle(fontSize: 11)),
            ),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: fg,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full-width alert card for the plant detail screen, in the same glass style
/// as the other cards there, tinted by [tone].
class PlantStatusBanner extends ConsumerWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final StatusTone tone;

  const PlantStatusBanner({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.tone,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final fg = tone.foreground(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: transparent
                  ? Color.alphaBlend(tone.base.withValues(alpha: 0.22),
                      context.glass.scrim(0.3))
                  : Color.alphaBlend(tone.base.withValues(alpha: 0.12),
                      colorScheme.surfaceContainerHighest),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: tone.base.withValues(alpha: 0.45)),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: tone.base.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: ExcludeSemantics(
                    child: Text(emoji, style: const TextStyle(fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: fg,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: transparent
                              ? context.glass.fgMuted
                              : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
