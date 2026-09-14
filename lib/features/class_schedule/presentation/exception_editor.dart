import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/academic_database.dart';
import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../providers/academic_providers.dart';
import 'editor_support.dart';

class ExceptionEditor extends ConsumerStatefulWidget {
  const ExceptionEditor({
    required this.data,
    required this.courseId,
    this.exception,
    super.key,
  });

  final AcademicSnapshot data;
  final String courseId;
  final ScheduleException? exception;

  @override
  ConsumerState<ExceptionEditor> createState() => _ExceptionEditorState();
}

class _ExceptionEditorState extends ConsumerState<ExceptionEditor>
    with EditorState {
  late ExceptionType type = widget.exception?.type ?? ExceptionType.cancelled;
  late String? meetingId =
      widget.exception?.meetingId ??
      widget.data.meetingsFor(widget.courseId).firstOrNull?.id;
  late DateTime date = widget.exception?.date ?? dateOnly(DateTime.now());

  late String startPeriod =
      widget.exception?.replacementStartPeriod ??
      nthuRangeForMinutes(
        widget.exception?.replacementStartTime ?? 8 * 60,
        widget.exception?.replacementEndTime ?? 8 * 60 + 50,
      )?.startPeriod ??
      '1';

  late String endPeriod =
      widget.exception?.replacementEndPeriod ??
      nthuRangeForMinutes(
        widget.exception?.replacementStartTime ?? 8 * 60,
        widget.exception?.replacementEndTime ?? 8 * 60 + 50,
      )?.endPeriod ??
      '1';

  late final location = TextEditingController(
    text: widget.exception?.replacementLocation,
  );
  late final note = TextEditingController(text: widget.exception?.note);

  @override
  void dispose() {
    location.dispose();
    note.dispose();
    super.dispose();
  }

  bool get needsReplacementPeriods =>
      type == ExceptionType.rescheduled || type == ExceptionType.extraClass;

  NthuPeriodRange get selectedRange => NthuPeriodRange(startPeriod, endPeriod);

  @override
  Widget build(BuildContext context) => EditorFrame(
    title: 'One-off schedule change',
    formKey: formKey,
    saving: saving,
    error: error,
    onSave: () => submit(() {
      final range = needsReplacementPeriods ? selectedRange : null;
      return ref
          .read(academicRepositoryProvider)
          .saveException(
            id: widget.exception?.id,
            courseId: widget.courseId,
            meetingId: meetingId,
            date: date,
            type: type,
            start: range?.startMinute,
            end: range?.endMinute,
            dayCode: range == null ? null : nthuDayCode(date.weekday),
            startPeriod: range?.startPeriod,
            endPeriod: range?.endPeriod,
            location: location.text,
            note: note.text,
          );
    }),
    child: Column(
      spacing: 7,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        enumField(
          'Change type',
          type,
          ExceptionType.values,
          (value) => setState(() => type = value),
        ),
        DateField(
          label: 'Date',
          date: date,
          onChanged: (value) => setState(() => date = value),
        ),
        if (type != ExceptionType.extraClass)
          DropdownButtonFormField<String>(
            initialValue: meetingId,
            isExpanded: true,
            itemHeight: null,
            decoration: const InputDecoration(
              labelText: 'Weekly meeting to change',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: [
              for (final meeting in widget.data.meetingsFor(widget.courseId))
                DropdownMenuItem(
                  value: meeting.id,
                  child: Text(_meetingLabel(meeting)),
                ),
            ],
            validator: (value) => value == null
                ? 'Select a meeting or choose Extra class.'
                : null,
            onChanged: (value) => setState(() => meetingId = value),
          ),
        if (needsReplacementPeriods) _periodPicker(context),
        if (type != ExceptionType.cancelled)
          editorField(
            location,
            'Replacement room / location',
            required: type == ExceptionType.locationChanged,
          ),
        editorField(note, 'Note', lines: 2),
        Text(
          type == ExceptionType.rescheduled
              ? 'This moves the selected class to a different NTHU period on the same date.'
              : type == ExceptionType.extraClass
              ? 'This adds one extra NTHU class occurrence on the selected date.'
              : 'This change applies to this date only; your normal weekly schedule is unchanged.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    ),
  );

  Widget _periodPicker(BuildContext context) {
    final startIndex = nthuPeriodIndex(startPeriod);
    if (nthuPeriodIndex(endPeriod) < startIndex) endPeriod = startPeriod;
    final range = selectedRange;
    final code = nthuScheduleCode(
      dayCode: nthuDayCode(date.weekday),
      startPeriod: startPeriod,
      endPeriod: endPeriod,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Replacement NTHU periods',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 5),
        FormFieldsRow(
          children: [
            DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              initialValue: startPeriod,
              decoration: const InputDecoration(
                labelText: 'From period',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final period in nthuPeriods)
                  DropdownMenuItem(
                    value: period.code,
                    child: Text('${period.code} · ${period.startLabel}'),
                  ),
              ],
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  startPeriod = value;
                  if (nthuPeriodIndex(endPeriod) < nthuPeriodIndex(value)) {
                    endPeriod = value;
                  }
                });
              },
            ),
            DropdownButtonFormField<String>(
              isExpanded: true,
              itemHeight: null,
              key: ValueKey('exception-end-$startPeriod-$endPeriod'),
              initialValue: endPeriod,
              decoration: const InputDecoration(
                labelText: 'To period',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              items: [
                for (final period in nthuPeriods.where(
                  (item) =>
                      nthuPeriodIndex(item.code) >=
                      nthuPeriodIndex(startPeriod),
                ))
                  DropdownMenuItem(
                    value: period.code,
                    child: Text('${period.code} · ${period.endLabel}'),
                  ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => endPeriod = value);
              },
            ),
          ],
        ),
        const SizedBox(height: 5),
        Wrap(
          spacing: 5,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Chip(label: Text(code)),
            Text(
              '${timeLabel(range.startMinute)}–${timeLabel(range.endMinute)}',
            ),
          ],
        ),
      ],
    );
  }

  String _meetingLabel(ClassMeeting meeting) {
    final hasNthu =
        meeting.dayCode != null &&
        meeting.startPeriod != null &&
        meeting.endPeriod != null;
    final code = hasNthu
        ? nthuScheduleCode(
            dayCode: meeting.dayCode!,
            startPeriod: meeting.startPeriod!,
            endPeriod: meeting.endPeriod!,
          )
        : weekdayLabels[meeting.dayOfWeek - 1];
    return '$code · ${timeLabel(meeting.startTime)}–${timeLabel(meeting.endTime)}';
  }
}
