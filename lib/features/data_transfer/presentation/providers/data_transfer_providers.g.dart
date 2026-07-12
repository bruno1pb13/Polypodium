// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'data_transfer_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dataExportService)
final dataExportServiceProvider = DataExportServiceProvider._();

final class DataExportServiceProvider extends $FunctionalProvider<
    DataExportService,
    DataExportService,
    DataExportService> with $Provider<DataExportService> {
  DataExportServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dataExportServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dataExportServiceHash();

  @$internal
  @override
  $ProviderElement<DataExportService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataExportService create(Ref ref) {
    return dataExportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataExportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataExportService>(value),
    );
  }
}

String _$dataExportServiceHash() => r'af068191c590322789ec931eeb8868f6b5451e10';

@ProviderFor(dataImportService)
final dataImportServiceProvider = DataImportServiceProvider._();

final class DataImportServiceProvider extends $FunctionalProvider<
    DataImportService,
    DataImportService,
    DataImportService> with $Provider<DataImportService> {
  DataImportServiceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dataImportServiceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dataImportServiceHash();

  @$internal
  @override
  $ProviderElement<DataImportService> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  DataImportService create(Ref ref) {
    return dataImportService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DataImportService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DataImportService>(value),
    );
  }
}

String _$dataImportServiceHash() => r'4af0d650b51adab2825525dfd37eb6ce2ec679aa';

/// Resolves whether the active workspace may export/import right now. The
/// server is asked fresh on every (re)build so a toggled admin setting takes
/// effect without re-login; invalidate this provider to re-check.

@ProviderFor(dataTransferPermission)
final dataTransferPermissionProvider = DataTransferPermissionProvider._();

/// Resolves whether the active workspace may export/import right now. The
/// server is asked fresh on every (re)build so a toggled admin setting takes
/// effect without re-login; invalidate this provider to re-check.

final class DataTransferPermissionProvider extends $FunctionalProvider<
        AsyncValue<DataTransferPermission>,
        DataTransferPermission,
        FutureOr<DataTransferPermission>>
    with
        $FutureModifier<DataTransferPermission>,
        $FutureProvider<DataTransferPermission> {
  /// Resolves whether the active workspace may export/import right now. The
  /// server is asked fresh on every (re)build so a toggled admin setting takes
  /// effect without re-login; invalidate this provider to re-check.
  DataTransferPermissionProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'dataTransferPermissionProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$dataTransferPermissionHash();

  @$internal
  @override
  $FutureProviderElement<DataTransferPermission> $createElement(
          $ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<DataTransferPermission> create(Ref ref) {
    return dataTransferPermission(ref);
  }
}

String _$dataTransferPermissionHash() =>
    r'1f91a4ac3629f84512ee618f0c77548e7d56cafc';
