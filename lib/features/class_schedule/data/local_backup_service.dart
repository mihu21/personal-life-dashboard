import 'dart:convert';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../domain/one_time_event.dart';
import '../../tasks/domain/task_types.dart';
import 'academic_database.dart';
import '../../spending/domain/spending_models.dart';
import '../../spending/domain/spending_engine.dart';
import 'one_time_event_repository.dart';

class LocalBackupSummary {
  const LocalBackupSummary({
    required this.semesters,
    required this.categories,
    required this.courses,
    required this.meetings,
    required this.exceptions,
    required this.tags,
    required this.oneTimeEvents,
    this.tasks = 0,
  });

  final int semesters;
  final int categories;
  final int courses;
  final int meetings;
  final int exceptions;
  final int tags;
  final int oneTimeEvents;
  final int tasks;

  int get academicRecords =>
      semesters + categories + courses + meetings + exceptions + tags;
}

class LocalBackupArchive {
  const LocalBackupArchive({required this.bytes, required this.summary});

  final Uint8List bytes;
  final LocalBackupSummary summary;
}

/// Creates and restores a portable local backup of user-owned academic data.
///
/// NTHU catalog/cache tables are intentionally excluded. Courses are restored
/// with their catalog link cleared so a backup can move safely between devices
/// even when their locally downloaded catalog caches differ.
class LocalBackupService {
  LocalBackupService(this.db, this.oneTimeEvents);

  final AcademicDatabase db;
  final OneTimeEventRepository oneTimeEvents;

  static const int formatVersion = 7;
  static const String formatName = 'personal-life-dashboard-backup';

  Future<LocalBackupArchive> createBackup() async {
    final academic = await db.transaction<Map<String, Object?>>(() async {
      final semesters = await db.select(db.semesters).get();
      final categories = await db.select(db.graduationCategories).get();
      final courses = await db.select(db.courses).get();
      final meetings = await db.select(db.classMeetings).get();
      final exceptions = await db.select(db.scheduleExceptions).get();
      final tags = await db.select(db.tags).get();
      final courseTags = await db.select(db.courseTags).get();
      final settings = await db.select(db.academicSettings).get();

      final tasks = await db.select(db.taskRecords).get();
      final reminders = await db.select(db.taskReminders).get();
      final taskPreferences = await db.select(db.taskPreferences).get();
      final taskCategories = await db.select(db.taskCategoryRecords).get();
      final taskExternalLinks = await db.customSelect('''
        SELECT task_id AS taskId,
               provider,
               account_scope AS accountScope,
               resource_type AS resourceType,
               external_id AS externalId,
               external_url AS externalUrl,
               remote_course_id AS remoteCourseId,
               remote_course_name AS remoteCourseName,
               last_remote_title AS lastRemoteTitle,
               last_remote_description AS lastRemoteDescription,
               last_remote_deadline AS lastRemoteDeadline,
               last_remote_has_deadline_time AS lastRemoteHasDeadlineTime,
               last_seen_at AS lastSeenAt,
               ignored
        FROM task_external_links
      ''').get();
      final spending = await db
          .customSelect('SELECT payload FROM spending_state WHERE id = 1')
          .getSingleOrNull();
      return {
        'spending':
            spending?.read<String>('payload') ?? SpendingState().encode(),
        'taskCategories': [for (final row in taskCategories) row.toJson()],
        'tasks': [for (final row in tasks) row.toJson()],
        'taskReminders': [for (final row in reminders) row.toJson()],
        'taskPreferences': [for (final row in taskPreferences) row.toJson()],
        'taskExternalLinks': [for (final row in taskExternalLinks) row.data],
        'semesters': [for (final row in semesters) row.toJson()],
        'graduationCategories': [for (final row in categories) row.toJson()],
        'courses': [
          for (final row in courses)
            {
              ...row.toJson(),
              // This points into the device-local NTHU catalog cache.
              'catalogCourseId': null,
            },
        ],
        'classMeetings': [for (final row in meetings) row.toJson()],
        'scheduleExceptions': [for (final row in exceptions) row.toJson()],
        'tags': [for (final row in tags) row.toJson()],
        'courseTags': [for (final row in courseTags) row.toJson()],
        'academicSettings': [for (final row in settings) row.toJson()],
      };
    });

    final events = await oneTimeEvents.load();
    final summary = LocalBackupSummary(
      semesters: _listLength(academic['semesters']),
      categories: _listLength(academic['graduationCategories']),
      courses: _listLength(academic['courses']),
      meetings: _listLength(academic['classMeetings']),
      exceptions: _listLength(academic['scheduleExceptions']),
      tags: _listLength(academic['tags']),
      oneTimeEvents: events.length,
      tasks: _listLength(academic['tasks']),
    );

    final createdAt = DateTime.now().toUtc();
    final manifest = <String, Object?>{
      'format': formatName,
      'formatVersion': formatVersion,
      'databaseSchemaVersion': db.schemaVersion,
      'createdAt': createdAt.toIso8601String(),
      'contains': {
        'academicRecords': true,
        'oneTimeEvents': true,
        'tasks': true,
        'spending': true,
        'taskExternalLinks': true,
        'nthuCatalogCache': false,
      },
      'counts': {
        'semesters': summary.semesters,
        'graduationCategories': summary.categories,
        'courses': summary.courses,
        'classMeetings': summary.meetings,
        'scheduleExceptions': summary.exceptions,
        'tags': summary.tags,
        'oneTimeEvents': summary.oneTimeEvents,
        'tasks': summary.tasks,
        'taskExternalLinks': _listLength(academic['taskExternalLinks']),
      },
    };

    final archive = Archive()
      ..add(_jsonFile('manifest.json', manifest))
      ..add(_jsonFile('academic.json', academic))
      ..add(
        _jsonFile('one_time_events.json', [
          for (final event in events) event.toJson(),
        ]),
      );

    return LocalBackupArchive(
      bytes: ZipEncoder().encodeBytes(archive),
      summary: summary,
    );
  }

