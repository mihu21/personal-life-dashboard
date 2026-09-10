import 'package:flutter/material.dart';

import '../../../shared/widgets/module_placeholder.dart';

class TasksPlaceholder extends StatelessWidget {
  const TasksPlaceholder({this.desktop = false, super.key});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return ModulePlaceholder(
      desktop: desktop,
      title: 'Tasks & Reminders',
      subtitle: 'A little less on your mind',
      headline: 'Space for your next steps.',
      description:
          'From small to-dos to things you want to remember. '
          'A calmer way to keep track is on its way.',
      icon: Icons.checklist_rounded,
      color: Color(0xFF367A70),
      previewLabels: ['To-dos', 'Reminders'],
    );
  }
}
