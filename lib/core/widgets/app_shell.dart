import 'package:flutter/material.dart';
import '../../features/plants/presentation/screens/home_screen.dart';
import '../../features/species/presentation/screens/species_list_screen.dart';
import '../../features/locations/presentation/screens/locations_list_screen.dart';
import '../../features/soils/presentation/screens/soils_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';

const double kWideBreakpoint = 720.0;
const double _kSidebarWidth = 240.0;

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;
  final _contentKey = GlobalKey<NavigatorState>();

  static const _labels = [
    'Minhas Plantas',
    'Espécies',
    'Localizações',
    'Solos',
    'Configurações',
  ];
  static const _icons = [
    Icons.home_outlined,
    Icons.eco_outlined,
    Icons.location_on_outlined,
    Icons.terrain_outlined,
    Icons.settings_outlined,
  ];
  static const _selectedIcons = [
    Icons.home,
    Icons.eco,
    Icons.location_on,
    Icons.terrain,
    Icons.settings,
  ];

  Widget _screen(int index) => switch (index) {
    0 => const HomeScreen(),
    1 => const SpeciesListScreen(),
    2 => const LocationsListScreen(),
    3 => const SoilsListScreen(),
    4 => const SettingsScreen(),
    _ => const HomeScreen(),
  };

  void _onSelected(int index) {
    if (index == _selectedIndex) {
      _contentKey.currentState?.popUntil((r) => r.isFirst);
      return;
    }
    setState(() => _selectedIndex = index);
    _contentKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => _screen(index)),
      (r) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < kWideBreakpoint) {
          return const HomeScreen();
        }

        return Scaffold(
          body: Row(
            children: [
              _SideNav(
                selectedIndex: _selectedIndex,
                labels: _labels,
                icons: _icons,
                selectedIcons: _selectedIcons,
                onSelected: _onSelected,
              ),
              Expanded(
                child: Navigator(
                  key: _contentKey,
                  onGenerateRoute: (_) => MaterialPageRoute(
                    builder: (_) => _screen(_selectedIndex),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({
    required this.selectedIndex,
    required this.labels,
    required this.icons,
    required this.selectedIcons,
    required this.onSelected,
  });

  final int selectedIndex;
  final List<String> labels;
  final List<IconData> icons;
  final List<IconData> selectedIcons;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: _kSidebarWidth,
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        border: Border(
          right: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.5)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with logo
          Container(
            height: 88,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            decoration: BoxDecoration(
              color: cs.primaryContainer.withValues(alpha: 0.45),
              border: Border(
                bottom: BorderSide(color: cs.outlineVariant.withValues(alpha: 0.4)),
              ),
            ),
            child: Row(
              children: [
                Image.asset('assets/images/logo.png', width: 40, height: 40),
                const SizedBox(width: 12),
                Text(
                  'Polypodium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontFamily: 'CormorantGaramond',
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    letterSpacing: 0.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          for (int i = 0; i < labels.length; i++)
            _NavTile(
              icon: i == selectedIndex ? selectedIcons[i] : icons[i],
              label: labels[i],
              selected: i == selectedIndex,
              onTap: () => onSelected(i),
            ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text('v1.0.0', style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: selected ? cs.secondaryContainer : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                ),
                const SizedBox(width: 14),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                    color: selected ? cs.onSecondaryContainer : cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
