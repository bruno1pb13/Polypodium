import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../plants/presentation/screens/plant_group_screen.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/location_model.dart';
import '../providers/locations_providers.dart';
import '../providers/locations_search_providers.dart';
import 'add_edit_location_screen.dart';
import '../../../../core/theme/glass_colors.dart';

class LocationsListScreen extends ConsumerStatefulWidget {
  const LocationsListScreen({super.key});

  @override
  ConsumerState<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends ConsumerState<LocationsListScreen> {
  final _searchController = TextEditingController();

  Future<void> _refresh() async {
    ref.invalidate(locationsNotifierProvider);
    try {
      await ref.read(filteredSortedLocationsProvider.future);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locationsAsync = ref.watch(filteredSortedLocationsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          context.l10n.navLocations,
          style: TextStyle(
            color: context.glass.fg,
            fontWeight: FontWeight.w600,
            shadows: [
              Shadow(
                color: context.glass.shadow(Colors.black45),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              excludeFromSemantics: true,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    context.glass.scrim(0.5),
                    Colors.transparent,
                    context.glass.scrim(0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                AppSearchBar<LocationSortOption>(
                  controller: _searchController,
                  hintText: context.l10n.searchLocationsHint,
                  onChanged: (value) {
                    ref.read(locationSearchQueryProvider.notifier).setQuery(value);
                  },
                  onSortSelected: (option) {
                    ref
                        .read(locationSortOptionNotifierProvider.notifier)
                        .setSortOption(option);
                  },
                  sortOptions: [
                    PopupMenuItem(
                      value: LocationSortOption.nameAZ,
                      child: Text(context.l10n.sortNameAZ),
                    ),
                    PopupMenuItem(
                      value: LocationSortOption.nameZA,
                      child: Text(context.l10n.sortNameZA),
                    ),
                    PopupMenuItem(
                      value: LocationSortOption.dateAdded,
                      child: Text(context.l10n.sortDateAdded),
                    ),
                  ],
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _refresh,
                    color: Colors.white,
                    backgroundColor: Colors.black54,
                    child: locationsAsync.when(
                      loading: () => Center(
                        child:
                            CircularProgressIndicator(color: context.glass.fg),
                      ),
                      error: (e, _) => Center(
                        child: Text(
                          context.l10n.errorGeneric('$e'),
                          style: TextStyle(color: context.glass.fg),
                        ),
                      ),
                      data: (locations) {
                        if (locations.isEmpty) {
                          return LayoutBuilder(
                            builder: (_, constraints) => SingleChildScrollView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              child: SizedBox(
                                height: constraints.maxHeight,
                                child: _searchController.text.isNotEmpty
                                    ? Center(
                                        child: Text(
                                            context.l10n.noLocationsFound,
                                            style: TextStyle(
                                                color: context.glass.fg)))
                                    : const _EmptyState(),
                              ),
                            ),
                          );
                        }
                        return ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: locations.length,
                          itemBuilder: (ctx, i) => _LocationListItem(
                            location: locations[i],
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PlantGroupScreen.byLocation(
                                  title: locations[i].name,
                                  locationId: locations[i].id,
                                ),
                              ),
                            ),
                            onEdit: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AddEditLocationScreen(location: locations[i]),
                              ),
                            ),
                            onDelete: () =>
                                _confirmDelete(context, ref, locations[i].id),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.addLocation,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditLocationScreen()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.deleteLocationTitle),
        content: Text(ctx.l10n.deleteLocationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(locationsNotifierProvider.notifier).delete(id);
    }
  }
}

class _LocationListItem extends ConsumerWidget {
  final LocationModel location;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LocationListItem({
    required this.location,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final pushCursor = ref.watch(pushCursorToServerProvider).value;
    final isPendingSync = pushCursor != null && location.localRev > pushCursor;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: transparencyEnabled
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            decoration: BoxDecoration(
              color: transparencyEnabled
                  ? context.glass.glassFill
                  : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: transparencyEnabled
                    ? context.glass.tint(0.1)
                    : Colors.transparent,
              ),
            ),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: transparencyEnabled
                            ? context.glass.tint(0.1)
                            : colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.location_on_outlined,
                        color: transparencyEnabled
                            ? context.glass.fg
                            : colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            location.name,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: transparencyEnabled
                                  ? context.glass.fg
                                  : colorScheme.onSurfaceVariant,
                              shadows: transparencyEnabled
                                  ? [
                                      Shadow(
                                        color: context.glass.shadow(Colors.black26),
                                        offset: Offset(0, 1),
                                        blurRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          if (location.description != null &&
                              location.description!.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              location.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: transparencyEnabled
                                    ? context.glass.fgMuted
                                    : colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.7),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (isPendingSync)
                      Tooltip(
                        message: context.l10n.pendingSync,
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 16,
                          color: transparencyEnabled
                              ? context.glass.warning
                              : Colors.orange,
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      color: transparencyEnabled
                          ? context.glass.fgMuted
                          : colorScheme.onSurfaceVariant,
                      tooltip: context.l10n.editLocation,
                      onPressed: onEdit,
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline),
                      color: transparencyEnabled
                          ? context.glass.fgMuted
                          : colorScheme.onSurfaceVariant,
                      tooltip: context.l10n.delete,
                      onPressed: onDelete,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on_outlined,
            size: 64,
            color: context.glass.tint(0.4),
          ),
          const SizedBox(height: 16),
          Text(
            context.l10n.noLocationsRegistered,
            style: TextStyle(color: context.glass.fg, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddLocation,
            style: TextStyle(fontSize: 13, color: context.glass.fgMuted),
          ),
        ],
      ),
    );
  }
}
