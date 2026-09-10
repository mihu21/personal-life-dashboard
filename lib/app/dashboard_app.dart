import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'shell/dashboard_shell.dart';
import 'shell/shell_state.dart';
import 'theme/app_theme.dart';

class DashboardApp extends ConsumerWidget {
  const DashboardApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Personal Life Dashboard',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ref.watch(themeModeProvider),
      home: const DashboardShell(),
    );
  }
}
