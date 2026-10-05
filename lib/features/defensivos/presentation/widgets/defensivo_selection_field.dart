import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/defensivo_model.dart';
import 'defensivo_picker_sheet.dart';
import '../../../../core/theme/glass_colors.dart';

class DefensivoSelectionField extends StatelessWidget {
  final DefensivoModel? selectedDefensivo;
  final String? errorText;
  final ValueChanged<DefensivoModel?> onDefensivoSelected;

  const DefensivoSelectionField({
    super.key,
    this.selectedDefensivo,
    this.errorText,
    required this.onDefensivoSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<DefensivoModel>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => DefensivoPickerSheet(
                selectedDefensivoId: selectedDefensivo?.id,
              ),
            );
            if (result != null) {
              onDefensivoSelected(result);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: context.glass.tint(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : context.glass.outline,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.glass.tint(0.1),
                    borderRadius: BorderRadius.circular(8),
                    image: selectedDefensivo?.imagePath != null
                        ? DecorationImage(
                            image:
                                FileImage(File(selectedDefensivo!.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: selectedDefensivo?.imagePath == null
                      ? Icon(Icons.science_outlined,
                          color: context.glass.fgMuted, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.defensivoFieldLabel,
                        style: TextStyle(
                          color: context.glass.fgMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedDefensivo?.name ??
                            context.l10n.selectDefensivoTitle,
                        style: TextStyle(
                          color: selectedDefensivo != null
                              ? context.glass.fg
                              : context.glass.fgAlpha(0.4),
                          fontSize: 15,
                          fontWeight: selectedDefensivo != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.keyboard_arrow_down, color: context.glass.fgFaint),
              ],
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 6),
            child: Text(
              errorText!,
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }
}
