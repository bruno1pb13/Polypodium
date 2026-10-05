import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../entries/presentation/providers/entries_providers.dart';
import '../../../domain/plant_model.dart';

/// Latest photo, nickname and species of the plant.
class PlantDetailHeader extends ConsumerWidget {
  final PlantModel plant;
  final PlantWithSpecies? pws;

  const PlantDetailHeader({super.key, required this.plant, required this.pws});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photoAsync = ref.watch(latestPlantPhotoProvider(plant.id));

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _PlantPhoto(photoPath: photoAsync.value),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  plant.nickname,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [Shadow(color: Colors.black38, blurRadius: 4)],
                  ),
                ),
                if (pws != null) ...[
                  Text(
                    pws!.species.popularName,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Text(
                    pws!.species.scientificName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantPhoto extends StatelessWidget {
  final String? photoPath;

  const _PlantPhoto({this.photoPath});

  @override
  Widget build(BuildContext context) {
    final photoPath = this.photoPath;
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: photoPath != null
            ? GestureDetector(
                onTap: () => showFullscreenImageViewer(context, photoPath),
                child: Image.file(
                  File(photoPath),
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _PhotoPlaceholder(),
                ),
              )
            : _PhotoPlaceholder(),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white.withValues(alpha: 0.1),
      child: const Icon(
        Icons.local_florist_outlined,
        size: 48,
        color: Colors.white24,
      ),
    );
  }
}
