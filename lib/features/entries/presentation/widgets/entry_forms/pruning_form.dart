import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Pruning — reason chips
// ---------------------------------------------------------------------------

class PruningForm extends StatelessWidget {
  final String? reason;
  final ValueChanged<String?> onReasonChanged;

  const PruningForm({
    super.key,
    required this.reason,
    required this.onReasonChanged,
  });

  List<({String key, String label})> _pruningReasons(AppLocalizations l10n) => [
        (key: 'formacao', label: l10n.pruningFormation),
        (key: 'limpeza', label: l10n.pruningCleaning),
        (key: 'rejuvenescimento', label: l10n.pruningRejuvenation),
        (key: 'colheita', label: l10n.pruningHarvest),
      ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '✂️', label: context.l10n.entryTypePruning),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.pruningReasonHint),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _pruningReasons(context.l10n).map((r) {
            final selected = reason == r.key;
            return ChoiceChip(
              label: Text(r.label),
              selected: selected,
              onSelected: (_) => onReasonChanged(selected ? null : r.key),
              backgroundColor: Colors.black.withValues(alpha: 0.2),
              selectedColor: Theme.of(context).colorScheme.primary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.white70,
                fontSize: 13,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: selected
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.white12,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
