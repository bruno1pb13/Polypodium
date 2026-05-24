import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../plants/presentation/providers/plants_providers.dart';

class SettingsRepository {
  static const _notificationsEnabledKey = 'notifications_enabled';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  Future<void> rescheduleAllNotifications(Ref ref) async {
    final enabled = areNotificationsEnabled();
    final plantsWithSpecies = await ref.read(plantsWithSpeciesProvider.future);

    for (final p in plantsWithSpecies) {
      await NotificationService.scheduleIrrigationNotification(
        plant: p.plant,
        species: p.species,
        enabled: enabled,
      );
    }
  }
}
