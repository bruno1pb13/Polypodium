import 'package:flutter/material.dart';

import '../../../../../core/l10n/l10n.dart';
import 'entry_form_widgets.dart';

// ---------------------------------------------------------------------------
// Height
// ---------------------------------------------------------------------------

class HeightForm extends StatelessWidget {
  final TextEditingController controller;

  /// Whether to flag the (required) height as invalid.
  final bool hasError;
  final ValueChanged<String> onChanged;

  const HeightForm({
    super.key,
    required this.controller,
    required this.hasError,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        EntrySectionTitle(emoji: '📏', label: context.l10n.heightSectionTitle),
        const SizedBox(height: 12),
        EntryNumericField(
          controller: controller,
          label: '${context.l10n.heightCmLabel} *',
          suffix: 'cm',
          hint: context.l10n.heightHint,
          hasError: hasError,
          errorText: hasError ? context.l10n.heightInvalid : null,
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),
        EntryHintText(context.l10n.heightMeasureHint),
      ],
    );
  }
}
