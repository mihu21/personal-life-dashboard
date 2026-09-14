import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme/app_density.dart';

import '../data/academic_snapshot.dart';
import '../domain/academic_types.dart';
import '../domain/schedule_engine.dart';
import '../domain/one_time_event.dart';
import '../providers/academic_providers.dart';
import 'academic_data_view.dart';
import 'add_schedule_button.dart';
import 'course_editor.dart';
import 'one_time_event_editor.dart';
import 'record_editors.dart';
import 'records_view.dart';
import 'today_schedule.dart';
import 'week_timetable.dart';

void openAcademicRecords(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<void>(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Academic records')),
      body: SafeArea(
        child: AcademicDataView(builder: (data) => RecordsView(data: data)),
      ),
    ),
  ),
);

class ScheduleView extends ConsumerStatefulWidget {
  const ScheduleView({required this.data, this.semesterId, super.key});
  final AcademicSnapshot data;
  final String? semesterId;

  @override
  ConsumerState<ScheduleView> createState() => _ScheduleViewState();
}

class _ScheduleViewState extends ConsumerState<ScheduleView> {
  String? selectedId;
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    final week = ref.watch(scheduleViewModeProvider) == ScheduleViewMode.week;
    final now =
        ref.watch(scheduleClockProvider).asData?.value ?? DateTime.now();
    final events =
        ref.watch(oneTimeEventsProvider).asData?.value ??
        const <OneTimeEvent>[];
    final semester =
        data.semesters
            .where((s) => s.id == (selectedId ?? widget.semesterId))
            .firstOrNull ??
        data.currentSemester ??
        data.semesters.firstOrNull;

    if (semester == null) {
      return _NoSemesterState(
        onCreate: () => showDialog(
          context: context,
          builder: (_) => const SemesterEditor(),
        ),
      );
    }

    final day =
        selectedDate ??
        (dateOnly(now).isBefore(semester.startDate) ||
                dateOnly(now).isAfter(semester.endDate)
            ? semester.startDate
            : dateOnly(now));
    final screenTextScale = MediaQuery.textScalerOf(context).scale(1);
    final mobileDense =
        MediaQuery.sizeOf(context).width < 600 && screenTextScale <= 1.4;

    return Column(
      children: [
        Material(
          color: Theme.of(context).colorScheme.surface,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              mobileDense ? 4 : 8,
              mobileDense ? 3 : 6,
              mobileDense ? 4 : 8,
              mobileDense ? 2 : 5,
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(context).scale(1);
                final compact = constraints.maxWidth < 1040 || textScale > 1.4;
                final veryCompact =
                    constraints.maxWidth < 600 || textScale > 1.4;
                final semesterPicker = _SemesterPicker(
                  data: data,
                  semesterId: semester.id,
                  onChanged: (value) => setState(() {
                    selectedId = value;
                    selectedDate = null;
                  }),
                );
                final viewToggle = SegmentedButton<bool>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: false,
                      icon: Icon(Icons.view_day_outlined, size: 16),
                      label: Text('Today'),
                    ),
                    ButtonSegment(
                      value: true,
                      icon: Icon(Icons.calendar_view_week_outlined, size: 16),
                      label: Text('Week'),
                    ),
                  ],
                  selected: {week},
                  onSelectionChanged: (value) => ref
                      .read(scheduleViewModeProvider.notifier)
                      .setWeek(value.single),
                );
                final addButton = AddScheduleButton(
                  data: data,
                  semester: semester,
                  initialDate: day,
                );
                final menu = PopupMenuButton<String>(
                  tooltip: 'More schedule actions',
                  onSelected: (value) {
                    if (value == 'manual') {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            CourseEditor(data: data, semesterId: semester.id),
                      );
                    } else if (value == 'records') {
                      openAcademicRecords(context);
                    } else if (value == 'semester') {
                      showDialog(
                        context: context,
                        builder: (_) => SemesterEditor(semester: semester),
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'semester',
                      child: ListTile(
                        leading: Icon(Icons.edit_calendar_outlined),
                        title: Text('Edit semester'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'manual',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Add manually'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'records',
                      child: ListTile(
                        leading: Icon(Icons.folder_open_outlined),
                        title: Text('Manage records'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                );

                if (compact) {
                  final compactAdd = veryCompact
                      ? AddScheduleButton(
                          data: data,
                          semester: semester,
                          initialDate: day,
                          iconOnly: true,
                        )
                      : addButton;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(child: semesterPicker),
                          SizedBox(width: mobileDense ? 2 : 6),
                          compactAdd,
                          menu,
                        ],
                      ),
                      SizedBox(height: AppDensity.controlGap(context)),
                      if (mobileDense)
                        Row(
                          children: [
                            SizedBox(
                              width: 112,
                              child: _CompactViewToggle(
                                week: week,
                                onChanged: (value) => ref
                                    .read(scheduleViewModeProvider.notifier)
                                    .setWeek(value),
                                showIcons: false,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: _DateNavigator(
                                date: day,
                                week: week,
                                now: now,
                                compact: true,
                                onChanged: (value) =>
                                    setState(() => selectedDate = value),
                              ),
                            ),
                          ],
                        )
                      else ...[
                        if (veryCompact)
                          _CompactViewToggle(
                            week: week,
                            onChanged: (value) => ref
                                .read(scheduleViewModeProvider.notifier)
                                .setWeek(value),
                          )
                        else
                          Align(
                            alignment: Alignment.centerLeft,
                            child: viewToggle,
                          ),
                        SizedBox(height: mobileDense ? 1 : 4),
                        _DateNavigator(
                          date: day,
                          week: week,
                          now: now,
                          compact: true,
                          onChanged: (value) =>
                              setState(() => selectedDate = value),
                        ),
                      ],
                    ],
                  );
                }

                return Row(
                  children: [
                    SizedBox(width: 210, child: semesterPicker),
                    const SizedBox(width: 8),
                    viewToggle,
                    const SizedBox(width: 8),
                    _DateNavigator(
                      date: day,
                      week: week,
                      now: now,
                      onChanged: (value) =>
                          setState(() => selectedDate = value),
                    ),
                    const Spacer(),
                    addButton,
                    menu,
                  ],
                );
              },
            ),
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: week
              ? WeekTimetable(
                  data: data,
                  semesterId: semester.id,
                  date: day,
                  now: now,
                  events: events,
                  onEventTap: (event) =>
                      showOneTimeEventEditor(context, event: event),
                )
              : TodaySchedule(
                  classes: scheduleForDay(data, semester.id, day),
                  events: eventsForDay(events, day),
                  now: now,
                  onEventTap: (event) =>
                      showOneTimeEventEditor(context, event: event),
                ),
        ),
      ],
    );
  }
}

