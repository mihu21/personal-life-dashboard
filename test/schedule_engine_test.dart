import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/course_draft.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/schedule_engine.dart';

void main() {
  late AcademicDatabase db;
  late AcademicRepository repo;
  late String semester;
  late String course;
  setUp(() async {
    db = AcademicDatabase(NativeDatabase.memory());
    repo = AcademicRepository(db);
    await repo.initialize();
    semester = await repo.saveSemester(
      name: 'Fall',
      academicYear: '2026',
      term: 'Fall',
      start: DateTime(2026, 9, 1),
      end: DateTime(2026, 12, 31),
      status: SemesterStatus.current,
    );
    final category = (await repo.snapshot()).categories.first.id;
    course = await repo.saveCourse(
      CourseDraft(
        name: 'Algebra',
        credits: 3,
        semesterId: semester,
        categoryId: category,
        location: 'Main room',
        meetings: const [
          MeetingDraft(day: 1, start: 540, end: 600),
          MeetingDraft(day: 1, start: 660, end: 720, location: 'Lab'),
        ],
      ),
    );
  });
  tearDown(() => db.close());

  test(
    'multiple meetings, location precedence, next/current and boundaries',
    () async {
      final data = await repo.snapshot();
      final classes = scheduleForDay(data, semester, DateTime(2026, 9, 7));
      expect(classes.length, 2);
      expect(classes.last.location, 'Lab');
      expect(classes.first.isCurrent(DateTime(2026, 9, 7, 9)), true);
      expect(classes.first.isCurrent(DateTime(2026, 9, 7, 10)), false);
      expect(nextClass(classes, DateTime(2026, 9, 7, 9, 30)), classes.last);
      expect(nextClass(classes, DateTime(2026, 9, 7, 12)), isNull);
      expect(freeTimeGaps(classes).single.minutes, 60);
      expect(scheduleForDay(data, semester, DateTime(2026, 8, 31)), isEmpty);
    },
  );

  test('cancellation affects only selected meeting on one date', () async {
    var data = await repo.snapshot();
    await repo.saveException(
      courseId: course,
      meetingId: data.meetings.first.id,
      date: DateTime(2026, 9, 7),
      type: ExceptionType.cancelled,
    );
    data = await repo.snapshot();
    expect(
      scheduleForDay(data, semester, DateTime(2026, 9, 7)).single.start,
      660,
    );
    expect(scheduleForDay(data, semester, DateTime(2026, 9, 14)).length, 2);
  });

  test(
    'rescheduling, location changes, extra classes and restoring exceptions',
    () async {
      var data = await repo.snapshot();
      await repo.saveException(
        courseId: course,
        meetingId: data.meetings.first.id,
        date: DateTime(2026, 9, 7),
        type: ExceptionType.rescheduled,
        start: 780,
        end: 840,
        location: 'New room',
      );
      await repo.saveException(
        courseId: course,
        meetingId: data.meetings.last.id,
        date: DateTime(2026, 9, 7),
        type: ExceptionType.locationChanged,
        location: 'Annex',
      );
      await repo.saveException(
        courseId: course,
        date: DateTime(2026, 9, 12),
        type: ExceptionType.extraClass,
        start: 540,
        end: 600,
      );
      data = await repo.snapshot();
      final monday = scheduleForDay(data, semester, DateTime(2026, 9, 7));
      expect(monday.last.start, 780);
      expect(monday.last.location, 'New room');
      expect(monday.first.location, 'Annex');
      expect(scheduleForDay(data, semester, DateTime(2026, 9, 12)).length, 1);
      await repo.removeException(data.exceptions.first.id);
      expect(
        scheduleForDay(
          await repo.snapshot(),
          semester,
          DateTime(2026, 9, 7),
        ).first.start,
        540,
      );
    },
  );

  test('exception validation and withdrawn courses', () async {
    final data = await repo.snapshot();
    await expectLater(
      repo.saveException(
        courseId: course,
        meetingId: data.meetings.first.id,
        date: DateTime(2026, 9, 8),
        type: ExceptionType.cancelled,
      ),
      throwsArgumentError,
    );
    await expectLater(
      repo.saveException(
        courseId: course,
        date: DateTime(2027, 1, 2),
        type: ExceptionType.extraClass,
        start: 540,
        end: 600,
      ),
      throwsArgumentError,
    );
    await repo.setCourseStatus(course, CourseStatus.withdrawn);
    expect(
      scheduleForDay(await repo.snapshot(), semester, DateTime(2026, 9, 7)),
      isEmpty,
    );
  });

  test('short NTHU transition breaks are not reported as free time', () async {
    final original = scheduleForDay(
      await repo.snapshot(),
      semester,
      DateTime(2026, 9, 7),
    ).first;
    ClassOccurrence item(int start, int end) => ClassOccurrence(
      id: '$start',
      course: original.course,
      date: original.date,
      start: start,
      end: end,
      location: 'Room',
    );

    expect(
      freeTimeGaps([
        item(8 * 60, 8 * 60 + 50),
        item(9 * 60, 9 * 60 + 50),
        item(10 * 60 + 10, 11 * 60),
      ]),
      isEmpty,
    );

    final realGap = freeTimeGaps([
      item(8 * 60, 8 * 60 + 50),
      item(10 * 60 + 10, 11 * 60),
    ]).single;
    expect(realGap.start, 8 * 60 + 50);
    expect(realGap.end, 10 * 60 + 10);
  });

  test(
    'gaps merge overlapping intervals and exclude adjacent boundaries',
    () async {
      final original = scheduleForDay(
        await repo.snapshot(),
        semester,
        DateTime(2026, 9, 7),
      ).first;
      ClassOccurrence item(int start, int end) => ClassOccurrence(
        id: '$start',
        course: original.course,
        date: original.date,
        start: start,
        end: end,
        location: 'Room',
      );
      final gaps = freeTimeGaps([
        item(540, 660),
        item(550, 600),
        item(660, 720),
        item(780, 840),
      ]);
      expect(gaps.single.start, 720);
      expect(gaps.single.end, 780);
    },
  );
}
