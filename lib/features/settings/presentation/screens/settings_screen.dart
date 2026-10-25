import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/updates/update_controller.dart';
import '../../../../core/widgets/adaptive_layout.dart';
import '../../../weather/presentation/providers/weather_providers.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';
import '../providers/settings_providers.dart';
import '../widgets/settings_sections.dart';
import '../widgets/weather_settings.dart';

/// From this width on the categories sit in a column beside the selected
/// one's settings; below it they're a list leading to one page each.
const double kSettingsTwoColumnWidth = 760.0;

const double _categoryColumnWidth = 300.0;

enum SettingsCategory {
  reminders(Icons.notifications_outlined, Icons.notifications),
  weather(Icons.wb_cloudy_outlined, Icons.wb_cloudy),
  appearance(Icons.palette_outlined, Icons.palette),
  sync(Icons.cloud_sync_outlined, Icons.cloud_sync),
  data(Icons.import_export, Icons.import_export),
  about(Icons.info_outline, Icons.info);

  const SettingsCategory(this.icon, this.selectedIcon);

  final IconData icon;
  final IconData selectedIcon;

  String title(BuildContext context) => switch (this) {
        reminders => context.l10n.settingsReminders,
        weather => context.l10n.localWeatherTitle,
        appearance => context.l10n.settingsAppearance,
        sync => context.l10n.settingsSync,
        data => context.l10n.settingsData,
        about => context.l10n.settingsAbout,
      };

  Widget content() => switch (this) {
        reminders => const RemindersSettings(),
        weather => const WeatherSettings(),
        appearance => const AppearanceSettings(),
        sync => const SyncSettings(),
        data => const DataSettings(),
        about => const AboutSettings(),
      };
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  /// The category open beside the list in the two-column layout.
  SettingsCategory _selected = SettingsCategory.reminders;

  void _openPage(SettingsCategory category) => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SettingsCategoryPage(category: category)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.navSettings)),
      body: LayoutBuilder(builder: (context, constraints) {
        if (constraints.maxWidth < kSettingsTwoColumnWidth) {
          return ReadableListView(
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              for (final category in SettingsCategory.values)
                _CategoryTile(
                  category: category,
                  onTap: () => _openPage(category),
                ),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: _categoryColumnWidth,
              child: ListView(
                padding: const EdgeInsets.all(8),
                children: [
                  for (final category in SettingsCategory.values)
                    _CategoryTile(
                      category: category,
                      selected: category == _selected,
                      onTap: () => setState(() => _selected = category),
                    ),
                ],
              ),
            ),
            const VerticalDivider(width: 1),
            Expanded(
              child: ReadableListView(
                key: ValueKey(_selected),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  _CategoryHeader(title: _selected.title(context)),
                  _selected.content(),
                ],
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// One category on a page of its own, opened from the narrow layout.
class SettingsCategoryPage extends StatelessWidget {
  const SettingsCategoryPage({super.key, required this.category});

  final SettingsCategory category;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(category.title(context))),
      body: ReadableListView(
        padding: const EdgeInsets.only(top: 8, bottom: 24),
        children: [category.content()],
      ),
    );
  }
}

/// A category in the list or the column, with a line summing up its state.
class _CategoryTile extends ConsumerWidget {
  const _CategoryTile({
    required this.category,
    required this.onTap,
    this.selected,
  });

  final SettingsCategory category;
  final VoidCallback onTap;

  /// Null in the narrow list, where tiles lead to a page instead.
  final bool? selected;

  String _summary(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    switch (category) {
      case SettingsCategory.reminders:
        return ref.watch(notificationsEnabledNotifierProvider)
            ? l10n.settingsRemindersOn(
                ref.watch(notificationTimeNotifierProvider).format(context))
            : l10n.settingsRemindersOff;
      case SettingsCategory.weather:
        if (ref.watch(activeWorkspaceProvider).type != WorkspaceType.local) {
          return l10n.settingsWeatherServer;
        }
        return ref.watch(localWeatherEnabledNotifierProvider)
            ? l10n.settingsWeatherOn
            : l10n.settingsWeatherOff;
      case SettingsCategory.appearance:
        return l10n.settingsAppearanceSummary(
            switch (ref.watch(themeModeNotifierProvider)) {
          'light' => l10n.themeLight,
          'dark' => l10n.themeDark,
          _ => l10n.themeAuto,
        });
      case SettingsCategory.sync:
        return ref.watch(activeWorkspaceProvider).name;
      case SettingsCategory.data:
        return l10n.settingsDataSummary;
      case SettingsCategory.about:
        final version = ref.watch(appVersionProvider).value;
        return version == null
            ? l10n.settingsAboutSummaryNoVersion
            : l10n.settingsAboutSummary(version);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelected = selected ?? false;
    final tile = ListTile(
      key: ValueKey('settings-category-${category.name}'),
      leading: Icon(isSelected ? category.selectedIcon : category.icon),
      title: Text(category.title(context)),
      subtitle: Text(_summary(context, ref)),
      trailing: selected == null ? const Icon(Icons.chevron_right) : null,
      selected: isSelected,
      onTap: onTap,
    );
    if (selected == null) return tile;
    final scheme = Theme.of(context).colorScheme;
    return ListTileTheme.merge(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      selectedTileColor: scheme.secondaryContainer,
      selectedColor: scheme.onSecondaryContainer,
      child: tile,
    );
  }
}

class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title, style: Theme.of(context).textTheme.titleLarge),
    );
  }
}
