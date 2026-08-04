import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/enums.dart';
import '../../../../core/l10n/l10n.dart';
import '../../../../core/storage/photo_storage.dart';
import '../../../../core/storage/photo_storage_provider.dart';
import '../../domain/defensivo_model.dart';
import '../providers/defensivos_providers.dart';

class AddEditDefensivoScreen extends ConsumerStatefulWidget {
  final DefensivoModel? defensivo;

  const AddEditDefensivoScreen({super.key, this.defensivo});

  @override
  ConsumerState<AddEditDefensivoScreen> createState() =>
      _AddEditDefensivoScreenState();
}

class _AddEditDefensivoScreenState
    extends ConsumerState<AddEditDefensivoScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _compositionCtrl;
  late final TextEditingController _carenciaCtrl;
  late final TextEditingController _customCategoryCtrl;
  DefensivoCategory? _category;
  String? _imagePath;
  bool _saving = false;
  bool _submitted = false;
  late final PhotoStorage _photoStorage;

  bool get _isEditing => widget.defensivo != null;

  @override
  void initState() {
    super.initState();
    _photoStorage = ref.read(photoStorageProvider);
    _nameCtrl = TextEditingController(text: widget.defensivo?.name ?? '');
    _compositionCtrl =
        TextEditingController(text: widget.defensivo?.composition ?? '');
    _carenciaCtrl = TextEditingController(
        text: widget.defensivo?.carenciaDays?.toString() ?? '');
    _customCategoryCtrl = TextEditingController(
        text: widget.defensivo?.customCategoryLabel ?? '');
    _category = widget.defensivo?.category;
    _imagePath = widget.defensivo?.imagePath;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _compositionCtrl.dispose();
    _carenciaCtrl.dispose();
    _customCategoryCtrl.dispose();
    if (!_submitted &&
        _imagePath != null &&
        _imagePath != widget.defensivo?.imagePath) {
      _photoStorage.deletePhoto(_imagePath!);
    }
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image == null) return;
    final oldPath = _imagePath;
    final savedPath = await _photoStorage.savePhoto(File(image.path));
    setState(() => _imagePath = savedPath);
    if (oldPath != null) await _photoStorage.deletePhoto(oldPath);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      final defensivo = DefensivoModel(
        id: widget.defensivo?.id ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        category: _category,
        customCategoryLabel: _category == DefensivoCategory.custom
            ? (_customCategoryCtrl.text.trim().isEmpty
                ? null
                : _customCategoryCtrl.text.trim())
            : null,
        composition: _compositionCtrl.text.trim().isEmpty
            ? null
            : _compositionCtrl.text.trim(),
        carenciaDays: int.tryParse(_carenciaCtrl.text.trim()),
        imagePath: _imagePath,
        createdAt: widget.defensivo?.createdAt ?? DateTime.now(),
      );

      await ref.read(defensivosNotifierProvider.notifier).save(defensivo);
      _submitted = true;
      if (mounted) Navigator.pop(context, defensivo);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          _isEditing ? context.l10n.editDefensivo : context.l10n.newDefensivo,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
          ),
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.3),
                  ],
                ),
              ),
            ),
          ),
          SafeArea(
            child: Theme(
              data: _darkFormTheme(context),
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + bottomInset),
                  children: [
                    _GlassCard(
                      child: Column(
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                width: 160,
                                height: 160,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                      color:
                                          Colors.white.withValues(alpha: 0.2)),
                                  image: _imagePath != null
                                      ? DecorationImage(
                                          image: FileImage(File(_imagePath!)),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: _imagePath == null
                                    ? const Icon(Icons.add_a_photo_outlined,
                                        size: 48, color: Colors.white70)
                                    : null,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            context.l10n.tapToChangeImage,
                            style: const TextStyle(
                                fontSize: 12, color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionTitle(context.l10n.sectionInformation),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _nameCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: '${context.l10n.defensivoNameLabel} *',
                              hintText: context.l10n.defensivoNameHint,
                              prefixIcon: const Icon(Icons.science_outlined),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? context.l10n.nameRequired
                                : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            context.l10n.defensivoCategoryLabel,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: DefensivoCategory.values.map((c) {
                              final selected = _category == c;
                              return ChoiceChip(
                                label: Text(c.label(context.l10n)),
                                selected: selected,
                                onSelected: (_) => setState(
                                    () => _category = selected ? null : c),
                                backgroundColor:
                                    Colors.black.withValues(alpha: 0.2),
                                selectedColor:
                                    Theme.of(context).colorScheme.primary,
                                showCheckmark: false,
                                labelStyle: TextStyle(
                                  color:
                                      selected ? Colors.white : Colors.white70,
                                  fontSize: 13,
                                  fontWeight: selected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  side: BorderSide(
                                    color: selected
                                        ? Colors.white.withValues(alpha: 0.3)
                                        : Colors.white12,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          if (_category == DefensivoCategory.custom) ...[
                            const SizedBox(height: 16),
                            TextFormField(
                              controller: _customCategoryCtrl,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                labelText:
                                    context.l10n.defensivoCustomCategoryLabel,
                                hintText:
                                    context.l10n.defensivoCustomCategoryHint,
                                prefixIcon: const Icon(Icons.label_outline),
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _compositionCtrl,
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              labelText: context.l10n.defensivoCompositionLabel,
                              hintText: context.l10n.defensivoCompositionHint,
                              prefixIcon: const Icon(Icons.layers_outlined),
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _carenciaCtrl,
                            style: const TextStyle(color: Colors.white),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: InputDecoration(
                              labelText: context.l10n.defensivoCarenciaLabel,
                              hintText: context.l10n.defensivoCarenciaHint,
                              suffixText: context.l10n.daysSuffix,
                              prefixIcon: const Icon(Icons.event_repeat),
                            ),
                          ),
                        ],
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
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                _isEditing
                                    ? context.l10n.saveChanges
                                    : context.l10n.createDefensivo,
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
            ),
          ),
        ],
      ),
    );
  }
}

ThemeData _darkFormTheme(BuildContext context) {
  final base = Theme.of(context);
  final primary = base.colorScheme.primary;
  OutlineInputBorder border([Color color = Colors.white24]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: color),
      );

  return base.copyWith(
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.05),
      labelStyle: const TextStyle(color: Colors.white70),
      floatingLabelStyle: TextStyle(color: primary),
      hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.4)),
      helperStyle: const TextStyle(color: Colors.white60),
      prefixIconColor: Colors.white70,
      suffixIconColor: Colors.white70,
      iconColor: Colors.white70,
      border: border(),
      enabledBorder: border(),
      focusedBorder: border(primary),
      errorBorder: border(base.colorScheme.error),
      focusedErrorBorder: border(base.colorScheme.error),
      errorStyle: TextStyle(color: base.colorScheme.error),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: primary,
      selectionColor: primary.withValues(alpha: 0.4),
      selectionHandleColor: primary,
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  final String text;

  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _GlassCard extends StatelessWidget {
  final Widget child;

  const _GlassCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
          ),
          child: child,
        ),
      ),
    );
  }
}
