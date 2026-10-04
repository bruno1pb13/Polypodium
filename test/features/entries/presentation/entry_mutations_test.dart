import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/data/entries_repository.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';
import 'package:polypodium/features/entries/presentation/providers/entries_providers.dart';
import 'package:polypodium/features/plants/data/plants_repository.dart';
import 'package:polypodium/features/plants/presentation/providers/plants_providers.dart';

class MockPlantsRepository extends Mock implements PlantsRepository {}

class MockEntriesRepository extends Mock implements EntriesRepository {}

void main() {
  late MockPlantsRepository plantsRepo;
  late MockEntriesRepository entriesRepo;
  late ProviderContainer container;

  setUpAll(() {
    registerFallbackValue(EntryModel(
      id: '',
      plantId: '',
      date: DateTime(2026),
      type: EntryType.other,
      createdAt: DateTime(2026),
    ));
  });

  setUp(() {
    plantsRepo = MockPlantsRepository();
    entriesRepo = MockEntriesRepository();
    when(() => entriesRepo.create(any())).thenAnswer((_) async {});
    when(() => plantsRepo.refreshPlantStatus(any(),
        reschedule: any(named: 'reschedule'))).thenAnswer((_) async {});
    when(() => plantsRepo.refreshPesticideStatus(any(),
        reschedule: any(named: 'reschedule'))).thenAnswer((_) async {});
    when(() => plantsRepo.rescheduleNotifications()).thenAnswer((_) async {});

    container = ProviderContainer(overrides: [
      plantsRepositoryProvider.overrideWithValue(plantsRepo),
      entriesRepositoryProvider.overrideWithValue(entriesRepo),
    ]);
  });

  tearDown(() => container.dispose());

  test('recordIrrigation creates one entry per plant and reschedules once',
      () async {
    await container
        .read(entryMutationsProvider)
        .recordIrrigation(['p1', 'p2', 'p3']);

    final created = verify(() => entriesRepo.create(captureAny()))
        .captured
        .cast<EntryModel>();
    expect(created.map((e) => e.plantId), ['p1', 'p2', 'p3']);
    expect(created.every((e) => e.type == EntryType.irrigation), isTrue);

    for (final id in ['p1', 'p2', 'p3']) {
      verify(() => plantsRepo.refreshPlantStatus(id, reschedule: false))
          .called(1);
    }
    verify(() => plantsRepo.rescheduleNotifications()).called(1);
  });

  test('entries that do not affect reminders skip rescheduling', () async {
    await container.read(entryMutationsProvider).create(EntryModel(
          id: 'e1',
          plantId: 'p1',
          date: DateTime(2026),
          type: EntryType.pest,
          createdAt: DateTime(2026),
        ));

    verify(() => entriesRepo.create(any())).called(1);
    verifyNever(() => plantsRepo.rescheduleNotifications());
  });

  test('entries of a type with recurring reminders reschedule', () async {
    await container.read(entryMutationsProvider).create(EntryModel(
          id: 'e1',
          plantId: 'p1',
          date: DateTime(2026),
          type: EntryType.fertilizer,
          createdAt: DateTime(2026),
        ));

    verify(() => plantsRepo.rescheduleNotifications()).called(1);
    verifyNever(() => plantsRepo.refreshPlantStatus(any(),
        reschedule: any(named: 'reschedule')));
  });

  test('deleting such an entry reschedules too', () async {
    when(() => entriesRepo.getById('e1')).thenAnswer((_) async => EntryModel(
          id: 'e1',
          plantId: 'p1',
          date: DateTime(2026),
          type: EntryType.pruning,
          createdAt: DateTime(2026),
        ));
    when(() => entriesRepo.delete('e1')).thenAnswer((_) async {});

    await container.read(entryMutationsProvider).delete('e1');

    verify(() => plantsRepo.rescheduleNotifications()).called(1);
  });
}
