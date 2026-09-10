import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell_state.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text('Settings'),
      content: SizedBox(
        width: 320,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: Theme.of(context).textTheme.labelLarge),
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
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Done'),
        ),
      ],
    );
  }
}
