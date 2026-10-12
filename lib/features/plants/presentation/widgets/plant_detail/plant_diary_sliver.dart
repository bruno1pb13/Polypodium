import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/enums.dart';
import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/storage/photo_picker.dart';
import '../../../../../core/storage/photo_storage_provider.dart';
import '../../../../entries/domain/entry_model.dart';
import '../../../../entries/presentation/providers/entries_providers.dart';
import '../../../../entries/presentation/providers/entry_filters_provider.dart';
import '../../../../entries/presentation/widgets/entry_forms/entry_photo_section.dart';
import '../../../../entries/presentation/widgets/entry_timeline_item.dart';
import '../../../../../core/theme/glass_colors.dart';

/// Timeline of the plant's entries, filtered and sorted as chosen in
/// [PlantEntriesHeader]. Returns a sliver.
class PlantDiarySliver extends ConsumerWidget {
  final String plantId;

  const PlantDiarySliver({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(entriesNotifierProvider(plantId));
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));
    final activeSort = ref.watch(entrySortNotifierProvider(plantId));

    return entriesAsync.when(
      loading: () => const SliverToBoxAdapter(
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(child: Text(context.l10n.errorGeneric('$e'))),
      ),
      data: (entries) {
        final filteredEntries =
            entries.where((e) => activeFilters.contains(e.type)).toList();

        switch (activeSort) {
          case EntrySortOption.dateAsc:
            filteredEntries.sort((a, b) => a.date.compareTo(b.date));
          case EntrySortOption.typeAZ:
            filteredEntries.sort((a, b) => a.type
                .label(context.l10n)
                .compareTo(b.type.label(context.l10n)));
          case EntrySortOption.dateDesc:
            break;
        }

        if (filteredEntries.isEmpty) {
          return SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(48),
              child: Center(
                child: Text(
                  context.l10n.noEntriesFound,
                  style: TextStyle(color: context.glass.fgMuted),
                ),
              ),
            ),
          );
        }

        return SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => EntryTimelineItem(
              entry: filteredEntries[i],
              isLast: i == filteredEntries.length - 1,
              onDelete: () => _deleteEntry(context, ref, filteredEntries[i]),
              onAddPhotos: () => _addPhotos(context, ref, filteredEntries[i]),
            ),
            childCount: filteredEntries.length,
          ),
        );
      },
    );
  }

  /// Picks photos from the camera or the gallery and attaches them to
  /// [entry], up to its room for more.
  Future<void> _addPhotos(
    BuildContext context,
    WidgetRef ref,
    EntryModel entry,
  ) async {
    final room = maxEntryPhotos - entry.photos.length;
    if (room <= 0) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: context.glass.sheet,
      builder: (sheetContext) {
        Widget option(IconData icon, String label, ImageSource source) =>
            ListTile(
              leading: Icon(icon, color: context.glass.fg),
              title: Text(label, style: TextStyle(color: context.glass.fg)),
              onTap: () => Navigator.pop(sheetContext, source),
            );
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              option(Icons.photo_camera_outlined, context.l10n.camera,
                  ImageSource.camera),
              option(Icons.photo_library_outlined, context.l10n.gallery,
                  ImageSource.gallery),
            ],
          ),
        );
      },
    );
    if (source == null) return;
    final picked =
        await ref.read(photoPickerProvider).pick(source, limit: room);
    if (picked.isEmpty) return;
    final storage = ref.read(photoStorageProvider);
    final saved = [
      for (final path in picked.take(room)) await storage.savePhoto(File(path)),
    ];
    // The keepAlive mutations service, so the save outlives this widget.
    await ref.read(entryMutationsProvider).addPhotos(entry.id, saved);
  }

  Future<void> _deleteEntry(
    BuildContext context,
    WidgetRef ref,
    EntryModel entry,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteEntryTitle),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref
          .read(entriesNotifierProvider(plantId).notifier)
          .delete(entry.id);
    }
  }
}
