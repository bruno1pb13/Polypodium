import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/photo_picker.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../domain/entry_model.dart';
import '../providers/entries_providers.dart';
import '../widgets/entry_forms/entry_form_widgets.dart';
import '../widgets/entry_forms/entry_note_section.dart';
import '../widgets/entry_forms/entry_photo_section.dart';

/// Edits the note and photos of an existing entry. Its type and data stay
/// as recorded: they drive plant status, reminders and moves done when the
/// entry was created.
class EditEntryScreen extends ConsumerStatefulWidget {
  final EntryModel entry;

  const EditEntryScreen({super.key, required this.entry});

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late final _noteCtrl = TextEditingController(text: widget.entry.note);

  // The entry's photos as edited, in order: kept ones by their current
  // path, picked ones by their saved copy.
  late final List<String> _photoPaths = [
    for (final p in widget.entry.photos) p.path,
  ];

  // Saved copies of the photos picked here, deleted unless saved.
  final Set<String> _newPhotoPaths = {};

  bool _saving = false;
  bool _submitted = false;
  late final PhotoStorage _photoStorage;

  @override
  void initState() {
    super.initState();
    _photoStorage = ref.read(photoStorageProvider);
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    if (!_submitted) {
      for (final path in _newPhotoPaths) {
        _photoStorage.deletePhoto(path);
      }
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final entry = widget.entry;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          context.l10n.editEntry,
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
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
              children: [
                EntryGlassCard(
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        entry.type.label(context.l10n),
                        style: TextStyle(
                          color: context.glass.fg,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        DateFormat.yMd(context.l10n.localeName)
                            .add_Hm()
                            .format(entry.date),
                        style: TextStyle(color: context.glass.fgMuted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                EntryGlassCard(
                  child:
                      EntryNoteSection(controller: _noteCtrl, type: entry.type),
                ),
                const SizedBox(height: 16),
                EntryGlassCard(
                  child: EntryPhotoSection(
                    photoPaths: _photoPaths,
                    onRemove: (i) {
                      final path = _photoPaths[i];
                      setState(() => _photoPaths.removeAt(i));
                      // A kept photo goes only once the edit is saved.
                      if (_newPhotoPaths.remove(path)) {
                        _photoStorage.deletePhoto(path);
                      }
                    },
                    onPick: _pickPhotos,
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  height: 56,
                  child: FilledButton(
                    onPressed: _saving ? null : _submit,
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _saving
                        ? SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: context.glass.fg,
                            ),
                          )
                        : Text(
                            context.l10n.saveChanges,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhotos(ImageSource source) async {
    final room = maxEntryPhotos - _photoPaths.length;
    if (room <= 0) return;
    final picked =
        await ref.read(photoPickerProvider).pick(source, limit: room);
    final saved = [
      for (final path in picked.take(room))
        await _photoStorage.savePhoto(File(path)),
    ];
    if (!mounted) {
      // The screen is gone, along with the chance to save them.
      for (final path in saved) {
        await _photoStorage.deletePhoto(path);
      }
      return;
    }
    setState(() {
      _photoPaths.addAll(saved);
      _newPhotoPaths.addAll(saved);
    });
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final note = _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim();
      await ref.read(entryMutationsProvider).edit(
            widget.entry.id,
            note: note,
            photoPaths: _photoPaths,
            newPhotoPaths: _newPhotoPaths,
          );
      _submitted = true;
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
