import 'package:flutter/material.dart';

import '../domain/task_logic.dart';
import '../domain/task_types.dart';
import 'task_editor.dart';

class TaskFilterDialog extends StatefulWidget {
  const TaskFilterDialog({
    required this.filter,
    required this.categories,
    required this.courses,
    super.key,
  });

  final TaskFilter filter;
  final List<String> categories;
  final Map<String, String> courses;

  @override
  State<TaskFilterDialog> createState() => _TaskFilterDialogState();
}

class _TaskFilterDialogState extends State<TaskFilterDialog> {
  late Set<String> categories;
  late Set<TaskPriority> priorities;
  late Set<TaskStatus> statuses;
  late Set<TaskSource> sources;
  late Set<String> courseIds;
  late bool includeNoCourse;
  late DuePeriod due;
  DateTime? start, end;
  late bool overdue, noDeadline;

  @override
  void initState() {
    super.initState();
    read(widget.filter);
  }

  void read(TaskFilter f) {
    categories = {...f.categories};
    priorities = {...f.priorities};
    statuses = {...f.statuses};
    sources = {...f.sources};
    courseIds = f.courseIds.where(widget.courses.containsKey).toSet();
    includeNoCourse = f.includeNoCourse;
    due = f.duePeriod;
    start = f.start;
    end = f.end;
    overdue = f.includeOverdue;
    noDeadline = f.includeNoDeadline;
  }

  String get _courseSummary {
    if (courseIds.isEmpty && !includeNoCourse) return 'All courses';
    final selected = <String>[
      for (final id in courseIds)
        if (widget.courses[id] != null) widget.courses[id]!,
      if (includeNoCourse) 'No related course',
    ];
    if (selected.isEmpty) return 'All courses';
    if (selected.length == 1) return selected.single;
    return '${selected.length} selected';
  }

  Future<void> _pickCourses() async {
    var draftIds = {...courseIds};
    var draftNoCourse = includeNoCourse;
    final entries = widget.courses.entries.toList()
      ..sort((a, b) => a.value.toLowerCase().compareTo(b.value.toLowerCase()));
    final result = await showDialog<(Set<String>, bool)>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Courses'),
          scrollable: true,
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CheckboxListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('No related course'),
                  value: draftNoCourse,
                  onChanged: (value) => setDialogState(
                    () => draftNoCourse = value ?? false,
                  ),
                ),
                for (final entry in entries)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value),
                    value: draftIds.contains(entry.key),
                    onChanged: (value) => setDialogState(() {
                      if (value == true) {
                        draftIds.add(entry.key);
                      } else {
                        draftIds.remove(entry.key);
                      }
                    }),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => setDialogState(() {
                draftIds.clear();
                draftNoCourse = false;
              }),
              child: const Text('All courses'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                (<String>{...draftIds}, draftNoCourse),
              ),
              child: const Text('Done'),
            ),
          ],
        ),
      ),
    );
    if (result != null && mounted) {
      setState(() {
        courseIds = result.$1;
        includeNoCourse = result.$2;
      });
    }
  }

  @override
  Widget build(BuildContext context) => TaskTypography(
    child: AlertDialog(
      title: const Text('Filter tasks'),
      scrollable: true,
      content: SizedBox(
        width: 520,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Categories · no selection means all'),
            chips(widget.categories, categories, (v) => v),
            const SizedBox(height: 12),
            const Text('Priorities · no selection means all'),
            chips(TaskPriority.values, priorities, (v) => v.label),
            const SizedBox(height: 12),
            const Text('Statuses · select at least one'),
            chips(TaskStatus.values, statuses, (v) => v.label),
            const SizedBox(height: 12),
            const Text('Sources · select at least one'),
            chips(TaskSource.values, sources, (v) => v.label),
            const SizedBox(height: 16),
            const Text('Courses · no selection means all'),
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _pickCourses,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _courseSummary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<DuePeriod>(
              initialValue: due,
              key: ValueKey(due),
              isExpanded: true,
              decoration: const InputDecoration(labelText: 'Due period'),
              items: [
                for (final period in DuePeriod.values)
                  DropdownMenuItem(value: period, child: Text(period.label)),
              ],
              onChanged: (v) => setState(() => due = v!),
            ),
            if (due == DuePeriod.custom)
              TextButton.icon(
                icon: const Icon(Icons.date_range),
                label: Text(
                  start == null || end == null
                      ? 'Choose date range'
                      : '${taskDateLabel(start!)} – ${taskDateLabel(end!)}',
                ),
                onPressed: () async {
                  final range = await showDateRangePicker(
                    context: context,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2200, 12, 31),
                    initialDateRange: start != null && end != null
                        ? DateTimeRange(start: start!, end: end!)
                        : null,
                  );
                  if (range != null && mounted) {
                    setState(() {
                      start = range.start;
                      end = range.end;
                    });
                  }
                },
              ),
            const SizedBox(height: 8),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include overdue tasks'),
              value: overdue,
              onChanged: (v) => setState(() => overdue = v!),
            ),
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include no-deadline tasks'),
              value: noDeadline,
              onChanged: (v) => setState(() => noDeadline = v!),
            ),
            const Text(
              'Overdue and no-deadline tasks stay visible outside the selected due period.',
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => read(const TaskFilter())),
          child: const Text('Reset'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed:
              statuses.isEmpty ||
                  sources.isEmpty ||
                  due == DuePeriod.custom && (start == null || end == null)
              ? null
              : () => Navigator.pop(
                  context,
                  TaskFilter(
                    categories: categories,
                    priorities: priorities,
                    statuses: statuses,
                    sources: sources,
                    courseIds: courseIds,
                    includeNoCourse: includeNoCourse,
                    duePeriod: due,
                    start: start,
                    end: end,
                    includeOverdue: overdue,
                    includeNoDeadline: noDeadline,
                    search: widget.filter.search,
                  ),
                ),
          child: const Text('Apply'),
        ),
      ],
    ),
  );

  Widget chips<T>(List<T> values, Set<T> selected, String Function(T) label) =>
      Wrap(
        spacing: 6,
        runSpacing: 4,
        children: [
          for (final value in values)
            FilterChip(
              label: Text(label(value)),
              selected: selected.contains(value),
              onSelected: (v) => setState(
                () => v ? selected.add(value) : selected.remove(value),
              ),
            ),
        ],
      );
}
