import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database_provider.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../data/reminders_repository.dart';
import '../../domain/reminder_model.dart';

part 'reminders_providers.g.dart';

@Riverpod(keepAlive: true)
RemindersRepository remindersRepository(Ref ref) =>
    RemindersRepository(ref.watch(appDatabaseProvider));

/// A plant's reminders with their derived due dates. Re-emits when an entry
/// of the plant is created or deleted, which moves the due date.
@riverpod
Stream<List<ReminderStatus>> plantReminders(Ref ref, String plantId) =>
    ref.watch(remindersRepositoryProvider).watchStatusesByPlant(plantId);

/// Every active reminder across all plants (enabled or not), for the agenda.
@riverpod
Stream<List<ReminderStatus>> allReminders(Ref ref) =>
    ref.watch(remindersRepositoryProvider).watchAllStatuses();

@Riverpod(keepAlive: true)
ReminderMutations reminderMutations(Ref ref) => ReminderMutations(ref);

/// Reminder save/delete plus their side effects (notification reschedule,
/// sync trigger). KeepAlive for the same reason as EntryMutations: the work
/// must survive the dialog/screen that started it.
class ReminderMutations {
  ReminderMutations(this._ref);

  final Ref _ref;

  Future<void> save(ReminderModel reminder) async {
    await _ref.read(remindersRepositoryProvider).save(reminder);
    await _afterChange();
  }

  Future<void> delete(String id) async {
    await _ref.read(remindersRepositoryProvider).delete(id);
    await _afterChange();
  }

  Future<void> _afterChange() async {
    await _ref.read(plantsRepositoryProvider).rescheduleNotifications();
    try {
      final syncService = _ref.read(syncServiceProvider);
      if (syncService.isLoggedIn) {
        _ref.read(syncNotifierProvider.notifier).sync().catchError((_) {});
      }
    } catch (_) {
      // SharedPreferences might not be ready in tests
    }
  }
}
