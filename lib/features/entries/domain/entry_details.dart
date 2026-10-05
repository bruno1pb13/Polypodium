import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../core/enums.dart';

/// Typed view of [EntryModel.extraData], the JSON blob holding the structured
/// fields of an entry type.
///
/// The JSON keys and value types are a persisted contract shared with the
/// database, backups, sync payloads and older app versions: keep them stable.
/// Irrigation intensity, health score and severities live in
/// [EntryModel.numericValue], not here.
sealed class EntryDetails {
  const EntryDetails();

  /// Parses [json] for an entry of [type]. Lenient: returns null for types
  /// without details, null/malformed JSON or a non-object payload, and skips
  /// fields of unexpected types. Never throws.
  static EntryDetails? decode(EntryType type, String? json) {
    if (json == null) return null;
    final Object? decoded;
    try {
      decoded = jsonDecode(json);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, dynamic>) return null;
    return switch (type) {
      EntryType.pest => PestDetails._fromJson(decoded),
      EntryType.fertilizer => FertilizerDetails._fromJson(decoded),
      EntryType.pruning => PruningDetails._fromJson(decoded),
      EntryType.pesticide => PesticideDetails._fromJson(decoded),
      EntryType.repotting => RepottingDetails._fromJson(decoded),
      EntryType.harvest => HarvestDetails._fromJson(decoded),
      _ => null,
    };
  }

  /// JSON to store in [EntryModel.extraData], or null when there is nothing
  /// worth storing.
  String? encode() => isEmpty ? null : jsonEncode(toJson());

  bool get isEmpty;

  Map<String, dynamic> toJson();
}

/// `{"pestType": String}`
final class PestDetails extends EntryDetails {
  final String? pestType;

  const PestDetails({this.pestType});

  factory PestDetails._fromJson(Map<String, dynamic> json) =>
      PestDetails(pestType: _string(json['pestType']));

  @override
  bool get isEmpty => pestType == null || pestType!.isEmpty;

  @override
  Map<String, dynamic> toJson() => {'pestType': pestType};

  @override
  bool operator ==(Object other) =>
      other is PestDetails && other.pestType == pestType;

  @override
  int get hashCode => pestType.hashCode;
}

/// `{"products": [{"name": String, "dose": double?}, ...]}` — dose in ml.
final class FertilizerDetails extends EntryDetails {
  final List<FertilizerProduct> products;

  const FertilizerDetails({this.products = const []});

  factory FertilizerDetails._fromJson(Map<String, dynamic> json) =>
      FertilizerDetails(
        products: _objects(json['products'])
            .map((p) => FertilizerProduct(
                  name: _string(p['name']) ?? '',
                  dose:
                      (p['dose'] is num) ? (p['dose'] as num).toDouble() : null,
                ))
            .toList(),
      );

  @override
  bool get isEmpty => products.isEmpty;

  @override
  Map<String, dynamic> toJson() => {
        'products': [
          for (final p in products)
            {'name': p.name, if (p.dose != null) 'dose': p.dose},
        ],
      };

  @override
  bool operator ==(Object other) =>
      other is FertilizerDetails && listEquals(other.products, products);

  @override
  int get hashCode => Object.hashAll(products);
}

class FertilizerProduct {
  final String name;
  final double? dose;

  const FertilizerProduct({required this.name, this.dose});

  @override
  bool operator ==(Object other) =>
      other is FertilizerProduct && other.name == name && other.dose == dose;

  @override
  int get hashCode => Object.hash(name, dose);
}

/// `{"reason": String}` — one of `formacao`, `limpeza`, `rejuvenescimento`,
/// `colheita`.
final class PruningDetails extends EntryDetails {
  final String? reason;

  const PruningDetails({this.reason});

  factory PruningDetails._fromJson(Map<String, dynamic> json) =>
      PruningDetails(reason: _string(json['reason']));

  @override
  bool get isEmpty => reason == null;

  @override
  Map<String, dynamic> toJson() => {'reason': reason};

  @override
  bool operator ==(Object other) =>
      other is PruningDetails && other.reason == reason;

  @override
  int get hashCode => reason.hashCode;
}

/// `{"products": [{"defensivoId": String, "name": String, "dose": String?,
/// "carenciaDays": int?}], "recurrenceDays": int}` — both top-level keys
/// optional. The defensivo name and carência are copied at launch time so the
/// entry survives catalog edits and deletions; entries saved before the
/// carência was copied have no `carenciaDays`.
final class PesticideDetails extends EntryDetails {
  final List<PesticideProduct> products;

  /// Days until the next application; drives the plant's pesticide reminder.
  final int? recurrenceDays;

  const PesticideDetails({this.products = const [], this.recurrenceDays});

  factory PesticideDetails._fromJson(Map<String, dynamic> json) =>
      PesticideDetails(
        products: _objects(json['products'])
            .map((p) => PesticideProduct(
                  defensivoId: _string(p['defensivoId']),
                  name: _string(p['name']) ?? '',
                  dose: _string(p['dose']),
                  carenciaDays: (p['carenciaDays'] is num)
                      ? (p['carenciaDays'] as num).toInt()
                      : null,
                ))
            .toList(),
        recurrenceDays: (json['recurrenceDays'] is num)
            ? (json['recurrenceDays'] as num).toInt()
            : null,
      );

