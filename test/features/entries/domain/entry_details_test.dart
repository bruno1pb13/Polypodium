import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';

void main() {
  // Byte-for-byte what AddEntryScreen wrote before EntryDetails existed; the
  // same strings live in databases, backups and sync payloads.
  const goldens = <(EntryType, String, EntryDetails)>[
    (
      EntryType.pest,
      '{"pestType":"Cochonilha"}',
      PestDetails(pestType: 'Cochonilha'),
    ),
    (
      EntryType.fertilizer,
      '{"products":[{"name":"NPK 10-10-10","dose":2.5},{"name":"Húmus"}]}',
      FertilizerDetails(products: [
        FertilizerProduct(name: 'NPK 10-10-10', dose: 2.5),
        FertilizerProduct(name: 'Húmus'),
      ]),
    ),
    (
      EntryType.fertilizer,
      '{"products":[{"name":"Bokashi","dose":10.0}]}',
      FertilizerDetails(
          products: [FertilizerProduct(name: 'Bokashi', dose: 10)]),
    ),
    (
      EntryType.pruning,
      '{"reason":"limpeza"}',
      PruningDetails(reason: 'limpeza'),
    ),
    (
      EntryType.pesticide,
      '{"products":[{"defensivoId":"d1","name":"Óleo de neem","dose":"5 ml/L"},'
          '{"defensivoId":"d2","name":"Calda bordalesa"}],"recurrenceDays":14}',
      PesticideDetails(products: [
        PesticideProduct(
            defensivoId: 'd1', name: 'Óleo de neem', dose: '5 ml/L'),
        PesticideProduct(defensivoId: 'd2', name: 'Calda bordalesa'),
      ], recurrenceDays: 14),
    ),
    (
      EntryType.pesticide,
      '{"products":[{"defensivoId":"d1","name":"Neem"}]}',
      PesticideDetails(
          products: [PesticideProduct(defensivoId: 'd1', name: 'Neem')]),
    ),
    (
      EntryType.pesticide,
      '{"products":[{"defensivoId":"d1","name":"Neem","carenciaDays":3}]}',
      PesticideDetails(products: [
        PesticideProduct(defensivoId: 'd1', name: 'Neem', carenciaDays: 3),
      ]),
    ),
    (
      EntryType.pesticide,
      '{"recurrenceDays":7}',
      PesticideDetails(recurrenceDays: 7),
    ),
    (
      EntryType.repotting,
      '{"potDiameterCm":14.5,"potMaterial":"clay","newSoilId":"s1",'
          '"newSoilName":"Substrato"}',
      RepottingDetails(
        potDiameterCm: 14.5,
        potMaterial: PotMaterial.clay,
        newSoilId: 's1',
        newSoilName: 'Substrato',
      ),
    ),
    (
      EntryType.repotting,
      '{"potMaterial":"fabric"}',
      RepottingDetails(potMaterial: PotMaterial.fabric),
    ),
  ];

  group('golden extraData', () {
    for (final (type, json, details) in goldens) {
      test('decodes ${type.name} $json', () {
        expect(EntryDetails.decode(type, json), details);
      });

      test('encodes ${type.name} $json byte-for-byte', () {
        expect(details.encode(), json);
      });

      test('round-trips ${type.name} $json', () {
        expect(EntryDetails.decode(type, details.encode()), details);
      });
    }
  });

  group('encode', () {
    test('returns null when there is nothing to store', () {
      expect(const PestDetails().encode(), isNull);
      expect(const PestDetails(pestType: '').encode(), isNull);
      expect(const FertilizerDetails().encode(), isNull);
      expect(const PruningDetails().encode(), isNull);
      expect(const PesticideDetails().encode(), isNull);
      expect(const RepottingDetails().encode(), isNull);
    });
  });

  group('lenient decode', () {
    test('returns null for missing or malformed JSON', () {
      for (final json in [null, '', 'not json', '{', '[]', '42', '"x"']) {
        expect(EntryDetails.decode(EntryType.pesticide, json), isNull,
            reason: json);
      }
    });

    test('returns null for entry types without details', () {
      for (final type in [
        EntryType.irrigation,
        EntryType.observation,
        EntryType.height,
        EntryType.chlorosis,
        EntryType.other,
        EntryType.history,
      ]) {
        expect(EntryDetails.decode(type, '{"pestType":"x"}'), isNull);
      }
    });

    test('an empty object yields empty details', () {
      expect(EntryDetails.decode(EntryType.pest, '{}'), const PestDetails());
      expect(EntryDetails.decode(EntryType.fertilizer, '{}'),
          const FertilizerDetails());
      expect(
          EntryDetails.decode(EntryType.pruning, '{}'), const PruningDetails());
      expect(EntryDetails.decode(EntryType.pesticide, '{}'),
          const PesticideDetails());
      expect(EntryDetails.decode(EntryType.repotting, '{}'),
          const RepottingDetails());
    });

    test('repotting: unexpected types are skipped, unknown materials kept '
        'as other', () {
      expect(
          EntryDetails.decode(EntryType.repotting,
              '{"potDiameterCm":"14","potMaterial":3,"newSoilId":7}'),
          const RepottingDetails());
      expect(
          EntryDetails.decode(EntryType.repotting,
              '{"potDiameterCm":12,"potMaterial":"bamboo"}'),
          const RepottingDetails(
              potDiameterCm: 12, potMaterial: PotMaterial.other));
    });

    test('ignores fields of unexpected types', () {
      expect(EntryDetails.decode(EntryType.pest, '{"pestType":3}'),
          const PestDetails());
      expect(EntryDetails.decode(EntryType.pruning, '{"reason":["a"]}'),
          const PruningDetails());
      expect(
          EntryDetails.decode(EntryType.fertilizer,
              '{"products":[{"name":"A","dose":"2"},"junk",{"dose":1}]}'),
          const FertilizerDetails(products: [
            FertilizerProduct(name: 'A'),
            FertilizerProduct(name: '', dose: 1),
          ]));
      expect(
          EntryDetails.decode(EntryType.pesticide,
              '{"products":{"name":"A"},"recurrenceDays":"7"}'),
          const PesticideDetails());
      expect(
          EntryDetails.decode(EntryType.pesticide,
              '{"products":[{"name":"A","carenciaDays":"7"}]}'),
          const PesticideDetails(products: [PesticideProduct(name: 'A')]));
    });

    test('accepts numeric values encoded as int or double', () {
      expect(
          EntryDetails.decode(
              EntryType.fertilizer, '{"products":[{"name":"A","dose":3}]}'),
          const FertilizerDetails(
              products: [FertilizerProduct(name: 'A', dose: 3.0)]));
      expect(EntryDetails.decode(EntryType.pesticide, '{"recurrenceDays":7.0}'),
          const PesticideDetails(recurrenceDays: 7));
      expect(
          EntryDetails.decode(EntryType.pesticide,
              '{"products":[{"name":"A","carenciaDays":7.0}]}'),
          const PesticideDetails(
              products: [PesticideProduct(name: 'A', carenciaDays: 7)]));
    });

    test('ignores unknown keys', () {
      expect(
          EntryDetails.decode(
              EntryType.pruning, '{"reason":"colheita","future":true}'),
          const PruningDetails(reason: 'colheita'));
    });
  });

  test('PesticideDetails.recurrenceDaysOf reads the raw column', () {
    expect(PesticideDetails.recurrenceDaysOf('{"recurrenceDays":21}'), 21);
    expect(PesticideDetails.recurrenceDaysOf('{"products":[]}'), isNull);
    expect(PesticideDetails.recurrenceDaysOf(null), isNull);
    expect(PesticideDetails.recurrenceDaysOf('garbage'), isNull);
  });

  test('EntryModel.details decodes by entry type', () {
    EntryModel entry(EntryType type, String? extraData) => EntryModel(
          id: 'e1',
          plantId: 'p1',
          date: DateTime(2026),
          type: type,
          extraData: extraData,
          createdAt: DateTime(2026),
        );

    expect(entry(EntryType.pruning, '{"reason":"formacao"}').details,
        const PruningDetails(reason: 'formacao'));
    expect(
        entry(EntryType.irrigation, '{"reason":"formacao"}').details, isNull);
    expect(entry(EntryType.pest, null).details, isNull);
  });
}
