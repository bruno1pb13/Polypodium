import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/admin/domain/account_info.dart';
import 'package:polypodium/features/admin/domain/server_data_settings.dart';
import 'package:polypodium/features/admin/domain/server_weather_status.dart';

void main() {
  test('servers predating weather report no support', () {
    final old = ServerDataSettings.fromJson(
        {'allowMemberExport': true, 'allowMemberImport': false});
    expect(old.supportsWeather, isFalse);
    expect(AccountInfo.fromJson({'role': 'member'}).weatherEnabled, isFalse);

    final current = ServerDataSettings.fromJson({
      'allowMemberExport': true,
      'allowMemberImport': true,
      'weatherEnabled': false,
    });
    expect(current.supportsWeather, isTrue);
    expect(current.weatherEnabled, isFalse);
  });

  test('weather status summarizes the regions', () {
    final status = ServerWeatherStatus.fromJson({
      'enabled': true,
      'regions': [
        {'lastFetchedAt': '2026-10-05T10:00:00.000Z', 'lastError': null},
        {'lastFetchedAt': '2026-10-06T09:30:00.000Z', 'lastError': null},
        {'lastFetchedAt': null, 'lastError': 'HTTP 503'},
      ],
    });
    expect(status.enabled, isTrue);
    expect(status.regionCount, 3);
    expect(status.failingRegionCount, 1);
    expect(status.lastFetchedAt, DateTime.utc(2026, 10, 6, 9, 30).toLocal());
  });
}
