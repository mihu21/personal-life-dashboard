import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/add_schedule_button.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/one_time_event_editor.dart';

import 'academic_fixtures.dart';

void main() {
  testWidgets(
    'add menu opens Add event and Add course only after the menu closes',
    (tester) async {
      final data = sampleAcademicData();
      final semester = data.currentSemester!;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Center(
                child: AddScheduleButton(
                  data: data,
                  semester: semester,
                  initialDate: DateTime(2026, 9, 7),
                  onAddCourse: (context) async {
                    await showDialog<void>(
                      context: context,
                      builder: (_) => const AlertDialog(
                        title: Text('Course picker opened'),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      expect(find.text('Add course'), findsOneWidget);
      expect(find.text('Add event'), findsOneWidget);
      expect(find.text('Add one-time event'), findsNothing);

      await tester.tap(find.text('Add event'));
      await tester.pumpAndSettle();
      expect(find.byType(OneTimeEventEditor), findsOneWidget);
      expect(find.text('Add event'), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add course'));
      await tester.pumpAndSettle();
      expect(find.text('Course picker opened'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
