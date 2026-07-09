import 'package:flutter_test/flutter_test.dart';
import 'package:polypodium/core/sync/lww_merge.dart';

void main() {
  group('shouldApplyRemote', () {
    test('applies when there is no local row yet', () {
      expect(
        shouldApplyRemote(
          localUpdatedAt: null,
          remoteUpdatedAt: DateTime(2026, 1, 1),
        ),
        isTrue,
      );
    });

    test('applies when remote is strictly newer', () {
      expect(
        shouldApplyRemote(
          localUpdatedAt: DateTime(2026, 1, 1),
          remoteUpdatedAt: DateTime(2026, 1, 2),
        ),
        isTrue,
      );
    });

    test('rejects when remote is older', () {
      expect(
        shouldApplyRemote(
          localUpdatedAt: DateTime(2026, 1, 2),
          remoteUpdatedAt: DateTime(2026, 1, 1),
        ),
        isFalse,
      );
    });

    test('applies on an exact timestamp tie (remote wins ties)', () {
      final t = DateTime(2026, 1, 1, 12, 0, 0);
      expect(
        shouldApplyRemote(localUpdatedAt: t, remoteUpdatedAt: t),
        isTrue,
      );
    });

    test('re-applying the same change is idempotent', () {
      final t = DateTime(2026, 1, 1, 12, 0, 0);
      // First apply: no local row yet.
      expect(shouldApplyRemote(localUpdatedAt: null, remoteUpdatedAt: t), isTrue);
      // Second apply of the identical change: local now has updatedAt == t.
      expect(shouldApplyRemote(localUpdatedAt: t, remoteUpdatedAt: t), isTrue);
    });
  });
}
