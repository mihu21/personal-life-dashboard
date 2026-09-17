import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';
import 'package:personal_life_dashboard/features/note_plus/domain/note_plus_types.dart';
import 'package:personal_life_dashboard/features/note_plus/presentation/note_plus_module.dart';
import 'package:personal_life_dashboard/features/note_plus/providers/note_plus_providers.dart';
import 'package:personal_life_dashboard/features/tasks/presentation/tasks_module.dart';
import 'package:personal_life_dashboard/features/tasks/providers/task_providers.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/app/dashboard_app.dart';
import 'package:personal_life_dashboard/app/shell/shell_state.dart';
import 'package:personal_life_dashboard/shared/widgets/module_placeholder.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/class_schedule_card.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/class_schedule_module.dart';
import 'package:personal_life_dashboard/features/class_schedule/providers/academic_providers.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/week_timetable.dart';

import 'academic_fixtures.dart';

Future<void> pumpDashboard(
  WidgetTester tester, {
  Size size = const Size(1280, 1000),
  double textScale = 1,
  AcademicSnapshot? data,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        taskCategoriesProvider.overrideWith(
          (_) => Stream.value([
            for (final e in defaultTaskCategoryColors.entries)
              TaskCategoryRecord(name: e.key, color: e.value),
          ]),
        ),
        tasksProvider.overrideWith((ref) => Stream.value(const <TaskBundle>[])),
        taskFilterProvider.overrideWith(_TestTaskFilter.new),
        taskNotificationSyncProvider.overrideWith((ref) async {}),
        notePlusProvider.overrideWith((ref) => Stream.value(const NotePlusSnapshot(notes: [], lists: []))),
        academicSnapshotProvider.overrideWith(
          (ref) => Stream.value(data ?? emptyAcademicData()),
        ),
        scheduleClockProvider.overrideWith(
          (ref) => Stream.value(DateTime(2026, 9, 7, 9, 30)),
        ),
        oneTimeEventsProvider.overrideWith((ref) async => const []),
      ],
      child: const DashboardApp(),
    ),
  );
  await tester.pumpAndSettle();
}

Finder module(String title) => title == 'Class Schedule'
    ? find.byWidgetPredicate(
        (widget) =>
            widget is ClassScheduleCard || widget is ClassScheduleModule,
      )
    : title == 'Tasks & Reminders'
    ? find.byWidgetPredicate(
        (widget) =>
            widget is TasksDashboardCard ||
            widget is TasksModule && !widget.compact,
      )
    : title == 'Note+'
    ? find.byWidgetPredicate(
        (widget) => widget is NotePlusDashboardCard || widget is NotePlusModule,
      )
    : find.widgetWithText(ModulePlaceholder, title);

