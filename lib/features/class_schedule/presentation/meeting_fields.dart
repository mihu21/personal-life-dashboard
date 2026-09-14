import 'package:flutter/material.dart';

import '../domain/academic_types.dart';
import '../domain/course_draft.dart';
import '../domain/nthu_academic.dart';
import 'editor_support.dart';

class MeetingFields {
  MeetingFields([MeetingDraft? meeting])
    : id = meeting?.id,
      dayCode = meeting?.dayCode ?? nthuDayCode(meeting?.day ?? 1),
      startPeriod =
          meeting?.startPeriod ??
          nthuRangeForMinutes(
            meeting?.start ?? 480,
            meeting?.end ?? 590,
          )?.startPeriod ??
          '1',
      endPeriod =
          meeting?.endPeriod ??
          nthuRangeForMinutes(
            meeting?.start ?? 480,
            meeting?.end ?? 590,
          )?.endPeriod ??
          '2',
      location = TextEditingController(text: meeting?.location),
      needsReview = meeting?.needsReview ?? false;

  final String? id;
  String dayCode;
  String startPeriod;
  String endPeriod;
  final TextEditingController location;
  bool needsReview;

  MeetingDraft toDraft() => MeetingDraft.nthu(
    id: id,
    dayCode: dayCode,
    startPeriod: startPeriod,
    endPeriod: endPeriod,
    location: location.text,
  );

  void dispose() => location.dispose();
}

int? parseTime(String value) {
  final parts = value.trim().split(':');
  if (parts.length != 2) return null;
  final hour = int.tryParse(parts[0]);
  final minute = int.tryParse(parts[1]);
  if (hour == null ||
      minute == null ||
      hour < 0 ||
      hour > 24 ||
      minute < 0 ||
      minute > 59 ||
      hour == 24 && minute != 0) {
    return null;
  }
  return hour * 60 + minute;
}

class MeetingFieldsWidget extends StatefulWidget {
  const MeetingFieldsWidget({
    required this.fields,
    required this.onRemove,
    super.key,
  });

  final MeetingFields fields;
  final VoidCallback onRemove;

  @override
  State<MeetingFieldsWidget> createState() => _MeetingFieldsWidgetState();
}

class _MeetingFieldsWidgetState extends State<MeetingFieldsWidget> {
  MeetingFields get fields => widget.fields;

  @override
  Widget build(BuildContext context) {
    final startIndex = nthuPeriodIndex(fields.startPeriod);
    final endIndex = nthuPeriodIndex(fields.endPeriod);
    final safeEnd = endIndex >= startIndex
        ? fields.endPeriod
        : fields.startPeriod;
    if (safeEnd != fields.endPeriod) fields.endPeriod = safeEnd;

    final range = NthuPeriodRange(fields.startPeriod, fields.endPeriod);
    return Card.outlined(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: DropdownButtonFormField<String>(
                    key: ValueKey('meeting-day-${fields.dayCode}'),
                    initialValue: fields.dayCode,
                    isExpanded: true,
                    itemHeight: null,
                    decoration: const InputDecoration(
                      labelText: 'Day',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: [
                      for (var i = 0; i < nthuDayCodes.length; i++)
                        DropdownMenuItem(
                          value: nthuDayCodes[i],
                          child: Text(
                            '${nthuDayNames[i].substring(0, 3)} (${nthuDayCodes[i]})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    selectedItemBuilder: (context) => [
                      for (var i = 0; i < nthuDayCodes.length; i++)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${nthuDayNames[i].substring(0, 3)} (${nthuDayCodes[i]})',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => fields.dayCode = value);
                      }
                    },
                  ),
                ),
                IconButton(
                  tooltip: 'Remove meeting',
                  onPressed: widget.onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 10),
            FormFieldsRow(
              minFieldWidth: 135,
              children: [
                DropdownButtonFormField<String>(
                  key: ValueKey('meeting-start-${fields.startPeriod}'),
                  initialValue: fields.startPeriod,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(
                    labelText: 'Start period',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final period in nthuPeriods)
                      DropdownMenuItem(
                        value: period.code,
                        child: Text(
                          '${period.code}  ${period.startLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  selectedItemBuilder: (context) => [
                    for (final period in nthuPeriods)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${period.code} · ${period.startLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() {
                      fields.startPeriod = value;
                      if (nthuPeriodIndex(fields.endPeriod) <
                          nthuPeriodIndex(value)) {
                        fields.endPeriod = value;
                      }
                    });
                  },
                ),
                DropdownButtonFormField<String>(
                  key: ValueKey(
                    'meeting-end-${fields.startPeriod}-${fields.endPeriod}',
                  ),
                  initialValue: fields.endPeriod,
                  isExpanded: true,
                  itemHeight: null,
                  decoration: const InputDecoration(
                    labelText: 'End period',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  items: [
                    for (final period in nthuPeriods.where(
                      (item) =>
                          nthuPeriodIndex(item.code) >=
                          nthuPeriodIndex(fields.startPeriod),
                    ))
                      DropdownMenuItem(
                        value: period.code,
                        child: Text(
                          '${period.code}  ${period.endLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  selectedItemBuilder: (context) => [
                    for (final period in nthuPeriods.where(
                      (item) =>
                          nthuPeriodIndex(item.code) >=
                          nthuPeriodIndex(fields.startPeriod),
                    ))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          '${period.code} · ${period.endLabel}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => fields.endPeriod = value);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 5),
            Wrap(
              spacing: 5,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Chip(
                  avatar: const Icon(Icons.schedule, size: 16),
                  label: Text(
                    nthuScheduleCode(
                      dayCode: fields.dayCode,
                      startPeriod: fields.startPeriod,
                      endPeriod: fields.endPeriod,
                    ),
                  ),
                ),
                Text(
                  '${timeLabel(range.startMinute)}–${timeLabel(range.endMinute)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 5),
            editorField(fields.location, 'Room / location (optional)'),
            if (fields.needsReview)
              Padding(
                padding: const EdgeInsets.only(top: 5),
                child: Text(
                  'This meeting came from an older free-form time. Review the NTHU periods before saving.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
