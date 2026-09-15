import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/task_logic.dart';
import '../domain/task_types.dart';

abstract class TaskNotificationGateway {
  Future<bool> permission({bool request = false});
  Future<void> cancelAll();
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String taskId,
  });
}

/// Refactors the previous event scheduler, retaining platform identity and
/// packages so existing OS reminders can be retired without touching event data.
class LocalTaskNotificationGateway implements TaskNotificationGateway {
  LocalTaskNotificationGateway({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();
  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initializing;
  bool get supported => Platform.isAndroid || Platform.isWindows;

  Future<void> initialize() async {
    if (!supported) {
      throw UnsupportedError('Local reminders support Android and Windows.');
    }
    try {
      await (_initializing ??= _initialize());
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final zone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(zone.identifier));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        windows: WindowsInitializationSettings(
          appName: 'Personal Life Dashboard',
          appUserModelId: 'MiHu.PersonalLifeDashboard.Desktop.App',
          guid: '2f2f9e4a-7bcb-4a9f-a0ba-3c3890a86475',
        ),
      ),
    );
  }

  @override
  Future<bool> permission({bool request = false}) async {
    await initialize();
    if (!Platform.isAndroid) return true;
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if ((await android?.areNotificationsEnabled()) ?? false) return true;
    return request
        ? (await android?.requestNotificationsPermission()) ?? false
        : false;
  }

  @override
  Future<void> cancelAll() async {
    await initialize();
    // One owner: remove both legacy event requests and obsolete task requests.
    // cancelAll also removes Windows scheduled toasts in the installed plugin.
    await _plugin.cancelAll();
  }

  @override
  Future<void> schedule({
    required int id,
    required String title,
    required String body,
    required DateTime at,
    required String taskId,
  }) async {
    await initialize();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      payload: 'task:$taskId',
      scheduledDate: tz.TZDateTime.from(at, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'task_reminders',
          'Task reminders',
          channelDescription: 'Reminders for tasks in Personal Life Dashboard.',
          importance: Importance.high,
          priority: Priority.high,
        ),
        windows: WindowsNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
}

class TaskNotificationService {
  TaskNotificationService(this.gateway, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final TaskNotificationGateway gateway;
  final DateTime Function() clock;
  Future<void> _queue = Future.value();

  /// Persist first, then reconcile the OS mirror. Read the latest committed data
  /// inside the serial queue: concurrent edits cannot reinstate an older schedule.
  /// A failure leaves SQLite intact and can be retried on resume or via the UI.
  Future<void> synchronize(Future<List<TaskBundle>> Function() load) {
    final operation = _queue.then((_) async {
      final tasks = await load();
      await gateway.cancelAll();
      final now = clock();
      final pending = <({TaskBundle bundle, int id, DateTime at})>[];
      for (final bundle in tasks) {
        if (bundle.task.status == TaskStatus.completed ||
            bundle.task.deletedAt != null) {
          continue;
        }
        final seen = <DateTime>{};
        for (final reminder in bundle.reminders) {
          final at = reminderTime(bundle.task, reminder);
          if (at == null || !at.isAfter(now) || !seen.add(at)) continue;
          pending.add((bundle: bundle, id: reminder.id, at: at));
        }
      }
      if (pending.isEmpty) return;
      if (!await gateway.permission()) {
        throw StateError(
          'Notifications are disabled. Your reminders are saved; enable notifications and retry.',
        );
      }
      pending.sort((a, b) => a.at.compareTo(b.at));
      final failures = <Object>[];
      for (final item in pending) {
        final task = item.bundle.task;
        try {
          await gateway.schedule(
            id: item.id,
            title: task.title,
            body:
                '${task.category} · ${task.priority.label}${task.deadline == null ? '' : ' · Due ${taskDateLabel(task.deadline!, time: task.hasDeadlineTime)}'}',
            at: item.at,
            taskId: task.id,
          );
        } catch (error) {
          failures.add(error);
        }
      }
      if (failures.isNotEmpty) {
        throw StateError(
          '${failures.length} reminder(s) could not be scheduled: ${failures.first}',
        );
      }
    });
    _queue = operation.then<void>((_) {}, onError: (Object _, StackTrace _) {});
    return operation;
  }
}
