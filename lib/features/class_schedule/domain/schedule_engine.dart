import 'dart:math' as math;

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import 'academic_types.dart';
import 'nthu_academic.dart';

DateTime calendarDay(DateTime date, int delta) =>
    DateTime(date.year, date.month, date.day + delta);
DateTime weekStart(DateTime date) =>
    calendarDay(dateOnly(date), 1 - date.weekday);

class ClassOccurrence {
  const ClassOccurrence({
    required this.id,
    required this.course,
    required this.date,
    required this.start,
    required this.end,
    required this.location,
    this.exception,
  });
  final String id;
  final Course course;
  final DateTime date;
  final int start;
  final int end;
  final String location;
  final ScheduleException? exception;
  DateTime get startsAt =>
      DateTime(date.year, date.month, date.day, start ~/ 60, start % 60);
  DateTime get endsAt =>
      DateTime(date.year, date.month, date.day, end ~/ 60, end % 60);
  bool isCurrent(DateTime now) =>
      !now.isBefore(startsAt) && now.isBefore(endsAt);
  bool isFinished(DateTime now) => !now.isBefore(endsAt);
}

class FreeGap {
  const FreeGap(this.start, this.end);
  final int start;
  final int end;
  int get minutes => end - start;
}

List<ClassOccurrence> scheduleForDay(
  AcademicSnapshot data,
  String semesterId,
  DateTime date,
) {
  final day = dateOnly(date);
  final semester = data.semesters.where((s) => s.id == semesterId).firstOrNull;
  if (semester == null ||
      day.isBefore(semester.startDate) ||
      day.isAfter(semester.endDate)) {
    return [];
  }
  final courses = {
    for (final c
        in data
            .coursesIn(semesterId)
            .where(
              (c) =>
                  c.status != CourseStatus.withdrawn &&
                  c.status != CourseStatus.failed,
            ))
      c.id: c,
  };
  final exceptions = data.exceptions
      .where((e) => dateOnly(e.date) == day)
      .toList();
  final result = <ClassOccurrence>[];
  for (final m in data.meetings.where(
    (m) => m.dayOfWeek == day.weekday && courses.containsKey(m.courseId),
  )) {
    final course = courses[m.courseId]!;
    final exception = exceptions
        .where((e) => e.meetingId == m.id && e.type != ExceptionType.extraClass)
        .firstOrNull;
    if (exception?.type == ExceptionType.cancelled) continue;
    result.add(
      ClassOccurrence(
        id: m.id,
        course: course,
        date: day,
        start: exception?.type == ExceptionType.rescheduled
            ? exception!.replacementStartTime!
            : m.startTime,
        end: exception?.type == ExceptionType.rescheduled
            ? exception!.replacementEndTime!
            : m.endTime,
        location: _location([
          exception?.replacementLocation,
          m.locationOverride,
          course.location,
        ]),
        exception: exception,
      ),
    );
  }
  for (final e in exceptions.where(
    (e) =>
        e.type == ExceptionType.extraClass && courses.containsKey(e.courseId),
  )) {
    final course = courses[e.courseId]!;
    result.add(
      ClassOccurrence(
        id: e.id,
        course: course,
        date: day,
        start: e.replacementStartTime!,
        end: e.replacementEndTime!,
        location: _location([e.replacementLocation, course.location]),
        exception: e,
      ),
    );
  }
  result.sort((a, b) {
    final time = a.start.compareTo(b.start);
    return time != 0
        ? time
        : a.course.courseName.compareTo(b.course.courseName);
  });
  return result;
}

String _location(List<String?> values) =>
    values.whereType<String>().where((v) => v.trim().isNotEmpty).firstOrNull ??
    'Location not set';

List<FreeGap> freeTimeGaps(List<ClassOccurrence> classes) {
  final sorted = [...classes]..sort((a, b) => a.start.compareTo(b.start));
  if (sorted.isEmpty) return [];
  final result = <FreeGap>[];
  var end = sorted.first.end;
  for (final c in sorted.skip(1)) {
    if (c.start > end && containsWholeNthuPeriod(end, c.start)) {
      result.add(FreeGap(end, c.start));
    }
    end = math.max(end, c.end);
  }
  return result;
}

ClassOccurrence? nextClass(List<ClassOccurrence> classes, DateTime now) =>
    (classes.where((c) => c.startsAt.isAfter(now)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)))
        .firstOrNull;

String gapLabel(FreeGap gap) => '${gap.minutes ~/ 60}h ${gap.minutes % 60}m';
