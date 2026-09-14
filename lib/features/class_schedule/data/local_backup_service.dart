import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:drift/drift.dart';

import '../domain/one_time_event.dart';
import 'academic_database.dart';
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
  });

  final int semesters;
  final int categories;
  final int courses;
  final int meetings;
  final int exceptions;
  final int tags;
  final int oneTimeEvents;

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

  static const int formatVersion = 1;
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

      return {
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
      },
    };

    final archive = Archive()
      ..add(_jsonFile('manifest.json', manifest))
      ..add(_jsonFile('academic.json', academic))
      ..add(
        _jsonFile(
          'one_time_events.json',
          [for (final event in events) event.toJson()],
        ),
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
      throw const FormatException('This file is not a Personal Life Dashboard backup.');
    }
    final version = manifest['formatVersion'];
    if (version is! num || version.toInt() != formatVersion) {
      throw FormatException(
        'Unsupported backup version: ${version ?? 'unknown'}.',
      );
    }

    final academic = _readJsonMap(archive, 'academic.json');
    final eventJson = _readJsonList(archive, 'one_time_events.json');

    // Fully parse before replacing anything, so malformed backups do not erase
    // the current device's data.
    final semesters = _records(academic, 'semesters')
        .map(Semester.fromJson)
        .toList(growable: false);
    final categories = _records(academic, 'graduationCategories')
        .map(GraduationCategory.fromJson)
        .toList(growable: false);
    final courses = _records(academic, 'courses')
        .map((json) => Course.fromJson({...json, 'catalogCourseId': null}))
        .toList(growable: false);
    final meetings = _records(academic, 'classMeetings')
        .map(ClassMeeting.fromJson)
        .toList(growable: false);
    final exceptions = _records(academic, 'scheduleExceptions')
        .map(ScheduleException.fromJson)
        .toList(growable: false);
    final tags = _records(academic, 'tags')
        .map(Tag.fromJson)
        .toList(growable: false);
    final courseTags = _records(academic, 'courseTags')
        .map(CourseTag.fromJson)
        .toList(growable: false);
    final settings = _records(academic, 'academicSettings')
        .map(AcademicSetting.fromJson)
        .toList(growable: false);
    if (settings.length > 1) {
      throw const FormatException('Backup contains invalid academic settings.');
    }

    final events = eventJson
        .map((item) => OneTimeEvent.fromJson(Map<String, Object?>.from(item as Map)))
        .toList(growable: false);

    final previousEvents = await oneTimeEvents.load();
    await oneTimeEvents.replaceAll(events);
    try {
      await db.transaction(() async {
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
