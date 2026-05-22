import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../entries/domain/entry_model.dart';
import '../../../entries/presentation/providers/entries_providers.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  final String plantId;

  const AddEntryScreen({super.key, required this.plantId});

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  final _noteCtrl = TextEditingController();
  EntryType _type = EntryType.observation;
  String? _photoPath;
  bool _saving = false;

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo registro')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Tipo', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: EntryType.values.map((t) {
              final selected = t == _type;
              return ChoiceChip(
                label: Text('${t.emoji} ${t.label}'),
                selected: selected,
                onSelected: (_) => setState(() => _type = t),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _noteCtrl,
            decoration: const InputDecoration(
              labelText: 'Observação',
              hintText: 'Notas opcionais...',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Text('Foto', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 8),
          if (_photoPath != null) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                File(_photoPath!),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            TextButton.icon(
              onPressed: () => setState(() => _photoPath = null),
              icon: const Icon(Icons.close),
              label: const Text('Remover foto'),
            ),
          ] else
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.camera),
                  icon: const Icon(Icons.photo_camera_outlined),
                  label: const Text('Câmera'),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: () => _pickPhoto(ImageSource.gallery),
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galeria'),
                ),
              ],
            ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Salvar registro'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picker = ImagePicker();
    final xFile = await picker.pickImage(source: source, imageQuality: 85);
    if (xFile == null) return;

    // Save photo via PhotoStorage and store the final path
    final savedPath = await ref
        .read(photoStorageProvider)
        .savePhoto(File(xFile.path));
    setState(() => _photoPath = savedPath);
  }

  Future<void> _submit() async {
    setState(() => _saving = true);
    try {
      final entry = EntryModel(
        id: const Uuid().v4(),
        plantId: widget.plantId,
        date: DateTime.now(),
        photoPath: _photoPath,
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        type: _type,
        createdAt: DateTime.now(),
      );
      await ref
          .read(entriesNotifierProvider(widget.plantId).notifier)
          .create(entry);
      if (mounted) Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}