  Future<LocalBackupSummary> restoreBackup(Uint8List bytes) async {
    late final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const FormatException('This is not a valid dashboard backup ZIP.');
    }

    final manifest = _readJsonMap(archive, 'manifest.json');
    if (manifest['format'] != formatName) {
      throw const FormatException(
        'This file is not a Personal Life Dashboard backup.',
      );
    }
    final version = manifest['formatVersion'];
    if (version is! num ||
        !const [1, 2, 3, 4, 5, 6, formatVersion].contains(version.toInt())) {
      throw FormatException(
        'Unsupported backup version: ${version ?? 'unknown'}.',
      );
    }

    final academic = _readJsonMap(archive, 'academic.json');
    final eventJson = _readJsonList(archive, 'one_time_events.json');
    final spendingPayload = version.toInt() >= 7
        ? academic['spending'] as String
        : null;
    if (spendingPayload != null) {
      SpendingEngine(
        SpendingState.decode(spendingPayload),
        () => '',
      ).validate();
    }

    // Fully parse before replacing anything, so malformed backups do not erase
    // the current device's data.
    final semesters = _records(
      academic,
      'semesters',
    ).map(Semester.fromJson).toList(growable: false);
    final categories = _records(
      academic,
      'graduationCategories',
    ).map(GraduationCategory.fromJson).toList(growable: false);
    final courses = _records(academic, 'courses')
        .map((json) => Course.fromJson({...json, 'catalogCourseId': null}))
        .toList(growable: false);
    final meetings = _records(
      academic,
      'classMeetings',
    ).map(ClassMeeting.fromJson).toList(growable: false);
    final exceptions = _records(
      academic,
      'scheduleExceptions',
    ).map(ScheduleException.fromJson).toList(growable: false);
    final tags = _records(
      academic,
      'tags',
    ).map(Tag.fromJson).toList(growable: false);
    final courseTags = _records(
      academic,
      'courseTags',
    ).map(CourseTag.fromJson).toList(growable: false);
    final settings = _records(
      academic,
      'academicSettings',
    ).map(AcademicSetting.fromJson).toList(growable: false);
    if (settings.length > 1) {
      throw const FormatException('Backup contains invalid academic settings.');
    }

    final events = eventJson
        .map(
          (item) =>
              OneTimeEvent.fromJson(Map<String, Object?>.from(item as Map)),
        )
        .toList(growable: false);

