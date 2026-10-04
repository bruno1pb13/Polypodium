import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/providers/entry_filters_provider.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../entries/presentation/widgets/entry_timeline_item.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../reminders/presentation/widgets/plant_reminders_card.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../domain/plant_model.dart';
import '../providers/plant_detail_view_provider.dart';
import '../providers/plants_providers.dart';
import '../widgets/plant_insights_view.dart';
import '../widgets/plant_photos_sliver.dart';
import '../widgets/plant_status.dart';
import 'add_edit_plant_screen.dart';

class PlantDetailScreen extends ConsumerWidget {
  final String plantId;

  const PlantDetailScreen({super.key, required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plantsAsync = ref.watch(plantsNotifierProvider);
    final speciesAsync = ref.watch(speciesNotifierProvider);
    final locationsAsync = ref.watch(locationsNotifierProvider);
    final soilsAsync = ref.watch(soilsNotifierProvider);
    final entriesAsync = ref.watch(entriesNotifierProvider(plantId));
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));
    final activeSort = ref.watch(entrySortNotifierProvider(plantId));
    final activeView = ref.watch(plantDetailViewNotifierProvider(plantId));

    return plantsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) =>
          Scaffold(body: Center(child: Text(context.l10n.errorGeneric('$e')))),
      data: (plants) {
        final plant = plants.where((p) => p.id == plantId).firstOrNull;
        if (plant == null) {
          return Scaffold(
            body: Center(child: Text(context.l10n.plantNotFound)),
          );
        }
        final species = speciesAsync.value
            ?.where((s) => s.id == plant.speciesId)
            .firstOrNull;

        final location = plant.locationId != null
            ? locationsAsync.value
                ?.where((l) => l.id == plant.locationId)
                .firstOrNull
            : null;

        final soil = soilsAsync.value
            ?.where((s) => s.id == plant.soilId)
            .firstOrNull;

        final pws = species != null
            ? PlantWithSpecies(
                plant: plant,
                species: species,
                location: location,
              )
            : null;

        return Scaffold(
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            title: Text(
              plant.nickname,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEditPlantScreen(plant: plant),
                  ),
                ),
              ),
              PopupMenuButton<PlantStatus>(
                icon: const Icon(Icons.inventory_2_outlined),
                tooltip: context.l10n.plantStatusChange,
                onSelected: (status) => ref
                    .read(plantsNotifierProvider.notifier)
                    .setStatus(plantId, status),
                itemBuilder: (ctx) => [
                  for (final status in PlantStatus.values)
                    if (status != plant.status)
                      PopupMenuItem(
                        value: status,
                        child: Text(_statusActionLabel(ctx, status)),
                      ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
          body: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                ),
              ),
              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.5),
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.3),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(plantsNotifierProvider);
                    ref.invalidate(entriesNotifierProvider(plantId));
                    try {
                      await Future.wait([
                        ref.read(plantsNotifierProvider.future),
                        ref.read(entriesNotifierProvider(plantId).future),
                      ]);
                    } catch (_) {}
                  },
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeaderSection(plant: plant, pws: pws),
                    ),
                    if (!plant.isActive)
                      SliverToBoxAdapter(
                        child: _LifecycleBanner(plant: plant),
                      ),
                    if (pws != null)
                      SliverToBoxAdapter(
                        child: _CareAlerts(pws: pws),
                      ),
                    SliverToBoxAdapter(
                      child: _PlantInfoCard(plant: plant, pws: pws, soilName: soil?.name, soilComposition: soil?.composition),
                    ),
                    // Reminders of plants that are no longer active are
                    // ignored, so they aren't offered either.
                    if (plant.isActive)
                      SliverToBoxAdapter(
                        child: PlantRemindersCard(plantId: plantId),
                      ),
                    SliverToBoxAdapter(
                      child: _ViewSelector(plantId: plantId),
                    ),
                    if (activeView == PlantDetailView.diary) ...[
                      SliverToBoxAdapter(
                        child: _EntriesHeader(plantId: plantId),
                      ),
                      // Timeline Entries
                      entriesAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                              child: Text(context.l10n.errorGeneric('$e'))),
                        ),
                        data: (entries) {
                          final filteredEntries = entries
                              .where((e) => activeFilters.contains(e.type))
                              .toList();

                          switch (activeSort) {
                            case EntrySortOption.dateAsc:
                              filteredEntries.sort(
                                  (a, b) => a.date.compareTo(b.date));
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
                                    style:
                                        const TextStyle(color: Colors.white70),
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
                                onDelete: () => _deleteEntry(
                                    context, ref, filteredEntries[i]),
                              ),
                              childCount: filteredEntries.length,
                            ),
                          );
                        },
                      ),
                    ] else if (activeView == PlantDetailView.charts)
                      entriesAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                              child: Text(context.l10n.errorGeneric('$e'))),
                        ),
                        data: (entries) => SliverToBoxAdapter(
                          child:
                              PlantInsightsView(entries: entries, pws: pws),
                        ),
                      )
                    else
                      entriesAsync.when(
                        loading: () => const SliverToBoxAdapter(
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => SliverToBoxAdapter(
                          child: Center(
                              child: Text(context.l10n.errorGeneric('$e'))),
                        ),
                        data: (entries) =>
                            PlantPhotosSliver(entries: entries),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                  ),
                ),
              ),
            ],
          ),
          floatingActionButton: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.small(
                heroTag: 'add_entry',
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AddEntryScreen(plantId: plantId),
                  ),
                ),
                child: const Icon(Icons.note_add_outlined),
              ),
              if (plant.isActive) ...[
                const SizedBox(height: 8),
                FloatingActionButton.extended(
                  heroTag: 'irrigate',
                  onPressed: () => _irrigate(context, ref),
                  icon: const Icon(Icons.water_drop),
                  label: Text(context.l10n.wateredNow),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _irrigate(BuildContext context, WidgetRef ref) async {
    try {
      final entry = EntryModel(
        id: const Uuid().v4(),
        plantId: plantId,
        date: DateTime.now(),
        type: EntryType.irrigation,
        createdAt: DateTime.now(),
      );

      await ref.read(entriesNotifierProvider(plantId).notifier).create(entry);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.irrigationRecorded),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.irrigationRecordError('$e')),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
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
      await ref.read(entriesNotifierProvider(plantId).notifier).delete(entry.id);
    }
  }

  static String _statusActionLabel(BuildContext context, PlantStatus status) =>
      switch (status) {
        PlantStatus.active => context.l10n.plantStatusReactivate,
        PlantStatus.dead => context.l10n.plantStatusMarkDead,
        PlantStatus.donated => context.l10n.plantStatusMarkDonated,
        PlantStatus.archived => context.l10n.plantStatusArchive,
      };

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final plant = await ref.read(plantsRepositoryProvider).getById(plantId);
    if (!context.mounted) return;
    final canArchive = plant != null && plant.isActive;
    final choice = await showDialog<_DeleteChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deletePlantTitle),
        content: Text(canArchive
            ? '${ctx.l10n.deletePlantBody}\n\n${ctx.l10n.deletePlantArchiveHint}'
            : ctx.l10n.deletePlantBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(ctx.l10n.cancel),
          ),
          if (canArchive)
            TextButton(
              onPressed: () => Navigator.pop(ctx, _DeleteChoice.archive),
              child: Text(ctx.l10n.plantStatusArchive),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, _DeleteChoice.delete),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (!context.mounted) return;
    final notifier = ref.read(plantsNotifierProvider.notifier);
    switch (choice) {
      case _DeleteChoice.archive:
        await notifier.setStatus(plantId, PlantStatus.archived);
      case _DeleteChoice.delete:
        final navigator = Navigator.of(context);
        await notifier.delete(plantId);
        navigator.pop();
      case null:
        break;
    }
  }
}

