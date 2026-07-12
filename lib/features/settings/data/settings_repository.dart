import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/notifications/notification_service.dart';
import '../../plants/presentation/providers/plants_providers.dart';

class SettingsRepository {
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _transparencyEnabledKey = 'transparency_enabled';
  static const _themeModeKey = 'theme_mode';
  static const _syncServerUrlKey = 'sync_server_url';
  static const _autoSyncEnabledKey = 'auto_sync_enabled';
  static const _introSeenKey = 'intro_seen';

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

  String? getSyncServerUrl() => _prefs.getString(_syncServerUrlKey);

  Future<void> setSyncServerUrl(String? url) async {
    if (url == null) {
      await _prefs.remove(_syncServerUrlKey);
    } else {
      await _prefs.setString(_syncServerUrlKey, url);
    }
  }

  bool hasSeenIntro() => _prefs.getBool(_introSeenKey) ?? false;

  Future<void> setIntroSeen() async {
    await _prefs.setBool(_introSeenKey, true);
  }

  bool isAutoSyncEnabled() => _prefs.getBool(_autoSyncEnabledKey) ?? true;

  Future<void> setAutoSyncEnabled(bool enabled) async {
    await _prefs.setBool(_autoSyncEnabledKey, enabled);
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