void main() {
  testWidgets(
    'populated mobile schedule fits a small screen at 200 percent text',
    (tester) async {
      await pumpDashboard(
        tester,
        size: const Size(320, 568),
        textScale: 2,
        data: sampleAcademicData(),
      );
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Week'));
      await tester.tap(find.text('Week'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'planning displays a future semester, impact and every conflict',
    (tester) async {
      await pumpDashboard(
        tester,
        size: const Size(390, 844),
        data: planningAcademicData(),
      );
      await tester.ensureVisible(find.text('Planning'));
      await tester.tap(find.text('Planning'));
      await tester.pumpAndSettle();
      expect(find.text('Add planned course'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Graduation impact preview'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.text('Graduation impact preview'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('Weekly schedule conflicts'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      await tester.scrollUntilVisible(
        find.textContaining('30 minutes overlap'),
        250,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('30 minutes overlap'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'progress and semester history expose separate credit and schedule views',
    (tester) async {
      await pumpDashboard(
        tester,
        size: const Size(390, 844),
        data: sampleAcademicData(),
      );
      await tester.tap(find.text('Graduation'));
      await tester.pumpAndSettle();
      expect(find.text('Academic progress'), findsOneWidget);
      expect(find.text('Completed'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      await tester.ensureVisible(find.text('History'));
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();
      expect(find.text('Semester history'), findsOneWidget);
      await tester.tap(find.text('2026 Fall'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('View schedule'));
      await tester.pumpAndSettle();
      expect(find.text('2026 Fall schedule'), findsOneWidget);
      expect(find.text('Algebra'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('populated desktop switches Today and Week within its panel', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      size: const Size(900, 320),
      data: sampleAcademicData(),
    );
    expect(find.text('Algebra'), findsOneWidget);
    await tester.tap(find.byTooltip('Show week'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekTimetable), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(find.text('Networks'), findsOneWidget);
    final scrollables = find.descendant(
      of: find.byType(WeekTimetable),
      matching: find.byType(Scrollable),
    );
    expect(scrollables, findsNothing);
    expect(
      tester.getRect(find.byType(WeekTimetable)).bottom,
      lessThanOrEqualTo(tester.getRect(find.byType(ClassScheduleCard)).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('full schedule and dashboard card share Today/Week mode', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      size: const Size(900, 600),
      data: sampleAcademicData(),
    );

    await tester.tap(find.byTooltip('Show week'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekTimetable), findsOneWidget);

    await tester.tap(find.byTooltip('Open full schedule'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekTimetable), findsOneWidget);

    await tester.tap(find.text('Today'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekTimetable), findsNothing);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Show week'), findsOneWidget);
    expect(find.byType(WeekTimetable), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile schedule keeps records inside the more-actions menu', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      size: const Size(390, 844),
      data: sampleAcademicData(),
    );
    expect(find.byTooltip('Manage records'), findsNothing);
    await tester.tap(find.byTooltip('More schedule actions'));
    await tester.pumpAndSettle();
    expect(find.text('Manage records'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile full schedule renders populated timetable', (
    tester,
  ) async {
    await pumpDashboard(
      tester,
      size: const Size(390, 844),
      data: sampleAcademicData(),
    );
    expect(find.text('Algebra'), findsOneWidget);
    await tester.tap(find.text('Week'));
    await tester.pumpAndSettle();
    expect(find.byType(WeekTimetable), findsOneWidget);
    expect(find.text('Algebra'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('desktop places Today above the specified two-by-two dashboard', (
    tester,
  ) async {
    await pumpDashboard(tester);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(ModulePlaceholder), findsOneWidget);

    final schedule = tester.getTopLeft(module('Class Schedule'));
    final tasks = tester.getTopLeft(module('Tasks & Reminders'));
    final shopping = tester.getTopLeft(module('Note+'));
    final spending = tester.getTopLeft(module('Spending'));
    expect(tester.getBottomLeft(find.text('Today')).dy, lessThan(schedule.dy));
    expect(schedule.dy, tasks.dy);
    expect(schedule.dx, lessThan(tasks.dx));
    expect(shopping.dy, spending.dy);
    expect(shopping.dy, greaterThan(schedule.dy));
    expect(shopping.dx, schedule.dx);
    expect(spending.dx, tasks.dx);
    expect(tester.takeException(), isNull);
  });

  for (final size in const [
    Size(900, 320),
    Size(900, 600),
    Size(1280, 720),
    Size(1920, 1080),
    Size(2560, 1440),
  ]) {
    testWidgets('desktop fills $size with four equal panels and no scrolling', (
      tester,
    ) async {
      await pumpDashboard(tester, size: size);
      expect(
        find
            .byType(Scrollable)
            .evaluate()
            .where(
              (e) =>
                  e.findAncestorWidgetOfExactType<TasksDashboardCard>() == null,
            ),
        isEmpty,
      );
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Your day, in one place.'), findsNothing);
      expect(find.text('Your week, a little clearer.'), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Personal space'), findsNothing);
      final today = tester.getRect(find.byKey(const ValueKey('today-summary')));
      expect(today.top, 8);
      expect(today.height, inInclusiveRange(34, 44));
      final settings = tester.getRect(find.byTooltip('Settings'));
      expect(settings.right, greaterThan(size.width - 64));
      expect(settings.top, greaterThanOrEqualTo(today.top));
      expect(settings.bottom, lessThanOrEqualTo(today.bottom));

      final panels = [
        for (final title in [
          'Class Schedule',
          'Tasks & Reminders',
          'Note+',
          'Spending',
        ])
          tester.getRect(module(title)),
      ];
      for (final panel in panels) {
        expect(panel.size, panels.first.size);
        expect(panel.top, greaterThanOrEqualTo(50));
        expect(panel.height, (size.height - today.height - 32) / 2);
        expect(panel.bottom, lessThanOrEqualTo(size.height - 8));
      }
      expect(panels.first.left, 8);
      expect(panels[1].right, size.width - 8);
      expect(panels.last.bottom, size.height - 8);
      expect(panels[1].left - panels.first.right, 8);
      expect(panels[2].top - panels.first.bottom, 8);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('desktop panels grow with window height and support large text', (
    tester,
  ) async {
    await pumpDashboard(tester, size: const Size(900, 600), textScale: 2);
    final initialHeight = tester.getSize(module('Class Schedule')).height;
    expect(tester.takeException(), isNull);
    tester.view.physicalSize = const Size(1920, 1080);
    await tester.pumpAndSettle();
    expect(
      tester.getSize(module('Class Schedule')).height,
      greaterThan(initialHeight),
    );
    expect(
      find
          .byType(Scrollable)
          .evaluate()
          .where(
            (e) =>
                e.findAncestorWidgetOfExactType<TasksDashboardCard>() == null,
          ),
      isEmpty,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile navigation shows the selected module', (tester) async {
    await pumpDashboard(tester, size: const Size(390, 844));
    expect(module('Class Schedule'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.byTooltip('Manage records'), findsNothing);
    expect(find.byTooltip('Settings'), findsOneWidget);
    expect(find.text('Your week, a little clearer.'), findsNothing);

    for (final entry in {
      'Tasks': 'Tasks & Reminders',
      'Note+': 'Note+',
      'Spending': 'Spending',
      'Schedule': 'Class Schedule',
    }.entries) {
      await tester.tap(
        find.descendant(
          of: find.byType(NavigationBar),
          matching: find.text(entry.key),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byType(ModulePlaceholder),
        entry.key == 'Spending' ? findsOneWidget : findsNothing,
      );
      expect(module(entry.value), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('selected mobile destination survives a desktop resize', (
    tester,
  ) async {
    await pumpDashboard(tester, size: const Size(390, 844));
    await tester.tap(find.text('Tasks'));
    await tester.pumpAndSettle();
    tester.view.physicalSize = const Size(1200, 900);
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(ModulePlaceholder), findsOneWidget);
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(module('Tasks & Reminders'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile settings switches light, dark, and system appearance', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpDashboard(tester, size: const Size(390, 844));

    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold))).brightness;
    expect(brightness(), Brightness.dark);
    await tester.tap(find.byTooltip('Settings'));
    await tester.pumpAndSettle();
    expect(find.text('Theme'), findsOneWidget);

    for (final entry in {
      'Light theme': Brightness.light,
      'Dark theme': Brightness.dark,
      'System theme': Brightness.dark,
    }.entries) {
      await tester.tap(find.byType(DropdownButton<ThemeMode>));
      await tester.pumpAndSettle();
      await tester.tap(find.text(entry.key).last);
      await tester.pumpAndSettle();
      expect(brightness(), entry.value);
      expect(find.byType(AlertDialog), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'desktop settings applies themes and retains selection on reopen',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      await pumpDashboard(tester);
      expect(find.byTooltip('Choose theme'), findsNothing);
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Theme'), findsOneWidget);

      for (final entry in {
        'Light theme': Brightness.light,
        'Dark theme': Brightness.dark,
        'System theme': Brightness.dark,
      }.entries) {
        await tester.tap(find.byType(DropdownButton<ThemeMode>));
        await tester.pumpAndSettle();
        await tester.tap(find.text(entry.key).last);
        await tester.pumpAndSettle();
        expect(
          Theme.of(tester.element(find.byType(Scaffold))).brightness,
          entry.value,
        );
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(tester.takeException(), isNull);
      }

      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      expect(
        find
            .byType(Scrollable)
            .evaluate()
            .where(
              (e) =>
                  e.findAncestorWidgetOfExactType<TasksDashboardCard>() == null,
            ),
        isEmpty,
      );
      await tester.tap(find.byTooltip('Settings'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<DropdownButton<ThemeMode>>(
              find.byType(DropdownButton<ThemeMode>),
            )
            .value,
        ThemeMode.system,
      );
    },
  );

  for (final size in const [Size(320, 568), Size(844, 390), Size(899, 700)]) {
    testWidgets('layout scrolls without overflow at $size and large text', (
      tester,
    ) async {
      await pumpDashboard(tester, size: size, textScale: 2);
      expect(tester.takeException(), isNull);
      final container = ProviderScope.containerOf(
        tester.element(find.byType(DashboardApp)),
      );
      for (final selection in DashboardModule.values) {
        container.read(selectedModuleProvider.notifier).select(selection);
        await tester.pumpAndSettle();
        if (find.byType(Scrollable).evaluate().isNotEmpty) {
          await tester.drag(
            find.byType(Scrollable).last,
            const Offset(0, -1500),
          );
        }
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}

class _TestTaskFilter extends TaskFilterNotifier {
  @override
  Future<TaskFilter> build() async => const TaskFilter();
}
