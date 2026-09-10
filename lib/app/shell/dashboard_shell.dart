import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/class_schedule/presentation/class_schedule_placeholder.dart';
import '../../features/shopping/presentation/shopping_placeholder.dart';
import '../../features/spending/presentation/spending_placeholder.dart';
import '../../features/tasks/presentation/tasks_placeholder.dart';
import 'shell_state.dart';
import 'desktop_dashboard.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static const desktopBreakpoint = 900.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(selectedModuleProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= desktopBreakpoint;
        return Scaffold(
          appBar: desktop
              ? null
              : AppBar(
                  title: Row(
                    children: [
                      Icon(
                        Icons.space_dashboard_rounded,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      const Flexible(child: Text('Personal space')),
                    ],
                  ),
                  actions: [
                    PopupMenuButton<ThemeMode>(
                      tooltip: 'Choose theme',
                      initialValue: ref.watch(themeModeProvider),
                      onSelected: ref.read(themeModeProvider.notifier).select,
                      icon: const Icon(Icons.brightness_6_outlined),
                      itemBuilder: (context) => [
                        for (final mode in ThemeMode.values)
                          CheckedPopupMenuItem(
                            value: mode,
                            checked: ref.read(themeModeProvider) == mode,
                            child: Text(switch (mode) {
                              ThemeMode.system => 'System theme',
                              ThemeMode.light => 'Light theme',
                              ThemeMode.dark => 'Dark theme',
                            }),
                          ),
                      ],
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
          body: SafeArea(
            child: desktop
                ? const DesktopDashboard()
                : SingleChildScrollView(
                    key: PageStorageKey(selected.name),
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 1240),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _pageTitle(selected),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                                letterSpacing: -.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'A space for the things that matter.',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _page(selected),
                          ],
                        ),
                      ),
                    ),
                  ),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: selected.index,
                  onDestinationSelected: (index) => ref
                      .read(selectedModuleProvider.notifier)
                      .select(DashboardModule.values[index]),
                  destinations: const [
                    NavigationDestination(
                      icon: Icon(Icons.calendar_month_outlined),
                      selectedIcon: Icon(Icons.calendar_month_rounded),
                      label: 'Schedule',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.checklist_outlined),
                      selectedIcon: Icon(Icons.checklist_rounded),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.shopping_bag_outlined),
                      selectedIcon: Icon(Icons.shopping_bag_rounded),
                      label: 'Shopping',
                    ),
                    NavigationDestination(
                      icon: Icon(Icons.account_balance_wallet_outlined),
                      selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                      label: 'Spending',
                    ),
                  ],
                ),
        );
      },
    );
  }

  static String _pageTitle(DashboardModule module) => switch (module) {
    DashboardModule.schedule => 'Make time for learning.',
    DashboardModule.tasks => 'One thing at a time.',
    DashboardModule.shopping => 'For your next trip.',
    DashboardModule.spending => 'See the everyday clearly.',
  };

  static Widget _page(DashboardModule module) => switch (module) {
    DashboardModule.schedule => const ClassSchedulePlaceholder(),
    DashboardModule.tasks => const TasksPlaceholder(),
    DashboardModule.shopping => const ShoppingPlaceholder(),
    DashboardModule.spending => const SpendingPlaceholder(),
  };
}
