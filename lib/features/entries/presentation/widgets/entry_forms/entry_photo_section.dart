import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/theme/glass_colors.dart';

/// Most photos one entry takes.
const maxEntryPhotos = 5;

/// Photos of the entry: previews with a remove button each, and
/// camera/gallery buttons while there's room for more.
class EntryPhotoSection extends StatelessWidget {
  final List<String> photoPaths;
  final ValueChanged<int> onRemove;
  final ValueChanged<ImageSource> onPick;

  const EntryPhotoSection({
    super.key,
    required this.photoPaths,
    required this.onRemove,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    final count = photoPaths.length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              context.l10n.photosTitle,
              style: TextStyle(
                color: context.glass.fg,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (count > 0)
              Text(
                context.l10n.photosCounter(count, maxEntryPhotos),
                style: TextStyle(color: context.glass.fgMuted, fontSize: 14),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (count > 0) ...[
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: count,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _PhotoPreview(
                path: photoPaths[i],
                label: context.l10n.photoNumberLabel(i + 1, count),
                removeTooltip: context.l10n.removePhotoNumber(i + 1),
                onRemove: () => onRemove(i),
              ),
            ),
          ),
          if (count < maxEntryPhotos) const SizedBox(height: 12),
        ],
        if (count < maxEntryPhotos)
          Row(
            children: [
              Expanded(
                child: _PhotoButton(
                  icon: Icons.photo_camera_outlined,
                  label: context.l10n.camera,
                  onTap: () => onPick(ImageSource.camera),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PhotoButton(
                  icon: Icons.photo_library_outlined,
                  label: context.l10n.gallery,
                  onTap: () => onPick(ImageSource.gallery),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _PhotoPreview extends StatelessWidget {
  final String path;
  final String label;
  final String removeTooltip;
  final VoidCallback onRemove;

  const _PhotoPreview({
    required this.path,
    required this.label,
    required this.removeTooltip,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              File(path),
              fit: BoxFit.cover,
              semanticLabel: label,
              errorBuilder: (_, __, ___) => Semantics(
                image: true,
                label: label,
                child: Container(
                  color: context.glass.tint(0.1),
                  child: Icon(Icons.broken_image_outlined,
                      color: context.glass.outline),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton.filled(
              onPressed: onRemove,
              tooltip: removeTooltip,
              icon: const Icon(Icons.close, size: 20),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PhotoButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PhotoButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            border: Border.all(color: context.glass.outline),
            borderRadius: BorderRadius.circular(16),
            color: context.glass.tint(0.05),
          ),
          child: Column(
            children: [
              Icon(icon, color: context.glass.fgMuted),
              const SizedBox(height: 8),
              Text(
                label,
                style: TextStyle(color: context.glass.fgMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
