import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/emoji_text.dart';
import '../../../../../core/theme/glass_colors.dart';

/// Choice chips of the entry types that can be created by hand.
class EntryTypeSelector extends StatelessWidget {
  final EntryType selectedType;
  final ValueChanged<EntryType> onSelected;

  /// When set, only these types are offered.
  final Set<EntryType>? allowedTypes;

  const EntryTypeSelector({
    super.key,
    required this.selectedType,
    required this.onSelected,
    this.allowedTypes,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.entryTypeCardTitle,
          style: TextStyle(
            color: context.glass.fg,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: EntryType.values
              .where((t) => t != EntryType.history && t != EntryType.other)
              .where((t) => allowedTypes?.contains(t) ?? true)
              .map((t) {
            final selected = t == selectedType;
            return ChoiceChip(
              label: EmojiText(t.emoji, t.label(context.l10n)),
              selected: selected,
              onSelected: (_) => onSelected(t),
              backgroundColor: context.glass.scrim(0.2),
              selectedColor: Theme.of(context).colorScheme.primary,
              showCheckmark: false,
              labelStyle: TextStyle(
                color: selected ? Colors.white : context.glass.fgMuted,
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
