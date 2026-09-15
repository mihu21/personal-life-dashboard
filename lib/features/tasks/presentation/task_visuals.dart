import 'package:flutter/material.dart';
import '../domain/task_types.dart';

/// Color identifies category; the number of bars identifies priority.
class TaskPriorityMark extends StatelessWidget {
  const TaskPriorityMark({
    required this.priority,
    required this.color,
    required this.category,
    super.key,
  });
  final TaskPriority priority;
  final Color color;
  final String category;
  @override
  Widget build(BuildContext context) => Tooltip(
    message: '$category · ${priority.label} priority',
    child: Semantics(
      label: '$category · ${priority.label} priority',
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 3 - priority.index; i++)
            Container(
              width: 3,
              height: 18,
              margin: const EdgeInsets.only(right: 2),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    ),
  );
}
