import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';
import 'package:personal_life_dashboard/features/tasks/providers/task_providers.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:drift/native.dart';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/app/dashboard_app.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_snapshot.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/nthu_catalog_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/nthu_academic.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/one_time_event.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/course_editor.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/nthu_course_picker.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/one_time_event_editor.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/record_editors.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/schedule_view.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/course_details.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/exception_editor.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/add_schedule_button.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/planning_view.dart';
import 'package:personal_life_dashboard/features/class_schedule/providers/academic_providers.dart';

import 'academic_fixtures.dart';

const _output = String.fromEnvironment('AUDIT_OUTPUT');
const _baseline = bool.fromEnvironment('AUDIT_BASELINE');
final _boundary = GlobalKey();

AcademicSnapshot _auditData() {
  final data = sampleAcademicData();
  return AcademicSnapshot(
    semesters: data.semesters,
    categories: [
      data.categories.first.copyWith(name: 'Departmental core requirements'),
    ],
    courses: [
      data.courses[0].copyWith(courseName: 'Linear Algebra and Applications'),
      data.courses[1].copyWith(
        courseName: 'Computer Networks and Communication',
      ),
      data.courses[2].copyWith(courseName: 'Mandarin Intermediate II'),
    ],
    meetings: data.meetings,
    exceptions: data.exceptions,
    tags: data.tags,
    courseTags: data.courseTags,
    settings: data.settings,
  );
}

Future<void> _capture(WidgetTester tester, String name) async {
  await tester.pumpAndSettle();
  final exception = tester.takeException();
  if (_baseline && exception != null) {
    debugPrint('BASELINE $name: $exception');
  } else {
    expect(exception, isNull, reason: name);
  }
  if (_output.isEmpty) return;
  await tester.runAsync(() async {
    final render =
        _boundary.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = await render.toImage();
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    final file = File('$_output/$name.png');
    await file.parent.create(recursive: true);
    await file.writeAsBytes(bytes!.buffer.asUint8List());
    image.dispose();
  });
}

Future<void> _open(WidgetTester tester, Widget dialog) async {
  final context = tester.element(find.byType(Scaffold).last);
  showDialog<void>(context: context, builder: (_) => dialog);
  await tester.pumpAndSettle();
}

