import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Pest — identification field + severity selector
// ---------------------------------------------------------------------------

class PestForm extends StatelessWidget {
  final TextEditingController pestTypeController;
  final int severity;

  /// Whether to flag the (required) pest type as missing.
  final bool hasError;
  final ValueChanged<String> onPestTypeChanged;
  final ValueChanged<int> onSeverityChanged;

  const PestForm({
    super.key,
    required this.pestTypeController,
    required this.severity,
    required this.hasError,
    required this.onPestTypeChanged,
    required this.onSeverityChanged,
  });

  List<EntryOption> _pestSeverityOptions(AppLocalizations l10n) => [
        (
          value: 0,
          label: l10n.pestEradicated,
          description: l10n.pestEradicatedDesc
        ),
        (value: 1, label: l10n.severityMild, description: l10n.pestMildDesc),
        (
          value: 2,
          label: l10n.severityModerate,
          description: l10n.pestModerateDesc
        ),
        (
          value: 3,
          label: l10n.severitySevere,
          description: l10n.pestSevereDesc
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '🐛', label: context.l10n.entryTypePest),
        const SizedBox(height: 12),
        EntryTextField(
          controller: pestTypeController,
          label: '${context.l10n.pestTypeLabel} *',
          hint: context.l10n.pestTypeHint,
          hasError: hasError,
          errorText: hasError ? context.l10n.pestTypeRequired : null,
          onChanged: onPestTypeChanged,
        ),
        const SizedBox(height: 16),
        EntryHintText(context.l10n.pestSeverityHint),
        const SizedBox(height: 8),
        ..._pestSeverityOptions(context.l10n).map((s) => Padding(
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
