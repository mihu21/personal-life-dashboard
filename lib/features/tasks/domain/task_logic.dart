import 'dart:convert';

import '../../class_schedule/data/academic_database.dart';
import 'task_types.dart';

DateTime taskDay(DateTime date) => DateTime(date.year, date.month, date.day);
DateTime taskDayAfter(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

DateTime? effectiveDeadline(TaskRecord task) {
  final date = task.deadline;
  if (date == null) return null;
  return task.hasDeadlineTime
      ? date
      : taskDayAfter(date, 1).subtract(const Duration(microseconds: 1));
}

bool isTaskOverdue(TaskRecord task, DateTime now) =>
    task.status != TaskStatus.completed &&
    effectiveDeadline(task)?.isBefore(now) == true;

DateTime? reminderTime(TaskRecord task, TaskReminder reminder) =>
    reminder.snoozedUntil ??
    reminder.customAt ??
    effectiveDeadline(
      task,
    )?.subtract(Duration(minutes: reminder.minutesBefore!));

class TaskBundle {
  const TaskBundle(
    this.task, [
    this.reminders = const [],
    this.source = TaskSource.manual,
  ]);
  final TaskRecord task;
  final List<TaskReminder> reminders;
  final TaskSource source;
}

enum DuePeriod { any, today, next3, thisWeek, next7, next30, custom }

extension DuePeriodLabel on DuePeriod {
  String get label => [
    'Any time',
    'Today',
    'Next 3 days',
    'This week',
    'Next 7 days',
    'Next 30 days',
    'Custom date range',
  ][index];
}

class TaskFilter {
  const TaskFilter({
    this.categories = const {},
    this.priorities = const {},
    this.statuses = const {TaskStatus.active},
    this.sources = const {
      TaskSource.manual,
      TaskSource.eeclass,
      TaskSource.elearn,
    },
    this.courseIds = const {},
    this.includeNoCourse = false,
    this.duePeriod = DuePeriod.any,
    this.start,
    this.end,
    this.search = '',
    this.includeOverdue = true,
    this.includeNoDeadline = true,
  });
  final Set<String> categories;
  final Set<TaskPriority> priorities;
  final Set<TaskStatus> statuses;
  final Set<TaskSource> sources;
  final Set<String> courseIds;
  final bool includeNoCourse;
  final DuePeriod duePeriod;
  final DateTime? start;
  final DateTime? end;
  final String search;
  final bool includeOverdue;
  final bool includeNoDeadline;

  String encode() => jsonEncode({
    'categories': categories.toList(),
    'priorities': priorities.map((e) => e.name).toList(),
    'statuses': statuses.map((e) => e.name).toList(),
    'sources': sources.map((e) => e.name).toList(),
    'courseIds': courseIds.toList(),
    'includeNoCourse': includeNoCourse,
    'duePeriod': duePeriod.name,
    'start': start?.toIso8601String(),
    'end': end?.toIso8601String(),
    'search': search,
    'includeOverdue': includeOverdue,
    'includeNoDeadline': includeNoDeadline,
  });

  factory TaskFilter.decode(String value) {
    final json = jsonDecode(value) as Map<String, dynamic>;
    return TaskFilter(
      categories: (json['categories'] as List).cast<String>().toSet(),
      priorities: (json['priorities'] as List)
          .map((e) => parseTaskPriority(e as String))
          .toSet(),
      statuses: (json['statuses'] as List)
          .map((e) => parseTaskStatus(e as String))
          .toSet(),
      sources: json['sources'] is List
          ? (json['sources'] as List)
                .map((e) => TaskSource.values.byName(e as String))
                .toSet()
          : const {
              TaskSource.manual,
              TaskSource.eeclass,
              TaskSource.elearn,
            },
      courseIds: json['courseIds'] is List
          ? (json['courseIds'] as List).cast<String>().toSet()
          : const {},
      includeNoCourse: json['includeNoCourse'] as bool? ?? false,
      duePeriod: DuePeriod.values.byName(json['duePeriod'] as String),
      start: DateTime.tryParse(json['start'] as String? ?? ''),
      end: DateTime.tryParse(json['end'] as String? ?? ''),
      search: json['search'] as String? ?? '',
      includeOverdue: json['includeOverdue'] as bool? ?? true,
      includeNoDeadline: json['includeNoDeadline'] as bool? ?? true,
    );
  }

  TaskFilter withSearch(String value) => TaskFilter(
    categories: categories,
    priorities: priorities,
    statuses: statuses,
    sources: sources,
    courseIds: courseIds,
    includeNoCourse: includeNoCourse,
    duePeriod: duePeriod,
    start: start,
    end: end,
    search: value,
    includeOverdue: includeOverdue,
    includeNoDeadline: includeNoDeadline,
  );
}

List<TaskBundle> filterTasks(
  Iterable<TaskBundle> tasks,
  TaskFilter filter,
  DateTime now, {
  Map<String, String> courseNames = const {},
}) {
  final today = taskDay(now);
  final rangeStart = filter.duePeriod == DuePeriod.custom
      ? filter.start
      : today;
  final rangeEnd = switch (filter.duePeriod) {
    DuePeriod.any => null,
    DuePeriod.today => taskDayAfter(today, 1),
    DuePeriod.next3 => taskDayAfter(today, 3),
    DuePeriod.thisWeek => taskDayAfter(today, 8 - today.weekday),
    DuePeriod.next7 => taskDayAfter(today, 7),
    DuePeriod.next30 => taskDayAfter(today, 30),
    DuePeriod.custom =>
      filter.end == null ? null : taskDayAfter(filter.end!, 1),
  };
  final query = filter.search.trim().toLowerCase();
  final visible =
      tasks.where((bundle) {
        final task = bundle.task;
        if (task.deletedAt != null) return false;
        if (filter.categories.isNotEmpty &&
            !filter.categories.contains(task.category)) {
          return false;
        }
        if (filter.priorities.isNotEmpty &&
            !filter.priorities.contains(task.priority)) {
          return false;
        }
        if (!filter.statuses.contains(task.status)) return false;
        if (!filter.sources.contains(bundle.source)) return false;
        if (filter.courseIds.isNotEmpty || filter.includeNoCourse) {
          final courseId = task.courseId;
          if (courseId == null) {
            if (!filter.includeNoCourse) return false;
          } else if (!filter.courseIds.contains(courseId)) {
            return false;
          }
        }
        if (query.isNotEmpty &&
            !'${task.title} ${task.notes} ${task.category} ${courseNames[task.courseId] ?? ''}'
                .toLowerCase()
                .contains(query)) {
          return false;
        }
        if (task.deadline == null) return filter.includeNoDeadline;
        if (isTaskOverdue(task, now)) return filter.includeOverdue;
        if (filter.duePeriod != DuePeriod.any) {
          final day = taskDay(task.deadline!);
          if (rangeStart != null && day.isBefore(taskDay(rangeStart))) {
            return false;
          }
          if (rangeEnd != null && !day.isBefore(rangeEnd)) return false;
        }
        return true;
      }).toList()..sort((a, b) {
        final ad = effectiveDeadline(a.task), bd = effectiveDeadline(b.task);
        final date = ad == null
            ? (bd == null ? 0 : 1)
            : (bd == null ? -1 : ad.compareTo(bd));
        if (date != 0) return date;
        final priority = a.task.priority.index.compareTo(b.task.priority.index);
        return priority != 0 ? priority : a.task.title.compareTo(b.task.title);
      });
  return visible;
}

String agendaSection(TaskRecord task, DateTime now) {
  if (isTaskOverdue(task, now)) return 'Overdue';
  final date = task.deadline;
  if (date == null) return 'No Deadline';
  final day = taskDay(date), today = taskDay(now);
  if (day == today) return 'Today';
  if (day == taskDayAfter(today, 1)) return 'Tomorrow';
  if (day.isBefore(today)) {
    return 'Earlier'; // Explicitly included completed work.
  }
  if (day.isBefore(taskDayAfter(today, 8 - today.weekday))) return 'This Week';
  return 'Later';
}

/// Calendar arithmetic keeps local wall-clock time, including across DST.
/// Monthly occurrences retain the original day (Jan 31 -> Feb 28 -> Mar 31).
DateTime advanceRecurrence(
  DateTime anchor,
  RepeatUnit unit,
  int interval, {
  int? anchorDay,
}) {
  if (interval < 1) throw ArgumentError('Repeat interval must be positive.');
  if (unit == RepeatUnit.monthly) {
    final month = DateTime(anchor.year, anchor.month + interval);
    final lastDay = DateTime(month.year, month.month + 1, 0).day;
    final day = (anchorDay ?? anchor.day).clamp(1, lastDay);
    return DateTime(
      month.year,
      month.month,
      day,
      anchor.hour,
      anchor.minute,
      anchor.second,
    );
  }
  return DateTime(
    anchor.year,
    anchor.month,
    anchor.day + interval * (unit == RepeatUnit.weekly ? 7 : 1),
    anchor.hour,
    anchor.minute,
    anchor.second,
  );
}

String taskDateLabel(DateTime date, {bool time = false}) =>
    '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'
    '${time ? ' · ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}' : ''}';