Future<void> _close(WidgetTester tester) async {
  Navigator.of(tester.element(find.byType(Dialog).last)).pop();
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => WidgetController.hitTestWarningShouldBeFatal = true);
  setUpAll(() async {
    // Opt-in review screenshots use real local fonts, never Ahem rectangles.
    // No font assets or user records are copied into the repository.
    if (_output.isNotEmpty && Platform.isWindows) {
      final icons = FontLoader('MaterialIcons')
        ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
      await icons.load();
      for (final family in ['Roboto', 'Segoe UI']) {
        final loader = FontLoader(family);
        loader.addFont(
          File(
            'C:/Windows/Fonts/segoeui.ttf',
          ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
        );
        await loader.load();
      }
    }
  });

  for (final size in const [
    Size(360, 800),
    Size(390, 844),
    Size(412, 915),
    Size(900, 600),
    Size(1280, 720),
    Size(1920, 1080),
  ]) {
    for (final scale in [1.0, 2.0]) {
      testWidgets('responsive audit $size at ${scale}x', (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        final data = _auditData();
        final catalog = _AuditCatalog();
        addTearDown(catalog.db.close);
        final stamp = DateTime(2026, 9, 7);
        final event = OneTimeEvent(
          id: 'audit-event',
          title: 'Research project review and planning',
          date: stamp,
          startPeriod: '5',
          endPeriod: '5',
          location: 'Library meeting room',
          specificTime: '13:25–13:50',
          createdAt: stamp,
          updatedAt: stamp,
        );
        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              taskFilterProvider.overrideWith(_AuditTaskFilter.new),
              taskCategoriesProvider.overrideWith(
                (_) => Stream.value([
                  for (final e in defaultTaskCategoryColors.entries)
                    TaskCategoryRecord(name: e.key, color: e.value),
                ]),
              ),
              tasksProvider.overrideWith(
                (ref) => Stream.value(const <TaskBundle>[]),
              ),
              taskNotificationSyncProvider.overrideWith((ref) async {}),
              nthuCatalogRepositoryProvider.overrideWithValue(catalog),
              academicSnapshotProvider.overrideWith(
                (ref) => Stream.value(data),
              ),
              scheduleClockProvider.overrideWith(
                (ref) => Stream.value(DateTime(2026, 9, 7, 8, 30)),
              ),
              oneTimeEventsProvider.overrideWith((ref) async => [event]),
            ],
            child: RepaintBoundary(key: _boundary, child: const DashboardApp()),
          ),
        );
        final prefix =
            '${size.width.toInt()}x${size.height.toInt()}-${scale.toInt()}x';
        await _capture(tester, '$prefix-dashboard');
        if (size.width >= 900) {
          await tester.tap(find.byTooltip('Show week'));
          await _capture(tester, '$prefix-dashboard-week');
          await tester.tap(find.byTooltip('Open full schedule'));
          await tester.pumpAndSettle();
        }
        final container = ProviderScope.containerOf(
          tester.element(find.byType(DashboardApp)),
        );
        container.read(scheduleViewModeProvider.notifier).setWeek(true);
        await _capture(tester, '$prefix-week');
        container.read(scheduleViewModeProvider.notifier).setWeek(false);
        await _capture(tester, '$prefix-today');
        await tester.tap(find.byType(AddScheduleButton).last);
        await _capture(tester, '$prefix-add-menu');
        await tester.tap(find.text('Add event'));
        await _capture(tester, '$prefix-add-event');
        if (size.width < 600) {
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          await _capture(tester, '$prefix-event-keyboard');
          tester.view.resetViewInsets();
          await tester.pumpAndSettle();
        }
        await _close(tester);
        for (final label in ['Graduation', 'History', 'Planning']) {
          final text = find.text(label).first;
          final chip = find.ancestor(
            of: text,
            matching: find.byType(ChoiceChip),
          );
          final tab = chip.evaluate().isNotEmpty
              ? chip
              : find.ancestor(of: text, matching: find.byType(ListTile));
          await tester.ensureVisible(tab);
          await tester.pumpAndSettle();
          await tester.tap(tab);
          await _capture(tester, '$prefix-${label.toLowerCase()}');
          expect(
            find.text(switch (label) {
              'Graduation' => 'Academic progress',
              'History' => 'Semester history',
              _ => 'Future semester planning',
            }),
            findsOneWidget,
          );
        }
        await _open(tester, OneTimeEventEditor(event: event));
        await _capture(tester, '$prefix-event');
        await _close(tester);
        await _open(
          tester,
          CourseEditor(data: data, course: data.courses.first),
        );
        await _capture(tester, '$prefix-course');
        await tester.ensureVisible(find.text('Add NTHU meeting'));
        await _capture(tester, '$prefix-course-meetings');
        await _close(tester);
        // Unlinked semester tests the picker error/empty/manual path offline.
        await _open(
          tester,
          NthuCoursePickerDialog(
            data: data,
            semester: data.semesters.first.copyWith(
              name: 'Unlinked semester',
              academicYear: '',
              term: '',
            ),
          ),
        );
        await _capture(tester, '$prefix-picker');
        await _close(tester);
        await _open(
          tester,
          NthuCoursePickerDialog(data: data, semester: data.semesters.first),
        );
        await _capture(tester, '$prefix-catalog');
        await tester.scrollUntilVisible(
          find.text('Physical Education and Wellness'),
          180,
          scrollable: find
              .descendant(
                of: find.byType(NthuCoursePickerDialog),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Physical Education and Wellness'));
        await _capture(tester, '$prefix-catalog-selected');
        final category = find.byWidgetPredicate(
          (w) =>
              w is DropdownButtonFormField<String> &&
              w.decoration.labelText == 'Graduation category *',
        );
        await tester.ensureVisible(category);
        await tester.pumpAndSettle();
        await tester.tap(category);
        await tester.pumpAndSettle();
        await tester.tap(find.text(data.categories.first.name).last);
        await _capture(tester, '$prefix-catalog-category');
        final add = find.widgetWithText(FilledButton, 'Add course');
        await tester.ensureVisible(add);
        await tester.pumpAndSettle();
        expect(tester.widget<FilledButton>(add).onPressed, isNotNull);
        await _close(tester);
        await _open(tester, GraduationRequirementsEditor(data: data));
        await _capture(tester, '$prefix-requirements');
        await _close(tester);
        await _open(tester, CourseDetails(courseId: data.courses.first.id));
        await _capture(tester, '$prefix-details');
        Navigator.of(tester.element(find.byType(AlertDialog).last)).pop();
        await tester.pumpAndSettle();
        await _open(
          tester,
          ExceptionEditor(data: data, courseId: data.courses.first.id),
        );
        await _capture(tester, '$prefix-exception');
        await _close(tester);
        await _open(tester, SemesterEditor(semester: data.semesters.first));
        await _capture(tester, '$prefix-semester');
        await _close(tester);
        final context = tester.element(find.byType(Scaffold).last);
        openAcademicRecords(context);
        await _capture(tester, '$prefix-records');
        for (final label in ['Semesters', 'Categories']) {
          await tester.tap(find.text(label));
          await _capture(tester, '$prefix-records-${label.toLowerCase()}');
        }
        Navigator.of(tester.element(find.byType(Scaffold).last)).push(
          MaterialPageRoute<void>(
            builder: (_) =>
                Scaffold(body: PlanningView(data: planningAcademicData())),
          ),
        );
        await _capture(tester, '$prefix-populated-planning');
        await tester.scrollUntilVisible(
          find.text('Weekly schedule conflicts'),
          250,
          scrollable: find.byType(Scrollable).last,
        );
        await _capture(tester, '$prefix-planning-conflicts');
      });
    }
  }
}

