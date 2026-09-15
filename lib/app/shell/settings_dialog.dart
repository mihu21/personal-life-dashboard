import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/class_schedule/providers/academic_providers.dart';
import 'shell_state.dart';

class SettingsDialog extends ConsumerStatefulWidget {
  const SettingsDialog({super.key});

  @override
  ConsumerState<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends ConsumerState<SettingsDialog> {
  bool _backupBusy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 360,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Theme', style: theme.textTheme.labelLarge),
              const SizedBox(height: 8),
              DropdownButton<ThemeMode>(
                isExpanded: true,
                value: ref.watch(themeModeProvider),
                onChanged: (mode) {
                  if (mode != null) {
                    ref.read(themeModeProvider.notifier).select(mode);
                  }
                },
                items: [
                  for (final mode in ThemeMode.values)
                    DropdownMenuItem(
                      value: mode,
                      child: Text(switch (mode) {
                        ThemeMode.system => 'System theme',
                        ThemeMode.light => 'Light theme',
                        ThemeMode.dark => 'Dark theme',
                      }),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text('Backup & restore', style: theme.textTheme.labelLarge),
              const SizedBox(height: 4),
              Text(
                'Move your semesters, courses, schedule records, and one-time '
                'events between devices without cloud sync. Downloaded NTHU '
                'catalog data is not included.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _backupBusy ? null : _exportBackup,
                      icon: const Icon(Icons.file_upload_outlined),
                      label: const Text('Export backup'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: _backupBusy ? null : _importBackup,
                      icon: const Icon(Icons.file_download_outlined),
                      label: const Text('Import backup'),
                    ),
                  ),
                ],
              ),
              if (_backupBusy) ...[
                const SizedBox(height: 12),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _backupBusy ? null : () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }

  Future<void> _exportBackup() async {
    setState(() => _backupBusy = true);
    try {
      final backup = await ref.read(localBackupServiceProvider).createBackup();
      final now = DateTime.now();
      final date =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      final output = await FilePicker.saveFile(
        dialogTitle: 'Export Personal Life Dashboard backup',
        fileName: 'personal_life_dashboard_backup_$date.zip',
        bytes: backup.bytes,
        mimeType: 'application/zip',
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (output == null || !mounted) return;
      _showMessage(
        'Backup exported: ${backup.summary.courses} courses, '
        '${backup.summary.semesters} semesters, '
        '${backup.summary.oneTimeEvents} one-time events.',
      );
    } catch (error) {
      if (mounted) _showMessage('Could not export backup: $error', error: true);
    } finally {
      if (mounted) setState(() => _backupBusy = false);
    }
  }

  Future<void> _importBackup() async {
    try {
      final file = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: const ['zip'],
      );
      if (file == null || !mounted) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace local data?'),
          content: Text(
            'Importing ${file.name} will replace this device’s semesters, '
            'courses, academic records, and one-time events. Your downloaded '
            'NTHU catalog cache will be kept.\n\nThis cannot be undone unless '
            'you export a backup of this device first.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Import and replace'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;

      setState(() => _backupBusy = true);
      final bytes = await file.readAsBytes();
      final summary = await ref
          .read(localBackupServiceProvider)
          .restoreBackup(bytes);

      ref.invalidate(academicSnapshotProvider);
      ref.invalidate(oneTimeEventsProvider);

      if (!mounted) return;
      _showMessage(
        'Backup imported: ${summary.courses} courses, '
        '${summary.semesters} semesters, '
        '${summary.oneTimeEvents} one-time events.',
      );
    } on FormatException catch (error) {
      if (mounted) _showMessage(error.message, error: true);
    } catch (error) {
      if (mounted) _showMessage('Could not import backup: $error', error: true);
    } finally {
      if (mounted && _backupBusy) setState(() => _backupBusy = false);
    }
  }

  void _showMessage(String message, {bool error = false}) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger?.showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