enum _DeleteChoice { archive, delete }

/// Tells what happened to a plant that left the collection, and when.
class _LifecycleBanner extends StatelessWidget {
  final PlantModel plant;

  const _LifecycleBanner({required this.plant});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final label = plant.status.label(l10n);
    final since = plant.statusChangedAt;
    return PlantStatusBanner(
      emoji: plant.status.emoji,
      title: since == null
          ? label
          : l10n.plantStatusSince(
              label, DateFormat.yMd(l10n.localeName).format(since)),
      subtitle: l10n.plantInactiveHint,
      tone: StatusTone.neutral,
    );
  }
}

class _HeaderSection extends ConsumerWidget {
  final PlantModel plant;
  final PlantWithSpecies? pws;

  const _HeaderSection({required this.plant, required this.pws});

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

class _PlantInfoCard extends ConsumerWidget {
  final PlantModel plant;
  final PlantWithSpecies? pws;
  final String? soilName;
  final String? soilComposition;

  const _PlantInfoCard({required this.plant, required this.pws, this.soilName, this.soilComposition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final alertStatus =
        ref.watch(plantAlertStatusProvider(plant.id)).value ?? noPlantAlerts;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              children: [
                _row(
                  context,
                  Icons.terrain_outlined,
                  context.l10n.soilLabel,
                  soilName ?? context.l10n.notInformed,
                  transparencyEnabled,
                ),
                if (soilComposition != null) ...[
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.only(left: 32),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        soilComposition!,
                        style: TextStyle(
                          fontSize: 12,
                          color: transparencyEnabled
                              ? Colors.white54
                              : Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ),
                ],
                const Divider(color: Colors.white10, height: 16),
                _row(
                  context,
                  Icons.location_on_outlined,
                  context.l10n.locationLabel,
                  pws?.location?.name ??
                      plant.location ??
                      context.l10n.notInformed,
                  transparencyEnabled,
                ),
                const Divider(color: Colors.white10, height: 16),
                _row(
                  context,
                  Icons.calendar_today_outlined,
                  context.l10n.acquiredOnLabel,
                  DateFormat.yMd(context.l10n.localeName)
                      .format(plant.acquisitionDate),
                  transparencyEnabled,
                ),
                if (pws?.effectiveFrequencyDays != null) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _row(
                    context,
                    Icons.opacity_outlined,
                    context.l10n.irrigationFrequencyShort,
                    context.l10n.daysCount(pws!.effectiveFrequencyDays!),
                    transparencyEnabled,
                  ),
                ],
                if (alertStatus.hasActivePest) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.pest,
                    context.l10n.pestBadge,
                    PlantStatusChip(
                      label: _severityLabel(context, alertStatus.pestSeverity),
                      tone: StatusTone.forSeverity(alertStatus.pestSeverity),
                    ),
                    transparencyEnabled,
                  ),
                ],
                if (alertStatus.hasActiveChlorosis) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.chlorosis,
                    context.l10n.entryTypeChlorosis,
                    PlantStatusChip(
                      label: _severityLabel(
                          context, alertStatus.chlorosisSeverity),
                      tone: StatusTone.forSeverity(
                          alertStatus.chlorosisSeverity),
                    ),
                    transparencyEnabled,
                  ),
                ],
                if (pws != null &&
                    (pws!.pesticideUnderActiveControl ||
                        pws!.needsPesticideReapplication)) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _statusRow(
                    context,
                    EntryType.pesticide,
                    context.l10n.entryTypePesticide,
                    pws!.needsPesticideReapplication
                        ? PlantStatusChip(
                            label: context.l10n.pesticideReapplyBadge,
                            tone: StatusTone.danger,
                          )
                        : PlantStatusChip(
                            label: context.l10n.pesticideActiveControlBadge,
                            tone: StatusTone.positive,
                          ),
                    transparencyEnabled,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool transparencyEnabled,
  ) =>
      Row(
        children: [
          Icon(icon, size: 20, color: transparencyEnabled ? Colors.white60 : null),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: transparencyEnabled ? Colors.white70 : null)),
          const Spacer(),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: transparencyEnabled ? Colors.white : null)),
        ],
      );

  String _severityLabel(BuildContext context, int? v) => switch (v) {
        1 => context.l10n.severityMild,
        2 => context.l10n.severityModerate,
        3 => context.l10n.severitySevere,
        _ => context.l10n.severityActive,
      };

  Widget _statusRow(
    BuildContext context,
    EntryType type,
    String label,
    Widget chip,
    bool transparencyEnabled,
  ) =>
      Row(
        children: [
          SizedBox(
            width: 20,
            child: Text(
              type.emoji,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15),
            ),
          ),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  color: transparencyEnabled ? Colors.white70 : null)),
          const Spacer(),
          chip,
        ],
      );
}

