import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';

AcademicSnapshot sampleAcademicData() {
  final stamp = DateTime(2026, 9, 1);
  final courses = [
    for (var i = 0; i < 3; i++)
      Course(
        id: 'course-$i',
        courseCode: 'CS$i',
        courseName: ['Algebra', 'Networks', 'Programming'][i],
        credits: 3,
        semesterId: 'fall',
        graduationCategoryId: 'core',
        status: CourseStatus.inProgress,
        location: 'Room ${100 + i}',
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
      for (var i = 0; i < 3; i++)
        ClassMeeting(
          id: 'meeting-$i',
          courseId: courses[i].id,
          dayOfWeek: 1,
          startTime: [540, 570, 780][i],
          endTime: [600, 660, 840][i],
          needsReview: false,
          createdAt: stamp,
          updatedAt: stamp,
        ),
    ],
    exceptions: [],
    tags: [],
    courseTags: [],
    settings: emptyAcademicData().settings,
  );
}

AcademicSnapshot planningAcademicData() {
  final data = sampleAcademicData();
  return AcademicSnapshot(
    semesters: [data.semesters.single.copyWith(status: SemesterStatus.planned)],
    courses: data.courses
        .map((c) => c.copyWith(status: CourseStatus.planned))
        .toList(),
    categories: data.categories,
    meetings: data.meetings,
    exceptions: [],
    tags: [],
    courseTags: [],
    settings: data.settings,
  );
}

AcademicSnapshot emptyAcademicData() => AcademicSnapshot(
  semesters: [],
  categories: [],
  courses: [],
  meetings: [],
  exceptions: [],
  tags: [],
  courseTags: [],
  settings: AcademicSetting(
    id: 'academic',
    createdAt: DateTime(2026),
    updatedAt: DateTime(2026),
    setupDismissed: true,
  ),
);
