import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/widgets/emoji_text.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../entries/presentation/screens/add_entry_screen.dart';
import '../../../plants/domain/plant_model.dart';
import '../../../plants/presentation/widgets/plant_status.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../domain/reminder_model.dart';
import '../providers/reminders_providers.dart';
import '../../../../core/theme/glass_colors.dart';

/// Glass card on the plant detail screen listing the plant's recurring care
/// reminders, with their next due date, and letting the user add, edit,
/// pause or delete them. Also lists the pesticide reapplication set on the
/// latest pesticide entry, which is managed from the diary instead.
class PlantRemindersCard extends ConsumerWidget {
  final PlantModel plant;

  const PlantRemindersCard({super.key, required this.plant});

  String get plantId => plant.id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transparent = ref.watch(transparencyEnabledNotifierProvider);
    final statuses = ref.watch(plantRemindersProvider(plantId)).value;
    if (statuses == null) return const SizedBox.shrink();
    final pesticide = _PesticideReminder.of(plant);

    final l10n = context.l10n;
    final usedTypes = {for (final s in statuses) s.reminder.entryType};
    final freeTypes =
        reminderEntryTypes.where((t) => !usedTypes.contains(t)).toList();
    final secondary = transparent ? context.glass.fgSubtle : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: transparent
              ? ImageFilter.blur(sigmaX: 10, sigmaY: 10)
              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
            decoration: BoxDecoration(
              color: transparent
                  ? context.glass.scrim(0.3)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: transparent
                    ? context.glass.tint(0.1)
                    : Colors.transparent,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.notifications_active_outlined,
                        size: 20, color: secondary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.remindersSectionTitle,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: transparent ? context.glass.fg : null,
                        ),
                      ),
                    ),
                    if (freeTypes.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.add,
                            color: transparent ? context.glass.fg : null),
                        tooltip: l10n.addReminder,
                        onPressed: () => showDialog<void>(
                          context: context,
                          builder: (_) => ReminderDialog(
                              plantId: plantId, availableTypes: freeTypes),
                        ),
                      ),
                  ],
                ),
                if (statuses.isEmpty && pesticide == null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(32, 0, 8, 8),
                    child: Text(
                      l10n.remindersEmpty,
                      style: TextStyle(fontSize: 13, color: secondary),
                    ),
                  ),
                if (pesticide != null)
                  _ReminderRow(
                    entryType: EntryType.pesticide,
                    intervalDays: pesticide.intervalDays,
                    lastDoneAt: pesticide.lastAppliedAt,
                    dueDate: pesticide.dueDate,
                    enabled: true,
                    transparent: transparent,
                    onTap: () => _showPesticideInfo(context),
                  ),
                for (final status in statuses)
                  _ReminderRow(
                    entryType: status.reminder.entryType,
                    intervalDays: status.reminder.intervalDays,
                    lastDoneAt: status.lastDoneAt,
                    dueDate: status.dueDate,
                    enabled: status.reminder.enabled,
                    transparent: transparent,
                    onTap: () => showDialog<void>(
                      context: context,
                      builder: (_) => ReminderDialog(
                        plantId: plantId,
                        availableTypes: [status.reminder.entryType],
                        existing: status.reminder,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// The pesticide reminder is derived from the latest pesticide entry, so
  /// there is nothing to edit here: explain where it comes from and offer to
  /// record a new application.
  Future<void> _showPesticideInfo(BuildContext context) async {
    final l10n = context.l10n;
    final record = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pesticideReminderInfoTitle),
        content: Text(l10n.pesticideReminderInfoBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).closeButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pesticideReminderRecord),
          ),
        ],
      ),
    );
    if (record != true || !context.mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEntryScreen(
            plantId: plantId, initialType: EntryType.pesticide),
      ),
    );
  }
}

/// The plant's pending pesticide reapplication, as set on its latest
/// pesticide entry (see PlantsRepository.refreshPesticideStatus).
class _PesticideReminder {
  final int intervalDays;
  final DateTime lastAppliedAt;

  const _PesticideReminder(this.intervalDays, this.lastAppliedAt);

  static _PesticideReminder? of(PlantModel plant) {
    final days = plant.pesticideReapplicationDays;
    final last = plant.lastPesticideAppliedAt;
    if (days == null || last == null) return null;
    return _PesticideReminder(days, last);
  }

  /// Same calendar-day math as [ReminderStatus.dueDate] and the agenda.
  DateTime get dueDate {
    final anchor = lastAppliedAt.toLocal();
    return DateTime(anchor.year, anchor.month, anchor.day + intervalDays);
  }
}

