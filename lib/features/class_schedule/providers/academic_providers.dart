import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/academic_database.dart';
import '../data/academic_repository.dart';
import '../data/academic_snapshot.dart';
import '../data/nthu_catalog_repository.dart';
import '../data/one_time_event_repository.dart';
import '../domain/one_time_event.dart';

enum ScheduleViewMode { today, week }

class ScheduleViewModeNotifier extends Notifier<ScheduleViewMode> {
  @override
  ScheduleViewMode build() => ScheduleViewMode.today;

  void setWeek(bool week) {
    state = week ? ScheduleViewMode.week : ScheduleViewMode.today;
  }

  void toggle() {
    state = state == ScheduleViewMode.week
        ? ScheduleViewMode.today
        : ScheduleViewMode.week;
  }
}

final scheduleViewModeProvider =
    NotifierProvider<ScheduleViewModeNotifier, ScheduleViewMode>(
      ScheduleViewModeNotifier.new,
    );

final oneTimeEventRepositoryProvider = Provider<OneTimeEventRepository>(
  (ref) => OneTimeEventRepository(),
);

final oneTimeEventsProvider = FutureProvider<List<OneTimeEvent>>((ref) async {
  try {
    return await ref.watch(oneTimeEventRepositoryProvider).load();
  } catch (_) {
    // Keep the schedule usable if local event storage is temporarily unavailable.
    return const <OneTimeEvent>[];
  }
});

final academicDatabaseProvider = Provider<AcademicDatabase>((ref) {
  final database = AcademicDatabase();
  ref.onDispose(database.close);
  return database;
});

final nthuCatalogRepositoryProvider = Provider<NthuCatalogRepository>(
  (ref) => NthuCatalogRepository(ref.watch(academicDatabaseProvider)),
);

final academicRepositoryProvider = Provider<AcademicRepository>(
  (ref) => AcademicRepository(ref.watch(academicDatabaseProvider)),
);

final academicSnapshotProvider = StreamProvider<AcademicSnapshot>((ref) async* {
  final repository = ref.watch(academicRepositoryProvider);
  await repository.initialize();
  yield* repository.watch();
});

// Periodic updates keep current/next class and the day fresh in an open monitor.
final scheduleClockProvider = StreamProvider<DateTime>((ref) async* {
  yield DateTime.now();
  yield* Stream.periodic(const Duration(seconds: 30), (_) => DateTime.now());
});
