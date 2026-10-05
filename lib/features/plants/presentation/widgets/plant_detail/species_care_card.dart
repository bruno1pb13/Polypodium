import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/glass_colors.dart';
import '../../../../settings/presentation/providers/settings_providers.dart';
import '../../../../species/domain/species_model.dart';
import '../plant_status.dart';

/// Care sheet of the plant's species: light, humidity, pet toxicity,
/// flowering months and notes. Only the filled-in fields are shown.
class SpeciesCareCard extends ConsumerWidget {
  final SpeciesModel species;

  const SpeciesCareCard({super.key, required this.species});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final l10n = context.l10n;
    final light = species.light;
    final humidity = species.humidity;
    final notes = species.careNotes?.trim();
    final divider = Divider(color: context.glass.divider, height: 16);

    final rows = <Widget>[
      if (light != null)
        _row(context, light.emoji, l10n.lightLabel,
            _value(context, light.label(l10n), transparent), transparent),
      if (humidity != null)
        _row(context, humidity.emoji, l10n.humidityLabel,
            _value(context, humidity.label(l10n), transparent), transparent),
      if (species.petToxicity != PetToxicity.unknown)
        _row(
          context,
          species.petToxicity.emoji,
          l10n.petToxicityLabel,
          // Coloured text rather than a tinted chip, which loses contrast
          // over the background illustration.
          _value(
            context,
            species.petToxicity.label(l10n),
            transparent,
            tone: species.petToxicity == PetToxicity.toxic
                ? StatusTone.danger
                : StatusTone.positive,
          ),
          transparent,
        ),
      if (species.floweringMonths.isNotEmpty)
        _textRow(
          context,
          Icons.local_florist_outlined,
          l10n.floweringIn(_months(l10n.localeName)),
          transparent,
        ),
      if (notes != null && notes.isNotEmpty)
        _textRow(context, Icons.notes_outlined, notes, transparent),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transparent
                  ? context.glass.scrim(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color:
                    transparent ? context.glass.tint(0.1) : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.spa_outlined,
                        size: 20,
                        color: transparent ? context.glass.fgSubtle : null),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.speciesCareTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: transparent ? context.glass.fg : null,
                        ),
                      ),
                    ),
                  ],
                ),
                for (final row in rows) ...[divider, row],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _months(String locale) {
    final format = DateFormat.MMM(locale);
    return (species.floweringMonths.toList()..sort())
        .map((m) => format.format(DateTime(2000, m)))
        .join(', ');
  }

  Widget _value(BuildContext context, String text, bool transparent,
          {StatusTone? tone}) =>
      Text(
        text,
        textAlign: TextAlign.end,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: tone?.foreground(context) ??
              (transparent ? context.glass.fg : null),
        ),
      );

  Widget _row(
    BuildContext context,
    String emoji,
    String label,
    Widget value,
    bool transparent,
  ) =>
      Row(
        children: [
          // The label next to it already says what the emoji shows.
          SizedBox(
            width: 20,
            child: ExcludeSemantics(
              child: Text(
                emoji,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(label,
                      style: TextStyle(
                          color: transparent ? context.glass.fgMuted : null)),
                ),
                const SizedBox(width: 12),
                Flexible(child: value),
              ],
            ),
          ),
        ],
      );

  Widget _textRow(
    BuildContext context,
    IconData icon,
    String text,
    bool transparent,
  ) =>
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon,
              size: 20, color: transparent ? context.glass.fgSubtle : null),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    color: transparent ? context.glass.fgMuted : null)),
          ),
        ],
      );
}
