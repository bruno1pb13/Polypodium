import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../plants/presentation/providers/plants_providers.dart';

class SettingsRepository {
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _transparencyEnabledKey = 'transparency_enabled';
  static const _themeModeKey = 'theme_mode';

  final SharedPreferences _prefs;

  SettingsRepository(this._prefs);

  bool areNotificationsEnabled() {
    return _prefs.getBool(_notificationsEnabledKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs.setBool(_notificationsEnabledKey, enabled);
  }

  bool isTransparencyEnabled() {
    return _prefs.getBool(_transparencyEnabledKey) ?? true;
  }

  Future<void> setTransparencyEnabled(bool enabled) async {
    await _prefs.setBool(_transparencyEnabledKey, enabled);
  }

  String getThemeMode() {
    return _prefs.getString(_themeModeKey) ?? 'system';
  }

  Future<void> setThemeMode(String themeMode) async {
    await _prefs.setString(_themeModeKey, themeMode);
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
