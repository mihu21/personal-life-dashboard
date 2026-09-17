import 'package:personal_life_dashboard/features/tasks/presentation/task_categories_dialog.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/task_details.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/task_visuals.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/app/theme/app_theme.dart';
import 'package:personal_life_dashboard/features/class_schedule/providers/academic_providers.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/task_editor.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/task_filter_dialog.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/tasks_module.dart';
import 'package:personal_life_dashboard/features/tasks/providers/task_providers.dart';

import 'academic_fixtures.dart';
import 'task_logic_test.dart' show taskFixture;

class WidgetTaskFilter extends TaskFilterNotifier {
  @override
  Future<TaskFilter> build() async => const TaskFilter();
  @override
  Future<void> apply(TaskFilter filter) async {
    state = AsyncData(filter);
  }
}

void main() {
  const output = String.fromEnvironment('TASK_AUDIT_OUTPUT');
  setUpAll(() async {
    if (output.isNotEmpty && Platform.isWindows) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      final font = FontLoader('Roboto')
        ..addFont(
          File(
            'C:/Windows/Fonts/segoeui.ttf',
          ).readAsBytes().then(ByteData.sublistView),
        );
      await font.load();
    }
  });
  final now = DateTime.now();
  final bundles = [
    TaskBundle(
      taskFixture(
        'Submit OS homework',
        due: DateTime(now.year, now.month, now.day, 23, 59),
        category: 'Homework',
        priority: TaskPriority.high,
      ),
      [TaskReminder(id: 1, taskId: 'Submit OS homework', minutesBefore: 60)],
    ),
    TaskBundle(taskFixture('Research exchange programs')),
    TaskBundle(
      taskFixture(
        'Overdue report',
        due: taskDayAfter(now, -2),
        category: 'Organization',
      ),
    ),
    TaskBundle(
      taskFixture(
        'Buy detergent',
        due: taskDayAfter(now, 1),
        timed: false,
        category: 'Shopping',
      ),
    ),
  ];

  Future<void> pump(
    WidgetTester tester,
    Size size,
    double scale, {
    bool dark = false,
    Widget? child,
    GlobalKey? boundary,
    AcademicSnapshot? snapshot,
    List<TaskBundle>? taskBundles,
    DateTime? clock,
  }) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    tester.platformDispatcher.textScaleFactorTestValue = scale;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      tester.platformDispatcher.clearTextScaleFactorTestValue();
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          taskCategoriesProvider.overrideWith(
            (_) => Stream.value([
              for (final e in defaultTaskCategoryColors.entries)
                TaskCategoryRecord(name: e.key, color: e.value),
            ]),
          ),
          tasksProvider.overrideWith((_) => Stream.value(taskBundles ?? bundles)),
          taskFilterProvider.overrideWith(WidgetTaskFilter.new),
          taskNotificationSyncProvider.overrideWith((_) async {}),
          academicSnapshotProvider.overrideWith(
            (_) => Stream.value(snapshot ?? sampleAcademicData()),
          ),
          scheduleClockProvider.overrideWith((_) => Stream.value(clock ?? now)),
        ],
        child: MaterialApp(
          theme: dark ? AppTheme.dark : AppTheme.light,
          builder: (context, child) => Theme(
            data: AppTheme.responsive(context, Theme.of(context)),
            child: child!,
          ),
          home: RepaintBoundary(
            key: boundary,
            child: Scaffold(body: child ?? const TasksModule()),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(900, 600),
    const Size(1440, 900),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('task views, editor and filters fit $size at ${scale}x', (
        tester,
      ) async {
        await pump(tester, size, scale, dark: scale == 2);
        expect(find.text('Agenda'), findsOneWidget);
        expect(find.text('Daily'), findsNothing);
        expect(find.textContaining('Overdue ·'), findsOneWidget);
        expect(tester.takeException(), isNull);
        for (final view in ['Week', 'Month', 'Agenda']) {
          await tester.ensureVisible(find.widgetWithText(ChoiceChip, view));
          await tester.tap(find.widgetWithText(ChoiceChip, view));
          await tester.pumpAndSettle();
          expect(tester.takeException(), isNull);
          expect(find.text('Algebra'), findsNothing);
          expect(find.text('Networks'), findsNothing);
        }
        await tester.ensureVisible(find.byTooltip('Filter tasks').last);
        await tester.tap(find.byTooltip('Filter tasks').last);
        await tester.pumpAndSettle();
        expect(find.byType(TaskFilterDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
        await tester.ensureVisible(find.text('Add task'));
        await tester.tap(find.text('Add task'));
        await tester.pumpAndSettle();
        expect(find.byType(TaskEditor), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });
    }
  }

  testWidgets(
    'agenda search and applied multi-select filters affect visible tasks',
    (tester) async {
      await pump(tester, const Size(900, 1200), 1);
      await tester.enterText(
        find.widgetWithText(TextField, 'Search tasks'),
        'exchange',
      );
      await tester.pumpAndSettle();
      expect(find.text('Research exchange programs'), findsOneWidget);
      expect(find.text('Submit OS homework'), findsNothing);
      await tester.tap(find.byTooltip('Clear search'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Filter tasks').last);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(FilterChip, 'Homework'));
      await tester.tap(find.widgetWithText(FilterChip, 'Shopping'));
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();
      expect(find.text('Submit OS homework'), findsOneWidget);
      expect(find.text('Buy detergent'), findsOneWidget);
      expect(find.text('Research exchange programs'), findsNothing);
    },
  );

  testWidgets(
    'existing custom reminders and recurrence remain editable at large text',
    (tester) async {
      final bundle =
          TaskBundle(taskFixture('Weekly review', repeat: RepeatUnit.weekly), [
            TaskReminder(
              id: 4,
              taskId: 'Weekly review',
              customAt: now.add(const Duration(days: 1)),
            ),
          ]);
      await pump(
        tester,
        const Size(320, 568),
        2,
        child: TaskEditor(bundle: bundle),
      );
      await tester.ensureVisible(find.text('Add reminder'));
      await tester.pumpAndSettle();
      expect(find.byTooltip('Snooze reminder'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Recurrence'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('category management remains usable at 200 percent text', (tester) async {
    await pump(tester, const Size(320, 568), 2, child: const TaskCategoriesDialog());
    await tester.ensureVisible(find.byTooltip('Edit Homework'));
    await tester.tap(find.byTooltip('Edit Homework'));
    await tester.pumpAndSettle();
    expect(find.text('Edit category'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.ensureVisible(find.widgetWithText(TextField, 'Color (six-digit hex)'));
    expect(tester.takeException(), isNull);
  });

  testWidgets('click opens readable details before editing', (tester) async {
    await pump(tester, const Size(900, 600), 1);
    await tester.tap(find.text('Submit OS homework'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetails), findsOneWidget);
    expect(find.byType(TaskEditor), findsNothing);
    expect(find.byTooltip('Mark complete'), findsOneWidget);
    expect(find.text('Complete task'), findsNothing);
    expect(find.text('Active'), findsNothing);
    expect(find.text('Delete task'), findsOneWidget);
    await tester.tap(find.text('Edit task'));
    await tester.pumpAndSettle();
    expect(find.byType(TaskDetails), findsNothing);
    expect(find.byType(TaskEditor), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<TaskStatus>), findsNothing);
  });

  testWidgets('course choices contain only current in-progress courses', (
    tester,
  ) async {
    final source = sampleAcademicData();
    final snapshot = AcademicSnapshot(
      semesters: source.semesters,
      categories: source.categories,
      courses: [
        source.courses[0],
        source.courses[1].copyWith(status: CourseStatus.completed),
        source.courses[2].copyWith(semesterId: 'previous'),
      ],
      meetings: source.meetings,
      exceptions: source.exceptions,
      tags: source.tags,
      courseTags: source.courseTags,
      settings: source.settings,
    );
    await pump(
      tester,
      const Size(900, 900),
      1,
      child: const TaskEditor(),
      snapshot: snapshot,
    );
    final fields = tester.widgetList<DropdownButtonFormField<String>>(
      find.byType(DropdownButtonFormField<String>),
    );
    final field = fields.firstWhere(
      (f) => f.decoration.labelText == 'Active course (optional)',
    );
    final courseDropdown = tester.widget<DropdownButton<String>>(
      find.descendant(
        of: find.byWidget(field),
        matching: find.byType(DropdownButton<String>),
      ),
    );
    expect(courseDropdown.items!.map((i) => i.value), ['', 'course-0']);
    expect(find.byType(DropdownButtonFormField<TaskStatus>), findsNothing);
    final priorities = tester.widget<DropdownButtonFormField<TaskPriority>>(
      find.byType(DropdownButtonFormField<TaskPriority>),
    );
    final priorityDropdown = tester.widget<DropdownButton<TaskPriority>>(
      find.descendant(
        of: find.byWidget(priorities),
        matching: find.byType(DropdownButton<TaskPriority>),
      ),
    );
    expect(priorityDropdown.items!.length, 3);
  });

  testWidgets('small card stays a compact agenda preview', (tester) async {
    await pump(
      tester,
      const Size(840, 420),
      1,
      child: const TasksDashboardCard(),
    );
    expect(find.widgetWithText(TextField, 'Search tasks'), findsNothing);
    expect(find.byTooltip('Filter tasks'), findsOneWidget);
    expect(find.byTooltip('Change task view'), findsOneWidget);
    expect(find.byTooltip('Add task'), findsOneWidget);
    expect(find.byTooltip('Expand Tasks & Reminders'), findsOneWidget);

    final element = tester.element(find.byType(TasksModule));
    final container = ProviderScope.containerOf(element);
    container.read(taskDisplayProvider.notifier).view(TaskView.month);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('task-month-grid')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.byTooltip('Expand Tasks & Reminders'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Month'))
          .selected,
      true,
    );
  });



  testWidgets('mobile agenda is dense and keeps completion checkbox only there', (
    tester,
  ) async {
    final clock = DateTime(2026, 9, 16, 12);
    final mobileBundles = [
      TaskBundle(
        taskFixture(
          'Mobile high',
          due: DateTime(2026, 9, 16, 18, 30),
          category: 'Personal',
          priority: TaskPriority.high,
        ),
      ),
      TaskBundle(
        taskFixture(
          'Mobile medium',
          due: DateTime(2026, 9, 16),
          timed: false,
          category: 'Organization',
          priority: TaskPriority.medium,
        ),
      ),
    ];

    await pump(
      tester,
      const Size(320, 700),
      1,
      taskBundles: mobileBundles,
      clock: clock,
    );

    expect(find.text('Mobile high'), findsOneWidget);
    expect(find.text('Mobile medium'), findsOneWidget);
    expect(find.text('Personal · High'), findsNothing);
    expect(find.text('Organization · Medium'), findsNothing);
    expect(find.text('Active'), findsNothing);
    expect(find.byType(Checkbox), findsNWidgets(2));

    final element = tester.element(find.byType(TasksModule));
    final container = ProviderScope.containerOf(element);
    container.read(taskDisplayProvider.notifier).date(clock);
    container.read(taskDisplayProvider.notifier).view(TaskView.week);
    await tester.pumpAndSettle();

    expect(find.text('Mobile high'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('Personal · High'), findsNothing);
    expect(find.text('Active'), findsNothing);
    expect(tester.takeException(), isNull);
  });
  testWidgets('mobile week fits all seven days and shows each day tasks', (
    tester,
  ) async {
    final clock = DateTime(2026, 9, 16, 12);
    final weekBundles = [
      TaskBundle(
        taskFixture(
          'Monday planning task with a long name',
          due: DateTime(2026, 9, 14, 9, 15),
          priority: TaskPriority.high,
          category: 'Personal',
        ),
      ),
      TaskBundle(
        taskFixture(
          'Wednesday task',
          due: DateTime(2026, 9, 16, 18, 30),
          priority: TaskPriority.medium,
          category: 'Homework',
        ),
      ),
      TaskBundle(
        taskFixture(
          'Sunday task',
          due: DateTime(2026, 9, 20),
          timed: false,
          priority: TaskPriority.low,
          category: 'Shopping',
        ),
      ),
    ];

    await pump(
      tester,
      const Size(320, 700),
      1,
      taskBundles: weekBundles,
      clock: clock,
    );
    final element = tester.element(find.byType(TasksModule));
    final container = ProviderScope.containerOf(element);
    container.read(taskDisplayProvider.notifier).date(clock);
    container.read(taskDisplayProvider.notifier).view(TaskView.week);
    await tester.pumpAndSettle();

    for (final day in [14, 15, 16, 17, 18, 19, 20]) {
      expect(
        find.byKey(ValueKey('task-mobile-week-day-2026-9-$day')),
        findsOneWidget,
      );
    }
    expect(
      find.byKey(
        const ValueKey(
          'task-mobile-week-task-Monday planning task with a long name',
        ),
      ),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('task-mobile-week-task-Wednesday task')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('task-mobile-week-task-Sunday task')),
      findsOneWidget,
    );
    expect(find.text('09:15 High'), findsOneWidget);
    expect(find.text('18:30 Medium'), findsOneWidget);
    expect(find.text('Low'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('task details keeps scrolling confined to the notes area', (
    tester,
  ) async {
    final bundle = TaskBundle(
      taskFixture('Long notes task').copyWith(
        notes: List.generate(40, (i) => 'Note line ${i + 1}').join('\n'),
      ),
    );
    await pump(
      tester,
      const Size(320, 568),
      1,
      child: TaskDetails(bundle: bundle),
    );

    expect(find.byKey(const ValueKey('task-notes-area')), findsOneWidget);
    expect(find.byKey(const ValueKey('task-notes-scroll')), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('task-notes-area'))).width,
      greaterThan(200),
    );
    expect(find.text('Reminders (0)'), findsOneWidget);
    expect(find.text('Does not repeat.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('small week cards leave the checkbox out to preserve width', (
    tester,
  ) async {
    final clock = DateTime(2026, 9, 16, 12);
    final weekBundles = [
      TaskBundle(
        taskFixture(
          'High priority task',
          due: clock,
          category: 'Homework',
          priority: TaskPriority.high,
        ),
      ),
      TaskBundle(
        taskFixture(
          'Medium priority task',
          due: clock,
          category: 'Personal',
          priority: TaskPriority.medium,
        ),
      ),
    ];
    await pump(
      tester,
      const Size(840, 420),
      1,
      child: const TasksDashboardCard(),
      taskBundles: weekBundles,
      clock: clock,
    );
    final element = tester.element(find.byType(TasksModule));
    final container = ProviderScope.containerOf(element);
    container.read(taskDisplayProvider.notifier).date(clock);
    container.read(taskDisplayProvider.notifier).view(TaskView.week);
    await tester.pumpAndSettle();

    expect(find.text('High priority task'), findsOneWidget);
    expect(find.text('Medium priority task'), findsOneWidget);
    expect(find.byType(Checkbox), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final dashboardCompact in [false, true]) {
    testWidgets(
      'month uses compact bars in dashboard and detailed rows when expanded; '
      'adjacent-month days stay dimmed ${dashboardCompact ? 'in dashboard' : 'when expanded'}',
      (tester) async {
        final clock = DateTime(2026, 9, 16, 12);
        final monthBundles = [
          TaskBundle(
            taskFixture(
              'month-high',
              due: DateTime(2026, 9, 16),
              priority: TaskPriority.high,
              category: 'Homework',
            ),
          ),
          TaskBundle(
            taskFixture(
              'month-medium',
              due: DateTime(2026, 9, 16),
              priority: TaskPriority.medium,
              category: 'Personal',
            ),
          ),
          TaskBundle(
            taskFixture(
              'month-low',
              due: DateTime(2026, 9, 16),
              priority: TaskPriority.low,
              category: 'Shopping',
            ),
          ),
          TaskBundle(
            taskFixture(
              'month-next-day',
              due: DateTime(2026, 9, 17),
              category: 'Organization',
            ),
          ),
        ];
        await pump(
          tester,
          dashboardCompact ? const Size(840, 420) : const Size(1440, 700),
          1,
          child: dashboardCompact
              ? const TasksDashboardCard()
              : const TasksModule(),
          taskBundles: monthBundles,
          clock: clock,
        );
        final element = tester.element(find.byType(TasksModule));
        final container = ProviderScope.containerOf(element);
        container.read(taskDisplayProvider.notifier).date(clock);
        container.read(taskDisplayProvider.notifier).view(TaskView.month);
        await tester.pumpAndSettle();

        final compactIndicators = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('task-month-indicator-');
        });
        final detailedRows = find.byWidgetPredicate((widget) {
          final key = widget.key;
          return key is ValueKey<String> &&
              key.value.startsWith('task-month-detail-');
        });
        if (dashboardCompact) {
          expect(compactIndicators, findsNWidgets(monthBundles.length));
          expect(detailedRows, findsNothing);
        } else {
          expect(compactIndicators, findsNothing);
          expect(detailedRows, findsWidgets);
        }

        final outside = tester.widget<Opacity>(
          find.byKey(const ValueKey('task-month-cell-2026-8-31')),
        );
        final inside = tester.widget<Opacity>(
          find.byKey(const ValueKey('task-month-cell-2026-9-1')),
        );
        expect(outside.opacity, lessThan(1));
        expect(inside.opacity, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final month in [DateTime(2026, 9), DateTime(2026, 11)]) {
    testWidgets('month grid fits desktop height for ${month.month}', (
      tester,
    ) async {
      await pump(tester, const Size(1440, 700), 1);
      final element = tester.element(find.byType(TasksModule));
      final container = ProviderScope.containerOf(element);
      container.read(taskDisplayProvider.notifier).date(month);
      container.read(taskDisplayProvider.notifier).view(TaskView.month);
      await tester.pumpAndSettle();
      final grid = find.byKey(const ValueKey('task-month-grid'));
      final rect = tester.getRect(grid);
      expect(rect.bottom, lessThanOrEqualTo(700));
      expect(find.text('Monday'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('priority marks encode one two and three category-colored bars', (
    tester,
  ) async {
    await pump(
      tester,
      const Size(900, 600),
      1,
      child: Row(
        children: [
          for (final p in TaskPriority.values)
            TaskPriorityMark(
              priority: p,
              color: const Color(0xFF123456),
              category: 'Study',
            ),
        ],
      ),
    );
    for (final p in TaskPriority.values) {
      final mark = find.byWidgetPredicate(
        (w) => w is TaskPriorityMark && w.priority == p,
      );
      expect(
        find.descendant(of: mark, matching: find.byType(Container)),
        findsNWidgets(3 - p.index),
      );
    }
  });

  if (output.isNotEmpty) {
    for (final dark in [false, true]) {
      testWidgets('render task views ${dark ? 'dark' : 'light'}', (
        tester,
      ) async {
        final boundary = GlobalKey();
        await pump(
          tester,
          const Size(1440, 900),
          1,
          dark: dark,
          boundary: boundary,
        );
        for (final view in ['Agenda', 'Week', 'Month']) {
          await tester.tap(find.widgetWithText(ChoiceChip, view));
          await tester.pumpAndSettle();
          await tester.runAsync(() async {
            final render =
                boundary.currentContext!.findRenderObject()!
                    as RenderRepaintBoundary;
            final image = await render.toImage();
            final bytes = await image.toByteData(
              format: ui.ImageByteFormat.png,
            );
            final file = File(
              '$output/${view.toLowerCase()}-${dark ? 'dark' : 'light'}.png',
            );
            await file.parent.create(recursive: true);
            await file.writeAsBytes(bytes!.buffer.asUint8List());
            image.dispose();
          });
        }
      });
    }
  }
}
