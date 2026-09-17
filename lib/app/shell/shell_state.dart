import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum DashboardModule { schedule, tasks, notePlus, spending }

// Only transient shell preferences live here. Feature state belongs to features.
final selectedModuleProvider =
    NotifierProvider<SelectedModule, DashboardModule>(SelectedModule.new);

class SelectedModule extends Notifier<DashboardModule> {
  @override
  DashboardModule build() => DashboardModule.schedule;

  void select(DashboardModule module) => state = module;
}

final themeModeProvider = NotifierProvider<AppThemeMode, ThemeMode>(
  AppThemeMode.new,
);

class AppThemeMode extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void select(ThemeMode mode) => state = mode;
}
