import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';

TaskRecord taskFixture(
  String id, {
  DateTime? due,
  bool timed = true,
  String category = 'Personal',
  TaskPriority priority = TaskPriority.medium,
  TaskStatus status = TaskStatus.active,
  RepeatUnit repeat = RepeatUnit.none,
}) => TaskRecord(
  id: id,
  title: id,
  notes: 'Notes for $id',
  category: category,
  deadline: due,
  hasDeadlineTime: due != null && timed,
  priority: priority,
  status: status,
  repeatUnit: repeat,
  repeatInterval: 1,
  createdAt: DateTime(2026, 9, 15, 8),
  updatedAt: DateTime(2026, 9, 15, 8),
);

void main() {
  final now = DateTime(2026, 9, 15, 12);
  test('date-only deadline stays current through end of local day', () {
    final task = taskFixture(
      'date only',
      due: DateTime(2026, 9, 15),
      timed: false,
    );
    expect(isTaskOverdue(task, now), false);
    expect(isTaskOverdue(task, DateTime(2026, 9, 16)), true);
    expect(
      isTaskOverdue(
        task.copyWith(status: TaskStatus.completed),
        DateTime(2026, 9, 16),
      ),
      false,
    );
    expect(task.priority, TaskPriority.medium);
    expect(isTaskOverdue(taskFixture('undated'), now), false);
  });

  test(
    'deadlines sort chronologically, date-only at end of day, undated last',
    () {
      final tasks = [
        TaskBundle(taskFixture('none')),
        TaskBundle(taskFixture('date', due: taskDay(now), timed: false)),
        TaskBundle(taskFixture('time', due: now.add(const Duration(hours: 2)))),
        TaskBundle(taskFixture('old', due: taskDayAfter(now, -1))),
      ];
      expect(
        filterTasks(tasks, const TaskFilter(), now).map((b) => b.task.id),
        ['old', 'time', 'date', 'none'],
      );
      expect(tasks.map((b) => b.task.id).first, 'none');
    },
  );

  test(
    'OR within categories/priorities/statuses, AND across filter groups',
    () {
      final tasks = [
        TaskBundle(
          taskFixture('a', category: 'Homework', priority: TaskPriority.high),
        ),
        TaskBundle(
          taskFixture(
            'b',
            category: 'Exam',
            priority: TaskPriority.high,
            status: TaskStatus.active,
          ),
        ),
        TaskBundle(
          taskFixture('c', category: 'Personal', priority: TaskPriority.high),
        ),
        TaskBundle(
          taskFixture('d', category: 'Homework', priority: TaskPriority.low),
        ),
        TaskBundle(
          taskFixture(
            'e',
            category: 'Homework',
            priority: TaskPriority.high,
            status: TaskStatus.completed,
          ),
        ),
      ];
      const filter = TaskFilter(
        categories: {'Homework', 'Exam'},
        priorities: {TaskPriority.high},
        statuses: {TaskStatus.active},
      );
      expect(filterTasks(tasks, filter, now).map((b) => b.task.id), ['a', 'b']);
      expect(
        filterTasks(
          tasks,
          const TaskFilter(statuses: {TaskStatus.completed}),
          now,
        ).single.task.id,
        'e',
      );
    },
  );

  for (final limit in [5, 10, 20, null]) {
    test('Next $limit applies after filters and preserves overdue/undated', () {
      final tasks = [
        for (var i = 0; i < 50; i++)
          TaskBundle(
            taskFixture(
              'task$i',
              due: now.add(Duration(days: i + 1)),
              category: i.isEven ? 'Exam' : 'Personal',
            ),
          ),
        TaskBundle(
          taskFixture(
            'overdue',
            due: now.subtract(const Duration(days: 1)),
            category: 'Exam',
          ),
        ),
        TaskBundle(taskFixture('undated', category: 'Exam')),
      ];
      final result = filterTasks(
        tasks,
        TaskFilter(categories: const {'Exam'}, limit: limit),
        now,
      );
      expect(result.length, (limit ?? 25) + 2);
      expect(result.first.task.id, 'overdue');
      expect(result.last.task.id, 'undated');
      expect(
        filterTasks(
          tasks,
          TaskFilter(categories: const {'Exam'}, limit: limit),
          now,
          applyLimit: false,
        ).length,
        27,
      );
    });
  }

  test(
    'all due periods use inclusive civil dates and exclude end boundary',
    () {
      final tasks = [
        for (var i = 0; i < 40; i++)
          TaskBundle(
            taskFixture('$i', due: taskDayAfter(now, i), timed: false),
          ),
      ];
      for (final entry in {
        DuePeriod.today: 1,
        DuePeriod.next3: 3,
        DuePeriod.thisWeek: 6,
        DuePeriod.next7: 7,
        DuePeriod.next30: 30,
      }.entries) {
        expect(
          filterTasks(
            tasks,
            TaskFilter(duePeriod: entry.key, limit: null),
            now,
          ).length,
          entry.value,
        );
      }
      final custom = TaskFilter(
        duePeriod: DuePeriod.custom,
        start: DateTime(2026, 9, 17),
        end: DateTime(2026, 9, 19),
      );
      expect(filterTasks(tasks, custom, now).map((b) => b.task.id), [
        '2',
        '3',
        '4',
      ]);
      expect(
        filterTasks(
          [
            TaskBundle(taskFixture('none')),
            TaskBundle(taskFixture('old', due: taskDayAfter(now, -1))),
          ],
          const TaskFilter(includeNoDeadline: false, includeOverdue: false),
          now,
        ),
        isEmpty,
      );
    },
  );

  test(
    'search cooperates with filters and searches notes and linked course',
    () {
      final task = taskFixture('Homework').copyWith(
        courseId: const Value('os'),
        notes: 'Read synchronization chapter',
      );
      final tasks = [TaskBundle(task)];
      expect(
        filterTasks(tasks, const TaskFilter(search: 'SYNCHRONIZATION'), now),
        hasLength(1),
      );
      expect(
        filterTasks(
          tasks,
          const TaskFilter(search: 'operating'),
          now,
          courseNames: {'os': 'Operating Systems'},
        ),
        hasLength(1),
      );
      expect(
        filterTasks(
          tasks,
          const TaskFilter(search: 'Homework', categories: {'Exam'}),
          now,
        ),
        isEmpty,
      );
    },
  );

  test('filters round trip including custom range and all limit', () {
    final f = TaskFilter(
      categories: {'Exam', 'Personal'},
      priorities: {TaskPriority.high, TaskPriority.low},
      statuses: {TaskStatus.completed},
      duePeriod: DuePeriod.custom,
      start: now,
      end: taskDayAfter(now, 3),
      limit: null,
      includeOverdue: false,
      includeNoDeadline: false,
      search: 'report',
    );
    expect(TaskFilter.decode(f.encode()).encode(), f.encode());
  });

  test(
    'custom reminder is independent; presets follow deadline edits; snooze overrides',
    () {
      final task = taskFixture('no deadline');
      final custom = TaskReminder(id: 1, taskId: task.id, customAt: now);
      expect(reminderTime(task, custom), now);
      for (final minutes in reminderPresets.keys) {
        final reminder = TaskReminder(
          id: 2,
          taskId: task.id,
          minutesBefore: minutes,
        );
        expect(
          reminderTime(
            task.copyWith(deadline: Value(now), hasDeadlineTime: true),
            reminder,
          ),
          now.subtract(Duration(minutes: minutes)),
        );
        expect(
          reminderTime(task, reminder.copyWith(snoozedUntil: Value(now))),
          now,
        );
      }
    },
  );

  test(
    'daily weekly monthly and custom recurrence preserve wall time and month anchor',
    () {
      final jan = DateTime(2028, 1, 31, 18, 45);
      final feb = advanceRecurrence(jan, RepeatUnit.monthly, 1, anchorDay: 31);
      expect(feb, DateTime(2028, 2, 29, 18, 45));
      expect(
        advanceRecurrence(feb, RepeatUnit.monthly, 1, anchorDay: 31),
        DateTime(2028, 3, 31, 18, 45),
      );
      expect(
        advanceRecurrence(jan, RepeatUnit.daily, 3),
        DateTime(2028, 2, 3, 18, 45),
      );
      expect(
        advanceRecurrence(jan, RepeatUnit.weekly, 2),
        DateTime(2028, 2, 14, 18, 45),
      );
    },
  );
}
