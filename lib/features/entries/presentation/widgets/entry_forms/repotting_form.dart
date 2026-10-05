import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/glass_colors.dart';
import '../../../../soils/domain/soil_model.dart';
import '../../../../soils/presentation/widgets/soil_selection_field.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Repotting — pot diameter/material and an optional new soil
// ---------------------------------------------------------------------------

/// The diameter controller and the picked material/soil are owned by the
/// screen; picking a soil also moves the plant to it when saved.
class RepottingForm extends StatelessWidget {
  final TextEditingController diameterController;
  final PotMaterial? material;
  final ValueChanged<PotMaterial?> onMaterialChanged;
  final SoilModel? newSoil;
  final ValueChanged<SoilModel?> onSoilChanged;

  const RepottingForm({
    super.key,
    required this.diameterController,
    required this.material,
    required this.onMaterialChanged,
    required this.newSoil,
    required this.onSoilChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(
            emoji: EntryType.repotting.emoji, label: l10n.entryTypeRepotting),
        const SizedBox(height: 4),
        EntryHintText(l10n.repottingHint),
        const SizedBox(height: 12),
        EntryNumericField(
          controller: diameterController,
          label: l10n.potDiameterLabel,
          suffix: 'cm',
          hint: '15',
        ),
        const SizedBox(height: 16),
        Text(
          l10n.potMaterialLabel,
          style: TextStyle(color: context.glass.fgMuted, fontSize: 13),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PotMaterial.values.map((m) {
            final selected = material == m;
            final colors = Theme.of(context).colorScheme;
            return ChoiceChip(
              label: Text(m.label(l10n)),
              selected: selected,
              onSelected: (_) => onMaterialChanged(selected ? null : m),
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
        const SizedBox(height: 16),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SoilSelectionField(
                label: l10n.newSoilLabel,
                selectedSoil: newSoil,
                onSoilSelected: onSoilChanged,
              ),
            ),
            if (newSoil != null) ...[
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: IconButton(
                  onPressed: () => onSoilChanged(null),
                  tooltip: l10n.keepCurrentSoil,
                  icon: Icon(Icons.close, color: context.glass.fgFaint),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        EntryHintText(l10n.newSoilHint),
      ],
    );
  }
}
