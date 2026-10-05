import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/glass_colors.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Harvest — quantity and unit
// ---------------------------------------------------------------------------

/// The quantity controller and the picked unit are owned by the screen.
class HarvestForm extends StatelessWidget {
  final TextEditingController quantityController;
  final HarvestUnit? unit;
  final ValueChanged<HarvestUnit?> onUnitChanged;

  const HarvestForm({
    super.key,
    required this.quantityController,
    required this.unit,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(
            emoji: EntryType.harvest.emoji, label: l10n.entryTypeHarvest),
        const SizedBox(height: 4),
        EntryHintText(l10n.harvestHint),
        const SizedBox(height: 12),
        EntryNumericField(
          controller: quantityController,
          label: l10n.harvestQuantityLabel,
          suffix: unit?.label(l10n) ?? '',
          hint: '500',
        ),
        const SizedBox(height: 16),
        Text(
          l10n.harvestUnitLabel,
          style: TextStyle(color: context.glass.fgMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: HarvestUnit.values.map((u) {
            final selected = unit == u;
            return ChoiceChip(
              label: Text(u.label(l10n)),
              selected: selected,
              onSelected: (_) => onUnitChanged(selected ? null : u),
              backgroundColor: context.glass.scrim(0.2),
              selectedColor: colors.primary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? colors.onPrimary : context.glass.fgMuted,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? context.glass.tint(0.3)
                      : context.glass.tint(0.12),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
