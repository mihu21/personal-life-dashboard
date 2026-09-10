import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/app/dashboard_app.dart';
import 'package:personal_life_dashboard/app/shell/shell_state.dart';
import 'package:personal_life_dashboard/shared/widgets/module_placeholder.dart';

Future<void> pumpDashboard(
  WidgetTester tester, {
  Size size = const Size(1280, 1000),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
  await tester.pumpWidget(const ProviderScope(child: DashboardApp()));
  await tester.pumpAndSettle();
}

Finder module(String title) => find.widgetWithText(ModulePlaceholder, title);

void main() {
  testWidgets('desktop places Today above the specified two-by-two dashboard', (
    tester,
  ) async {
    await pumpDashboard(tester);
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.byType(ModulePlaceholder), findsNWidgets(4));

    final schedule = tester.getTopLeft(module('Class Schedule'));
    final tasks = tester.getTopLeft(module('Tasks & Reminders'));
    final shopping = tester.getTopLeft(module('Shopping'));
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
      expect(find.byType(Scrollable), findsNothing);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Your day, in one place.'), findsNothing);
      expect(find.text('Your week, a little clearer.'), findsNothing);
      expect(find.byType(AppBar), findsNothing);
      expect(find.text('Personal space'), findsNothing);
      final today = tester.getRect(find.byKey(const ValueKey('today-summary')));
      expect(today.top, 12);
      expect(today.height, 40);
      final settings = tester.getRect(find.byTooltip('Settings'));
      expect(settings.right, greaterThan(size.width - 64));
      expect(settings.top, greaterThanOrEqualTo(today.top));
      expect(settings.bottom, lessThanOrEqualTo(today.bottom));

      final panels = [
        for (final title in [
          'Class Schedule',
          'Tasks & Reminders',
          'Shopping',
          'Spending',
        ])
          tester.getRect(module(title)),
      ];
      for (final panel in panels) {
        expect(panel.size, panels.first.size);
        expect(panel.top, greaterThanOrEqualTo(64));
        expect(panel.height, (size.height - 88) / 2);
        expect(panel.bottom, lessThanOrEqualTo(size.height - 12));
      }
      expect(panels.first.left, 12);
      expect(panels[1].right, size.width - 12);
      expect(panels.last.bottom, size.height - 12);
      expect(panels[1].left - panels.first.right, 12);
      expect(panels[2].top - panels.first.bottom, 12);
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
    expect(find.byType(Scrollable), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile navigation shows one placeholder per destination', (
    tester,
  ) async {
    await pumpDashboard(tester, size: const Size(390, 844));
    expect(module('Class Schedule'), findsOneWidget);
    expect(find.text('Today'), findsNothing);
    expect(find.text('Make time for learning.'), findsOneWidget);
    expect(find.text('Your week, a little clearer.'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    for (final entry in {
      'Tasks': 'Tasks & Reminders',
      'Shopping': 'Shopping',
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
      expect(find.byType(ModulePlaceholder), findsOneWidget);
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
    expect(find.byType(ModulePlaceholder), findsNWidgets(4));
    tester.view.physicalSize = const Size(390, 844);
    await tester.pumpAndSettle();
    expect(module('Tasks & Reminders'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      1,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('mobile theme menu switches light, dark, and system appearance', (
    tester,
  ) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpDashboard(tester, size: const Size(390, 844));

    Brightness brightness() =>
        Theme.of(tester.element(find.byType(Scaffold))).brightness;
    expect(brightness(), Brightness.dark);
    for (final entry in {
      'Light theme': Brightness.light,
      'Dark theme': Brightness.dark,
      'System theme': Brightness.dark,
    }.entries) {
      await tester.tap(find.byTooltip('Choose theme'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(CheckedPopupMenuItem<ThemeMode>, entry.key),
      );
      await tester.pumpAndSettle();
      expect(brightness(), entry.value);
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
      expect(find.byType(Scrollable), findsNothing);
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
        await tester.drag(
          find.byType(SingleChildScrollView),
          const Offset(0, -1500),
        );
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
    });
  }
}
