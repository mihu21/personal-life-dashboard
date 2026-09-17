import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../class_schedule/data/academic_database.dart';
import '../domain/task_logic.dart';
import '../domain/task_types.dart';

class TaskRepository {
  TaskRepository(this.db, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final AcademicDatabase db;
  final DateTime Function() clock;
  static const uuid = Uuid();

  Stream<List<TaskCategoryRecord>> watchCategories() => (db.select(
    db.taskCategoryRecords,
  )..orderBy([(c) => OrderingTerm.asc(c.name)])).watch();

  Future<void> saveCategory(
    String name,
    int color, {
    String? previousName,
  }) async {
    name = name.trim();
    if (name.isEmpty || name.length > 50) {
      throw ArgumentError('Use a category name of 1–50 characters.');
    }
    if (color < 0xFF000000 || color > 0xFFFFFFFF) {
      throw ArgumentError('Choose an opaque category color.');
    }
    await db.transaction(() async {
      final existing = await db.select(db.taskCategoryRecords).get();
      if (existing.any(
        (c) =>
            c.name.toLowerCase() == name.toLowerCase() &&
            c.name != previousName,
      )) {
        throw ArgumentError('A category with that name already exists.');
      }
      if (previousName != null &&
          !existing.any((c) => c.name == previousName)) {
        throw StateError('Category no longer exists.');
      }
      if (previousName != null && previousName != name) {
        await _moveCategoryTasks(previousName, name);
        await (db.delete(
          db.taskCategoryRecords,
        )..where((c) => c.name.equals(previousName))).go();
      }
      await db
          .into(db.taskCategoryRecords)
          .insertOnConflictUpdate(TaskCategoryRecord(name: name, color: color));
    });
  }

  Future<void> removeCategory(String name, String replacement) async {
    await db.transaction(() async {
      final all = await db.select(db.taskCategoryRecords).get();
      if (name == replacement || !all.any((c) => c.name == replacement)) {
        throw ArgumentError('Choose another category for these tasks.');
      }
      await _moveCategoryTasks(name, replacement);
      await (db.delete(
        db.taskCategoryRecords,
      )..where((c) => c.name.equals(name))).go();
    });
  }

  Future<void> _moveCategoryTasks(String oldName, String newName) async {
    await (db.update(
      db.taskRecords,
    )..where((t) => t.category.equals(oldName))).write(
      TaskRecordsCompanion(category: Value(newName), updatedAt: Value(clock())),
    );
    final filter = await loadFilter();
    if (filter.categories.contains(oldName)) {
      await saveFilter(
        TaskFilter(
          categories: {...filter.categories}
            ..remove(oldName)
            ..add(newName),
          priorities: filter.priorities,
          statuses: filter.statuses,
          sources: filter.sources,
          courseIds: filter.courseIds,
          includeNoCourse: filter.includeNoCourse,
          duePeriod: filter.duePeriod,
          start: filter.start,
          end: filter.end,
          search: filter.search,
          includeOverdue: filter.includeOverdue,
          includeNoDeadline: filter.includeNoDeadline,
        ),
      );
    }
  }

  Future<List<TaskBundle>> load() async {
    final tasks = await (db.select(
      db.taskRecords,
    )..where((t) => t.deletedAt.isNull())).get();
    final reminders = await db.select(db.taskReminders).get();
    final sourceRows = await db.customSelect('''
      SELECT task_id, provider
      FROM task_external_links
      WHERE ignored = 0
    ''').get();
    final sources = <String, TaskSource>{
      for (final row in sourceRows)
        row.read<String>('task_id'): switch (row.read<String>('provider')) {
          'eeclass' => TaskSource.eeclass,
          'elearn' => TaskSource.elearn,
          _ => TaskSource.manual,
        },
    };
    return [
      for (final task in tasks)
        TaskBundle(
          task,
          reminders.where((r) => r.taskId == task.id).toList(),
          sources[task.id] ?? TaskSource.manual,
        ),
    ];
  }

  Stream<List<TaskBundle>> watch() => db
      .customSelect(
        'SELECT id FROM task_records',
        readsFrom: {db.taskRecords, db.taskReminders},
      )
      .watch()
      .asyncMap((_) => load());

  Future<TaskFilter> loadFilter() async {
    final row = await (db.select(
      db.taskPreferences,
    )..where((t) => t.key.equals('agenda'))).getSingleOrNull();
    if (row == null) return const TaskFilter();
    try {
      return TaskFilter.decode(row.value);
    } on Object {
      return const TaskFilter();
    }
  }

  Future<void> saveFilter(TaskFilter filter) => db
      .into(db.taskPreferences)
      .insertOnConflictUpdate(
        TaskPreferencesCompanion.insert(key: 'agenda', value: filter.encode()),
      );

  Future<void> save(TaskBundle bundle) async {
    final task = bundle.task;
    if (task.title.trim().isEmpty) {
      throw ArgumentError('Task title is required.');
    }
    if (task.category.trim().isEmpty) {
      throw ArgumentError('Category is required.');
    }
    if (task.repeatInterval < 1 || task.repeatInterval > 999) {
      throw ArgumentError('Repeat interval must be 1–999.');
    }
    for (final reminder in bundle.reminders) {
      if ((reminder.customAt == null) == (reminder.minutesBefore == null)) {
        throw ArgumentError('Choose a custom reminder or a deadline offset.');
      }
      if (reminder.minutesBefore != null &&
          (task.deadline == null || reminder.minutesBefore! < 0)) {
        throw ArgumentError('Relative reminders require a deadline.');
      }
    }
    await db.transaction(() async {
      // Preserve imported/custom category names without inventing a second store.
      await db
          .into(db.taskCategoryRecords)
          .insert(
            TaskCategoryRecordsCompanion.insert(
              name: task.category,
              color: defaultTaskCategoryColors[task.category] ?? 0xFFA6A6B9,
            ),
            mode: InsertMode.insertOrIgnore,
          );
      final previous = await (db.select(
        db.taskRecords,
      )..where((t) => t.id.equals(task.id))).getSingleOrNull();
      if (previous?.deletedAt != null) {
        throw StateError('This task was deleted.');
      }
      final now = clock();
      final saved = task.copyWith(
        title: task.title.trim(),
        updatedAt: now,
        createdAt: previous?.createdAt ?? task.createdAt,
        deadline: Value(
          task.deadline == null
              ? null
              : task.hasDeadlineTime
              ? task.deadline
              : taskDay(task.deadline!),
        ),
        hasDeadlineTime: task.deadline != null && task.hasDeadlineTime,
        completedAt: Value(
          task.status == TaskStatus.completed
              ? previous?.completedAt ?? now
              : null,
        ),
      );
      await db
          .into(db.taskRecords)
          .insertOnConflictUpdate(saved.toCompanion(false));
      final old = await (db.select(
        db.taskReminders,
      )..where((r) => r.taskId.equals(task.id))).get();
      final retained = bundle.reminders
          .map((r) => r.id)
          .where((id) => id > 0)
          .toSet();
      for (final reminder in old.where((r) => !retained.contains(r.id))) {
        await (db.delete(
          db.taskReminders,
        )..where((r) => r.id.equals(reminder.id))).go();
      }
      final seen = <String>{};
      for (final reminder in bundle.reminders) {
        final signature =
            '${reminder.minutesBefore}:${reminder.customAt}:${reminder.snoozedUntil}';
        if (!seen.add(signature)) continue;
        if (reminder.id > 0 && !old.any((r) => r.id == reminder.id)) {
          throw ArgumentError('Reminder does not belong to this task.');
        }
        await db
            .into(db.taskReminders)
            .insertOnConflictUpdate(
              TaskRemindersCompanion(
                id: reminder.id > 0 ? Value(reminder.id) : const Value.absent(),
                taskId: Value(task.id),
                minutesBefore: Value(reminder.minutesBefore),
                customAt: Value(reminder.customAt),
                snoozedUntil: Value(reminder.snoozedUntil),
              ),
            );
      }
      if (saved.status == TaskStatus.completed &&
          previous?.status != TaskStatus.completed &&
          saved.repeatUnit != RepeatUnit.none) {
        await _createNext(saved, bundle.reminders, now);
      }
    });
  }

  Future<void> _createNext(
    TaskRecord task,
    List<TaskReminder> reminders,
    DateTime now,
  ) async {
    // One successor per completed occurrence. Reopening/recompleting the parent
    // never creates duplicates, even if its successor was subsequently deleted.
    final existing = await (db.select(
      db.taskRecords,
    )..where((t) => t.previousOccurrenceId.equals(task.id))).getSingleOrNull();
    if (existing != null) return;
    final customs =
        reminders.map((r) => r.customAt).whereType<DateTime>().toList()..sort();
    final anchor = task.deadline ?? customs.firstOrNull ?? task.createdAt;
    var next = advanceRecurrence(
      anchor,
      task.repeatUnit,
      task.repeatInterval,
      anchorDay: task.repeatAnchorDay,
    );
    while (!(task.deadline != null && !task.hasDeadlineTime
            ? taskDayAfter(next, 1)
            : next)
        .isAfter(now)) {
      next = advanceRecurrence(
        next,
        task.repeatUnit,
        task.repeatInterval,
        anchorDay: task.repeatAnchorDay ?? anchor.day,
      );
    }
    final id = uuid.v4();
    await db
        .into(db.taskRecords)
        .insert(
          task.copyWith(
            id: id,
            createdAt: now,
            updatedAt: now,
            status: TaskStatus.active,
            deadline: Value(task.deadline == null ? null : next),
            completedAt: const Value(null),
            previousOccurrenceId: Value(task.id),
            repeatAnchorDay: Value(task.repeatAnchorDay ?? anchor.day),
          ),
        );
    // Offset reminders follow the new deadline. Absolute reminders retain their
    // calendar-day offset and wall-clock time; snooze applies to one occurrence.
    final shift = DateTime.utc(
      next.year,
      next.month,
      next.day,
    ).difference(DateTime.utc(anchor.year, anchor.month, anchor.day)).inDays;
    for (final reminder in reminders) {
      final custom = reminder.customAt;
      await db
          .into(db.taskReminders)
          .insert(
            TaskRemindersCompanion.insert(
              taskId: id,
              minutesBefore: Value(reminder.minutesBefore),
              customAt: Value(
                custom == null
                    ? null
                    : DateTime(
                        custom.year,
                        custom.month,
                        custom.day + shift,
                        custom.hour,
                        custom.minute,
                      ),
              ),
            ),
          );
    }
  }

  Future<void> setStatus(String id, TaskStatus status) async {
    final bundle = (await load()).where((b) => b.task.id == id).firstOrNull;
    if (bundle == null) throw StateError('Task no longer exists.');
    await save(
      TaskBundle(bundle.task.copyWith(status: status), bundle.reminders),
    );
  }

  Future<void> delete(String id) async {
    await (db.update(db.taskRecords)..where((t) => t.id.equals(id))).write(
      TaskRecordsCompanion(
        deletedAt: Value(clock()),
        updatedAt: Value(clock()),
      ),
    );
  }

  Future<void> snooze(int reminderId, DateTime until) async {
    if (!until.isAfter(clock())) {
      throw ArgumentError('Snooze must be in the future.');
    }
    final reminder = await (db.select(
      db.taskReminders,
    )..where((r) => r.id.equals(reminderId))).getSingle();
    final task = await (db.select(
      db.taskRecords,
    )..where((t) => t.id.equals(reminder.taskId))).getSingle();
    if (task.deletedAt != null || task.status == TaskStatus.completed) {
      throw StateError('Only active tasks can be snoozed.');
    }
    await (db.update(db.taskReminders)..where((r) => r.id.equals(reminderId)))
        .write(TaskRemindersCompanion(snoozedUntil: Value(until)));
  }
}
