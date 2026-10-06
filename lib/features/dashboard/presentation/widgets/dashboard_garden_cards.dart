import 'dart:io';
import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../plants/presentation/screens/home_screen.dart';
import '../../../plants/presentation/screens/plant_detail_screen.dart';
import '../../../plants/presentation/widgets/plant_status.dart';
import '../../domain/garden_overview.dart';
import 'dashboard_card.dart';

/// How many plants the carousel shows.
const _spotlightShown = 12;

/// Horizontal strip of plant photos, those needing attention first.
class DashboardGardenCarousel extends ConsumerStatefulWidget {
  final GardenOverview overview;

  const DashboardGardenCarousel({super.key, required this.overview});

  @override
  ConsumerState<DashboardGardenCarousel> createState() =>
      _DashboardGardenCarouselState();
}

class _DashboardGardenCarouselState
    extends ConsumerState<DashboardGardenCarousel> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final overview = widget.overview;
    final l10n = context.l10n;
    final plants = overview.spotlight.take(_spotlightShown).toList();
    // Photo plus two lines of text, which grow with the font scale.
    final textScaler = MediaQuery.textScalerOf(context);
    final height = _PlantTile._photoHeight +
        6 +
        (textScaler.scale(13.5) + textScaler.scale(11.5)) * 1.5;

    return DashboardCard(
      title: l10n.dashboardYourGarden,
      // The card has no right padding, so the strip scrolls to the edge.
      trailing: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: DashboardCardAction(
          label: l10n.dashboardSeeAll,
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      // Mice and trackpads drag the strip too: on desktop a horizontal list
      // can't be scrolled otherwise. The scrollbar shows there is more.
      child: ScrollConfiguration(
        behavior: ScrollConfiguration.of(context).copyWith(
          dragDevices: PointerDeviceKind.values.toSet(),
        ),
        child: Scrollbar(
          controller: _scroll,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SizedBox(
              height: height,
              child: ListView.separated(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.only(right: 16),
                itemCount: plants.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _PlantTile(pws: plants[i]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PlantTile extends ConsumerWidget {
  final PlantWithSpecies pws;

  const _PlantTile({required this.pws});

  static const _width = 124.0;
  static const _photoHeight = 116.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = dashboardPalette(context, ref);
    final colorScheme = Theme.of(context).colorScheme;
    final photo = ref.watch(plantCoverPhotoProvider(pws.plant.id)).value;
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final thirsty = pws.needsWatering;

    return SizedBox(
      width: _width,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PlantDetailScreen(plantId: pws.plant.id),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: SizedBox(
                width: _width,
                height: _photoHeight,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      color: colorScheme.primaryContainer,
                      child: Icon(
                        Icons.local_florist_outlined,
                        size: 40,
                        color: colorScheme.onPrimaryContainer
                            .withValues(alpha: 0.6),
                      ),
                    ),
                    if (photo != null)
                      Image.file(
                        File(photo),
                        fit: BoxFit.cover,
                        cacheWidth: (_width * dpr).round(),
                        gaplessPlayback: true,
                        excludeFromSemantics: true,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    if (thirsty)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: StatusTone.danger.base,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.water_drop,
                              size: 14, color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              pws.plant.nickname,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: palette.ink,
              ),
            ),
            Text(
              pws.species.popularName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11.5, color: palette.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}
