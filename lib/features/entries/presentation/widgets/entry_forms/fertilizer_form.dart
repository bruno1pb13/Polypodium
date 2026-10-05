import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// Holds name + dose controllers for one fertilizer product row.
class FertilizerProductEntry {
  final TextEditingController nameCtrl = TextEditingController();
  final TextEditingController doseCtrl = TextEditingController();

  void dispose() {
    nameCtrl.dispose();
    doseCtrl.dispose();
  }
}

// ---------------------------------------------------------------------------
// Fertilizer — dynamic product list
// ---------------------------------------------------------------------------

/// The rows' controllers are owned by the screen, which adds/removes rows
/// through [onAdd] and [onRemove].
class FertilizerForm extends StatelessWidget {
  final List<FertilizerProductEntry> products;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final ValueChanged<String> onDoseChanged;

  const FertilizerForm({
    super.key,
    required this.products,
    required this.onAdd,
    required this.onRemove,
    required this.onDoseChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '🌱', label: context.l10n.entryTypeFertilizer),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.fertilizerProductsHint),
        const SizedBox(height: 12),
        ...List.generate(products.length, (i) {
          final p = products[i];
          final canRemove = products.length > 1;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: EntryTextField(
                        controller: p.nameCtrl,
                        label:
                            '${context.l10n.productLabel} ${products.length > 1 ? "${i + 1}" : ""}',
                        hint: context.l10n.productHint,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: EntryNumericField(
                        controller: p.doseCtrl,
                        label: context.l10n.doseLabel,
                        suffix: 'ml',
                        hint: '5',
                        onChanged: onDoseChanged,
                      ),
                    ),
                    if (canRemove) ...[
                      const SizedBox(width: 4),
                      EntryRemoveRowButton(onPressed: () => onRemove(i)),
                    ],
                  ],
                ),
                if (i < products.length - 1)
                  Divider(
                    color: Colors.white.withValues(alpha: 0.1),
                    height: 1,
                  ),
              ],
            ),
          );
        }),
        EntryAddRowButton(label: context.l10n.addProduct, onPressed: onAdd),
      ],
    );
  }
}
