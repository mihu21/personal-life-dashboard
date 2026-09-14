import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/course_draft.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/schedule_conflicts.dart';

import 'academic_fixtures.dart';

void main() {
  MeetingSlot slot(String id, int start, int end, {int day = 2}) => MeetingSlot(
    id: id,
    courseId: id,
    courseName: id,
    day: day,
    start: start,
    end: end,
  );
  test(
    'interval overlaps include containment and all pairs, but not adjacency or different days',
    () {
      final conflicts = detectConflicts([
        slot('A', 800, 910),
        slot('B', 860, 1040),
        slot('C', 870, 880),
        slot('adjacent', 1040, 1100),
        slot('other day', 800, 910, day: 3),
      ]);
      expect(conflicts.length, 3);
      expect(conflicts.first.minutes, 50);
      expect(conflicts.map((c) => c.minutes), containsAll([10, 10]));
    },
  );

  test(
    'draft edits replace their own old meetings and isolate semester/status',
    () {
      final data = sampleAcademicData();
      CourseDraft draft({
        String? id,
        String semester = 'fall',
        CourseStatus status = CourseStatus.planned,
        List<MeetingDraft>? meetings,
      }) => CourseDraft(
        id: id,
        name: 'New',
        credits: 3,
        semesterId: semester,
        categoryId: 'core',
        status: status,
        meetings:
            meetings ?? [const MeetingDraft(day: 1, start: 590, end: 620)],
      );
      expect(draftConflicts(data, draft()).length, 2);
      expect(draftConflicts(data, draft(id: 'course-0')).length, 1);
      expect(draftConflicts(data, draft(semester: 'different')), isEmpty);
      expect(
        draftConflicts(data, draft(status: CourseStatus.withdrawn)),
        isEmpty,
      );
      expect(
        draftConflicts(
          data,
          draft(
            meetings: [
              const MeetingDraft(day: 2, start: 100, end: 200),
              const MeetingDraft(day: 2, start: 150, end: 250),
            ],
          ),
        ).length,
        1,
      );
    },
  );
}
