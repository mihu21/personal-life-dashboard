import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/nthu_academic.dart';
import '../domain/one_time_event.dart';

/// Schedules device-local reminders for one-time calendar events.
///
/// Event reminder choices are persisted with each event. This service only
/// mirrors those choices into the platform notification scheduler.
class EventNotificationService {
  EventNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const _channelId = 'event_reminders';
  static const _channelName = 'Event reminders';
  static const _channelDescription =
      'Reminders for events saved in Personal Life Dashboard.';

  final FlutterLocalNotificationsPlugin _plugin;
  Future<void>? _initializing;

  bool get _supported => Platform.isAndroid || Platform.isWindows;

  Future<void> initialize() {
    if (!_supported) return Future.value();
    return _initializing ??= _initialize();
  }

  Future<void> _initialize() async {
    tz_data.initializeTimeZones();
    try {
      final timezone = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timezone.identifier));
    } catch (_) {
      // UTC is a safe fallback. TZDateTime.from below preserves the actual
      // instant represented by the device-local DateTime.
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

  /// Requests Android notification permission only in response to the user
  /// enabling reminders. Windows does not need an equivalent runtime prompt.
  Future<bool> ensurePermission() async {
    if (!_supported) return false;
    await initialize();
    if (!Platform.isAndroid) return true;

    final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin
    >();
    if (android == null) return false;
    if ((await android.areNotificationsEnabled()) ?? false) return true;
    return await android.requestNotificationsPermission() ?? false;
  }

  /// Cancels the pending reminders that belong to one event.
  Future<void> cancelEvent(OneTimeEvent event) async {
    if (!_supported || event.reminderMinutesBefore.isEmpty) return;
    await initialize();
    for (final minutesBefore in event.reminderMinutesBefore.toSet()) {
      await _plugin.cancel(id: _notificationId(event.id, minutesBefore));
    }
  }

  /// Replaces an event's pending reminder schedule without touching any other
  /// notification types the app may add later.
  ///
  /// Past reminder times are skipped rather than delivered immediately.
  Future<void> replaceEvent({
    OneTimeEvent? previous,
    required OneTimeEvent event,
    required bool scheduleReminders,
  }) async {
    if (!_supported) return;
    if (previous != null) await cancelEvent(previous);
    if (!scheduleReminders || event.reminderMinutesBefore.isEmpty) return;

    await initialize();
    final now = DateTime.now();
    final reminders = event.reminderMinutesBefore.toSet().toList()..sort();
    for (final minutesBefore in reminders) {
      final scheduledAt = event.startDateTime.subtract(
        Duration(minutes: minutesBefore),
      );
      if (!scheduledAt.isAfter(now)) continue;
      await _schedule(event, minutesBefore, scheduledAt);
    }
  }

  Future<void> _schedule(
    OneTimeEvent event,
    int minutesBefore,
    DateTime scheduledAt,
  ) async {
    final startPeriod = nthuPeriod(event.startPeriod);
    final endPeriod = nthuPeriod(event.endPeriod);
    final periodTime = startPeriod != null && endPeriod != null
        ? '${startPeriod.startLabel}–${endPeriod.endLabel}'
        : event.specificTime;
    final displayedTime = event.specificTime.trim().isNotEmpty
        ? event.specificTime.trim()
        : periodTime;
    final bodyParts = <String>[
      if (displayedTime.isNotEmpty) displayedTime,
      if (event.location.trim().isNotEmpty) event.location.trim(),
    ];

    await _plugin.zonedSchedule(
      id: _notificationId(event.id, minutesBefore),
      title: event.title,
      body: bodyParts.isEmpty ? reminderLabel(minutesBefore) : bodyParts.join(' · '),
      payload: 'event:${event.id}',
      scheduledDate: tz.TZDateTime.from(scheduledAt, tz.local),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        windows: WindowsNotificationDetails(),
      ),
      // Avoid requiring Android's separate exact-alarm permission. These are
      // reminders, not alarm-clock events, so slight OS batching is acceptable.
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  static int _notificationId(String eventId, int minutesBefore) {
    var hash = 0x811c9dc5;
    for (final unit in '$eventId:$minutesBefore'.codeUnits) {
      hash ^= unit;
      hash = (hash * 0x01000193) & 0x7fffffff;
    }
    return hash == 0 ? 1 : hash;
  }
}
