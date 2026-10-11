import 'package:in_app_review/in_app_review.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../updates/distribution_channel.dart';
import '../updates/update_controller.dart';

part 'review_prompter.g.dart';

/// Asks for a store rating once, right after a happy moment: the user's
/// [wateringsBeforeAsking]th watering recorded on this device. Bulk
/// waterings count once. The store decides whether the sheet actually
/// shows (Play caps it per user), so it is never asked again either way.
class ReviewPrompter {
  ReviewPrompter({required Future<void> Function() requestReview})
      : _requestReview = requestReview;

  static const wateringsBeforeAsking = 10;
  static const _countKey = 'review.waterings';
  static const _askedKey = 'review.asked';

  final Future<void> Function() _requestReview;

  Future<void> recordWatering() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    final count = (prefs.getInt(_countKey) ?? 0) + 1;
    await prefs.setInt(_countKey, count);
    if (count < wateringsBeforeAsking) return;
    await prefs.setBool(_askedKey, true);
    try {
      await _requestReview();
    } catch (_) {
      // No Play services or no network: the rating is never worth an error.
    }
  }
}

/// Only Google Play builds ask: the in-app review API needs a copy
/// installed by Play, and the other channels have no such flow.
@Riverpod(keepAlive: true)
ReviewPrompter? reviewPrompter(Ref ref) {
  if (ref.watch(distributionChannelProvider) !=
      DistributionChannel.playStore) {
    return null;
  }
  return ReviewPrompter(requestReview: () async {
    final review = InAppReview.instance;
    if (await review.isAvailable()) await review.requestReview();
  });
}
