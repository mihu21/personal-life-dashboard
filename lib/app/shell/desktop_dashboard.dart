import 'package:flutter/material.dart';

import '../../features/class_schedule/presentation/class_schedule_placeholder.dart';
import '../../features/shopping/presentation/shopping_placeholder.dart';
import '../../features/spending/presentation/spending_placeholder.dart';
import '../../features/tasks/presentation/tasks_placeholder.dart';
import 'settings_dialog.dart';

/// Viewport-bound desktop composition. Each feature receives a bounded panel.
class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TodaySummary(),
          const SizedBox(height: 12),
          Expanded(
            child: Column(
              spacing: 12,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: const [
                      Expanded(child: ClassSchedulePlaceholder(desktop: true)),
                      Expanded(child: TasksPlaceholder(desktop: true)),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 12,
                    children: const [
                      Expanded(child: ShoppingPlaceholder(desktop: true)),
                      Expanded(child: SpendingPlaceholder(desktop: true)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TodaySummary extends StatelessWidget {
  const _TodaySummary();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey('today-summary'),
      height: 40,
      padding: const EdgeInsets.only(left: 14, right: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(
            Icons.wb_sunny_outlined,
            size: 18,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Text('Today', style: theme.textTheme.labelLarge),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Daily summary coming soon',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 20),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => showDialog<void>(
              context: context,
              builder: (context) => const SettingsDialog(),
            ),
          ),
        ],
      ),
    );
  }
}
