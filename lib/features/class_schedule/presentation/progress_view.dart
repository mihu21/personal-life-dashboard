import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/credit_progress.dart';
import 'academic_data_view.dart';
import 'course_details.dart';
import 'record_editors.dart';

class ProgressView extends StatelessWidget {
  const ProgressView({required this.data, super.key});
  final AcademicSnapshot data;
  @override
  Widget build(BuildContext context) {
    final allocated = allocatedCategoryCredits(data.courses, data.categories);
    return ListView(
      padding: EdgeInsets.all(AppDensity.pagePadding(context)),
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppDensity.controlGap(context),
          runSpacing: AppDensity.sectionGap(context),
          children: [
            Text(
              'Academic progress',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            OutlinedButton(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => GraduationRequirementsEditor(data: data),
              ),
              child: const Text('Edit requirements'),
            ),
          ],
        ),
        SizedBox(height: AppDensity.cardPadding(context)),
        CreditSummary(
          totals: creditTotals(data.courses),
          target: data.settings.requiredCredits,
          completedCourses: completedCourseCount(data.courses),
        ),
        SizedBox(height: AppDensity.sectionGap(context)),
        const Text(
          'Potential assumes all in-progress and planned courses are completed. It is not earned credit.',
        ),
        SizedBox(height: AppDensity.sectionGap(context)),
        const Text(
          'Categories other than Free Elective stop counting at their requirement; excess credits roll into Free Elective. Free Elective can exceed its requirement, and every valid course credit still counts toward the overall graduation total.',
        ),
        SizedBox(height: AppDensity.cardPadding(context)),
        for (final category in data.categories)
          _categoryProgressCard(
            context: context,
            data: data,
            category: category,
            allocated: allocated,
          ),
        if (data.courses.isEmpty)
          Padding(
            padding: EdgeInsets.all(AppDensity.cardPadding(context)),
            child: Text('Your completed courses will appear here.'),
          ),
      ],
    );
  }
}

Widget _categoryProgressCard({
  required BuildContext context,
  required AcademicSnapshot data,
  required GraduationCategory category,
  required Map<String, CreditTotals> allocated,
}) {
  final raw = creditTotals(data.courses, categoryId: category.id);
  final accounted = allocated[category.id] ?? const CreditTotals();
  final freeElective = isFreeElectiveCategory(category);
  final transfer = freeElective
      ? _positiveDifference(accounted, raw)
      : _positiveDifference(raw, accounted);

  return CategoryProgressCard(
    name: '${category.name}${category.isActive ? '' : ' (hidden)'}',
    target: category.requiredCredits,
    totals: accounted,
    completedCourses: completedCourseCount(
      data.courses,
      categoryId: category.id,
    ),
    isFreeElective: freeElective,
    overflowCredits: freeElective ? 0 : transfer.potential,
    receivedOverflowCredits: freeElective ? transfer.potential : 0,
    onTap: () => Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CategoryCoursesPage(
          categoryId: category.id,
          fallbackCategoryName: category.name,
        ),
      ),
    ),
  );
}

CreditTotals _positiveDifference(CreditTotals larger, CreditTotals smaller) =>
    CreditTotals(
      completed: _nonNegative(larger.completed - smaller.completed),
      inProgress: _nonNegative(larger.inProgress - smaller.inProgress),
      planned: _nonNegative(larger.planned - smaller.planned),
    );

double _nonNegative(double value) => value > 0 ? value : 0;

