import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/class_schedule/presentation/class_schedule_module.dart';
import '../../features/note_plus/presentation/note_plus_module.dart';
import '../../features/spending/presentation/spending_module.dart';
import '../../features/tasks/presentation/tasks_module.dart';
import '../../features/tasks/providers/task_providers.dart';
import '../../features/spending/providers/spending_providers.dart';
import '../theme/app_density.dart';
import 'desktop_dashboard.dart';
import 'settings_dialog.dart';
import 'shell_state.dart';

class DashboardShell extends ConsumerWidget {
  const DashboardShell({super.key});

  static const desktopBreakpoint = AppDensity.desktopBreakpoint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(selectedModuleProvider);
    ref.watch(taskNotificationSyncProvider);
    ref.watch(spendingProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final desktop = constraints.maxWidth >= desktopBreakpoint;
        final denseMobile = AppDensity.isMobile(context);
        final scaffold = Scaffold(
          appBar: desktop
              ? null
              : AppBar(
                  titleSpacing: denseMobile ? 8 : 10,
                  title: Row(
                    children: [
                      Icon(
                        Icons.space_dashboard_rounded,
                        size: denseMobile ? 18 : 20,
                        color: theme.colorScheme.primary,
                      ),
                      SizedBox(width: denseMobile ? 5 : 8),
                      Flexible(
                        child: Text(
                          'Personal space',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: denseMobile
                              ? theme.textTheme.titleMedium
                              : null,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    IconButton(
                      tooltip: 'Settings',
                      icon: Icon(
                        Icons.settings_outlined,
                        size: denseMobile ? 19 : 21,
                      ),
                      onPressed: () => showDialog<void>(
                        context: context,
                        builder: (_) => const SettingsDialog(),
                      ),
                    ),
                    SizedBox(width: denseMobile ? 2 : 4),
                  ],
                ),
          body: SafeArea(
            child: desktop
                ? const DesktopDashboard()
                : selected == DashboardModule.schedule
                ? const ClassScheduleModule()
                : selected == DashboardModule.tasks
                ? const TasksModule()
                : selected == DashboardModule.notePlus
                ? const NotePlusModule()
                : const SpendingModule(),
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
                      icon: _TightNavIcon(Icons.calendar_month_outlined),
                      selectedIcon: _TightNavIcon(Icons.calendar_month_rounded),
                      label: 'Schedule',
                    ),
                    NavigationDestination(
                      icon: _TightNavIcon(Icons.checklist_outlined),
                      selectedIcon: _TightNavIcon(Icons.checklist_rounded),
                      label: 'Tasks',
                    ),
                    NavigationDestination(
                      icon: _TightNavIcon(Icons.note_alt_outlined),
                      selectedIcon: _TightNavIcon(Icons.note_alt_rounded),
                      label: 'Note+',
                    ),
                    NavigationDestination(
                      icon: _TightNavIcon(
                        Icons.account_balance_wallet_outlined,
                      ),
                      selectedIcon: _TightNavIcon(
                        Icons.account_balance_wallet_rounded,
                      ),
                      label: 'Spending',
                    ),
                  ],
                ),
        );
        return scaffold;
      },
    );
  }
}

class _TightNavIcon extends StatelessWidget {
  const _TightNavIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) =>
      Transform.translate(offset: const Offset(0, 2), child: Icon(icon));
}
