import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/enums.dart';
import 'package:polypodium/features/defensivos/domain/defensivo_model.dart';
import 'package:polypodium/features/entries/domain/carencia.dart';
import 'package:polypodium/features/entries/domain/entry_details.dart';
import 'package:polypodium/features/entries/domain/entry_model.dart';

void main() {
  var nextId = 0;
  EntryModel pesticide(DateTime date, List<PesticideProduct> products,
          {DateTime? deletedAt, EntryType type = EntryType.pesticide}) =>
      EntryModel(
        id: 'e${nextId++}',
        plantId: 'p1',
        date: date,
        type: type,
        extraData: PesticideDetails(products: products).encode(),
        createdAt: date,
        deletedAt: deletedAt,
      );

  const neem = PesticideProduct(defensivoId: 'd1', name: 'Neem');
  const calda = PesticideProduct(defensivoId: 'd2', name: 'Calda');
  const catalog = {'d1': 3, 'd2': 7};

  group('carenciaDaysByDefensivo', () {
    test('skips deleted defensivos and those without carência', () {
      DefensivoModel d(String id, int? days, {bool deleted = false}) =>
          DefensivoModel(
            id: id,
            name: id,
            carenciaDays: days,
            createdAt: DateTime(2026),
            deletedAt: deleted ? DateTime(2026, 2) : null,
          );
      expect(
        carenciaDaysByDefensivo([
          d('a', 3),
          d('b', null),
          d('c', 5, deleted: true),
          d('z', 0),
        ]),
        {'a': 3, 'z': 0},
      );
    });
  });

  group('carenciaOn', () {
    test('covers the application day up to N-1 days after it', () {
      final entries = [
        pesticide(DateTime(2026, 10, 1, 18), [neem])
      ];
      final expected =
          CarenciaStatus(until: DateTime(2026, 10, 3), productNames: ['Neem']);

      // Calendar days: the hour of the application doesn't matter.
      expect(carenciaOn(DateTime(2026, 10, 1, 8), entries, catalog), expected);
      expect(carenciaOn(DateTime(2026, 10, 3, 23, 59), entries, catalog),
          expected);
      expect(carenciaOn(DateTime(2026, 10, 4), entries, catalog), isNull);
      // Before the application there was no carência yet.
      expect(carenciaOn(DateTime(2026, 9, 30, 23), entries, catalog), isNull);
    });

    test('takes the latest end over products and entries', () {
      final entries = [
        pesticide(DateTime(2026, 10, 1), [neem, calda]),
        pesticide(DateTime(2026, 10, 5), [neem]),
      ];

      // Calda (7 days from 1/10) still runs; the second Neem ends sooner.
      expect(
        carenciaOn(DateTime(2026, 10, 5), entries, catalog),
        CarenciaStatus(
            until: DateTime(2026, 10, 7), productNames: ['Calda', 'Neem']),
      );
      // Both products of the first application.
      expect(
        carenciaOn(DateTime(2026, 10, 2), [entries.first], catalog),
        CarenciaStatus(
            until: DateTime(2026, 10, 7), productNames: ['Neem', 'Calda']),
      );
      expect(
        carenciaOn(DateTime(2026, 10, 7), entries, catalog)?.productNames,
        ['Calda', 'Neem'],
      );
      expect(
        carenciaOn(DateTime(2026, 10, 8), entries, catalog),
        isNull,
      );
    });

    test('ignores products without carência or no longer in the catalog', () {
      final entries = [
        pesticide(DateTime(2026, 10, 1), [
          const PesticideProduct(defensivoId: 'gone', name: 'Removido'),
          const PesticideProduct(name: 'Sem catálogo'),
          neem,
        ]),
      ];
      expect(
        carenciaOn(DateTime(2026, 10, 2), entries, catalog),
        CarenciaStatus(until: DateTime(2026, 10, 3), productNames: ['Neem']),
      );
      expect(carenciaOn(DateTime(2026, 10, 2), entries, const {}), isNull);
      // 0 days means no carência at all.
      expect(
          carenciaOn(DateTime(2026, 10, 1), entries, const {'d1': 0}), isNull);
    });

    test(
        'the copied carência wins over the catalog, which only fills in '
        'older entries', () {
      final entries = [
        pesticide(DateTime(2026, 10, 1), [
          const PesticideProduct(
              defensivoId: 'd1', name: 'Neem', carenciaDays: 10),
        ]),
        pesticide(DateTime(2026, 10, 1), [calda]),
      ];
      // The catalog now says 3 days for Neem; the entry recorded 10.
      expect(
        carenciaOn(DateTime(2026, 10, 9), entries, catalog),
        CarenciaStatus(until: DateTime(2026, 10, 10), productNames: ['Neem']),
      );
      // A copied carência survives the defensivo's deletion.
      expect(
        carenciaOn(DateTime(2026, 10, 9), entries, const {})?.until,
        DateTime(2026, 10, 10),
      );
      // A copied 0 is kept too, even if the catalog says otherwise now.
      expect(
        carenciaOn(
          DateTime(2026, 10, 1),
          [
            pesticide(DateTime(2026, 10, 1), [
              const PesticideProduct(
                  defensivoId: 'd2', name: 'Calda', carenciaDays: 0),
            ]),
          ],
          catalog,
        ),
        isNull,
      );
    });

    test('ignores deleted entries and other entry types', () {
      final entries = [
        pesticide(DateTime(2026, 10, 1), [calda],
            deletedAt: DateTime(2026, 10, 2)),
        pesticide(DateTime(2026, 10, 1), [calda], type: EntryType.fertilizer),
      ];
      expect(carenciaOn(DateTime(2026, 10, 2), entries, catalog), isNull);
    });

    test('crosses month and year boundaries by calendar days', () {
      final entries = [
        pesticide(DateTime(2026, 12, 28, 22), [calda])
      ];
      expect(
        carenciaOn(DateTime(2027, 1, 3, 1), entries, catalog)?.until,
        DateTime(2027, 1, 3),
      );
      expect(carenciaOn(DateTime(2027, 1, 4), entries, catalog), isNull);
    });
  });
}
