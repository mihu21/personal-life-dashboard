import '../../class_schedule/data/academic_database.dart';
import '../domain/task_types.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../class_schedule/providers/academic_providers.dart';
import '../data/task_notification_service.dart';
import '../data/task_repository.dart';
import '../domain/task_logic.dart';

final taskRepositoryProvider = Provider(
  (ref) => TaskRepository(ref.watch(academicDatabaseProvider)),
);
final taskNotificationServiceProvider = Provider(
  (ref) => TaskNotificationService(LocalTaskNotificationGateway()),
);
final tasksProvider = StreamProvider<List<TaskBundle>>(
  (ref) => ref.watch(taskRepositoryProvider).watch(),
);

final taskNotificationSyncProvider = FutureProvider<void>((ref) async {
  final tasks = ref.watch(tasksProvider);
  if (tasks.hasError) throw tasks.error!;
  // The first stream value rebuilds this provider. Do not also reconcile from
  // the loading generation, which would enqueue startup twice.
  if (!tasks.hasValue) return;
  await ref
      .watch(taskNotificationServiceProvider)
      .synchronize(ref.read(taskRepositoryProvider).load);
});

class TaskFilterNotifier extends AsyncNotifier<TaskFilter> {
  @override
  Future<TaskFilter> build() => ref.watch(taskRepositoryProvider).loadFilter();
  Future<void> apply(TaskFilter filter) async {
    await ref.read(taskRepositoryProvider).saveFilter(filter);
    state = AsyncData(filter);
  }
}

final taskFilterProvider =
    AsyncNotifierProvider<TaskFilterNotifier, TaskFilter>(
      TaskFilterNotifier.new,
    );

final taskCategoriesProvider = StreamProvider<List<TaskCategoryRecord>>(
  (ref) => ref.watch(taskRepositoryProvider).watchCategories(),
);

class TaskDisplay {
  TaskDisplay({this.view = TaskView.agenda, DateTime? date})
    : date = date ?? taskDay(DateTime.now());
  final TaskView view;
  final DateTime date;
}

class TaskDisplayNotifier extends Notifier<TaskDisplay> {
  @override
  TaskDisplay build() => TaskDisplay();
  void view(TaskView value) =>
      state = TaskDisplay(view: value, date: state.date);
  void date(DateTime value) =>
      state = TaskDisplay(view: state.view, date: value);
}

final taskDisplayProvider = NotifierProvider<TaskDisplayNotifier, TaskDisplay>(
  TaskDisplayNotifier.new,
);
