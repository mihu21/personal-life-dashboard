import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/local_backup_service.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/one_time_event_repository.dart';
import 'package:personal_life_dashboard/features/spending/data/spending_repository.dart';
import 'package:personal_life_dashboard/features/spending/domain/spending_models.dart';
import 'package:personal_life_dashboard/features/tasks/domain/task_types.dart';

import 'spending_engine_check.dart' as checks;

void main() {
  test('accounting and recurring invariants', checks.main);
  test('atomic commands, reminders and backup round trip', () async {
    final dir = await Directory.systemTemp.createTemp('spending_test');
    final db = AcademicDatabase(NativeDatabase.memory());
    final repo = SpendingRepository(db, clock: () => DateTime(2026, 9, 23));
    addTearDown(() async {
      repo.dispose();
      await db.close();
      await dir.delete(recursive: true);
    });
    await repo.change((e) {
      e.account(
        SpendRow({
          'id': 'cash',
          'name': 'Cash',
          'currency': 'TWD',
          'opening': 100000,
        }),
      );
      e.person(SpendRow({'id': 'alex', 'name': 'Alex'}));
      e.post(
        checks.entry('debt', 'debt', 10000, {
          'personId': 'alex',
          'direction': 'theyOwe',
          'due': '2026-09-25',
          'remind': true,
        }),
      );
    });
    var tasks = await db.select(db.taskRecords).get();
    expect(tasks.single.id, 'spending:debt:debt');
    expect(tasks.single.deadline, DateTime(2026, 9, 25, 9));
    expect((await db.select(db.taskReminders).get()).length, 1);
    await expectLater(
      repo.change((e) {
        e.post(checks.entry('invalid', 'expense', -1));
      }),
      throwsFormatException,
    );
    expect((await repo.load()).entries, isEmpty);
    await Future.wait([
      repo.change((e) => e.repay('debt', 'cash', 3000, DateTime(2026, 9, 23))),
      repo.change((e) => e.repay('debt', 'cash', 2000, DateTime(2026, 9, 23))),
    ]);
    var state = await repo.load();
    expect(state.remaining(state.debt('debt')), 5000);
    final events = OneTimeEventRepository(
      fileFactory: () async => File('${dir.path}/events.json'),
    );
    final backup = LocalBackupService(db, events);
    final bytes = (await backup.createBackup()).bytes;
    await repo.change(
      (e) => e.repay('debt', 'cash', 5000, DateTime(2026, 9, 23)),
    );
    tasks = await db.select(db.taskRecords).get();
    expect(tasks.single.status, TaskStatus.completed);
    await backup.restoreBackup(bytes);
    state = await repo.load();
    expect(state.remaining(state.debt('debt')), 5000);
    expect(state.balance('cash'), 105000);
    tasks = await db.select(db.taskRecords).get();
    expect(tasks.single.status, TaskStatus.active);
    // A malformed spending payload must not replace any existing data.
    final archive = ZipDecoder().decodeBytes(bytes);
    final academic =
        jsonDecode(utf8.decode(archive.findFile('academic.json')!.readBytes()!))
            as Map<String, dynamic>;
    academic['spending'] = '{"version":999}';
    final malformed = Archive();
    for (final f in archive.files) {
      if (f.name != 'academic.json') malformed.add(f);
    }
    malformed.add(
      ArchiveFile(
        'academic.json',
        utf8.encode(jsonEncode(academic)).length,
        utf8.encode(jsonEncode(academic)),
      ),
    );
    await expectLater(
      backup.restoreBackup(Uint8List.fromList(ZipEncoder().encode(malformed))),
      throwsFormatException,
    );
    expect((await repo.load()).balance('cash'), 105000);
    // Legacy backup does not erase spending.
    final legacy = Archive();
    for (final f in archive.files) {
      if (f.name == 'manifest.json') {
        final manifest =
            jsonDecode(utf8.decode(f.readBytes()!)) as Map<String, dynamic>;
        manifest['formatVersion'] = 6;
        final content = utf8.encode(jsonEncode(manifest));
        legacy.add(ArchiveFile(f.name, content.length, content));
      } else {
        legacy.add(f);
      }
    }
    await backup.restoreBackup(Uint8List.fromList(ZipEncoder().encode(legacy)));
    expect((await repo.load()).balance('cash'), 105000);
  });
  test('schema 10 upgrades without losing existing data', () async {
    final dir = await Directory.systemTemp.createTemp('spending_migration');
    final file = File('${dir.path}/test.db');
    var db = AcademicDatabase(NativeDatabase(file));
    await db.customStatement(
      "INSERT INTO academic_settings(id, setup_dismissed) VALUES ('migration', 1)",
    );
    await db.customStatement('DROP TABLE spending_state');
    await db.customStatement('PRAGMA user_version = 10');
    await db.close();
    db = AcademicDatabase(NativeDatabase(file));
    final repo = SpendingRepository(db);
    expect((await repo.load()).entries, isEmpty);
    expect((await db.select(db.academicSettings).get()).single.id, 'migration');
    repo.dispose();
    await db.close();
    await dir.delete(recursive: true);
  });
}
