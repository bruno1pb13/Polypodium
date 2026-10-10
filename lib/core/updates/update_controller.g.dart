// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(distributionChannel)
final distributionChannelProvider = DistributionChannelProvider._();

final class DistributionChannelProvider extends $FunctionalProvider<
    DistributionChannel,
    DistributionChannel,
    DistributionChannel> with $Provider<DistributionChannel> {
  DistributionChannelProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'distributionChannelProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$distributionChannelHash();

  @$internal
  @override
  $ProviderElement<DistributionChannel> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DistributionChannel create(Ref ref) {
    return distributionChannel(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DistributionChannel value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DistributionChannel>(value),
    );
  }
}

String _$distributionChannelHash() =>
    r'57b627c7f23bc8e3b6e511be5977809b1790539e';

/// Running version name, e.g. `1.2.0`.

@ProviderFor(appVersion)
final appVersionProvider = AppVersionProvider._();

/// Running version name, e.g. `1.2.0`.

final class AppVersionProvider
    extends $FunctionalProvider<AsyncValue<String>, String, FutureOr<String>>
    with $FutureModifier<String>, $FutureProvider<String> {
  /// Running version name, e.g. `1.2.0`.
  AppVersionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'appVersionProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$appVersionHash();

  @$internal
  @override
  $FutureProviderElement<String> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<String> create(Ref ref) {
    return appVersion(ref);
  }
}

String _$appVersionHash() => r'59b58cc8214f60571dfe517b1f68cfc1aed29718';

/// How this copy of the app looks for updates, or null when it doesn't:
/// the Microsoft Store updates its apps by itself, and debug or package
/// manager installs aren't ours to update.

@ProviderFor(updateChecker)
final updateCheckerProvider = UpdateCheckerProvider._();

/// How this copy of the app looks for updates, or null when it doesn't:
/// the Microsoft Store updates its apps by itself, and debug or package
/// manager installs aren't ours to update.

final class UpdateCheckerProvider extends $FunctionalProvider<
        AsyncValue<UpdateChecker?>, UpdateChecker?, FutureOr<UpdateChecker?>>
    with $FutureModifier<UpdateChecker?>, $FutureProvider<UpdateChecker?> {
  /// How this copy of the app looks for updates, or null when it doesn't:
  /// the Microsoft Store updates its apps by itself, and debug or package
  /// manager installs aren't ours to update.
  UpdateCheckerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateCheckerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateCheckerHash();

  @$internal
  @override
  $FutureProviderElement<UpdateChecker?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<UpdateChecker?> create(Ref ref) {
    return updateChecker(ref);
  }
}

String _$updateCheckerHash() => r'23e82b7f0a3976eacb3106a211cf7b659b590a97';

/// The update on offer, or null. Checked automatically at most once a day
/// while the app is up to date (and on every launch while an update is
/// pending, until it is installed or dismissed); any failure is silent, the
/// app is offline-first.

@ProviderFor(UpdateController)
final updateControllerProvider = UpdateControllerProvider._();

/// The update on offer, or null. Checked automatically at most once a day
/// while the app is up to date (and on every launch while an update is
/// pending, until it is installed or dismissed); any failure is silent, the
/// app is offline-first.
final class UpdateControllerProvider
    extends $NotifierProvider<UpdateController, AvailableUpdate?> {
  /// The update on offer, or null. Checked automatically at most once a day
  /// while the app is up to date (and on every launch while an update is
  /// pending, until it is installed or dismissed); any failure is silent, the
  /// app is offline-first.
  UpdateControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'updateControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$updateControllerHash();

  @$internal
  @override
  UpdateController create() => UpdateController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AvailableUpdate? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AvailableUpdate?>(value),
    );
  }
}

String _$updateControllerHash() => r'1297b7d6e578887f55cdf9f7039bd2e357e9605d';

/// The update on offer, or null. Checked automatically at most once a day
/// while the app is up to date (and on every launch while an update is
/// pending, until it is installed or dismissed); any failure is silent, the
/// app is offline-first.

abstract class _$UpdateController extends $Notifier<AvailableUpdate?> {
  AvailableUpdate? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AvailableUpdate?, AvailableUpdate?>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AvailableUpdate?, AvailableUpdate?>,
        AvailableUpdate?,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}
