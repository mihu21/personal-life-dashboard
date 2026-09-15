import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/class_schedule/domain/one_time_event.dart';
import 'package:personal_life_dashboard/features/class_schedule/presentation/one_time_event_details.dart';

void main() {
  testWidgets('event tap details show reminders and scrollable notes', (tester) async {
    final stamp = DateTime(2026, 9, 15, 10);
    final event = OneTimeEvent(
      id: 'details-event',
      title: 'GSA meeting',
      date: DateTime(2026, 9, 20),
      startPeriod: '5',
      endPeriod: '6',
      location: 'EECS 106',
      notes: List.filled(30, 'Long meeting note.').join(' '),
      reminderMinutesBefore: const [30, 1440],
      createdAt: stamp,
      updatedAt: stamp,
    );

    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: OneTimeEventDetails(initialEvent: event),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('GSA meeting'), findsOneWidget);
    expect(find.text('30 min before · 1 day before'), findsOneWidget);
    expect(find.text('EECS 106'), findsOneWidget);
    expect(find.text('Edit'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);
    expect(find.byType(Scrollbar), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsWidgets);
    expect(tester.takeException(), isNull);
  });
}
