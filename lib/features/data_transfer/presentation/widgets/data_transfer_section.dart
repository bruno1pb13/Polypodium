import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/l10n/error_messages.dart';
import '../../../../core/l10n/l10n.dart';
import '../../data/data_export_service.dart';
import '../../data/data_import_service.dart';
import '../../domain/data_transfer_permission.dart';
import '../providers/data_transfer_providers.dart';

/// The "Dados" block of the settings screen: export the active workspace to
/// a backup file and import (merge) a backup back in. Availability follows
/// the server's member permissions via dataTransferPermissionProvider.
class DataTransferSection extends ConsumerStatefulWidget {
  const DataTransferSection({super.key});

  @override
  ConsumerState<DataTransferSection> createState() =>
      _DataTransferSectionState();
}

class _DataTransferSectionState extends ConsumerState<DataTransferSection> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) {
    final permissionAsync = ref.watch(dataTransferPermissionProvider);
    final permission = permissionAsync.value;
    final canExport = permission?.canExport ?? false;
    final canImport = permission?.canImport ?? false;
    final deniedReason = permission?.deniedReason;

    String subtitleFor(bool allowed, String normal) {
      if (permissionAsync.isLoading) return context.l10n.checkingPermission;
      if (permissionAsync.hasError) {
        return context.l10n.permissionCheckFailed;
      }
      if (!allowed) {
        return switch (deniedReason) {
          DataTransferDeniedReason.notConnected =>
            context.l10n.connectToTransfer,
          DataTransferDeniedReason.disabledByAdmin =>
            context.l10n.disabledByAdmin,
          DataTransferDeniedReason.permissionUnverified =>
            context.l10n.permissionCheckFailed,
          null => context.l10n.notAllowed,
        };
      }
      return normal;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: Text(context.l10n.exportData),
          subtitle:
              Text(subtitleFor(canExport, context.l10n.exportDataSubtitle)),
          enabled: canExport && !_busy,
          onTap: () => _run(_export),
        ),
        ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: Text(context.l10n.importData),
          subtitle:
              Text(subtitleFor(canImport, context.l10n.importDataSubtitle)),
          enabled: canImport && !_busy,
          onTap: () => _run(_import),
        ),
      ],
    );
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _export() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    final box = context.findRenderObject() as RenderBox?;
    try {
      final bytes =
          await ref.read(dataExportServiceProvider).buildArchiveBytes();
      final fileName = DataExportService.suggestedFileName();

      if (Platform.isAndroid || Platform.isIOS) {
        final dir = await getTemporaryDirectory();
        final file = File(p.join(dir.path, fileName));
        await file.writeAsBytes(bytes);
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path, mimeType: 'application/zip')],
            sharePositionOrigin: box != null
                ? (box.localToGlobal(Offset.zero) & box.size)
                : null,
          ),
        );
      } else {
        final location = await getSaveLocation(
          suggestedName: fileName,
          acceptedTypeGroups: const [
            XTypeGroup(label: 'Backup Polypodium', extensions: ['zip']),
          ],
        );
        if (location == null) return;
        await File(location.path).writeAsBytes(bytes);
        messenger.showSnackBar(
          SnackBar(content: Text(l10n.dataExportedTo(location.path))),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.exportError('$e'))),
      );
    }
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
    final l10n = context.l10n;
    try {
      final file = await openFile(
        acceptedTypeGroups: const [
          XTypeGroup(
            label: 'Backup Polypodium',
            extensions: ['zip', 'json'],
            mimeTypes: ['application/zip', 'application/json'],
            uniformTypeIdentifiers: ['public.zip-archive', 'public.json'],
          ),
        ],
      );
      if (file == null || !mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(ctx.l10n.importDataTitle),
          content: Text(ctx.l10n.importDataBody(p.basename(file.path))),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(ctx.l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(ctx.l10n.importAction),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final bytes = await file.readAsBytes();
      final summary =
          await ref.read(dataImportServiceProvider).importFromBytes(bytes);
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            summary.skipped > 0
                ? l10n.importDoneWithSkipped(summary.applied, summary.skipped)
                : l10n.importDone(summary.applied),
          ),
        ),
      );
    } on InvalidBackupException catch (e) {
      final message = switch (e.kind) {
        InvalidBackupKind.corrupt => l10n.backupCorrupt,
        InvalidBackupKind.unrecognized => l10n.backupUnrecognized,
        InvalidBackupKind.notPolypodiumBackup => l10n.backupNotPolypodium,
        InvalidBackupKind.newerVersion => l10n.backupNewerVersion,
      };
      messenger.showSnackBar(SnackBar(content: Text(message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizedErrorMessage(e, l10n))),
      );
    }
  }
}
