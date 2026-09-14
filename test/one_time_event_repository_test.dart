import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/one_time_event_repository.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/one_time_event.dart';

void main() {
  test('one-time events persist, update, and delete', () async {
    final directory = await Directory.systemTemp.createTemp(
      'personal-life-dashboard-events-',
    );
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}${Platform.pathSeparator}events.json');
    final repository = OneTimeEventRepository(fileFactory: () async => file);
    final stamp = DateTime(2026, 9, 15, 10);
    final event = OneTimeEvent(
      id: 'event-1',
      title: 'Club meeting',
      date: DateTime(2026, 9, 19),
      startPeriod: '3',
      endPeriod: '4',
      specificTime: '10:20–11:45',
      location: 'Student center',
      notes: 'Bring the form',
      createdAt: stamp,
      updatedAt: stamp,
    );

    await repository.upsert(event);
    var loaded = await repository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.title, 'Club meeting');
    expect(loaded.single.scheduleCode, 'S3S4');
    expect(loaded.single.specificTime, '10:20–11:45');
    expect(eventsForDay(loaded, DateTime(2026, 9, 19)), hasLength(1));
    expect(eventsForDay(loaded, DateTime(2026, 9, 26)), isEmpty);

    await repository.upsert(
      event.copyWith(
        title: 'Updated club meeting',
        updatedAt: stamp.add(const Duration(minutes: 5)),
      ),
    );
    loaded = await repository.load();
    expect(loaded, hasLength(1));
    expect(loaded.single.title, 'Updated club meeting');

    await repository.delete(event.id);
    expect(await repository.load(), isEmpty);
  });
}
