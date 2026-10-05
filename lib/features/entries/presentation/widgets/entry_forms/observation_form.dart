import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';
import '../../../../../core/theme/glass_colors.dart';

// ---------------------------------------------------------------------------
// Observation — health score 1–5
// ---------------------------------------------------------------------------

/// Health score 1–5 (0 = not set).
class ObservationForm extends StatelessWidget {
  final int healthScore;
  final ValueChanged<int> onHealthScoreChanged;

  const ObservationForm({
    super.key,
    required this.healthScore,
    required this.onHealthScoreChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scoreLabels = [
      '',
      context.l10n.healthCritical,
      context.l10n.healthBad,
      context.l10n.healthRegular,
      context.l10n.healthGood,
      context.l10n.healthExcellent,
    ];
    final scoreColors = [
      Colors.transparent,
      Colors.red.shade400,
      Colors.orange.shade400,
      Colors.yellow.shade600,
      Colors.lightGreen.shade400,
      Colors.green.shade400,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(
            emoji: '👁', label: context.l10n.entryTypeObservation),
        const SizedBox(height: 4),
        EntryHintText(context.l10n.healthScoreHint),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(5, (i) {
            final score = i + 1;
            final selected = healthScore == score;
            return Semantics(
              container: true,
              button: true,
              selected: selected,
              label: '${context.l10n.healthSummary(score)} — '
                  '${scoreLabels[score]}',
              child: GestureDetector(
                onTap: () => onHealthScoreChanged(selected ? 0 : score),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected
                        ? scoreColors[score].withValues(alpha: 0.8)
                        : context.glass.tint(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected
                          ? scoreColors[score]
                          : context.glass.outline,
                      width: selected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: ExcludeSemantics(
                      child: Text(
                        '$score',
                        style: TextStyle(
                          color: selected
                              ? Colors.white
                              : context.glass.fgMuted,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (healthScore > 0) ...[
          const SizedBox(height: 8),
          Center(
            child: Text(
              scoreLabels[healthScore],
              style: TextStyle(
                color: scoreColors[healthScore],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