class _SemesterPicker extends StatelessWidget {
  const _SemesterPicker({
    required this.data,
    required this.semesterId,
    required this.onChanged,
  });

  final AcademicSnapshot data;
  final String semesterId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final denseMobile =
        MediaQuery.sizeOf(context).width < 600 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.4;
    final scheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(minHeight: denseMobile ? 34 : 36),
      padding: EdgeInsets.symmetric(
        horizontal: denseMobile ? 8 : 10,
        vertical: denseMobile ? 3 : 5,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: scheme.outlineVariant),
        borderRadius: BorderRadius.circular(7),
        color: scheme.surface,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: ValueKey('schedule-semester-$semesterId'),
          value: semesterId,
          isExpanded: true,
          isDense: true,
          icon: Icon(
            Icons.arrow_drop_down,
            size: denseMobile ? 18 : 20,
          ),
          selectedItemBuilder: (context) => [
            for (final semester in data.semesters)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Semester · ${semester.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
          ],
          items: [
            for (final semester in data.semesters)
              DropdownMenuItem(
                value: semester.id,
                child: Text(
                  semester.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({
    required this.date,
    required this.week,
    required this.now,
    required this.onChanged,
    this.compact = false,
  });

  final DateTime date;
  final bool week;
  final DateTime now;
  final ValueChanged<DateTime> onChanged;
  final bool compact;

  Future<void> _pickDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2200),
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    final denseMobile =
        MediaQuery.sizeOf(context).width < 600 &&
        MediaQuery.textScalerOf(context).scale(1) <= 1.4;
    final dateButton = TextButton(
      style: TextButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: denseMobile ? 4 : 8),
        minimumSize: Size(0, denseMobile ? 28 : 34),
        visualDensity: VisualDensity.compact,
      ),
      onPressed: () => _pickDate(context),
      child: Text(
        dateLabel(week ? weekStart(date) : date),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );

    if (compact) {
      return Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Previous ${week ? 'week' : 'day'}',
            icon: Icon(Icons.chevron_left, size: denseMobile ? 19 : 22),
            onPressed: () => onChanged(calendarDay(date, week ? -7 : -1)),
          ),
          Expanded(child: dateButton),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Next ${week ? 'week' : 'day'}',
            icon: Icon(Icons.chevron_right, size: denseMobile ? 19 : 22),
            onPressed: () => onChanged(calendarDay(date, week ? 7 : 1)),
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            tooltip: 'Go to today',
            icon: Icon(Icons.today_outlined, size: denseMobile ? 18 : 21),
            onPressed: () => onChanged(dateOnly(now)),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Previous ${week ? 'week' : 'day'}',
          icon: Icon(Icons.chevron_left, size: denseMobile ? 19 : 22),
          onPressed: () => onChanged(calendarDay(date, week ? -7 : -1)),
        ),
        dateButton,
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Next ${week ? 'week' : 'day'}',
          icon: Icon(Icons.chevron_right, size: denseMobile ? 19 : 22),
          onPressed: () => onChanged(calendarDay(date, week ? 7 : 1)),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          tooltip: 'Go to today',
          icon: Icon(Icons.today_outlined, size: denseMobile ? 18 : 21),
          onPressed: () => onChanged(dateOnly(now)),
        ),
      ],
    );
  }
}

class _CompactViewToggle extends StatelessWidget {
  const _CompactViewToggle({
    required this.week,
    required this.onChanged,
    this.showIcons = true,
  });

  final bool week;
  final ValueChanged<bool> onChanged;
  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    Widget option({
      required bool value,
      required IconData icon,
      required String label,
    }) {
      final selected = week == value;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: value ? 0 : 4),
          child: OutlinedButton.icon(
            onPressed: () => onChanged(value),
            icon: showIcons ? Icon(icon, size: 16) : null,
            label: Text(label, maxLines: 1),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 30),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              visualDensity: VisualDensity.compact,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              backgroundColor: selected ? scheme.secondaryContainer : null,
              foregroundColor: selected
                  ? scheme.onSecondaryContainer
                  : scheme.onSurface,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        option(value: false, icon: Icons.view_day_outlined, label: 'Today'),
        option(
          value: true,
          icon: Icons.calendar_view_week_outlined,
          label: 'Week',
        ),
      ],
    );
  }
}

class _NoSemesterState extends StatelessWidget {
  const _NoSemesterState({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) => SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: constraints.maxHeight > 24
              ? constraints.maxHeight - 24
              : 0,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_month_outlined,
                  size: 36,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 7),
                Text(
                  'Set your current NTHU semester',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                const Text(
                  'After that you can add classes directly from the official NTHU catalog.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                FilledButton.icon(
                  onPressed: onCreate,
                  icon: const Icon(Icons.add),
                  label: const Text('Create semester'),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
