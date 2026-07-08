// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(workspaceRepository)
final workspaceRepositoryProvider = WorkspaceRepositoryProvider._();

final class WorkspaceRepositoryProvider extends $FunctionalProvider<
    WorkspaceRepository,
    WorkspaceRepository,
    WorkspaceRepository> with $Provider<WorkspaceRepository> {
  WorkspaceRepositoryProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'workspaceRepositoryProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$workspaceRepositoryHash();

  @$internal
  @override
  $ProviderElement<WorkspaceRepository> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  WorkspaceRepository create(Ref ref) {
    return workspaceRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WorkspaceRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WorkspaceRepository>(value),
    );
  }
}

String _$workspaceRepositoryHash() =>
    r'b0fe320ad13912da114e1cc0b204ac1eb40820a6';

@ProviderFor(WorkspacesNotifier)
final workspacesNotifierProvider = WorkspacesNotifierProvider._();

final class WorkspacesNotifierProvider
    extends $NotifierProvider<WorkspacesNotifier, List<Workspace>> {
  WorkspacesNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'workspacesNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$workspacesNotifierHash();

  @$internal
  @override
  WorkspacesNotifier create() => WorkspacesNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<Workspace> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<Workspace>>(value),
    );
  }
}

String _$workspacesNotifierHash() =>
    r'f5d3f39f6f0346e8af6940da03e2f3a3b6739cf7';

abstract class _$WorkspacesNotifier extends $Notifier<List<Workspace>> {
  List<Workspace> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<Workspace>, List<Workspace>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<List<Workspace>, List<Workspace>>,
        List<Workspace>,
        Object?,
        Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(ActiveWorkspaceIdNotifier)
final activeWorkspaceIdNotifierProvider = ActiveWorkspaceIdNotifierProvider._();

final class ActiveWorkspaceIdNotifierProvider
    extends $NotifierProvider<ActiveWorkspaceIdNotifier, String> {
  ActiveWorkspaceIdNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeWorkspaceIdNotifierProvider',
          isAutoDispose: false,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeWorkspaceIdNotifierHash();

  @$internal
  @override
  ActiveWorkspaceIdNotifier create() => ActiveWorkspaceIdNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String>(value),
    );
  }
}

String _$activeWorkspaceIdNotifierHash() =>
    r'8ec109edbcffcc12aa3d630b2122fb8d156c6d3d';

abstract class _$ActiveWorkspaceIdNotifier extends $Notifier<String> {
  String build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<String, String>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<String, String>, String, Object?, Object?>;
    return element.handleCreate(ref, build);
  }
}

@ProviderFor(activeWorkspace)
final activeWorkspaceProvider = ActiveWorkspaceProvider._();

final class ActiveWorkspaceProvider
    extends $FunctionalProvider<Workspace, Workspace, Workspace>
    with $Provider<Workspace> {
  ActiveWorkspaceProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'activeWorkspaceProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$activeWorkspaceHash();

  @$internal
  @override
  $ProviderElement<Workspace> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Workspace create(Ref ref) {
    return activeWorkspace(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Workspace value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Workspace>(value),
    );
  }
}

String _$activeWorkspaceHash() => r'b25fd7253aaac449fc6987be914674dc83b55efb';
