import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/features/admin/domain/server_watering_settings.dart';
import 'package:polypodium/features/weather/domain/local_watering_rules.dart';

void main() {
  test('starts at the built-in defaults', () {
    const rules = LocalWateringRules();
    expect(rules.isDefault, isTrue);
    expect(rules.value(WateringRule.maxPostponeDays), 7);
    expect(rules.toRules().maxPostponeDays, 7);
  });

  test('stores only what differs from the default, within the limits', () {
    final rules = const LocalWateringRules()
        .withRule(WateringRule.maxAdvanceDays, 4)
        .withRule(WateringRule.minRainMm, 80)
        .withRule(WateringRule.rainEfficiency, 0.7);
    expect(rules.overrides, {
      WateringRule.maxAdvanceDays: 4.0,
      WateringRule.minRainMm: 50.0,
    });
    expect(rules.toRules().maxAdvanceDays, 4);

    final back = LocalWateringRules.fromJson(rules.toJson());
    expect(back.overrides, rules.overrides);
    expect(back.withRule(WateringRule.maxAdvanceDays, 2).overrides,
        {WateringRule.minRainMm: 50.0});
  });

  test('ignores a broken or out-of-range setting', () {
    expect(LocalWateringRules.fromJson('not json').overrides, isEmpty);
    expect(LocalWateringRules.fromJson('[1]').overrides, isEmpty);
    expect(
      LocalWateringRules.fromJson(
              '{"minDemand": 3, "maxDemand": 2.5, "unknown": 1}')
          .overrides,
      {WateringRule.maxDemand: 2.5},
    );
  });
}
