import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../domain/one_time_event.dart';
import '../domain/schedule_engine.dart';
import 'course_details.dart';

class TodaySchedule extends StatelessWidget {
  const TodaySchedule({
    required this.classes,
    required this.now,
    this.events = const [],
    this.onEventTap,
    this.compact = false,
    this.onOpen,
    super.key,
  });

  final List<ClassOccurrence> classes;
  final DateTime now;
  final List<OneTimeEvent> events;
  final ValueChanged<OneTimeEvent>? onEventTap;
  final bool compact;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    final eventDate =
        classes.firstOrNull?.date ?? events.firstOrNull?.date ?? dateOnly(now);
    final entries =
        <_TodayEntry>[
          for (final occurrence in classes) _TodayEntry.fromClass(occurrence),
          for (final event in eventsForDay(events, eventDate))
            _TodayEntry.fromEvent(event),
        ]..sort((a, b) {
          final time = a.start.compareTo(b.start);
          return time != 0 ? time : a.title.compareTo(b.title);
        });

    if (entries.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(8),
          child: Text(
            'No classes or events today.\nYou’re free for the day.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final next = _nextEntry(entries, now);
    final gaps = _freeTimeGaps(entries);
    final finished = entries.every((entry) => entry.isFinished(now));
    final denseMobile =
        !compact &&
        MediaQuery.sizeOf(context).width < 600 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.4;

    if (compact) {
      final compactItems = <(int, Widget)>[
        for (final entry in entries)
          (
            entry.start,
            _CompactScheduleTile(
              entry: entry,
              now: now,
              isNext: entry.id == next?.id,
              onEventTap: onEventTap,
            ),
          ),
        for (final gap in gaps)
          (
            gap.start,
            Padding(
              padding: const EdgeInsets.fromLTRB(7, 2, 7, 2),
              child: Text(
                'Free ${timeLabel(gap.start)}–${timeLabel(gap.end)} · ${gapLabel(gap)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ]..sort((a, b) => a.$1.compareTo(b.$1));

      return ListView(
        padding: const EdgeInsets.fromLTRB(6, 6, 6, 4),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(1, 0, 1, 3),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    finished
                        ? 'Schedule finished for today'
                        : "Today's schedule",
                    style: Theme.of(context).textTheme.labelLarge,
                  ),
                ),
                Text(
                  '${entries.length} ${entries.length == 1 ? 'item' : 'items'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          ...compactItems.map((item) => item.$2),
        ],
      );
    }

    final items = <(int, Widget)>[
      for (final entry in entries)
        (
          entry.start,
          Opacity(
            opacity: entry.isFinished(now) ? .55 : 1,
            child: Card.outlined(
              margin: const EdgeInsets.symmetric(vertical: 2),
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () => _openEntry(context, entry),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 48),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppDensity.cardPadding(context),
                      vertical: 7,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          entry.event != null
                              ? Icons.event_outlined
                              : entry.isCurrent(now)
                              ? Icons.play_circle_outline
                              : entry.isFinished(now)
                              ? Icons.check_circle_outline
                              : Icons.schedule,
                          size: denseMobile ? 18 : null,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                entry.title,
                                style: Theme.of(context).textTheme.bodyLarge,
                              ),
                              SizedBox(height: AppDensity.tinyGap(context)),
                              Text(
                                entry.subtitle,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        if (entry.isCurrent(now) || entry.id == next?.id) ...[
                          const SizedBox(width: 8),
                          Text(
                            entry.isCurrent(now) ? 'Now' : 'Next',
                            style: Theme.of(context).textTheme.labelSmall,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      for (final gap in gaps)
        (
          gap.start,
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: denseMobile ? 7 : 12,
              vertical: denseMobile ? 2 : 6,
            ),
            child: Text(
              'Free · ${timeLabel(gap.start)}–${timeLabel(gap.end)} · ${gapLabel(gap)}',
              style: denseMobile ? Theme.of(context).textTheme.bodySmall : null,
            ),
          ),
        ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));

    return ListView(
      padding: EdgeInsets.all(denseMobile ? 4 : 8),
      children: [
        if (finished)
          Padding(
            padding: EdgeInsets.all(denseMobile ? 4 : 8),
            child: const Text('Schedule finished for today'),
          ),
        ...items.map((item) => item.$2),
      ],
    );
  }

  void _openEntry(BuildContext context, _TodayEntry entry) {
    final event = entry.event;
    if (event != null) {
      onEventTap?.call(event);
      return;
    }
    showDialog(
      context: context,
      builder: (_) => CourseDetails(courseId: entry.classOccurrence!.course.id),
    );
  }
}

class _CompactScheduleTile extends StatelessWidget {
  const _CompactScheduleTile({
    required this.entry,
    required this.now,
    required this.isNext,
    required this.onEventTap,
  });

  final _TodayEntry entry;
  final DateTime now;
  final bool isNext;
  final ValueChanged<OneTimeEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    final isCurrent = entry.isCurrent(now);
    final isFinished = entry.isFinished(now);
    final scheme = Theme.of(context).colorScheme;

    return Opacity(
      opacity: isFinished && !isCurrent ? .55 : 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 1),
        child: Material(
          color: isCurrent
              ? scheme.primaryContainer.withValues(alpha: .35)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () {
              final event = entry.event;
              if (event != null) {
                onEventTap?.call(event);
              } else {
                showDialog(
                  context: context,
                  builder: (_) =>
                      CourseDetails(courseId: entry.classOccurrence!.course.id),
                );
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (entry.event != null) ...[
                    const Icon(Icons.event_outlined, size: 15),
                    const SizedBox(width: 5),
                  ],
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${entry.scheduleCode} · ${timeLabel(entry.start)}–${timeLabel(entry.end)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.labelLarge,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          entry.title,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (entry.detailLine.isNotEmpty)
                          Text(
                            entry.detailLine,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (isCurrent || isNext)
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Text(
                        isCurrent ? 'NOW' : 'NEXT',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TodayEntry {
  const _TodayEntry({
    required this.id,
    required this.title,
    required this.date,
    required this.start,
    required this.end,
    required this.scheduleCode,
    required this.location,
    this.classOccurrence,
    this.event,
  });

  factory _TodayEntry.fromClass(ClassOccurrence occurrence) => _TodayEntry(
    id: occurrence.id,
    title: occurrence.course.courseName,
    date: occurrence.date,
    start: occurrence.start,
    end: occurrence.end,
    scheduleCode: _nthuCode(occurrence),
    location: occurrence.location,
    classOccurrence: occurrence,
  );

  factory _TodayEntry.fromEvent(OneTimeEvent event) => _TodayEntry(
    id: event.id,
    title: event.title,
    date: event.date,
    start: event.startMinute,
    end: event.endMinute,
    scheduleCode: event.scheduleCode,
    location: event.location,
    event: event,
  );

  final String id;
  final String title;
  final DateTime date;
  final int start;
  final int end;
  final String scheduleCode;
  final String location;
  final ClassOccurrence? classOccurrence;
  final OneTimeEvent? event;

  DateTime get startsAt =>
      DateTime(date.year, date.month, date.day, start ~/ 60, start % 60);
  DateTime get endsAt =>
      DateTime(date.year, date.month, date.day, end ~/ 60, end % 60);

  bool isCurrent(DateTime value) =>
      !value.isBefore(startsAt) && value.isBefore(endsAt);
  bool isFinished(DateTime value) => !value.isBefore(endsAt);

  String get detailLine {
    final eventValue = event;
    if (eventValue != null && eventValue.specificTime.trim().isNotEmpty) {
      return eventValue.specificTime.trim();
    }
    return location == 'Location not set' ? '' : location.trim();
  }

  String get subtitle {
    final eventValue = event;
    final lines = <String>[
      '$scheduleCode · ${timeLabel(start)}–${timeLabel(end)}',
      if (eventValue?.specificTime.trim().isNotEmpty == true)
        'Specific time: ${eventValue!.specificTime.trim()}',
      if (location.trim().isNotEmpty && location != 'Location not set')
        location.trim(),
      if (eventValue?.notes.trim().isNotEmpty == true) eventValue!.notes.trim(),
      if (classOccurrence?.exception != null)
        '${statusLabel(classOccurrence!.exception!.type)}${classOccurrence!.exception!.note?.isNotEmpty == true ? ': ${classOccurrence!.exception!.note}' : ''}',
    ];
    return lines.join(' · ');
  }
}

_TodayEntry? _nextEntry(List<_TodayEntry> entries, DateTime now) =>
    (entries.where((entry) => entry.startsAt.isAfter(now)).toList()
          ..sort((a, b) => a.startsAt.compareTo(b.startsAt)))
        .firstOrNull;

List<FreeGap> _freeTimeGaps(List<_TodayEntry> entries) {
  final sorted = [...entries]..sort((a, b) => a.start.compareTo(b.start));
  if (sorted.isEmpty) return [];
  final result = <FreeGap>[];
  var end = sorted.first.end;
  for (final entry in sorted.skip(1)) {
    if (entry.start > end && containsWholeNthuPeriod(end, entry.start)) {
      result.add(FreeGap(end, entry.start));
    }
    end = math.max(end, entry.end);
  }
  return result;
}

String _nthuCode(ClassOccurrence occurrence) {
  final range = nthuRangeForMinutes(occurrence.start, occurrence.end);
  if (range == null) return 'NTHU';
  return nthuScheduleCode(
    dayCode: nthuDayCode(occurrence.date.weekday),
    startPeriod: range.startPeriod,
    endPeriod: range.endPeriod,
  );
}
