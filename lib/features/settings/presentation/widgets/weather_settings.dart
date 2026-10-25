import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/links/external_links.dart';
import '../../../admin/domain/server_watering_settings.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../weather/domain/local_watering_rules.dart';
import '../../../weather/presentation/providers/weather_providers.dart';
import '../../../weather/presentation/widgets/watering_rule_slider.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../../workspaces/presentation/providers/workspace_providers.dart';

/// The weather analysis: in the local workspace this device fetches the
/// forecast itself, so the user turns it on (after being told what leaves
/// the device) and tunes its rules here. A workspace with a server only
/// explains that the server does it.
class WeatherSettings extends ConsumerWidget {
  const WeatherSettings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLocal =
        ref.watch(activeWorkspaceProvider).type == WorkspaceType.local;
    return isLocal ? const _LocalWeatherSettings() : const _ServerWeatherInfo();
  }
}

/// Asks before turning the local weather on, spelling out what is sent to
/// Open-Meteo. True when the user agrees.
Future<bool> confirmLocalWeather(BuildContext context) async {
  final l10n = context.l10n;
  final agreed = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.privacy_tip_outlined),
      title: Text(l10n.weatherEnableDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.weatherThirdPartyBody),
            const SizedBox(height: 12),
            Text(l10n.weatherEnableDialogFooter),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(l10n.weatherEnableConfirm),
        ),
      ],
    ),
  );
  return agreed ?? false;
}

class _LocalWeatherSettings extends ConsumerWidget {
  const _LocalWeatherSettings();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final enabled = ref.watch(localWeatherEnabledNotifierProvider);
    final notifier = ref.read(localWeatherEnabledNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          title: Text(l10n.weatherAnalysisTitle),
          subtitle: Text(l10n.weatherAnalysisSubtitle),
          secondary: const Icon(Icons.wb_cloudy_outlined),
          value: enabled,
          onChanged: (value) async {
            if (value && !await confirmLocalWeather(context)) return;
            await notifier.setEnabled(value);
          },
        ),
        _ThirdPartyNotice(enabled: enabled),
        if (enabled) ...[
          const _LocalWeatherStatus(),
          const Divider(height: 32),
          const _LocalRules(),
        ],
      ],
    );
  }
}

/// What leaves the device and to whom, shown whether the analysis is on
/// or off so the choice is an informed one.
class _ThirdPartyNotice extends StatelessWidget {
  const _ThirdPartyNotice({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Card(
      key: const ValueKey('weather-third-party-notice'),
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: scheme.secondaryContainer,
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.privacy_tip_outlined,
                    color: scheme.onSecondaryContainer),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.weatherThirdPartyTitle,
                      style: text.titleSmall
                          ?.copyWith(color: scheme.onSecondaryContainer)),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              enabled
                  ? l10n.weatherThirdPartyBody
                  : '${l10n.weatherThirdPartyBody} ${l10n.weatherThirdPartyOff}',
              style:
                  text.bodyMedium?.copyWith(color: scheme.onSecondaryContainer),
            ),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                    foregroundColor: scheme.onSecondaryContainer),
                onPressed: () => openExternalLink(
                    context, ExternalLinks.privacyPolicy(l10n.localeName)),
                icon: const Icon(Icons.open_in_new, size: 18),
                label: Text(l10n.privacyPolicy),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// When the forecast was last fetched, or why there is none yet.
class _LocalWeatherStatus extends ConsumerWidget {
  const _LocalWeatherStatus();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locations = ref.watch(locationsNotifierProvider).value;
    final regions = ref.watch(localWeatherRegionsProvider).value;
    if (locations == null || regions == null) return const SizedBox.shrink();

    final hasCoordinates =
        locations.any((l) => l.latitude != null && l.longitude != null);
    final fetched = [
      for (final r in regions)
        if (r.fetchedAt case final at?) at,
    ]..sort();
    final failed = regions.any((r) => r.lastError != null);

    final (IconData icon, String message) = !hasCoordinates
        ? (Icons.location_off_outlined, l10n.weatherStatusNoCoordinates)
        : fetched.isNotEmpty
            ? (
                Icons.update,
                [
                  l10n.weatherStatusUpdated(
                      DateFormat.yMd(l10n.localeName)
                          .add_Hm()
                          .format(fetched.last)),
                  if (failed) l10n.weatherStatusFailed,
                ].join('\n'),
              )
            : failed
                ? (Icons.cloud_off_outlined, l10n.weatherStatusFailed)
                : (Icons.hourglass_empty, l10n.weatherStatusPending);

    return ListTile(
      key: const ValueKey('weather-status'),
      leading: Icon(icon),
      title: Text(message),
    );
  }
}

/// The local watering rules, one slider each.
class _LocalRules extends ConsumerWidget {
  const _LocalRules();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final rules = ref.watch(localWateringRulesNotifierProvider);
    final notifier = ref.read(localWateringRulesNotifierProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          child: Text(l10n.weatherRulesSection,
              style: Theme.of(context).textTheme.titleMedium),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
          child: Text(l10n.weatherRulesSectionHint,
              style: Theme.of(context).textTheme.bodySmall),
        ),
        for (final rule in WateringRule.values)
          WateringRuleSlider(
            rule: rule,
            value: rules.value(rule),
            min: LocalWateringRules.limits[rule]!.min,
            max: LocalWateringRules.limits[rule]!.max,
            defaultValue: LocalWateringRules.defaultOf(rule),
            onChanged: (v) => notifier.setRule(rule, v),
          ),
        Align(
          alignment: AlignmentDirectional.centerEnd,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextButton.icon(
              icon: const Icon(Icons.restart_alt),
              label: Text(l10n.wateringRulesReset),
              onPressed: rules.isDefault ? null : notifier.reset,
            ),
          ),
        ),
      ],
    );
  }
}

/// A workspace with a server: the device computes nothing, the server's
/// admin decides.
class _ServerWeatherInfo extends ConsumerWidget {
  const _ServerWeatherInfo();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final serverOn = ref.watch(serverWeatherEnabledProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.dns_outlined),
          title: Text(l10n.weatherRemoteTitle),
          subtitle: Text(l10n.weatherRemoteBody),
        ),
        if (serverOn.value case final on?)
          ListTile(
            leading: Icon(on ? Icons.wb_cloudy_outlined : Icons.cloud_off),
            title: Text(on ? l10n.weatherRemoteOn : l10n.weatherRemoteOff),
          ),
      ],
    );
  }
}
