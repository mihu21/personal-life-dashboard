import 'academic_types.dart';
import 'nthu_academic.dart';

class MeetingDraft {
  const MeetingDraft({
    this.id,
    required this.day,
    required this.start,
    required this.end,
    this.location,
    this.dayCode,
    this.startPeriod,
    this.endPeriod,
    this.needsReview = false,
  });
  final String? id;
  final int day;
  final int start;
  final int end;
  final String? location;
  final String? dayCode;
  final String? startPeriod;
  final String? endPeriod;
  final bool needsReview;

  factory MeetingDraft.nthu({
    String? id,
    required String dayCode,
    required String startPeriod,
    required String endPeriod,
    String? location,
  }) {
    final range = NthuPeriodRange(startPeriod, endPeriod);
    return MeetingDraft(
      id: id,
      day: nthuWeekday(dayCode)!,
      start: range.startMinute,
      end: range.endMinute,
      location: location,
      dayCode: dayCode,
      startPeriod: startPeriod,
      endPeriod: endPeriod,
    );
  }
}

class CourseDraft {
  const CourseDraft({
    this.id,
    required this.name,
    required this.credits,
    required this.semesterId,
    required this.categoryId,
    this.status = CourseStatus.inProgress,
    this.code = '',
    this.location,
    this.professor,
    this.notes,
    this.tags = const [],
    this.meetings = const [],
    this.catalogCourseId,
    this.englishName,
    this.teachingLanguage,
  });
  final String? id;
  final String name;
  final double credits;
  final String semesterId;
  final String categoryId;
  final CourseStatus status;
  final String code;
  final String? location;
  final String? professor;
  final String? notes;
  final List<String> tags;
  final List<MeetingDraft> meetings;
  final String? catalogCourseId;
  final String? englishName;
  final String? teachingLanguage;
}
