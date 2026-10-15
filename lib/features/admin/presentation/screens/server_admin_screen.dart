import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/adaptive_layout.dart';
import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../workspaces/domain/workspace_model.dart';
import '../../domain/server_status.dart';
import '../../domain/server_user.dart';
import '../../domain/server_watering_settings.dart';
import '../providers/admin_providers.dart';

class ServerAdminScreen extends ConsumerWidget {
  const ServerAdminScreen({super.key, required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusAsync = ref.watch(serverStatusProvider(workspace));
    final usersAsync = ref.watch(serverUsersNotifierProvider(workspace));

    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.serverAdministration)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(serverStatusProvider(workspace));
          ref.invalidate(serverDataSettingsNotifierProvider(workspace));
          ref.invalidate(serverWeatherStatusProvider(workspace));
          ref.invalidate(serverWateringSettingsNotifierProvider(workspace));
          ref.invalidate(serverUsersNotifierProvider(workspace));
        },
        child: ReadableListView(
          children: [
            _StatusCard(statusAsync: statusAsync),
            _DataSettingsCard(workspace: workspace),
            _WeatherCard(workspace: workspace),
            _WateringCard(workspace: workspace),
            _McpCard(workspace: workspace),
            const Divider(height: 1),
            usersAsync.when(
              data: (users) => Column(
                children: [
                  for (final user in users)
                    _UserTile(
                      user: user,
                      isSelf: user.email == workspace.userEmail,
                      onSetRole: (role) => _confirmAndRun(
                        context,
                        title: role == 'admin'
                            ? context.l10n.promoteToAdminTitle
                            : context.l10n.demoteToMemberTitle,
                        message: role == 'admin'
                            ? context.l10n.promoteToAdminBody(user.email)
                            : context.l10n.demoteToMemberBody(user.email),
                        confirmLabel: role == 'admin'
                            ? context.l10n.promote
                            : context.l10n.demote,
                        destructive: role != 'admin',
                        action: () => ref
                            .read(serverUsersNotifierProvider(workspace).notifier)
                            .setRole(user.id, role),
                      ),
                      onSetDisabled: (disabled) => _confirmAndRun(
                        context,
                        title: disabled
                            ? context.l10n.disableAccountTitle
                            : context.l10n.enableAccountTitle,
                        message: disabled
                            ? context.l10n.disableAccountBody(user.email)
                            : context.l10n.enableAccountBody(user.email),
                        confirmLabel: disabled
                            ? context.l10n.disable
                            : context.l10n.enable,
                        destructive: disabled,
                        action: () => ref
                            .read(serverUsersNotifierProvider(workspace).notifier)
                            .setDisabled(user.id, disabled),
                      ),
                    ),
                ],
              ),
              loading: () => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(context.l10n
                    .errorLoadingUsers(localizedErrorMessage(e, context.l10n))),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addUser(context, ref),
        icon: const Icon(Icons.person_add_outlined),
        label: Text(context.l10n.addUser),
      ),
    );
  }

  Future<void> _confirmAndRun(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required bool destructive,
    required Future<void> Function() action,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              confirmLabel,
              style: destructive
                  ? TextStyle(color: Theme.of(ctx).colorScheme.error)
                  : null,
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await action();
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    }
  }

  Future<void> _addUser(BuildContext context, WidgetRef ref) async {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ctx.l10n.addUser),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: ctx.l10n.emailLabel),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: ctx.l10n.passwordLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(ctx.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(ctx.l10n.create),
          ),
        ],
      ),
    );
    final email = emailController.text.trim();
    final password = passwordController.text;
    emailController.dispose();
    passwordController.dispose();

    if (created != true || email.isEmpty || password.isEmpty) return;
    try {
      await ref
          .read(serverUsersNotifierProvider(workspace).notifier)
          .createUser(email, password);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    }
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.statusAsync});

  final AsyncValue<ServerStatus> statusAsync;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statusAsync.when(
          data: (status) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(context.l10n.serverCardTitle,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(context.l10n
                  .serverUptime(_formatUptime(status.uptimeSeconds))),
              Text(context.l10n.serverVersion(status.version)),
              Text(context.l10n.serverUsers('${status.userCount}')),
              if (status.updateAvailable && status.latestVersion != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.warning_amber_rounded,
                        size: 18, color: Theme.of(context).colorScheme.error),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        context.l10n
                            .serverUpdateAvailable(status.latestVersion!),
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Text(context.l10n.errorLoadingStatus('$e')),
        ),
      ),
    );
  }

  String _formatUptime(int seconds) {
    final d = Duration(seconds: seconds);
    final days = d.inDays;
    final hours = d.inHours % 24;
    final minutes = d.inMinutes % 60;
    if (days > 0) return '${days}d ${hours}h ${minutes}m';
    if (hours > 0) return '${hours}h ${minutes}m';
    return '${minutes}m';
  }
}

