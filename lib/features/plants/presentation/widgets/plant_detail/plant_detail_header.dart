import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/l10n/l10n.dart';
import '../../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../../entries/presentation/providers/entries_providers.dart';
import '../../../domain/plant_model.dart';
import '../../../../../core/theme/glass_colors.dart';

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
          _PlantPhoto(
            photoPath: photoAsync.value,
            nickname: plant.nickname,
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  header: true,
                  child: Text(
                    plant.nickname,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: context.glass.fg,
                      shadows: [
                        Shadow(
                          color: context.glass.shadow(Colors.black38),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                if (pws != null) ...[
                  Text(
                    pws!.species.popularName,
                    style: TextStyle(
                      fontSize: 16,
                      color: context.glass.fgMuted,
                    ),
                  ),
                  Text(
                    pws!.species.scientificName,
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: context.glass.fgFaint,
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
  final String nickname;

  const _PlantPhoto({this.photoPath, required this.nickname});

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
            color: context.glass.scrim(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: photoPath != null
            ? Semantics(
                container: true,
                button: true,
                image: true,
                label: context.l10n.plantPhotoLabel(nickname),
                child: GestureDetector(
                  onTap: () => showFullscreenImageViewer(context, photoPath),
                  child: Image.file(
                    File(photoPath),
                    fit: BoxFit.cover,
                    excludeFromSemantics: true,
                    errorBuilder: (_, __, ___) => _PhotoPlaceholder(),
                  ),
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
      color: context.glass.tint(0.1),
      child: Icon(
        Icons.local_florist_outlined,
        size: 48,
        color: context.glass.outline,
      ),
    );
  }
}
