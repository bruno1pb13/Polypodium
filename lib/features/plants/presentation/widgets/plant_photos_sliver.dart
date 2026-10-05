import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../entries/domain/entry_model.dart';
import '../../domain/plant_photos.dart';
import '../screens/photo_comparison_screen.dart';
import '../../../../core/theme/glass_colors.dart';

/// Chronological photo grid ("time-lapse") of a plant, built from the
/// photos of its entries. Oldest first, so scrolling reads as growth.
/// Long-pressing a photo offers to make it the plant's cover or to compare
/// it with another one.
class PlantPhotosSliver extends StatefulWidget {
  final List<EntryModel> entries;

  /// The cover picked for the plant (see PlantModel.coverPhotoId).
  final String? coverPhotoId;

  /// Picks a photo id as cover, or null to go back to the latest photo.
  /// Without it the photos don't offer to become the cover.
  final ValueChanged<String?>? onSetCover;

  const PlantPhotosSliver({
    super.key,
    required this.entries,
    this.coverPhotoId,
    this.onSetCover,
  });

  @override
  State<PlantPhotosSliver> createState() => _PlantPhotosSliverState();
}

class _PlantPhotosSliverState extends State<PlantPhotosSliver> {
  /// Photo waiting for a second one to compare with.
  PlantPhoto? _comparing;

  @override
  Widget build(BuildContext context) {
    final photos = plantPhotosOf(widget.entries);

    if (photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Text(
              context.l10n.photosEmpty,
              textAlign: TextAlign.center,
              style: TextStyle(color: context.glass.fgMuted, height: 1.4),
            ),
          ),
        ),
      );
    }

    final coverId = coverPhotoIdOf(photos, widget.coverPhotoId);
    final gallery = [for (final p in photos) p.photo.path];
    final comparing = photos
        .where((p) => p.photo.id == _comparing?.photo.id)
        .firstOrNull;
    final hasOptions = widget.onSetCover != null || photos.length > 1;

    return SliverMainAxisGroup(
      slivers: [
        if (comparing != null)
          SliverToBoxAdapter(child: _buildComparePrompt(context)),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 140,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final item = photos[i];
                final isCover = item.photo.id == coverId;
                final selected = item.photo.id == comparing?.photo.id;
                return _PhotoTile(
                  item: item,
                  gallery: gallery,
                  isCover: isCover,
                  selected: selected,
                  onTap: comparing == null
                      ? null
                      : selected
                          ? () => setState(() => _comparing = null)
                          : () => _compare(context, comparing, item),
                  onLongPress: hasOptions && comparing == null
                      ? () => _showOptions(context, photos, item)
                      : null,
                );
              },
              childCount: photos.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComparePrompt(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        child: Container(
          padding: const EdgeInsets.only(left: 16),
          decoration: BoxDecoration(
            color: context.glass.scrim(0.36),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: context.glass.glassBorder),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  context.l10n.pickPhotoToCompare,
                  style: TextStyle(
                      color: context.glass.fg, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: () => setState(() => _comparing = null),
                style: TextButton.styleFrom(
                    foregroundColor: context.glass.fg,
                    minimumSize: const Size(48, 48)),
                child: Text(context.l10n.cancel),
              ),
            ],
          ),
        ),
      );

  void _compare(BuildContext context, PlantPhoto a, PlantPhoto b) {
    setState(() => _comparing = null);
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => PhotoComparisonScreen(a: a, b: b)),
    );
  }

  Future<void> _showOptions(
      BuildContext context, List<PlantPhoto> photos, PlantPhoto item) {
    final onSetCover = widget.onSetCover;
    final picked = item.photo.id == widget.coverPhotoId;
    final first = photos.first;
    final textStyle = TextStyle(color: context.glass.fg);

    Widget option(IconData icon, String label, VoidCallback onTap,
            BuildContext sheetContext) =>
        ListTile(
          leading: Icon(icon, color: context.glass.fg),
          title: Text(label, style: textStyle),
          onTap: () {
            Navigator.pop(sheetContext);
            onTap();
          },
        );

    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.glass.sheet,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (onSetCover != null && !picked)
              option(Icons.star_outline, context.l10n.setAsCover,
                  () => onSetCover(item.photo.id), sheetContext),
            if (onSetCover != null && picked)
              option(Icons.history, context.l10n.useLatestAsCover,
                  () => onSetCover(null), sheetContext),
            if (item.photo.id != first.photo.id)
              option(Icons.compare, context.l10n.compareWithFirst,
                  () => _compare(context, first, item), sheetContext),
            if (photos.length > 1)
              option(
                  Icons.photo_library_outlined,
                  context.l10n.compareWithOther,
                  () => setState(() => _comparing = item),
                  sheetContext),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final PlantPhoto item;

  /// Every photo of the plant, swiped through from this one.
  final List<String> gallery;
  final bool isCover;

  /// Picked as the first of two photos to compare.
  final bool selected;

  /// Replaces opening the photo (while picking one to compare).
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  const _PhotoTile({
    required this.item,
    required this.gallery,
    required this.isCover,
    this.selected = false,
    this.onTap,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat.yMd(context.l10n.localeName).format(item.entry.date);
    final path = item.photo.path;

    return Semantics(
      container: true,
      button: true,
      image: true,
      // Only while picking a photo to compare.
      selected: onTap == null ? null : selected,
      label: isCover
          ? context.l10n.coverPhotoLabel(date)
          : context.l10n.entryPhotoLabel(date),
      onLongPressHint:
          onLongPress == null ? null : context.l10n.photoOptionsHint,
      child: GestureDetector(
        onTap: onTap ??
            () => showFullscreenImageViewer(context, path, gallery: gallery),
        onLongPress: onLongPress,
        child: ExcludeSemantics(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: context.glass.tint(0.1),
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: context.glass.outline,
                    ),
                  ),
                ),
                if (selected)
                  DecoratedBox(
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                if (isCover)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black87,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 12, color: Colors.white),
                          const SizedBox(width: 2),
                          Text(
                            context.l10n.coverBadge,
                            style: const TextStyle(
                              fontSize: 10.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(8, 14, 8, 5),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black54],
                      ),
                    ),
                    child: Text(
                      date,
                      style: const TextStyle(
                        fontSize: 10.5,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        shadows: [Shadow(color: Colors.black45, blurRadius: 2)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
