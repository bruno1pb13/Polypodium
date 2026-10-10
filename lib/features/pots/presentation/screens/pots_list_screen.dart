import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../../core/widgets/app_search_bar.dart';
import '../../../entries/presentation/providers/entries_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/pot_with_plants.dart';
import '../providers/pots_providers.dart';
import '../providers/pots_search_providers.dart';
import '../widgets/pot_actions.dart';
import '../widgets/pot_ui.dart';
import 'add_edit_pot_screen.dart';
import 'pot_detail_screen.dart';

class PotsListScreen extends ConsumerStatefulWidget {
  const PotsListScreen({super.key});

  @override
  ConsumerState<PotsListScreen> createState() => _PotsListScreenState();
}

class _PotsListScreenState extends ConsumerState<PotsListScreen> {
  final _searchController = TextEditingController();

  Future<void> _refresh() async {
    ref.invalidate(potsNotifierProvider);
    try {
      await ref.read(filteredSortedPotsProvider.future);
    } catch (_) {}
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final potsAsync = ref.watch(filteredSortedPotsProvider);

    return PotScreenScaffold(
      title: l10n.navPots,
      floatingActionButton: FloatingActionButton(
        tooltip: l10n.addPot,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPotScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          AppSearchBar<PotSortOption>(
            controller: _searchController,
            hintText: l10n.searchPotsHint,
            onChanged: (value) =>
                ref.read(potSearchQueryProvider.notifier).setQuery(value),
            onSortSelected: (option) => ref
                .read(potSortOptionNotifierProvider.notifier)
                .setSortOption(option),
            sortOptions: [
              PopupMenuItem(
                value: PotSortOption.nameAZ,
                child: Text(l10n.sortNameAZ),
              ),
              PopupMenuItem(
                value: PotSortOption.mostPlants,
                child: Text(l10n.sortMostPlants),
              ),
              PopupMenuItem(
                value: PotSortOption.dateAdded,
                child: Text(l10n.sortDateAdded),
              ),
            ],
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.white,
              backgroundColor: Colors.black54,
              child: potsAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.glass.fg),
                ),
                error: (e, _) => Center(
                  child: Text(l10n.errorGeneric('$e'),
                      style: TextStyle(color: context.glass.fg)),
                ),
                data: (pots) {
                  if (pots.isEmpty) {
                    return LayoutBuilder(
                      builder: (_, constraints) => SingleChildScrollView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: SizedBox(
                          height: constraints.maxHeight,
                          child: _searchController.text.isNotEmpty
                              ? Center(
                                  child: Text(l10n.noPotsFound,
                                      style:
                                          TextStyle(color: context.glass.fg)))
                              : const _EmptyState(),
                        ),
                      ),
                    );
                  }
                  return ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(top: 8, bottom: 80),
                    itemCount: pots.length,
                    itemBuilder: (_, i) => PotListItem(
                      pot: pots[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PotDetailScreen(potId: pots[i].pot.id),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A pot in the list: kind, name, location, size/material and its plants.
class PotListItem extends ConsumerWidget {
  final PotWithPlants pot;
  final VoidCallback onTap;

  const PotListItem({super.key, required this.pot, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final transparencyEnabled = ref.watch(transparencyEnabledNotifierProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final pushCursor = ref.watch(pushCursorToServerProvider).value;
    final isPendingSync = pushCursor != null && pot.pot.localRev > pushCursor;
    final muted = transparencyEnabled
        ? context.glass.fgMuted
        : colorScheme.onSurfaceVariant.withValues(alpha: 0.7);
    final specs = potSpecs(l10n, pot.pot);
    final details = [
      if (pot.location != null) pot.location!.name,
      if (specs != null) specs,
    ].join(' · ');
    final active = pot.activePlants;

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
                    PotKindBadge(kind: pot.pot.kind),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pot.pot.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: transparencyEnabled
                                  ? context.glass.fg
                                  : colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (details.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(details,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 13, color: muted)),
                          ],
                          const SizedBox(height: 2),
                          Text(
                            pot.plants.isEmpty
                                ? l10n.potPlantCount(0)
                                : '${l10n.potPlantCount(pot.plants.length)}: '
                                    '${pot.plants.map((p) => p.plant.nickname).join(', ')}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 13, color: muted),
                          ),
                        ],
                      ),
                    ),
                    if (isPendingSync)
                      Tooltip(
                        message: l10n.pendingSync,
                        child: Icon(
                          Icons.cloud_upload_outlined,
                          size: 16,
                          color: transparencyEnabled
                              ? context.glass.warning
                              : Colors.orange,
                        ),
                      ),
                    if (active.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.water_drop_outlined),
                        color: transparencyEnabled
                            ? context.glass.fgMuted
                            : colorScheme.onSurfaceVariant,
                        tooltip: l10n.waterPot,
                        onPressed: () => waterPotPlants(
                          context,
                          ref.read(entryMutationsProvider),
                          [for (final p in active) p.plant.id],
                        ),
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
          Icon(Icons.yard_outlined, size: 64, color: context.glass.tint(0.4)),
          const SizedBox(height: 16),
          Text(
            context.l10n.noPotsRegistered,
            style: TextStyle(color: context.glass.fg, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            context.l10n.tapToAddPot,
            style: TextStyle(fontSize: 13, color: context.glass.fgMuted),
          ),
        ],
      ),
    );
  }
}