/// Immediate offline catalog responses keep visual tests independent of HTTP,
/// local databases, changing official catalog contents, and the user's records.
class _AuditCatalog extends NthuCatalogRepository {
  _AuditCatalog() : super(AcademicDatabase(NativeDatabase.memory()));
  @override
  Future<NthuCatalogTerm?> cachedTerm(String termCode) async => NthuCatalogTerm(
    id: termCode,
    termCode: termCode,
    displayName: '115 Fall',
    createdAt: DateTime(2026, 9, 1),
    updatedAt: DateTime(2026, 9, 1),
    fetchedAt: DateTime(2026, 9, 1),
    sourceType: 'currentJson',
    sourceUrl: 'test fixture',
  );
  @override
  Future<List<NthuCatalogCourseModel>> search(
    String termCode, {
    String query = '',
    NthuCatalogSearchField field = NthuCatalogSearchField.all,
    String? department,
    String? language,
    String? dayCode,
  }) async => [
    for (var i = 0; i < 5; i++)
      NthuCatalogCourseModel(
        id: 'catalog-$i',
        termCode: termCode,
        officialCourseCode: '11510PE11101$i',
        chineseName: '',
        englishName: i == 0
            ? 'Physical Education and Wellness'
            : 'Introduction to Computer Science $i',
        credits: i == 0 ? 0 : 3,
        teachingLanguage: 'English',
        instructorNames: const ['Professor Lin'],
        department: 'Department of Computer Science',
        rawLocationText: 'Engineering Building 102',
        meetings: const [
          NthuCatalogMeetingModel(
            dayCode: 'M',
            startPeriod: '3',
            endPeriod: '4',
            scheduleCode: 'M3M4',
          ),
        ],
      ),
  ].where((course) => course.matches(query)).toList();
}

class _AuditTaskFilter extends TaskFilterNotifier {
  @override
  Future<TaskFilter> build() async => const TaskFilter();
  @override
  Future<void> apply(TaskFilter filter) async {
    state = AsyncData(filter);
  }
}