    // Version 1 backups have no task data: leave current tasks intact.
    final hasTasks = version.toInt() >= 2;
    final tasks = hasTasks
        ? _records(academic, 'tasks')
              .map(
                (json) => TaskRecord.fromJson({
                  ...json,
                  'status': parseTaskStatus(json['status'] as String).name,
                  'priority': parseTaskPriority(json['priority'] as String)
                      .name,
                }),
              )
              .toList()
        : <TaskRecord>[];
    final reminders = hasTasks
        ? _records(
            academic,
            'taskReminders',
          ).map(TaskReminder.fromJson).toList()
        : <TaskReminder>[];
    final taskPreferences = hasTasks
        ? _records(
            academic,
            'taskPreferences',
          ).map(TaskPreference.fromJson).toList()
        : <TaskPreference>[];
    final taskCategories = version.toInt() >= 3
        ? _records(
            academic,
            'taskCategories',
          ).map(TaskCategoryRecord.fromJson).toList()
        : <TaskCategoryRecord>[];
    final taskExternalLinks = version.toInt() >= 4
        ? _records(academic, 'taskExternalLinks')
        : <Map<String, dynamic>>[];
    if (version.toInt() >= 3 &&
        (taskCategories.isEmpty ||
            taskCategories.any(
              (c) =>
                  c.name.trim().isEmpty ||
                  c.name.length > 50 ||
                  c.color < 0xFF000000 ||
                  c.color > 0xFFFFFFFF,
            ) ||
            taskCategories.map((c) => c.name.toLowerCase()).toSet().length !=
                taskCategories.length)) {
      throw const FormatException('Backup contains invalid task categories.');
    }
    for (final task in tasks) {
      if (task.title.trim().isEmpty ||
          task.category.trim().isEmpty ||
          task.repeatInterval < 1 ||
          task.repeatInterval > 999) {
        throw const FormatException('Backup contains an invalid task.');
      }
    }
    for (final reminder in reminders) {
      final task = tasks.where((t) => t.id == reminder.taskId).firstOrNull;
      if (task == null ||
          reminder.id <= 0 ||
          (reminder.customAt == null) == (reminder.minutesBefore == null) ||
          reminder.minutesBefore != null &&
              (task.deadline == null || reminder.minutesBefore! < 0)) {
        throw const FormatException(
          'Backup contains an invalid task reminder.',
        );
      }
    }
    final taskIds = tasks.map((task) => task.id).toSet();
    final externalIdentities = <String>{};
    final linkedTaskIds = <String>{};
    for (final link in taskExternalLinks) {
      final taskId = link['taskId'];
      final provider = link['provider'];
      final accountScope = link['accountScope'];
      final resourceType = link['resourceType'];
      final externalId = link['externalId'];
      final externalUrl = link['externalUrl'];
      final remoteCourseId = link['remoteCourseId'];
      final remoteCourseName = link['remoteCourseName'];
      final lastRemoteTitle = link['lastRemoteTitle'];
      final lastRemoteDescription = version.toInt() >= 6
          ? link['lastRemoteDescription']
          : '';
      final lastRemoteDeadline = link['lastRemoteDeadline'];
      final lastSeenAt = link['lastSeenAt'];
      final hasTime = link['lastRemoteHasDeadlineTime'];
      final ignored = version.toInt() >= 5 ? link['ignored'] : 0;
      final identity =
          '$provider\u0000$accountScope\u0000$resourceType\u0000$externalId';
      if (taskId is! String ||
          !taskIds.contains(taskId) ||
          provider is! String ||
          provider.trim().isEmpty ||
          accountScope is! String ||
          accountScope.trim().isEmpty ||
          resourceType is! String ||
          resourceType.trim().isEmpty ||
          externalId is! String ||
          externalId.trim().isEmpty ||
          externalUrl is! String ||
          externalUrl.trim().isEmpty ||
          (remoteCourseId != null && remoteCourseId is! String) ||
          remoteCourseName is! String ||
          remoteCourseName.trim().isEmpty ||
          lastRemoteTitle is! String ||
          lastRemoteTitle.trim().isEmpty ||
          lastRemoteDescription is! String ||
          lastRemoteDeadline is! String ||
          DateTime.tryParse(lastRemoteDeadline) == null ||
          lastSeenAt is! String ||
          DateTime.tryParse(lastSeenAt) == null ||
          hasTime is! int ||
          (hasTime != 0 && hasTime != 1) ||
          ignored is! int ||
          (ignored != 0 && ignored != 1) ||
          !externalIdentities.add(identity) ||
          !linkedTaskIds.add(taskId)) {
        throw const FormatException(
          'Backup contains invalid imported-task metadata.',
        );
      }
    }
    final previousEvents = await oneTimeEvents.load();
    await oneTimeEvents.replaceAll(events);
    try {
      await db.transaction(() async {
        if (spendingPayload != null) {
          await db.customStatement(
            'INSERT INTO spending_state(id, payload) VALUES (1, ?) ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
            [spendingPayload],
          );
        }
        if (version.toInt() >= 3) {
          await db.delete(db.taskCategoryRecords).go();
          for (final c in taskCategories) {
            await db.into(db.taskCategoryRecords).insert(c);
          }
        }
        if (hasTasks) {
          await db.customStatement('DELETE FROM task_external_links');
          await db.delete(db.taskReminders).go();
          await db.delete(db.taskRecords).go();
          await db.delete(db.taskPreferences).go();
          for (final row in tasks) {
            await db.into(db.taskRecords).insert(row);
            await db
                .into(db.taskCategoryRecords)
                .insert(
                  TaskCategoryRecordsCompanion.insert(
                    name: row.category,
                    color:
                        defaultTaskCategoryColors[row.category] ?? 0xFFA6A6B9,
                  ),
                  mode: InsertMode.insertOrIgnore,
                );
          }
          for (final row in reminders) {
            await db.into(db.taskReminders).insert(row);
          }
          for (final row in taskPreferences) {
            await db.into(db.taskPreferences).insert(row);
          }
          for (final link in taskExternalLinks) {
            await db.customStatement(
              '''
              INSERT INTO task_external_links(
                task_id, provider, account_scope, resource_type, external_id,
                external_url, remote_course_id, remote_course_name,
                last_remote_title, last_remote_description,
                last_remote_deadline, last_remote_has_deadline_time,
                last_seen_at, ignored
              ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              ''',
              [
                link['taskId'],
                link['provider'],
                link['accountScope'],
                link['resourceType'],
                link['externalId'],
                link['externalUrl'],
                link['remoteCourseId'],
                link['remoteCourseName'],
                link['lastRemoteTitle'],
                version.toInt() >= 6 ? link['lastRemoteDescription'] : '',
                link['lastRemoteDeadline'],
                link['lastRemoteHasDeadlineTime'],
                link['lastSeenAt'],
                version.toInt() >= 5 ? link['ignored'] : 0,
              ],
            );
          }
        }
        // Child tables first. NTHU catalog/cache tables are deliberately retained.
        await db.delete(db.scheduleExceptions).go();
        await db.delete(db.classMeetings).go();
        await db.delete(db.courseTags).go();
        await db.delete(db.courses).go();
        await db.delete(db.tags).go();
        await db.delete(db.semesters).go();
        await db.delete(db.graduationCategories).go();
        await db.delete(db.academicSettings).go();

        for (final row in semesters) {
          await db.into(db.semesters).insert(row, mode: InsertMode.insert);
        }
        for (final row in categories) {
          await db
              .into(db.graduationCategories)
              .insert(row, mode: InsertMode.insert);
        }
        for (final row in tags) {
          await db.into(db.tags).insert(row, mode: InsertMode.insert);
        }
        if (settings.isEmpty) {
          await db
              .into(db.academicSettings)
              .insert(AcademicSettingsCompanion.insert(id: 'academic'));
        } else {
          await db
              .into(db.academicSettings)
              .insert(settings.single, mode: InsertMode.insert);
        }
        for (final row in courses) {
          await db.into(db.courses).insert(row, mode: InsertMode.insert);
        }
        for (final row in meetings) {
          await db.into(db.classMeetings).insert(row, mode: InsertMode.insert);
        }
        for (final row in courseTags) {
          await db.into(db.courseTags).insert(row, mode: InsertMode.insert);
        }
        for (final row in exceptions) {
          await db
              .into(db.scheduleExceptions)
              .insert(row, mode: InsertMode.insert);
        }
      });
    } catch (_) {
      // The Drift transaction rolls itself back; also restore the separate
      // one-time-event file so a failed import leaves the device unchanged.
      await oneTimeEvents.replaceAll(previousEvents);
      rethrow;
    }

