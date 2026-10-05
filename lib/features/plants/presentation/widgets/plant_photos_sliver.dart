import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../entries/domain/entry_model.dart';
import '../../domain/plant_photos.dart';
import '../../../../core/theme/glass_colors.dart';

/// Chronological photo grid ("time-lapse") of a plant, built from the
/// photos of its entries. Oldest first, so scrolling reads as growth.
/// Long-pressing a photo offers to make it the plant's cover.
class PlantPhotosSliver extends StatelessWidget {
  final List<EntryModel> entries;

  /// The cover picked for the plant (see PlantModel.coverPhotoId).
  final String? coverPhotoId;

  /// Picks a photo id as cover, or null to go back to the latest photo.
  /// Without it the photos offer no options.
  final ValueChanged<String?>? onSetCover;

  const PlantPhotosSliver({
    super.key,
    required this.entries,
    this.coverPhotoId,
    this.onSetCover,
  });

  @override
  Widget build(BuildContext context) {
    final photos = plantPhotosOf(entries);

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

    final coverId = coverPhotoIdOf(photos, coverPhotoId);

    return SliverPadding(
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
            return _PhotoTile(
              item: item,
              isCover: isCover,
              onLongPress: onSetCover == null
                  ? null
                  : () => _showOptions(context, item, isCover),
            );
          },
          childCount: photos.length,
        ),
      ),
    );
  }

  Future<void> _showOptions(
      BuildContext context, PlantPhoto item, bool isCover) {
    final picked = item.photo.id == coverPhotoId;
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.glass.sheet,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isCover || !picked)
              ListTile(
                leading: Icon(Icons.star_outline, color: context.glass.fg),
                title: Text(context.l10n.setAsCover,
                    style: TextStyle(color: context.glass.fg)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSetCover!(item.photo.id);
                },
              ),
            if (picked)
              ListTile(
                leading: Icon(Icons.history, color: context.glass.fg),
                title: Text(context.l10n.useLatestAsCover,
                    style: TextStyle(color: context.glass.fg)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  onSetCover!(null);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final PlantPhoto item;
  final bool isCover;
  final VoidCallback? onLongPress;

  const _PhotoTile({
    required this.item,
    required this.isCover,
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
      label: isCover
          ? context.l10n.coverPhotoLabel(date)
          : context.l10n.entryPhotoLabel(date),
      onLongPressHint:
          onLongPress == null ? null : context.l10n.photoOptionsHint,
      child: GestureDetector(
        onTap: () => showFullscreenImageViewer(context, path),
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
