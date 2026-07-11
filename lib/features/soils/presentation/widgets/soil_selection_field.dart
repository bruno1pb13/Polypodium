import 'dart:io';
import 'package:flutter/material.dart';
import '../../../../core/l10n/l10n.dart';
import '../../domain/soil_model.dart';
import 'soil_picker_sheet.dart';

class SoilSelectionField extends StatelessWidget {
  final SoilModel? selectedSoil;
  final String? errorText;
  final bool isRecommended;
  final ValueChanged<SoilModel?> onSoilSelected;

  const SoilSelectionField({
    super.key,
    this.selectedSoil,
    this.errorText,
    this.isRecommended = false,
    required this.onSoilSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () async {
            final result = await showModalBottomSheet<SoilModel>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => SoilPickerSheet(
                selectedSoilId: selectedSoil?.id,
              ),
            );
            if (result != null) {
              onSoilSelected(result);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? Theme.of(context).colorScheme.error
                    : Colors.white24,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    image: selectedSoil?.imagePath != null
                        ? DecorationImage(
                            image: selectedSoil!.imagePath!.startsWith('assets/')
                                ? AssetImage(selectedSoil!.imagePath!)
                                    as ImageProvider
                                : FileImage(File(selectedSoil!.imagePath!)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: selectedSoil?.imagePath == null
                      ? const Icon(Icons.terrain_outlined,
                          color: Colors.white70, size: 20)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${context.l10n.soilTypeLabel} *${isRecommended ? ' ${context.l10n.recommendedSuffix}' : ''}',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        selectedSoil?.name ?? context.l10n.selectSoilTitle,
                        style: TextStyle(
                          color: selectedSoil != null
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: 15,
                          fontWeight: selectedSoil != null
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.keyboard_arrow_down, color: Colors.white54),
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
