// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workspace_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$workspaceRepositoryHash() =>
    r'b0fe320ad13912da114e1cc0b204ac1eb40820a6';

/// See also [workspaceRepository].
@ProviderFor(workspaceRepository)
final workspaceRepositoryProvider = Provider<WorkspaceRepository>.internal(
  workspaceRepository,
  name: r'workspaceRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workspaceRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef WorkspaceRepositoryRef = ProviderRef<WorkspaceRepository>;
String _$activeWorkspaceHash() => r'b25fd7253aaac449fc6987be914674dc83b55efb';

/// See also [activeWorkspace].
@ProviderFor(activeWorkspace)
final activeWorkspaceProvider = AutoDisposeProvider<Workspace>.internal(
  activeWorkspace,
  name: r'activeWorkspaceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeWorkspaceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ActiveWorkspaceRef = AutoDisposeProviderRef<Workspace>;
String _$workspacesNotifierHash() =>
    r'87e4d6ef3a449a83f2cc43c16a03cc676c7a5a7c';

/// See also [WorkspacesNotifier].
@ProviderFor(WorkspacesNotifier)
final workspacesNotifierProvider =
    NotifierProvider<WorkspacesNotifier, List<Workspace>>.internal(
  WorkspacesNotifier.new,
  name: r'workspacesNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$workspacesNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$WorkspacesNotifier = Notifier<List<Workspace>>;
String _$activeWorkspaceIdNotifierHash() =>
    r'8ec109edbcffcc12aa3d630b2122fb8d156c6d3d';

/// See also [ActiveWorkspaceIdNotifier].
@ProviderFor(ActiveWorkspaceIdNotifier)
final activeWorkspaceIdNotifierProvider =
    NotifierProvider<ActiveWorkspaceIdNotifier, String>.internal(
  ActiveWorkspaceIdNotifier.new,
  name: r'activeWorkspaceIdNotifierProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$activeWorkspaceIdNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$ActiveWorkspaceIdNotifier = Notifier<String>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
