import 'academic_database.dart';
import '../domain/academic_types.dart';

class AcademicSnapshot {
  const AcademicSnapshot({
    required this.semesters,
    required this.categories,
    required this.courses,
    required this.meetings,
    required this.exceptions,
    required this.tags,
    required this.courseTags,
    required this.settings,
  });
  final List<Semester> semesters;
  final List<GraduationCategory> categories;
  final List<Course> courses;
  final List<ClassMeeting> meetings;
  final List<ScheduleException> exceptions;
  final List<Tag> tags;
  final List<CourseTag> courseTags;
  final AcademicSetting settings;

  Semester? get currentSemester =>
      semesters.where((s) => s.status == SemesterStatus.current).firstOrNull;
  List<Course> coursesIn(String semesterId) =>
      courses.where((c) => c.semesterId == semesterId).toList();
  List<ClassMeeting> meetingsFor(String courseId) =>
      meetings.where((m) => m.courseId == courseId).toList();
  List<String> tagsFor(String courseId) {
    final ids = courseTags
        .where((t) => t.courseId == courseId)
        .map((t) => t.tagId)
        .toSet();
    return tags.where((t) => ids.contains(t.id)).map((t) => t.name).toList();
  }
}
