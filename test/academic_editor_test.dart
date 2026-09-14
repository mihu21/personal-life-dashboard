import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:drift/native.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/course_draft.dart';
import 'package:personal_life_dashboard/features/class_schedule/providers/academic_providers.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/course_editor.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/record_editors.dart';

import 'academic_fixtures.dart';

void main() {
  testWidgets(
    'conflict review cancels save; Save anyway persists a fresh duplicate',
    (tester) async {
      final repository = _RecordingRepository();
      addTearDown(repository.db.close);
      final data = sampleAcademicData();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [academicRepositoryProvider.overrideWithValue(repository)],
          child: MaterialApp(
            home: Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () => showDialog(
                    context: context,
                    builder: (_) => CourseEditor(
                      data: data,
                      course: data.courses.first,
                      duplicate: true,
                    ),
                  ),
                  child: const Text('Open editor'),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open editor'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Schedule conflicts'), findsOneWidget);
      expect(repository.saved, isNull);
      await tester.tap(find.text('Review times'));
      await tester.pumpAndSettle();
      expect(find.byType(CourseEditor), findsOneWidget);
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save anyway'));
      await tester.pumpAndSettle();
      expect(repository.saved?.name, 'Algebra');
      expect(repository.saved?.id, isNull);
      expect(repository.saved?.meetings.single.id, isNull);
      expect(find.byType(CourseEditor), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'course form accepts zero credits while still validating required fields',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: CourseEditor(data: emptyAcademicData())),
          ),
        ),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Credits'),
        '0',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(find.text('Course name is required.'), findsOneWidget);
      expect(find.text('Credits cannot be negative.'), findsNothing);
      expect(find.text('Create and select a semester first.'), findsOneWidget);
      expect(find.text('Create and select a category first.'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('course form rejects negative credits', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: CourseEditor(data: emptyAcademicData())),
        ),
      ),
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'Credits'), '-1');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Credits cannot be negative.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('category editor supports hiding and validates credit target', (
    tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(home: Scaffold(body: CategoryEditor())),
      ),
    );
    await tester.enterText(
      find.widgetWithText(
        TextFormField,
        'Required / max counted credits (optional)',
      ),
      '-1',
    );
    await tester.tap(find.text('Active category'));
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Enter a non-negative credit target.'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).value,
      false,
    );
    expect(tester.takeException(), isNull);
  });
}

class _RecordingRepository extends AcademicRepository {
  _RecordingRepository() : super(AcademicDatabase(NativeDatabase.memory()));
  CourseDraft? saved;
  @override
  Future<AcademicSnapshot> snapshot() async => sampleAcademicData();
  @override
  Future<String> saveCourse(CourseDraft draft) async {
    saved = draft;
    return 'saved';
  }
}
