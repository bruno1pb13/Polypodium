enum SoilType {
  sandy,
  clay,
  loamy,
  peaty,
  chalky,
  silty,
  latosol,
  argisol,
  terraRoxa,
  massape,
  alluvial,
  terraVegetal,
  pottingMix,
  wormCastings,
  succulentMix,
  coconutFiber,
  manure,
}

enum EntryType { irrigation, fertilizer, pruning, observation, other, history }

// TODO(sync): Tracks local changes pending server synchronization
enum SyncStatus { synced, pending, conflict }

enum PlantSortOption {
  wateringNeeds,
  nameAZ,
  nameZA,
  lastWatered,
  dateAdded,
}

enum SpeciesSortOption {
  popularAZ,
  popularZA,
  scientificAZ,
  scientificZA,
  dateAdded,
}

enum SoilSortOption {
  nameAZ,
  nameZA,
  dateAdded,
}

enum LocationSortOption {
  nameAZ,
  nameZA,
  dateAdded,
}

extension SoilTypeX on SoilType {
  String get label => switch (this) {
        SoilType.sandy => 'Arenoso',
        SoilType.clay => 'Argiloso',
        SoilType.loamy => 'Franco',
        SoilType.peaty => 'Turfoso',
        SoilType.chalky => 'Calcário',
        SoilType.silty => 'Siltoso',
        SoilType.latosol => 'Latossolo',
        SoilType.argisol => 'Argissolo',
        SoilType.terraRoxa => 'Terra Roxa',
        SoilType.massape => 'Massapê',
        SoilType.alluvial => 'Aluvial/Várzea',
        SoilType.terraVegetal => 'Terra Vegetal',
        SoilType.pottingMix => 'Substrato Pronto',
        SoilType.wormCastings => 'Húmus de Minhoca',
        SoilType.succulentMix => 'Substrato p/ Suculentas',
        SoilType.coconutFiber => 'Fibra de Coco',
        SoilType.manure => 'Esterco Curtido',
      };

  String get description => switch (this) {
        SoilType.sandy => 'Alta drenagem, baixa retenção de nutrientes.',
        SoilType.clay => 'Alta retenção de água, tende a compactar.',
        SoilType.loamy => 'Equilibrado entre areia, silte e argila.',
        SoilType.peaty => 'Rico em matéria orgânica, retém muita umidade.',
        SoilType.chalky => 'Pedregoso e alcalino, boa drenagem.',
        SoilType.silty => 'Retém bem a umidade, fértil e macio.',
        SoilType.latosol => 'Rico em ferro e alumínio. Muito poroso e bem drenado.',
        SoilType.argisol => 'Acúmulo de argila em profundidade. Risco de erosão.',
        SoilType.terraRoxa => 'Origem vulcânica. Extrema fertilidade e cor avermelhada.',
        SoilType.massape => 'Escuro, muito argiloso e fértil. Típico do NE.',
        SoilType.alluvial => 'Sedimentos de rios. Naturalmente fértil e jovem.',
        SoilType.terraVegetal => 'Terra mineral misturada com restos vegetais decompostos.',
        SoilType.pottingMix => 'Mix balanceado de turfa, casca de pinus e perlita.',
        SoilType.wormCastings => 'Rico em NPK e microrganismos. Ótimo fertilizante.',
        SoilType.succulentMix => 'Alta drenagem. 50% orgânico e 50% areia ou perlita.',
        SoilType.coconutFiber => 'Melhora a aeração e mantém umidade controlada.',
        SoilType.manure => 'Adubo orgânico rico. Deve ser usado sempre decomposto.',
      };
}

extension EntryTypeX on EntryType {
  String get label => switch (this) {
        EntryType.irrigation => 'Irrigação',
        EntryType.fertilizer => 'Fertilização',
        EntryType.pruning => 'Poda',
        EntryType.observation => 'Observação',
        EntryType.other => 'Outro',
        EntryType.history => 'Histórico',
      };

  String get emoji => switch (this) {
        EntryType.irrigation => '💧',
        EntryType.fertilizer => '🌱',
        EntryType.pruning => '✂️',
        EntryType.observation => '👁',
        EntryType.other => '📝',
        EntryType.history => '📜',
      };
}