class _DataSettingsCard extends ConsumerWidget {
  const _DataSettingsCard({required this.workspace});

  final Workspace workspace;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync =
        ref.watch(serverDataSettingsNotifierProvider(workspace));

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: settingsAsync.when(
          data: (settings) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(context.l10n.memberPermissions,
                    style: Theme.of(context).textTheme.titleMedium),
              ),
              SwitchListTile(
                title: Text(context.l10n.exportData),
                subtitle: Text(context.l10n.memberExportSubtitle),
                value: settings.allowMemberExport,
                onChanged: (value) => _update(
                    context,
                    ref
                        .read(serverDataSettingsNotifierProvider(workspace)
                            .notifier)
                        .setAllowMemberExport(value)),
              ),
              SwitchListTile(
                title: Text(context.l10n.importData),
                subtitle: Text(context.l10n.memberImportSubtitle),
                value: settings.allowMemberImport,
                onChanged: (value) => _update(
                    context,
                    ref
                        .read(serverDataSettingsNotifierProvider(workspace)
                            .notifier)
                        .setAllowMemberImport(value)),
              ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (e, _) => Padding(
            padding: const EdgeInsets.all(16),
            child: Text(context.l10n.errorLoadingPermissions('$e')),
          ),
        ),
      ),
    );
  }

  Future<void> _update(BuildContext context, Future<void> action) async {
    try {
      await action;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    }
  }
}

