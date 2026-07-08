import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/enums.dart';
import '../../../../core/notifications/notification_provider.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../data/plants_repository.dart';
import '../../domain/plant_model.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../soils/presentation/providers/soils_providers.dart';
import '../../../species/presentation/providers/species_providers.dart';

import '../../../../core/sync/sync_providers.dart';

part 'plants_providers.g.dart';

@Riverpod(keepAlive: true)
PlantsRepository plantsRepository(Ref ref) {
  return PlantsRepository(
    ref.watch(appDatabaseProvider),
    ref.watch(notificationServiceProvider),
  );
}

@riverpod
class PlantsNotifier extends _$PlantsNotifier {
  @override
  Stream<List<PlantModel>> build() =>
      ref.watch(plantsRepositoryProvider).watchAll();

  Future<void> save(PlantModel plant) async {
    final oldPlants = await future;
    final oldPlant = oldPlants.where((p) => p.id == plant.id).firstOrNull;

    await ref.read(plantsRepositoryProvider).save(plant);

    final note = await _generateHistoryNote(oldPlant, plant);
    if (note != null) {
      final entry = EntryModel(
        id: const Uuid().v4(),
        plantId: plant.id,
        date: DateTime.now(),
        type: EntryType.history,
        note: note,
        createdAt: DateTime.now(),
      );
      // We read the notifier and call create.
      // Note: this will also trigger refreshPlantStatus if it were an irrigation,
      // but for history it just creates the entry and invalidates entries.
      await ref.read(entriesNotifierProvider(plant.id).notifier).create(entry);
    }
    
    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }

  Future<String?> _generateHistoryNote(PlantModel? old, PlantModel next) async {
    if (old == null) {
      // Creation
      final species = await ref.read(speciesNotifierProvider.future).then(
          (list) => list.where((s) => s.id == next.speciesId).firstOrNull);
      final location = next.locationId == null
          ? null
          : await ref.read(locationsNotifierProvider.future).then(
              (list) => list.where((l) => l.id == next.locationId).firstOrNull);

      final sb = StringBuffer();
      sb.writeln('Planta adicionada ao sistema:');
      sb.writeln('• Apelido: ${next.nickname}');
      if (species != null) {
        sb.writeln(
            '• Espécie: ${species.popularName} (${species.scientificName})');
      }
      final soil = await ref.read(soilsNotifierProvider.future).then(
          (list) => list.where((s) => s.id == next.soilId).firstOrNull);
      sb.writeln('• Solo: ${soil?.name ?? 'Desconhecido'}');
      if (location != null) {
        sb.writeln('• Localização: ${location.name}');
      }
      sb.writeln(
          '• Adquirida em: ${DateFormat('dd/MM/yyyy').format(next.acquisitionDate)}');
      if (next.irrigationFrequencyDays != null) {
        sb.writeln(
            '• Rega personalizada: ${next.irrigationFrequencyDays} dias');
      }
      return sb.toString().trim();
    }

    // Update
    final changes = <String>[];
    if (old.nickname != next.nickname) {
      changes.add('Apelido: ${old.nickname} → ${next.nickname}');
    }
    if (old.speciesId != next.speciesId) {
      final speciesList = await ref.read(speciesNotifierProvider.future);
      final oldS = speciesList.where((s) => s.id == old.speciesId).firstOrNull;
      final nextS =
          speciesList.where((s) => s.id == next.speciesId).firstOrNull;
      changes.add(
          'Espécie: ${oldS?.popularName ?? 'Desconhecida'} → ${nextS?.popularName ?? 'Desconhecida'}');
    }
    if (old.soilId != next.soilId) {
      final soilList = await ref.read(soilsNotifierProvider.future);
      final oldSoil = soilList.where((s) => s.id == old.soilId).firstOrNull;
      final nextSoil = soilList.where((s) => s.id == next.soilId).firstOrNull;
      changes.add(
          'Solo: ${oldSoil?.name ?? 'Desconhecido'} → ${nextSoil?.name ?? 'Desconhecido'}');
    }
    if (old.locationId != next.locationId) {
      final locList = await ref.read(locationsNotifierProvider.future);
      final oldL = locList.where((l) => l.id == old.locationId).firstOrNull;
      final nextL = locList.where((l) => l.id == next.locationId).firstOrNull;
      changes.add(
          'Localização: ${oldL?.name ?? 'Nenhuma'} → ${nextL?.name ?? 'Nenhuma'}');
    }
    if (old.irrigationFrequencyDays != next.irrigationFrequencyDays) {
      changes.add(
          'Frequência de rega: ${old.irrigationFrequencyDays ?? 'Padrão'} → ${next.irrigationFrequencyDays ?? 'Padrão'} dias');
    }
    if (old.acquisitionDate.day != next.acquisitionDate.day ||
        old.acquisitionDate.month != next.acquisitionDate.month ||
        old.acquisitionDate.year != next.acquisitionDate.year) {
      changes.add(
          'Data de aquisição: ${DateFormat('dd/MM/yyyy').format(old.acquisitionDate)} → ${DateFormat('dd/MM/yyyy').format(next.acquisitionDate)}');
    }

    if (changes.isEmpty) return null;
    return 'Informações atualizadas:\n${changes.map((c) => '• $c').join('\n')}';
  }

  Future<void> irrigate(String plantId) async {
    await ref.read(plantsRepositoryProvider).irrigate(plantId);

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }

  Future<void> delete(String plantId) async {
    await ref.read(plantsRepositoryProvider).delete(plantId);

    // Trigger immediate sync if logged in
    try {
      final syncService = ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }
}

/// Combines each plant with its resolved species for home-screen display.
@riverpod
Future<List<PlantWithSpecies>> plantsWithSpecies(Ref ref) async {
  // Watch all futures at once to keep them alive and potentially run in parallel
  final plantsStream = ref.watch(plantsNotifierProvider.future);
  final speciesStream = ref.watch(speciesNotifierProvider.future);
  final locationsStream = ref.watch(locationsNotifierProvider.future);

  final plants = await plantsStream;
  final species = await speciesStream;
  final locations = await locationsStream;

  final speciesById = {for (final s in species) s.id: s};
  final locationsById = {for (final l in locations) l.id: l};

  // Pre-fetch entries sync status for all plants to avoid N+1 queries if possible,
  // but for simplicity we'll fetch per plant for now as it's a small list.
  final db = ref.watch(appDatabaseProvider);

  final results = <PlantWithSpecies>[];
  for (final p in plants) {
    if (!speciesById.containsKey(p.speciesId)) continue;

    final species = speciesById[p.speciesId]!;
    
    // Check if any entry for this plant is pending sync
    final hasPendingEntries = await db.entriesDao.hasPendingSync(p.id);
    
    // Check if the location is pending sync
    final location = p.locationId != null ? locationsById[p.locationId] : null;
    final locationPending = location?.syncStatus == SyncStatus.pending;
    
    // Determine overall sync status: if plant, species, location, or any entry is pending, overall is pending
    final overallSyncStatus = (p.syncStatus == SyncStatus.pending || 
                               species.syncStatus == SyncStatus.pending || 
                               locationPending ||
                               hasPendingEntries) 
                               ? SyncStatus.pending 
                               : SyncStatus.synced;

    results.add(PlantWithSpecies(
      plant: p.copyWith(syncStatus: overallSyncStatus),
      species: species,
      location: location,
    ));
  }

  return results;
}
