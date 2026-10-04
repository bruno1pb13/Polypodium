import 'dart:io';
import 'dart:ui' show DartPluginRegistrant;

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:uuid/uuid.dart';

import '../database/app_database.dart';
import '../enums.dart';
import '../storage/photo_storage.dart';
import '../../features/entries/data/entries_repository.dart';
import '../../features/entries/domain/entry_model.dart';
import '../../features/plants/data/plants_repository.dart';
import '../../features/plants/domain/plant_model.dart';
import '../../features/reminders/domain/reminder_model.dart';
import '../../features/workspaces/data/workspace_repository.dart';
import '../../features/workspaces/domain/workspace_model.dart';
import '../../features/workspaces/domain/workspace_paths.dart';
import '../l10n/l10n.dart';
import 'reminder_payload.dart';

/// Runs in a background isolate when a notification action button that
/// doesn't open the app ("Watered", "Remind in 3 h") is tapped — the plugin
/// starts a headless engine for it, even if the app is in the foreground.
@pragma('vm:entry-point')
void onBackgroundNotificationResponse(NotificationResponse response) {
  NotificationService._handleBackgroundResponse(response);
}

abstract interface class INotificationService {
  /// Rebuilds the whole reminder schedule from [plants] — the full set of
  /// active plants — and [reminders], their enabled recurring care
  /// reminders. Anything previously scheduled that is no longer due
  /// (watered meanwhile, deleted, archived, disabled) is cancelled.
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
      {List<PlantReminder> reminders = const []});
}

class NotificationService implements INotificationService {
  const NotificationService();

  static const irrigationCheckTask = 'irrigation-check';
  static const _channelId = 'polypodium_irrigation';
  static const _pesticideChannelId = 'polypodium_defensivo';
  static const _careChannelId = 'polypodium_care';

  /// Groups every irrigation reminder in the notification shade (Android
  /// bundles by groupKey; iOS threads by threadIdentifier).
  static const _groupKey = 'polypodium_irrigation_group';
  static const _pesticideGroupKey = 'polypodium_defensivo_group';
  static const _careGroupKey = 'polypodium_care_group';

  /// Notification ids are namespaced by "kind" (added to the date-based id)
  /// so an irrigation reminder and a pesticide reminder due on the same
  /// calendar date never collide/overwrite each other.
  static const _pesticideIdOffset = 1000000000;

  /// Recurring care reminders use [_careIdOffset] + entry type index ×
  /// 1 000 000 + days since 1970-01-01 of the due date. Days stay below
  /// 1 000 000 until the year 4707 and EntryType has ~10 values, so these
  /// ids live in [500 000 000, 600 000 000): above every irrigation id
  /// (yyyymmdd < 100 000 000) and below the pesticide ones.
  static const _careIdOffset = 500000000;
  static const _careIdTypeStride = 1000000;

  /// Snoozed reminders get sequential ids above every date-based id (still
  /// below 2^31, the platform limit).
  static const _snoozeIdOffset = 1500000000;

  /// Darwin category ids, which select the action buttons shown on iOS/macOS.
  static const _irrigationCategoryId = 'irrigation';
  static const _pesticideCategoryId = 'pesticide';
  static const _careCategoryId = 'care';

  /// SharedPreferences keys — shared with SettingsRepository, which cannot be
  /// imported here (it depends on this service).
  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notification_time_minutes';
  static const defaultTimeMinutes = 9 * 60;

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Localizations resolved from the device locale — notifications are also
  /// built from background isolates, where no [BuildContext] exists.
  static AppLocalizations get _l10n => systemL10n();

