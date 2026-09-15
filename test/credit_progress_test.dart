import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/credit_progress.dart';

import 'academic_fixtures.dart';

void main() {
  test(
    'credits separate statuses, categories and potential without tag duplication',
    () {
      final original = sampleAcademicData().courses.first;
      final courses = [
        original.copyWith(
          id: '1',
          status: CourseStatus.completed,
          credits: 3.5,
        ),
        original.copyWith(id: '2', status: CourseStatus.inProgress, credits: 2),
        original.copyWith(id: '3', status: CourseStatus.planned, credits: 4),
        original.copyWith(id: '4', status: CourseStatus.failed, credits: 10),
        original.copyWith(id: '5', status: CourseStatus.withdrawn, credits: 10),
        original.copyWith(
          id: '6',
          graduationCategoryId: 'elective',
          status: CourseStatus.completed,
          credits: 1,
        ),
        original.copyWith(
          id: '7',
          status: CourseStatus.completed,
          deletedAt: Value(DateTime(2026)),
        ),
      ];
      final totals = creditTotals(courses);
      expect(totals.completed, 4.5);
      expect(totals.inProgress, 2);
      expect(totals.planned, 4);
      expect(totals.potential, 10.5);
      expect(creditTotals(courses, categoryId: 'core').completed, 3.5);
      expect(totals.remaining(12), 7.5);
      expect(totals.remaining(12, includePotential: true), 1.5);
      expect(totals.remaining(2), 0);
      expect(totals.remaining(null), isNull);
    },
  );

  test('selected-semester planning preview excludes unrelated plans', () {
    final original = sampleAcademicData().courses.first;
    final courses = [
      original.copyWith(status: CourseStatus.completed),
      original.copyWith(id: 'active', status: CourseStatus.inProgress),
      original.copyWith(
        id: 'a',
        semesterId: 'plan-a',
        status: CourseStatus.planned,
      ),
      original.copyWith(
        id: 'b',
        semesterId: 'plan-b',
        status: CourseStatus.planned,
      ),
    ];
    final totals = creditTotals(courses, plannedSemesterId: 'plan-a');
    expect(totals.completed, 3);
    expect(totals.inProgress, 3);
    expect(totals.planned, 3);
    expect(totals.potential, 9);
    expect(creditTotals(courses).planned, 6);
  });

  test(
    'category targets cap credits and overflow rolls into Free Elective',
    () {
      final stamp = DateTime(2026, 9, 1);
      final original = sampleAcademicData().courses.first;
      final categories = [
        GraduationCategory(
          id: 'core',
          name: 'Basic Core',
          requiredCredits: 6,
          sortOrder: 0,
          isActive: true,
          createdAt: stamp,
          updatedAt: stamp,
        ),
        GraduationCategory(
          id: 'elective',
          name: 'Free Elective',
          requiredCredits: 12,
          sortOrder: 1,
          isActive: true,
          createdAt: stamp,
          updatedAt: stamp,
        ),
      ];
      final courses = [
        original.copyWith(
          id: 'core-1',
          graduationCategoryId: 'core',
          status: CourseStatus.completed,
          credits: 3,
        ),
        original.copyWith(
          id: 'core-2',
          graduationCategoryId: 'core',
          status: CourseStatus.completed,
          credits: 3,
        ),
        original.copyWith(
          id: 'core-3',
          graduationCategoryId: 'core',
          status: CourseStatus.inProgress,
          credits: 3,
        ),
        original.copyWith(
          id: 'free-1',
          graduationCategoryId: 'elective',
          status: CourseStatus.completed,
          credits: 2,
        ),
      ];

      final allocated = allocatedCategoryCredits(courses, categories);
      expect(allocated['core']!.completed, 6);
      expect(allocated['core']!.inProgress, 0);
      expect(allocated['elective']!.completed, 2);
      expect(allocated['elective']!.inProgress, 3);
      expect(allocated['elective']!.potential, 5);
      expect(creditTotals(courses).potential, 11);
    },
  );

  test('Free Elective can exceed its requirement after overflow', () {
    final stamp = DateTime(2026, 9, 1);
    final original = sampleAcademicData().courses.first;
    final categories = [
      GraduationCategory(
        id: 'core',
        name: 'Core',
        requiredCredits: 12,
        sortOrder: 0,
        isActive: true,
        createdAt: stamp,
        updatedAt: stamp,
      ),
      GraduationCategory(
        id: 'elective',
        name: 'Free Elective',
        requiredCredits: 30,
        sortOrder: 1,
        isActive: true,
        createdAt: stamp,
        updatedAt: stamp,
      ),
    ];
    final courses = [
      original.copyWith(
        id: 'core-1',
        graduationCategoryId: 'core',
        status: CourseStatus.completed,
        credits: 6,
      ),
      original.copyWith(
        id: 'core-2',
        graduationCategoryId: 'core',
        status: CourseStatus.completed,
        credits: 7,
      ),
      original.copyWith(
        id: 'free-1',
        graduationCategoryId: 'elective',
        status: CourseStatus.completed,
        credits: 15,
      ),
      original.copyWith(
        id: 'free-2',
        graduationCategoryId: 'elective',
        status: CourseStatus.completed,
        credits: 18,
      ),
    ];

    final allocated = allocatedCategoryCredits(courses, categories);

    expect(allocated['core']!.completed, 12);
    expect(allocated['elective']!.completed, 34);
    expect(allocated['elective']!.completed, greaterThan(30));
    expect(creditTotals(courses).completed, 46);
    expect(
      allocated['core']!.completed + allocated['elective']!.completed,
      46,
    );
  });

  test('completed course count tracks overall and category completion', () {
    final original = sampleAcademicData().courses.first;
    final courses = [
      original.copyWith(id: 'completed-core-1', status: CourseStatus.completed),
      original.copyWith(id: 'completed-core-2', status: CourseStatus.completed),
      original.copyWith(
        id: 'completed-elective',
        graduationCategoryId: 'elective',
        status: CourseStatus.completed,
      ),
      original.copyWith(id: 'current', status: CourseStatus.inProgress),
      original.copyWith(id: 'failed', status: CourseStatus.failed),
      original.copyWith(
        id: 'deleted',
        status: CourseStatus.completed,
        deletedAt: Value(DateTime(2026, 9, 2)),
      ),
    ];

    expect(completedCourseCount(courses), 3);
    expect(completedCourseCount(courses, categoryId: 'core'), 2);
    expect(completedCourseCount(courses, categoryId: 'elective'), 1);
  });
}