const reminderPresets = <int, String>{
  0: 'At deadline',
  10: '10 minutes before',
  30: '30 minutes before',
  60: '1 hour before',
  180: '3 hours before',
  1440: '1 day before',
  4320: '3 days before',
  10080: '1 week before',
};

String recurrenceDescription(TaskRecord task) {
  if (task.repeatUnit == RepeatUnit.none) return 'Does not repeat.';
  final unit = switch (task.repeatUnit) {
    RepeatUnit.daily => 'day',
    RepeatUnit.weekly => 'week',
    RepeatUnit.monthly => 'month',
    RepeatUnit.none => '',
  };
  final anchor = task.deadline ?? task.createdAt;
  final next = advanceRecurrence(
    anchor,
    task.repeatUnit,
    task.repeatInterval,
    anchorDay: task.repeatAnchorDay,
  );
  return 'Every ${task.repeatInterval} $unit${task.repeatInterval == 1 ? '' : 's'}. '
      'When you complete this task, one new active task is created. '
      '${task.deadline == null ? 'Without a deadline, the reminder date (or creation date) sets the rhythm. The next task also has no deadline.' : 'For example, due ${taskDateLabel(anchor)} → next due ${taskDateLabel(next)}.'} '
      'Dates already past are skipped. Completed tasks stay in your history. '
      '${task.repeatUnit == RepeatUnit.monthly ? 'Short months use their last day, then return to the original day when possible.' : ''}';
}
