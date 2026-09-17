import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../class_schedule/data/academic_database.dart';
import '../../class_schedule/domain/academic_types.dart';
import '../../tasks/domain/task_types.dart';
import '../domain/lms_types.dart';

class LmsTaskSyncService {
  LmsTaskSyncService(this.db, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;

  final AcademicDatabase db;
  final DateTime Function() clock;
  static const _uuid = Uuid();

  Future<LmsTaskSyncResult> syncPreview(LmsPreviewSnapshot preview) async {
    if (preview.accountScope == 'legacy' ||
        preview.accountScope.trim().isEmpty) {
      throw const LmsTaskSyncException(
        'Sign in to the LMS again before importing Tasks so the account can be identified safely.',
      );
    }

    return db.transaction(() async {
      await db.customStatement(createTaskExternalLinksTableSql);
      final taskCategories = await db.select(db.taskCategoryRecords).get();
      late final String importCategory;
      if (taskCategories.any((category) => category.name == 'Homework')) {
        importCategory = 'Homework';
      } else if (taskCategories.any((category) => category.name == 'Other')) {
        importCategory = 'Other';
      } else if (taskCategories.isNotEmpty) {
        importCategory = taskCategories.first.name;
      } else {
        importCategory = 'Homework';
        await db
            .into(db.taskCategoryRecords)
            .insert(
              TaskCategoryRecordsCompanion.insert(
                name: importCategory,
                color: defaultTaskCategoryColors['Homework']!,
              ),
              mode: InsertMode.insertOrIgnore,
            );
      }

      final courses = await (db.select(
        db.courses,
      )..where((c) => c.deletedAt.isNull())).get();
      final semesters = await (db.select(
        db.semesters,
      )..where((s) => s.deletedAt.isNull())).get();

      var created = 0;
      var updated = 0;
      var unchanged = 0;
      var restored = 0;
      var suppressed = 0;
      var preservedOverrides = 0;
      final now = clock();

      for (final item in preview.items) {
        if (item.resourceType != LmsResourceType.homework) {
          continue;
        }
        final link = await _findLink(preview.accountScope, item);
        if (link == null) {
          final taskId = _uuid.v4();
          final localCourseId = _matchLocalCourseId(courses, semesters, item);
          final remoteDeadline = _taskDeadline(item);
          await db
              .into(db.taskRecords)
              .insert(
                TaskRecord(
                  id: taskId,
                  createdAt: now,
                  updatedAt: now,
                  title: item.title,
                  notes: item.description,
                  category: importCategory,
                  courseId: localCourseId,
                  deadline: remoteDeadline,
                  hasDeadlineTime:
                      item.duePrecision == LmsDuePrecision.dateTime,
                  priority: TaskPriority.medium,
                  status: TaskStatus.active,
                  repeatUnit: RepeatUnit.none,
                  repeatInterval: 1,
                ),
              );
          await _insertLink(
            taskId: taskId,
            accountScope: preview.accountScope,
            item: item,
            lastSeenAt: now,
          );
          created++;
          continue;
        }

        final task = await (db.select(
          db.taskRecords,
        )..where((t) => t.id.equals(link.taskId))).getSingleOrNull();
        if (task == null) {
          throw LmsTaskSyncException(
            'Imported-task metadata for ${item.title} is inconsistent. Restore from backup or reconnect before syncing again.',
          );
        }

        if (link.ignored) {
          await _updateLink(link: link, item: item, lastSeenAt: now);
          suppressed++;
          continue;
        }

        var wasRestored = false;
        if (task.deletedAt != null) {
          await (db.update(
            db.taskRecords,
          )..where((t) => t.id.equals(task.id))).write(
            TaskRecordsCompanion(
              deletedAt: const Value(null),
              updatedAt: Value(now),
            ),
          );
          restored++;
          wasRestored = true;
        }

        final remoteDeadline = _taskDeadline(item);
        final remoteHasTime = item.duePrecision == LmsDuePrecision.dateTime;
        final matchedLocalCourseId = _matchLocalCourseId(
          courses,
          semesters,
          item,
        );
        final titleCanFollowRemote = task.title == link.lastRemoteTitle;
        final notesCanFollowRemote = task.notes == link.lastRemoteDescription;
        final deadlineCanFollowRemote = _sameDeadline(
          task.deadline,
          task.hasDeadlineTime,
          link.lastRemoteDeadline,
          link.lastRemoteHasDeadlineTime,
        );

        final titleChangedRemotely = item.title != link.lastRemoteTitle;
        final descriptionChangedRemotely =
            item.description != link.lastRemoteDescription;
        final deadlineChangedRemotely = !_sameDeadline(
          remoteDeadline,
          remoteHasTime,
          link.lastRemoteDeadline,
          link.lastRemoteHasDeadlineTime,
        );

        String? nextTitle;
        String? nextNotes;
        String? nextCourseId;
        DateTime? nextDeadline;
        bool? nextHasDeadlineTime;
        var changed = false;

        // Existing imported tasks from older syncs may not have been linked to
        // their local course because eLearn decorates course names with Chinese
        // text, semester codes and official course numbers. Fill the link when
        // it is still empty, but never replace a course the user already chose.
        if (task.courseId == null && matchedLocalCourseId != null) {
          nextCourseId = matchedLocalCourseId;
          changed = true;
        }

        if (titleChangedRemotely) {
          if (titleCanFollowRemote) {
            nextTitle = item.title;
            changed = true;
          } else {
            preservedOverrides++;
          }
        }

        if (descriptionChangedRemotely) {
          if (notesCanFollowRemote) {
            nextNotes = item.description;
            changed = true;
          } else {
            preservedOverrides++;
          }
        }

        if (deadlineChangedRemotely) {
          if (deadlineCanFollowRemote) {
            nextDeadline = remoteDeadline;
            nextHasDeadlineTime = remoteHasTime;
            changed = true;
          } else {
            preservedOverrides++;
          }
        }

        if (changed) {
          await (db.update(
            db.taskRecords,
          )..where((t) => t.id.equals(task.id))).write(
            TaskRecordsCompanion(
              title: nextTitle == null
                  ? const Value.absent()
                  : Value(nextTitle),
              notes: nextNotes == null
                  ? const Value.absent()
                  : Value(nextNotes),
              courseId: nextCourseId == null
                  ? const Value.absent()
                  : Value(nextCourseId),
              deadline: nextHasDeadlineTime == null
                  ? const Value.absent()
                  : Value(nextDeadline),
              hasDeadlineTime: nextHasDeadlineTime == null
                  ? const Value.absent()
                  : Value(nextHasDeadlineTime),
              updatedAt: Value(now),
            ),
          );
          if (!wasRestored) {
            updated++;
          }
        } else if (!wasRestored) {
          unchanged++;
        }

        await _updateLink(link: link, item: item, lastSeenAt: now);
      }

      return LmsTaskSyncResult(
        created: created,
        updated: updated,
        unchanged: unchanged,
        restored: restored,
        suppressed: suppressed,
        preservedOverrides: preservedOverrides,
      );
    });
  }

  Future<bool> isImportedTask(String taskId) async {
    await db.customStatement(createTaskExternalLinksTableSql);
    final row = await db
        .customSelect(
          'SELECT 1 AS present FROM task_external_links WHERE task_id = ? LIMIT 1',
          variables: [Variable<String>(taskId)],
        )
        .getSingleOrNull();
    return row != null;
  }

  Future<void> deleteImportedTask(String taskId) async {
    await db.transaction(() async {
      await db.customStatement(createTaskExternalLinksTableSql);
      final exists = await db
          .customSelect(
            'SELECT 1 AS present FROM task_external_links WHERE task_id = ? LIMIT 1',
            variables: [Variable<String>(taskId)],
          )
          .getSingleOrNull();
      if (exists == null) {
        throw const LmsTaskSyncException(
          'This task is not linked to an LMS item.',
        );
      }
      await db.customStatement(
        'UPDATE task_external_links SET ignored = ? WHERE task_id = ?',
        [1, taskId],
      );
      final now = clock();
      await (db.update(
        db.taskRecords,
      )..where((t) => t.id.equals(taskId))).write(
        TaskRecordsCompanion(
          deletedAt: Value(now),
          updatedAt: Value(now),
        ),
      );
    });
  }

  Future<List<LmsIgnoredTask>> loadIgnoredTasks() async {
    await db.customStatement(createTaskExternalLinksTableSql);
    final rows = await db.customSelect(
      '''
      SELECT l.task_id, l.provider, l.resource_type, l.external_id,
             l.remote_course_name, l.last_remote_title
      FROM task_external_links l
      JOIN task_records t ON t.id = l.task_id
      WHERE l.ignored = 1
      ORDER BY l.remote_course_name COLLATE NOCASE,
               l.last_remote_title COLLATE NOCASE
      ''',
    ).get();
    return [
      for (final row in rows)
        LmsIgnoredTask(
          taskId: row.read<String>('task_id'),
          provider: row.read<String>('provider'),
          resourceType: row.read<String>('resource_type'),
          externalId: row.read<String>('external_id'),
          courseName: row.read<String>('remote_course_name'),
          title: row.read<String>('last_remote_title'),
        ),
    ];
  }

  Future<void> restoreIgnoredTask(String taskId) async {
    await db.transaction(() async {
      await db.customStatement(createTaskExternalLinksTableSql);
      await db.customStatement(
        'UPDATE task_external_links SET ignored = 0 WHERE task_id = ?',
        [taskId],
      );
      final now = clock();
      await (db.update(
        db.taskRecords,
      )..where((t) => t.id.equals(taskId))).write(
        TaskRecordsCompanion(
          deletedAt: const Value(null),
          updatedAt: Value(now),
        ),
      );
    });
  }

  DateTime _taskDeadline(LmsItem item) =>
      item.duePrecision == LmsDuePrecision.dateOnly
      ? DateTime(item.dueAt.year, item.dueAt.month, item.dueAt.day)
      : item.dueAt;

  bool _sameDeadline(
    DateTime? left,
    bool leftHasTime,
    DateTime? right,
    bool rightHasTime,
  ) {
    if (left == null || right == null) {
      return left == right && leftHasTime == rightHasTime;
    }
    return left.isAtSameMomentAs(right) && leftHasTime == rightHasTime;
  }

  String? _matchLocalCourseId(
    List<Course> courses,
    List<Semester> semesters,
    LmsItem item,
  ) {
    if (courses.isEmpty) return null;

    final semesterById = {
      for (final semester in semesters) semester.id: semester,
    };
    final remoteCodes = _remoteCourseCodes(item.courseName);
    if (remoteCodes.isNotEmpty) {
      final codeMatches = courses.where((course) {
        final code = _normalizeCourseCode(course.courseCode);
        return code.isNotEmpty && remoteCodes.contains(code);
      }).toList();
      final resolved = _resolveCourseMatch(
        codeMatches,
        semesterById,
        item.dueAt,
      );
      if (resolved != null) return resolved;
    }

    final remoteBaseName = _stripRemoteCourseSuffix(item.courseName);
    final remoteEnglish = _normalizeEnglishCourseName(remoteBaseName);
    if (remoteEnglish.isNotEmpty) {
      final englishMatches = courses.where((course) {
        final names = <String>{
          _normalizeEnglishCourseName(course.courseName),
          if (course.englishName?.trim().isNotEmpty == true)
            _normalizeEnglishCourseName(course.englishName!),
        }..removeWhere((value) => value.isEmpty);
        return names.contains(remoteEnglish);
      }).toList();
      final resolved = _resolveCourseMatch(
        englishMatches,
        semesterById,
        item.dueAt,
      );
      if (resolved != null) return resolved;
    }

    final remoteNormalized = _normalizeCourseName(remoteBaseName);
    if (remoteNormalized.isEmpty) return null;
    final nameMatches = courses.where((course) {
      final names = <String>{
        _normalizeCourseName(course.courseName),
        if (course.englishName?.trim().isNotEmpty == true)
          _normalizeCourseName(course.englishName!),
        if (course.englishName?.trim().isNotEmpty == true)
          _normalizeCourseName('${course.courseName}${course.englishName}'),
      }..removeWhere((value) => value.isEmpty);
      return names.contains(remoteNormalized);
    }).toList();
    return _resolveCourseMatch(nameMatches, semesterById, item.dueAt);
  }

  String? _resolveCourseMatch(
    List<Course> matches,
    Map<String, Semester> semesterById,
    DateTime dueAt,
  ) {
    if (matches.length == 1) return matches.single.id;
    if (matches.isEmpty) return null;

    final dueDate = DateTime(dueAt.year, dueAt.month, dueAt.day);
    final dueSemesterMatches = matches.where((course) {
      final semester = semesterById[course.semesterId];
      if (semester == null) return false;
      final start = DateTime(
        semester.startDate.year,
        semester.startDate.month,
        semester.startDate.day,
      );
      final end = DateTime(
        semester.endDate.year,
        semester.endDate.month,
        semester.endDate.day,
      );
      return !dueDate.isBefore(start) && !dueDate.isAfter(end);
    }).toList();
    if (dueSemesterMatches.length == 1) return dueSemesterMatches.single.id;

    final activeMatches = matches
        .where((course) => course.status == CourseStatus.inProgress)
        .toList();
    return activeMatches.length == 1 ? activeMatches.single.id : null;
  }

  Set<String> _remoteCourseCodes(String value) {
    final codes = <String>{};
    final pattern = RegExp(r'(\d{5})\s*([A-Za-z]{2,})\s*(\d{3,})');
    for (final match in pattern.allMatches(value)) {
      final term = match.group(1)!;
      final subject = match.group(2)!;
      final number = match.group(3)!;
      codes.add(_normalizeCourseCode('$term$subject$number'));
      // Some manually entered local courses omit the semester prefix.
      codes.add(_normalizeCourseCode('$subject$number'));
    }
    return codes;
  }

  String _stripRemoteCourseSuffix(String value) {
    final pattern = RegExp(r'(\d{5})\s*([A-Za-z]{2,})\s*(\d{3,})');
    final matches = pattern.allMatches(value).toList();
    if (matches.isEmpty) return value.trim();
    final match = matches.last;
    final trailing = value.substring(match.end);
    if (trailing.replaceAll(RegExp(r'[\s_\-–—:;,.()\[\]]'), '').isNotEmpty) {
      return value.trim();
    }
    return value
        .substring(0, match.start)
        .replaceFirst(RegExp(r'[\s_\-–—:;,.()\[\]]+$'), '')
        .trim();
  }

  String _normalizeCourseCode(String value) => value
      .toUpperCase()
      .replaceAll(RegExp(r'[^A-Z0-9]'), '')
      .trim();

  String _normalizeEnglishCourseName(String value) => RegExp(r'[A-Za-z0-9]+')
      .allMatches(value.toLowerCase())
      .map((match) => match.group(0)!)
      .join();

  String _normalizeCourseName(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9\u3400-\u9fff]'), '')
      .trim();

  Future<_TaskExternalLink?> _findLink(
    String accountScope,
    LmsItem item,
  ) async {
    final row = await db
        .customSelect(
          '''
      SELECT task_id, provider, account_scope, resource_type, external_id,
             external_url, remote_course_id, remote_course_name,
             last_remote_title, last_remote_description, last_remote_deadline,
             last_remote_has_deadline_time, last_seen_at, ignored
      FROM task_external_links
      WHERE provider = ? AND account_scope = ? AND resource_type = ? AND external_id = ?
      LIMIT 1
      ''',
          variables: [
            Variable<String>(item.provider.name),
            Variable<String>(accountScope),
            Variable<String>(item.resourceType.name),
            Variable<String>(item.externalId),
          ],
        )
        .getSingleOrNull();
    return row == null ? null : _TaskExternalLink.fromRow(row.data);
  }

  Future<void> _insertLink({
    required String taskId,
    required String accountScope,
    required LmsItem item,
    required DateTime lastSeenAt,
  }) => db.customStatement(
    '''
    INSERT INTO task_external_links(
      task_id, provider, account_scope, resource_type, external_id,
      external_url, remote_course_id, remote_course_name,
      last_remote_title, last_remote_description, last_remote_deadline,
      last_remote_has_deadline_time, last_seen_at
    ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''',
    [
      taskId,
      item.provider.name,
      accountScope,
      item.resourceType.name,
      item.externalId,
      item.url,
      item.courseId,
      item.courseName,
      item.title,
      item.description,
      _taskDeadline(item).toIso8601String(),
      item.duePrecision == LmsDuePrecision.dateTime ? 1 : 0,
      lastSeenAt.toIso8601String(),
    ],
  );

  Future<void> _updateLink({
    required _TaskExternalLink link,
    required LmsItem item,
    required DateTime lastSeenAt,
  }) => db.customStatement(
    '''
    UPDATE task_external_links
    SET external_url = ?, remote_course_id = ?, remote_course_name = ?,
        last_remote_title = ?, last_remote_description = ?,
        last_remote_deadline = ?, last_remote_has_deadline_time = ?, last_seen_at = ?
    WHERE task_id = ?
    ''',
    [
      item.url,
      item.courseId,
      item.courseName,
      item.title,
      item.description,
      _taskDeadline(item).toIso8601String(),
      item.duePrecision == LmsDuePrecision.dateTime ? 1 : 0,
      lastSeenAt.toIso8601String(),
      link.taskId,
    ],
  );
}

class _TaskExternalLink {
  const _TaskExternalLink({
    required this.taskId,
    required this.lastRemoteTitle,
    required this.lastRemoteDescription,
    required this.lastRemoteDeadline,
    required this.lastRemoteHasDeadlineTime,
    required this.ignored,
  });

  final String taskId;
  final String lastRemoteTitle;
  final String lastRemoteDescription;
  final DateTime lastRemoteDeadline;
  final bool lastRemoteHasDeadlineTime;
  final bool ignored;

  factory _TaskExternalLink.fromRow(Map<String, Object?> row) =>
      _TaskExternalLink(
        taskId: row['task_id']! as String,
        lastRemoteTitle: row['last_remote_title']! as String,
        lastRemoteDescription:
            (row['last_remote_description'] as String?) ?? '',
        lastRemoteDeadline: DateTime.parse(
          row['last_remote_deadline']! as String,
        ),
        lastRemoteHasDeadlineTime:
            (row['last_remote_has_deadline_time']! as int) != 0,
        ignored: (row['ignored']! as int) != 0,
      );
}

class LmsIgnoredTask {
  const LmsIgnoredTask({
    required this.taskId,
    required this.provider,
    required this.resourceType,
    required this.externalId,
    required this.courseName,
    required this.title,
  });

  final String taskId;
  final String provider;
  final String resourceType;
  final String externalId;
  final String courseName;
  final String title;
}
