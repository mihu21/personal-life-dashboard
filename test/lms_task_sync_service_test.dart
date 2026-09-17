import 'dart:io';

import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/local_backup_service.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/one_time_event_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/lms/data/lms_task_sync_service.dart';
import 'package:personal_life_dashboard/features/lms/domain/lms_types.dart';
import 'package:personal_life_dashboard/features/tasks/data/task_repository.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';

void main() {
  late AcademicDatabase db;
  late TaskRepository tasks;
  late LmsTaskSyncService sync;
  final now = DateTime(2026, 9, 16, 18, 30);

  setUp(() {
    db = AcademicDatabase(NativeDatabase.memory());
    tasks = TaskRepository(db, clock: () => now);
    sync = LmsTaskSyncService(db, clock: () => now);
  });

  tearDown(() => db.close());

  LmsPreviewSnapshot preview({
    String title = 'HW1',
    DateTime? due,
    String externalId = '67426',
    String accountScope = 'user:38735',
    LmsProvider provider = LmsProvider.eeclass,
    String description = 'Remote assignment instructions',
    String courseName = '計算機結構Computer Architecture',
    String? remoteCourseId = '33864',
  }) => LmsPreviewSnapshot(
    accountScope: accountScope,
    syncedAt: now,
    items: [
      LmsItem(
        provider: provider,
        resourceType: LmsResourceType.homework,
        externalId: externalId,
        title: title,
        courseName: courseName,
        courseId: remoteCourseId,
        dueAt: due ?? DateTime(2026, 9, 22),
        duePrecision: LmsDuePrecision.dateTime,
        url: provider == LmsProvider.eeclass
            ? 'https://eeclass.nthu.edu.tw/course/homework/$externalId'
            : 'https://elearn.nthu.edu.tw/mod/assign/view.php?id=$externalId',
        description: description,
      ),
    ],
  );

  test(
    'creates one Homework task and never duplicates the same eeclass item',
    () async {
      final first = await sync.syncPreview(preview());
      expect(first.created, 1);
      var loaded = await tasks.load();
      expect(loaded, hasLength(1));
      expect(loaded.single.task.title, 'HW1');
      expect(loaded.single.task.category, 'Homework');
      expect(loaded.single.task.notes, 'Remote assignment instructions');
      expect(loaded.single.task.priority, TaskPriority.medium);
      expect(loaded.single.task.status, TaskStatus.active);
      expect(loaded.single.task.deadline, DateTime(2026, 9, 22));
      expect(loaded.single.task.hasDeadlineTime, true);
      expect(loaded.single.source, TaskSource.eeclass);

      final second = await sync.syncPreview(preview());
      expect(second.created, 0);
      expect(second.unchanged, 1);
      loaded = await tasks.load();
      expect(loaded, hasLength(1));
      expect(
        (await db
                .customSelect(
                  'SELECT COUNT(*) AS count FROM task_external_links',
                )
                .getSingle())
            .read<int>('count'),
        1,
      );
    },
  );

  test('schema 5 to 8 creates imported-task identity storage', () async {
    final dir = await Directory.systemTemp.createTemp('lms-v5-migration-');
    final file = File('${dir.path}/records.sqlite');
    final first = AcademicDatabase(NativeDatabase(file));
    await first.customStatement('DROP TABLE task_external_links');
    await first.customStatement('PRAGMA user_version = 5');
    await first.close();

    final upgraded = AcademicDatabase(NativeDatabase(file));
    final table = await upgraded
        .customSelect(
          "SELECT name FROM sqlite_master WHERE type = 'table' AND name = 'task_external_links'",
        )
        .getSingleOrNull();
    expect(table?.read<String>('name'), 'task_external_links');
    final columns = await upgraded.customSelect('PRAGMA table_info(task_external_links)').get();
    expect(columns.any((row) => row.read<String>('name') == 'ignored'), true);
    expect(
      columns.any(
        (row) => row.read<String>('name') == 'last_remote_description',
      ),
      true,
    );
    await upgraded.close();
    await dir.delete(recursive: true);
  });

  test(
    'the same remote homework id is isolated between eeclass accounts',
    () async {
      await sync.syncPreview(preview(accountScope: 'user:111'));
      await sync.syncPreview(preview(accountScope: 'user:222'));
      expect(await tasks.load(), hasLength(2));
    },
  );

  test('the same numeric remote id is isolated between LMS providers', () async {
    await sync.syncPreview(preview(provider: LmsProvider.eeclass));
    await sync.syncPreview(preview(provider: LmsProvider.elearn));
    final loaded = await tasks.load();
    expect(loaded, hasLength(2));
    expect(loaded.map((bundle) => bundle.source).toSet(), {
      TaskSource.eeclass,
      TaskSource.elearn,
    });
  });

  test(
    'eLearn mixed-language course names link to the matching local course',
    () async {
      await db.into(db.semesters).insert(
        SemestersCompanion.insert(
          id: 'semester-current',
          name: 'Fall 2026',
          academicYear: '115',
          term: '1',
          startDate: DateTime(2026, 9, 1),
          endDate: DateTime(2027, 1, 31),
          status: SemesterStatus.current,
          nthuTermCode: const Value('11510'),
        ),
      );
      await db.into(db.graduationCategories).insert(
        GraduationCategoriesCompanion.insert(
          id: 'professional',
          name: 'Professional Course',
        ),
      );
      await db.into(db.courses).insert(
        CoursesCompanion.insert(
          id: 'discrete-math',
          courseName: 'Discrete Mathematics',
          credits: 3,
          semesterId: 'semester-current',
          graduationCategoryId: 'professional',
          status: CourseStatus.inProgress,
          courseCode: const Value('11510CS233601'),
          englishName: const Value('Discrete Mathematics'),
        ),
      );

      await sync.syncPreview(
        preview(
          provider: LmsProvider.elearn,
          courseName: '離散數學Discrete Mathematics_11510CS 233601',
          remoteCourseId: '99123',
          due: DateTime(2026, 9, 20, 23, 59),
        ),
      );

      final task = (await tasks.load()).single.task;
      expect(task.courseId, 'discrete-math');
      final link = await db.customSelect(
        'SELECT remote_course_name FROM task_external_links WHERE task_id = ?',
        variables: [Variable<String>(task.id)],
      ).getSingle();
      expect(
        link.read<String>('remote_course_name'),
        '離散數學Discrete Mathematics_11510CS 233601',
      );
    },
  );

  test('a later sync backfills a missing imported-task course link', () async {
    await sync.syncPreview(
      preview(
        provider: LmsProvider.elearn,
        courseName: '離散數學Discrete Mathematics_11510CS 233601',
        remoteCourseId: '99123',
        due: DateTime(2026, 9, 20, 23, 59),
      ),
    );
    var task = (await tasks.load()).single.task;
    expect(task.courseId, isNull);

    await db.into(db.semesters).insert(
      SemestersCompanion.insert(
        id: 'semester-current',
        name: 'Fall 2026',
        academicYear: '115',
        term: '1',
        startDate: DateTime(2026, 9, 1),
        endDate: DateTime(2027, 1, 31),
        status: SemesterStatus.current,
      ),
    );
    await db.into(db.graduationCategories).insert(
      GraduationCategoriesCompanion.insert(
        id: 'professional',
        name: 'Professional Course',
      ),
    );
    await db.into(db.courses).insert(
      CoursesCompanion.insert(
        id: 'discrete-math',
        courseName: 'Discrete Mathematics',
        credits: 3,
        semesterId: 'semester-current',
        graduationCategoryId: 'professional',
        status: CourseStatus.inProgress,
        englishName: const Value('Discrete Mathematics'),
      ),
    );

    final result = await sync.syncPreview(
      preview(
        provider: LmsProvider.elearn,
        courseName: '離散數學Discrete Mathematics_11510CS 233601',
        remoteCourseId: '99123',
        due: DateTime(2026, 9, 20, 23, 59),
      ),
    );
    expect(result.updated, 1);
    task = (await tasks.load()).single.task;
    expect(task.courseId, 'discrete-math');
  });

  test(
    'items disappearing from Recent Events are not deleted or completed',
    () async {
      await sync.syncPreview(preview());
      final empty = LmsPreviewSnapshot(
        accountScope: 'user:38735',
        syncedAt: now.add(const Duration(hours: 1)),
        items: const [],
      );
      final result = await sync.syncPreview(empty);
      expect(result.processed, 0);
      final task = (await tasks.load()).single.task;
      expect(task.status, TaskStatus.active);
      expect(task.deletedAt, isNull);
    },
  );

  test('a removed Homework category is not silently recreated', () async {
    await (db.delete(
      db.taskCategoryRecords,
    )..where((category) => category.name.equals('Homework'))).go();
    await sync.syncPreview(preview());
    expect((await tasks.load()).single.task.category, 'Other');
    expect(
      (await tasks.watchCategories().first).any(
        (category) => category.name == 'Homework',
      ),
      false,
    );
  });

  test(
    'remote changes update untouched fields but preserve user edits, status and reminders',
    () async {
      await sync.syncPreview(preview());
      var bundle = (await tasks.load()).single;

      final remoteChanged = await sync.syncPreview(
        preview(
          title: 'HW1 revised',
          due: DateTime(2026, 9, 23, 18),
          description: 'Revised remote instructions',
        ),
      );
      expect(remoteChanged.updated, 1);
      bundle = (await tasks.load()).single;
      expect(bundle.task.title, 'HW1 revised');
      expect(bundle.task.deadline, DateTime(2026, 9, 23, 18));
      expect(bundle.task.notes, 'Revised remote instructions');

      await tasks.save(
        TaskBundle(
          bundle.task.copyWith(
            title: 'My custom HW title',
            notes: 'My own notes',
            deadline: Value(DateTime(2026, 9, 24, 20)),
            status: TaskStatus.completed,
          ),
          [TaskReminder(id: 0, taskId: bundle.task.id, minutesBefore: 60)],
        ),
      );

      final overridden = await sync.syncPreview(
        preview(
          title: 'HW1 final',
          due: DateTime(2026, 9, 25, 10),
          description: 'Final remote instructions',
        ),
      );
      expect(overridden.preservedOverrides, 3);
      bundle = (await tasks.load()).single;
      expect(bundle.task.title, 'My custom HW title');
      expect(bundle.task.deadline, DateTime(2026, 9, 24, 20));
      expect(bundle.task.notes, 'My own notes');
      expect(bundle.task.status, TaskStatus.completed);
      expect(bundle.reminders.single.minutesBefore, 60);
    },
  );

  test('deleted imported tasks stay deleted until restored', () async {
    await sync.syncPreview(preview());
    final id = (await tasks.load()).single.task.id;
    await sync.deleteImportedTask(id);
    expect(await tasks.load(), isEmpty);

    final result = await sync.syncPreview(
      preview(title: 'HW1 changed', due: DateTime(2026, 9, 30, 8)),
    );
    expect(result.suppressed, 1);
    expect(await tasks.load(), isEmpty);
    final deleted = await sync.loadIgnoredTasks();
    expect(deleted, hasLength(1));
    expect(deleted.single.taskId, id);
    expect(deleted.single.title, 'HW1 changed');

    await sync.restoreIgnoredTask(id);
    expect(await sync.loadIgnoredTasks(), isEmpty);
    final restored = (await tasks.load()).single.task;
    expect(restored.id, id);
    expect(restored.deletedAt, isNull);
  });

  test(
    'backup round trip preserves external identity and prevents duplicate re-import',
    () async {
      final dir = await Directory.systemTemp.createTemp('lms-task-backup-');
      final events = OneTimeEventRepository(
        fileFactory: () async => File('${dir.path}/events.json'),
      );
      final backup = LocalBackupService(db, events);

      await sync.syncPreview(preview());
      final originalTaskId = (await tasks.load()).single.task.id;
      await sync.deleteImportedTask(originalTaskId);
      final archive = await backup.createBackup();

      await sync.restoreIgnoredTask(originalTaskId);
      await backup.restoreBackup(archive.bytes);
      expect(await tasks.load(), isEmpty);
      expect(await sync.loadIgnoredTasks(), hasLength(1));

      final result = await sync.syncPreview(preview());
      expect(result.created, 0);
      expect(result.suppressed, 1);
      expect(await tasks.load(), isEmpty);

      await dir.delete(recursive: true);
    },
  );
}
