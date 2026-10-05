import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/l10n/l10n.dart';
import '../../domain/plant_photos.dart';

/// Two photos of a plant compared, the older one as "before": side by side,
/// or overlaid with a divider dragged across them.
class PhotoComparisonScreen extends StatefulWidget {
  final PlantPhoto before;
  final PlantPhoto after;

  PhotoComparisonScreen(
      {super.key, required PlantPhoto a, required PlantPhoto b})
      : before = a.entry.date.isAfter(b.entry.date) ? b : a,
        after = a.entry.date.isAfter(b.entry.date) ? a : b;

  @override
  State<PhotoComparisonScreen> createState() => _PhotoComparisonScreenState();
}

class _PhotoComparisonScreenState extends State<PhotoComparisonScreen> {
  bool _slider = false;

  /// Share of the width showing the "before" photo in slider mode.
  double _split = 0.5;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = DateFormat.yMd(l10n.localeName);
    final beforeLabel =
        l10n.comparisonBefore(format.format(widget.before.entry.date));
    final afterLabel =
        l10n.comparisonAfter(format.format(widget.after.entry.date));

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(l10n.comparisonTitle),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SegmentedButton<bool>(
                style: SegmentedButton.styleFrom(
                  foregroundColor: Colors.white,
                  selectedForegroundColor: Colors.black,
                  selectedBackgroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                ),
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.view_column_outlined),
                    label: Text(l10n.comparisonSideBySide),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.compare),
                    label: Text(l10n.comparisonSlider),
                  ),
                ],
                selected: {_slider},
                onSelectionChanged: (s) => setState(() => _slider = s.single),
              ),
            ),
            Expanded(
              child: _slider
                  ? _buildSlider(beforeLabel, afterLabel)
                  : _buildSideBySide(beforeLabel, afterLabel),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSideBySide(String beforeLabel, String afterLabel) {
    Widget side(PlantPhoto photo, String label) => Expanded(
          child: Column(
            children: [
              Expanded(child: _photo(photo, label, BoxFit.contain)),
              const SizedBox(height: 8),
              _DateLabel(label),
            ],
          ),
        );

    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 16),
      child: Row(
        children: [
          side(widget.before, beforeLabel),
          const SizedBox(width: 8),
          side(widget.after, afterLabel),
        ],
      ),
    );
  }

  Widget _buildSlider(String beforeLabel, String afterLabel) {
    return LayoutBuilder(builder: (context, constraints) {
      final width = constraints.maxWidth;
      final x = width * _split;

      void moveTo(double dx) =>
          setState(() => _split = (dx / width).clamp(0.0, 1.0));

      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragUpdate: (d) => moveTo(d.localPosition.dx),
        onTapDown: (d) => moveTo(d.localPosition.dx),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _photo(widget.after, afterLabel, BoxFit.cover),
            ClipRect(
              clipper: _LeftClipper(x),
              child: _photo(widget.before, beforeLabel, BoxFit.cover),
            ),
            Positioned(
              left: x - 1,
              top: 0,
              bottom: 0,
              child: Container(width: 2, color: Colors.white),
            ),
            Positioned(
              left: (x - 24).clamp(0.0, width - 48),
              top: constraints.maxHeight / 2 - 24,
              child: Semantics(
                slider: true,
                label: context.l10n.comparisonDivider,
                value: '${(_split * 100).round()}%',
                increasedValue:
                    '${((_split + 0.1).clamp(0.0, 1.0) * 100).round()}%',
                decreasedValue:
                    '${((_split - 0.1).clamp(0.0, 1.0) * 100).round()}%',
                onIncrease: () =>
                    setState(() => _split = (_split + 0.1).clamp(0.0, 1.0)),
                onDecrease: () =>
                    setState(() => _split = (_split - 0.1).clamp(0.0, 1.0)),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.compare_arrows, color: Colors.black),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 12,
              child: _DateLabel(beforeLabel, boxed: true),
            ),
            Positioned(
              right: 12,
              top: 12,
              child: _DateLabel(afterLabel, boxed: true),
            ),
          ],
        ),
      );
    });
  }

  Widget _photo(PlantPhoto photo, String label, BoxFit fit) => Image.file(
        File(photo.photo.path),
        fit: fit,
        semanticLabel: label,
        errorBuilder: (_, __, ___) => Semantics(
          image: true,
          label: label,
          child: const Center(
            child: Icon(Icons.broken_image_outlined,
                color: Colors.white54, size: 64),
          ),
        ),
      );
}

class _DateLabel extends StatelessWidget {
  final String text;
  final bool boxed;

  const _DateLabel(this.text, {this.boxed = false});

  @override
  Widget build(BuildContext context) {
    final label = ExcludeSemantics(
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
    if (!boxed) return label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: label,
    );
  }
}

/// Keeps the part of the child left of [x].
class _LeftClipper extends CustomClipper<Rect> {
  final double x;

  const _LeftClipper(this.x);

  @override
  Rect getClip(Size size) => Rect.fromLTWH(0, 0, x, size.height);

  @override
  bool shouldReclip(_LeftClipper oldClipper) => oldClipper.x != x;
}
