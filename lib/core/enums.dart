enum SoilType { sandy, clay, loamy, peaty, chalky, silty }

enum EntryType { irrigation, fertilizer, pruning, observation, other }

// TODO(sync): Tracks local changes pending server synchronization
enum SyncStatus { synced, pending, conflict }

extension SoilTypeX on SoilType {
  String get label => switch (this) {
        SoilType.sandy => 'Arenoso',
        SoilType.clay => 'Argiloso',
        SoilType.loamy => 'Franco',
        SoilType.peaty => 'Turfoso',
        SoilType.chalky => 'Calcário',
        SoilType.silty => 'Siltoso',
      };
}

extension EntryTypeX on EntryType {
  String get label => switch (this) {
        EntryType.irrigation => 'Irrigação',
        EntryType.fertilizer => 'Fertilização',
        EntryType.pruning => 'Poda',
        EntryType.observation => 'Observação',
        EntryType.other => 'Outro',
      };

  String get emoji => switch (this) {
        EntryType.irrigation => '💧',
        EntryType.fertilizer => '🌱',
        EntryType.pruning => '✂️',
        EntryType.observation => '👁',
        EntryType.other => '📝',
      };
}
