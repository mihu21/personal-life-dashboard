import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import '../domain/academic_types.dart';

part 'academic_database.g.dart';

abstract class AuditedTable extends Table {
  TextColumn get id => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class Semesters extends AuditedTable {
  TextColumn get name => text()();
  TextColumn get academicYear => text()();
  TextColumn get term => text()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get status => textEnum<SemesterStatus>()();
  TextColumn get nthuTermCode => text().nullable()();
}

class GraduationCategories extends AuditedTable {
  TextColumn get name => text()();
  RealColumn get requiredCredits => real().nullable()();
  TextColumn get description => text().nullable()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

class Courses extends AuditedTable {
  TextColumn get courseCode => text().withDefault(const Constant(''))();
  TextColumn get courseName => text()();
  RealColumn get credits => real()();
  TextColumn get semesterId => text().references(Semesters, #id)();
  TextColumn get graduationCategoryId =>
      text().references(GraduationCategories, #id)();
  TextColumn get status => textEnum<CourseStatus>()();
  TextColumn get location => text().nullable()();
  TextColumn get professor => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get catalogCourseId =>
      text().nullable().references(NthuCatalogCourses, #id)();
  TextColumn get englishName => text().nullable()();
  TextColumn get teachingLanguage => text().nullable()();

  @override
  List<String> get customConstraints => ['CHECK (credits >= 0)'];
}

class Tags extends AuditedTable {
  TextColumn get name => text().unique()();
}

class CourseTags extends AuditedTable {
  TextColumn get courseId => text().references(Courses, #id)();
  TextColumn get tagId => text().references(Tags, #id)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {courseId, tagId},
  ];
}

class ClassMeetings extends AuditedTable {
  TextColumn get courseId => text().references(Courses, #id)();
  IntColumn get dayOfWeek => integer()();
  IntColumn get startTime => integer()();
  IntColumn get endTime => integer()();
  TextColumn get locationOverride => text().nullable()();
  TextColumn get dayCode => text().nullable()();
  TextColumn get startPeriod => text().nullable()();
  TextColumn get endPeriod => text().nullable()();
  BoolColumn get needsReview => boolean().withDefault(const Constant(false))();

  @override
  List<String> get customConstraints => [
    'CHECK (day_of_week BETWEEN 1 AND 7)',
    'CHECK (start_time >= 0 AND end_time <= 1440 AND end_time > start_time)',
  ];
}

class ScheduleExceptions extends AuditedTable {
  TextColumn get courseId => text().references(Courses, #id)();
  TextColumn get meetingId =>
      text().nullable().references(ClassMeetings, #id)();
  DateTimeColumn get date => dateTime()();
  TextColumn get type => textEnum<ExceptionType>()();
  IntColumn get replacementStartTime => integer().nullable()();
  IntColumn get replacementEndTime => integer().nullable()();
  TextColumn get replacementLocation => text().nullable()();
  TextColumn get note => text().nullable()();
  TextColumn get replacementDayCode => text().nullable()();
  TextColumn get replacementStartPeriod => text().nullable()();
  TextColumn get replacementEndPeriod => text().nullable()();
}

class AcademicSettings extends AuditedTable {
  RealColumn get requiredCredits => real().nullable()();
  BoolColumn get setupDismissed =>
      boolean().withDefault(const Constant(false))();
}

class NthuCatalogTerms extends AuditedTable {
  TextColumn get termCode => text().unique()();
  TextColumn get displayName => text()();
  DateTimeColumn get fetchedAt => dateTime()();
  TextColumn get sourceType => text()();
  TextColumn get sourceUrl => text()();
  DateTimeColumn get sourceUpdatedAt => dateTime().nullable()();
}

class NthuCatalogCourses extends AuditedTable {
  TextColumn get termCode => text().references(NthuCatalogTerms, #termCode)();
  TextColumn get officialCourseCode => text()();
  TextColumn get chineseName => text()();
  TextColumn get englishName => text()();
  RealColumn get credits => real()();
  TextColumn get teachingLanguage => text()();
  TextColumn get instructorNames => text()();
  TextColumn get notes => text()();
  TextColumn get cancellationFlag => text()();
  TextColumn get restrictions => text()();
  TextColumn get requiredElectiveMetadata => text()();
  TextColumn get department => text()();
  TextColumn get subject => text()();
  TextColumn get rawScheduleText => text()();
  TextColumn get rawLocationText => text()();
  DateTimeColumn get fetchedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {termCode, officialCourseCode},
  ];
}

class NthuCatalogMeetings extends AuditedTable {
  TextColumn get catalogCourseId =>
      text().references(NthuCatalogCourses, #id)();
  TextColumn get dayCode => text()();
  TextColumn get startPeriod => text()();
  TextColumn get endPeriod => text()();
  TextColumn get scheduleCode => text()();
  TextColumn get location => text()();
}

@DriftDatabase(
  tables: [
    Semesters,
    GraduationCategories,
    Courses,
    Tags,
    CourseTags,
    ClassMeetings,
    ScheduleExceptions,
    AcademicSettings,
    NthuCatalogTerms,
    NthuCatalogCourses,
    NthuCatalogMeetings,
  ],
)
class AcademicDatabase extends _$AcademicDatabase {
  AcademicDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'academic_records',
              native: const DriftNativeOptions(
                databaseDirectory: getApplicationSupportDirectory,
              ),
            ),
      );

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        "CREATE UNIQUE INDEX one_current_semester ON semesters(status) WHERE status = 'current' AND deleted_at IS NULL",
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.addColumn(semesters, semesters.nthuTermCode);
        await m.createTable(nthuCatalogTerms);
        await m.createTable(nthuCatalogCourses);
        await m.createTable(nthuCatalogMeetings);
        await m.addColumn(courses, courses.catalogCourseId);
        await m.addColumn(courses, courses.englishName);
        await m.addColumn(courses, courses.teachingLanguage);
        await m.addColumn(classMeetings, classMeetings.dayCode);
        await m.addColumn(classMeetings, classMeetings.startPeriod);
        await m.addColumn(classMeetings, classMeetings.endPeriod);
        await m.addColumn(classMeetings, classMeetings.needsReview);
        await m.addColumn(
          scheduleExceptions,
          scheduleExceptions.replacementDayCode,
        );
        await m.addColumn(
          scheduleExceptions,
          scheduleExceptions.replacementStartPeriod,
        );
        await m.addColumn(
          scheduleExceptions,
          scheduleExceptions.replacementEndPeriod,
        );
        await customStatement('''
          UPDATE class_meetings SET
            day_code = CASE day_of_week
              WHEN 1 THEN 'M' WHEN 2 THEN 'T' WHEN 3 THEN 'W'
              WHEN 4 THEN 'R' WHEN 5 THEN 'F' WHEN 6 THEN 'S' WHEN 7 THEN 'U'
            END,
            start_period = CASE start_time
              WHEN 480 THEN '1' WHEN 540 THEN '2' WHEN 610 THEN '3'
              WHEN 670 THEN '4' WHEN 730 THEN 'n' WHEN 800 THEN '5'
              WHEN 860 THEN '6' WHEN 930 THEN '7' WHEN 990 THEN '8'
              WHEN 1050 THEN '9' WHEN 1110 THEN 'a' WHEN 1170 THEN 'b'
              WHEN 1230 THEN 'c' WHEN 1290 THEN 'd'
            END,
            end_period = CASE end_time
              WHEN 530 THEN '1' WHEN 590 THEN '2' WHEN 660 THEN '3'
              WHEN 720 THEN '4' WHEN 780 THEN 'n' WHEN 850 THEN '5'
              WHEN 910 THEN '6' WHEN 980 THEN '7' WHEN 1040 THEN '8'
              WHEN 1100 THEN '9' WHEN 1160 THEN 'a' WHEN 1220 THEN 'b'
              WHEN 1280 THEN 'c' WHEN 1340 THEN 'd'
            END,
            needs_review = CASE
              WHEN start_time IN (480,540,610,670,730,800,860,930,990,1050,1110,1170,1230,1290)
               AND end_time IN (530,590,660,720,780,850,910,980,1040,1100,1160,1220,1280,1340)
              THEN 0 ELSE 1 END
        ''');
      }
      if (from < 3) {
        await m.alterTable(TableMigration(courses));
        await customStatement('''
          UPDATE nthu_catalog_terms
          SET source_type = 'stale:' || source_type
          WHERE source_type IN ('currentJson', 'historicalArchive')
        ''');
      }
    },
    beforeOpen: (_) async => customStatement('PRAGMA foreign_keys = ON'),
  );
}
