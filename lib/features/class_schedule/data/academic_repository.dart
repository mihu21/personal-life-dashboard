import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../domain/academic_types.dart';
import '../domain/course_draft.dart';
import 'academic_database.dart';
import 'academic_snapshot.dart';

class _DefaultGraduationCategory {
  const _DefaultGraduationCategory({
    required this.id,
    required this.name,
    required this.sortOrder,
    this.requiredCredits,
    this.isActive = true,
  });

  final String id;
  final String name;
  final double? requiredCredits;
  final String description = '';
  final int sortOrder;
  final bool isActive;
}

const _defaultGraduationCategories = <_DefaultGraduationCategory>[
  _DefaultGraduationCategory(
    id: '5a0c9cf4-278f-43d2-8df1-922f2119d460',
    name: 'Chinese',
    requiredCredits: 8.0,
    sortOrder: 0,
  ),
  _DefaultGraduationCategory(
    id: 'd96afc50-8bd8-4526-9267-c1d0b248b978',
    name: 'General Education',
    requiredCredits: 20.0,
    sortOrder: 1,
  ),
  _DefaultGraduationCategory(
    id: '70b11764-589c-47ec-a0f3-f51fa9bb4f9e',
    name: 'Physical Education',
    sortOrder: 2,
  ),
  _DefaultGraduationCategory(
    id: '2372452d-3a7a-480e-a8d5-e46a8114e1f7',
    name: 'Department Required',
    requiredCredits: 18.0,
    sortOrder: 3,
  ),
  _DefaultGraduationCategory(
    id: '74dc6526-6ed8-4551-8448-2d41f5874ecd',
    name: 'Basic Core',
    requiredCredits: 12.0,
    sortOrder: 4,
  ),
  _DefaultGraduationCategory(
    id: '4a48d632-381d-475b-aa9e-d938f18a6294',
    name: 'Core',
    requiredCredits: 12.0,
    sortOrder: 5,
  ),
  _DefaultGraduationCategory(
    id: '83644351-7686-48c8-a94e-eb7d7dc144fd',
    name: 'Lab',
    requiredCredits: 4.0,
    sortOrder: 6,
  ),
  _DefaultGraduationCategory(
    id: '4de84f88-22ae-4c49-baf9-e463ccf6d443',
    name: 'Professional Course',
    requiredCredits: 24.0,
    sortOrder: 7,
  ),
  _DefaultGraduationCategory(
    id: '0d19167e-7753-42c3-9677-fc01b2d2bd6c',
    name: 'Free Elective',
    requiredCredits: 30.0,
    sortOrder: 8,
  ),
  _DefaultGraduationCategory(
    id: '2bf8f749-83f9-4f38-a5c2-88ee3a2644dd',
    name: 'Others',
    sortOrder: 9,
    isActive: false,
  ),
];

class AcademicRepository {
  AcademicRepository(this.db);
  final AcademicDatabase db;
  static const _uuid = Uuid();

  Future<void> initialize() => db.transaction(() async {
    final settings = await db.select(db.academicSettings).getSingleOrNull();
    if (settings == null) {
      await db
          .into(db.academicSettings)
          .insert(
            AcademicSettingsCompanion.insert(
              id: 'academic',
              requiredCredits: const Value(128.0),
            ),
          );
    }

    final existing = await (db.select(
      db.graduationCategories,
    )..where((t) => t.deletedAt.isNull())).get();
    if (existing.isEmpty) {
      // Fresh installations start from the graduation requirements exported
      // from the owner's current dashboard. Existing installations are never
      // rewritten here because this block only runs with no active categories.
      for (final category in _defaultGraduationCategories) {
        await db
            .into(db.graduationCategories)
            .insert(
              GraduationCategoriesCompanion.insert(
                id: category.id,
                name: category.name,
                requiredCredits: Value(category.requiredCredits),
                description: Value(category.description),
                sortOrder: Value(category.sortOrder),
                isActive: Value(category.isActive),
              ),
            );
      }
      return;
    }

    final hasFreeElective = existing.any(
      (category) => _isFreeElectiveName(category.name),
    );
    if (!hasFreeElective) {
      final maxSort = existing.fold<int>(
        -1,
        (value, category) =>
            category.sortOrder > value ? category.sortOrder : value,
      );
      await db
          .into(db.graduationCategories)
          .insert(
            GraduationCategoriesCompanion.insert(
              id: _uuid.v4(),
              name: 'Free Elective',
              sortOrder: Value(maxSort + 1),
            ),
          );
    }
  });

