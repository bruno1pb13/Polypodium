import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/links/app_link_handler.dart';
import '../../../../core/sync/auto_sync_controller.dart';
import '../../../../core/sync/sync_providers.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/app_shell.dart';
import '../../../labels/data/label_scanner.dart';
import '../../../locations/presentation/screens/locations_list_screen.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../plants/presentation/screens/add_edit_plant_screen.dart';
import '../../../plants/presentation/screens/home_screen.dart';
import '../../../species/presentation/screens/species_list_screen.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../../domain/garden_overview.dart';
import '../providers/dashboard_providers.dart';
import '../widgets/dashboard_activity_cards.dart';
import '../widgets/dashboard_card.dart';
import '../widgets/dashboard_care_cards.dart';
import '../widgets/dashboard_garden_cards.dart';
import '../widgets/dashboard_summary.dart';

/// Content wider than this is centered instead of stretched.
const _maxContentWidth = 960.0;

/// From this content width on, cards pair up side by side.
const _twoColumnWidth = 720.0;

/// The app's start screen: today's care, garden health, recent activity and
/// a glimpse of the plants, each leading to its full screen.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  Future<void> _refresh() async {
    if (ref.read(activeWorkspaceProvider).isLoggedIn) {
      await ref.read(autoSyncControllerProvider.notifier).syncNow();
    }
    ref.invalidate(plantsNotifierProvider);
    try {
      await ref.read(gardenOverviewProvider.future);
    } catch (_) {}
  }

  Future<void> _scanLabel() async {
    final navigator = Navigator.of(context);
    final code = await ref.read(labelScannerProvider).scan(context);
    if (code == null || !mounted) return;
    await openScannedLabel(
        navigator, code, ref.read(plantsRepositoryProvider).getById);
  }

  Future<void> _manualSync() async {
    await ref.read(syncNotifierProvider.notifier).sync();
    if (!mounted) return;
    final state = ref.read(syncNotifierProvider);
    if (state.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(localizedErrorMessage(state.error!, context.l10n)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _push(Widget screen) => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => screen),
      );

  @override
  Widget build(BuildContext context) {
    final overviewAsync = ref.watch(gardenOverviewProvider);
    final hasAnyPlant =
        ref.watch(plantsWithSpeciesProvider).value?.isNotEmpty ?? false;
    final workspace = ref.watch(activeWorkspaceProvider);
    final syncState = ref.watch(syncNotifierProvider);
    final scanner = ref.watch(labelScannerProvider);
    final wide = MediaQuery.sizeOf(context).width >= kWideBreakpoint;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: wide
            ? null
            : Text(
                'Polypodium',
                style: TextStyle(
                  fontFamily: 'CormorantGaramond',
                  fontWeight: FontWeight.w600,
                  fontSize: 28,
                  letterSpacing: 0.5,
                  color: context.glass.fg,
                  shadows: [
                    Shadow(
                      color: context.glass.shadow(Colors.black45),
                      offset: const Offset(0, 2),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
        actions: [
          if (scanner.isSupported)
            IconButton(
              icon: const Icon(Icons.qr_code_scanner),
              tooltip: context.l10n.labelScan,
              onPressed: _scanLabel,
            ),
          if (workspace.isLoggedIn)
            IconButton(
              icon: syncState.isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: context.glass.fg,
                      ),
                    )
                  : const Icon(Icons.sync),
              tooltip: context.l10n.syncNow,
              onPressed: syncState.isLoading ? null : _manualSync,
            ),
        ],
      ),
      drawer: wide ? null : const AppDrawer(),
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
                    context.glass.scrim(0.2),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              onRefresh: _refresh,
              color: Colors.white,
              backgroundColor: Colors.black54,
              child: overviewAsync.when(
                loading: () => Center(
                  child: CircularProgressIndicator(color: context.glass.fg),
                ),
                error: (e, _) => Center(
                  child: Text(
                    context.l10n.errorGeneric('$e'),
                    style: TextStyle(color: context.glass.fg),
                  ),
                ),
                data: (overview) => _DashboardBody(
                  overview: overview,
                  hasAnyPlant: hasAnyPlant,
                  push: _push,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: context.l10n.addPlant,
        onPressed: () => _push(const AddEditPlantScreen()),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _DashboardBody extends StatelessWidget {
  final GardenOverview overview;
  final bool hasAnyPlant;
  final void Function(Widget screen) push;

  const _DashboardBody({
    required this.overview,
    required this.hasAnyPlant,
    required this.push,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const gap = SizedBox(height: 12);

    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth.clamp(0.0, _maxContentWidth) - 32;
      final twoColumns = width >= _twoColumnWidth;

      Widget pair(Widget a, Widget? b) {
        if (b == null) return a;
        if (!twoColumns) return Column(children: [a, gap, b]);
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: a),
            const SizedBox(width: 12),
            Expanded(child: b),
          ],
        );
      }

      final children = <Widget>[
        DashboardGreeting(overview: overview, now: DateTime.now()),
        gap,
        if (!hasAnyPlant)
          const _WelcomeCard()
        else ...[
          DashboardStatTiles(stats: [
            (
              icon: Icons.local_florist_outlined,
              value: overview.activeCount,
              label: l10n.dashboardStatPlants,
              onTap: () => push(const HomeScreen()),
            ),
            (
              icon: Icons.eco_outlined,
              value: overview.speciesCount,
              label: l10n.dashboardStatSpecies,
              onTap: () => push(const SpeciesListScreen()),
            ),
            (
              icon: Icons.location_on_outlined,
              value: overview.locationCount,
              label: l10n.dashboardStatLocations,
              onTap: () => push(const LocationsListScreen()),
            ),
            (
              icon: Icons.edit_note,
              value: overview.entriesInWindow,
              label: l10n.dashboardStatEntries(activityWindowDays),
              onTap: null,
            ),
          ]),
          gap,
          pair(
            DashboardTodayCard(overview: overview),
            overview.activeCount > 0
                ? DashboardHealthCard(overview: overview)
                : null,
          ),
          if (overview.spotlight.isNotEmpty) ...[
            gap,
            DashboardGardenCarousel(overview: overview),
          ],
          gap,
          pair(
            DashboardActivityCard(overview: overview),
            overview.byLocation.isNotEmpty
                ? DashboardLocationsCard(overview: overview)
                : null,
          ),
          if (overview.recent.isNotEmpty) ...[
            gap,
            DashboardRecentCard(overview: overview),
          ],
        ],
      ];

      return ListView(
        key: const ValueKey('dashboard'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(
          horizontal:
              ((constraints.maxWidth - _maxContentWidth) / 2).clamp(0, 1e9) +
                  16,
        ).copyWith(top: 4, bottom: 96),
        children: children,
      );
    });
  }
}

class _WelcomeCard extends ConsumerWidget {
  const _WelcomeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final palette = dashboardPalette(context, ref);

    return DashboardCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(Icons.local_florist_outlined, size: 56, color: palette.growth),
          const SizedBox(height: 12),
          Text(
            context.l10n.dashboardEmptyTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: palette.ink,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            context.l10n.dashboardEmptyBody,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.5, color: palette.inkSoft),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            icon: const Icon(Icons.add),
            label: Text(context.l10n.addPlant),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddEditPlantScreen()),
            ),
          ),
        ],
      ),
    );
  }
}
