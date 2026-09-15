import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class_schedule/data/academic_database.dart';
import '../../class_schedule/providers/academic_providers.dart';
import '../../class_schedule/domain/academic_types.dart';
import 'task_categories_dialog.dart';
import '../data/task_repository.dart';
import '../domain/task_logic.dart';
import '../domain/task_types.dart';
import '../providers/task_providers.dart';

Future<void> showTaskEditor(
  BuildContext context, {
  TaskBundle? bundle,
  DateTime? date,
}) => showDialog<void>(
  context: context,
  builder: (_) => TaskEditor(bundle: bundle, date: date),
);

/// Keep the app's typography and colors, with readable task text on small screens.
class TaskTypography extends StatelessWidget {
  const TaskTypography({required this.child, super.key});
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(
          bodyMedium: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
          bodyLarge: theme.textTheme.bodyLarge?.copyWith(fontSize: 14),
          bodySmall: theme.textTheme.bodySmall?.copyWith(fontSize: 14),
          labelLarge: theme.textTheme.labelLarge?.copyWith(fontSize: 14),
          titleSmall: theme.textTheme.titleSmall?.copyWith(fontSize: 16),
        ),
      ),
      child: child,
    );
  }
}

Future<DateTime?> pickTaskDateTime(
  BuildContext context,
  DateTime initial,
) async {
  final date = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2200, 12, 31),
  );
  if (date == null || !context.mounted) return null;
  final time = await showTimePicker(
    context: context,
    initialTime: TimeOfDay.fromDateTime(initial),
  );
  return time == null
      ? null
      : DateTime(date.year, date.month, date.day, time.hour, time.minute);
}

class TaskEditor extends ConsumerStatefulWidget {
  const TaskEditor({this.bundle, this.date, super.key});
  final TaskBundle? bundle;
  final DateTime? date;
  @override
  ConsumerState<TaskEditor> createState() => _TaskEditorState();
}