class _CareAlerts extends StatelessWidget {
  final PlantWithSpecies pws;

  const _CareAlerts({required this.pws});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final wateringDays = pws.daysRelativeToSchedule;
    final pesticideDays = pws.pesticideDaysRelative;

    String overdueText(int days) =>
        days == 0 ? l10n.dueToday : l10n.daysOverdue(days);

    final banners = [
      if (pws.needsWatering && wateringDays != null)
        PlantStatusBanner(
          emoji: EntryType.irrigation.emoji,
          title: l10n.needsWater,
          subtitle: pws.plant.lastIrrigatedAt == null
              ? l10n.lastWateringNotRecorded
              : overdueText(wateringDays),
          tone: StatusTone.danger,
        ),
      if (pws.needsPesticideReapplication && pesticideDays != null)
        PlantStatusBanner(
          emoji: EntryType.pesticide.emoji,
          title: l10n.needsPesticideApplication,
          subtitle: overdueText(pesticideDays),
          tone: StatusTone.danger,
        )
      else if (pws.pesticideReapplicationApproaching && pesticideDays != null)
        PlantStatusBanner(
          emoji: EntryType.pesticide.emoji,
          title: l10n.pesticideApproachingTitle,
          subtitle: l10n.nextPesticideInDays(-pesticideDays),
          tone: StatusTone.warning,
        ),
    ];

