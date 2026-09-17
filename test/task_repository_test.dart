import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:personal_life_dashboard/features/tasks/providers/task_providers.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/academic_types.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/course_draft.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/one_time_event.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/local_backup_service.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/one_time_event_repository.dart';
import 'package:personal_life_dashboard/features/tasks/data/task_notification_service.dart';
import 'package:personal_life_dashboard/features/tasks/data/task_repository.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_logic.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';

import 'task_logic_test.dart' show taskFixture;

class FakeNotifications implements TaskNotificationGateway {
  final scheduled = <int, DateTime>{};
  int cancellations = 0;
  bool allowed = true, fail = false;
  @override
  Future<void> cancelAll() async {
    cancellations++;
    scheduled.clear();
  }

  @override
  Future<bool> permission({bool request = false}) async => allowed;
  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String taskId,
  }) async {
    if (fail) throw StateError('offline platform');
    scheduled[id] = at;
  }
}

void main() {
  late AcademicDatabase db;
  late TaskRepository repo;
  final now = DateTime(2026, 9, 15, 12);
  setUp(() {
    db = AcademicDatabase(NativeDatabase.memory());
    repo = TaskRepository(db, clock: () => now);
  });
  tearDown(() => db.close());

  test(
    'category rename, color and removal preserve tasks and selected filters',
    () async {
      await repo.save(
        TaskBundle(taskFixture('categorized', category: 'Homework')),
      );
      await repo.saveFilter(const TaskFilter(categories: {'Homework'}));
      await repo.saveCategory('Study', 0xFF123456, previousName: 'Homework');
      expect((await repo.load()).single.task.category, 'Study');
      expect((await repo.loadFilter()).categories, {'Study'});
      expect(
        (await repo.watchCategories().first)
            .firstWhere((c) => c.name == 'Study')
            .color,
        0xFF123456,
      );
      await expectLater(
        repo.saveCategory('study', 0xFF123456),
        throwsArgumentError,
      );
      await repo.removeCategory('Study', 'Personal');
      expect((await repo.load()).single.task.category, 'Personal');
      expect((await repo.loadFilter()).categories, {'Personal'});
      expect(
        (await repo.watchCategories().first).any((c) => c.name == 'Study'),
        false,
      );
    },
  );

  test(
    'schema 4 migration maps old states and priorities and keeps reminder IDs',
    () async {
      final dir = await Directory.systemTemp.createTemp('task-v4-');
      final file = File('${dir.path}/db.sqlite');
      final old = AcademicDatabase(NativeDatabase(file));
      final oldRepo = TaskRepository(old);
      await oldRepo.save(
        TaskBundle(taskFixture('legacy', category: 'Custom'), [
          TaskReminder(id: 0, taskId: 'legacy', customAt: now),
        ]),
      );
      final reminder = (await oldRepo.load()).single.reminders.single;
      await old.customStatement(
        "UPDATE task_records SET status = 'inProgress', priority = 'urgent'",
      );
      await old.customStatement('DROP TABLE task_category_records');
      await old.customStatement('PRAGMA user_version = 4');
      await old.close();
      final upgraded = AcademicDatabase(NativeDatabase(file));
      final upgradedRepo = TaskRepository(upgraded);
      final saved = (await upgradedRepo.load()).single;
      expect(saved.task.status, TaskStatus.active);
      expect(saved.task.priority, TaskPriority.high);
      expect(saved.reminders.single.toJson(), reminder.toJson());
      expect(
        (await upgradedRepo.watchCategories().first).any(
          (c) => c.name == 'Custom',
        ),
        true,
      );
      await upgraded.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'old filter status and priority values normalize without resetting other choices',
    () {
      final encoded = const TaskFilter(
        categories: {'Homework'},
        priorities: {TaskPriority.high},
        statuses: {TaskStatus.active},
        sources: {TaskSource.eeclass, TaskSource.elearn},
        courseIds: {'course-a'},
      ).encode();
      final filter = TaskFilter.decode(
        encoded.replaceAll('active', 'todo').replaceAll('high', 'urgent'),
      );
      expect(filter.statuses, {TaskStatus.active});
      expect(filter.priorities, {TaskPriority.high});
      expect(filter.categories, {'Homework'});
      expect(filter.sources, {TaskSource.eeclass, TaskSource.elearn});
      expect(filter.courseIds, {'course-a'});
    },
  );

  test(
    'CRUD, stable reminder IDs, completion timestamps, custom snooze',
    () async {
      final task = taskFixture('task');
      await repo.save(
        TaskBundle(task, [
          TaskReminder(
            id: 0,
            taskId: task.id,
            customAt: now.add(const Duration(hours: 1)),
          ),
        ]),
      );
      var bundle = (await repo.load()).single;
      final reminderId = bundle.reminders.single.id;
      expect(reminderId, greaterThan(0));
      await repo.save(
        TaskBundle(
          bundle.task.copyWith(title: 'Changed', status: TaskStatus.active),
          bundle.reminders,
        ),
      );
      expect((await repo.load()).single.reminders.single.id, reminderId);
      await repo.snooze(reminderId, now.add(const Duration(days: 1)));
      bundle = (await repo.load()).single;
      expect(
        reminderTime(bundle.task, bundle.reminders.single),
        now.add(const Duration(days: 1)),
      );
      await repo.setStatus(task.id, TaskStatus.completed);
      expect((await repo.load()).single.task.completedAt, now);
      await repo.setStatus(task.id, TaskStatus.active);
      expect((await repo.load()).single.task.completedAt, isNull);
      await repo.delete(task.id);
      expect(await repo.load(), isEmpty);
      expect((await db.select(db.taskRecords).get()).single.deletedAt, now);
    },
  );

  test(
    'database reopen persists tasks, reminders, filters and course links',
    () async {
      final dir = await Directory.systemTemp.createTemp('task-persistence-');
      final file = File('${dir.path}/records.sqlite');
      final first = AcademicDatabase(NativeDatabase(file));
      final repository = TaskRepository(first);
      final task = taskFixture(
        'persist',
      ).copyWith(courseId: const Value('existing-course'));
      await repository.save(
        TaskBundle(task, [TaskReminder(id: 0, taskId: task.id, customAt: now)]),
      );
      await repository.saveFilter(
        const TaskFilter(
          categories: {'Exam'},
          search: 'test',
          sources: {TaskSource.elearn},
          courseIds: {'existing-course'},
        ),
      );
      await first.close();
      final reopened = AcademicDatabase(NativeDatabase(file));
      final loaded = TaskRepository(reopened);
      expect((await loaded.load()).single.task.courseId, 'existing-course');
      expect((await loaded.load()).single.reminders.single.customAt, now);
      final savedFilter = await loaded.loadFilter();
      expect(savedFilter.search, 'test');
      expect(savedFilter.sources, {TaskSource.elearn});
      expect(savedFilter.courseIds, {'existing-course'});
      await reopened.close();
      await dir.delete(recursive: true);
    },
  );

  test(
    'notification lifecycle cancels obsolete, completed, deleted and legacy schedules',
    () async {
      final gateway = FakeNotifications()
        ..scheduled[9999] = now.add(const Duration(days: 1));
      final service = TaskNotificationService(gateway, clock: () => now);
      final due = now.add(const Duration(days: 2));
      final task = taskFixture('task', due: due);
      await repo.save(
        TaskBundle(task, [
          TaskReminder(id: 0, taskId: task.id, minutesBefore: 60),
          TaskReminder(id: 0, taskId: task.id, minutesBefore: 1440),
        ]),
      );
      await service.synchronize(repo.load);
      expect(gateway.scheduled, hasLength(2));
      expect(gateway.scheduled.containsKey(9999), false);
      var bundle = (await repo.load()).single;
      final keptId = bundle.reminders.first.id;
      await repo.save(
        TaskBundle(
          bundle.task.copyWith(
            deadline: Value(due.add(const Duration(days: 1))),
          ),
          [bundle.reminders.first],
        ),
      );
      await service.synchronize(repo.load);
      expect(gateway.scheduled.keys, [keptId]);
      expect(
        gateway.scheduled[keptId],
        due.add(const Duration(days: 1)).subtract(const Duration(hours: 1)),
      );
      await repo.setStatus(task.id, TaskStatus.completed);
      await service.synchronize(repo.load);
      expect(gateway.scheduled, isEmpty);
      await repo.setStatus(task.id, TaskStatus.active);
      await service.synchronize(repo.load);
      expect(gateway.scheduled, hasLength(1));
      await repo.delete(task.id);
      await service.synchronize(repo.load);
      expect(gateway.scheduled, isEmpty);
    },
  );

  test(
    'denied permission/platform error preserves data and retry is idempotent',
    () async {
      final gateway = FakeNotifications()..allowed = false;
      final service = TaskNotificationService(gateway, clock: () => now);
      await repo.save(
        TaskBundle(taskFixture('task'), [
          TaskReminder(
            id: 0,
            taskId: 'task',
            customAt: now.add(const Duration(hours: 1)),
          ),
        ]),
      );
      await expectLater(service.synchronize(repo.load), throwsStateError);
      expect(await repo.load(), hasLength(1));
      gateway.allowed = true;
      gateway.fail = true;
      await expectLater(service.synchronize(repo.load), throwsStateError);
      gateway.fail = false;
      await Future.wait([
        service.synchronize(repo.load),
        service.synchronize(repo.load),
      ]);
      expect(gateway.scheduled, hasLength(1));
    },
  );

  test(
    'app provider automatically reconciles on startup, edits and completion',
    () async {
      final gateway = FakeNotifications();
      final container = ProviderContainer(
        overrides: [
          taskRepositoryProvider.overrideWithValue(repo),
          taskNotificationServiceProvider.overrideWithValue(
            TaskNotificationService(gateway, clock: () => now),
          ),
        ],
      );
      final subscription = container.listen(
        taskNotificationSyncProvider,
        (_, _) {},
        fireImmediately: true,
      );
      try {
        await container.read(tasksProvider.future);
        await container.read(taskNotificationSyncProvider.future);
        expect(gateway.cancellations, 1);
        await repo.save(
          TaskBundle(taskFixture('reactive'), [
            TaskReminder(
              id: 0,
              taskId: 'reactive',
              customAt: now.add(const Duration(hours: 1)),
            ),
          ]),
        );
        for (var i = 0; i < 100 && gateway.scheduled.isEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(gateway.scheduled, hasLength(1));
        await repo.setStatus('reactive', TaskStatus.completed);
        for (var i = 0; i < 100 && gateway.scheduled.isNotEmpty; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        expect(gateway.scheduled, isEmpty);
      } finally {
        subscription.close();
        container.dispose();
      }
    },
  );

  test(
    'daily weekly monthly completion produces exactly one successor',
    () async {
      for (final unit in [
        RepeatUnit.daily,
        RepeatUnit.weekly,
        RepeatUnit.monthly,
      ]) {
        final task = taskFixture(
          unit.name,
          due: DateTime(2026, 8, 31, 18),
          repeat: unit,
        ).copyWith(repeatAnchorDay: const Value(31));
        await repo.save(
          TaskBundle(task, [
            TaskReminder(id: 0, taskId: task.id, minutesBefore: 60),
          ]),
        );
        await repo.setStatus(task.id, TaskStatus.completed);
        final successor = (await repo.load()).singleWhere(
          (b) => b.task.previousOccurrenceId == task.id,
        );
        expect(successor.task.deadline!.isAfter(now), true);
        expect(successor.task.status, TaskStatus.active);
        expect(successor.reminders.single.minutesBefore, 60);
        if (unit == RepeatUnit.monthly) {
          expect(successor.task.deadline, DateTime(2026, 9, 30, 18));
        }
        await repo.setStatus(task.id, TaskStatus.active);
        await repo.setStatus(task.id, TaskStatus.completed);
        expect(
          (await repo.load()).where(
            (b) => b.task.previousOccurrenceId == task.id,
          ),
          hasLength(1),
        );
      }
      expect(await repo.load(), hasLength(6));
    },
  );

  test(
    'no-deadline recurrence shifts custom reminder; no synthetic deadline',
    () async {
      await repo.save(
        TaskBundle(taskFixture('repeat', repeat: RepeatUnit.daily), [
          TaskReminder(
            id: 0,
            taskId: 'repeat',
            customAt: now.add(const Duration(hours: 1)),
          ),
        ]),
      );
      await repo.setStatus('repeat', TaskStatus.completed);
      final next = (await repo.load()).singleWhere(
        (b) => b.task.previousOccurrenceId == 'repeat',
      );
      expect(next.task.deadline, isNull);
      expect(
        next.reminders.single.customAt,
        now.add(const Duration(days: 1, hours: 1)),
      );
    },
  );

  test(
    'invalid relative reminder rejected before changing persisted task',
    () async {
      await repo.save(TaskBundle(taskFixture('task')));
      await expectLater(
        repo.save(
          TaskBundle(taskFixture('task').copyWith(title: 'Bad'), [
            const TaskReminder(id: 0, taskId: 'task', minutesBefore: 10),
          ]),
        ),
        throwsArgumentError,
      );
      expect((await repo.load()).single.task.title, 'task');
    },
  );

  test('editing can clear deadline, course link and all reminders', () async {
    await repo.save(
      TaskBundle(
        taskFixture('task', due: now).copyWith(courseId: const Value('course')),
        [const TaskReminder(id: 0, taskId: 'task', minutesBefore: 60)],
      ),
    );
    final task = (await repo.load()).single.task;
    await repo.save(
      TaskBundle(
        task.copyWith(deadline: const Value(null), courseId: const Value(null)),
      ),
    );
    final saved = (await repo.load()).single;
    expect(saved.task.deadline, isNull);
    expect(saved.task.hasDeadlineTime, false);
    expect(saved.task.courseId, isNull);
    expect(saved.reminders, isEmpty);
  });

  test(
    'schema 3 to 5 preserves academic records, graduation data and legacy event file',
    () async {
      final dir = await Directory.systemTemp.createTemp('task-migration-');
      final file = File('${dir.path}/records.sqlite');
      final old = AcademicDatabase(NativeDatabase(file));
      final academic = AcademicRepository(old);
      await academic.initialize();
      final semester = await academic.saveSemester(
        name: 'Fall',
        academicYear: '2026',
        term: 'Fall',
        start: DateTime(2026, 9),
        end: DateTime(2027, 1, 31),
        status: SemesterStatus.current,
      );
      final category = (await academic.snapshot()).categories.first.id;
      final course = await academic.saveCourse(
        CourseDraft(
          name: 'Preserved course',
          credits: 3,
          semesterId: semester,
          categoryId: category,
          meetings: [const MeetingDraft(day: 1, start: 480, end: 530)],
        ),
      );
      final original = (await old.select(old.courses).get()).single.toJson();
      // The v3 schema is the existing schema with only the three v4 tables absent.
      await old.customStatement('DROP TABLE task_reminders');
      await old.customStatement('DROP TABLE task_records');
      await old.customStatement('DROP TABLE task_preferences');
      await old.customStatement('DROP TABLE task_category_records');
      await old.customStatement('PRAGMA user_version = 3');
      await old.close();
      final eventFile = File('${dir.path}/events.json');
      final events = OneTimeEventRepository(fileFactory: () async => eventFile);
      await events.upsert(
        OneTimeEvent(
          id: 'event',
          title: 'Organization meeting',
          date: now,
          startPeriod: '1',
          endPeriod: '2',
          createdAt: now,
          updatedAt: now,
          reminderMinutesBefore: [30, 1440],
        ),
      );
      final originalEvents = await eventFile.readAsBytes();
      final upgraded = AcademicDatabase(NativeDatabase(file));
      final tasks = TaskRepository(upgraded);
      expect(await tasks.load(), isEmpty);
      expect(
        (await upgraded.select(upgraded.courses).get()).single.toJson(),
        original,
      );
      expect(
        (await upgraded.select(upgraded.classMeetings).get()).single.courseId,
        course,
      );
      expect(
        await upgraded.select(upgraded.graduationCategories).get(),
        isNotEmpty,
      );
      await tasks.save(TaskBundle(taskFixture('new task')));
      expect(await eventFile.readAsBytes(), originalEvents);
      expect((await events.load()).single.reminderMinutesBefore, [30, 1440]);
      await upgraded.close();
      await dir.delete(recursive: true);
    },
  );

  test('backup round trip includes tasks/reminders/preferences', () async {
    final dir = await Directory.systemTemp.createTemp('task-backup-');
    final events = OneTimeEventRepository(
      fileFactory: () async => File('${dir.path}/events.json'),
    );
    final backup = LocalBackupService(db, events);
    await repo.save(
      TaskBundle(taskFixture('task'), [
        TaskReminder(id: 0, taskId: 'task', customAt: now),
      ]),
    );
    await repo.saveFilter(
      const TaskFilter(
        sources: {TaskSource.manual, TaskSource.elearn},
        includeNoCourse: true,
      ),
    );
    await repo.saveCategory('Personal', 0xFF112233, previousName: 'Personal');
    final archive = await backup.createBackup();
    await repo.saveCategory('Personal', 0xFF445566, previousName: 'Personal');
    expect(
      ZipDecoder().decodeBytes(archive.bytes).findFile('academic.json'),
      isNotNull,
    );
    await repo.delete('task');
    await backup.restoreBackup(archive.bytes);
    expect((await repo.load()).single.reminders.single.customAt, now);
    final restoredFilter = await repo.loadFilter();
    expect(restoredFilter.sources, {TaskSource.manual, TaskSource.elearn});
    expect(restoredFilter.includeNoCourse, true);
    expect(
      (await repo.watchCategories().first)
          .firstWhere((c) => c.name == 'Personal')
          .color,
      0xFF112233,
    );
    await dir.delete(recursive: true);
  });

  test(
    'old backup keeps tasks; malformed task backup rolls back without losing data',
    () async {
      final dir = await Directory.systemTemp.createTemp('task-old-backup-');
      final events = OneTimeEventRepository(
        fileFactory: () async => File('${dir.path}/events.json'),
      );
      final backup = LocalBackupService(db, events);
      await repo.save(TaskBundle(taskFixture('keep me')));
      final original = await backup.createBackup();
      Uint8List rewrite({required bool legacy}) {
        final result = Archive();
        for (final file in ZipDecoder().decodeBytes(original.bytes)) {
          var data = file.readBytes()!;
          if (file.name == 'manifest.json') {
            final manifest =
                jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
            manifest['formatVersion'] = legacy ? 1 : 2;
            data = Uint8List.fromList(utf8.encode(jsonEncode(manifest)));
          }
          if (file.name == 'academic.json') {
            final academic =
                jsonDecode(utf8.decode(data)) as Map<String, dynamic>;
            if (legacy) {
              academic.remove('tasks');
              academic.remove('taskReminders');
              academic.remove('taskPreferences');
            } else {
              (academic['tasks'] as List).first['title'] = '';
            }
            data = Uint8List.fromList(utf8.encode(jsonEncode(academic)));
          }
          result.add(ArchiveFile(file.name, data.length, data));
        }
        return ZipEncoder().encodeBytes(result);
      }

      await backup.restoreBackup(rewrite(legacy: true));
      expect((await repo.load()).single.task.id, 'keep me');
      await expectLater(
        backup.restoreBackup(rewrite(legacy: false)),
        throwsFormatException,
      );
      expect((await repo.load()).single.task.id, 'keep me');
      await dir.delete(recursive: true);
    },
  );
}
