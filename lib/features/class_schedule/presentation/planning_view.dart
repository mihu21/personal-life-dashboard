import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/credit_progress.dart';
import '../domain/schedule_conflicts.dart';
import 'nthu_course_picker.dart';
import 'progress_view.dart';
import 'record_editors.dart';
import 'records_view.dart';

class PlanningView extends StatefulWidget {
  const PlanningView({required this.data, super.key});
  final AcademicSnapshot data;
  @override
  State<PlanningView> createState() => _PlanningViewState();
}

class _PlanningViewState extends State<PlanningView> {
  String? selectedId;
  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final semesters = data.semesters
        .where((s) => s.status == SemesterStatus.planned)
        .toList();
    final semester =
        semesters.where((s) => s.id == selectedId).firstOrNull ??
        semesters.firstOrNull;
    final conflicts = semester == null
        ? <ScheduleConflict>[]
        : detectConflicts(semesterSlots(data, semester.id));
    final allocated = semester == null
        ? <String, CreditTotals>{}
        : allocatedCategoryCredits(
            data.courses,
            data.categories,
            plannedSemesterId: semester.id,
          );
    return ListView(
      padding: EdgeInsets.all(AppDensity.pagePadding(context)),
      children: [
        Wrap(
          spacing: AppDensity.controlGap(context),
          runSpacing: AppDensity.sectionGap(context),
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Future semester planning',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            OutlinedButton.icon(
              onPressed: () => showDialog(
                context: context,
                builder: (_) => const SemesterEditor(planned: true),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Create future semester'),
            ),
          ],
        ),
        if (semester == null)
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: AppDensity.cardPadding(context),
            ),
            child: const Text('Create a future semester to start planning.'),
          ),
        if (semester != null) ...[
          DropdownButton<String>(
            isExpanded: true,
            itemHeight: null,
            value: semester.id,
            items: [
              for (final s in semesters)
                DropdownMenuItem(value: s.id, child: Text(s.name)),
            ],
            onChanged: (value) => setState(() => selectedId = value),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: () =>
                  showNthuCoursePicker(context, data: data, semester: semester),
              icon: const Icon(Icons.add),
              label: const Text('Add planned course'),
            ),
          ),
          if (data.coursesIn(semester.id).isEmpty)
            Padding(
              padding: EdgeInsets.all(AppDensity.cardPadding(context)),
              child: const Text('No courses planned for this semester.'),
            ),
          for (final course in data.coursesIn(semester.id))
            CourseRecordTile(course: course),
          const Divider(),
          Text(
            'Graduation impact preview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: AppDensity.sectionGap(context)),
          const Text(
            'Completed credits + all in-progress credits + planned courses in this semester only. Other future plans are excluded.',
          ),
          SizedBox(height: AppDensity.cardPadding(context)),
          CreditSummary(
            totals: creditTotals(data.courses, plannedSemesterId: semester.id),
            target: data.settings.requiredCredits,
            completedCourses: completedCourseCount(data.courses),
          ),
          SizedBox(height: AppDensity.cardPadding(context)),
          for (final category in data.categories)
            CategoryProgressCard(
              name: category.name,
              target: category.requiredCredits,
              totals: allocated[category.id] ?? const CreditTotals(),
              completedCourses: completedCourseCount(
                data.courses,
                categoryId: category.id,
              ),
              overflowCredits: isFreeElectiveCategory(category)
                  ? 0
                  : _planningOverflow(
                      creditTotals(
                        data.courses,
                        categoryId: category.id,
                        plannedSemesterId: semester.id,
                      ),
                      allocated[category.id] ?? const CreditTotals(),
                    ),
              preview: true,
            ),
          Text(
            'Weekly schedule conflicts',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          if (conflicts.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: AppDensity.cardPadding(context),
              ),
              child: const Text('No weekly meeting conflicts detected.'),
            ),
          for (final conflict in conflicts)
            Card.outlined(
              child: Padding(
                padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                child: Text(conflict.description),
              ),
            ),
        ],
      ],
    );
  }
}

double _planningOverflow(CreditTotals raw, CreditTotals allocated) {
  final value = raw.potential - allocated.potential;
  return value > 0 ? value : 0;
}
