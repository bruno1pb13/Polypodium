// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_widget_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeWidgetGateway)
final homeWidgetGatewayProvider = HomeWidgetGatewayProvider._();

final class HomeWidgetGatewayProvider extends $FunctionalProvider<
    HomeWidgetGateway,
    HomeWidgetGateway,
    HomeWidgetGateway> with $Provider<HomeWidgetGateway> {
  HomeWidgetGatewayProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeWidgetGatewayProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeWidgetGatewayHash();

  @$internal
  @override
  $ProviderElement<HomeWidgetGateway> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeWidgetGateway create(Ref ref) {
    return homeWidgetGateway(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeWidgetGateway value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeWidgetGateway>(value),
    );
  }
}

String _$homeWidgetGatewayHash() => r'66546dc4a06d4e67c6e30b59f99e1c5355b11293';

/// Keeps the home-screen widget in step with the agenda while the app runs:
/// every new agenda (an action, a sync pull, a workspace switch, the resume
/// refresh) republishes the snapshot. Listen to it to keep it running.

@ProviderFor(homeWidgetSync)
final homeWidgetSyncProvider = HomeWidgetSyncProvider._();

/// Keeps the home-screen widget in step with the agenda while the app runs:
/// every new agenda (an action, a sync pull, a workspace switch, the resume
/// refresh) republishes the snapshot. Listen to it to keep it running.

final class HomeWidgetSyncProvider
    extends $FunctionalProvider<HomeWidgetSync, HomeWidgetSync, HomeWidgetSync>
    with $Provider<HomeWidgetSync> {
  /// Keeps the home-screen widget in step with the agenda while the app runs:
  /// every new agenda (an action, a sync pull, a workspace switch, the resume
  /// refresh) republishes the snapshot. Listen to it to keep it running.
  HomeWidgetSyncProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'homeWidgetSyncProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$homeWidgetSyncHash();

  @$internal
  @override
  $ProviderElement<HomeWidgetSync> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  HomeWidgetSync create(Ref ref) {
    return homeWidgetSync(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(HomeWidgetSync value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<HomeWidgetSync>(value),
    );
  }
}

String _$homeWidgetSyncHash() => r'00fc1a27c0ff9f35004a5b6630448519295f2fe6';
