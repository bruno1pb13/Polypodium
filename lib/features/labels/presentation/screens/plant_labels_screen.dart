import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/glass_colors.dart';
import '../../../locations/presentation/providers/locations_providers.dart';
import '../../../plants/presentation/providers/plants_providers.dart';
import '../../../species/presentation/providers/species_providers.dart';
import '../../data/label_pdf_builder.dart';
import '../../data/label_pdf_output.dart';
import '../../domain/plant_label.dart';
import '../widgets/plant_label_preview.dart';

/// Prints or exports QR code labels for [plantIds], in that order.
class PlantLabelsScreen extends ConsumerStatefulWidget {
  const PlantLabelsScreen({super.key, required this.plantIds});

  final List<String> plantIds;

  @override
  ConsumerState<PlantLabelsScreen> createState() => _PlantLabelsScreenState();
}

class _PlantLabelsScreenState extends ConsumerState<PlantLabelsScreen> {
  var _options = const LabelOptions();
  bool _busy = false;

  static const _fileName = 'polypodium-labels.pdf';

  List<PlantLabel>? _labels() {
    final plants = ref.watch(plantsNotifierProvider).value;
    final species = ref.watch(speciesNotifierProvider).value;
    final locations = ref.watch(locationsNotifierProvider).value;
    if (plants == null || species == null || locations == null) return null;
    final plantsById = {for (final p in plants) p.id: p};
    final speciesById = {for (final s in species) s.id: s};
    final locationsById = {for (final l in locations) l.id: l};
    return [
      for (final id in widget.plantIds)
        if (plantsById[id] case final plant?)
          PlantLabel.of(
            plant,
            species: speciesById[plant.speciesId],
            location: locationsById[plant.locationId],
          ),
    ];
  }

  String Function(DateTime) _acquiredText(AppLocalizations l10n) {
    final format = DateFormat.yMd(l10n.localeName);
    return (date) => l10n.labelsAcquiredOn(format.format(date));
  }

  Future<void> _output(List<PlantLabel> labels,
      {required bool toPrinter}) async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final output = ref.read(labelPdfOutputProvider);
    final box = context.findRenderObject() as RenderBox?;
    setState(() => _busy = true);
    try {
      final bytes = await buildLabelsPdf(
        labels,
        options: _options,
        acquiredText: _acquiredText(l10n),
        title: l10n.labelsTitle(labels.length),
      );
      if (toPrinter) {
        await output.printPdf(bytes, name: _fileName);
      } else {
        final path = await output.export(
          bytes,
          fileName: _fileName,
          origin:
              box != null ? box.localToGlobal(Offset.zero) & box.size : null,
        );
        if (path != null) {
          messenger
              .showSnackBar(SnackBar(content: Text(l10n.labelsSavedTo(path))));
        }
      }
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.labelsError('$e'))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final labels = _labels();
    final savesToFile = ref.watch(labelPdfOutputProvider).savesToFile;
    final textStyle = TextStyle(color: context.glass.fg);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: context.glass.fg),
        title: Text(
          context.l10n.labelsTitle(labels?.length ?? widget.plantIds.length),
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
            child: labels == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      if (labels.isNotEmpty)
                        _GlassCard(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 420),
                              child: PlantLabelPreview(
                                label: labels.first,
                                options: _options,
                                acquiredText: _acquiredText(context.l10n),
                              ),
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      _GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTileTheme(
                          textColor: context.glass.fg,
                          iconColor: context.glass.fgMuted,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 0),
                                child: Text(
                                  context.l10n.labelsSheetLayout,
                                  style: textStyle.copyWith(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              RadioGroup<LabelSheetPreset>(
                                groupValue: _options.preset,
                                onChanged: (preset) => setState(() => _options =
                                    _options.copyWith(preset: preset)),
                                child: Column(
                                  children: [
                                    for (final preset
                                        in LabelSheetPreset.values)
                                      RadioListTile<LabelSheetPreset>(
                                        value: preset,
                                        title: Text(_presetName(preset)),
                                      ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  context.l10n.labelsPages(
                                      _options.preset.pagesFor(labels.length)),
                                  style: TextStyle(
                                      color: context.glass.fgMuted,
                                      fontSize: 13),
                                ),
                              ),
                              Divider(color: context.glass.divider),
                              SwitchListTile(
                                title: Text(context.l10n.labelsShowLocation),
                                secondary:
                                    const Icon(Icons.location_on_outlined),
                                value: _options.showLocation,
                                onChanged: (v) => setState(() => _options =
                                    _options.copyWith(showLocation: v)),
                              ),
                              SwitchListTile(
                                title: Text(
                                    context.l10n.labelsShowAcquisitionDate),
                                secondary: const Icon(Icons.event_outlined),
                                value: _options.showAcquisitionDate,
                                onChanged: (v) => setState(() => _options =
                                    _options.copyWith(showAcquisitionDate: v)),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        alignment: WrapAlignment.end,
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          OutlinedButton.icon(
                            onPressed: _busy || labels.isEmpty
                                ? null
                                : () => _output(labels, toPrinter: false),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: context.glass.fg,
                              side: BorderSide(color: context.glass.outline),
                              minimumSize: const Size(48, 48),
                            ),
                            icon: Icon(savesToFile
                                ? Icons.save_alt
                                : Icons.share_outlined),
                            label: Text(savesToFile
                                ? context.l10n.labelsSavePdf
                                : context.l10n.labelsSharePdf),
                          ),
                          FilledButton.icon(
                            onPressed: _busy || labels.isEmpty
                                ? null
                                : () => _output(labels, toPrinter: true),
                            style: FilledButton.styleFrom(
                                minimumSize: const Size(48, 48)),
                            icon: const Icon(Icons.print_outlined),
                            label: Text(context.l10n.labelsPrint),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  String _presetName(LabelSheetPreset preset) => switch (preset) {
        LabelSheetPreset.a4x24 => context.l10n.labelsPresetA4x24,
        LabelSheetPreset.a4x10 => context.l10n.labelsPresetA4x10,
      };
}

class _GlassCard extends StatelessWidget {
  const _GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: context.glass.scrim(0.3),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: context.glass.tint(0.1)),
          ),
          // Ink of the list tiles inside.
          child: Material(type: MaterialType.transparency, child: child),
        ),
      ),
    );
  }
}
