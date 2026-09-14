import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/academic_types.dart';
import '../domain/schedule_engine.dart';
import '../domain/one_time_event.dart';
import '../providers/academic_providers.dart';
import 'academic_data_view.dart';
import 'add_schedule_button.dart';
import 'class_schedule_module.dart';
import 'one_time_event_editor.dart';
import 'today_schedule.dart';
import 'week_timetable.dart';

class ClassScheduleCard extends ConsumerStatefulWidget {
  const ClassScheduleCard({super.key});
  @override
  ConsumerState<ClassScheduleCard> createState() => _ClassScheduleCardState();
}

class _ClassScheduleCardState extends ConsumerState<ClassScheduleCard> {
  @override
  Widget build(BuildContext context) {
    final week = ref.watch(scheduleViewModeProvider) == ScheduleViewMode.week;
    final now =
        ref.watch(scheduleClockProvider).asData?.value ?? DateTime.now();
    final snapshot = ref.watch(academicSnapshotProvider).asData?.value;
    final events =
        ref.watch(oneTimeEventsProvider).asData?.value ??
        const <OneTimeEvent>[];
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: (MediaQuery.textScalerOf(context).scale(14) * 1.5 + 12)
                .clamp(40, double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 2),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Class Schedule',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  if (snapshot?.currentSemester != null)
                    AddScheduleButton(
                      data: snapshot!,
                      semester: snapshot.currentSemester!,
                      initialDate: dateOnly(now),
                      iconOnly: true,
                    ),
                  IconButton(
                    tooltip: week ? 'Show today' : 'Show week',
                    onPressed: () =>
                        ref.read(scheduleViewModeProvider.notifier).toggle(),
                    icon: Icon(
                      week ? Icons.today : Icons.view_week_outlined,
                      size: 20,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Open full schedule',
                    onPressed: () => openFullSchedule(context),
                    icon: const Icon(Icons.open_in_full, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: AcademicDataView(
              builder: (data) {
                final semester = data.currentSemester;
                if (semester == null) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('No current semester yet.'),
                            TextButton(
                              onPressed: () => openFullSchedule(context),
                              child: const Text('Set up academic records'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return week
                    ? WeekTimetable(
                        data: data,
                        semesterId: semester.id,
                        date: dateOnly(now),
                        now: now,
                        events: events,
                        onEventTap: (event) =>
                            showOneTimeEventEditor(context, event: event),
                        compact: true,
                      )
                    : TodaySchedule(
                        classes: scheduleForDay(data, semester.id, now),
                        events: eventsForDay(events, now),
                        now: now,
                        onEventTap: (event) =>
                            showOneTimeEventEditor(context, event: event),
                        compact: true,
                        onOpen: () => openFullSchedule(context),
                      );
              },
            ),
          ),
        ],
      ),
    );
  }
}
