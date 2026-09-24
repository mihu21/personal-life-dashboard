import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../class_schedule/data/academic_database.dart';
import '../../tasks/domain/task_types.dart';
import '../domain/spending_engine.dart';
import '../domain/spending_models.dart';

class SpendingRepository {
  SpendingRepository(this.db, {DateTime Function()? clock})
    : clock = clock ?? DateTime.now;
  final AcademicDatabase db;
  final DateTime Function() clock;
  final _changes = StreamController<void>.broadcast();
  Future<void> _queue = Future.value();
  bool _disposed = false;
  String newId() => const Uuid().v4();
  void dispose() {
    _disposed = true;
    _changes.close();
  }

  Future<SpendingState> _read() async {
    final row = await db
        .customSelect('SELECT payload FROM spending_state WHERE id = 1')
        .getSingleOrNull();
    return row == null
        ? SpendingState()
        : SpendingState.decode(row.read<String>('payload'));
  }

  Future<SpendingState> load() => _command(null);
  Future<void> change(void Function(SpendingEngine) action) async {
    await _command(action);
  }

  Future<SpendingState> _command(void Function(SpendingEngine)? action) {
    final result = Completer<SpendingState>();
    _queue = _queue.then((_) async {
      try {
        final state = await db.transaction(() async {
          final state = await _read();
          final engine = SpendingEngine(state, newId, now: clock());
          engine.validate();
          final generated = engine.generate();
          action?.call(engine);
          engine.validate();
          if (generated || action != null) {
            await db.customStatement(
              'INSERT INTO spending_state(id, payload) VALUES (1, ?) ON CONFLICT(id) DO UPDATE SET payload = excluded.payload',
              [state.encode()],
            );
          }
          await _syncReminders(state);
          return state;
        });
        if (action != null && !_disposed) _changes.add(null);
        result.complete(state);
      } catch (e, stack) {
        result.completeError(e, stack);
      }
    });
    return result.future;
  }

  Stream<SpendingState> watch() {
    late StreamController<SpendingState> controller;
    Timer? timer;
    StreamSubscription<void>? subscription;
    var running = false;
    var pending = false;
    Future<void> refresh() async {
      if (running) {
        pending = true;
        return;
      }
      running = true;
      try {
        final value = await load();
        if (!controller.isClosed) controller.add(value);
      } catch (e, st) {
        if (!controller.isClosed) controller.addError(e, st);
      } finally {
        running = false;
        if (pending && !controller.isClosed) {
          pending = false;
          refresh();
        }
      }
    }

    controller = StreamController<SpendingState>(
      onListen: () {
        subscription = _changes.stream.listen((_) => refresh());
        timer = Timer.periodic(const Duration(minutes: 1), (_) => refresh());
        refresh();
      },
      onCancel: () async {
        timer?.cancel();
        await subscription?.cancel();
      },
    );
    return controller.stream;
  }

  /// The existing Tasks service remains the sole OS notification owner.
  /// Debt reminders appear as Personal tasks; paying a debt completes its task.
  Future<void> _syncReminders(SpendingState state) async {
    final desired =
        <String, ({String title, String notes, DateTime due, bool done})>{};
    for (final d in state.debts.where(
      (d) => d.flag('remind') && d.text('due').isNotEmpty,
    )) {
      desired['spending:debt:${d.id}'] = (
        title:
            '${d.text('direction') == 'iOwe' ? 'Pay' : 'Collect from'} ${state.person(d.text('personId')).text('name')}: ${d.text('title')}',
        notes:
            '${money(state.remaining(d), d.text('currency'))} remaining. Record repayment in Spending to update the balance.',
        due: DateTime(
          d.date('due').year,
          d.date('due').month,
          d.date('due').day,
          9,
        ),
        done: state.remaining(d) == 0,
      );
    }
    for (final p in state.plans.where(
      (p) =>
          p.text('status') == 'active' && SpendRow(p.template).flag('remind'),
    )) {
      final due = recurrenceDate(p, p.number('next'));
      if (p.text('end').isNotEmpty && due.isAfter(p.date('end'))) continue;
      desired['spending:plan:${p.id}'] = (
        title: 'Upcoming: ${p.text('title')}',
        notes:
            'The next charge will be recorded when the dashboard opens on or after ${dateKey(due)}.',
        due: DateTime(due.year, due.month, due.day, 9),
        done: false,
      );
    }
    final existing = await (db.select(
      db.taskRecords,
    )..where((t) => t.id.like('spending:%'))).get();
    for (final old in existing) {
      if (!desired.containsKey(old.id) &&
          old.deletedAt == null &&
          old.status != TaskStatus.completed) {
        await (db.delete(
          db.taskReminders,
        )..where((r) => r.taskId.equals(old.id))).go();
        await (db.update(
          db.taskRecords,
        )..where((t) => t.id.equals(old.id))).write(
          TaskRecordsCompanion(
            status: const Value(TaskStatus.completed),
            completedAt: Value(clock()),
          ),
        );
      }
    }
    for (final entry in desired.entries) {
      final old = existing.where((t) => t.id == entry.key).firstOrNull;
      // Respect a reminder explicitly deleted in Tasks.
      if (old?.deletedAt != null) continue;
      final v = entry.value;
      final status = v.done ? TaskStatus.completed : TaskStatus.active;
      if (old != null &&
          old.title == v.title &&
          old.notes == v.notes &&
          old.deadline == v.due &&
          old.status == status) {
        continue;
      }
      await db
          .into(db.taskRecords)
          .insertOnConflictUpdate(
            TaskRecordsCompanion.insert(
              id: entry.key,
              title: v.title,
              notes: Value(v.notes),
              category: const Value('Personal'),
              priority: TaskPriority.low,
              status: status,
              repeatUnit: RepeatUnit.none,
              deadline: Value(v.due),
              hasDeadlineTime: const Value(true),
              createdAt: Value(old?.createdAt ?? clock()),
              updatedAt: Value(clock()),
              completedAt: Value(v.done ? clock() : null),
            ),
          );
      final reminders = await (db.select(
        db.taskReminders,
      )..where((r) => r.taskId.equals(entry.key))).get();
      if (reminders.isEmpty && !v.done) {
        await db
            .into(db.taskReminders)
            .insert(
              TaskRemindersCompanion.insert(
                taskId: entry.key,
                minutesBefore: const Value(0),
              ),
            );
      }
    }
  }
}