/// Server-side weather forecasts. Hidden on servers that predate the
/// feature (their settings carry no `weatherEnabled`).
class _WeatherCard extends ConsumerStatefulWidget {
  const _WeatherCard({required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<_WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends ConsumerState<_WeatherCard> {
  bool _busy = false;

  Workspace get _workspace => widget.workspace;

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(serverDataSettingsNotifierProvider(_workspace)).value;
    if (settings == null || !settings.supportsWeather) {
      return const SizedBox.shrink();
    }
    final enabled = settings.weatherEnabled!;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(context.l10n.weatherForecastTitle,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            SwitchListTile(
              title: Text(context.l10n.weatherFetchForLocations),
              subtitle: Text(context.l10n.weatherFetchSubtitle),
              value: enabled,
              onChanged: _busy
                  ? null
                  : (value) => _run(() => ref
                      .read(serverDataSettingsNotifierProvider(_workspace)
                          .notifier)
                      .setWeatherEnabled(value)),
            ),
            if (enabled) _buildStatus(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatus(BuildContext context) {
    final statusAsync = ref.watch(serverWeatherStatusProvider(_workspace));
    return ListTile(
      leading: const Icon(Icons.cloud_outlined),
      title: statusAsync.when(
        data: (status) => Text(context.l10n.weatherRegions(status.regionCount)),
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text(localizedErrorMessage(e, context.l10n)),
      ),
      subtitle: statusAsync.whenOrNull(data: (status) {
        final last = status.lastFetchedAt;
        final lines = [
          last == null
              ? context.l10n.weatherNeverFetched
              : context.l10n.weatherLastFetched(DateFormat.yMd(
                      Localizations.localeOf(context).toString())
                  .add_Hm()
                  .format(last)),
          if (status.failingRegionCount > 0)
            context.l10n.weatherFailingRegions(status.failingRegionCount),
        ];
        return Text(lines.join('\n'));
      }),
      trailing: IconButton(
        icon: _busy
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2))
            : const Icon(Icons.refresh),
        tooltip: context.l10n.weatherRefreshNow,
        onPressed: _busy
            ? null
            : () => _run(() async {
                  await ref.read(adminClientProvider).refreshWeather(
                        serverUrl: _workspace.serverUrl!,
                        token: _workspace.token!,
                      );
                  ref.invalidate(serverWeatherStatusProvider(_workspace));
                }),
      ),
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// The rules that postpone or bring forward watering with the weather.
/// Shown while weather is on, and hidden on servers that predate them.
class _WateringCard extends ConsumerStatefulWidget {
  const _WateringCard({required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<_WateringCard> createState() => _WateringCardState();
}

class _WateringCardState extends ConsumerState<_WateringCard> {
  bool _busy = false;

  /// Slider positions while dragging, before they are saved.
  final _dragging = <WateringRule, double>{};

  ServerWateringSettingsNotifier get _notifier => ref.read(
      serverWateringSettingsNotifierProvider(widget.workspace).notifier);

  @override
  Widget build(BuildContext context) {
    final weatherOn = ref
        .watch(serverDataSettingsNotifierProvider(widget.workspace))
        .value
        ?.weatherEnabled;
    final settings =
        ref.watch(serverWateringSettingsNotifierProvider(widget.workspace)).value;
    if (weatherOn != true || settings == null) return const SizedBox.shrink();
    final l10n = context.l10n;

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(l10n.wateringRulesTitle,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            SwitchListTile(
              title: Text(l10n.wateringRulesEnable),
              subtitle: Text(l10n.wateringRulesEnableSubtitle),
              value: settings.enabled,
              onChanged:
                  _busy ? null : (v) => _run(() => _notifier.setEnabled(v)),
            ),
            if (settings.enabled) ...[
              for (final rule in WateringRule.values)
                if (settings.limits[rule] != null)
                  _ruleTile(context, settings, rule),
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextButton.icon(
                    icon: const Icon(Icons.restart_alt),
                    label: Text(l10n.wateringRulesReset),
                    onPressed: _busy || settings.isDefault
                        ? null
                        : () => _run(_notifier.resetRules),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _ruleTile(
      BuildContext context, ServerWateringSettings settings, WateringRule rule) {
    final l10n = context.l10n;
    final limits = settings.limits[rule]!;
    final step = _step(rule);
    final divisions = ((limits.max - limits.min) / step).round();
    final value =
        (_dragging[rule] ?? settings.value(rule)).clamp(limits.min, limits.max);
    final (title, hint) = switch (rule) {
      WateringRule.minRainMm => (
          l10n.wateringRuleMinRain,
          l10n.wateringRuleMinRainHint
        ),
      WateringRule.rainEfficiency => (
          l10n.wateringRuleRainEfficiency,
          l10n.wateringRuleRainEfficiencyHint
        ),
      WateringRule.maxPostponeDays => (
          l10n.wateringRuleMaxPostpone,
          l10n.wateringRuleMaxPostponeHint
        ),
      WateringRule.maxAdvanceDays => (
          l10n.wateringRuleMaxAdvance,
          l10n.wateringRuleMaxAdvanceHint
        ),
      WateringRule.minDemand => (
          l10n.wateringRuleMinDemand,
          l10n.wateringRuleMinDemandHint
        ),
      WateringRule.maxDemand => (
          l10n.wateringRuleMaxDemand,
          l10n.wateringRuleMaxDemandHint
        ),
    };
    final fallback = settings.defaults[rule];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                  child: Text(title,
                      style: Theme.of(context).textTheme.bodyLarge)),
              Text(_format(context, rule, value),
                  style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          Text(
            [
              hint,
              if (fallback != null)
                l10n.wateringRuleDefault(_format(context, rule, fallback)),
            ].join(' · '),
            style: Theme.of(context).textTheme.bodySmall,
          ),
          Slider(
            value: value,
            min: limits.min,
            max: limits.max,
            divisions: divisions > 0 ? divisions : null,
            label: _format(context, rule, value),
            onChanged: _busy
                ? null
                : (v) => setState(() => _dragging[rule] = v),
            onChangeEnd: _busy
                ? null
                : (v) => _run(() async {
                      try {
                        if (v != settings.value(rule)) {
                          await _notifier.setRule(rule, _snap(rule, v));
                        }
                      } finally {
                        _dragging.remove(rule);
                      }
                    }),
          ),
        ],
      ),
    );
  }

  static double _step(WateringRule rule) => switch (rule) {
        WateringRule.minRainMm => 0.5,
        WateringRule.rainEfficiency || WateringRule.minDemand => 0.05,
        WateringRule.maxDemand => 0.1,
        WateringRule.maxPostponeDays || WateringRule.maxAdvanceDays => 1,
      };

  /// Rounds a slider position to its step, without float noise.
  static double _snap(WateringRule rule, double value) {
    final step = _step(rule);
    return double.parse(((value / step).round() * step).toStringAsFixed(2));
  }

  static String _format(BuildContext context, WateringRule rule, double value) {
    final locale = context.l10n.localeName;
    return switch (rule) {
      WateringRule.minRainMm => context.l10n.wateringRuleMm(
          NumberFormat.decimalPatternDigits(locale: locale, decimalDigits: 1)
              .format(value)),
      WateringRule.maxPostponeDays ||
      WateringRule.maxAdvanceDays =>
        context.l10n.wateringRuleDays(value.round()),
      _ => NumberFormat.percentPattern(locale).format(value),
    };
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

/// Whether AI assistants may connect to the server's gardens over MCP.
/// Hidden on servers that predate the feature.
class _McpCard extends ConsumerStatefulWidget {
  const _McpCard({required this.workspace});

  final Workspace workspace;

  @override
  ConsumerState<_McpCard> createState() => _McpCardState();
}

class _McpCardState extends ConsumerState<_McpCard> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final settings =
        ref.watch(serverDataSettingsNotifierProvider(widget.workspace)).value;
    if (settings == null || !settings.supportsMcp) {
      return const SizedBox.shrink();
    }
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(context.l10n.mcpAccess,
                  style: Theme.of(context).textTheme.titleMedium),
            ),
            SwitchListTile(
              title: Text(context.l10n.mcpAllowOnServer),
              subtitle: Text(context.l10n.mcpAllowOnServerSubtitle),
              value: settings.mcpEnabled!,
              onChanged: _busy ? null : _set,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _set(bool value) async {
    setState(() => _busy = true);
    try {
      await ref
          .read(serverDataSettingsNotifierProvider(widget.workspace).notifier)
          .setMcpEnabled(value);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(localizedErrorMessage(e, context.l10n))));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isSelf,
    required this.onSetRole,
    required this.onSetDisabled,
  });

  final ServerUser user;
  final bool isSelf;
  final void Function(String role) onSetRole;
  final void Function(bool disabled) onSetDisabled;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(user.isAdmin
          ? Icons.admin_panel_settings_outlined
          : Icons.person_outline),
      title: Row(
        children: [
          Flexible(child: Text(user.email, overflow: TextOverflow.ellipsis)),
          if (isSelf) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(context.l10n.youChip),
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
      subtitle: Text([
        user.isAdmin ? context.l10n.roleAdmin : context.l10n.roleMember,
        if (user.disabled) context.l10n.accountDisabled,
      ].join(' · ')),
      trailing: PopupMenuButton<String>(
        onSelected: (action) {
          switch (action) {
            case 'promote':
              onSetRole('admin');
            case 'demote':
              onSetRole('member');
            case 'disable':
              onSetDisabled(true);
            case 'enable':
              onSetDisabled(false);
          }
        },
        itemBuilder: (context) => [
          if (!user.isAdmin)
            PopupMenuItem(
                value: 'promote', child: Text(context.l10n.promoteToAdmin)),
          if (user.isAdmin)
            PopupMenuItem(
                value: 'demote', child: Text(context.l10n.demoteToMember)),
          const PopupMenuDivider(),
          if (!user.disabled)
            PopupMenuItem(
                value: 'disable', child: Text(context.l10n.disableAccount)),
          if (user.disabled)
            PopupMenuItem(
                value: 'enable', child: Text(context.l10n.enableAccount)),
        ],
      ),
    );
  }
}
