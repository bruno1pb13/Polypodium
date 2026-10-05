import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Chlorosis — severity selector
// ---------------------------------------------------------------------------

class ChlorosisForm extends StatelessWidget {
  final int severity;
  final ValueChanged<int> onSeverityChanged;

  const ChlorosisForm({
    super.key,
    required this.severity,
    required this.onSeverityChanged,
  });

  List<EntryOption> _chlorosisSeverityOptions(AppLocalizations l10n) => [
        (
          value: 0,
          label: l10n.chlorosisCured,
          description: l10n.chlorosisCuredDesc
        ),
        (
          value: 1,
          label: l10n.severityMild,
          description: l10n.chlorosisMildDesc
        ),
        (
          value: 2,
          label: l10n.severityModerate,
          description: l10n.chlorosisModerateDesc
        ),
        (
          value: 3,
          label: l10n.severitySevere,
          description: l10n.chlorosisSevereDesc
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '🟡', label: context.l10n.entryTypeChlorosis),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.severitySelectHint),
        const SizedBox(height: 12),
        ..._chlorosisSeverityOptions(context.l10n).map((s) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: EntrySelectionRow(
                selected: severity == s.value,
                label: s.label,
                description: s.description,
                onTap: () => onSeverityChanged(s.value),
              ),
            )),
      ],
    );
  }
}
