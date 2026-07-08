import 'package:flutter_riverpod/legacy.dart';

/// Tracks the set of plant ids selected in the Home screen's selection mode.
/// Selection mode is active whenever this set is non-empty.
final plantSelectionProvider =
    StateProvider.autoDispose<Set<String>>((ref) => {});
