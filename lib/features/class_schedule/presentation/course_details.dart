import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/academic_types.dart';
import '../providers/academic_providers.dart';
import 'course_editor.dart';
import 'editor_support.dart';
import 'exception_editor.dart';

class CourseDetails extends ConsumerWidget {
  const CourseDetails({required this.courseId, super.key});
  final String courseId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(academicSnapshotProvider).asData?.value;
    final course = data?.courses.where((c) => c.id == courseId).firstOrNull;
    if (data == null || course == null) {
      return const AlertDialog(content: Text('Course is no longer available.'));
    }

    final semester = data.semesters.firstWhere(
      (s) => s.id == course.semesterId,
    );
    final category = data.categories.firstWhere(
      (c) => c.id == course.graduationCategoryId,
    );
    return AlertDialog(
      title: Text(course.courseName),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 8,
            children: [
              Text(
                'Code: ${course.courseCode.isEmpty ? '—' : course.courseCode}',
              ),
              Text(
                'Credits: ${course.credits} · ${statusLabel(course.status)}',
              ),
              Text('Semester: ${semester.name}'),
              Text('Category: ${category.name}'),
              Text(
                'Location: ${course.location?.isNotEmpty == true ? course.location : 'Not set'}',
              ),
              Text(
                'Professor: ${course.professor?.isNotEmpty == true ? course.professor : 'Not set'}',
              ),
              Text('Tags: ${data.tagsFor(courseId).join(', ')}'),
              if (course.notes?.isNotEmpty ?? false) Text(course.notes!),
              const Divider(),
              Text('Meetings', style: Theme.of(context).textTheme.titleSmall),
              if (data.meetingsFor(courseId).isEmpty)
                const Text('No weekly meetings.'),
              for (final meeting in data.meetingsFor(courseId))
                Text(
                  '${weekdayLabels[meeting.dayOfWeek - 1]} ${timeLabel(meeting.startTime)}–${timeLabel(meeting.endTime)}${meeting.locationOverride?.isNotEmpty == true ? ' · ${meeting.locationOverride}' : ''}',
                ),
              const Divider(),
              Text(
                'One-off changes',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              for (final exception in data.exceptions.where(
                (e) => e.courseId == courseId,
              ))
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    '${dateLabel(exception.date)} · ${statusLabel(exception.type)}',
                  ),
                  subtitle: exception.note?.isNotEmpty == true
                      ? Text(exception.note!)
                      : null,
                  onTap: () => showDialog(
                    context: context,
                    builder: (_) => ExceptionEditor(
                      data: data,
                      courseId: courseId,
                      exception: exception,
                    ),
                  ),
                  trailing: IconButton(
                    tooltip: 'Remove exception',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      if (await confirmAction(
                        context,
                        'Remove this one-off change and restore the weekly schedule?',
                      )) {
                        if (context.mounted) {
                          await runAction(
                            context,
                            () => ref
                                .read(academicRepositoryProvider)
                                .removeException(exception.id),
                          );
                        }
                      }
                    },
                  ),
                ),
              OutlinedButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (_) =>
                      ExceptionEditor(data: data, courseId: courseId),
                ),
                child: const Text('Add one-off change'),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  OutlinedButton(
                    onPressed: () => showDialog(
                      context: context,
                      builder: (_) => CourseEditor(data: data, course: course),
                    ),
                    child: const Text('Edit'),
                  ),
                  OutlinedButton(
                    onPressed: () => runAction(
                      context,
                      () => ref
                          .read(academicRepositoryProvider)
                          .setCourseStatus(courseId, CourseStatus.completed),
                    ),
                    child: const Text('Mark completed'),
                  ),
                  OutlinedButton(
                    onPressed: () => runAction(
                      context,
                      () => ref
                          .read(academicRepositoryProvider)
                          .setCourseStatus(courseId, CourseStatus.withdrawn),
                    ),
                    child: const Text('Mark withdrawn'),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final target = await showDialog<String>(
                        context: context,
                        builder: (context) => SimpleDialog(
                          title: const Text('Duplicate into semester'),
                          children: [
                            for (final s in data.semesters)
                              SimpleDialogOption(
                                onPressed: () => Navigator.pop(context, s.id),
                                child: Text(s.name),
                              ),
                          ],
                        ),
                      );
                      if (target != null && context.mounted) {
                        await showDialog(
                          context: context,
                          builder: (_) => CourseEditor(
                            data: data,
                            course: course,
                            semesterId: target,
                            duplicate: true,
                          ),
                        );
                      }
                    },
                    child: const Text('Duplicate'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (await confirmAction(
                        context,
                        'Delete ${course.courseName} and its meetings?',
                      )) {
                        if (!context.mounted) return;
                        await runAction(
                          context,
                          () => ref
                              .read(academicRepositoryProvider)
                              .removeCourse(courseId),
                        );
                        if (context.mounted) Navigator.pop(context);
                      }
                    },
                    child: const Text('Delete course'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
