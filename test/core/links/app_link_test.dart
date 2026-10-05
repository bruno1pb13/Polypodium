import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/links/app_link.dart';

void main() {
  group('AppLink.parse', () {
    test('reads the links the home-screen widget sends', () {
      final agenda = AppLink.parse(Uri.parse('polypodium://agenda'))!;
      expect(agenda.type, AppLinkType.agenda);
      expect(agenda.plantId, isNull);

      final plant = AppLink.parse(Uri.parse('polypodium://plant?id=a%20b'))!;
      expect(plant.type, AppLinkType.plant);
      expect(plant.plantId, 'a b');

      final water = AppLink.parse(Uri.parse('polypodium://water?id=p1'))!;
      expect(water.type, AppLinkType.water);
      expect(water.plantId, 'p1');

      expect(AppLink.parse(Uri.parse('polypodium://refresh'))!.type,
          AppLinkType.refresh);
    });

    test('reads the link printed on labels', () {
      const id = '3f1c2b9e-6a4d-4e0b-9c8a-1d2e3f4a5b6c';
      final uri = AppLink.plantUri(id);
      expect(uri.toString(), 'polypodium://plant/$id');

      final link = AppLink.parse(uri)!;
      expect(link.type, AppLinkType.plant);
      expect(link.plantId, id);
      expect(AppLink.parse(Uri.parse('polypodium://plant/$id/'))!.plantId, id);
    });

    test('round-trips ids that need escaping', () {
      for (final id in ['a b', 'x/y', 'ç?#&']) {
        expect(AppLink.parse(AppLink.plantUri(id))!.plantId, id);
        expect(AppLink.tryParse(AppLink.plantUri(id).toString())!.plantId, id);
      }
    });

    test('ignores anything else', () {
      expect(AppLink.parse(null), isNull);
      expect(AppLink.parse(Uri.parse('https://agenda')), isNull);
      expect(AppLink.parse(Uri.parse('https://example.com/plant/p1')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://unknown')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://settings/p1')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://plant')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://plant/')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://plant/a/b')), isNull);
      expect(AppLink.parse(Uri.parse('polypodium://water?id=')), isNull);
    });
  });

  group('AppLink.tryParse', () {
    test('accepts the text of a scanned code', () {
      expect(AppLink.tryParse('  polypodium://plant/p1\n')!.plantId, 'p1');
    });

    test('rejects text that is not a link of the app', () {
      expect(AppLink.tryParse(null), isNull);
      expect(AppLink.tryParse(''), isNull);
      expect(AppLink.tryParse('hello world'), isNull);
      expect(AppLink.tryParse('http://[::1'), isNull);
      expect(AppLink.tryParse('7891000315507'), isNull);
    });
  });
}
