import 'package:flutter/material.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../domain/pot_model.dart';
import 'pot_picker_sheet.dart';
import 'pot_ui.dart';

/// Tappable field showing the picked pot (or "No pot"); opens the pot
/// picker, in the style of SoilSelectionField.
class PotSelectionField extends StatelessWidget {
  final PotModel? selectedPot;
  final ValueChanged<PotModel?> onPotSelected;

  /// Field label; defaults to "Pot".
  final String? label;

  /// Prefilled values of a pot created from the picker.
  final PotModel? newPotDefaults;

  /// Shown when no pot is picked; defaults to "No pot".
  final String? emptyLabel;

  /// Whether the picker offers "No pot".
  final bool allowNone;

  const PotSelectionField({
    super.key,
    required this.selectedPot,
    required this.onPotSelected,
    this.label,
    this.newPotDefaults,
    this.emptyLabel,
    this.allowNone = true,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pot = selectedPot;
    final specs = pot == null ? null : potSpecs(l10n, pot);
    return InkWell(
      onTap: () async {
        final choice = await showPotPicker(
          context,
          currentPotId: pot?.id,
          allowNone: allowNone,
          newPotDefaults: newPotDefaults,
        );
        if (choice != null) onPotSelected(choice.pot);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: context.glass.tint(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: context.glass.outline),
        ),
        child: Row(
          children: [
            pot == null
                ? Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: context.glass.tint(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.yard_outlined,
                        color: context.glass.fgMuted, size: 20),
                  )
                : PotKindBadge(kind: pot.kind, size: 40),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label ?? l10n.potLabel,
                    style:
                        TextStyle(color: context.glass.fgMuted, fontSize: 12),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    pot?.name ?? emptyLabel ?? l10n.noPot,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: pot != null
                          ? context.glass.fg
                          : context.glass.fgAlpha(0.4),
                      fontSize: 15,
                      fontWeight:
                          pot != null ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  if (specs != null)
                    Text(specs,
                        style: TextStyle(
                            color: context.glass.fgMuted, fontSize: 12)),
                ],
              ),
            ),
            if (pot != null)
              IconButton(
                onPressed: () => onPotSelected(null),
                tooltip: emptyLabel ?? l10n.noPot,
                icon: Icon(Icons.close, color: context.glass.fgFaint),
              )
            else
              Icon(Icons.keyboard_arrow_down, color: context.glass.fgFaint),
          ],
        ),
      ),
    );
  }
}
