import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/tasks/providers/task_providers.dart';
import 'shell/dashboard_shell.dart';
import 'shell/shell_state.dart';
import 'theme/app_theme.dart';

class DashboardApp extends ConsumerStatefulWidget {
  const DashboardApp({super.key});

  @override
  ConsumerState<DashboardApp> createState() => _DashboardAppState();
}

class _DashboardAppState extends ConsumerState<DashboardApp> {
  late final AppLifecycleListener lifecycle;
  @override
  void initState() {
    super.initState();
    lifecycle = AppLifecycleListener(
      onResume: () => ref.invalidate(taskNotificationSyncProvider),
    );
  }

  @override
  void dispose() {
    lifecycle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Personal Life Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      builder: (context, child) => Theme(
        data: AppTheme.responsive(context, Theme.of(context)),
        child: child!,
      ),
      home: const DashboardShell(),
    );
  }
}
