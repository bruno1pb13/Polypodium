import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../theme/glass_colors.dart';

class AppSearchBar<T> extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final List<PopupMenuEntry<T>>? sortOptions;
  final ValueChanged<T>? onSortSelected;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.hintText,
    this.sortOptions,
    this.onSortSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: context.glass.scrim(0.3),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: context.glass.tint(0.2),
                    ),
                  ),
                  child: TextField(
                    controller: controller,
                    style: TextStyle(color: context.glass.fg),
                    decoration: InputDecoration(
                      hintText: hintText,
                      hintStyle: TextStyle(
                        color: context.glass.fgAlpha(0.6),
                      ),
                      prefixIcon:
                          Icon(Icons.search, color: context.glass.fgMuted),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    onChanged: onChanged,
                  ),
                ),
              ),
            ),
          ),
          if (sortOptions != null && onSortSelected != null) ...[
            const SizedBox(width: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: PopupMenuButton<T>(
                    icon: Icon(Icons.tune, color: context.glass.fg),
                    tooltip: context.l10n.sortTooltip,
                    onSelected: onSortSelected,
                    itemBuilder: (context) => sortOptions!,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