    return LocalBackupSummary(
      semesters: semesters.length,
      categories: categories.length,
      courses: courses.length,
      meetings: meetings.length,
      exceptions: exceptions.length,
      tags: tags.length,
      oneTimeEvents: events.length,
      tasks: _listLength(academic['tasks']),
    );
  }

  static ArchiveFile _jsonFile(String name, Object? value) {
    final text = const JsonEncoder.withIndent('  ').convert(value);
    final data = utf8.encode(text);
    return ArchiveFile(name, data.length, data);
  }

  static Map<String, dynamic> _readJsonMap(Archive archive, String name) {
    final decoded = _readJson(archive, name);
    if (decoded is! Map) {
      throw FormatException('$name has an invalid format.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  static List<dynamic> _readJsonList(Archive archive, String name) {
    final decoded = _readJson(archive, name);
    if (decoded is! List) {
      throw FormatException('$name has an invalid format.');
    }
    return decoded;
  }

  static dynamic _readJson(Archive archive, String name) {
    final file = archive.findFile(name);
    final data = file?.readBytes();
    if (data == null) {
      throw FormatException('Backup is missing $name.');
    }
    try {
      return jsonDecode(utf8.decode(data));
    } catch (_) {
      throw FormatException('Backup contains invalid $name.');
    }
  }

  static List<Map<String, dynamic>> _records(
    Map<String, dynamic> academic,
    String key,
  ) {
    final value = academic[key];
    if (value is! List) {
      throw FormatException('Backup is missing academic data: $key.');
    }
    try {
      return [for (final item in value) Map<String, dynamic>.from(item as Map)];
    } catch (_) {
      throw FormatException('Backup contains invalid academic data: $key.');
    }
  }

  static int _listLength(Object? value) => value is List ? value.length : 0;
}