  /// [onResponse] handles notification taps (and action buttons that open
  /// the app) in the UI isolate; the other actions go to
  /// [onBackgroundNotificationResponse].
  static Future<void> initialize({
    DidReceiveNotificationResponseCallback? onResponse,
  }) async {
    await _initTimezone();
    await _initializePlugin(onResponse: onResponse);

    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          _l10n.irrigationChannelName,
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _pesticideChannelId,
          _l10n.pesticideChannelName,
          importance: Importance.defaultImportance,
        ),
      );
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _careChannelId,
          _l10n.careChannelName,
          description: _l10n.careChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  static Future<void> _initializePlugin({
    DidReceiveNotificationResponseCallback? onResponse,
  }) async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final l10n = _l10n;
    final watered = DarwinNotificationAction.plain(
        ReminderAction.water, l10n.notificationActionWatered);
    final snooze = DarwinNotificationAction.plain(
        ReminderAction.snooze, l10n.notificationActionSnooze);
    // Permissions are NOT requested here — the user opts in from the
    // onboarding or the settings screen (see [requestPermissions]).
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(_irrigationCategoryId,
            actions: [watered, snooze]),
        DarwinNotificationCategory(_pesticideCategoryId, actions: [snooze]),
        DarwinNotificationCategory(_careCategoryId, actions: [snooze]),
      ],
    );
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    await _plugin.initialize(
      InitializationSettings(
          android: android, iOS: darwin, macOS: darwin, linux: linux),
      onDidReceiveNotificationResponse: onResponse,
      onDidReceiveBackgroundNotificationResponse:
          onBackgroundNotificationResponse,
    );
  }

  /// The tap that launched the app from a terminated state, if any — it
  /// never reaches the onResponse callback given to [initialize].
  static Future<NotificationResponse?> launchResponse() async {
    try {
      final details = await _plugin.getNotificationAppLaunchDetails();
      if (details == null || !details.didNotificationLaunchApp) return null;
      return details.notificationResponse;
    } catch (_) {
      // Not implemented on every desktop platform.
      return null;
    }
  }

  /// Loads the timezone database and sets the device zone as tz.local, which
  /// zonedSchedule() relies on. Needed once per isolate.
  static Future<void> _initTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName.identifier));
    } catch (e) {
      // ignore: avoid_print
      print(
          '[NotificationService] Failed to set local location, falling back to UTC: $e');
      tz.setLocalLocation(tz.getLocation('UTC'));
    }
  }

  /// Asks the OS for notification permissions. Call only after an explicit
  /// user gesture (onboarding opt-in or the settings toggle).
  ///
  /// Returns whether notifications are allowed afterwards. On platforms
  /// without a runtime permission this is a no-op returning true.
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await android?.requestNotificationsPermission();
      await android?.requestExactAlarmsPermission();
      return granted ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted =
          await ios?.requestPermissions(alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    if (Platform.isMacOS) {
      final macos = _plugin.resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin>();
      final granted = await macos?.requestPermissions(
          alert: true, badge: true, sound: true);
      return granted ?? false;
    }
    return true;
  }

  // INotificationService --------------------------------------------------

  @override
  Future<void> rescheduleAll(List<PlantWithSpecies> plants,
          {List<PlantReminder> reminders = const []}) =>
      rescheduleAllNotifications(plants, reminders: reminders);

  // Static API ------------------------------------------------------------

  /// Cancels every pending reminder and schedules a fresh set: one
  /// notification per due date (and, for care [reminders], per entry type),
  /// listing all plants due that day.
  ///
  /// Starting from a clean slate is what keeps the schedule honest — a plant
  /// watered or deleted on another device (applied locally by a sync pull)
  /// loses its stale reminder here instead of firing it later.
  ///
  /// [enabled] overrides the persisted setting when the caller already knows
  /// it (e.g. the settings toggle mid-write); when null it is read from
  /// SharedPreferences.
  static Future<void> rescheduleAllNotifications(
    List<PlantWithSpecies> plants, {
    List<PlantReminder> reminders = const [],
    bool? enabled,
  }) async {
    // flutter_local_notifications only implements scheduling on
    // Android, iOS and macOS; calling zonedSchedule()/cancelAll() elsewhere
    // throws UnimplementedError.
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;

    final prefs = await SharedPreferences.getInstance();
    // SharedPreferences caches per isolate, and snoozes are written from the
    // notification-action isolate.
    await prefs.reload();
    final isEnabled = enabled ?? (prefs.getBool(_enabledKey) ?? true);

    await _plugin.cancelAll();
    if (!isEnabled) return;

    final timeMinutes = prefs.getInt(_timeKey) ?? defaultTimeMinutes;
    final hour = timeMinutes ~/ 60;
    final minute = timeMinutes % 60;

    final now = tz.TZDateTime.now(tz.local);
    final groups =
        groupPlantsByDueDate(plants, now.toLocal(), hour: hour, minute: minute);
    final pesticideGroups = groupPlantsByPesticideDueDate(
        plants, now.toLocal(),
        hour: hour, minute: minute);

    final careGroups = groupRemindersByDueDate(reminders, now.toLocal(),
        hour: hour, minute: minute);

    for (final entry in groups.entries) {
      final date = entry.key;
      await _schedule(
        ReminderKind.irrigation,
        _dateNotificationId(date),
        tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute),
        entry.value,
      );
    }

    for (final entry in pesticideGroups.entries) {
      final date = entry.key;
      await _schedule(
        ReminderKind.pesticide,
        _dateNotificationId(date, kindOffset: _pesticideIdOffset),
        tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute),
        entry.value,
      );
    }

    for (final entry in careGroups.entries) {
      final (:date, :type) = entry.key;
      await _schedule(
        ReminderKind.care,
        careNotificationId(date, type),
        tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute),
        entry.value,
        entryType: type,
      );
    }

    // Snoozed reminders, narrowed to the plants that still need it — one
    // watered, archived or deleted meanwhile drops out, and an empty one is
    // skipped.
    final snoozes = await ReminderSnoozeStore(prefs).loadPending(now.toLocal());
    final byId = {for (final item in plants) item.plant.id: item};
    final careDue = {
      for (final r in reminders)
        if (r.plant.isActive &&
            r.status.reminder.enabled &&
            r.status.isDue(now.toLocal()))
          (r.plant.id, r.entryType): r.plant,
    };
    for (final (index, snooze) in snoozes.indexed) {
      PlantModel? stillDue(String id) => switch (snooze.kind) {
            ReminderKind.irrigation when byId[id]?.needsWatering ?? false =>
              byId[id]!.plant,
            ReminderKind.pesticide
                when byId[id]?.needsPesticideReapplication ?? false =>
              byId[id]!.plant,
            ReminderKind.care => careDue[(id, snooze.entryType)],
            _ => null,
          };
      final due = [
        for (final id in snooze.plantIds)
          if (stillDue(id) case final plant?) plant,
      ];
      if (due.isEmpty) continue;
      await _schedule(snooze.kind, _snoozeIdOffset + index,
          tz.TZDateTime.from(snooze.at, tz.local), due,
          entryType: snooze.entryType);
    }
  }

  /// Schedules one reminder of [kind] listing [plants], with the action
  /// buttons of that kind and a payload naming the plants. [entryType] is
  /// required for (and only for) [ReminderKind.care].
  static Future<void> _schedule(
    ReminderKind kind,
    int id,
    tz.TZDateTime when,
    List<PlantModel> plants, {
    EntryType? entryType,
  }) async {
    final l10n = _l10n;
    final nicknames = [for (final plant in plants) plant.nickname];
    final count = nicknames.length;
    final names = nicknames.join(', ');
    // Up to 2 plants the names fit comfortably; beyond that just the count.
    final body = switch ((kind, count)) {
      (ReminderKind.irrigation, 1) =>
        l10n.irrigationNotificationBody(nicknames.single),
      (ReminderKind.irrigation, 2) =>
        l10n.irrigationNotificationBodyMany(count, names),
      (ReminderKind.irrigation, _) =>
        l10n.irrigationNotificationBodyCount(count),
      (ReminderKind.pesticide, 1) =>
        l10n.pesticideNotificationBody(nicknames.single),
      (ReminderKind.pesticide, 2) =>
        l10n.pesticideNotificationBodyMany(count, names),
      (ReminderKind.pesticide, _) =>
        l10n.pesticideNotificationBodyCount(count),
      (ReminderKind.care, 1) => l10n.careNotificationBody(nicknames.single),
      (ReminderKind.care, 2) => l10n.careNotificationBodyMany(count, names),
      (ReminderKind.care, _) => l10n.careNotificationBodyCount(count),
    };
    final title = switch (kind) {
      ReminderKind.irrigation => l10n.irrigationNotificationTitle,
      ReminderKind.pesticide => l10n.pesticideNotificationTitle,
      ReminderKind.care =>
        l10n.careNotificationTitle(entryType!.label(l10n), entryType.emoji),
    };
    final (channelId, channelName, channelDescription, groupKey, categoryId) =
        switch (kind) {
      ReminderKind.irrigation => (
          _channelId,
          l10n.irrigationChannelName,
          l10n.irrigationChannelDescription,
          _groupKey,
          _irrigationCategoryId,
        ),
      ReminderKind.pesticide => (
          _pesticideChannelId,
          l10n.pesticideChannelName,
          l10n.pesticideChannelDescription,
          _pesticideGroupKey,
          _pesticideCategoryId,
        ),
      ReminderKind.care => (
          _careChannelId,
          l10n.careChannelName,
          l10n.careChannelDescription,
          _careGroupKey,
          _careCategoryId,
        ),
    };

    // Neither action opens the app: they run in
    // onBackgroundNotificationResponse.
    final snooze = AndroidNotificationAction(
        ReminderAction.snooze, l10n.notificationActionSnooze,
        showsUserInterface: false, cancelNotification: true);
    final actions = [
      if (kind == ReminderKind.irrigation)
        AndroidNotificationAction(
            ReminderAction.water, l10n.notificationActionWatered,
            showsUserInterface: false, cancelNotification: true),
      snooze,
    ];

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          channelName,
          channelDescription: channelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          groupKey: groupKey,
          // Long plant lists stay readable when the user expands the card.
          styleInformation: BigTextStyleInformation(body),
          actions: actions,
        ),
        iOS: DarwinNotificationDetails(
          threadIdentifier: channelId,
          categoryIdentifier: categoryId,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: ReminderPayload(kind, [for (final plant in plants) plant.id],
              entryType: entryType)
          .encode(),
      // No matchDateTimeComponents — one-shot; the schedule is rebuilt after
      // every irrigation/save/delete/sync pull and by the 12 h background
      // check.
    );
  }

  /// Called from the WorkManager background isolate every 12 h to recover
  /// notifications lost after a device reboot.
  // TODO(sync): Also trigger a background sync pass here
  static Future<void> checkAndRescheduleAll() async {
    // ignore: avoid_print
    print('[NotificationService] Background check triggered');

    await _initTimezone();
    // Re-initialise the plugin inside the background isolate
    await _initializePlugin();

    final active = await _openActiveDatabase();
    if (active == null) return;
    try {
      await PlantsRepository(active.db, const NotificationService())
          .rescheduleNotifications();
    } finally {
      await active.db.close();
    }
  }

  /// Handles "Watered" / "Remind in 3 h" from a background isolate, with no
  /// Riverpod: writes go straight to the active workspace's database. The
  /// UI isolate's Drift streams don't see them; the app refreshes its
  /// queries when resumed. Synced on the next regular sync pass.
  static Future<void> _handleBackgroundResponse(
      NotificationResponse response) async {
    final action = response.actionId;
    final payload = ReminderPayload.decode(response.payload);
    if (payload == null || payload.plantIds.isEmpty) return;
    if (action != ReminderAction.water && action != ReminderAction.snooze) {
      return;
    }

    try {
      DartPluginRegistrant.ensureInitialized();
      await _initTimezone();
      // iOS keeps the plugin's state from the UI engine; re-initialising
      // there would only re-register the categories.
      if (Platform.isAndroid) await _initializePlugin();

      final active = await _openActiveDatabase();
      if (active == null) return;
      try {
        final plantsRepo =
            PlantsRepository(active.db, const NotificationService());
        if (action == ReminderAction.water) {
          final ws = active.workspace;
          final entriesRepo = EntriesRepository(
            active.db,
            ws == null
                ? PhotoStorage()
                : PhotoStorage(baseDirName: photoDirNameFor(ws)),
          );
          // Skip plants deleted or archived since the notification was
          // scheduled.
          final existing = {
            for (final plant in await plantsRepo.getAll())
              if (plant.isActive) plant.id
          };
          final now = DateTime.now();
          for (final plantId in payload.plantIds.where(existing.contains)) {
            await entriesRepo.create(EntryModel(
              id: const Uuid().v4(),
              plantId: plantId,
              date: now,
              type: EntryType.irrigation,
              createdAt: now,
            ));
            await plantsRepo.refreshPlantStatus(plantId, reschedule: false);
          }
        } else {
          await snoozeReminder(payload);
        }
        await plantsRepo.rescheduleNotifications();
      } finally {
        await active.db.close();
      }
    } catch (e, st) {
      // ignore: avoid_print
      print(
          '[NotificationService] Notification action $action failed: $e\n$st');
    }
  }

  /// Persists a snooze of [payload]'s reminder; it is scheduled by the next
  /// [rescheduleAllNotifications], which the caller must trigger.
  static Future<void> snoozeReminder(ReminderPayload payload) async {
    final prefs = await SharedPreferences.getInstance();
    // Don't overwrite snoozes saved by another isolate with a stale cache.
    await prefs.reload();
    await ReminderSnoozeStore(prefs).add(ReminderSnooze(
      payload.kind,
      payload.plantIds,
      DateTime.now().add(ReminderSnoozeStore.snoozeDuration),
      entryType: payload.entryType,
    ));
  }

  /// Opens the active workspace's database from an isolate without Riverpod
  /// (WorkManager, notification actions). Null when that file doesn't exist
  /// yet: opening it would create an empty database, and rescheduling from
  /// it would cancel every pending reminder.
  static Future<({AppDatabase db, Workspace? workspace})?>
      _openActiveDatabase() async {
    final prefs = await SharedPreferences.getInstance();
    // The cache may predate a workspace switch made in the UI isolate.
    await prefs.reload();
    final repo = WorkspaceRepository(prefs);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, repo.activeDbFileName()));
    if (!file.existsSync()) return null;
    // The UI isolate may hold the same file open: wait for its locks
    // instead of failing with SQLITE_BUSY.
    final db = AppDatabase.forTesting(NativeDatabase(file,
        setup: (raw) => raw.execute('PRAGMA busy_timeout = 5000;')));
    return (db: db, workspace: repo.loadActiveWorkspace());
  }

  // ---------------------------------------------------------------------------

  /// Computes the next occurrence of the user's reminder time ([hour]:[minute],
  /// default 9:00) on or after the plant's due irrigation date.
  ///
  /// Exposed for unit testing; prefer [rescheduleAllNotifications] in
  /// production code.
  @visibleForTesting
  static DateTime computeNextIrrigationDate(
    DateTime? lastIrrigatedAt,
    int frequencyDays,
    DateTime now, {
    int hour = 9,
    int minute = 0,
  }) {
    final base = lastIrrigatedAt == null
        ? now
        : lastIrrigatedAt.add(Duration(days: frequencyDays));

    // For overdue plants `base` can be arbitrarily far in the past; clamp to
    // the next reminder time strictly after `now`, otherwise zonedSchedule()
    // throws for dates in the past.
    var scheduled = DateTime(base.year, base.month, base.day, hour, minute);
    if (!scheduled.isAfter(now)) {
      scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      if (!scheduled.isAfter(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }
    }
    return scheduled;
  }

  /// Groups the plants due on the same date into a single reminder: date
  /// (at midnight) → every plant due that day. Plants that are no longer
  /// active, or without an irrigation frequency (own or species default),
  /// are skipped.
  @visibleForTesting
  static Map<DateTime, List<PlantModel>> groupPlantsByDueDate(
    List<PlantWithSpecies> plants,
    DateTime now, {
    int hour = 9,
    int minute = 0,
  }) {
    final groups = <DateTime, List<PlantModel>>{};
    for (final item in plants) {
      if (!item.plant.isActive) continue;
      final frequencyDays = item.effectiveFrequencyDays;
      if (frequencyDays == null) continue;

      final scheduled = computeNextIrrigationDate(
          item.plant.lastIrrigatedAt, frequencyDays, now,
          hour: hour, minute: minute);
      final date = DateTime(scheduled.year, scheduled.month, scheduled.day);
      groups.putIfAbsent(date, () => []).add(item.plant);
    }
    return groups;
  }

  /// Groups the plants due for pesticide reapplication on the same date,
  /// mirroring [groupPlantsByDueDate]. Plants that are no longer active, or
  /// without an active pesticide reminder (no recurrence set on their most
  /// recent 'pesticide' entry), are skipped.
  @visibleForTesting
  static Map<DateTime, List<PlantModel>> groupPlantsByPesticideDueDate(
    List<PlantWithSpecies> plants,
    DateTime now, {
    int hour = 9,
    int minute = 0,
  }) {
    final groups = <DateTime, List<PlantModel>>{};
    for (final item in plants) {
      if (!item.plant.isActive) continue;
      final frequencyDays = item.plant.pesticideReapplicationDays;
      final lastApplied = item.plant.lastPesticideAppliedAt;
      if (frequencyDays == null || lastApplied == null) continue;

      final scheduled = computeNextIrrigationDate(
          lastApplied, frequencyDays, now,
          hour: hour, minute: minute);
      final date = DateTime(scheduled.year, scheduled.month, scheduled.day);
      groups.putIfAbsent(date, () => []).add(item.plant);
    }
    return groups;
  }

  /// Groups the enabled care [reminders] due on the same date for the same
  /// entry type into a single notification. Reminders of plants that are no
  /// longer active are skipped, and a plant listed twice for the same
  /// (date, type) — duplicate reminders created on two synced devices — is
  /// kept once.
  @visibleForTesting
  static Map<({DateTime date, EntryType type}), List<PlantModel>>
      groupRemindersByDueDate(
    List<PlantReminder> reminders,
    DateTime now, {
    int hour = 9,
    int minute = 0,
  }) {
    final groups = <({DateTime date, EntryType type}), List<PlantModel>>{};
    for (final item in reminders) {
      if (!item.plant.isActive || !item.status.reminder.enabled) continue;

      final scheduled = computeNextIrrigationDate(
          item.status.dueDate, 0, now,
          hour: hour, minute: minute);
      final key = (
        date: DateTime(scheduled.year, scheduled.month, scheduled.day),
        type: item.entryType,
      );
      final plants = groups.putIfAbsent(key, () => []);
      if (plants.every((p) => p.id != item.plant.id)) plants.add(item.plant);
    }
    return groups;
  }

  /// Deterministic id of the care reminder of [type] due on [date]; see
  /// [_careIdOffset] for the layout.
  @visibleForTesting
  static int careNotificationId(DateTime date, EntryType type) {
    final days = DateTime.utc(date.year, date.month, date.day)
        .difference(DateTime.utc(1970))
        .inDays;
    return _careIdOffset + type.index * _careIdTypeStride + days;
  }

  /// One deterministic id per due date (e.g. 2026-07-16 → 20260716), so a
  /// reschedule for the same day replaces the pending notification instead
  /// of stacking a new one. [kindOffset] namespaces ids across reminder
  /// kinds (irrigation vs. pesticide) so they never collide.
  static int _dateNotificationId(DateTime date, {int kindOffset = 0}) =>
      kindOffset + date.year * 10000 + date.month * 100 + date.day;
}
