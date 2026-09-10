import 'package:flutter/material.dart';

import '../../../shared/widgets/module_placeholder.dart';

/// Replace this presentation entry point when the schedule module is built.
class ClassSchedulePlaceholder extends StatelessWidget {
  const ClassSchedulePlaceholder({this.desktop = false, super.key});

  final bool desktop;

  @override
  Widget build(BuildContext context) {
    return ModulePlaceholder(
      desktop: desktop,
      title: 'Class Schedule',
      subtitle: 'Make room for learning',
      headline: 'Your week, a little clearer.',
      description:
          'A home for your classes, campus stops, and the time in between. '
          'Your schedule will take shape here.',
      icon: Icons.calendar_month_rounded,
      color: Color(0xFF6B59A5),
      previewLabels: ['Today & week', 'Classes & locations'],
    );
  }
}
