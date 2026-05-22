import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../entries/presentation/widgets/entry_list_item.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
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
    final entriesAsync = ref.watch(entriesNotifierProvider(plantId));

    return plantsAsync.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
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

        final pws = species != null
            ? PlantWithSpecies(
                plant: plant,
                species: species,
                location: location,
              )
            : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(plant.nickname),
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
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _PlantInfoCard(plant: plant, pws: pws),
              ),
              if (pws != null)
                SliverToBoxAdapter(
                  child: _IrrigationStatusCard(pws: pws),
                ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text(
                    'Registros',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              entriesAsync.when(
                loading: () => const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, _) => SliverToBoxAdapter(
                  child: Center(child: Text('Erro: $e')),
                ),
                data: (entries) => entries.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(32),
                          child: Center(child: Text('Nenhum registro ainda')),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (ctx, i) => EntryListItem(
                            entry: entries[i],
                            onDelete: () =>
                                _deleteEntry(context, ref, entries[i]),
                          ),
                          childCount: entries.length,
                        ),
                      ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 80)),
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

      // Now we only need to create the entry.
      // The EntriesNotifier will trigger refreshPlantStatus if it's an irrigation.
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
        content: const Text(
            'Todos os registros desta planta serão removidos.'),
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
      await ref.read(plantsNotifierProvider.notifier).delete(plantId);
      Navigator.pop(context);
    }
  }
}

class _PlantInfoCard extends StatelessWidget {
  final PlantModel plant;
  final PlantWithSpecies? pws;

  const _PlantInfoCard({required this.plant, required this.pws});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (pws != null) ...[
              Text(pws!.species.scientificName,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 4),
            ],
            _row('Solo', plant.soilType.label),
            if (pws?.location != null)
              _row('Localização', pws!.location!.name)
            else if (plant.location != null)
              _row('Localização (antiga)', plant.location!),
            _row(
              'Adquirida em',
              DateFormat('dd/MM/yyyy').format(plant.acquisitionDate),
            ),
            if (pws != null)
              _row(
                'Frequência de irrigação',
                '${pws!.effectiveFrequencyDays} dias',
              ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Text('$label: ',
                style: const TextStyle(fontWeight: FontWeight.w500)),
            Text(value),
          ],
        ),
      );
}

class _IrrigationStatusCard extends StatelessWidget {
  final PlantWithSpecies pws;

  const _IrrigationStatusCard({required this.pws});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final overdue = pws.needsWatering;
    final days = pws.daysRelativeToSchedule;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: overdue ? colorScheme.errorContainer : colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      fontWeight: FontWeight.w600,
                      color: overdue
                          ? colorScheme.onErrorContainer
                          : colorScheme.onPrimaryContainer,
                    ),
                  ),
                  Text(
                    pws.plant.lastIrrigatedAt == null
                        ? 'Nunca regada'
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
    );
  }
}
