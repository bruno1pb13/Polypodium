import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../entries/domain/entry_model.dart';

/// Chronological photo grid ("time-lapse") of a plant, built from the
/// entries that carry a photo. Oldest first, so scrolling reads as growth.
class PlantPhotosSliver extends StatelessWidget {
  final List<EntryModel> entries;

  const PlantPhotosSliver({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final photos = entries.where((e) => e.photoPath != null).toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (photos.isEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Center(
            child: Text(
              context.l10n.photosEmpty,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70, height: 1.4),
            ),
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 140,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, i) => _PhotoTile(entry: photos[i]),
          childCount: photos.length,
        ),
      ),
    );
  }
}

class _PhotoTile extends StatelessWidget {
  final EntryModel entry;

  const _PhotoTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    final date =
        DateFormat.yMd(context.l10n.localeName).format(entry.date);

    return GestureDetector(
      onTap: () => showFullscreenImageViewer(context, entry.photoPath!),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(entry.photoPath!),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.white.withValues(alpha: 0.1),
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.white24,
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
    );
  }
}
