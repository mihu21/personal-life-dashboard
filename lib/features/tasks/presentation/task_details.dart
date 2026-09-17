import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../class_schedule/data/academic_database.dart';
import '../../class_schedule/providers/academic_providers.dart';
import '../../lms/providers/lms_providers.dart';
import '../domain/task_logic.dart';
import '../domain/task_types.dart';
import '../providers/task_providers.dart';
import 'task_editor.dart';
import 'task_visuals.dart';

Future<void> showTaskDetails(BuildContext context, TaskBundle bundle) async {
  final edit = await showDialog<TaskBundle>(
    context: context,
    builder: (_) => TaskDetails(bundle: bundle),
  );
  if (edit != null && context.mounted) {
    await showTaskEditor(context, bundle: edit);
  }
}

class TaskDetails extends ConsumerStatefulWidget {
  const TaskDetails({required this.bundle, super.key});
  final TaskBundle bundle;
  @override
  ConsumerState<TaskDetails> createState() => _TaskDetailsState();
}

class _TaskDetailsState extends ConsumerState<TaskDetails> {
  final notesScrollController = ScrollController();
  bool busy = false;
  String? error;

  @override
  void dispose() {
    notesScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bundle =
        ref
            .watch(tasksProvider)
            .asData
            ?.value
            .where((b) => b.task.id == widget.bundle.task.id)
            .firstOrNull ??
        widget.bundle;
    final t = bundle.task;
    final categories = ref.watch(taskCategoriesProvider).asData?.value;
    final color = Color(
      categories?.where((c) => c.name == t.category).firstOrNull?.color ??
          defaultTaskCategoryColors[t.category] ??
          0xFFA6A6B9,
    );
    final course = ref
        .watch(academicSnapshotProvider)
        .asData
        ?.value
        .courses
        .where((c) => c.id == t.courseId)
        .firstOrNull;
    final screenHeight = MediaQuery.sizeOf(context).height;
    final maxContentHeight = (screenHeight * .66).clamp(280.0, 600.0).toDouble();
    final maxNotesHeight = (screenHeight * .27).clamp(100.0, 260.0).toDouble();
    final overdue = isTaskOverdue(t, DateTime.now());
    return TaskTypography(
      child: AlertDialog(
        title: Text(t.title),
        content: SizedBox(
          width: 520,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxContentHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          TaskPriorityMark(
                            priority: t.priority,
                            color: color,
                            category: t.category,
                          ),
                          Text('${t.category} · ${t.priority.label} priority'),
                        ],
                      ),
                    ),
                    Tooltip(
                      message: t.status == TaskStatus.completed
                          ? 'Mark active'
                          : 'Mark complete',
                      child: Checkbox(
                        value: t.status == TaskStatus.completed,
                        onChanged: busy
                            ? null
                            : (value) => setCompleted(value ?? false),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  t.deadline == null
                      ? 'No deadline${overdue ? ' · Overdue' : ''}'
                      : 'Due ${taskDateLabel(t.deadline!, time: t.hasDeadlineTime)}${t.hasDeadlineTime ? '' : ' (end of day)'}${overdue ? ' · Overdue' : ''}',
                ),
                if (t.courseId != null)
                  Text('Course: ${course?.courseName ?? 'Unavailable course'}'),
                if (t.notes.isNotEmpty) ...[
                  const Divider(height: 24),
                  Flexible(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: maxNotesHeight),
                      child: SizedBox(
                        key: const ValueKey('task-notes-area'),
                        width: double.infinity,
                        child: Scrollbar(
                          controller: notesScrollController,
                          child: SingleChildScrollView(
                            key: const ValueKey('task-notes-scroll'),
                            controller: notesScrollController,
                            primary: false,
                            padding: const EdgeInsets.only(right: 12),
                            child: SelectableText(
                              t.notes,
                              textAlign: TextAlign.start,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
                const Divider(height: 24),
                Text(
                  'Reminders (${bundle.reminders.length})',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                if (bundle.reminders.isEmpty) const Text('No reminders'),
                for (final r in bundle.reminders)
                  Text(
                    '${taskDateLabel(reminderTime(t, r)!, time: true)}${r.snoozedUntil == null ? '' : ' · Snoozed'}',
                  ),
                const SizedBox(height: 12),
                Text(recurrenceDescription(t)),
                if (error != null) Text(error!),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: busy ? null : () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: busy ? null : () => _deleteTask(t),
            child: const Text('Delete task'),
          ),
          OutlinedButton(
            onPressed: busy ? null : () => Navigator.pop(context, bundle),
            child: const Text('Edit task'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskRecord task) async {
    final syncService = ref.read(lmsTaskSyncServiceProvider);
    final imported = await syncService.isImportedTask(task.id);
    if (!mounted) {
      return;
    }

    if (!imported) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Delete task?'),
          content: Text('Delete “${task.title}” and cancel its reminders?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('Delete'),
            ),
          ],
        ),
      );
      if (confirmed == true && mounted) {
        await act(() => ref.read(taskRepositoryProvider).delete(task.id));
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete LMS task?'),
        content: Text(
          'Delete “${task.title}”?\n\n'
          'It will stay deleted during future LMS syncs. You can restore it later from Settings → NTHU LMS → Deleted LMS tasks.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }

    await act(() async {
      await syncService.deleteImportedTask(task.id);
      ref.invalidate(ignoredLmsTasksProvider);
    });
  }

  Future<void> setCompleted(bool completed) async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      await ref
          .read(taskRepositoryProvider)
          .setStatus(
            widget.bundle.task.id,
            completed ? TaskStatus.completed : TaskStatus.active,
          );
      if (mounted) setState(() => busy = false);
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
          error = '$e';
        });
      }
    }
  }

  Future<void> act(Future<void> Function() action) async {
    setState(() => busy = true);
    try {
      await action();
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          busy = false;
          error = '$e';
        });
      }
    }
  }
}
