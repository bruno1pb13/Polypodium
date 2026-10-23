// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherClient)
final weatherClientProvider = WeatherClientProvider._();

final class WeatherClientProvider
    extends $FunctionalProvider<WeatherClient, WeatherClient, WeatherClient>
    with $Provider<WeatherClient> {
  WeatherClientProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'weatherClientProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$weatherClientHash();

  @$internal
  @override
  $ProviderElement<WeatherClient> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WeatherClient create(Ref ref) {
    return weatherClient(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherClient value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherClient>(value),
    );
  }
}

String _$weatherClientHash() => r'a5dc434c9178bd127634e95f3877d7319f8e4af4';

/// Whether the active workspace's server serves weather forecasts. False
/// for the local workspace, a disconnected one, or an unreachable server.

@ProviderFor(serverWeatherEnabled)
final serverWeatherEnabledProvider = ServerWeatherEnabledProvider._();

/// Whether the active workspace's server serves weather forecasts. False
/// for the local workspace, a disconnected one, or an unreachable server.

final class ServerWeatherEnabledProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether the active workspace's server serves weather forecasts. False
  /// for the local workspace, a disconnected one, or an unreachable server.
  ServerWeatherEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'serverWeatherEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$serverWeatherEnabledHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return serverWeatherEnabled(ref);
  }
}

String _$serverWeatherEnabledHash() =>
    r'd5a871ece83e9572dd9f6d9a9c06f049ff48e50e';

/// The forecast for a location, or null when there is none. Errors count
/// as none: weather is extra information and never blocks the list. The
/// local workspace reads what this device fetched itself; any other takes
/// it from its server.

@ProviderFor(locationWeather)
final locationWeatherProvider = LocationWeatherFamily._();

/// The forecast for a location, or null when there is none. Errors count
/// as none: weather is extra information and never blocks the list. The
/// local workspace reads what this device fetched itself; any other takes
/// it from its server.

