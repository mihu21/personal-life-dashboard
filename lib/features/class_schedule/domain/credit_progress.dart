import 'dart:math' as math;

import '../data/academic_database.dart';
import 'academic_types.dart';

class CreditTotals {
  const CreditTotals({
    this.completed = 0,
    this.inProgress = 0,
    this.planned = 0,
  });
  final double completed;
  final double inProgress;
  final double planned;
  double get potential => completed + inProgress + planned;
  double? remaining(double? target, {bool includePotential = false}) =>
      target == null
      ? null
      : math.max(0, target - (includePotential ? potential : completed));
}

int completedCourseCount(Iterable<Course> courses, {String? categoryId}) =>
    courses.where((course) {
      if (course.deletedAt != null || course.status != CourseStatus.completed) {
        return false;
      }
      return categoryId == null || course.graduationCategoryId == categoryId;
    }).length;

CreditTotals creditTotals(
  Iterable<Course> courses, {
  String? categoryId,
  String? plannedSemesterId,
}) {
  double completed = 0, inProgress = 0, planned = 0;
  for (final c in courses) {
    if (c.deletedAt != null ||
        categoryId != null && c.graduationCategoryId != categoryId) {
      continue;
    }
    switch (c.status) {
      case CourseStatus.completed:
        completed += c.credits;
      case CourseStatus.inProgress:
        inProgress += c.credits;
      case CourseStatus.planned:
        if (plannedSemesterId == null || c.semesterId == plannedSemesterId) {
          planned += c.credits;
        }
      case CourseStatus.withdrawn || CourseStatus.failed:
        break;
    }
  }
  return CreditTotals(
    completed: completed,
    inProgress: inProgress,
    planned: planned,
  );
}

/// Graduation-category accounting with category caps.
///
/// A category with [GraduationCategory.requiredCredits] set can contribute at
/// most that many credits. Credits above the cap are transferred to the
/// `Free Elective` bucket while preserving their status (completed,
/// in-progress, or planned). Completed credits consume a category cap first,
/// followed by in-progress and then planned credits.
///
/// Overall credit totals should still use [creditTotals], because every valid
/// course credit remains part of the student's total even when a category cap
/// is already full.
Map<String, CreditTotals> allocatedCategoryCredits(
  Iterable<Course> courses,
  Iterable<GraduationCategory> categories, {
  String? plannedSemesterId,
}) {
  final categoryList = categories.where((c) => c.deletedAt == null).toList();
  final freeElective = categoryList.where(isFreeElectiveCategory).firstOrNull;
  final result = <String, CreditTotals>{};
  var overflow = const CreditTotals();

  for (final category in categoryList) {
    if (freeElective != null && category.id == freeElective.id) continue;
    final raw = creditTotals(
      courses,
      categoryId: category.id,
      plannedSemesterId: plannedSemesterId,
    );
    final capped = _capTotals(raw, category.requiredCredits);
    result[category.id] = capped.allocated;
    overflow = _addTotals(overflow, capped.overflow);
  }

  if (freeElective != null) {
    final rawFree = creditTotals(
      courses,
      categoryId: freeElective.id,
      plannedSemesterId: plannedSemesterId,
    );
    final combined = _addTotals(rawFree, overflow);
    result[freeElective.id] = _capTotals(
      combined,
      freeElective.requiredCredits,
    ).allocated;
  }

  return result;
}

bool isFreeElectiveCategory(GraduationCategory category) =>
    category.name.trim().toLowerCase() == 'free elective';

({CreditTotals allocated, CreditTotals overflow}) _capTotals(
  CreditTotals raw,
  double? target,
) {
  if (target == null) {
    return (allocated: raw, overflow: const CreditTotals());
  }

  var remaining = math.max(0.0, target);
  final completed = math.min(raw.completed, remaining);
  remaining -= completed;
  final inProgress = math.min(raw.inProgress, remaining);
  remaining -= inProgress;
  final planned = math.min(raw.planned, remaining);

  return (
    allocated: CreditTotals(
      completed: completed,
      inProgress: inProgress,
      planned: planned,
    ),
    overflow: CreditTotals(
      completed: math.max(0.0, raw.completed - completed),
      inProgress: math.max(0.0, raw.inProgress - inProgress),
      planned: math.max(0.0, raw.planned - planned),
    ),
  );
}

CreditTotals _addTotals(CreditTotals a, CreditTotals b) => CreditTotals(
  completed: a.completed + b.completed,
  inProgress: a.inProgress + b.inProgress,
  planned: a.planned + b.planned,
);

String creditLabel(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
