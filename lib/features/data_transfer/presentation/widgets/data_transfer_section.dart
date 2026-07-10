import 'dart:io';

import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../data/data_export_service.dart';
import '../../data/data_import_service.dart';
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
      if (permissionAsync.isLoading) return 'Verificando permissão...';
      if (permissionAsync.hasError) {
        return 'Não foi possível verificar a permissão com o servidor.';
      }
      if (!allowed) return deniedReason ?? 'Não permitido.';
      return normal;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          leading: const Icon(Icons.upload_file_outlined),
          title: const Text('Exportar dados'),
          subtitle: Text(subtitleFor(
              canExport, 'Gera um arquivo .zip com os dados e fotos')),
          enabled: canExport && !_busy,
          onTap: () => _run(_export),
        ),
        ListTile(
          leading: const Icon(Icons.file_download_outlined),
          title: const Text('Importar dados'),
          subtitle: Text(subtitleFor(
              canImport, 'Mescla um backup exportado com os dados atuais')),
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
          SnackBar(content: Text('Dados exportados para ${location.path}')),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao exportar: $e')),
      );
    }
  }

  Future<void> _import() async {
    final messenger = ScaffoldMessenger.of(context);
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
          title: const Text('Importar dados?'),
          content: Text(
            'Os dados de "${p.basename(file.path)}" serão mesclados aos '
            'dados deste workspace. Itens editados mais recentemente no '
            'aplicativo são mantidos.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Importar'),
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
            'Importação concluída: ${summary.applied} item(ns) aplicados'
            '${summary.skipped > 0 ? ', ${summary.skipped} ignorados por serem mais antigos' : ''}.',
          ),
        ),
      );
    } on InvalidBackupException catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erro ao importar: $e')),
      );
    }
  }
}