class CreditSummary extends StatelessWidget {
  const CreditSummary({
    required this.totals,
    required this.completedCourses,
    this.target,
    super.key,
  });
  final CreditTotals totals;
  final int completedCourses;
  final double? target;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      LayoutBuilder(
        builder: (context, constraints) {
          final gap = AppDensity.controlGap(context);
          final scale = MediaQuery.textScalerOf(context).scale(1);
          final available = constraints.maxWidth.clamp(0.0, 720.0);
          final columns =
              (available / ((AppDensity.isMobile(context) ? 82 : 152) * scale))
                  .floor()
                  .clamp(1, 4);
          final width = (available - gap * (columns - 1)) / columns;
          return Wrap(
            spacing: AppDensity.controlGap(context),
            runSpacing: AppDensity.controlGap(context),
            children: [
              for (final item in [
                ('Completed', totals.completed),
                ('In progress', totals.inProgress),
                ('Planned', totals.planned),
                ('Potential', totals.potential),
              ])
                SizedBox(
                  width: width,
                  child: Card.outlined(
                    child: Padding(
                      padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1),
                          Text(
                            creditLabel(item.$2),
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
      SizedBox(height: AppDensity.sectionGap(context)),
      Text(
        '$completedCourses ${completedCourses == 1 ? 'course' : 'courses'} completed',
        style: Theme.of(context).textTheme.bodySmall,
      ),
      SizedBox(height: AppDensity.tinyGap(context)),
      Text(
        target == null
            ? 'Overall target not set'
            : 'Overall target: ${creditLabel(target!)} credits · ${creditLabel(totals.remaining(target)!)} remaining',
      ),
      if (target != null && target! > 0)
        Padding(
          padding: EdgeInsets.only(top: AppDensity.sectionGap(context)),
          child: LinearProgressIndicator(
            value: (totals.completed / target!).clamp(0, 1),
            semanticsLabel: 'Completed credits',
            semanticsValue:
                '${creditLabel(totals.completed)} of ${creditLabel(target!)}',
          ),
        ),
    ],
  );
}

class CategoryProgressCard extends StatelessWidget {
  const CategoryProgressCard({
    required this.name,
    required this.totals,
    required this.completedCourses,
    this.target,
    this.preview = false,
    this.isFreeElective = false,
    this.overflowCredits = 0,
    this.receivedOverflowCredits = 0,
    this.onTap,
    super.key,
  });
  final String name;
  final CreditTotals totals;
  final int completedCourses;
  final double? target;
  final bool preview;
  final bool isFreeElective;
  final double overflowCredits;
  final double receivedOverflowCredits;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: AppDensity.sectionGap(context)),
    child: Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(AppDensity.cardPadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: AppDensity.tinyGap(context),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  if (onTap != null)
                    Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                ],
              ),
              Text(
                '${creditLabel(totals.completed)}${target == null ? '' : ' / ${creditLabel(target!)}'} ${isFreeElective ? 'credits fulfilled' : 'credits completed'}',
              ),
              Text(
                isFreeElective && receivedOverflowCredits > 0
                    ? '$completedCourses directly assigned ${completedCourses == 1 ? 'course' : 'courses'} completed'
                    : '$completedCourses ${completedCourses == 1 ? 'course' : 'courses'} completed',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                '+${creditLabel(totals.inProgress)} in progress · +${creditLabel(totals.planned)} planned',
              ),
              Text(
                'Potential: ${creditLabel(totals.potential)}${target == null ? '' : ' · ${creditLabel(totals.remaining(target, includePotential: preview)!)} remaining${preview ? ' after completion' : ''}'}',
              ),
              if (overflowCredits > 0)
                Text(
                  '${creditLabel(overflowCredits)} overflow credits count toward Free Elective.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (receivedOverflowCredits > 0)
                Text(
                  'Includes ${creditLabel(receivedOverflowCredits)} overflow credits from other categories.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              if (target != null && target! > 0)
                LinearProgressIndicator(
                  value:
                      ((preview ? totals.potential : totals.completed) / target!)
                          .clamp(0, 1),
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

enum _CategoryCourseFilter { all, completed, inProgress, planned }

class CategoryCoursesPage extends StatefulWidget {
  const CategoryCoursesPage({
    required this.categoryId,
    required this.fallbackCategoryName,
    super.key,
  });

  final String categoryId;
  final String fallbackCategoryName;

  @override
  State<CategoryCoursesPage> createState() => _CategoryCoursesPageState();
}

class _CategoryCoursesPageState extends State<CategoryCoursesPage> {
  _CategoryCourseFilter filter = _CategoryCourseFilter.all;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(widget.fallbackCategoryName)),
    body: SafeArea(
      child: AcademicDataView(
        builder: (data) {
          final category = data.categories
              .where((category) => category.id == widget.categoryId)
              .firstOrNull;
          if (category == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('This graduation category is no longer available.'),
              ),
            );
          }

          final courses = data.courses
              .where(
                (course) => course.graduationCategoryId == widget.categoryId,
              )
              .toList();
          final rawTotals = creditTotals(courses);
          final allocated = allocatedCategoryCredits(
            data.courses,
            data.categories,
          );
          final accountedTotals =
              allocated[category.id] ?? const CreditTotals();
          final freeElective = isFreeElectiveCategory(category);
          final transferTotals = freeElective
              ? _positiveDifference(accountedTotals, rawTotals)
              : _positiveDifference(rawTotals, accountedTotals);
          final semesterById = {
            for (final semester in data.semesters) semester.id: semester,
          };

          courses.sort((a, b) {
            final aStart = semesterById[a.semesterId]?.startDate;
            final bStart = semesterById[b.semesterId]?.startDate;
            if (aStart != null && bStart != null) {
              final bySemester = bStart.compareTo(aStart);
              if (bySemester != 0) return bySemester;
            }
            return a.courseName.toLowerCase().compareTo(
              b.courseName.toLowerCase(),
            );
          });

          final visible = courses.where((course) {
            return switch (filter) {
              _CategoryCourseFilter.all => true,
              _CategoryCourseFilter.completed =>
                course.status == CourseStatus.completed,
              _CategoryCourseFilter.inProgress =>
                course.status == CourseStatus.inProgress,
              _CategoryCourseFilter.planned =>
                course.status == CourseStatus.planned,
            };
          }).toList();

          final courseListWidgets = <Widget>[];

          if (visible.isEmpty) {
            courseListWidgets.add(_EmptyCategoryCourses(filter: filter));
          } else if (filter == _CategoryCourseFilter.all) {
            for (final status in _categoryStatusOrder) {
              final statusCourses = visible
                  .where((course) => course.status == status)
                  .toList();
              if (statusCourses.isEmpty) continue;

              courseListWidgets.add(
                _CourseStatusSectionHeader(
                  status: status,
                  count: statusCourses.length,
                ),
              );
              for (final course in statusCourses) {
                courseListWidgets.add(
                  _CategoryCourseCard(
                    courseId: course.id,
                    courseName: course.courseName,
                    courseCode: course.courseCode,
                    credits: course.credits,
                    semesterName:
                        semesterById[course.semesterId]?.name ??
                        'Unknown semester',
                    status: course.status,
                  ),
                );
              }
              courseListWidgets.add(
                SizedBox(height: AppDensity.sectionGap(context)),
              );
            }
          } else {
            for (final course in visible) {
              courseListWidgets.add(
                _CategoryCourseCard(
                  courseId: course.id,
                  courseName: course.courseName,
                  courseCode: course.courseCode,
                  credits: course.credits,
                  semesterName:
                      semesterById[course.semesterId]?.name ??
                      'Unknown semester',
                  status: course.status,
                ),
              );
            }
          }

          return ListView(
            padding: EdgeInsets.all(AppDensity.pagePadding(context)),
            children: [
              Text(category.name, style: Theme.of(context).textTheme.titleLarge),
              if (!category.isActive)
                Padding(
                  padding: EdgeInsets.only(top: AppDensity.tinyGap(context)),
                  child: Text(
                    'This category is currently hidden, but its historical courses are preserved.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              SizedBox(height: AppDensity.sectionGap(context)),
              _CategoryCourseSummary(
                rawTotals: rawTotals,
                accountedTotals: accountedTotals,
                transferTotals: transferTotals,
                isFreeElective: freeElective,
                target: category.requiredCredits,
                courseCount: courses.length,
              ),
              SizedBox(height: AppDensity.sectionGap(context)),
              _CategoryFilterBar(
                filter: filter,
                allCount: courses.length,
                completedCount: _statusCount(courses, CourseStatus.completed),
                inProgressCount: _statusCount(
                  courses,
                  CourseStatus.inProgress,
                ),
                plannedCount: _statusCount(courses, CourseStatus.planned),
                onChanged: (value) => setState(() => filter = value),
              ),
              SizedBox(height: AppDensity.sectionGap(context)),
              ...courseListWidgets,
            ],
          );
        },
      ),
    ),
  );
}

const _categoryStatusOrder = [
  CourseStatus.completed,
  CourseStatus.inProgress,
  CourseStatus.planned,
  CourseStatus.withdrawn,
  CourseStatus.failed,
];

int _statusCount(Iterable<Course> courses, CourseStatus status) =>
    courses.where((course) => course.status == status).length;

class _CategoryCourseSummary extends StatelessWidget {
  const _CategoryCourseSummary({
    required this.rawTotals,
    required this.accountedTotals,
    required this.transferTotals,
    required this.isFreeElective,
    required this.courseCount,
    this.target,
  });

  final CreditTotals rawTotals;
  final CreditTotals accountedTotals;
  final CreditTotals transferTotals;
  final bool isFreeElective;
  final int courseCount;
  final double? target;

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: Padding(
      padding: EdgeInsets.all(AppDensity.cardPadding(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Assigned course credits',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: AppDensity.tinyGap(context)),
          Wrap(
            spacing: AppDensity.cardPadding(context),
            runSpacing: AppDensity.controlGap(context),
            children: [
              _SummaryValue(label: 'Completed', value: rawTotals.completed),
              _SummaryValue(
                label: 'In progress',
                value: rawTotals.inProgress,
              ),
              _SummaryValue(label: 'Planned', value: rawTotals.planned),
              _SummaryValue(label: 'Potential', value: rawTotals.potential),
            ],
          ),
          SizedBox(height: AppDensity.sectionGap(context)),
          Text(
            '$courseCount ${courseCount == 1 ? 'course' : 'courses'} directly assigned to this category',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          SizedBox(height: AppDensity.sectionGap(context)),
          const Divider(),
          SizedBox(height: AppDensity.sectionGap(context)),
          Text(
            'Graduation accounting',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          SizedBox(height: AppDensity.tinyGap(context)),
          if (isFreeElective) ...[
            _AccountingLine(
              label: 'Direct Free Elective courses',
              totals: rawTotals,
            ),
            if (transferTotals.potential > 0)
              _AccountingLine(
                label: 'Overflow received',
                totals: transferTotals,
              ),
            _AccountingLine(
              label: 'Free Elective total',
              totals: accountedTotals,
              emphasized: true,
            ),
          ] else ...[
            _AccountingLine(
              label: 'Counted toward this category',
              totals: accountedTotals,
              emphasized: true,
            ),
            if (transferTotals.potential > 0)
              _AccountingLine(
                label: 'Overflow sent to Free Elective',
                totals: transferTotals,
              ),
          ],
          SizedBox(height: AppDensity.sectionGap(context)),
          Text(
            target == null
                ? isFreeElective
                    ? '${creditLabel(accountedTotals.completed)} completed credits count toward Free Elective. No minimum requirement is set.'
                    : '${creditLabel(accountedTotals.completed)} completed credits count toward this category. No minimum requirement is set.'
                : '${creditLabel(accountedTotals.completed)} / ${creditLabel(target!)} credits fulfilled',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          if (target != null) ...[
            SizedBox(height: AppDensity.tinyGap(context)),
            Text(
              'Potential: ${creditLabel(accountedTotals.potential)} / ${creditLabel(target!)} · ${creditLabel(accountedTotals.remaining(target, includePotential: true)!)} remaining if current and planned courses are completed',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (target != null && target! > 0)
            Padding(
              padding: EdgeInsets.only(top: AppDensity.sectionGap(context)),
              child: LinearProgressIndicator(
                value: (accountedTotals.completed / target!).clamp(0, 1),
              ),
            ),
        ],
      ),
    ),
  );
}

class _AccountingLine extends StatelessWidget {
  const _AccountingLine({
    required this.label,
    required this.totals,
    this.emphasized = false,
  });

  final String label;
  final CreditTotals totals;
  final bool emphasized;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(top: AppDensity.tinyGap(context)),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: emphasized ? Theme.of(context).textTheme.bodyMedium : null,
          ),
        ),
        SizedBox(width: AppDensity.controlGap(context)),
        Flexible(
          child: Text(
            _creditBreakdown(totals),
            textAlign: TextAlign.end,
            style: emphasized
                ? Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  )
                : Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
          ),
        ),
      ],
    ),
  );
}

String _creditBreakdown(CreditTotals totals) =>
    '${creditLabel(totals.completed)} completed · +${creditLabel(totals.inProgress)} in progress · +${creditLabel(totals.planned)} planned';

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({required this.label, required this.value});

  final String label;
  final double value;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: AppDensity.isMobile(context) ? 92 : 118,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        Text(
          '${creditLabel(value)} cr',
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    ),
  );
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.filter,
    required this.allCount,
    required this.completedCount,
    required this.inProgressCount,
    required this.plannedCount,
    required this.onChanged,
  });

  final _CategoryCourseFilter filter;
  final int allCount;
  final int completedCount;
  final int inProgressCount;
  final int plannedCount;
  final ValueChanged<_CategoryCourseFilter> onChanged;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    scrollDirection: Axis.horizontal,
    child: Row(
      children: [
        _filterChip(_CategoryCourseFilter.all, 'All ($allCount)'),
        SizedBox(width: AppDensity.tinyGap(context)),
        _filterChip(
          _CategoryCourseFilter.completed,
          'Completed ($completedCount)',
        ),
        SizedBox(width: AppDensity.tinyGap(context)),
        _filterChip(
          _CategoryCourseFilter.inProgress,
          'In progress ($inProgressCount)',
        ),
        SizedBox(width: AppDensity.tinyGap(context)),
        _filterChip(_CategoryCourseFilter.planned, 'Planned ($plannedCount)'),
      ],
    ),
  );

  Widget _filterChip(_CategoryCourseFilter value, String label) => ChoiceChip(
    label: Text(label),
    selected: filter == value,
    showCheckmark: false,
    onSelected: (_) => onChanged(value),
  );
}

