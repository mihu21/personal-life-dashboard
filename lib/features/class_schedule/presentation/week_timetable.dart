import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/nthu_academic.dart';
import '../domain/one_time_event.dart';
import '../domain/schedule_engine.dart';
import 'course_details.dart';

class WeekTimetable extends StatelessWidget {
  const WeekTimetable({
    required this.data,
    required this.semesterId,
    required this.date,
    required this.now,
    this.events = const [],
    this.onEventTap,
    this.compact = false,
    super.key,
  });

  final AcademicSnapshot data;
  final String semesterId;
  final DateTime date;
  final DateTime now;
  final List<OneTimeEvent> events;
  final ValueChanged<OneTimeEvent>? onEventTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final start = weekStart(date);
    final allDays = List.generate(7, (index) {
      final day = calendarDay(start, index);
      final entries = <_TimetableEntry>[
        for (final occurrence in scheduleForDay(data, semesterId, day))
          _TimetableEntry.fromClass(occurrence),
        for (final event in eventsForDay(events, day))
          _TimetableEntry.fromEvent(event),
      ];
      entries.sort((a, b) {
        final time = a.start.compareTo(b.start);
        return time != 0 ? time : a.title.compareTo(b.title);
      });
      return entries;
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final denseMobile = AppDensity.isMobile(context);

        // Measure the axis/header text once, then let desktop rows shrink to
        // the available panel height. This keeps every NTHU period visible in
        // both the dashboard card and the expanded desktop schedule.
        final textScaler = MediaQuery.textScalerOf(context);
        final textDirection = Directionality.of(context);
        final timeStyle = denseMobile
            ? Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 9)
            : Theme.of(context).textTheme.labelSmall;
        final headerStyle = denseMobile
            ? Theme.of(context).textTheme.labelSmall
            : Theme.of(context).textTheme.labelMedium;
        final timePainter = TextPainter(
          text: TextSpan(text: '00:00', style: timeStyle),
          textDirection: textDirection,
          textScaler: textScaler,
          maxLines: 1,
        )..layout();
        final headerPainter = TextPainter(
          text: TextSpan(text: 'Wed  9/16', style: headerStyle),
          textDirection: textDirection,
          textScaler: textScaler,
          maxLines: 1,
        )..layout();
        final titleStyle = Theme.of(context).textTheme.labelLarge?.copyWith(
          fontSize: denseMobile ? 10.5 : 12,
          height: denseMobile ? 1.12 : 1.15,
        );
        final titlePainter = TextPainter(
          text: TextSpan(text: 'Course title', style: titleStyle),
          textDirection: textDirection,
          textScaler: textScaler,
        )..layout();

        final baseRowHeight = denseMobile || compact ? 40.0 : 48.0;
        final baseHeaderHeight = denseMobile || compact ? 28.0 : 36.0;
        final naturalRowHeight = math.max(
          baseRowHeight,
          math.max(timePainter.height * 2 + 12, titlePainter.height * 2 + 10),
        );
        final naturalHeaderHeight = math.max(
          baseHeaderHeight,
          headerPainter.height + (denseMobile ? 6.0 : 10.0),
        );
        final axisWidth = math.max(
          denseMobile ? 46.0 : 62.0,
          (denseMobile ? 2.0 : 3.0) * 2 +
              textScaler.scale(denseMobile ? 10.0 : 16.0) +
              2.0 +
              timePainter.width,
        );

        late final double headerHeight;
        late final double rowHeight;
        late final double height;
        late final double width;
        late final List<double> dayWidths;

        final compactMobile = denseMobile && textScale <= 1.4;
        final days = allDays;

        if (compactMobile) {
          // Keep the same readable mobile column width that fits five weekdays
          // on screen, but retain all seven days in the grid. Saturday and
          // Sunday are reached with a horizontal swipe instead of making every
          // column narrower or shrinking course text.
          final viewportWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : 360.0;
          final availableHeight = constraints.hasBoundedHeight
              ? math.max(1.0, constraints.maxHeight)
              : naturalHeaderHeight + naturalRowHeight * nthuPeriods.length;
          headerHeight = math.min(
            naturalHeaderHeight,
            math.max(22.0, availableHeight * .075),
          );
          final fittedRowHeight = math.max(
            1.0,
            (availableHeight - headerHeight) / nthuPeriods.length,
          );
          rowHeight = constraints.hasBoundedHeight
              ? math.min(naturalRowHeight, fittedRowHeight)
              : naturalRowHeight;
          height = headerHeight + rowHeight * nthuPeriods.length;
          final dayWidth = math.max(1.0, (viewportWidth - axisWidth) / 5);
          dayWidths = List<double>.filled(
            days.length,
            dayWidth,
            growable: false,
          );
          width = axisWidth + dayWidth * days.length;
        } else if (denseMobile) {
          // At large accessibility text sizes preserve readability by allowing
          // scrolling instead of forcing seven enlarged columns into the phone.
          headerHeight = naturalHeaderHeight;
          rowHeight = naturalRowHeight;
          height = headerHeight + rowHeight * nthuPeriods.length;
          final dayWidth = math.max(104.0 * textScale, 104.0);
          dayWidths = List<double>.filled(
            days.length,
            dayWidth,
            growable: false,
          );
          final minimumWidth = axisWidth + dayWidth * days.length;
          width = constraints.hasBoundedWidth
              ? math.max(constraints.maxWidth, minimumWidth)
              : minimumWidth;
        } else {
          // Desktop uses the viewport itself: no timetable scrolling, equal day
          // columns, and rows compressed only as much as necessary to show the
          // full 1-d period range at once.
          width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : axisWidth + 7 * (compact ? 96.0 : 120.0);
          final availableHeight = constraints.hasBoundedHeight
              ? math.max(1.0, constraints.maxHeight)
              : naturalHeaderHeight + naturalRowHeight * nthuPeriods.length;
          headerHeight = constraints.hasBoundedHeight
              ? math.min(
                  naturalHeaderHeight,
                  math.max(18.0, availableHeight * .12),
                )
              : naturalHeaderHeight;
          final fittedRowHeight = math.max(
            1.0,
            (availableHeight - headerHeight) / nthuPeriods.length,
          );
          rowHeight = constraints.hasBoundedHeight
              ? math.min(naturalRowHeight, fittedRowHeight)
              : naturalRowHeight;
          height = headerHeight + rowHeight * nthuPeriods.length;
          final dayWidth = math.max(1.0, (width - axisWidth) / 7);
          dayWidths = List<double>.filled(7, dayWidth, growable: false);
        }

        timePainter.dispose();
        headerPainter.dispose();
        titlePainter.dispose();

        final grid = _NthuGrid(
          data: data,
          days: days,
          weekStartDate: start,
          now: now,
          compact: compact,
          denseMobile: denseMobile,
          width: width,
          height: height,
          axisWidth: axisWidth,
          headerHeight: headerHeight,
          rowHeight: rowHeight,
          dayWidths: dayWidths,
          onEventTap: onEventTap,
        );

        if (denseMobile) {
          if (compactMobile) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SizedBox(width: width, height: height, child: grid),
            );
          }

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: width,
              child: SingleChildScrollView(child: grid),
            ),
          );
        }

        return SizedBox(width: width, height: height, child: grid);
      },
    );
  }
}