class _TaskEditorState extends ConsumerState<TaskEditor> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title, notes, interval;
  late String id, category;
  String? courseId;
  DateTime? deadline;
  var deadlineMode = 0;
  TaskPriority priority = TaskPriority.medium;
  TaskStatus status = TaskStatus.active;
  RepeatUnit repeat = RepeatUnit.none;
  List<TaskReminder> reminders = [];
  bool saving = false;
  String? error;

  @override
  void initState() {
    super.initState();
    final task = widget.bundle?.task;
    id = task?.id ?? TaskRepository.uuid.v4();
    title = TextEditingController(text: task?.title);
    notes = TextEditingController(text: task?.notes);
    interval = TextEditingController(text: '${task?.repeatInterval ?? 1}');
    category = task?.category ?? 'Personal';
    courseId = task?.courseId;
    deadline = task?.deadline ?? widget.date;
    deadlineMode = deadline == null
        ? 0
        : task?.hasDeadlineTime == true
        ? 2
        : 1;
    priority = task?.priority ?? priority;
    status = task?.status ?? status;
    repeat = task?.repeatUnit ?? repeat;
    reminders = [...?widget.bundle?.reminders];
  }

  @override
  void dispose() {
    title.dispose();
    notes.dispose();
    interval.dispose();
    super.dispose();
  }

  TaskRecord record() {
    final original = widget.bundle?.task;
    final now = DateTime.now();
    return TaskRecord(
      id: id,
      title: title.text.trim(),
      notes: notes.text.trim(),
      category: category,
      courseId: courseId,
      deadline: deadlineMode == 0 ? null : deadline,
      hasDeadlineTime: deadlineMode == 2,
      priority: priority,
      status: status,
      repeatUnit: repeat,
      repeatInterval: int.tryParse(interval.text) ?? 1,
      repeatAnchorDay: original?.deadline == deadline
          ? original?.repeatAnchorDay
          : deadline?.day,
      previousOccurrenceId: original?.previousOccurrenceId,
      completedAt: original?.completedAt,
      createdAt: original?.createdAt ?? now,
      updatedAt: now,
    );
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      saving = true;
      error = null;
    });
    String? warning;
    try {
      if (reminders.isNotEmpty && status != TaskStatus.completed) {
        try {
          if (!await ref
              .read(taskNotificationServiceProvider)
              .gateway
              .permission(request: true)) {
            warning =
                'Task saved. Notifications are disabled; enable them in system settings and retry in Tasks.';
          }
        } catch (_) {
          warning = 'Task saved. Notification setup failed; retry in Tasks.';
        }
      }
      await ref
          .read(taskRepositoryProvider)
          .save(TaskBundle(record(), reminders));
      if (!mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      if (warning != null) {
        messenger.showSnackBar(SnackBar(content: Text(warning)));
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          error = '$e';
          saving = false;
        });
      }
    }
  }

  Future<void> addReminder() async {
    final preset = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Add reminder'),
        children: [
          if (deadlineMode != 0)
            for (final entry in reminderPresets.entries)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(context, entry.key),
                child: Text(entry.value),
              ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, -1),
            child: const Text('Custom date/time'),
          ),
        ],
      ),
    );
    if (preset == null || !mounted) return;
    DateTime? custom;
    if (preset == -1) {
      custom = await pickTaskDateTime(
        context,
        DateTime.now().add(const Duration(hours: 1)),
      );
      if (custom == null || !mounted) return;
    }
    final value = TaskReminder(
      id: 0,
      taskId: id,
      customAt: custom,
      minutesBefore: preset == -1 ? null : preset,
    );
    if (!reminders.any(
      (r) =>
          r.minutesBefore == value.minutesBefore &&
          r.customAt == value.customAt,
    )) {
      setState(() => reminders.add(value));
    }
  }

  Future<void> snooze(int index, int minutes) async {
    final now = DateTime.now();
    final until = minutes == -1
        ? await pickTaskDateTime(context, now.add(const Duration(hours: 1)))
        : minutes == 1440
        ? DateTime(now.year, now.month, now.day + 1, now.hour, now.minute)
        : now.add(Duration(minutes: minutes));
    if (until != null && mounted) {
      setState(
        () => reminders[index] = reminders[index].copyWith(
          snoozedUntil: Value(until),
        ),
      );
    }
  }

  void changeDeadlineMode(int mode) {
    setState(() {
      if (mode == 0 && deadlineMode != 0) {
        final old = record();
        reminders = [
          for (final r in reminders)
            r.minutesBefore == null
                ? r
                : r.copyWith(
                    minutesBefore: const Value(null),
                    customAt: Value(reminderTime(old, r)),
                    snoozedUntil: const Value(null),
                  ),
        ];
      }
      deadlineMode = mode;
      if (mode != 0) deadline ??= taskDay(DateTime.now());
    });
  }

  @override
  Widget build(BuildContext context) => TaskTypography(
    child: Builder(
      builder: (context) {
        final snapshot = ref.watch(academicSnapshotProvider).asData?.value;
        final courses =
            snapshot?.courses
                .where(
                  (c) =>
                      c.deletedAt == null &&
                      c.semesterId == snapshot.currentSemester?.id &&
                      c.status == CourseStatus.inProgress,
                )
                .toList() ??
            <Course>[];
        final categoryRecords = ref.watch(taskCategoriesProvider).asData?.value;
        final categories =
            categoryRecords?.map((c) => c.name).toList() ?? [category];
        if (!categories.contains(category) && categories.isNotEmpty) {
          category = categories.first;
        }
        final inactiveLink =
            courseId != null && !courses.any((c) => c.id == courseId);
        return AlertDialog(
          title: Text(widget.bundle == null ? 'Add task' : 'Edit task'),
          scrollable: true,
          content: SizedBox(
            width: 540,
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        error!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  TextFormField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title'),
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Enter a task title.'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  _dropdown<String>(
                    'Category',
                    category,
                    categories,
                    (v) => v,
                    (v) => setState(() => category = v),
                  ),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => showTaskCategories(context),
                      icon: const Icon(Icons.palette_outlined),
                      label: const Text('Manage categories'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (inactiveLink)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'Previously linked: ${snapshot?.courses.where((c) => c.id == courseId).firstOrNull?.courseName ?? 'Unavailable course'}',
                      ),
                      subtitle: const Text(
                        'This course is no longer active. Its existing link is preserved.',
                      ),
                      trailing: IconButton(
                        tooltip: 'Unlink course',
                        icon: const Icon(Icons.link_off),
                        onPressed: () => setState(() => courseId = null),
                      ),
                    ),
                  _dropdown<String>(
                    'Active course (optional)',
                    inactiveLink ? '' : courseId ?? '',
                    ['', ...courses.map((c) => c.id)],
                    (v) => v.isEmpty
                        ? 'No course'
                        : courses.firstWhere((c) => c.id == v).courseName,
                    (v) => setState(() => courseId = v.isEmpty ? null : v),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: notes,
                    minLines: 2,
                    maxLines: 6,
                    decoration: const InputDecoration(
                      labelText: 'Notes / description',
                    ),
                  ),
                  const SizedBox(height: 12),
                  _dropdown<int>(
                    'Deadline',
                    deadlineMode,
                    [0, 1, 2],
                    (v) => ['No deadline', 'Date only', 'Date and time'][v],
                    changeDeadlineMode,
                  ),
                  if (deadlineMode != 0) ...[
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today_outlined),
                      label: Text(
                        taskDateLabel(deadline!, time: deadlineMode == 2),
                      ),
                      onPressed: () async {
                        final picked = deadlineMode == 2
                            ? await pickTaskDateTime(context, deadline!)
                            : await showDatePicker(
                                context: context,
                                initialDate: deadline!,
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2200, 12, 31),
                              );
                        if (picked != null && mounted) {
                          setState(() => deadline = picked);
                        }
                      },
                    ),
                    if (deadlineMode == 1)
                      const Text('Due at the end of this date.'),
                  ],
                  const SizedBox(height: 12),
                  _dropdown<TaskPriority>(
                    'Priority',
                    priority,
                    TaskPriority.values,
                    (v) => v.label,
                    (v) => setState(() => priority = v),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'New tasks start Active. Mark them completed from task details.',
                  ),
                  const SizedBox(height: 8),
                  ExpansionTile(
                    title: Text('Reminders (${reminders.length})'),
                    initiallyExpanded: reminders.isNotEmpty,
                    tilePadding: EdgeInsets.zero,
                    children: [
                      const Text(
                        'Reminders are independent of deadlines. Removing a deadline keeps its reminders as custom times.',
                      ),
                      for (var i = 0; i < reminders.length; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  '${reminders[i].minutesBefore == null ? 'Custom' : reminderPresets[reminders[i].minutesBefore] ?? '${reminders[i].minutesBefore} minutes before'}\n'
                                  '${taskDateLabel(reminderTime(record(), reminders[i])!, time: true)}'
                                  '${reminders[i].snoozedUntil == null ? '' : ' · Snoozed'}'
                                  '${reminderTime(record(), reminders[i])!.isBefore(DateTime.now()) ? ' · Past (will not notify)' : ''}',
                                ),
                              ),
                              if (status != TaskStatus.completed)
                                PopupMenuButton<int>(
                                  tooltip: 'Snooze reminder',
                                  icon: const Icon(Icons.snooze),
                                  onSelected: (v) => snooze(i, v),
                                  itemBuilder: (_) => [
                                    for (final e in const {
                                      10: '10 minutes',
                                      60: '1 hour',
                                      1440: 'Tomorrow',
                                      -1: 'Custom',
                                    }.entries)
                                      PopupMenuItem(
                                        value: e.key,
                                        child: Text(e.value),
                                      ),
                                  ],
                                ),
                              IconButton(
                                tooltip: 'Remove reminder',
                                onPressed: () =>
                                    setState(() => reminders.removeAt(i)),
                                icon: const Icon(Icons.close),
                              ),
                            ],
                          ),
                        ),
                      OutlinedButton.icon(
                        onPressed: addReminder,
                        icon: const Icon(Icons.add_alert_outlined),
                        label: const Text('Add reminder'),
                      ),
                    ],
                  ),
                  ExpansionTile(
                    title: const Text('Repeat'),
                    tilePadding: EdgeInsets.zero,
                    initiallyExpanded: repeat != RepeatUnit.none,
                    children: [
                      _dropdown<RepeatUnit>(
                        'Recurrence',
                        repeat,
                        RepeatUnit.values,
                        (v) => v.label,
                        (v) => setState(() => repeat = v),
                      ),
                      if (repeat != RepeatUnit.none) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: interval,
                          keyboardType: TextInputType.number,
                          onChanged: (_) => setState(() {}),
                          decoration: InputDecoration(
                            labelText: 'Repeat every',
                            suffixText: switch (repeat) {
                              RepeatUnit.daily => 'days',
                              RepeatUnit.weekly => 'weeks',
                              _ => 'months',
                            },
                          ),
                          validator: (v) =>
                              repeat == RepeatUnit.none ||
                                  (int.tryParse(v ?? '') ?? 0) >= 1 &&
                                      (int.tryParse(v ?? '') ?? 1000) <= 999
                              ? null
                              : 'Enter 1–999.',
                        ),
                        const SizedBox(height: 8),
                        Text(recurrenceDescription(record())),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: saving ? null : () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: saving ? null : save,
              child: Text(saving ? 'Saving…' : 'Save task'),
            ),
          ],
        );
      },
    ),
  );

  Widget _dropdown<T>(
    String label,
    T value,
    List<T> values,
    String Function(T) labelFor,
    void Function(T) changed,
  ) => DropdownButtonFormField<T>(
    key: ValueKey('$label:$value'),
    initialValue: value,
    isExpanded: true,
    itemHeight: null,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final entry in values)
        DropdownMenuItem(value: entry, child: Text(labelFor(entry))),
    ],
    onChanged: saving
        ? null
        : (v) {
            if (v != null) changed(v);
          },
  );
}
