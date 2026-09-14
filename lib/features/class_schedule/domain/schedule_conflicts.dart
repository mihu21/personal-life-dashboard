import 'dart:math' as math;

import '../data/academic_snapshot.dart';
import 'academic_types.dart';
import 'course_draft.dart';

class MeetingSlot {
  const MeetingSlot({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.day,
    required this.start,
    required this.end,
  });
  final String id;
  final String courseId;
  final String courseName;
  final int day;
  final int start;
  final int end;
}

class ScheduleConflict {
  const ScheduleConflict(this.first, this.second, this.minutes);
  final MeetingSlot first;
  final MeetingSlot second;
  final int minutes;
  String get description =>
      '${weekdayLabels[first.day - 1]} · $minutes minutes overlap\n'
      '${first.courseName}: ${timeLabel(first.start)}–${timeLabel(first.end)}\n'
      '${second.courseName}: ${timeLabel(second.start)}–${timeLabel(second.end)}';
}

List<ScheduleConflict> detectConflicts(List<MeetingSlot> slots) {
  final conflicts = <ScheduleConflict>[];
  for (var i = 0; i < slots.length; i++) {
    for (var j = i + 1; j < slots.length; j++) {
      final a = slots[i], b = slots[j];
      if (a.day != b.day) continue;
      final minutes =
          math.min<int>(a.end, b.end) - math.max<int>(a.start, b.start);
      if (minutes > 0) conflicts.add(ScheduleConflict(a, b, minutes));
    }
  }
  return conflicts;
}

List<MeetingSlot> semesterSlots(
  AcademicSnapshot data,
  String semesterId, {
  String? excludeCourseId,
}) {
  final courses = {
    for (final c
        in data
            .coursesIn(semesterId)
            .where(
              (c) =>
                  c.id != excludeCourseId &&
                  (c.status == CourseStatus.planned ||
                      c.status == CourseStatus.inProgress),
            ))
      c.id: c,
  };
  return [
    for (final m in data.meetings.where((m) => courses.containsKey(m.courseId)))
      MeetingSlot(
        id: m.id,
        courseId: m.courseId,
        courseName: courses[m.courseId]!.courseName,
        day: m.dayOfWeek,
        start: m.startTime,
        end: m.endTime,
      ),
  ];
}

List<ScheduleConflict> draftConflicts(
  AcademicSnapshot data,
  CourseDraft draft,
) {
  if (draft.status != CourseStatus.planned &&
      draft.status != CourseStatus.inProgress) {
    return [];
  }
  final id = draft.id ?? 'draft';
  final slots = [
    ...semesterSlots(data, draft.semesterId, excludeCourseId: draft.id),
    for (var i = 0; i < draft.meetings.length; i++)
      MeetingSlot(
        id: 'draft-$i',
        courseId: id,
        courseName: draft.name,
        day: draft.meetings[i].day,
        start: draft.meetings[i].start,
        end: draft.meetings[i].end,
      ),
  ];
  return detectConflicts(
    slots,
  ).where((c) => c.first.courseId == id || c.second.courseId == id).toList();
}
