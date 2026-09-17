import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../class_schedule/providers/academic_providers.dart';
import '../../class_schedule/data/academic_snapshot.dart';
import '../../class_schedule/domain/academic_types.dart';
import '../domain/task_logic.dart';
import '../domain/task_types.dart';
import '../providers/task_providers.dart';
import 'task_editor.dart';
import 'task_filter_dialog.dart';
import 'task_categories_dialog.dart';
import 'task_details.dart';
import 'task_visuals.dart';
export '../domain/task_types.dart' show TaskView;

void openFullTasks(BuildContext context) => Navigator.of(context).push<void>(
  MaterialPageRoute(
    builder: (_) => Scaffold(
      appBar: AppBar(title: const Text('Tasks & Reminders')),
      body: const SafeArea(child: TasksModule(showTitle: false)),
    ),
  ),
);

class TasksModule extends ConsumerStatefulWidget {
  const TasksModule({this.showTitle = true, this.compact = false, super.key});
  final bool showTitle, compact;
  @override
  ConsumerState<TasksModule> createState() => _TasksModuleState();
}

class _TasksModuleState extends ConsumerState<TasksModule> {
  final search = TextEditingController();
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  Future<void> apply(TaskFilter filter) async {
    try {
      await ref.read(taskFilterProvider.notifier).apply(filter);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not save filters: $e')));
      }
    }
  }

  Future<void> filters(
    TaskFilter filter,
    List<String> categories,
    Map<String, String> courses,
  ) async {
    final result = await showDialog<TaskFilter>(
      context: context,
      builder: (_) => TaskFilterDialog(
        filter: filter,
        categories: categories,
        courses: courses,
      ),
    );
    if (result != null && mounted) await apply(result);
  }

  @override
  Widget build(BuildContext context) => TaskTypography(
    child: Builder(
      builder: (context) {
        final data = ref.watch(tasksProvider);
        final filter =
            ref.watch(taskFilterProvider).asData?.value ?? const TaskFilter();
        if (search.text != filter.search) {
          search.value = TextEditingValue(
            text: filter.search,
            selection: TextSelection.collapsed(offset: filter.search.length),
          );
        }
        final display = ref.watch(taskDisplayProvider);
        final view = display.view;
        final colors = <String, int>{
          for (final c in ref.watch(taskCategoriesProvider).asData?.value ?? [])
            c.name: c.color,
        };
        final categories = colors.isEmpty
            ? taskCategories
            : colors.keys.toList();
        final academic = ref.watch(academicSnapshotProvider).asData?.value;
        final courses = <String, String>{
          for (final c in academic?.courses ?? []) c.id: c.courseName,
        };
        final now =
            ref.watch(scheduleClockProvider).asData?.value ?? DateTime.now();
        final currentCourses = _currentCourseOptions(academic, now);
        final selected = display.date;
        return LayoutBuilder(
          builder: (context, constraints) {
            final mobile = constraints.maxWidth < 600;
            final narrow =
                mobile || MediaQuery.textScalerOf(context).scale(1) > 1.4;
            return Padding(
              padding: widget.compact
                  ? const EdgeInsets.all(6)
                  : mobile
                  ? const EdgeInsets.fromLTRB(8, 2, 8, 6)
                  : const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (!widget.compact) ...[
                    if (widget.showTitle)
                      Padding(
                        padding: EdgeInsets.only(bottom: mobile ? 2 : 8),
                        child: Text(
                          'Tasks & Reminders',
                          style: mobile
                              ? Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                )
                              : Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    Wrap(
                      spacing: mobile ? 4 : 8,
                      runSpacing: mobile ? 2 : 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        for (final v in TaskView.values)
                          ChoiceChip(
                            label: Text(_viewName(v)),
                            labelStyle: mobile
                                ? const TextStyle(fontSize: 12)
                                : null,
                            visualDensity: mobile
                                ? const VisualDensity(horizontal: -2, vertical: -2)
                                : null,
                            materialTapTargetSize: mobile
                                ? MaterialTapTargetSize.shrinkWrap
                                : null,
                            padding: mobile
                                ? const EdgeInsets.symmetric(horizontal: 5)
                                : null,
                            selected: view == v,
                            onSelected: (_) =>
                                ref.read(taskDisplayProvider.notifier).view(v),
                          ),
                        FilledButton.icon(
                          style: mobile
                              ? FilledButton.styleFrom(
                                  visualDensity: const VisualDensity(
                                    horizontal: -2,
                                    vertical: -2,
                                  ),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  textStyle: const TextStyle(fontSize: 12),
                                )
                              : null,
                          onPressed: () => showTaskEditor(
                            context,
                            date: view == TaskView.agenda ? null : selected,
                          ),
                          icon: Icon(Icons.add, size: mobile ? 17 : 24),
                          label: const Text('Add task'),
                        ),
                        IconButton(
                          tooltip: 'Manage categories',
                          visualDensity: mobile
                              ? const VisualDensity(horizontal: -3, vertical: -3)
                              : null,
                          constraints: mobile
                              ? const BoxConstraints.tightFor(width: 32, height: 32)
                              : null,
                          padding: EdgeInsets.zero,
                          onPressed: () => showTaskCategories(context),
                          icon: Icon(
                            Icons.palette_outlined,
                            size: mobile ? 19 : 24,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!widget.compact)
                    Padding(
                      padding: mobile
                          ? const EdgeInsets.only(top: 1)
                          : const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: search,
                              style: mobile
                                  ? const TextStyle(fontSize: 12.5)
                                  : null,
                              onChanged: (v) => apply(filter.withSearch(v)),
                              decoration: InputDecoration(
                                hintText: 'Search tasks',
                                hintStyle: mobile
                                    ? const TextStyle(fontSize: 12.5)
                                    : null,
                                isDense: true,
                                contentPadding: mobile
                                    ? const EdgeInsets.symmetric(
                                        horizontal: 9,
                                        vertical: 6,
                                      )
                                    : null,
                                border: const OutlineInputBorder(),
                                prefixIcon: Icon(
                                  Icons.search,
                                  size: mobile ? 18 : 24,
                                ),
                                prefixIconConstraints: mobile
                                    ? const BoxConstraints(
                                        minWidth: 34,
                                        minHeight: 30,
                                      )
                                    : null,
                                suffixIcon: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (search.text.isNotEmpty)
                                      IconButton(
                                        tooltip: 'Clear search',
                                        visualDensity: mobile
                                            ? const VisualDensity(
                                                horizontal: -3,
                                                vertical: -3,
                                              )
                                            : null,
                                        constraints: mobile
                                            ? const BoxConstraints.tightFor(
                                                width: 30,
                                                height: 30,
                                              )
                                            : null,
                                        padding: EdgeInsets.zero,
                                        onPressed: () =>
                                            apply(filter.withSearch('')),
                                        icon: Icon(
                                          Icons.close,
                                          size: mobile ? 18 : 24,
                                        ),
                                      ),
                                    IconButton(
                                      tooltip: 'Filter tasks',
                                      visualDensity: mobile
                                          ? const VisualDensity(
                                              horizontal: -3,
                                              vertical: -3,
                                            )
                                          : null,
                                      constraints: mobile
                                          ? const BoxConstraints.tightFor(
                                              width: 30,
                                              height: 30,
                                            )
                                          : null,
                                      padding: EdgeInsets.zero,
                                      onPressed: () => filters(
                                        filter,
                                        categories,
                                        currentCourses,
                                      ),
                                      icon: Icon(
                                        Icons.filter_list,
                                        size: mobile ? 18 : 24,
                                      ),
                                    ),
                                  ],
                                ),
                                suffixIconConstraints: mobile
                                    ? const BoxConstraints(minHeight: 30)
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const TaskNotificationBanner(),
                  Expanded(
                    child: data.when(
                      loading: () =>
                          const Center(child: Text('Loading tasks…')),
                      error: (e, _) =>
                          Center(child: Text('Could not load tasks: $e')),
                      data: (all) {
                        // Compact mode has no search field, so keep search from
                        // silently restricting the dashboard while honoring all
                        // filters available from the visible filter button.
                        final effectiveFilter = widget.compact
                            ? TaskFilter(
                                categories: filter.categories,
                                priorities: filter.priorities,
                                statuses: filter.statuses,
                                sources: filter.sources,
                                courseIds: filter.courseIds,
                                includeNoCourse: filter.includeNoCourse,
                                duePeriod: filter.duePeriod,
                                start: filter.start,
                                end: filter.end,
                                search: '',
                                includeOverdue: filter.includeOverdue,
                                includeNoDeadline: filter.includeNoDeadline,
                              )
                            : filter;
                        final tasks = filterTasks(
                          all,
                          effectiveFilter,
                          now,
                          courseNames: courses,
                        );
                        if (view == TaskView.agenda) {
                          return agenda(tasks, courses, now, mobile: mobile);
                        }
                        return calendar(
                          context,
                          tasks,
                          colors,
                          courses,
                          now,
                          display,
                          narrow,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    ),
  );
  Widget agenda(
    List<TaskBundle> tasks,
    Map<String, String> courses,
    DateTime now, {
    required bool mobile,
  }) {
    final groups = <String, List<TaskBundle>>{};
    for (final b in tasks) {
      groups.putIfAbsent(agendaSection(b.task, now), () => []).add(b);
    }
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        if (tasks.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.compact
                  ? 'No open tasks. Add your next step.'
                  : 'No tasks match these filters. Add a task or adjust your filters.',
            ),
          ),
        for (final section in [
          'Overdue',
          'Earlier',
          'Today',
          'Tomorrow',
          'This Week',
          'Later',
          'No Deadline',
        ])
          if (groups.containsKey(section)) ...[
            Padding(
              padding: EdgeInsets.symmetric(
                vertical: widget.compact ? 4 : mobile ? 2 : 8,
              ),
              child: Text(
                '$section · ${groups[section]!.length}',
                style: TextStyle(
                  fontSize: mobile ? 12 : null,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            for (final b in groups[section]!)
              TaskTile(
                bundle: b,
                now: now,
                courseName: courses[b.task.courseId],
                dashboardCompact: widget.compact,
                mobileCompact: mobile && !widget.compact,
                showCompletionCheckbox: true,
              ),
          ],
      ],
    );
  }

  Widget calendar(
    BuildContext context,
    List<TaskBundle> tasks,
    Map<String, int> colors,
    Map<String, String> courses,
    DateTime now,
    TaskDisplay display,
    bool narrow,
  ) {
    final selected = display.date;
    final week = display.view == TaskView.week;
    final first = week
        ? taskDayAfter(selected, 1 - selected.weekday)
        : DateTime(selected.year, selected.month);
    final start = taskDayAfter(first, 1 - first.weekday);
    final count = week
        ? 7
        : ((first.weekday - 1 + DateTime(first.year, first.month + 1, 0).day) /
                      7)
                  .ceil() *
              7;
    final days = List.generate(count, (i) => taskDayAfter(start, i));
    List<TaskBundle> onDay(DateTime day) => tasks
        .where(
          (b) => b.task.deadline != null && taskDay(b.task.deadline!) == day,
        )
        .toList();
    void navigate(int n) => ref
        .read(taskDisplayProvider.notifier)
        .date(
          week
              ? taskDayAfter(selected, 7 * n)
              : DateTime(selected.year, selected.month + n),
        );
    return LayoutBuilder(
      builder: (context, box) {
        final short = box.maxHeight < 300;
        final scale = MediaQuery.textScalerOf(context).scale(1);
        final compactCalendarHeader = box.maxWidth < 600;
        final expandedMonthDetails = !widget.compact && box.maxWidth >= 600;
        final calendarNavHeight = compactCalendarHeader ? 18.0 : 24.0;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: calendarNavHeight,
              child: Row(
                children: [
                  IconButton(
                    tooltip: 'Previous ${display.view.name}',
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: compactCalendarHeader ? 22 : 28,
                      height: calendarNavHeight,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => navigate(-1),
                    icon: Icon(
                      Icons.chevron_left,
                      size: compactCalendarHeader ? 16 : 18,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      week
                          ? '${_months[start.month - 1]} ${start.day} – ${days.last.day}, ${days.last.year}'
                          : '${_months[selected.month - 1]} ${selected.year}',
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: compactCalendarHeader ? 12 : null,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Next ${display.view.name}',
                    visualDensity: const VisualDensity(
                      horizontal: -4,
                      vertical: -4,
                    ),
                    constraints: BoxConstraints.tightFor(
                      width: compactCalendarHeader ? 22 : 28,
                      height: calendarNavHeight,
                    ),
                    padding: EdgeInsets.zero,
                    onPressed: () => navigate(1),
                    icon: Icon(
                      Icons.chevron_right,
                      size: compactCalendarHeader ? 16 : 18,
                    ),
                  ),
                  if (!short)
                    IconButton(
                      tooltip: 'Go to today',
                      visualDensity: const VisualDensity(
                        horizontal: -4,
                        vertical: -4,
                      ),
                      constraints: BoxConstraints.tightFor(
                        width: compactCalendarHeader ? 24 : 28,
                        height: calendarNavHeight,
                      ),
                      padding: EdgeInsets.zero,
                      onPressed: () => ref
                          .read(taskDisplayProvider.notifier)
                          .date(taskDay(now)),
                      icon: Icon(
                        Icons.today_outlined,
                        size: compactCalendarHeader ? 17 : 18,
                      ),
                    ),
                ],
              ),
            ),
            if (week && narrow) ...[
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final day in days)
                      Expanded(
                        child: Container(
                          key: ValueKey(
                            'task-mobile-week-day-${day.year}-${day.month}-${day.day}',
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: day == selected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                    .withValues(alpha: .28)
                                : Theme.of(context).colorScheme.surfaceContainerLow,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              InkWell(
                                onTap: () => ref
                                    .read(taskDisplayProvider.notifier)
                                    .date(day),
                                child: SizedBox(
                                  height: math.max(25, 25 * math.min(scale, 1.35)),
                                  width: double.infinity,
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                      vertical: 2,
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Text(
                                        '${_weekdays[day.weekday - 1].substring(0, 3)} ${day.day}',
                                        maxLines: 1,
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: taskDay(now) == day
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Divider(height: 1),
                              Expanded(
                                child: ListView(
                                  primary: false,
                                  padding: const EdgeInsets.fromLTRB(2, 3, 2, 3),
                                  children: [
                                    for (final b in onDay(day))
                                      _mobileWeekTask(
                                        context,
                                        b,
                                        colors,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ] else if (week)
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final day in days)
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.outlineVariant,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: Text(
                                  '${box.maxWidth > 1100 ? _weekdays[day.weekday - 1] : _weekdays[day.weekday - 1].substring(0, 3)} ${day.day}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: taskDay(now) == day
                                        ? Theme.of(context).colorScheme.primary
                                        : null,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: ListView(
                                  padding: const EdgeInsets.all(4),
                                  children: [
                                    for (final b in onDay(day))
                                      TaskTile(
                                        bundle: b,
                                        now: now,
                                        compact: true,
                                        dashboardCompact: widget.compact,
                                        showCompletionCheckbox: false,
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              )
            else
              Expanded(
                child: LayoutBuilder(
                  builder: (context, gridBox) {
                    final minWidth =
                        7 *
                        (MediaQuery.textScalerOf(context).scale(14) * 2.1 + 8);
                    final width = math.max(gridBox.maxWidth, minWidth);
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SizedBox(
                        width: width,
                        height: gridBox.maxHeight,
                        child: Column(
                          children: [
                            Row(
                              children: [
                                for (final day in _weekdays)
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        width > 1100
                                            ? day
                                            : day.substring(0, 3),
                                        style: compactCalendarHeader
                                            ? const TextStyle(fontSize: 11)
                                            : null,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: compactCalendarHeader ? 2 : 4),
                            Expanded(
                              child: LayoutBuilder(
                                builder: (context, cells) => GridView.builder(
                                  key: const ValueKey('task-month-grid'),
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: count,
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 7,
                                        mainAxisExtent: math.max(
                                          1,
                                          (cells.maxHeight -
                                                  (count ~/ 7 - 1) * 3) /
                                              (count ~/ 7),
                                        ),
                                        crossAxisSpacing: 3,
                                        mainAxisSpacing: 3,
                                      ),
                                  itemBuilder: (_, i) => monthCell(
                                    context,
                                    days[i],
                                    onDay(days[i]),
                                    colors,
                                    now,
                                    selected,
                                    detailed: expandedMonthDetails,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _mobileWeekTask(
    BuildContext context,
    TaskBundle bundle,
    Map<String, int> colors,
  ) {
    final task = bundle.task;
    final scheme = Theme.of(context).colorScheme;
    final categoryColor = Color(
      colors[task.category] ??
          defaultTaskCategoryColors[task.category] ??
          0xFFA6A6B9,
    );
    final time = task.deadline != null && task.hasDeadlineTime
        ? '${task.deadline!.hour.toString().padLeft(2, '0')}:${task.deadline!.minute.toString().padLeft(2, '0')}'
        : null;
    final meta = time == null
        ? task.priority.label
        : '$time ${task.priority.label}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Tooltip(
        message:
            '${task.title}${time == null ? '' : ' · $time'} · ${task.priority.label} priority',
        child: Material(
          color: scheme.surfaceContainerHigh.withValues(alpha: .72),
          borderRadius: BorderRadius.circular(5),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            key: ValueKey('task-mobile-week-task-${task.id}'),
            onTap: () => showTaskDetails(context, bundle),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(2, 3, 2, 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 2,
                    height: 24,
                    decoration: BoxDecoration(
                      color: categoryColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          task.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 8.5,
                            height: 1,
                            fontWeight: FontWeight.w600,
                            decoration: task.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: double.infinity,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              meta,
                              maxLines: 1,
                              style: TextStyle(
                                fontSize: 7.5,
                                height: 1,
                                color: scheme.onSurfaceVariant,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
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

  Widget monthCell(
    BuildContext context,
    DateTime day,
    List<TaskBundle> tasks,
    Map<String, int> colors,
    DateTime now,
    DateTime selected, {
    required bool detailed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final outsideMonth =
        day.year != selected.year || day.month != selected.month;
    final isToday = taskDay(now) == day;
    final cellColor = outsideMonth
        ? Color.alphaBlend(
            scheme.onSurface.withValues(alpha: .055),
            scheme.surface,
          )
        : isToday
        ? scheme.primaryContainer.withValues(alpha: .6)
        : scheme.surfaceContainerLow;
    final dateColor = outsideMonth
        ? scheme.onSurfaceVariant.withValues(alpha: .72)
        : isToday
        ? scheme.primary
        : scheme.onSurface;

    return Semantics(
      label: '${taskDateLabel(day)}, ${tasks.length} tasks',
      button: true,
      child: Opacity(
        key: ValueKey('task-month-cell-${day.year}-${day.month}-${day.day}'),
        opacity: outsideMonth ? .58 : 1,
        child: Material(
          color: cellColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: scheme.outlineVariant.withValues(
                alpha: outsideMonth ? .45 : .7,
              ),
            ),
          ),
          child: InkWell(
            // Month cells open the day's list. Individual task markers/rows are
            // deliberately not separate tap targets to avoid accidental opens.
            onTap: () => dayDetails(day),
            child: detailed
                ? LayoutBuilder(
                    builder: (context, box) {
                      final line =
                          MediaQuery.textScalerOf(context).scale(14) * 1.35 + 6;
                      final capacity = math.max(
                        0,
                        ((box.maxHeight - line - 8) / line).floor(),
                      );
                      final titles = box.maxWidth >= 105;
                      final visible = tasks
                          .take(
                            math.max(
                              0,
                              capacity - (tasks.length > capacity ? 1 : 0),
                            ),
                          )
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.all(4),
                        child: ClipRect(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                height: math.min(
                                  line,
                                  math.max(0, box.maxHeight - 8),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${day.day}',
                                        style: TextStyle(
                                          fontWeight: isToday
                                              ? FontWeight.bold
                                              : null,
                                          color: dateColor,
                                        ),
                                      ),
                                    ),
                                    if (capacity == 0 && tasks.isNotEmpty)
                                      if (box.maxWidth >= 65)
                                        TaskPriorityMark(
                                          priority: tasks.first.task.priority,
                                          color: Color(
                                            colors[tasks.first.task.category] ??
                                                defaultTaskCategoryColors[tasks
                                                    .first
                                                    .task
                                                    .category] ??
                                                0xFFA6A6B9,
                                          ),
                                          category: tasks.first.task.category,
                                        )
                                      else
                                        Icon(
                                          Icons.circle,
                                          size: 6,
                                          color: Color(
                                            colors[tasks.first.task.category] ??
                                                defaultTaskCategoryColors[tasks
                                                    .first
                                                    .task
                                                    .category] ??
                                                0xFFA6A6B9,
                                          ),
                                        ),
                                  ],
                                ),
                              ),
                              for (final b in visible)
                                SizedBox(
                                  key: ValueKey(
                                    'task-month-detail-${b.task.id}',
                                  ),
                                  height: line,
                                  child: Tooltip(
                                    message: b.task.title,
                                    child: Row(
                                      children: [
                                        TaskPriorityMark(
                                          priority: b.task.priority,
                                          color: Color(
                                            colors[b.task.category] ??
                                                defaultTaskCategoryColors[b
                                                    .task
                                                    .category] ??
                                                0xFFA6A6B9,
                                          ),
                                          category: b.task.category,
                                        ),
                                        if (titles) ...[
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              b.task.title,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                decoration:
                                                    b.task.status ==
                                                        TaskStatus.completed
                                                    ? TextDecoration.lineThrough
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              if (tasks.length > visible.length && capacity > 0)
                                SizedBox(
                                  height: line,
                                  child: Text(
                                    '+${tasks.length - visible.length}${titles ? ' more' : ''}',
                                    maxLines: 1,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  )
                : Padding(
                    padding: const EdgeInsets.all(5),
                    child: ClipRect(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.topLeft,
                              child: Text(
                                '${day.day}',
                                style: TextStyle(
                                  fontWeight: isToday ? FontWeight.bold : null,
                                  color: dateColor,
                                ),
                              ),
                            ),
                          ),
                          if (tasks.isNotEmpty)
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Wrap(
                                alignment: WrapAlignment.end,
                                runAlignment: WrapAlignment.end,
                                spacing: 1,
                                runSpacing: 1,
                                children: [
                                  for (final b in tasks)
                                    SizedBox(
                                      key: ValueKey(
                                        'task-month-indicator-${b.task.id}',
                                      ),
                                      width: 8,
                                      height: 18,
                                      child: Center(
                                        child: Container(
                                          width: 3,
                                          height: 14,
                                          decoration: BoxDecoration(
                                            color: Color(
                                              colors[b.task.category] ??
                                                  defaultTaskCategoryColors[b
                                                      .task
                                                      .category] ??
                                                  0xFFA6A6B9,
                                            ).withValues(
                                              alpha:
                                                  b.task.status ==
                                                      TaskStatus.completed
                                                  ? .55
                                                  : 1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> dayDetails(DateTime day) => showDialog<void>(
    context: context,
    builder: (_) => Consumer(
      builder: (context, ref, _) {
        final filter =
            ref.watch(taskFilterProvider).asData?.value ?? const TaskFilter();
        final names = <String, String>{
          for (final c
              in ref.watch(academicSnapshotProvider).asData?.value.courses ??
                  [])
            c.id: c.courseName,
        };
        final tasks =
            filterTasks(
              ref.watch(tasksProvider).asData?.value ?? [],
              filter,
              DateTime.now(),
              courseNames: names,
            ).where(
              (b) =>
                  b.task.deadline != null && taskDay(b.task.deadline!) == day,
            );
        return AlertDialog(
          title: Text('${_weekdays[day.weekday - 1]} · ${taskDateLabel(day)}'),
          scrollable: true,
          content: SizedBox(
            width: 540,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (tasks.isEmpty)
                  const Text('No task deadlines on this date.'),
                for (final b in tasks)
                  TaskTile(
                    bundle: b,
                    now: DateTime.now(),
                    courseName: names[b.task.courseId],
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            FilledButton.icon(
              onPressed: () => showTaskEditor(context, date: day),
              icon: const Icon(Icons.add),
              label: const Text('Add task'),
            ),
          ],
        );
      },
    ),
  );
}

String _viewName(TaskView v) => ['Agenda', 'Week', 'Month'][v.index];
const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];
const _weekdays = [
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
  'Sunday',
];

class TaskTile extends ConsumerWidget {
  const TaskTile({
    required this.bundle,
    required this.now,
    this.courseName,
    this.compact = false,
    this.dashboardCompact = false,
    this.mobileCompact = false,
    this.showCompletionCheckbox = true,
    super.key,
  });
  final TaskBundle bundle;
  final DateTime now;
  final String? courseName;
  final bool compact;
  final bool dashboardCompact;
  final bool mobileCompact;
  final bool showCompletionCheckbox;

  Future<void> _setCompleted(
    BuildContext context,
    WidgetRef ref,
    bool completed,
  ) async {
    try {
      await ref
          .read(taskRepositoryProvider)
          .setStatus(
            bundle.task.id,
            completed ? TaskStatus.completed : TaskStatus.active,
          );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not update task: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = bundle.task;
    final color = Color(
      ref
              .watch(taskCategoriesProvider)
              .asData
              ?.value
              .where((c) => c.name == t.category)
              .firstOrNull
              ?.color ??
          defaultTaskCategoryColors[t.category] ??
          0xFFA6A6B9,
    );
    if (mobileCompact) {
      final overdue = isTaskOverdue(t, now);
      final scheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => showTaskDetails(context, bundle),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(7, 5, 3, 5),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TaskPriorityMark(
                    priority: t.priority,
                    color: color,
                    category: t.category,
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            height: 1.08,
                            fontWeight: FontWeight.w600,
                            decoration: t.status == TaskStatus.completed
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.deadline == null
                              ? 'No deadline'
                              : taskDateLabel(
                                  t.deadline!,
                                  time: t.hasDeadlineTime,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 11,
                            height: 1.05,
                            color: overdue
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showCompletionCheckbox) ...[
                    const SizedBox(width: 4),
                    SizedBox(
                      width: 30,
                      height: 30,
                      child: Tooltip(
                        message: t.status == TaskStatus.completed
                            ? 'Mark active'
                            : 'Mark complete',
                        child: Checkbox(
                          value: t.status == TaskStatus.completed,
                          visualDensity: const VisualDensity(
                            horizontal: -4,
                            vertical: -4,
                          ),
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          onChanged: (value) =>
                              _setCompleted(context, ref, value ?? false),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (dashboardCompact) {
      final overdue = isTaskOverdue(t, now);
      final scheme = Theme.of(context).colorScheme;
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Card(
          margin: EdgeInsets.zero,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => showTaskDetails(context, bundle),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 6, 4, 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TaskPriorityMark(
                    priority: t.priority,
                    color: color,
                    category: t.category,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          t.deadline == null
                              ? 'No deadline'
                              : taskDateLabel(
                                  t.deadline!,
                                  time: t.hasDeadlineTime,
                                ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                            color: overdue
                                ? scheme.error
                                : scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showCompletionCheckbox) ...[
                    const SizedBox(width: 6),
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Tooltip(
                        message: t.status == TaskStatus.completed
                            ? 'Mark active'
                            : 'Mark complete',
                        child: Checkbox(
                          value: t.status == TaskStatus.completed,
                          onChanged: (value) =>
                              _setCompleted(context, ref, value ?? false),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Card(
        margin: EdgeInsets.zero,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => showTaskDetails(context, bundle),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TaskPriorityMark(
                  priority: t.priority,
                  color: color,
                  category: t.category,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          decoration: t.status == TaskStatus.completed
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                      ),
                      if (!compact) ...[
                        const SizedBox(height: 4),
                        Text('${t.category} · ${t.priority.label}'),
                      ],
                      if (!compact && t.courseId != null)
                        Text(courseName ?? 'Unavailable course'),
                      Text(
                        t.deadline == null
                            ? 'No deadline'
                            : '${isTaskOverdue(t, now) ? 'Overdue' : 'Due'} ${taskDateLabel(t.deadline!, time: t.hasDeadlineTime)}',
                        style: TextStyle(
                          color: isTaskOverdue(t, now)
                              ? Theme.of(context).colorScheme.error
                              : null,
                        ),
                      ),
                      if (!compact &&
                          (bundle.reminders.isNotEmpty ||
                              t.repeatUnit != RepeatUnit.none))
                        Text(
                          [
                            if (bundle.reminders.isNotEmpty)
                              '${bundle.reminders.length} reminder${bundle.reminders.length == 1 ? '' : 's'}',
                            if (t.repeatUnit != RepeatUnit.none) 'Repeats',
                          ].join(' · '),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Map<String, String> _currentCourseOptions(
  AcademicSnapshot? academic,
  DateTime now,
) {
  if (academic == null) return const <String, String>{};

  final today = DateTime(now.year, now.month, now.day);
  final explicitCurrentSemester = academic.currentSemester;
  final datedCurrentSemester = academic.semesters.where((semester) {
    final start = DateTime(
      semester.startDate.year,
      semester.startDate.month,
      semester.startDate.day,
    );
    final end = DateTime(
      semester.endDate.year,
      semester.endDate.month,
      semester.endDate.day,
    );
    return !today.isBefore(start) && !today.isAfter(end);
  }).firstOrNull;

  final semestersByNewest = [...academic.semesters]
    ..sort((a, b) => b.startDate.compareTo(a.startDate));
  final effectiveCurrentSemester =
      explicitCurrentSemester ??
      datedCurrentSemester ??
      semestersByNewest.firstOrNull;
  final currentSemesterId = effectiveCurrentSemester?.id;
  if (currentSemesterId == null) return const <String, String>{};

  return <String, String>{
    for (final c in academic.courses)
      if (c.semesterId == currentSemesterId &&
          c.status != CourseStatus.withdrawn &&
          c.status != CourseStatus.failed)
        c.id: c.courseName,
  };
}

class TasksDashboardCard extends ConsumerWidget {
  const TasksDashboardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final display = ref.watch(taskDisplayProvider);
    final filter =
        ref.watch(taskFilterProvider).asData?.value ?? const TaskFilter();
    final categoryColors = <String, int>{
      for (final c in ref.watch(taskCategoriesProvider).asData?.value ?? [])
        c.name: c.color,
    };
    final categories = categoryColors.isEmpty
        ? taskCategories
        : categoryColors.keys.toList();
    final academic = ref.watch(academicSnapshotProvider).asData?.value;
    final now = ref.watch(scheduleClockProvider).asData?.value ?? DateTime.now();
    final currentCourses = _currentCourseOptions(academic, now);

    Future<void> showFilters() async {
      final result = await showDialog<TaskFilter>(
        context: context,
        builder: (_) => TaskFilterDialog(
          filter: filter,
          categories: categories,
          courses: currentCourses,
        ),
      );
      if (result == null || !context.mounted) return;
      try {
        await ref.read(taskFilterProvider.notifier).apply(result);
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not save filters: $e')),
          );
        }
      }
    }

    final buttonStyle = IconButton.styleFrom(
      minimumSize: const Size(34, 34),
      maximumSize: const Size(34, 34),
      padding: EdgeInsets.zero,
    );

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: (MediaQuery.textScalerOf(context).scale(14) * 1.5 + 12)
                .clamp(40, double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Row(
                children: [
                  Icon(
                    Icons.checklist_rounded,
                    size: 20,
                    color: const Color(0xFF367A70),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Tasks & Reminders',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                  ),
                  PopupMenuButton<TaskView>(
                    tooltip: 'Change task view',
                    initialValue: display.view,
                    onSelected: ref.read(taskDisplayProvider.notifier).view,
                    itemBuilder: (_) => [
                      for (final view in TaskView.values)
                        PopupMenuItem(
                          value: view,
                          child: Text(_viewName(view)),
                        ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _viewName(display.view),
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Filter tasks',
                    style: buttonStyle,
                    onPressed: showFilters,
                    icon: const Icon(Icons.filter_list, size: 19),
                  ),
                  IconButton(
                    tooltip: 'Add task',
                    style: buttonStyle,
                    onPressed: () => showTaskEditor(
                      context,
                      date: display.view == TaskView.agenda
                          ? null
                          : display.date,
                    ),
                    icon: const Icon(Icons.add, size: 20),
                  ),
                  IconButton(
                    tooltip: 'Expand Tasks & Reminders',
                    style: buttonStyle,
                    onPressed: () => openFullTasks(context),
                    icon: const Icon(Icons.open_in_full, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          const Expanded(
            child: TasksModule(compact: true, showTitle: false),
          ),
        ],
      ),
    );
  }
}

class TaskNotificationBanner extends ConsumerWidget {
  const TaskNotificationBanner({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(taskNotificationSyncProvider);
    if (!sync.hasError) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Reminder scheduling needs attention: ${sync.error}',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref
                    .read(taskNotificationServiceProvider)
                    .gateway
                    .permission(request: true);
              } catch (_) {}
              ref.invalidate(taskNotificationSyncProvider);
            },
            child: const Text('Retry reminders'),
          ),
        ],
      ),
    );
  }
}