class _ReminderRow extends StatelessWidget {
  final EntryType entryType;
  final int intervalDays;
  final DateTime? lastDoneAt;
  final DateTime dueDate;
  final bool enabled;
  final bool transparent;
  final VoidCallback onTap;

  const _ReminderRow({
    required this.entryType,
    required this.intervalDays,
    required this.lastDoneAt,
    required this.dueDate,
    required this.enabled,
    required this.transparent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final dateFormat = DateFormat.Md(l10n.localeName);
    final lastDone = lastDoneAt;
    final subtitle = [
      l10n.reminderEvery(intervalDays),
      lastDone == null
          ? l10n.reminderNeverDone
          : l10n.reminderLastDone(dateFormat.format(lastDone)),
    ].join(' · ');

    final days = calendarDaysBetween(dueDate);
    final chip = !enabled
        ? PlantStatusChip(label: l10n.reminderPaused, tone: StatusTone.neutral)
        : days > 0
            ? PlantStatusChip(
                label: l10n.reminderOverdue(days), tone: StatusTone.danger)
            : days == 0
                ? PlantStatusChip(
                    label: l10n.dueToday, tone: StatusTone.warning)
                : PlantStatusChip(
                    label: l10n
                        .reminderNextDate(dateFormat.format(dueDate)),
                    tone: StatusTone.positive,
                  );

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            // The type label next to it already names it.
            SizedBox(
              width: 20,
              child: ExcludeSemantics(
                child: Text(
                  entryType.emoji,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entryType.label(l10n),
                    style: TextStyle(
                      color: transparent ? context.glass.fg : null,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: transparent ? context.glass.fgMuted : null,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.4,
              ),
              child: chip,
            ),
          ],
        ),
      ),
    );
  }
}

/// Creates a reminder (choosing among [availableTypes]) or, with
/// [existing], edits its interval/enabled state or deletes it.
class ReminderDialog extends ConsumerStatefulWidget {
  final String plantId;
  final List<EntryType> availableTypes;
  final ReminderModel? existing;

  const ReminderDialog({
    super.key,
    required this.plantId,
    required this.availableTypes,
    this.existing,
  });

  @override
  ConsumerState<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends ConsumerState<ReminderDialog> {
  final _formKey = GlobalKey<FormState>();
  late EntryType _type;
  late bool _enabled;
  late final TextEditingController _interval;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _type = existing?.entryType ?? widget.availableTypes.first;
    _enabled = existing?.enabled ?? true;
    _interval = TextEditingController(
        text: existing == null ? '' : '${existing.intervalDays}');
  }

  @override
  void dispose() {
    _interval.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final days = int.parse(_interval.text.trim());
    final existing = widget.existing;
    final reminder = existing != null
        ? existing.copyWith(intervalDays: days, enabled: _enabled)
        : ReminderModel(
            id: const Uuid().v4(),
            plantId: widget.plantId,
            entryType: _type,
            intervalDays: days,
            enabled: _enabled,
            createdAt: DateTime.now(),
          );
    final mutations = ref.read(reminderMutationsProvider);
    Navigator.pop(context);
    await mutations.save(reminder);
  }

  Future<void> _delete() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteReminderTitle),
        content: Text(l10n.deleteReminderBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final mutations = ref.read(reminderMutationsProvider);
    Navigator.pop(context);
    await mutations.delete(widget.existing!.id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(_isEditing ? l10n.editReminder : l10n.addReminder),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<EntryType>(
              initialValue: _type,
              decoration: InputDecoration(labelText: l10n.reminderTypeLabel),
              items: [
                for (final type in widget.availableTypes)
                  DropdownMenuItem(
                    value: type,
                    child: EmojiText(type.emoji, type.label(l10n),
                        separator: '  '),
                  ),
              ],
              onChanged: _isEditing
                  ? null
                  : (type) => setState(() => _type = type ?? _type),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _interval,
              autofocus: !_isEditing,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration:
                  InputDecoration(labelText: l10n.reminderIntervalLabel),
              validator: (value) {
                final days = int.tryParse(value?.trim() ?? '');
                return days == null ||
                        days < 1 ||
                        days > maxReminderIntervalDays
                    ? l10n.reminderIntervalInvalid
                    : null;
              },
            ),
            const SizedBox(height: 4),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.reminderEnabledLabel),
              value: _enabled,
              onChanged: (value) => setState(() => _enabled = value),
            ),
          ],
        ),
      ),
      actions: [
        if (_isEditing)
          TextButton(
            onPressed: _delete,
            child: Text(l10n.delete,
                style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(onPressed: _save, child: Text(l10n.save)),
      ],
    );
  }
}
