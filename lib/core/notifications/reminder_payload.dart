import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Which reminder a notification is about.
enum ReminderKind { irrigation, pesticide }

/// Action ids of the buttons shown on reminder notifications.
abstract final class ReminderAction {
  /// Records an irrigation for every plant in the notification.
  static const water = 'water';

  /// Shows the same reminder again after [ReminderSnoozeStore.snoozeDuration].
  static const snooze = 'snooze';
}

/// Carried as the notification payload so a tap or an action button knows
/// which plants the reminder covered (one notification groups every plant
/// due on the same date).
class ReminderPayload {
  const ReminderPayload(this.kind, this.plantIds);

  final ReminderKind kind;
  final List<String> plantIds;

  String encode() => jsonEncode({'kind': kind.name, 'plantIds': plantIds});

  /// Null for a missing or malformed payload (e.g. a notification scheduled
  /// by an older app version, before payloads existed).
  static ReminderPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final kind = ReminderKind.values.byName(json['kind'] as String);
      final ids = (json['plantIds'] as List).cast<String>();
      return ReminderPayload(kind, ids);
    } catch (_) {
      return null;
    }
  }
}

/// A reminder the user postponed from the notification, to be shown again
/// at [at] for the plants that still need it by then.
class ReminderSnooze {
  const ReminderSnooze(this.kind, this.plantIds, this.at);

  final ReminderKind kind;
  final List<String> plantIds;
  final DateTime at;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'plantIds': plantIds,
        'at': at.toIso8601String(),
      };

  factory ReminderSnooze.fromJson(Map<String, dynamic> json) => ReminderSnooze(
        ReminderKind.values.byName(json['kind'] as String),
        (json['plantIds'] as List).cast<String>(),
        DateTime.parse(json['at'] as String),
      );
}

/// Persists snoozed reminders in SharedPreferences. They have to outlive the
/// in-memory schedule because every reschedule starts with cancelAll(),
/// which would otherwise drop a snoozed notification.
class ReminderSnoozeStore {
  ReminderSnoozeStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'notification_snoozes';
  static const snoozeDuration = Duration(hours: 3);

  /// Pending snoozes, skipping (and forgetting) the ones already past [now].
  Future<List<ReminderSnooze>> loadPending(DateTime now) async {
    final all = _load();
    final pending = all.where((s) => s.at.isAfter(now)).toList();
    if (pending.length != all.length) await _save(pending);
    return pending;
  }

  Future<void> add(ReminderSnooze snooze) async {
    await _save([..._load(), snooze]);
  }

  List<ReminderSnooze> _load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => ReminderSnooze.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<ReminderSnooze> snoozes) => _prefs.setString(
      _key, jsonEncode(snoozes.map((s) => s.toJson()).toList()));
}
