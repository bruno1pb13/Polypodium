import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';

import '../l10n/l10n.dart';

/// Opens [imagePath] in a fullscreen viewer with zoom, save-to-gallery and
/// share actions. With [gallery] (which holds [imagePath]) the viewer swipes
/// between its images, starting at [imagePath].
Future<void> showFullscreenImageViewer(
  BuildContext context,
  String imagePath, {
  List<String>? gallery,
}) {
  final paths = gallery ?? [imagePath];
  final index = paths.indexOf(imagePath);
  return Navigator.of(context).push(
    PageRouteBuilder(
      opaque: false,
      barrierColor: Colors.black,
      pageBuilder: (_, __, ___) => FullscreenImageViewer(
        imagePaths: paths,
        initialIndex: index < 0 ? 0 : index,
      ),
      transitionsBuilder: (_, animation, __, child) =>
          FadeTransition(opacity: animation, child: child),
    ),
  );
}

class FullscreenImageViewer extends StatefulWidget {
  final List<String> imagePaths;
  final int initialIndex;

  const FullscreenImageViewer({
    super.key,
    required this.imagePaths,
    this.initialIndex = 0,
  });

  @override
  State<FullscreenImageViewer> createState() => _FullscreenImageViewerState();
}

class _FullscreenImageViewerState extends State<FullscreenImageViewer> {
  bool _saving = false;
  late int _index = widget.initialIndex;
  late final _pageController = PageController(initialPage: widget.initialIndex);

  String get _imagePath => widget.imagePaths[_index];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final hasAccess = await Gal.hasAccess(toAlbum: true) ||
          await Gal.requestAccess(toAlbum: true);
      if (!hasAccess) {
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.galleryPermissionDenied)),
        );
        return;
      }
      await Gal.putImage(_imagePath, album: 'Polypodium');
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.imageSavedToGallery)),
      );
    } on GalException catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.imageSaveError(e.type.message))),
      );
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.imageSaveError('$e'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _share() async {
    final box = context.findRenderObject() as RenderBox?;
    try {
      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(_imagePath)],
          sharePositionOrigin:
              box != null ? (box.localToGlobal(Offset.zero) & box.size) : null,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.shareError('$e'))),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: widget.imagePaths.length > 1
            ? Text(
                context.l10n.photoPosition(
                    _index + 1, widget.imagePaths.length),
                style: const TextStyle(color: Colors.white, fontSize: 16),
              )
            : null,
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: _saving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.download_outlined),
            tooltip: context.l10n.saveToGallery,
            onPressed: _saving ? null : _save,
          ),
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: context.l10n.share,
            onPressed: _share,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return PageView.builder(
            controller: _pageController,
            itemCount: widget.imagePaths.length,
            onPageChanged: (i) => setState(() => _index = i),
            itemBuilder: (context, i) => InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: SizedBox(
                width: constraints.maxWidth,
                height: constraints.maxHeight,
                child: Image.file(
                  File(widget.imagePaths[i]),
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Colors.white54,
                      size: 64,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