final class LocationWeatherProvider extends $FunctionalProvider<
        AsyncValue<LocationWeather?>,
        LocationWeather?,
        FutureOr<LocationWeather?>>
    with $FutureModifier<LocationWeather?>, $FutureProvider<LocationWeather?> {
  /// The forecast for a location, or null when there is none. Errors count
  /// as none: weather is extra information and never blocks the list. The
  /// local workspace reads what this device fetched itself; any other takes
  /// it from its server.
  LocationWeatherProvider._(
      {required LocationWeatherFamily super.from,
      required String super.argument})
      : super(
          retry: null,
          name: r'locationWeatherProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$locationWeatherHash();

  @override
  String toString() {
    return r'locationWeatherProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<LocationWeather?> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<LocationWeather?> create(Ref ref) {
    final argument = this.argument as String;
    return locationWeather(
      ref,
      argument,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is LocationWeatherProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$locationWeatherHash() => r'e21fca96d61ee6cd7e2cf3f75fa74f254e7160e3';

/// The forecast for a location, or null when there is none. Errors count
/// as none: weather is extra information and never blocks the list. The
/// local workspace reads what this device fetched itself; any other takes
/// it from its server.

final class LocationWeatherFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<LocationWeather?>, String> {
  LocationWeatherFamily._()
      : super(
          retry: null,
          name: r'locationWeatherProvider',
          dependencies: null,
          $allTransitiveDependencies: null,
          isAutoDispose: true,
        );

  /// The forecast for a location, or null when there is none. Errors count
  /// as none: weather is extra information and never blocks the list. The
  /// local workspace reads what this device fetched itself; any other takes
  /// it from its server.

  LocationWeatherProvider call(
    String locationId,
  ) =>
      LocationWeatherProvider._(argument: locationId, from: this);

  @override
  String toString() => r'locationWeatherProvider';
}

/// The weather adjustments stored on this device, by plant id (see
/// WateringAdjustment): from the server after each sync, or computed here
/// for the local workspace.

@ProviderFor(wateringAdjustments)
final wateringAdjustmentsProvider = WateringAdjustmentsProvider._();

/// The weather adjustments stored on this device, by plant id (see
/// WateringAdjustment): from the server after each sync, or computed here
/// for the local workspace.

final class WateringAdjustmentsProvider extends $FunctionalProvider<
        AsyncValue<Map<String, WateringAdjustment>>,
        Map<String, WateringAdjustment>,
        Stream<Map<String, WateringAdjustment>>>
    with
        $FutureModifier<Map<String, WateringAdjustment>>,
        $StreamProvider<Map<String, WateringAdjustment>> {
  /// The weather adjustments stored on this device, by plant id (see
  /// WateringAdjustment): from the server after each sync, or computed here
  /// for the local workspace.
  WateringAdjustmentsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'wateringAdjustmentsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$wateringAdjustmentsHash();

  @$internal
  @override
  $StreamProviderElement<Map<String, WateringAdjustment>> $createElement(
          $ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<Map<String, WateringAdjustment>> create(Ref ref) {
    return wateringAdjustments(ref);
  }
}

String _$wateringAdjustmentsHash() =>
    r'7466067e7bca10041b74d92f32bc39abcdf906c3';

/// The "Previsão do tempo" setting of the local workspace (see
/// SettingsRepository.isLocalWeatherEnabled).

@ProviderFor(LocalWeatherEnabledNotifier)
final localWeatherEnabledNotifierProvider =
    LocalWeatherEnabledNotifierProvider._();

/// The "Previsão do tempo" setting of the local workspace (see
/// SettingsRepository.isLocalWeatherEnabled).
final class LocalWeatherEnabledNotifierProvider
    extends $NotifierProvider<LocalWeatherEnabledNotifier, bool> {
  /// The "Previsão do tempo" setting of the local workspace (see
  /// SettingsRepository.isLocalWeatherEnabled).
  LocalWeatherEnabledNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localWeatherEnabledNotifierProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localWeatherEnabledNotifierHash();

  @$internal
  @override
  LocalWeatherEnabledNotifier create() => LocalWeatherEnabledNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$localWeatherEnabledNotifierHash() =>
    r'4fa74366fce7d1f4b13995f271590a2924b10f66';

/// The "Previsão do tempo" setting of the local workspace (see
/// SettingsRepository.isLocalWeatherEnabled).

abstract class _$LocalWeatherEnabledNotifier extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<bool, bool>, bool, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

/// Whether this device computes the weather itself: only for the local
/// workspace, with the setting on. A workspace with a server never does.

@ProviderFor(localWeatherActive)
final localWeatherActiveProvider = LocalWeatherActiveProvider._();

/// Whether this device computes the weather itself: only for the local
/// workspace, with the setting on. A workspace with a server never does.

final class LocalWeatherActiveProvider
    extends $FunctionalProvider<bool, bool, bool> with $Provider<bool> {
  /// Whether this device computes the weather itself: only for the local
  /// workspace, with the setting on. A workspace with a server never does.
  LocalWeatherActiveProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localWeatherActiveProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localWeatherActiveHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return localWeatherActive(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$localWeatherActiveHash() =>
    r'2dc123f15128f0cd62e3dedc7be69293290ad77a';

@ProviderFor(localWeatherService)
final localWeatherServiceProvider = LocalWeatherServiceProvider._();

final class LocalWeatherServiceProvider extends $FunctionalProvider<
    LocalWeatherService,
    LocalWeatherService,
    LocalWeatherService> with $Provider<LocalWeatherService> {
  LocalWeatherServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localWeatherServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localWeatherServiceHash();

  @$internal
  @override
  $ProviderElement<LocalWeatherService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  LocalWeatherService create(Ref ref) {
    return localWeatherService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LocalWeatherService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LocalWeatherService>(value),
    );
  }
}

String _$localWeatherServiceHash() =>
    r'f73385b7f64130ae83c3a35623dcfafbbaf05261';

/// Keeps the local workspace's weather current while the app is open: on
/// start, hourly, and shortly after plants, species or locations change
/// (a watering, a new interval, new coordinates). Each run only fetches
/// the regions that are due, so most of them just recompute the advice.

@ProviderFor(LocalWeatherController)
final localWeatherControllerProvider = LocalWeatherControllerProvider._();

/// Keeps the local workspace's weather current while the app is open: on
/// start, hourly, and shortly after plants, species or locations change
/// (a watering, a new interval, new coordinates). Each run only fetches
/// the regions that are due, so most of them just recompute the advice.
final class LocalWeatherControllerProvider
    extends $NotifierProvider<LocalWeatherController, void> {
  /// Keeps the local workspace's weather current while the app is open: on
  /// start, hourly, and shortly after plants, species or locations change
  /// (a watering, a new interval, new coordinates). Each run only fetches
  /// the regions that are due, so most of them just recompute the advice.
  LocalWeatherControllerProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'localWeatherControllerProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$localWeatherControllerHash();

  @$internal
  @override
  LocalWeatherController create() => LocalWeatherController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$localWeatherControllerHash() =>
    r'3e7ae0d10dbca1927fe6b4dac5a9ef5852e1b60a';

/// Keeps the local workspace's weather current while the app is open: on
/// start, hourly, and shortly after plants, species or locations change
/// (a watering, a new interval, new coordinates). Each run only fetches
/// the regions that are due, so most of them just recompute the advice.

abstract class _$LocalWeatherController extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<void, void>, void, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}