  /// Shortcut for the reminder bookkeeping, which only has the raw column.
  static int? recurrenceDaysOf(String? extraData) =>
      (EntryDetails.decode(EntryType.pesticide, extraData) as PesticideDetails?)
          ?.recurrenceDays;

  @override
  bool get isEmpty => products.isEmpty && recurrenceDays == null;

  @override
  Map<String, dynamic> toJson() => {
        if (products.isNotEmpty)
          'products': [
            for (final p in products)
              {
                if (p.defensivoId != null) 'defensivoId': p.defensivoId,
                'name': p.name,
                if (p.dose != null) 'dose': p.dose,
                if (p.carenciaDays != null) 'carenciaDays': p.carenciaDays,
              },
          ],
        if (recurrenceDays != null) 'recurrenceDays': recurrenceDays,
      };

  @override
  bool operator ==(Object other) =>
      other is PesticideDetails &&
      listEquals(other.products, products) &&
      other.recurrenceDays == recurrenceDays;

  @override
  int get hashCode => Object.hash(Object.hashAll(products), recurrenceDays);
}

class PesticideProduct {
  final String? defensivoId;
  final String name;

  /// Free-text dose as typed by the user (e.g. "5 ml/L").
  final String? dose;

  /// The defensivo's carência when it was applied; null on older entries,
  /// which fall back to the catalog (see `carenciaOn`).
  final int? carenciaDays;

  const PesticideProduct({
    this.defensivoId,
    required this.name,
    this.dose,
    this.carenciaDays,
  });

  @override
  bool operator ==(Object other) =>
      other is PesticideProduct &&
      other.defensivoId == defensivoId &&
      other.name == name &&
      other.dose == dose &&
      other.carenciaDays == carenciaDays;

  @override
  int get hashCode => Object.hash(defensivoId, name, dose, carenciaDays);
}

/// `{"potDiameterCm": double, "potMaterial": String, "newSoilId": String,
/// "newSoilName": String}` — all keys optional. `potMaterial` is a
/// [PotMaterial] name. The soil name is copied at save time so the entry
/// survives catalog deletions, like [PesticideProduct.name].
final class RepottingDetails extends EntryDetails {
  final double? potDiameterCm;
  final PotMaterial? potMaterial;

  /// The soils row the plant was moved to, when the soil changed.
  final String? newSoilId;
  final String? newSoilName;

  const RepottingDetails({
    this.potDiameterCm,
    this.potMaterial,
    this.newSoilId,
    this.newSoilName,
  });

  factory RepottingDetails._fromJson(Map<String, dynamic> json) =>
      RepottingDetails(
        potDiameterCm: (json['potDiameterCm'] is num)
            ? (json['potDiameterCm'] as num).toDouble()
            : null,
        potMaterial: PotMaterial.fromName(_string(json['potMaterial'])),
        newSoilId: _string(json['newSoilId']),
        newSoilName: _string(json['newSoilName']),
      );

  @override
  bool get isEmpty =>
      potDiameterCm == null && potMaterial == null && newSoilId == null;

  @override
  Map<String, dynamic> toJson() => {
        if (potDiameterCm != null) 'potDiameterCm': potDiameterCm,
        if (potMaterial != null) 'potMaterial': potMaterial!.name,
        if (newSoilId != null) 'newSoilId': newSoilId,
        if (newSoilName != null) 'newSoilName': newSoilName,
      };

  @override
  bool operator ==(Object other) =>
      other is RepottingDetails &&
      other.potDiameterCm == potDiameterCm &&
      other.potMaterial == potMaterial &&
      other.newSoilId == newSoilId &&
      other.newSoilName == newSoilName;

  @override
  int get hashCode =>
      Object.hash(potDiameterCm, potMaterial, newSoilId, newSoilName);
}

/// `{"quantity": double, "unit": String, "duringCarencia": true}` — all keys
/// optional. `unit` is a [HarvestUnit] name; `duringCarencia` is only stored
/// when the harvest was confirmed while the plant was in carência.
final class HarvestDetails extends EntryDetails {
  final double? quantity;
  final HarvestUnit? unit;
  final bool duringCarencia;

  const HarvestDetails({
    this.quantity,
    this.unit,
    this.duringCarencia = false,
  });

  factory HarvestDetails._fromJson(Map<String, dynamic> json) =>
      HarvestDetails(
        quantity: (json['quantity'] is num)
            ? (json['quantity'] as num).toDouble()
            : null,
        unit: HarvestUnit.fromName(_string(json['unit'])),
        duringCarencia: json['duringCarencia'] == true,
      );

  HarvestDetails copyWith({bool? duringCarencia}) => HarvestDetails(
        quantity: quantity,
        unit: unit,
        duringCarencia: duringCarencia ?? this.duringCarencia,
      );

  @override
  bool get isEmpty => quantity == null && unit == null && !duringCarencia;

  @override
  Map<String, dynamic> toJson() => {
        if (quantity != null) 'quantity': quantity,
        if (unit != null) 'unit': unit!.name,
        if (duringCarencia) 'duringCarencia': true,
      };

  @override
  bool operator ==(Object other) =>
      other is HarvestDetails &&
      other.quantity == quantity &&
      other.unit == unit &&
      other.duringCarencia == duringCarencia;

  @override
  int get hashCode => Object.hash(quantity, unit, duringCarencia);
}

String? _string(Object? value) => value is String ? value : null;

Iterable<Map<String, dynamic>> _objects(Object? value) =>
    value is List ? value.whereType<Map<String, dynamic>>() : const [];
