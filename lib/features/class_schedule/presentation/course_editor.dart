import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/course_draft.dart';
import '../domain/schedule_conflicts.dart';
import '../providers/academic_providers.dart';
import 'editor_support.dart';
import 'meeting_fields.dart';
import 'conflict_warning.dart';

class CourseEditor extends ConsumerStatefulWidget {
  const CourseEditor({
    required this.data,
    this.course,
    this.semesterId,
    this.planned = false,
    this.duplicate = false,
    super.key,
  });
  final AcademicSnapshot data;
  final Course? course;
  final String? semesterId;
  final bool planned;
  final bool duplicate;
  @override
  ConsumerState<CourseEditor> createState() => _CourseEditorState();
}

class _CourseEditorState extends ConsumerState<CourseEditor> with EditorState {
  late final name = TextEditingController(text: widget.course?.courseName);
  late final code = TextEditingController(text: widget.course?.courseCode);
  late final credits = TextEditingController(
    text: widget.course?.credits.toString() ?? '3',
  );
  late final professor = TextEditingController(text: widget.course?.professor);
  late final location = TextEditingController(text: widget.course?.location);
  late final notes = TextEditingController(text: widget.course?.notes);
  late final tags = TextEditingController(
    text: widget.course == null
        ? ''
        : widget.data.tagsFor(widget.course!.id).join(', '),
  );
  late String? semester =
      widget.semesterId ??
      widget.course?.semesterId ??
      widget.data.currentSemester?.id ??
      widget.data.semesters.firstOrNull?.id;
  late String? category = widget.course?.graduationCategoryId;
  late CourseStatus status =
      (widget.duplicate ? null : widget.course?.status) ??
      _defaultStatusForSemester();

  CourseStatus _defaultStatusForSemester() {
    if (widget.planned) return CourseStatus.planned;
    final semesterStatus = widget.data.semesters
        .where((item) => item.id == semester)
        .firstOrNull
        ?.status;
    return switch (semesterStatus) {
      SemesterStatus.planned => CourseStatus.planned,
      SemesterStatus.completed ||
      SemesterStatus.archived => CourseStatus.completed,
      SemesterStatus.current || null => CourseStatus.inProgress,
    };
  }

  late final meetings = widget.course == null
      ? <MeetingFields>[]
      : widget.data
            .meetingsFor(widget.course!.id)
            .map(
              (m) => MeetingFields(
                MeetingDraft(
                  id: widget.duplicate ? null : m.id,
                  day: m.dayOfWeek,
                  start: m.startTime,
                  end: m.endTime,
                  location: m.locationOverride,
                  dayCode: m.dayCode,
                  startPeriod: m.startPeriod,
                  endPeriod: m.endPeriod,
                  needsReview: m.needsReview,
                ),
              ),
            )
            .toList();
  @override
  void dispose() {
    for (final controller in [
      name,
      code,
      credits,
      professor,
      location,
      notes,
      tags,
    ]) {
      controller.dispose();
    }
    for (final meeting in meetings) {
      meeting.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: widget.duplicate
        ? 'Duplicate course'
        : widget.course == null
        ? 'Add course'
        : 'Edit course',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(
      () => ref
          .read(academicRepositoryProvider)
          .saveCourse(
            CourseDraft(
              id: widget.duplicate ? null : widget.course?.id,
              name: name.text,
              code: code.text,
              credits: double.parse(credits.text),
              semesterId: semester!,
              categoryId: category!,
              status: status,
              professor: professor.text,
              location: location.text,
              notes: notes.text,
              tags: tags.text.split(','),
              meetings: meetings.map((m) => m.toDraft()).toList(),
              catalogCourseId: widget.course?.catalogCourseId,
              englishName: widget.course?.englishName,
              teachingLanguage: widget.course?.teachingLanguage,
            ),
          ),
      beforeSave: () async {
        final latest = await ref.read(academicRepositoryProvider).snapshot();
        if (!context.mounted) return false;
        return confirmConflicts(
          context,
          draftConflicts(
            latest,
            CourseDraft(
              id: widget.duplicate ? null : widget.course?.id,
              name: name.text,
              credits: double.parse(credits.text),
              semesterId: semester!,
              categoryId: category!,
              status: status,
              meetings: meetings.map((m) => m.toDraft()).toList(),
            ),
          ),
        );
      },
    ),
    child: Column(
      spacing: AppDensity.formGap(context),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        editorField(name, 'Course name', required: true),
        DropdownButtonFormField<String>(
          initialValue: semester,
          isExpanded: true,
          itemHeight: null,
          decoration: const InputDecoration(
            labelText: 'Semester',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final s in widget.data.semesters)
              DropdownMenuItem(value: s.id, child: Text(s.name)),
          ],
          validator: (value) =>
              value == null ? 'Create and select a semester first.' : null,
          onChanged: (value) => semester = value,
        ),
        DropdownButtonFormField<String>(
          initialValue: category,
          isExpanded: true,
          itemHeight: null,
          decoration: const InputDecoration(
            labelText: 'Graduation category',
            border: OutlineInputBorder(),
          ),
          items: [
            for (final c in widget.data.categories.where(
              (c) => c.isActive || c.id == category,
            ))
              DropdownMenuItem(value: c.id, child: Text(c.name)),
          ],
          validator: (value) =>
              value == null ? 'Create and select a category first.' : null,
          onChanged: (value) => category = value,
        ),
        enumField(
          'Course status',
          status,
          CourseStatus.values,
          (value) => setState(() => status = value),
        ),
        FormFieldsRow(
          children: [
            editorField(code, 'Course code (optional)'),
            editorField(
              credits,
              'Credits',
              numeric: true,
              validator: (value) {
                final number = double.tryParse(value ?? '');
                return number != null && number.isFinite && number >= 0
                    ? null
                    : 'Credits cannot be negative.';
              },
            ),
          ],
        ),
        FormFieldsRow(
          children: [
            editorField(professor, 'Professor (optional)'),
            editorField(location, 'Default location (optional)'),
          ],
        ),
        editorField(tags, 'Tags (comma-separated)'),
        editorField(notes, 'Notes', lines: 3),
        Text(
          'NTHU weekly periods',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        for (final meeting in meetings)
          MeetingFieldsWidget(
            key: ObjectKey(meeting),
            fields: meeting,
            onRemove: () => setState(() {
              meetings.remove(meeting);
              meeting.dispose();
            }),
          ),
        OutlinedButton.icon(
          onPressed: () => setState(() => meetings.add(MeetingFields())),
          icon: const Icon(Icons.add),
          label: const Text('Add NTHU meeting'),
        ),
      ],
    ),
  );
}
