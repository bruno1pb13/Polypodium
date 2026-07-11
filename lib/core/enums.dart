import '../l10n/app_localizations.dart';

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

enum EntryType {
  irrigation,
  fertilizer,
  pruning,
  observation,
  height,
  chlorosis,
  pest,
  other,
  history,
}

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

enum EntrySortOption {
  dateDesc,
  dateAsc,
  typeAZ,
}

extension EntrySortOptionX on EntrySortOption {
  String label(AppLocalizations l10n) => switch (this) {
        EntrySortOption.dateDesc => l10n.sortNewestFirst,
        EntrySortOption.dateAsc => l10n.sortOldestFirst,
        EntrySortOption.typeAZ => l10n.sortByType,
      };
}

extension SoilTypeX on SoilType {
  String label(AppLocalizations l10n) => switch (this) {
        SoilType.sandy => l10n.soilSandy,
        SoilType.clay => l10n.soilClay,
        SoilType.loamy => l10n.soilLoamy,
        SoilType.peaty => l10n.soilPeaty,
        SoilType.chalky => l10n.soilChalky,
        SoilType.silty => l10n.soilSilty,
        SoilType.latosol => l10n.soilLatosol,
        SoilType.argisol => l10n.soilArgisol,
        SoilType.terraRoxa => l10n.soilTerraRoxa,
        SoilType.massape => l10n.soilMassape,
        SoilType.alluvial => l10n.soilAlluvial,
        SoilType.terraVegetal => l10n.soilTerraVegetal,
        SoilType.pottingMix => l10n.soilPottingMix,
        SoilType.wormCastings => l10n.soilWormCastings,
        SoilType.succulentMix => l10n.soilSucculentMix,
        SoilType.coconutFiber => l10n.soilCoconutFiber,
        SoilType.manure => l10n.soilManure,
      };

  String description(AppLocalizations l10n) => switch (this) {
        SoilType.sandy => l10n.soilSandyDesc,
        SoilType.clay => l10n.soilClayDesc,
        SoilType.loamy => l10n.soilLoamyDesc,
        SoilType.peaty => l10n.soilPeatyDesc,
        SoilType.chalky => l10n.soilChalkyDesc,
        SoilType.silty => l10n.soilSiltyDesc,
        SoilType.latosol => l10n.soilLatosolDesc,
        SoilType.argisol => l10n.soilArgisolDesc,
        SoilType.terraRoxa => l10n.soilTerraRoxaDesc,
        SoilType.massape => l10n.soilMassapeDesc,
        SoilType.alluvial => l10n.soilAlluvialDesc,
        SoilType.terraVegetal => l10n.soilTerraVegetalDesc,
        SoilType.pottingMix => l10n.soilPottingMixDesc,
        SoilType.wormCastings => l10n.soilWormCastingsDesc,
        SoilType.succulentMix => l10n.soilSucculentMixDesc,
        SoilType.coconutFiber => l10n.soilCoconutFiberDesc,
        SoilType.manure => l10n.soilManureDesc,
      };

  String? get imagePath => switch (this) {
        SoilType.sandy => 'assets/soils/sandy.jpg',
        SoilType.clay => 'assets/soils/clay.jpg',
        SoilType.loamy => 'assets/soils/loamy.jpg',
        SoilType.peaty => 'assets/soils/peaty.jpg',
        SoilType.chalky => 'assets/soils/chalky.jpg',
        SoilType.silty => 'assets/soils/silty.jpg',
        SoilType.latosol => 'assets/soils/latosol.jpg',
        SoilType.argisol => 'assets/soils/argisol.jpg',
        SoilType.terraRoxa => 'assets/soils/terra_roxa.jpg',
        SoilType.massape => 'assets/soils/massape.jpg',
        SoilType.alluvial => 'assets/soils/alluvial.jpg',
        SoilType.wormCastings => 'assets/soils/worm_castings.jpg',
        SoilType.manure => 'assets/soils/manure.jpg',
        SoilType.terraVegetal => null,
        SoilType.pottingMix => null,
        SoilType.succulentMix => null,
        SoilType.coconutFiber => null,
      };

  String? get imageSource => switch (this) {
        SoilType.sandy =>
          'Wikimedia Commons — File:Arenosol.JPG (CC BY-SA)',
        SoilType.clay =>
          'Wikimedia Commons — File:Blue glacial clay IMG 5670 ersvika.JPG (CC BY-SA)',
        SoilType.loamy =>
          'Wikimedia Commons — File:Soil Texture Samples including loam, sand and clay.jpg (CC BY-SA)',
        SoilType.peaty =>
          'Wikimedia Commons — File:Histosol2.JPG (CC BY-SA)',
        SoilType.chalky =>
          'Wikimedia Commons — File:Haplic Calcisol.JPG (CC BY-SA)',
        SoilType.silty =>
          'Wikimedia Commons — File:Soil profile with silt, loam, and clay.jpg (CC BY-SA)',
        SoilType.latosol =>
          'Wikimedia Commons — File:Ferralsol.JPG (CC BY-SA) · ref. EMBRAPA SiBCS',
        SoilType.argisol =>
          'EMBRAPA — Agência de Informação Tecnológica, Argissolos',
        SoilType.terraRoxa =>
          'Wikimedia Commons — File:Tierra-misionera.JPG (CC BY-SA) · ref. pt.wikipedia.org/wiki/Terra_roxa',
        SoilType.massape =>
          'Wikimedia Commons — File:Calcari-eutric Vertisol.JPG (CC BY-SA) · ref. en.wikipedia.org/wiki/Massapê',
        SoilType.alluvial =>
          'Wikimedia Commons — File:Amazon alluvium deposit - autazes.jpg (CC BY-SA)',
        SoilType.wormCastings =>
          'Wikimedia Commons — File:A Vermi compost.JPG (CC BY-SA)',
        SoilType.manure =>
          'Wikimedia Commons — File:Compost pile.JPG (CC BY-SA)',
        SoilType.terraVegetal => null,
        SoilType.pottingMix => null,
        SoilType.succulentMix => null,
        SoilType.coconutFiber => null,
      };
}

extension EntryTypeX on EntryType {
  String label(AppLocalizations l10n) => switch (this) {
        EntryType.irrigation => l10n.entryTypeIrrigation,
        EntryType.fertilizer => l10n.entryTypeFertilizer,
        EntryType.pruning => l10n.entryTypePruning,
        EntryType.observation => l10n.entryTypeObservation,
        EntryType.height => l10n.entryTypeHeight,
        EntryType.chlorosis => l10n.entryTypeChlorosis,
        EntryType.pest => l10n.entryTypePest,
        EntryType.other => l10n.entryTypeOther,
        EntryType.history => l10n.entryTypeHistory,
      };

  String get emoji => switch (this) {
        EntryType.irrigation => '💧',
        EntryType.fertilizer => '🌱',
        EntryType.pruning => '✂️',
        EntryType.observation => '👁',
        EntryType.height => '📏',
        EntryType.chlorosis => '🟡',
        EntryType.pest => '🐛',
        EntryType.other => '📝',
        EntryType.history => '📜',
      };
}
