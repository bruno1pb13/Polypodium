import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Irrigation — 3 quick presets + custom input
// ---------------------------------------------------------------------------

/// Irrigation intensity: 1=Escassa 2=Moderada 3=Intensa (0 = not set).
class IrrigationForm extends StatelessWidget {
  final int intensity;
  final ValueChanged<int> onIntensityChanged;

  const IrrigationForm({
    super.key,
    required this.intensity,
    required this.onIntensityChanged,
  });

  List<EntryOption> _irrigationOptions(AppLocalizations l10n) => [
        (
          value: 1,
          label: l10n.irrigationScarce,
          description: l10n.irrigationScarceDesc
        ),
        (
          value: 2,
          label: l10n.irrigationModerate,
          description: l10n.irrigationModerateDesc
        ),
        (
          value: 3,
          label: l10n.irrigationIntense,
          description: l10n.irrigationIntenseDesc
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '💧', label: context.l10n.entryTypeIrrigation),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.irrigationIntensityHint),
        const SizedBox(height: 12),
        ..._irrigationOptions(context.l10n).map((o) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EntrySelectionRow(
                selected: intensity == o.value,
                label: o.label,
                description: o.description,
                onTap: () =>
                    onIntensityChanged(intensity == o.value ? 0 : o.value),
              ),
            )),
      ],
    );
  }
}