  Stream<AcademicSnapshot> watch() => db
      .customSelect(
        'SELECT 1',
        readsFrom: {
          db.semesters,
          db.graduationCategories,
          db.courses,
          db.classMeetings,
          db.scheduleExceptions,
          db.tags,
          db.courseTags,
          db.academicSettings,
        },
      )
      .watch()
      .asyncMap((_) => snapshot());

  Future<AcademicSnapshot> snapshot() => db.transaction(
    () async => AcademicSnapshot(
      semesters:
          await (db.select(db.semesters)
                ..where((t) => t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
              .get(),
      categories:
          await (db.select(db.graduationCategories)
                ..where((t) => t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.asc(t.sortOrder)]))
              .get(),
      courses:
          await (db.select(db.courses)
                ..where((t) => t.deletedAt.isNull())
                ..orderBy([(t) => OrderingTerm.asc(t.courseName)]))
              .get(),
      meetings: await (db.select(
        db.classMeetings,
      )..where((t) => t.deletedAt.isNull())).get(),
      exceptions: await (db.select(
        db.scheduleExceptions,
      )..where((t) => t.deletedAt.isNull())).get(),
      tags: await (db.select(
        db.tags,
      )..where((t) => t.deletedAt.isNull())).get(),
      courseTags: await (db.select(
        db.courseTags,
      )..where((t) => t.deletedAt.isNull())).get(),
      settings: await db.select(db.academicSettings).getSingle(),
    ),
  );

  Future<String> saveSemester({
    String? id,
    required String name,
    required String academicYear,
    required String term,
    required DateTime start,
    required DateTime end,
    required SemesterStatus status,
    String? nthuTermCode,
  }) async {
    _require(name.trim().isNotEmpty, 'Semester name is required.');
    _require(
      !dateOnly(end).isBefore(dateOnly(start)),
      'Semester end must follow its start.',
    );
    final key = id ?? _uuid.v4();
    final existingSemester = id == null
        ? null
        : await (db.select(
            db.semesters,
          )..where((t) => t.id.equals(id))).getSingleOrNull();
    final resolvedNthuTermCode = nthuTermCode ?? existingSemester?.nthuTermCode;
    await db.transaction(() async {
      if (status == SemesterStatus.current) {
        await (db.update(db.semesters)..where(
              (t) =>
                  t.status.equalsValue(SemesterStatus.current) &
                  t.id.equals(key).not(),
            ))
            .write(
              SemestersCompanion(
                status: const Value(SemesterStatus.completed),
                updatedAt: Value(DateTime.now()),
              ),
            );
      }
      await db
          .into(db.semesters)
          .insertOnConflictUpdate(
            SemestersCompanion.insert(
              id: key,
              name: name.trim(),
              academicYear: academicYear.trim(),
              term: term.trim(),
              startDate: dateOnly(start),
              endDate: dateOnly(end),
              status: status,
              nthuTermCode: Value(resolvedNthuTermCode),
              updatedAt: Value(DateTime.now()),
            ),
          );
    });
    return key;
  }

  Future<void> removeSemester(
    String id, {
    bool confirmed = false,
  }) => db.transaction(() async {
    final courses = await (db.select(
      db.courses,
    )..where((t) => t.semesterId.equals(id) & t.deletedAt.isNull())).get();
    _require(
      courses.isEmpty || confirmed,
      'Confirm deletion of this semester and its courses. Archiving preserves history.',
    );
    for (final course in courses) {
      await removeCourse(course.id);
    }
    await (db.update(db.semesters)..where((t) => t.id.equals(id))).write(
      SemestersCompanion(
        deletedAt: Value(DateTime.now()),
        updatedAt: Value(DateTime.now()),
      ),
    );
  });

  Future<String> saveCategory({
    String? id,
    required String name,
    double? requiredCredits,
    String? description,
    int sortOrder = 0,
    bool isActive = true,
  }) async {
    _require(name.trim().isNotEmpty, 'Category name is required.');
    _credits(requiredCredits);
    final key = id ?? _uuid.v4();
    final existingCategory = id == null
        ? null
        : await (db.select(
            db.graduationCategories,
          )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (existingCategory != null &&
        _isFreeElectiveName(existingCategory.name)) {
      _require(
        _isFreeElectiveName(name),
        'Free Elective is required for overflow credits and cannot be renamed.',
      );
    }
    if (_isFreeElectiveName(name)) {
      final duplicate = await (db.select(
        db.graduationCategories,
      )..where((t) => t.id.equals(key).not() & t.deletedAt.isNull())).get();
      _require(
        !duplicate.any((category) => _isFreeElectiveName(category.name)),
        'A Free Elective category already exists.',
      );
    }
    await db
        .into(db.graduationCategories)
        .insertOnConflictUpdate(
          GraduationCategoriesCompanion.insert(
            id: key,
            name: name.trim(),
            requiredCredits: Value(requiredCredits),
            description: Value(description),
            sortOrder: Value(sortOrder),
            isActive: Value(isActive),
            updatedAt: Value(DateTime.now()),
          ),
        );
    return key;
  }

  Future<void> removeCategory(String id) => db.transaction(() async {
    final category = await (db.select(
      db.graduationCategories,
    )..where((t) => t.id.equals(id) & t.deletedAt.isNull())).getSingleOrNull();
    _require(category != null, 'Category no longer exists.');
    _require(
      !_isFreeElectiveName(category!.name),
      'Free Elective is required for overflow credits and cannot be deleted.',
    );

    final assignedCourses =
        await (db.select(db.courses)..where(
              (t) => t.graduationCategoryId.equals(id) & t.deletedAt.isNull(),
            ))
            .get();
    _require(
      assignedCourses.isEmpty,
      'Reassign courses in this category before deleting it.',
    );

    final now = DateTime.now();
    await (db.update(
      db.graduationCategories,
    )..where((t) => t.id.equals(id))).write(
      GraduationCategoriesCompanion(
        deletedAt: Value(now),
        updatedAt: Value(now),
      ),
    );
  });

  Future<void> reorderCategories(List<String> ids) => db.transaction(() async {
    for (var i = 0; i < ids.length; i++) {
      await (db.update(
        db.graduationCategories,
      )..where((t) => t.id.equals(ids[i]))).write(
        GraduationCategoriesCompanion(
          sortOrder: Value(i),
          updatedAt: Value(DateTime.now()),
        ),
      );
    }
  });

  Future<void> saveSettings({
    double? requiredCredits,
    bool? setupDismissed,
  }) async {
    _credits(requiredCredits);
    await (db.update(
      db.academicSettings,
    )..where((t) => t.id.equals('academic'))).write(
      AcademicSettingsCompanion(
        requiredCredits: Value(requiredCredits),
        setupDismissed: setupDismissed == null
            ? const Value.absent()
            : Value(setupDismissed),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  Future<String> saveCourse(CourseDraft draft) => db.transaction(() async {
    _require(draft.name.trim().isNotEmpty, 'Course name is required.');
    _require(
      draft.credits.isFinite && draft.credits >= 0,
      'Credits cannot be negative.',
    );
    _require(
      await (db.select(db.semesters)..where(
                (t) => t.id.equals(draft.semesterId) & t.deletedAt.isNull(),
              ))
              .getSingleOrNull() !=
          null,
      'Select an existing semester.',
    );
    _require(
      await (db.select(db.graduationCategories)..where(
                (t) => t.id.equals(draft.categoryId) & t.deletedAt.isNull(),
              ))
              .getSingleOrNull() !=
          null,
      'Select an existing category.',
    );
    for (final m in draft.meetings) {
      _require(m.day >= 1 && m.day <= 7, 'Choose a valid weekday.');
      _interval(m.start, m.end);
    }
    final key = draft.id ?? _uuid.v4();
    final now = DateTime.now();
    await db
        .into(db.courses)
        .insertOnConflictUpdate(
          CoursesCompanion.insert(
            id: key,
            courseName: draft.name.trim(),
            credits: draft.credits,
            semesterId: draft.semesterId,
            graduationCategoryId: draft.categoryId,
            status: draft.status,
            courseCode: Value(draft.code.trim()),
            location: Value(draft.location),
            professor: Value(draft.professor),
            notes: Value(draft.notes),
            catalogCourseId: Value(draft.catalogCourseId),
            englishName: Value(draft.englishName),
            teachingLanguage: Value(draft.teachingLanguage),
            updatedAt: Value(now),
          ),
        );
    final existing = await (db.select(
      db.classMeetings,
    )..where((t) => t.courseId.equals(key))).get();
    final keep = draft.meetings.map((m) => m.id).whereType<String>().toSet();
    for (final meeting in existing.where((m) => !keep.contains(m.id))) {
      await (db.update(
        db.classMeetings,
      )..where((t) => t.id.equals(meeting.id))).write(
        ClassMeetingsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
      );
      await (db.update(
        db.scheduleExceptions,
      )..where((t) => t.meetingId.equals(meeting.id))).write(
        ScheduleExceptionsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    }
    for (final m in draft.meetings) {
      _require(
        m.id == null || existing.any((e) => e.id == m.id),
        'Meeting belongs to another course.',
      );
      await db
          .into(db.classMeetings)
          .insertOnConflictUpdate(
            ClassMeetingsCompanion.insert(
              id: m.id ?? _uuid.v4(),
              courseId: key,
              dayOfWeek: m.day,
              startTime: m.start,
              endTime: m.end,
              locationOverride: Value(m.location),
              dayCode: Value(m.dayCode),
              startPeriod: Value(m.startPeriod),
              endPeriod: Value(m.endPeriod),
              needsReview: Value(m.needsReview),
              updatedAt: Value(now),
              deletedAt: const Value(null),
            ),
          );
    }
    await (db.update(
      db.courseTags,
    )..where((t) => t.courseId.equals(key))).write(
      CourseTagsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    for (final name
        in draft.tags.map((t) => t.trim()).where((t) => t.isNotEmpty).toSet()) {
      final tag =
          await (db.select(db.tags)
                ..where((t) => t.name.lower().equals(name.toLowerCase())))
              .getSingleOrNull();
      final tagId = tag?.id ?? _uuid.v4();
      if (tag == null) {
        await db
            .into(db.tags)
            .insert(TagsCompanion.insert(id: tagId, name: name));
      }
      final link =
          await (db.select(db.courseTags)
                ..where((t) => t.courseId.equals(key) & t.tagId.equals(tagId)))
              .getSingleOrNull();
      await db
          .into(db.courseTags)
          .insertOnConflictUpdate(
            CourseTagsCompanion.insert(
              id: link?.id ?? _uuid.v4(),
              courseId: key,
              tagId: tagId,
              deletedAt: const Value(null),
              updatedAt: Value(now),
            ),
          );
    }
    return key;
  });

  Future<void> setCourseStatus(String id, CourseStatus status) =>
      (db.update(db.courses)..where((t) => t.id.equals(id))).write(
        CoursesCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now()),
        ),
      );

  Future<void> removeCourse(String id) => db.transaction(() async {
    final now = DateTime.now();
    await (db.update(db.courses)..where((t) => t.id.equals(id))).write(
      CoursesCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (db.update(
      db.classMeetings,
    )..where((t) => t.courseId.equals(id))).write(
      ClassMeetingsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (db.update(
      db.scheduleExceptions,
    )..where((t) => t.courseId.equals(id))).write(
      ScheduleExceptionsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
    await (db.update(db.courseTags)..where((t) => t.courseId.equals(id))).write(
      CourseTagsCompanion(deletedAt: Value(now), updatedAt: Value(now)),
    );
  });

  Future<String> duplicateCourse(String id, String semesterId) async {
    final data = await snapshot();
    final course = data.courses.firstWhere((c) => c.id == id);
    final semester = data.semesters.firstWhere((s) => s.id == semesterId);
    return saveCourse(
      CourseDraft(
        name: course.courseName,
        credits: course.credits,
        semesterId: semesterId,
        categoryId: course.graduationCategoryId,
        status: semester.status == SemesterStatus.planned
            ? CourseStatus.planned
            : CourseStatus.inProgress,
        code: course.courseCode,
        location: course.location,
        professor: course.professor,
        notes: course.notes,
        catalogCourseId: course.catalogCourseId,
        englishName: course.englishName,
        teachingLanguage: course.teachingLanguage,
        tags: data.tagsFor(id),
        meetings: data
            .meetingsFor(id)
            .map(
              (m) => MeetingDraft(
                day: m.dayOfWeek,
                start: m.startTime,
                end: m.endTime,
                location: m.locationOverride,
                dayCode: m.dayCode,
                startPeriod: m.startPeriod,
                endPeriod: m.endPeriod,
                needsReview: m.needsReview,
              ),
            )
            .toList(),
      ),
    );
  }

  Future<void> saveException({
    String? id,
    required String courseId,
    String? meetingId,
    required DateTime date,
    required ExceptionType type,
    int? start,
    int? end,
    String? dayCode,
    String? startPeriod,
    String? endPeriod,
    String? location,
    String? note,
  }) => db.transaction(() async {
    final course =
        await (db.select(db.courses)
              ..where((t) => t.id.equals(courseId) & t.deletedAt.isNull()))
            .getSingleOrNull();
    _require(course != null, 'Course no longer exists.');
    final semester = await (db.select(
      db.semesters,
    )..where((t) => t.id.equals(course!.semesterId))).getSingle();
    final day = dateOnly(date);
    _require(
      !day.isBefore(semester.startDate) && !day.isAfter(semester.endDate),
      'Exception date must be inside the semester.',
    );
    if (type != ExceptionType.extraClass) {
      _require(meetingId != null, 'Select the weekly meeting to change.');
      final meeting =
          await (db.select(db.classMeetings)..where(
                (t) =>
                    t.id.equals(meetingId!) &
                    t.courseId.equals(courseId) &
                    t.deletedAt.isNull(),
              ))
              .getSingleOrNull();
      _require(
        meeting != null && meeting.dayOfWeek == day.weekday,
        'The selected meeting does not occur on this date.',
      );
      final duplicate =
          await (db.select(db.scheduleExceptions)..where(
                (t) =>
                    t.meetingId.equals(meetingId!) &
                    t.date.equals(day) &
                    t.deletedAt.isNull(),
              ))
              .get();
      _require(
        duplicate.every((e) => e.id == id),
        'Edit the existing exception for this meeting and date.',
      );
    }
    if (type == ExceptionType.rescheduled || type == ExceptionType.extraClass) {
      _require(start != null && end != null, 'Replacement times are required.');
      _interval(start!, end!);
    }
    if (type == ExceptionType.locationChanged) {
      _require(
        location?.trim().isNotEmpty ?? false,
        'Replacement location is required.',
      );
    }
    await db
        .into(db.scheduleExceptions)
        .insertOnConflictUpdate(
          ScheduleExceptionsCompanion.insert(
            id: id ?? _uuid.v4(),
            courseId: courseId,
            meetingId: Value(
              type == ExceptionType.extraClass ? null : meetingId,
            ),
            date: day,
            type: type,
            replacementStartTime: Value(start),
            replacementEndTime: Value(end),
            replacementDayCode: Value(dayCode),
            replacementStartPeriod: Value(startPeriod),
            replacementEndPeriod: Value(endPeriod),
            replacementLocation: Value(location),
            note: Value(note),
            updatedAt: Value(DateTime.now()),
          ),
        );
  });

  Future<void> removeException(String id) =>
      (db.update(db.scheduleExceptions)..where((t) => t.id.equals(id))).write(
        ScheduleExceptionsCompanion(
          deletedAt: Value(DateTime.now()),
          updatedAt: Value(DateTime.now()),
        ),
      );

  static bool _isFreeElectiveName(String name) =>
      name.trim().toLowerCase() == 'free elective';

  static void _interval(int start, int end) => _require(
    start >= 0 && end <= 1440 && end > start,
    'End time must follow start time within the same day.',
  );
  static void _credits(double? credits) => _require(
    credits == null || credits.isFinite && credits >= 0,
    'Required credits cannot be negative.',
  );
  static void _require(bool valid, String message) {
    if (!valid) throw ArgumentError(message);
  }
}
