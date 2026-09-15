import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/course_draft.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/demo_seed.dart';

void main() {
  late AcademicDatabase db;
  late AcademicRepository repo;
  late String semester;
  late String category;
  var memoryClosed = false;
  setUp(() async {
    memoryClosed = false;
    db = AcademicDatabase(NativeDatabase.memory());
    repo = AcademicRepository(db);
    await repo.initialize();
    semester = await repo.saveSemester(
      name: '2026 Fall',
      academicYear: '2026',
      term: 'Fall',
      start: DateTime(2026, 9, 1),
      end: DateTime(2027, 1, 31),
      status: SemesterStatus.current,
    );
    category = (await repo.snapshot()).categories.first.id;
  });
  tearDown(() async {
    if (!memoryClosed) await db.close();
  });

  CourseDraft draft({
    String? id,
    String name = 'Algebra',
    double credits = 3,
    List<MeetingDraft>? meetings,
  }) => CourseDraft(
    id: id,
    name: name,
    credits: credits,
    semesterId: semester,
    categoryId: category,
    tags: ['Math', 'math'],
    meetings: meetings ?? [const MeetingDraft(day: 1, start: 540, end: 600)],
  );

  test(
    'zero-credit courses are valid but negative credits are rejected',
    () async {
      final zeroId = await repo.saveCourse(
        draft(name: 'Physical Education', credits: 0),
      );
      final zeroCourse = (await repo.snapshot()).courses.firstWhere(
        (course) => course.id == zeroId,
      );
      expect(zeroCourse.credits, 0);

      await expectLater(
        repo.saveCourse(draft(name: 'Invalid course', credits: -1)),
        throwsArgumentError,
      );
    },
  );

  test(
    'overlapping courses can be saved and duplication leaves source history intact',
    () async {
      final original = await repo.saveCourse(draft());
      await repo.saveCourse(draft(name: 'Overlapping course'));
      final target = await repo.saveSemester(
        name: 'Future',
        academicYear: '2027',
        term: 'Spring',
        start: DateTime(2027, 2),
        end: DateTime(2027, 6),
        status: SemesterStatus.planned,
      );
      final duplicate = await repo.duplicateCourse(original, target);
      final data = await repo.snapshot();
      expect(data.coursesIn(semester).length, 2);
      expect(
        data.courses.firstWhere((c) => c.id == duplicate).status,
        CourseStatus.planned,
      );
      expect(
        data.meetingsFor(duplicate).single.id,
        isNot(data.meetingsFor(original).single.id),
      );
      expect(data.tagsFor(duplicate), data.tagsFor(original));
      expect(data.currentSemester?.id, semester);
      await expectLater(loadAcademicDemo(repo), throwsArgumentError);
    },
  );

  test(
    'optional demo creates isolated fictional semesters only in empty records',
    () async {
      await repo.removeSemester(semester);
      await loadAcademicDemo(repo);
      final data = await repo.snapshot();
      expect(data.semesters.length, 3);
      expect(data.courses.length, 6);
      expect(data.courses.every((c) => c.courseName.startsWith('Demo')), true);
      expect(data.settings.requiredCredits, 128);
      await expectLater(loadAcademicDemo(repo), throwsArgumentError);
    },
  );

  test(
    'create/update/delete persists meetings and deduplicates tags',
    () async {
      final id = await repo.saveCourse(draft());
      var data = await repo.snapshot();
      final meeting = data.meetings.single;
      final created = data.courses.single.createdAt;
      expect(data.tagsFor(id), ['Math']);
      await repo.saveCourse(
        draft(
          id: id,
          name: 'Linear Algebra',
          meetings: [
            MeetingDraft(id: meeting.id, day: 2, start: 600, end: 660),
            const MeetingDraft(day: 4, start: 600, end: 660),
          ],
        ),
      );
      data = await repo.snapshot();
      expect(data.courses.single.courseName, 'Linear Algebra');
      expect(data.courses.single.createdAt, created);
      expect(data.meetings.length, 2);
      await repo.removeCourse(id);
      data = await repo.snapshot();
      expect(data.courses, isEmpty);
      expect(data.meetings, isEmpty);
      expect(data.courseTags, isEmpty);
      expect((await db.select(db.courses).get()).single.deletedAt, isNotNull);
    },
  );

  test(
    'only one current semester; switching preserves courses and history',
    () async {
      await repo.saveCourse(draft());
      await repo.saveSemester(
        name: 'Spring',
        academicYear: '2027',
        term: 'Spring',
        start: DateTime(2027, 2),
        end: DateTime(2027, 6),
        status: SemesterStatus.current,
      );
      final data = await repo.snapshot();
      expect(
        data.semesters.where((s) => s.status == SemesterStatus.current).length,
        1,
      );
      expect(data.courses.single.semesterId, semester);
      expect(data.courses.single.status, CourseStatus.inProgress);
      await expectLater(repo.removeSemester(semester), throwsArgumentError);

      await repo.removeSemester(semester, confirmed: true);
      final afterDelete = await repo.snapshot();
      expect(afterDelete.semesters.any((s) => s.id == semester), false);
      expect(afterDelete.courses.where((c) => c.semesterId == semester), isEmpty);
      expect(afterDelete.meetings, isEmpty);
      expect(afterDelete.courseTags, isEmpty);
    },
  );

  test('invalid edits roll back without losing meetings', () async {
    final id = await repo.saveCourse(draft());
    await expectLater(
      repo.saveCourse(
        draft(
          id: id,
          meetings: [const MeetingDraft(day: 1, start: 700, end: 600)],
        ),
      ),
      throwsArgumentError,
    );
    expect((await repo.snapshot()).meetings.single.startTime, 540);
  });

  test('fresh install seeds current graduation requirements once', () async {
    await repo.initialize();
    final initial = await repo.snapshot();
    final original = initial.categories;

    expect(
      original.map((item) => item.name),
      [
        'Chinese',
        'General Education',
        'Physical Education',
        'Department Required',
        'Basic Core',
        'Core',
        'Lab',
        'Professional Course',
        'Free Elective',
        'Others',
      ],
    );
    expect(
      original.map((item) => item.requiredCredits),
      [8, 20, null, 18, 12, 12, 4, 24, 30, null],
    );
    expect(original.last.isActive, false);
    expect(initial.settings.requiredCredits, 128);

    await repo.saveCategory(
      id: category,
      name: 'Chinese - customized',
      requiredCredits: 9,
      isActive: false,
    );
    await repo.reorderCategories(original.reversed.map((c) => c.id).toList());
    await repo.saveSettings(requiredCredits: 130, setupDismissed: true);

    // Re-initializing an existing installation must not restore bundled values.
    await repo.initialize();
    final data = await repo.snapshot();
    expect(data.categories.last.name, 'Chinese - customized');
    expect(data.categories.last.requiredCredits, 9);
    expect(data.categories.last.isActive, false);
    expect(data.settings.requiredCredits, 130);
  });

  test('on-disk records survive closing and reopening database', () async {
    await db.close();
    memoryClosed = true;
    final folder = await Directory.systemTemp.createTemp('academic-test-');
    final file = File('${folder.path}/records.sqlite');
    try {
      var disk = AcademicDatabase(NativeDatabase(file));
      var diskRepo = AcademicRepository(disk);
      await diskRepo.initialize();
      final diskCategory = await diskRepo.saveCategory(
        name: 'Persistent',
        requiredCredits: 12,
      );
      final diskSemester = await diskRepo.saveSemester(
        name: 'Saved semester',
        academicYear: '2026',
        term: 'Fall',
        start: DateTime(2026, 9),
        end: DateTime(2026, 12, 31),
        status: SemesterStatus.current,
      );
      final diskCourse = await diskRepo.saveCourse(
        CourseDraft(
          name: 'Saved course',
          credits: 2.5,
          semesterId: diskSemester,
          categoryId: diskCategory,
          tags: ['Saved tag'],
          meetings: const [MeetingDraft(day: 1, start: 540, end: 600)],
        ),
      );
      await diskRepo.saveException(
        courseId: diskCourse,
        date: DateTime(2026, 9, 12),
        type: ExceptionType.extraClass,
        start: 700,
        end: 750,
        location: 'Extra room',
      );
      await diskRepo.saveSettings(requiredCredits: 128, setupDismissed: true);
      await disk.close();
      disk = AcademicDatabase(NativeDatabase(file));
      diskRepo = AcademicRepository(disk);
      await diskRepo.initialize();
      final reopened = await diskRepo.snapshot();
      expect(reopened.semesters.single.name, 'Saved semester');
      expect(reopened.courses.single.credits, 2.5);
      expect(reopened.meetings.single.startTime, 540);
      expect(reopened.tagsFor(diskCourse), ['Saved tag']);
      expect(reopened.exceptions.single.replacementLocation, 'Extra room');
      expect(reopened.settings.requiredCredits, 128);
      expect(
        (await diskRepo.snapshot()).categories.any(
          (c) => c.name == 'Persistent',
        ),
        true,
      );
      await disk.close();
    } finally {
      await folder.delete(recursive: true);
    }
  });

  test(
    'unused categories can be deleted but Free Elective stays available',
    () async {
      final data = await repo.snapshot();
      final other = data.categories.firstWhere((c) => c.name == 'Others');
      final free = data.categories.firstWhere((c) => c.name == 'Free Elective');

      await repo.removeCategory(other.id);
      expect(
        (await repo.snapshot()).categories.any((c) => c.id == other.id),
        false,
      );
      await expectLater(repo.removeCategory(free.id), throwsArgumentError);

      await repo.saveCourse(draft());
      await expectLater(repo.removeCategory(category), throwsArgumentError);
    },
  );
}
