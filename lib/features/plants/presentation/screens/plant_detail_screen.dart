import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/widgets/fullscreen_image_viewer.dart';
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
    final activeSort = ref.watch(entrySortNotifierProvider(plantId));

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
                    SliverToBoxAdapter(
                      child: _PlantInfoCard(plant: plant, pws: pws, soilName: soil?.name, soilComposition: soil?.composition),
                    ),
                    if (pws != null)
                      SliverToBoxAdapter(
                        child: _IrrigationStatusCard(pws: pws),
                      ),
                    SliverToBoxAdapter(
                      child: _EntriesHeader(plantId: plantId),
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

                        switch (activeSort) {
                          case EntrySortOption.dateAsc:
                            filteredEntries.sort(
                                (a, b) => a.date.compareTo(b.date));
                          case EntrySortOption.typeAZ:
                            filteredEntries.sort(
                                (a, b) => a.type.label.compareTo(b.type.label));
                          case EntrySortOption.dateDesc:
                            break;
                        }

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
      await ref.read(entriesNotifierProvider(plantId).notifier).delete(entry.id);
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
    final alertStatus = ref.watch(plantAlertStatusProvider(plant.id)).value
        ?? (hasActiveChlorosis: false, chlorosisSeverity: null, hasActivePest: false, pestSeverity: null);

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
                if (alertStatus.hasActiveChlorosis) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _alertRow(
                    context,
                    '🟡',
                    'Clorose',
                    _severityLabel(alertStatus.chlorosisSeverity),
                    const Color(0xFFEAB308),
                    transparencyEnabled,
                  ),
                ],
                if (alertStatus.hasActivePest) ...[
                  const Divider(color: Colors.white10, height: 16),
                  _alertRow(
                    context,
                    '🐛',
                    'Praga',
                    _severityLabel(alertStatus.pestSeverity),
                    const Color(0xFFF97316),
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

  String _severityLabel(int? v) => switch (v) {
        1 => 'Leve',
        2 => 'Moderada',
        3 => 'Severa',
        _ => 'Ativa',
      };

  Widget _alertRow(
    BuildContext context,
    String emoji,
    String label,
    String badgeLabel,
    Color alertColor,
    bool transparencyEnabled,
  ) =>
      Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 10),
          Text(label,
              style: TextStyle(
                  color: transparencyEnabled ? Colors.white70 : null)),
          const Spacer(),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: alertColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              badgeLabel,
              style: TextStyle(
                color: alertColor,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
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
          const Text(
            'Registros',
            style: TextStyle(
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
                tooltip: 'Filtrar tipos',
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
            tooltip: 'Ordenar',
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
                          Text(s.label),
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
                      const Text(
                        'Tipos de registro',
                        style: TextStyle(
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
                            'Todos',
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
                      '${type.emoji}  ${type.label}',
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
                      const Text(
                        'Tipos de registro',
                        style: TextStyle(
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
                            'Todos',
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
                      '${type.emoji}  ${type.label}',
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