    if (banners.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Column(children: banners),
    );
  }
}

class _ViewSelector extends ConsumerWidget {
  final String plantId;
  const _ViewSelector({required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(plantDetailViewNotifierProvider(plantId));
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? Colors.black.withValues(alpha: 0.3)
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: transparencyEnabled
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.transparent,
              ),
            ),
            child: Row(
              children: [
                for (final view in PlantDetailView.values)
                  Expanded(
                    child: _Segment(
                      view: view,
                      selected: view == active,
                      transparent: transparencyEnabled,
                      onTap: () => ref
                          .read(plantDetailViewNotifierProvider(plantId)
                              .notifier)
                          .setView(view),
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

class _Segment extends StatelessWidget {
  final PlantDetailView view;
  final bool selected;
  final bool transparent;
  final VoidCallback onTap;

  const _Segment({
    required this.view,
    required this.selected,
    required this.transparent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final icon = switch (view) {
      PlantDetailView.diary => Icons.article_outlined,
      PlantDetailView.charts => Icons.show_chart,
      PlantDetailView.photos => Icons.photo_library_outlined,
    };
    final fg = selected
        ? (transparent ? Colors.white : colorScheme.onPrimaryContainer)
        : (transparent ? Colors.white60 : colorScheme.onSurfaceVariant);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? (transparent
                  ? Colors.white.withValues(alpha: 0.18)
                  : colorScheme.primaryContainer)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              view.label(context.l10n),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EntriesHeader extends ConsumerWidget {
  final String plantId;
  const _EntriesHeader({required this.plantId});

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
          Text(
            context.l10n.entriesTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list, color: Colors.white70),
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
                  : Colors.white70,
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
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
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
                    color: Colors.white30,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.entryTypesTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
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
                        .read(
                            entryFiltersNotifierProvider(plantId).notifier)
                        .toggleFilter(type),
                    title: Text(
                      '${type.emoji}  ${type.label(context.l10n)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    checkColor: Colors.white,
                    activeColor: colorScheme.primary,
                    side: const BorderSide(color: Colors.white30),
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
              color: Colors.black.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 8, 4),
                  child: Row(
                    children: [
                      Text(
                        context.l10n.entryTypesTitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
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
                        icon: const Icon(Icons.close,
                            color: Colors.white54, size: 18),
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
                        .read(
                            entryFiltersNotifierProvider(plantId).notifier)
                        .toggleFilter(type),
                    title: Text(
                      '${type.emoji}  ${type.label(context.l10n)}',
                      style: const TextStyle(color: Colors.white),
                    ),
                    checkColor: Colors.white,
                    activeColor: colorScheme.primary,
                    side: const BorderSide(color: Colors.white30),
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
