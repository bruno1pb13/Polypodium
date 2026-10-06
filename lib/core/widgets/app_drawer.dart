import 'dart:ui';
import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import '../../features/agenda/presentation/screens/agenda_screen.dart';
import '../../features/agenda/presentation/widgets/agenda_badge.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/plants/presentation/screens/home_screen.dart';
import '../../features/species/presentation/screens/species_list_screen.dart';
import '../../features/locations/presentation/screens/locations_list_screen.dart';
import '../../features/soils/presentation/screens/soils_list_screen.dart';
import '../../features/defensivos/presentation/screens/defensivos_list_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/workspaces/presentation/widgets/workspace_selector.dart';
import '../theme/glass_colors.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: ClipRect(
        child: Stack(
          children: [
            // Background image (same as app screens)
            Positioned.fill(
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                excludeFromSemantics: true,
              ),
            ),
            // Blur + dark overlay — glassmorphism
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  color: context.glass.scrim(0.55),
                ),
              ),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SafeArea(
                  bottom: false,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: context.glass.tint(0.12),
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 52,
                          height: 52,
                          excludeFromSemantics: true,
                        ),
                        const SizedBox(width: 14),
                        Text(
                          'Polypodium',
                          style: TextStyle(
                            fontFamily: 'CormorantGaramond',
                            fontWeight: FontWeight.w600,
                            fontSize: 26,
                            letterSpacing: 0.5,
                            color: context.glass.fg,
                            shadows: [
                              Shadow(
                                color: context.glass.shadow(Colors.black45),
                                blurRadius: 4,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: WorkspaceSelector(dark: true),
                ),
                _DrawerItem(
                  icon: Icons.home_outlined,
                  label: context.l10n.navHome,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                          builder: (_) => const DashboardScreen()),
                      (route) => false,
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.local_florist_outlined,
                  label: context.l10n.navMyPlants,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.event_note_outlined,
                  label: context.l10n.navAgenda,
                  trailing: const AgendaBadge(),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AgendaScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.eco_outlined,
                  label: context.l10n.navSpecies,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SpeciesListScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.location_on_outlined,
                  label: context.l10n.navLocations,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LocationsListScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.terrain_outlined,
                  label: context.l10n.navSoils,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SoilsListScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.science_outlined,
                  label: context.l10n.navDefensivos,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const DefensivosListScreen()),
                    );
                  },
                ),
                _DrawerItem(
                  icon: Icons.settings_outlined,
                  label: context.l10n.navSettings,
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsScreen()),
                    );
                  },
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text(
                    'v1.0.0',
                    style: TextStyle(
                      color: context.glass.fgAlpha(0.35),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          splashColor: context.glass.tint(0.08),
          highlightColor: context.glass.tint(0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                Icon(icon, color: context.glass.fgMuted, size: 22),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: context.glass.fg,
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                if (trailing != null) trailing!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
