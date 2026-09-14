import '../domain/academic_types.dart';
import '../domain/course_draft.dart';
import 'academic_repository.dart';

/// Optional fictional records. Never automatically seeded or mixed into records.
Future<void> loadAcademicDemo(AcademicRepository repository) =>
    repository.db.transaction(() async {
      await repository.initialize();
      final data = await repository.snapshot();
      if (data.semesters.isNotEmpty || data.courses.isNotEmpty) {
        throw ArgumentError(
          'Demo data can only be loaded before creating semesters or courses.',
        );
      }
      final now = DateTime.now();
      final category = data.categories.first.id;
      await repository.saveSettings(requiredCredits: 128, setupDismissed: true);
      final past = await repository.saveSemester(
        name: 'Demo · Previous year',
        academicYear: '${now.year - 1}',
        term: 'Fall',
        start: DateTime(now.year - 1, 9),
        end: DateTime(now.year - 1, 12, 31),
        status: SemesterStatus.completed,
      );
      final current = await repository.saveSemester(
        name: 'Demo · Current semester',
        academicYear: '${now.year}',
        term: 'Demo',
        start: DateTime(now.year),
        end: DateTime(now.year, 12, 31),
        status: SemesterStatus.current,
      );
      final future = await repository.saveSemester(
        name: 'Demo · Future plan',
        academicYear: '${now.year + 1}',
        term: 'Spring',
        start: DateTime(now.year + 1, 2),
        end: DateTime(now.year + 1, 6, 30),
        status: SemesterStatus.planned,
      );
      await repository.saveCategory(
        id: category,
        name: data.categories.first.name,
        requiredCredits: 24,
      );
      await repository.saveCourse(
        CourseDraft(
          name: 'Demo · Mathematics',
          credits: 3,
          semesterId: past,
          categoryId: category,
          status: CourseStatus.completed,
          meetings: const [MeetingDraft(day: 1, start: 540, end: 650)],
        ),
      );
      for (var i = 0; i < 3; i++) {
        await repository.saveCourse(
          CourseDraft(
            name: [
              'Demo · Operating Systems',
              'Demo · Linear Algebra',
              'Demo · Game Programming',
            ][i],
            code: 'DEMO${i + 1}',
            credits: 3,
            semesterId: current,
            categoryId: data.categories[i % data.categories.length].id,
            location: 'Demo room ${201 + i}',
            professor: 'Demo instructor',
            notes: 'Fictional demonstration course.',
            tags: ['Demo'],
            meetings: [
              MeetingDraft(
                day: now.weekday,
                start: [540, 800, 980][i],
                end: [650, 910, 1090][i],
              ),
              MeetingDraft(
                day: (now.weekday + 2) % 7 + 1,
                start: 600 + i * 120,
                end: 660 + i * 120,
              ),
            ],
          ),
        );
      }
      for (var i = 0; i < 2; i++) {
        await repository.saveCourse(
          CourseDraft(
            name: ['Demo · Networks', 'Demo · Data Science'][i],
            credits: 3,
            semesterId: future,
            categoryId: category,
            status: CourseStatus.planned,
            meetings: [
              MeetingDraft(day: 2, start: 800 + i * 60, end: 910 + i * 60),
            ],
          ),
        );
      }
    });