class _NthuGrid extends StatelessWidget {
  const _NthuGrid({
    required this.data,
    required this.days,
    required this.weekStartDate,
    required this.now,
    required this.compact,
    required this.denseMobile,
    required this.width,
    required this.height,
    required this.axisWidth,
    required this.headerHeight,
    required this.rowHeight,
    required this.dayWidths,
    required this.onEventTap,
  });

  final AcademicSnapshot data;
  final List<List<_TimetableEntry>> days;
  final DateTime weekStartDate;
  final DateTime now;
  final bool compact;
  final bool denseMobile;
  final double width;
  final double height;
  final double axisWidth;
  final double headerHeight;
  final double rowHeight;
  final List<double> dayWidths;
  final ValueChanged<OneTimeEvent>? onEventTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    double dayLeft(int index) =>
        axisWidth + dayWidths.take(index).fold<double>(0, (a, b) => a + b);
    final children = <Widget>[];

    children.add(
      Positioned(
        left: 0,
        top: 0,
        width: axisWidth,
        height: headerHeight,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.surfaceContainerLow,
            border: Border(
              right: BorderSide(color: scheme.outlineVariant),
              bottom: BorderSide(color: scheme.outlineVariant),
            ),
          ),
          child: Text('Time', style: Theme.of(context).textTheme.labelSmall),
        ),
      ),
    );

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final dayWidth = dayWidths[dayIndex];
      final day = calendarDay(weekStartDate, dayIndex);
      final isToday = dateOnly(day) == dateOnly(now);
      children.add(
        Positioned(
          left: dayLeft(dayIndex),
          top: 0,
          width: dayWidth,
          height: height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: isToday ? scheme.primary.withValues(alpha: .055) : null,
              border: Border(right: BorderSide(color: scheme.outlineVariant)),
            ),
          ),
        ),
      );
      children.add(
        Positioned(
          left: dayLeft(dayIndex),
          top: 0,
          width: dayWidth,
          height: headerHeight,
          child: Container(
            key: ValueKey('week-day-header-$dayIndex'),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isToday
                  ? scheme.primaryContainer.withValues(alpha: .45)
                  : scheme.surfaceContainerLow,
              border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
            ),
            child: Text(
              compact || denseMobile
                  ? weekdayLabels[dayIndex]
                  : '${weekdayLabels[dayIndex]}  ${day.month}/${day.day}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (denseMobile
                          ? Theme.of(context).textTheme.labelSmall
                          : Theme.of(context).textTheme.labelMedium)
                      ?.copyWith(fontWeight: isToday ? FontWeight.w700 : null),
            ),
          ),
        ),
      );
    }

    for (var periodIndex = 0; periodIndex < nthuPeriods.length; periodIndex++) {
      final period = nthuPeriods[periodIndex];
      final top = headerHeight + periodIndex * rowHeight;
      final activeNow =
          _isCurrentPeriod(period, now) && weekStart(now) == weekStartDate;

      children.add(
        Positioned(
          left: 0,
          top: top,
          width: axisWidth,
          height: rowHeight,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 2 : 3,
            ),
            alignment: Alignment.centerLeft,
            decoration: BoxDecoration(
              color: activeNow
                  ? scheme.primaryContainer.withValues(alpha: .55)
                  : scheme.surfaceContainerLowest,
              border: Border(
                right: BorderSide(color: scheme.outlineVariant),
                bottom: BorderSide(
                  color: scheme.outlineVariant.withValues(alpha: .75),
                ),
              ),
            ),
            child: LayoutBuilder(
              builder: (context, bounds) {
                final periodStyle = Theme.of(context).textTheme.labelSmall
                    ?.copyWith(
                      fontSize: denseMobile
                          ? 9
                          : compact
                          ? 10
                          : 11,
                      height: 1,
                    );
                if (bounds.maxHeight < 18) {
                  return Center(
                    child: Text(
                      period.code,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: periodStyle,
                    ),
                  );
                }

                final timeLabelStyle = Theme.of(context).textTheme.labelSmall
                    ?.copyWith(
                      fontSize: denseMobile
                          ? 8.5
                          : compact
                          ? 9.5
                          : 10,
                      height: 1,
                      color: scheme.onSurfaceVariant,
                    );
                return Row(
                  children: [
                    SizedBox(
                      width: MediaQuery.textScalerOf(
                        context,
                      ).scale(denseMobile ? 10 : 14),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          period.code,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: periodStyle,
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Column(
                        children: [
                          for (final label in [
                            period.startLabel,
                            period.endLabel,
                          ])
                            Expanded(
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  label,
                                  maxLines: 1,
                                  overflow: TextOverflow.clip,
                                  style: timeLabelStyle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );
      children.add(
        Positioned(
          left: axisWidth,
          right: 0,
          top: top + rowHeight - 1,
          child: Divider(
            height: 1,
            color: scheme.outlineVariant.withValues(alpha: .65),
          ),
        ),
      );
    }

    for (var dayIndex = 0; dayIndex < days.length; dayIndex++) {
      final dayWidth = dayWidths[dayIndex];
      final entries = days[dayIndex];
      final laneData = _lanesFor(entries);
      for (var itemIndex = 0; itemIndex < entries.length; itemIndex++) {
        final entry = entries[itemIndex];
        final range = _rangeForEntry(entry);
        if (range == null) continue;
        final placement = laneData[itemIndex];
        final laneCount = math.max(1, placement.laneCount);
        final laneWidth = dayWidth / laneCount;
        final top = headerHeight + range.$1 * rowHeight + 1;
        final blockHeight = math.max(
          2.0,
          (range.$2 - range.$1 + 1) * rowHeight - 2,
        );

        final course = entry.classOccurrence?.course;
        final categoryIndex = course == null
            ? -1
            : data.categories.indexWhere(
                (item) => item.id == course.graduationCategoryId,
              );
        final accent = entry.event != null
            ? scheme.tertiary
            : [
                scheme.primary,
                scheme.tertiary,
                scheme.secondary,
              ][math.max(0, categoryIndex) % 3];
        final dayCode = nthuDayCode(dayIndex + 1);
        final scheduleCode =
            entry.event?.scheduleCode ??
            nthuScheduleCode(
              dayCode: dayCode,
              startPeriod: nthuPeriods[range.$1].code,
              endPeriod: nthuPeriods[range.$2].code,
            );
        final event = entry.event;
        final details = <String>[
          '$scheduleCode · ${timeLabel(entry.start)}–${timeLabel(entry.end)}',
          entry.title,
          if (entry.location.trim().isNotEmpty) entry.location,
          if (event?.specificTime.trim().isNotEmpty == true)
            'Specific time: ${event!.specificTime}',
          if (event?.notes.trim().isNotEmpty == true) event!.notes,
        ].join('\n');

        children.add(
          Positioned(
            key: ValueKey(
              event == null
                  ? 'week-occurrence-${entry.id}'
                  : 'week-event-${entry.id}',
            ),
            left: dayLeft(dayIndex) + placement.lane * laneWidth + 2,
            top: top,
            width: math.max(2, laneWidth - 4),
            height: blockHeight,
            child: Tooltip(
              message: details,
              child: Material(
                color: accent.withValues(alpha: event == null ? .16 : .2),
                borderRadius: BorderRadius.circular(
                  compact
                      ? 3
                      : denseMobile
                      ? 4
                      : 6,
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: event != null
                      ? onEventTap == null
                            ? null
                            : () => onEventTap!(event)
                      : () => showDialog(
                          context: context,
                          builder: (_) => CourseDetails(courseId: course!.id),
                        ),
                  child: Container(
                    padding: EdgeInsets.all(
                      blockHeight < 20
                          ? 1
                          : denseMobile || compact
                          ? 2
                          : 4,
                    ),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: accent,
                          width: denseMobile ? 2 : 3,
                        ),
                      ),
                    ),
                    child: LayoutBuilder(
                      builder: (context, bounds) {
                        final scaler = MediaQuery.textScalerOf(context);
                        final style = Theme.of(context).textTheme.labelLarge
                            ?.copyWith(
                              fontSize: denseMobile ? 10.5 : 12,
                              height: denseMobile ? 1.12 : 1.15,
                            );
                        if (bounds.maxHeight < 18 || bounds.maxWidth < 28) {
                          return Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              entry.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: style,
                            ),
                          );
                        }
                        final painter = TextPainter(
                          text: TextSpan(text: entry.title, style: style),
                          textScaler: scaler,
                          textDirection: Directionality.of(context),
                          maxLines: 2,
                          ellipsis: '…',
                        )..layout(maxWidth: bounds.maxWidth);
                        final metaHeight =
                            scaler.scale(denseMobile ? 10 : 11) * 1.5;
                        final showCode =
                            bounds.maxWidth >= (denseMobile ? 68 : 64) &&
                            bounds.maxHeight >= painter.height + metaHeight + 4;
                        final showLocation =
                            entry.location.isNotEmpty &&
                            bounds.maxWidth >= (denseMobile ? 72 : 64) &&
                            bounds.maxHeight >=
                                painter.height + metaHeight * 2 + 6;
                        final titleLines =
                            ((bounds.maxHeight -
                                        (showCode ? metaHeight : 0) -
                                        (showLocation ? metaHeight : 0)) /
                                    painter.preferredLineHeight)
                                .floor()
                                .clamp(1, 2);
                        painter.dispose();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showCode)
                              Row(
                                children: [
                                  if (event != null) ...[
                                    Icon(
                                      Icons.event_outlined,
                                      size: denseMobile ? 10 : 12,
                                      color: scheme.onSurfaceVariant,
                                    ),
                                    const SizedBox(width: 3),
                                  ],
                                  Expanded(
                                    child: Text(
                                      scheduleCode,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelSmall
                                          ?.copyWith(
                                            fontSize: denseMobile ? 9 : null,
                                            color: scheme.onSurfaceVariant,
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            Expanded(
                              child: Text(
                                entry.title,
                                maxLines: titleLines,
                                overflow: TextOverflow.ellipsis,
                                style: style,
                              ),
                            ),
                            if (showLocation)
                              Text(
                                event?.specificTime.trim().isNotEmpty == true
                                    ? event!.specificTime
                                    : entry.location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontSize: denseMobile ? 9 : null,
                                      color: scheme.onSurfaceVariant,
                                    ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }
    }

    final todayIndex = weekStart(now) == weekStartDate ? now.weekday - 1 : -1;
    final activePeriodIndex = nthuPeriods.indexWhere(
      (period) => _isCurrentPeriod(period, now),
    );
    if (todayIndex >= 0 && todayIndex < days.length && activePeriodIndex >= 0) {
      children.add(
        Positioned(
          left: dayLeft(todayIndex),
          top: headerHeight + activePeriodIndex * rowHeight,
          width: dayWidths[todayIndex],
          child: Divider(height: 1, thickness: 2, color: scheme.error),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: ClipRect(child: Stack(children: children)),
    );
  }
}

class _TimetableEntry {
  const _TimetableEntry({
    required this.id,
    required this.title,
    required this.start,
    required this.end,
    required this.location,
    this.classOccurrence,
    this.event,
  });

  factory _TimetableEntry.fromClass(ClassOccurrence occurrence) =>
      _TimetableEntry(
        id: occurrence.id,
        title: occurrence.course.courseName,
        start: occurrence.start,
        end: occurrence.end,
        location: occurrence.location,
        classOccurrence: occurrence,
      );

  factory _TimetableEntry.fromEvent(OneTimeEvent event) => _TimetableEntry(
    id: event.id,
    title: event.title,
    start: event.startMinute,
    end: event.endMinute,
    location: event.location,
    event: event,
  );

  final String id;
  final String title;
  final int start;
  final int end;
  final String location;
  final ClassOccurrence? classOccurrence;
  final OneTimeEvent? event;
}

bool _isCurrentPeriod(NthuPeriod period, DateTime now) {
  final minute = now.hour * 60 + now.minute;
  return minute >= period.startMinute && minute < period.endMinute;
}

(int, int)? _rangeForEntry(_TimetableEntry entry) {
  final exact = nthuRangeForMinutes(entry.start, entry.end);
  if (exact != null) return (exact.startIndex, exact.endIndex);

  final first = nthuPeriods.indexWhere(
    (period) => entry.start < period.endMinute,
  );
  var last = -1;
  for (var i = nthuPeriods.length - 1; i >= 0; i--) {
    if (entry.end > nthuPeriods[i].startMinute) {
      last = i;
      break;
    }
  }
  if (first < 0 || last < first) return null;
  return (first, last);
}

class _LanePlacement {
  const _LanePlacement({required this.lane, required this.laneCount});

  final int lane;
  final int laneCount;
}

class _ActiveLane {
  const _ActiveLane({required this.end, required this.lane});

  final int end;
  final int lane;
}

List<_LanePlacement> _lanesFor(List<_TimetableEntry> entries) {
  if (entries.isEmpty) return const [];

  final placements = List<_LanePlacement>.filled(
    entries.length,
    const _LanePlacement(lane: 0, laneCount: 1),
  );
  final active = <_ActiveLane>[];
  final groupIndices = <int>[];
  var groupLaneCount = 1;

  void finishGroup() {
    for (final index in groupIndices) {
      placements[index] = _LanePlacement(
        lane: placements[index].lane,
        laneCount: groupLaneCount,
      );
    }
    groupIndices.clear();
    groupLaneCount = 1;
  }

  for (var index = 0; index < entries.length; index++) {
    final entry = entries[index];
    active.removeWhere((item) => item.end <= entry.start);

    if (active.isEmpty && groupIndices.isNotEmpty) {
      finishGroup();
    }

    final usedLanes = active.map((item) => item.lane).toSet();
    var lane = 0;
    while (usedLanes.contains(lane)) {
      lane++;
    }

    placements[index] = _LanePlacement(lane: lane, laneCount: 1);
    active.add(_ActiveLane(end: entry.end, lane: lane));
    groupIndices.add(index);
    groupLaneCount = math.max(groupLaneCount, lane + 1);
  }

  if (groupIndices.isNotEmpty) finishGroup();
  return placements;
}
