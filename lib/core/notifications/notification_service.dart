import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../database/app_database.dart';
import '../../features/plants/domain/plant_model.dart';
import '../../features/species/domain/species_model.dart';
import '../l10n/l10n.dart';

abstract interface class INotificationService {
  /// Rebuilds the whole irrigation reminder schedule from [plants] — the
  /// full set of active plants. Anything previously scheduled that is no
  /// longer due (watered meanwhile, deleted, disabled) is cancelled.
  Future<void> rescheduleAll(List<PlantWithSpecies> plants);
}

class NotificationService implements INotificationService {
  const NotificationService();

  static const irrigationCheckTask = 'irrigation-check';
  static const _channelId = 'polypodium_irrigation';

  /// Groups every irrigation reminder in the notification shade (Android
  /// bundles by groupKey; iOS threads by threadIdentifier).
  static const _groupKey = 'polypodium_irrigation_group';

  /// SharedPreferences keys — shared with SettingsRepository, which cannot be
  /// imported here (it depends on this service).
  static const _enabledKey = 'notifications_enabled';
  static const _timeKey = 'notification_time_minutes';
  static const defaultTimeMinutes = 9 * 60;

  static final _plugin = FlutterLocalNotificationsPlugin();

  /// Localizations resolved from the device locale — notifications are also
  /// built from background isolates, where no [BuildContext] exists.
  static AppLocalizations get _l10n => systemL10n();

  static Future<void> initialize() async {
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

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    // Permissions are NOT requested here — the user opts in from the
    // onboarding or the settings screen (see [requestPermissions]).
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: iOS, linux: linux),
    );

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
  Future<void> rescheduleAll(List<PlantWithSpecies> plants) =>
      rescheduleAllNotifications(plants);

  // Static API ------------------------------------------------------------

  /// Cancels every pending irrigation reminder and schedules a fresh set:
  /// one notification per due date, listing all plants due that day.
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
    bool? enabled,
  }) async {
    // flutter_local_notifications only implements scheduling on
    // Android, iOS and macOS; calling zonedSchedule()/cancelAll() elsewhere
    // throws UnimplementedError.
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;

    final prefs = await SharedPreferences.getInstance();
    final isEnabled = enabled ?? (prefs.getBool(_enabledKey) ?? true);

    await _plugin.cancelAll();
    if (!isEnabled) return;

    final timeMinutes = prefs.getInt(_timeKey) ?? defaultTimeMinutes;
    final hour = timeMinutes ~/ 60;
    final minute = timeMinutes % 60;

    final now = tz.TZDateTime.now(tz.local);
    final groups =
        groupPlantsByDueDate(plants, now.toLocal(), hour: hour, minute: minute);

    final l10n = _l10n;
    for (final entry in groups.entries) {
      final date = entry.key;
      final nicknames = entry.value;
      // Up to 2 plants the names fit comfortably; beyond that just the count.
      final body = switch (nicknames.length) {
        1 => l10n.irrigationNotificationBody(nicknames.single),
        2 => l10n.irrigationNotificationBodyMany(
            nicknames.length, nicknames.join(', ')),
        _ => l10n.irrigationNotificationBodyCount(nicknames.length),
      };

      await _plugin.zonedSchedule(
        _dateNotificationId(date),
        l10n.irrigationNotificationTitle,
        body,
        tz.TZDateTime(tz.local, date.year, date.month, date.day, hour, minute),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            l10n.irrigationChannelName,
            channelDescription: l10n.irrigationChannelDescription,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            groupKey: _groupKey,
            // Long plant lists stay readable when the user expands the card.
            styleInformation: BigTextStyleInformation(body),
          ),
          iOS: const DarwinNotificationDetails(threadIdentifier: _channelId),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // No matchDateTimeComponents — one-shot; the schedule is rebuilt after
        // every irrigation/save/delete/sync pull and by the 12 h background
        // check.
      );
    }
  }

  /// Called from the WorkManager background isolate every 12 h to recover
  /// notifications lost after a device reboot.
  // TODO(sync): Also trigger a background sync pass here
  static Future<void> checkAndRescheduleAll() async {
    // ignore: avoid_print
    print('[NotificationService] Background check triggered');

    tz_data.initializeTimeZones();
    try {
      final timezoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezoneName.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('UTC'));
    }

    // Re-initialise the plugin inside the background isolate
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iOS = DarwinInitializationSettings();
    await _plugin
        .initialize(const InitializationSettings(android: android, iOS: iOS));

    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'polypodium.db'));
    final db = AppDatabase.forTesting(NativeDatabase(file));

    try {
      final items = <PlantWithSpecies>[];
      final plantRows = await db.plantsDao.getAll();
      for (final row in plantRows) {
        final speciesRow = await db.speciesDao.getById(row.speciesId);
        if (speciesRow == null) continue;

        final plant = PlantModel(
          id: row.id,
          speciesId: row.speciesId,
          nickname: row.nickname,
          soilId: row.soilType,
          irrigationFrequencyDays: row.irrigationFrequencyDays,
          acquisitionDate: row.acquisitionDate,
          location: row.location,
          locationId: row.locationId,
          lastIrrigatedAt: row.lastIrrigatedAt,
          createdAt: row.createdAt,
        );
        final species = SpeciesModel(
          id: speciesRow.id,
          scientificName: speciesRow.scientificName,
          popularName: speciesRow.popularName,
          defaultIrrigationFrequencyDays:
              speciesRow.defaultIrrigationFrequencyDays,
          recommendedSoilIds: speciesRow.recommendedSoilTypes,
          createdAt: speciesRow.createdAt,
        );
        items.add(PlantWithSpecies(plant: plant, species: species));
      }
      await rescheduleAllNotifications(items);
    } finally {
      await db.close();
    }
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
  /// (at midnight) → nicknames of every plant due that day. Plants without
  /// an irrigation frequency (own or species default) are skipped.
  @visibleForTesting
  static Map<DateTime, List<String>> groupPlantsByDueDate(
    List<PlantWithSpecies> plants,
    DateTime now, {
    int hour = 9,
    int minute = 0,
  }) {
    final groups = <DateTime, List<String>>{};
    for (final item in plants) {
      final frequencyDays = item.effectiveFrequencyDays;
      if (frequencyDays == null) continue;

      final scheduled = computeNextIrrigationDate(
          item.plant.lastIrrigatedAt, frequencyDays, now,
          hour: hour, minute: minute);
      final date = DateTime(scheduled.year, scheduled.month, scheduled.day);
      groups.putIfAbsent(date, () => []).add(item.plant.nickname);
    }
    return groups;
  }

  /// One deterministic id per due date (e.g. 2026-07-16 → 20260716), so a
  /// reschedule for the same day replaces the pending notification instead
  /// of stacking a new one.
  static int _dateNotificationId(DateTime date) =>
      date.year * 10000 + date.month * 100 + date.day;
}