class _CourseStatusSectionHeader extends StatelessWidget {
  const _CourseStatusSectionHeader({required this.status, required this.count});

  final CourseStatus status;
  final int count;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: AppDensity.tinyGap(context),
      bottom: AppDensity.tinyGap(context),
    ),
    child: Row(
      children: [
        Icon(_statusIcon(status), size: 18),
        SizedBox(width: AppDensity.tinyGap(context)),
        Text(
          '${statusLabel(status)} ($count)',
          style: Theme.of(context).textTheme.titleSmall,
        ),
      ],
    ),
  );
}

class _CategoryCourseCard extends StatelessWidget {
  const _CategoryCourseCard({
    required this.courseId,
    required this.courseName,
    required this.courseCode,
    required this.credits,
    required this.semesterName,
    required this.status,
  });

  final String courseId;
  final String courseName;
  final String courseCode;
  final double credits;
  final String semesterName;
  final CourseStatus status;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(bottom: AppDensity.tinyGap(context)),
    child: Card.outlined(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(_statusIcon(status)),
        title: Text(courseName),
        subtitle: Padding(
          padding: EdgeInsets.only(top: AppDensity.tinyGap(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (courseCode.trim().isNotEmpty) Text(courseCode),
              Text(
                '$semesterName · ${creditLabel(credits)} credits · ${statusLabel(status)}',
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => showDialog(
          context: context,
          builder: (_) => CourseDetails(courseId: courseId),
        ),
      ),
    ),
  );
}

class _EmptyCategoryCourses extends StatelessWidget {
  const _EmptyCategoryCourses({required this.filter});

  final _CategoryCourseFilter filter;

  @override
  Widget build(BuildContext context) => Card.outlined(
    child: Padding(
      padding: EdgeInsets.all(AppDensity.cardPadding(context)),
      child: Text(
        switch (filter) {
          _CategoryCourseFilter.all =>
            'No courses are assigned to this category yet.',
          _CategoryCourseFilter.completed =>
            'No completed courses in this category.',
          _CategoryCourseFilter.inProgress =>
            'No in-progress courses in this category.',
          _CategoryCourseFilter.planned =>
            'No planned courses in this category.',
        },
      ),
    ),
  );
}

IconData _statusIcon(CourseStatus status) => switch (status) {
  CourseStatus.completed => Icons.check_circle_outline,
  CourseStatus.inProgress => Icons.schedule,
  CourseStatus.planned => Icons.event_note,
  CourseStatus.withdrawn => Icons.block,
  CourseStatus.failed => Icons.error_outline,
};
