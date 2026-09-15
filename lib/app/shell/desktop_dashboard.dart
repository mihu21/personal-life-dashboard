import 'package:flutter/material.dart';

import '../../features/class_schedule/presentation/class_schedule_card.dart';
import '../../features/shopping/presentation/shopping_placeholder.dart';
import '../../features/spending/presentation/spending_placeholder.dart';
import '../../features/tasks/presentation/tasks_module.dart';
import 'settings_dialog.dart';

/// Viewport-bound desktop composition. Each feature receives a bounded panel.
class DesktopDashboard extends StatelessWidget {
  const DesktopDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _TodaySummary(),
          const SizedBox(height: 8),
          Expanded(
            child: Column(
              spacing: 8,
              children: [
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: const [
                      Expanded(child: ClassScheduleCard()),
                      Expanded(child: TasksDashboardCard()),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
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
      constraints: const BoxConstraints(minHeight: 34),
      padding: const EdgeInsets.only(left: 10, right: 2),
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
          const SizedBox(width: 6),
          Text('Today', style: theme.textTheme.labelLarge),
          const SizedBox(width: 10),
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
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Settings',
            icon: const Icon(Icons.settings_outlined, size: 20),
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints.tightFor(width: 30, height: 30),
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
