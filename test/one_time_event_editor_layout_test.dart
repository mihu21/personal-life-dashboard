import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/one_time_event_editor.dart';

Future<void> _pumpEditor(
  WidgetTester tester, {
  required Size size,
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    tester.platformDispatcher.clearTextScaleFactorTestValue();
  });

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => Center(
              child: FilledButton(
                onPressed: () => showOneTimeEventEditor(
                  context,
                  initialDate: DateTime(2026, 9, 12),
                ),
                child: const Text('Open event editor'),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open event editor'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('event editor opens on desktop without intrinsic layout errors', (
    tester,
  ) async {
    await _pumpEditor(tester, size: const Size(1280, 720));

    expect(find.byType(OneTimeEventEditor), findsOneWidget);
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
    expect(find.text('Event title'), findsOneWidget);
    expect(find.text('Start period'), findsOneWidget);
    expect(find.text('End period'), findsOneWidget);
    expect(find.text('Reminders'), findsNothing);
    expect(find.text('Add reminder'), findsNothing);
    expect(
      find.descendant(
        of: find.byType(OneTimeEventEditor),
        matching: find.byType(LayoutBuilder),
      ),
      findsNothing,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.byType(OneTimeEventEditor), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'event editor opens on narrow mobile with large text and scrolls',
    (tester) async {
      await _pumpEditor(tester, size: const Size(390, 844), textScale: 2);

      expect(find.byType(OneTimeEventEditor), findsOneWidget);
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
      expect(find.text('Add event'), findsOneWidget);
      expect(find.text('Start period'), findsOneWidget);
      expect(find.text('End period'), findsOneWidget);
      expect(find.text('Reminders'), findsNothing);
      expect(tester.takeException(), isNull);

      await tester.ensureVisible(find.text('Cancel'));
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(OneTimeEventEditor), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
