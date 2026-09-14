import 'package:flutter/material.dart';

import '../domain/schedule_conflicts.dart';

Future<bool> confirmConflicts(
  BuildContext context,
  List<ScheduleConflict> conflicts,
) async {
  if (conflicts.isEmpty) return true;
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Schedule conflicts'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'These meetings overlap. You can revise the times or save them as they are.',
                  ),
                  for (final conflict in conflicts)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(conflict.description),
                    ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Review times'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save anyway'),
            ),
          ],
        ),
      ) ??
      false;
}
