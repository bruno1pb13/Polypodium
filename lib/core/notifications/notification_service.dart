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
  Future<void> schedule({required PlantModel plant, required SpeciesModel species});
  Future<void> cancel(String plantId);
}

class NotificationService implements INotificationService {
  const NotificationService();

  static const irrigationCheckTask = 'irrigation-check';
  static const _channelId = 'polypodium_irrigation';

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
    const iOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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
      await androidPlugin?.requestNotificationsPermission();
      await androidPlugin?.requestExactAlarmsPermission();
      await androidPlugin?.createNotificationChannel(
        AndroidNotificationChannel(
          _channelId,
          _l10n.irrigationChannelName,
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  // INotificationService --------------------------------------------------

  @override
  Future<void> schedule({
    required PlantModel plant,
    required SpeciesModel species,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('notifications_enabled') ?? true;
    await scheduleIrrigationNotification(
        plant: plant, species: species, enabled: enabled);
  }

  @override
  Future<void> cancel(String plantId) => cancelNotification(plantId);

  // Static API ------------------------------------------------------------

  static Future<void> scheduleIrrigationNotification({
    required PlantModel plant,
    required SpeciesModel species,
    bool enabled = true,
  }) async {
    if (!enabled) {
      await cancelNotification(plant.id);
      return;
    }

    final frequencyDays =
        plant.irrigationFrequencyDays ?? species.defaultIrrigationFrequencyDays;
    
    if (frequencyDays == null) {
      await cancelNotification(plant.id);
      return;
    }

    // flutter_local_notifications only implements scheduling on
    // Android, iOS and macOS; calling zonedSchedule() elsewhere throws
    // UnimplementedError.
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;

    final scheduledDate =
        _nextIrrigationTime(plant.lastIrrigatedAt, frequencyDays);

    final l10n = _l10n;
    await _plugin.zonedSchedule(
      _notificationId(plant.id),
      l10n.irrigationNotificationTitle,
      l10n.irrigationNotificationBody(plant.nickname),
      scheduledDate,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          l10n.irrigationChannelName,
          channelDescription: l10n.irrigationChannelDescription,
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      // No matchDateTimeComponents — one-shot; rescheduled after each irrigation
    );
  }

  static Future<void> cancelNotification(String plantId) async {
    // flutter_local_notifications has no Windows implementation (< v19);
    // cancel() falls through to the default method channel there and throws
    // MissingPluginException, which would abort callers such as plant delete.
    if (!(Platform.isAndroid ||
        Platform.isIOS ||
        Platform.isMacOS ||
        Platform.isLinux)) {
      return;
    }
    await _plugin.cancel(_notificationId(plantId));
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

        await scheduleIrrigationNotification(plant: plant, species: species);
      }
    } finally {
      await db.close();
    }
  }

  // ---------------------------------------------------------------------------

  /// Computes the next 9 am on or after the plant's due irrigation date.
  ///
  /// Exposed for unit testing; prefer [scheduleIrrigationNotification] in
  /// production code.
  @visibleForTesting
  static DateTime computeNextIrrigationDate(
    DateTime? lastIrrigatedAt,
    int frequencyDays,
    DateTime now,
  ) {
    final base = lastIrrigatedAt == null
        ? now
        : lastIrrigatedAt.add(Duration(days: frequencyDays));

    var scheduled = DateTime(base.year, base.month, base.day, 9);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  static tz.TZDateTime _nextIrrigationTime(
    DateTime? lastIrrigatedAt,
    int frequencyDays,
  ) {
    final now = tz.TZDateTime.now(tz.local);
    final result =
        computeNextIrrigationDate(lastIrrigatedAt, frequencyDays, now.toLocal());
    return tz.TZDateTime(
        tz.local, result.year, result.month, result.day, result.hour);
  }

  static int _notificationId(String uuid) => uuid.hashCode.abs() % 0x7FFFFFFF;
}
