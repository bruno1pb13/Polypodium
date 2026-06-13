import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/providers/entry_filters_provider.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../entries/presentation/widgets/entry_timeline_item.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../domain/plant_model.dart';
import '../providers/plants_providers.dart';
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

    return plantsAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Erro: $e'))),
      data: (plants) {
        final plant = plants.where((p) => p.id == plantId).firstOrNull;
        if (plant == null) {
          return const Scaffold(
            body: Center(child: Text('Planta não encontrada')),
          );
        }
        final species = speciesAsync.valueOrNull
            ?.where((s) => s.id == plant.speciesId)
            .firstOrNull;

        final location = plant.locationId != null
            ? locationsAsync.valueOrNull
                ?.where((l) => l.id == plant.locationId)
                .firstOrNull
            : null;

        final soil = soilsAsync.valueOrNull
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
                    await Future.wait([
                      ref.read(plantsNotifierProvider.future).catchError((_) {}),
                      ref.read(entriesNotifierProvider(plantId).future).catchError((_) {}),
                    ]);
                  },
                  color: Colors.white,
                  backgroundColor: Colors.black54,
                  child: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: _HeaderSection(plant: plant, pws: pws),
                    ),
                    SliverToBoxAdapter(
                      child: _PlantInfoCard(plant: plant, pws: pws, soilName: soil?.name, soilComposition: soil?.composition),
                    ),
                    if (pws != null)
                      SliverToBoxAdapter(
                        child: _IrrigationStatusCard(pws: pws),
                      ),
                    // Filters
                    SliverToBoxAdapter(
                      child: _FilterSection(plantId: plantId),
                    ),
                    // Timeline Entries
                    entriesAsync.when(
                      loading: () => const SliverToBoxAdapter(
                        child: Center(child: CircularProgressIndicator()),
                      ),
                      error: (e, _) => SliverToBoxAdapter(
                        child: Center(child: Text('Erro: $e')),
                      ),
                      data: (entries) {
                        final filteredEntries = entries
                            .where((e) => activeFilters.contains(e.type))
                            .toList();

                        if (filteredEntries.isEmpty) {
                          return const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(48),
                              child: Center(
                                child: Text(
                                  'Nenhum registro encontrado',
                                  style: TextStyle(color: Colors.white70),
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
                              onDelete: () =>
                                  _deleteEntry(context, ref, filteredEntries[i]),
                            ),
                            childCount: filteredEntries.length,
                          ),
                        );
                      },
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
              const SizedBox(height: 8),
              FloatingActionButton.extended(
                heroTag: 'irrigate',
                onPressed: () => _irrigate(context, ref),
                icon: const Icon(Icons.water_drop),
                label: const Text('Reguei agora'),
              ),
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
          const SnackBar(
            content: Text('Irrigação registrada!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao registrar irrigação: $e'),
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
        title: const Text('Deletar registro?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(entriesNotifierProvider(plantId).notifier).delete(
            entry.id,
            photoPath: entry.photoPath,
          );
    }
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deletar planta?'),
        content: const Text('Todos os registros desta planta serão removidos.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final navigator = Navigator.of(context);
      await ref.read(plantsNotifierProvider.notifier).delete(plantId);
      navigator.pop();
    }
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
          _PlantPhoto(photoPath: photoAsync.valueOrNull),
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
            ? Image.file(
                File(photoPath!),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _PhotoPlaceholder(),
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
                  'Solo',
                  soilName ?? 'Não informado',
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
                          color: transparencyEnabled ? Colors.white54 : Colors.black54,
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
                  'Localização',
                  pws?.location?.name ?? plant.location ?? 'Não informada',
                  transparencyEnabled,
                ),
                const Divider(color: Colors.white10, height: 16),
                _row(
                  context,
                  Icons.calendar_today_outlined,
                  'Adquirida em',
                  DateFormat('dd/MM/yyyy').format(plant.acquisitionDate),
                  transparencyEnabled,
                ),
                if (pws?.effectiveFrequencyDays != null) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _row(
                    context,
                    Icons.opacity_outlined,
                    'Frequência de irrigação',
                    '${pws!.effectiveFrequencyDays} dias',
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
          Icon(
            icon,
            size: 20,
            color: transparencyEnabled ? Colors.white60 : null,
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              color: transparencyEnabled ? Colors.white70 : null,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: transparencyEnabled ? Colors.white : null,
            ),
          ),
        ],
      );
}

class _IrrigationStatusCard extends ConsumerWidget {
  final PlantWithSpecies pws;

  const _IrrigationStatusCard({required this.pws});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final overdue = pws.needsWatering;
    final days = pws.daysRelativeToSchedule;

    if (days == null) return const SizedBox.shrink();

    final cardColor = overdue
        ? (transparencyEnabled
            ? colorScheme.errorContainer.withValues(alpha: 0.8)
            : colorScheme.errorContainer)
        : (transparencyEnabled
            ? colorScheme.primaryContainer.withValues(alpha: 0.6)
            : colorScheme.primaryContainer);

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
              color: cardColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  overdue ? Icons.water_drop : Icons.check_circle_outline,
                  color: overdue ? colorScheme.error : colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        overdue ? 'Precisa de água!' : 'Irrigação em dia',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: overdue
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                      Text(
                        pws.plant.lastIrrigatedAt == null
                            ? 'Última rega não registrada'
                            : overdue
                                ? '$days dia(s) em atraso'
                                : 'Próxima irrigação em ${-days} dia(s)',
                        style: TextStyle(
                          fontSize: 13,
                          color: overdue
                              ? colorScheme.onErrorContainer
                              : colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ],
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

class _FilterSection extends ConsumerWidget {
  final String plantId;

  const _FilterSection({required this.plantId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeFilters = ref.watch(entryFiltersNotifierProvider(plantId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            'Registros',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: EntryType.values.map((type) {
              final isActive = activeFilters.contains(type);
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(type.label),
                  selected: isActive,
                  onSelected: (_) => ref
                      .read(entryFiltersNotifierProvider(plantId).notifier)
                      .toggleFilter(type),
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  selectedColor: Theme.of(context).colorScheme.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: isActive ? Colors.white : Colors.white70,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(
                      color: isActive ? Colors.transparent : Colors.white24,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
