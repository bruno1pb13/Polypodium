// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'review_prompter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Only Google Play builds ask: the in-app review API needs a copy
/// installed by Play, and the other channels have no such flow.

@ProviderFor(reviewPrompter)
final reviewPrompterProvider = ReviewPrompterProvider._();

/// Only Google Play builds ask: the in-app review API needs a copy
/// installed by Play, and the other channels have no such flow.

final class ReviewPrompterProvider extends $FunctionalProvider<ReviewPrompter?,
    ReviewPrompter?, ReviewPrompter?> with $Provider<ReviewPrompter?> {
  /// Only Google Play builds ask: the in-app review API needs a copy
  /// installed by Play, and the other channels have no such flow.
  ReviewPrompterProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'reviewPrompterProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$reviewPrompterHash();

  @$internal
  @override
  $ProviderElement<ReviewPrompter?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ReviewPrompter? create(Ref ref) {
    return reviewPrompter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReviewPrompter? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReviewPrompter?>(value),
    );
  }
}

String _$reviewPrompterHash() => r'60fd90a10a6f8b71fc8de2ce74f4b5adf7876a95';
