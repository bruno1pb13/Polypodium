import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/review/review_prompter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late int requests;
  late ReviewPrompter prompter;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    requests = 0;
    prompter = ReviewPrompter(requestReview: () async => requests++);
  });

  Future<void> water(int times) async {
    for (var i = 0; i < times; i++) {
      await prompter.recordWatering();
    }
  }

  test('asks on the Nth watering', () async {
    await water(ReviewPrompter.wateringsBeforeAsking - 1);
    expect(requests, 0);
    await water(1);
    expect(requests, 1);
  });

  test('never asks again', () async {
    await water(ReviewPrompter.wateringsBeforeAsking * 3);
    expect(requests, 1);
  });

  test('the count survives restarts', () async {
    await water(ReviewPrompter.wateringsBeforeAsking - 1);
    prompter = ReviewPrompter(requestReview: () async => requests++);
    await water(1);
    expect(requests, 1);
  });

  test('a failing store flow is swallowed and not retried', () async {
    prompter = ReviewPrompter(requestReview: () async {
      requests++;
      throw Exception('no Play services');
    });
    await water(ReviewPrompter.wateringsBeforeAsking + 1);
    expect(requests, 1);
  });
}
