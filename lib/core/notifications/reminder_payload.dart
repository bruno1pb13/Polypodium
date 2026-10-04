import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../enums.dart';

/// Which reminder a notification is about. [care] covers the user-configured
/// recurring reminders (fertilizing, pruning, ...), told apart by the
/// entry type carried alongside it.
enum ReminderKind { irrigation, pesticide, care }

/// Reads the entry type of a [ReminderKind.care] reminder from [json]. Throws
/// when it's missing or unknown, so the whole payload is rejected; other
/// kinds carry none.
EntryType? _entryTypeFromJson(ReminderKind kind, Map<String, dynamic> json) {
  if (kind != ReminderKind.care) return null;
  return EntryType.values.byName(json['entryType'] as String);
}

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
  const ReminderPayload(this.kind, this.plantIds, {this.entryType})
      : assert((kind == ReminderKind.care) == (entryType != null));

  final ReminderKind kind;
  final List<String> plantIds;

  /// Set only for [ReminderKind.care].
  final EntryType? entryType;

  String encode() => jsonEncode({
        'kind': kind.name,
        'plantIds': plantIds,
        if (entryType != null) 'entryType': entryType!.name,
      });

  /// Null for a missing or malformed payload (e.g. a notification scheduled
  /// by an older app version, before payloads existed).
  static ReminderPayload? decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final kind = ReminderKind.values.byName(json['kind'] as String);
      final ids = (json['plantIds'] as List).cast<String>();
      return ReminderPayload(kind, ids,
          entryType: _entryTypeFromJson(kind, json));
    } catch (_) {
      return null;
    }
  }
}

/// A reminder the user postponed from the notification, to be shown again
/// at [at] for the plants that still need it by then.
class ReminderSnooze {
  const ReminderSnooze(this.kind, this.plantIds, this.at, {this.entryType});

  final ReminderKind kind;
  final List<String> plantIds;
  final DateTime at;

  /// Set only for [ReminderKind.care].
  final EntryType? entryType;

  Map<String, dynamic> toJson() => {
        'kind': kind.name,
        'plantIds': plantIds,
        'at': at.toIso8601String(),
        if (entryType != null) 'entryType': entryType!.name,
      };

  factory ReminderSnooze.fromJson(Map<String, dynamic> json) {
    final kind = ReminderKind.values.byName(json['kind'] as String);
    return ReminderSnooze(
      kind,
      (json['plantIds'] as List).cast<String>(),
      DateTime.parse(json['at'] as String),
      entryType: _entryTypeFromJson(kind, json),
    );
  }
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
