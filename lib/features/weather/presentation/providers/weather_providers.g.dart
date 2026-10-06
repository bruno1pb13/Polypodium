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

/// The server's forecast for a location, or null when there is none. Errors
/// count as none: weather is extra information and never blocks the list.

@ProviderFor(locationWeather)
final locationWeatherProvider = LocationWeatherFamily._();

/// The server's forecast for a location, or null when there is none. Errors
/// count as none: weather is extra information and never blocks the list.

final class LocationWeatherProvider extends $FunctionalProvider<
        AsyncValue<LocationWeather?>,
        LocationWeather?,
        FutureOr<LocationWeather?>>
    with $FutureModifier<LocationWeather?>, $FutureProvider<LocationWeather?> {
  /// The server's forecast for a location, or null when there is none. Errors
  /// count as none: weather is extra information and never blocks the list.
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

String _$locationWeatherHash() => r'60dc24faeb23a121f7b03169e12a44744e28500b';

/// The server's forecast for a location, or null when there is none. Errors
/// count as none: weather is extra information and never blocks the list.

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

  /// The server's forecast for a location, or null when there is none. Errors
  /// count as none: weather is extra information and never blocks the list.

  LocationWeatherProvider call(
    String locationId,
  ) =>
      LocationWeatherProvider._(argument: locationId, from: this);

  @override
  String toString() => r'locationWeatherProvider';
}
