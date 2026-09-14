import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/one_time_event.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/week_timetable.dart';

AcademicSnapshot overlapAcademicData() {
  final stamp = DateTime(2026, 9, 1);
  final courses = [
    Course(
      id: 'overlap-a',
      courseCode: 'A',
      courseName: 'Overlap A',
      credits: 3,
      semesterId: 'fall',
      graduationCategoryId: 'core',
      status: CourseStatus.inProgress,
      location: 'Room A',
      createdAt: stamp,
      updatedAt: stamp,
    ),
    Course(
      id: 'overlap-b',
      courseCode: 'B',
      courseName: 'Overlap B',
      credits: 3,
      semesterId: 'fall',
      graduationCategoryId: 'core',
      status: CourseStatus.inProgress,
      location: 'Room B',
      createdAt: stamp,
      updatedAt: stamp,
    ),
    Course(
      id: 'standalone',
      courseCode: 'M',
      courseName: 'Mandarin Intermediate II',
      credits: 2,
      semesterId: 'fall',
      graduationCategoryId: 'core',
      status: CourseStatus.inProgress,
      location: 'Room M',
      createdAt: stamp,
      updatedAt: stamp,
    ),
  ];

  return AcademicSnapshot(
    semesters: [
      Semester(
        id: 'fall',
        name: '2026 Fall',
        academicYear: '2026',
        term: 'Fall',
        startDate: stamp,
        endDate: DateTime(2026, 12, 31),
        status: SemesterStatus.current,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ],
    categories: [
      GraduationCategory(
        id: 'core',
        name: 'Core',
        requiredCredits: 24,
        sortOrder: 0,
        isActive: true,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ],
    courses: courses,
    meetings: [
      ClassMeeting(
        id: 'overlap-meeting-a',
        courseId: 'overlap-a',
        dayOfWeek: 4,
        startTime: 9 * 60,
        endTime: 11 * 60,
        needsReview: false,
        createdAt: stamp,
        updatedAt: stamp,
      ),
      ClassMeeting(
        id: 'overlap-meeting-b',
        courseId: 'overlap-b',
        dayOfWeek: 4,
        startTime: 10 * 60 + 10,
        endTime: 12 * 60,
        needsReview: false,
        createdAt: stamp,
        updatedAt: stamp,
      ),
      ClassMeeting(
        id: 'standalone-meeting',
        courseId: 'standalone',
        dayOfWeek: 4,
        startTime: 18 * 60 + 30,
        endTime: 20 * 60 + 20,
        needsReview: false,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ],
    exceptions: [],
    tags: [],
    courseTags: [],
    settings: AcademicSetting(
      id: 'academic',
      createdAt: stamp,
      updatedAt: stamp,
      setupDismissed: true,
    ),
  );
}

void main() {
  testWidgets(
    'standalone class uses full day width after an earlier overlap group',
    (tester) async {
      final data = overlapAcademicData();
      final date = DateTime(2026, 9, 14);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 1000,
              height: 900,
              child: WeekTimetable(
                data: data,
                semesterId: 'fall',
                date: date,
                now: date,
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final firstOverlap = tester.getRect(
        find.byKey(const ValueKey('week-occurrence-overlap-meeting-a')),
      );
      final secondOverlap = tester.getRect(
        find.byKey(const ValueKey('week-occurrence-overlap-meeting-b')),
      );
      final standalone = tester.getRect(
        find.byKey(const ValueKey('week-occurrence-standalone-meeting')),
      );

      expect(firstOverlap.width, closeTo(secondOverlap.width, 1));
      expect(standalone.width, greaterThan(firstOverlap.width * 1.8));
      final dayWidths = [
        for (var i = 0; i < 7; i++)
          tester.getSize(find.byKey(ValueKey('week-day-header-$i'))).width,
      ];
      for (final dayWidth in dayWidths.skip(1)) {
        expect(dayWidth, closeTo(dayWidths.first, .01));
      }
      expect(
        find.descendant(
          of: find.byType(WeekTimetable),
          matching: find.byType(Scrollable),
        ),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('events share conflict lanes and Saturday remains visible', (
    tester,
  ) async {
    final data = overlapAcademicData();
    final date = DateTime(2026, 9, 14);
    final stamp = DateTime(2026, 9, 1);
    final events = [
      OneTimeEvent(
        id: 'thursday-event',
        title: 'Thursday event',
        date: DateTime(2026, 9, 17),
        startPeriod: '2',
        endPeriod: '2',
        createdAt: stamp,
        updatedAt: stamp,
      ),
      OneTimeEvent(
        id: 'saturday-event',
        title: 'Saturday event',
        date: DateTime(2026, 9, 19),
        startPeriod: '3',
        endPeriod: '4',
        specificTime: '10:20–11:45',
        createdAt: stamp,
        updatedAt: stamp,
      ),
      OneTimeEvent(
        id: 'sunday-event',
        title: 'Sunday event',
        date: DateTime(2026, 9, 20),
        startPeriod: '5',
        endPeriod: '5',
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 1000,
            height: 900,
            child: WeekTimetable(
              data: data,
              semesterId: 'fall',
              date: date,
              now: date,
              events: events,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final overlap = tester.getRect(
      find.byKey(const ValueKey('week-occurrence-overlap-meeting-a')),
    );
    final event = tester.getRect(
      find.byKey(const ValueKey('week-event-thursday-event')),
    );
    final standalone = tester.getRect(
      find.byKey(const ValueKey('week-occurrence-standalone-meeting')),
    );

    expect(event.width, closeTo(overlap.width, 1));
    expect(standalone.width, greaterThan(event.width * 1.8));
    expect(find.text('Saturday event'), findsOneWidget);
    expect(find.text('Sunday event'), findsOneWidget);
    expect(find.textContaining('Sat  9/19'), findsOneWidget);
    expect(find.textContaining('Sun  9/20'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
