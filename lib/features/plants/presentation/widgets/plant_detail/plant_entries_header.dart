import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/emoji_text.dart';
import '../../../../entries/presentation/providers/entry_filters_provider.dart';
import '../../../../../core/theme/glass_colors.dart';

/// Title of the diary with its entry type filter and sort menu.
class PlantEntriesHeader extends ConsumerWidget {
  final String plantId;
  const PlantEntriesHeader({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));
    final activeSort = ref.watch(entrySortNotifierProvider(plantId));
    final allSelected = activeFilters.length == EntryType.values.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 4, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              context.l10n.entriesTitle,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: context.glass.fg,
              ),
            ),
          ),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: Icon(Icons.filter_list, color: context.glass.fgMuted),
                tooltip: context.l10n.filterTypes,
                onPressed: () {
                  final isDesktop = switch (defaultTargetPlatform) {
                    TargetPlatform.linux ||
                    TargetPlatform.macOS ||
                    TargetPlatform.windows =>
                      true,
                    _ => false,
                  };
                  if (isDesktop) {
                    showDialog(
                      context: context,
                      barrierColor: Colors.black38,
                      builder: (_) => _FilterDialog(plantId: plantId),
                    );
                  } else {
                    showModalBottomSheet(
                      context: context,
                      backgroundColor: Colors.transparent,
                      isScrollControlled: true,
                      builder: (_) => _FilterSheet(plantId: plantId),
                    );
                  }
                },
              ),
              if (!allSelected)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          PopupMenuButton<EntrySortOption>(
            icon: Icon(
              Icons.sort,
              color: activeSort != EntrySortOption.dateDesc
                  ? colorScheme.primary
                  : context.glass.fgMuted,
            ),
            tooltip: context.l10n.sortTooltip,
            onSelected: (sort) => ref
                .read(entrySortNotifierProvider(plantId).notifier)
                .setSort(sort),
            itemBuilder: (ctx) => EntrySortOption.values
                .map((s) => PopupMenuItem(
                      value: s,
                      child: Row(
                        children: [
                          Icon(
                            Icons.check,
                            size: 16,
                            color: s == activeSort
                                ? Theme.of(ctx).colorScheme.primary
                                : Colors.transparent,
                          ),
                          const SizedBox(width: 8),
                          Text(s.label(ctx.l10n)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _FilterSheet extends ConsumerWidget {
  final String plantId;
  const _FilterSheet({required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));
    final allSelected = activeFilters.length == EntryType.values.length;
    final colorScheme = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: context.glass.scrim(0.65),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: context.glass.tint(0.1)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.glass.tint(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.entryTypesTitle,
                          style: TextStyle(
                            color: context.glass.fg,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!allSelected)
                        TextButton(
                          onPressed: () => ref
                              .read(entryFiltersNotifierProvider(plantId)
                                  .notifier)
                              .selectAll(),
                          child: Text(
                            context.l10n.all,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                    ],
                  ),
                ),
                ...EntryType.values.map((type) {
                  final selected = activeFilters.contains(type);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) => ref
                        .read(entryFiltersNotifierProvider(plantId).notifier)
                        .toggleFilter(type),
                    title: EmojiText(
                      type.emoji,
                      type.label(context.l10n),
                      separator: '  ',
                      style: TextStyle(color: context.glass.fg),
                    ),
                    checkColor: Colors.white,
                    activeColor: colorScheme.primary,
                    side: BorderSide(color: context.glass.tint(0.3)),
                    dense: true,
                  );
                }),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FilterDialog extends ConsumerWidget {
  final String plantId;
  const _FilterDialog({required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));
    final allSelected = activeFilters.length == EntryType.values.length;
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 360,
            constraints: const BoxConstraints(maxWidth: 360),
            decoration: BoxDecoration(
              color: context.glass.scrim(0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: context.glass.tint(0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          context.l10n.entryTypesTitle,
                          style: TextStyle(
                            color: context.glass.fg,
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (!allSelected)
                        TextButton(
                          onPressed: () => ref
                              .read(entryFiltersNotifierProvider(plantId)
                                  .notifier)
                              .selectAll(),
                          child: Text(
                            context.l10n.all,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                        ),
                      IconButton(
                        icon: Icon(Icons.close,
                            color: context.glass.fgFaint, size: 18),
                        tooltip: MaterialLocalizations.of(context)
                            .closeButtonTooltip,
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                ...EntryType.values.map((type) {
                  final selected = activeFilters.contains(type);
                  return CheckboxListTile(
                    value: selected,
                    onChanged: (_) => ref
                        .read(entryFiltersNotifierProvider(plantId).notifier)
                        .toggleFilter(type),
                    title: EmojiText(
                      type.emoji,
                      type.label(context.l10n),
                      separator: '  ',
                      style: TextStyle(color: context.glass.fg),
                    ),
                    checkColor: Colors.white,
                    activeColor: colorScheme.primary,
                    side: BorderSide(color: context.glass.tint(0.3)),
                    dense: true,
                  );
                }),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
