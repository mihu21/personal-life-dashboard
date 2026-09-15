import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../data/demo_seed.dart';
import '../domain/academic_types.dart';
import '../providers/academic_providers.dart';
import 'course_details.dart';
import 'nthu_course_picker.dart';
import 'editor_support.dart';
import 'record_editors.dart';

class RecordsView extends ConsumerStatefulWidget {
  const RecordsView({required this.data, super.key});
  final AcademicSnapshot data;
  @override
  ConsumerState<RecordsView> createState() => _RecordsViewState();
}

class _RecordsViewState extends ConsumerState<RecordsView> {
  int section = 0;
  String? semesterId;

  Future<void> _deleteCategory(GraduationCategory category) async {
    final confirmed = await confirmAction(
      context,
      'Delete ${category.name}? This is only allowed when no courses are assigned to it.',
    );
    if (!confirmed || !mounted) return;
    await runAction(
      context,
      () => ref.read(academicRepositoryProvider).removeCategory(category.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.data;

    final selected =
        data.semesters.where((s) => s.id == semesterId).firstOrNull ??
        data.currentSemester ??
        data.semesters.firstOrNull;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(AppDensity.cardPadding(context)),
          child: Wrap(
            spacing: AppDensity.controlGap(context),
            runSpacing: AppDensity.sectionGap(context),
            children: [
              for (var i = 0; i < 3; i++)
                ChoiceChip(
                  label: Text(['Courses', 'Semesters', 'Categories'][i]),
                  selected: section == i,
                  onSelected: (_) => setState(() => section = i),
                ),
            ],
          ),
        ),
        Expanded(
          child: ListView(
            padding: EdgeInsets.fromLTRB(
              AppDensity.pagePadding(context),
              0,
              AppDensity.pagePadding(context),
              AppDensity.pagePadding(context),
            ),
            children: [
              if (data.semesters.isEmpty && data.courses.isEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    icon: const Icon(Icons.science_outlined),
                    label: const Text('Load fictional demo'),
                    onPressed: () async {
                      if (await confirmAction(
                        context,
                        'Add clearly labeled fictional courses, semesters and a sample credit target to this empty database?',
                        action: 'Load demo',
                      )) {
                        if (context.mounted) {
                          await runAction(
                            context,
                            () => loadAcademicDemo(
                              ref.read(academicRepositoryProvider),
                            ),
                          );
                        }
                      }
                    },
                  ),
                ),
              if (!data.settings.setupDismissed && data.courses.isEmpty)
                Card.outlined(
                  child: Padding(
                    padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Set up your academic records',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Text(
                          'Set a credit target, review categories, create a semester, then add your first course.',
                        ),
                        Wrap(
                          spacing: AppDensity.controlGap(context),
                          children: [
                            TextButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) =>
                                    GraduationRequirementsEditor(data: data),
                              ),
                              child: const Text('1. Graduation requirements'),
                            ),
                            TextButton(
                              onPressed: () => setState(() => section = 2),
                              child: const Text('2. Categories'),
                            ),
                            TextButton(
                              onPressed: () => showDialog(
                                context: context,
                                builder: (_) => const SemesterEditor(),
                              ),
                              child: const Text('3. Semester'),
                            ),
                            TextButton(
                              onPressed: data.semesters.isEmpty
                                  ? null
                                  : () => showDialog(
                                      context: context,
                                      builder: (_) => NthuCoursePickerDialog(
                                        data: data,
                                        semester:
                                            data.currentSemester ??
                                            data.semesters.first,
                                      ),
                                    ),
                              child: const Text('4. First course'),
                            ),
                            TextButton(
                              onPressed: () => runAction(
                                context,
                                () => ref
                                    .read(academicRepositoryProvider)
                                    .saveSettings(
                                      requiredCredits:
                                          data.settings.requiredCredits,
                                      setupDismissed: true,
                                    ),
                              ),
                              child: const Text('Skip setup'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              if (section == 0) ...[
                if (selected != null)
                  DropdownButton<String>(
                    isExpanded: true,
                    itemHeight: null,
                    value: selected.id,
                    items: [
                      for (final s in data.semesters)
                        DropdownMenuItem(value: s.id, child: Text(s.name)),
                    ],
                    onChanged: (id) => setState(() => semesterId = id),
                  ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: selected == null
                        ? null
                        : () => showNthuCoursePicker(
                            context,
                            data: data,
                            semester: selected,
                          ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add from NTHU catalog'),
                  ),
                ),
                if (selected == null)
                  Padding(
                    padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                    child: const Text(
                      'Create a semester to start adding courses.',
                    ),
                  ),
                if (selected != null && data.coursesIn(selected.id).isEmpty)
                  Padding(
                    padding: EdgeInsets.all(AppDensity.cardPadding(context)),
                    child: const Text('No courses in this semester.'),
                  ),
                if (selected != null)
                  for (final course in data.coursesIn(selected.id))
                    CourseRecordTile(course: course),
              ],
              if (section == 1) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => const SemesterEditor(),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Create semester'),
                  ),
                ),
                for (final s in data.semesters)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(s.name),
                    subtitle: Text(
                      '${statusLabel(s.status)} · ${dateLabel(s.startDate)} – ${dateLabel(s.endDate)}',
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) => SemesterEditor(semester: s),
                    ),
                    trailing: PopupMenuButton<String>(
                      tooltip: 'Semester actions',
                      onSelected: (action) async {
                        if (action == 'delete') {
                          final courseCount = data.coursesIn(s.id).length;
                          final message = courseCount == 0
                              ? 'Delete “${s.name}”? This cannot be undone.'
                              : 'Delete “${s.name}”? This semester contains '
                                    '$courseCount course${courseCount == 1 ? '' : 's'}. '
                                    'Deleting it will also remove all of those '
                                    'courses and their schedule data.';
                          if (await confirmAction(
                            context,
                            message,
                            action: courseCount == 0
                                ? 'Delete semester'
                                : 'Delete semester & courses',
                          )) {
                            if (context.mounted) {
                              await runAction(
                                context,
                                () => ref
                                    .read(academicRepositoryProvider)
                                    .removeSemester(
                                      s.id,
                                      confirmed: courseCount > 0,
                                    ),
                              );
                            }
                          }
                        } else {
                          await runAction(
                            context,
                            () => ref
                                .read(academicRepositoryProvider)
                                .saveSemester(
                                  id: s.id,
                                  name: s.name,
                                  academicYear: s.academicYear,
                                  term: s.term,
                                  start: s.startDate,
                                  end: s.endDate,
                                  status: SemesterStatus.values.byName(action),
                                ),
                          );
                        }
                      },
                      itemBuilder: (_) => [
                        for (final status in SemesterStatus.values)
                          PopupMenuItem(
                            value: status.name,
                            child: Text(
                              'Mark ${statusLabel(status).toLowerCase()}',
                            ),
                          ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete semester'),
                        ),
                      ],
                    ),
                  ),
              ],
              if (section == 2) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: FilledButton.icon(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CategoryEditor(sortOrder: data.categories.length),
                    ),
                    icon: const Icon(Icons.add),
                    label: const Text('Add category'),
                  ),
                ),
                for (var i = 0; i < data.categories.length; i++)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(data.categories[i].name),
                    subtitle: Text(
                      '${data.categories[i].requiredCredits ?? 'No'} required credits${data.categories[i].isActive ? '' : ' · Hidden'}',
                    ),
                    onTap: () => showDialog(
                      context: context,
                      builder: (_) =>
                          CategoryEditor(category: data.categories[i]),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          tooltip: 'Move category up',
                          icon: const Icon(Icons.arrow_upward),
                          onPressed: i == 0 ? null : () => _move(i, i - 1),
                        ),
                        IconButton(
                          tooltip: 'Move category down',
                          icon: const Icon(Icons.arrow_downward),
                          onPressed: i == data.categories.length - 1
                              ? null
                              : () => _move(i, i + 1),
                        ),
                        IconButton(
                          tooltip:
                              data.categories[i].name.trim().toLowerCase() ==
                                  'free elective'
                              ? 'Free Elective is required for overflow credits'
                              : 'Delete category',
                          icon: const Icon(Icons.delete_outline),
                          onPressed:
                              data.categories[i].name.trim().toLowerCase() ==
                                  'free elective'
                              ? null
                              : () => _deleteCategory(data.categories[i]),
                        ),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _move(int from, int to) {
    final ids = widget.data.categories.map((c) => c.id).toList();
    final moved = ids.removeAt(from);
    ids.insert(to, moved);
    runAction(
      context,
      () => ref.read(academicRepositoryProvider).reorderCategories(ids),
    );
  }
}

class CourseRecordTile extends StatelessWidget {
  const CourseRecordTile({required this.course, super.key});
  final Course course;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(course.courseName),
    subtitle: Text('${course.credits} credits · ${statusLabel(course.status)}'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () => showDialog(
      context: context,
      builder: (_) => CourseDetails(courseId: course.id),
    ),
  );
}
