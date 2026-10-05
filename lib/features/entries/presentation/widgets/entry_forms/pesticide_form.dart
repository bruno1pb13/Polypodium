import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../defensivos/domain/defensivo_model.dart';
import '../../../../defensivos/presentation/widgets/defensivo_selection_field.dart';
import 'entry_form_widgets.dart';

// Holds a selected catalog defensivo + dose controller for one pesticide
// application row.
class PesticideProductEntry {
  DefensivoModel? selected;
  final TextEditingController doseCtrl = TextEditingController();

  void dispose() {
    doseCtrl.dispose();
  }
}

// ---------------------------------------------------------------------------
// Pesticide — dynamic list of catalog-picked defensivos + optional
// reapplication recurrence
// ---------------------------------------------------------------------------

/// The rows and the recurrence controller are owned by the screen, which
/// adds/removes rows and stores the picked defensivo through the callbacks.
class PesticideForm extends StatelessWidget {
  final List<PesticideProductEntry> products;
  final TextEditingController recurrenceController;

  /// Whether to flag the (required) first defensivo as missing.
  final bool hasError;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final void Function(PesticideProductEntry row, DefensivoModel? defensivo)
      onDefensivoSelected;

  const PesticideForm({
    super.key,
    required this.products,
    required this.recurrenceController,
    required this.hasError,
    required this.onAdd,
    required this.onRemove,
    required this.onDefensivoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '🧪', label: context.l10n.entryTypePesticide),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.pesticideProductsHint),
        const SizedBox(height: 12),
        ...List.generate(products.length, (i) {
          final p = products[i];
          final canRemove = products.length > 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: DefensivoSelectionField(
                        selectedDefensivo: p.selected,
                        errorText: hasError && i == 0
                            ? context.l10n.defensivoRequired
                            : null,
                        onDefensivoSelected: (d) => onDefensivoSelected(p, d),
                      ),
                    ),
                    if (canRemove) ...[
                      const SizedBox(width: 4),
                      EntryRemoveRowButton(onPressed: () => onRemove(i)),
                    ],
                  ],
                ),
                const SizedBox(height: 8),
                EntryTextField(
                  controller: p.doseCtrl,
                  label: context.l10n.pesticideDoseLabel,
                  hint: context.l10n.pesticideDoseHint,
                ),
                if (i < products.length - 1) ...[
                  const SizedBox(height: 12),
                  Divider(
                      color: Colors.white.withValues(alpha: 0.1), height: 1),
                ],
              ],
            ),
          );
        }),
        EntryAddRowButton(label: context.l10n.addDefensivo, onPressed: onAdd),
        const SizedBox(height: 16),
        EntryNumericField(
          controller: recurrenceController,
          label: context.l10n.pesticideRecurrenceLabel,
          suffix: context.l10n.daysSuffix,
          hint: '15',
        ),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.pesticideRecurrenceHint),
      ],
    );
  }
}
