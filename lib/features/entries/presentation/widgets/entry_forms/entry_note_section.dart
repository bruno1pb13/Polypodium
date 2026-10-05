import 'package:flutter/material.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';

/// Free-text note of the entry, with a hint suited to its [type].
class EntryNoteSection extends StatelessWidget {
  final TextEditingController controller;
  final EntryType type;

  const EntryNoteSection({
    super.key,
    required this.controller,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.notesTitle,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          maxLines: 4,
          decoration: InputDecoration(
            hintText: switch (type) {
              EntryType.irrigation => context.l10n.noteHintIrrigation,
              EntryType.fertilizer => context.l10n.noteHintFertilizer,
              EntryType.pruning => context.l10n.noteHintPruning,
              EntryType.observation => context.l10n.noteHintObservation,
              EntryType.height => context.l10n.noteHintHeight,
              EntryType.chlorosis => context.l10n.noteHintChlorosis,
              EntryType.pest => context.l10n.noteHintPest,
              EntryType.pesticide => context.l10n.noteHintPesticide,
              _ => context.l10n.noteHintDefault,
            },
            hintStyle: TextStyle(
              color: Colors.white.withValues(alpha: 0.4),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white24),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
          ),
        ),
      ],
    );
  }
}
