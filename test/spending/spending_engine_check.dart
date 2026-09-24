// Also executable without Flutter: dart run test/spending/spending_engine_check.dart
import 'dart:io';

import 'package:personal_life_dashboard/features/spending/domain/spending_models.dart';
import 'package:personal_life_dashboard/features/spending/domain/spending_engine.dart';

void expectEqual(Object? actual, Object? expected, String label) {
  if (actual != expected) {
    throw StateError('$label: expected $expected, got $actual');
  }
}

void rejects(void Function() action, String label) {
  try {
    action();
  } catch (_) {
    return;
  }
  throw StateError('$label: expected rejection');
}

SpendingEngine fixture({DateTime? now}) {
  var counter = 0;
  final e = SpendingEngine(
    SpendingState(),
    () => 'id${++counter}',
    now: now ?? DateTime(2026, 9, 23),
  );
  e.account(
    SpendRow({
      'id': 'cash',
      'name': 'Cash',
      'currency': 'TWD',
      'opening': 100000,
    }),
  );
  e.account(
    SpendRow({'id': 'bank', 'name': 'Bank', 'currency': 'TWD', 'opening': 0}),
  );
  e.account(
    SpendRow({'id': 'idr', 'name': 'Rupiah', 'currency': 'IDR', 'opening': 0}),
  );
  e.person(SpendRow({'id': 'alex', 'name': 'Alex'}));
  e.person(SpendRow({'id': 'sam', 'name': 'Sam'}));
  return e;
}

SpendRow entry(
  String id,
  String kind,
  int amount, [
  Map<String, dynamic> extra = const {},
]) => SpendRow({
  'id': id,
  'kind': kind,
  'title': 'Test',
  'amount': amount,
  'accountId': 'cash',
  'currency': 'TWD',
  'rate': 1000000,
  'date': '2026-09-01',
  'category': kind == 'income' ? 'Salary' : 'Food',
  ...extra,
});
void main() {
  expectEqual(parseAmount('1,234.56', 'TWD'), 123456, 'exact minor units');
  expectEqual(parseAmount('10', 'JPY'), 10, 'JPY units');
  rejects(() => parseAmount('1.001', 'TWD'), 'reject extra precision');
  rejects(() => parseAmount('NaN', 'TWD'), 'reject nonfinite');
  rejects(() => parseRate('0'), 'reject zero rate');
  expectEqual(
    toTwd(10000000, 'IDR', parseRate('0.002')),
    20000,
    'IDR conversion',
  );
  expectEqual(
    toTwd(-10000000, 'IDR', parseRate('0.002')),
    -20000,
    'negative conversion',
  );
  final e = fixture();
  e.post(entry('salary', 'income', 50000));
  e.post(entry('lunch', 'expense', 20000));
  e.post(
    entry('transfer', 'transfer', 30000, {
      'toAccountId': 'bank',
      'received': 30000,
    }),
  );
  e.validate();
  expectEqual(e.state.balance('cash'), 100000, 'transfer source');
  expectEqual(e.state.balance('bank'), 30000, 'transfer destination');
  expectEqual(
    e.state.income(DateTime(2026, 9)),
    50000,
    'income excludes transfers',
  );
  expectEqual(
    e.state.expenses(DateTime(2026, 9)),
    20000,
    'expense excludes transfers',
  );
  e.refund('lunch', 5000, DateTime(2026, 9, 3));
  e.validate();
  expectEqual(
    e.state.expenses(DateTime(2026, 9)),
    15000,
    'refund lowers spending',
  );
  rejects(() => e.refund('lunch', 16000, DateTime(2026, 9)), 'excess refund');
  rejects(() => e.deleteEntry('lunch'), 'protect refunded expense');
  e.post(
    entry('dinner', 'split', 30000, {
      'ownAmount': 10000,
      'shares': [
        {'personId': 'alex', 'amount': 12000},
        {'personId': 'sam', 'amount': 8000},
      ],
    }),
  );
  e.validate();
  expectEqual(
    e.state.expenses(DateTime(2026, 9)),
    25000,
    'only own split share counts',
  );
  expectEqual(
    e.state.remaining(e.state.debt('dinner:alex')),
    12000,
    'split creates receivable',
  );
  e.repay('dinner:alex', 'cash', 5000, DateTime(2026, 9, 4));
  e.validate();
  expectEqual(
    e.state.remaining(e.state.debt('dinner:alex')),
    7000,
    'partial payment',
  );
  expectEqual(
    e.state.income(DateTime(2026, 9)),
    50000,
    'repayment is not income',
  );
  rejects(
    () => e.repay('dinner:alex', 'cash', 7001, DateTime(2026, 9)),
    'overpayment',
  );
  rejects(
    () => e.repay('dinner:alex', 'idr', 100, DateTime(2026, 9)),
    'currency mismatch',
  );
  rejects(() => e.deleteEntry('dinner'), 'protect paid split');
  e.post(
    entry('loan', 'debt', 5000, {
      'personId': 'alex',
      'direction': 'iOwe',
      'cashLoan': true,
    }),
  );
  e.repay('loan', 'cash', 5000, DateTime(2026, 9, 5));
  e.validate();
  expectEqual(e.state.remaining(e.state.debt('loan')), 0, 'settled loan');
  expectEqual(
    e.state.expenses(DateTime(2026, 9)),
    25000,
    'loan payment not expense',
  );
  final copy = SpendingState.decode(e.state.encode());
  SpendingEngine(copy, () => 'unused').validate();
  expectEqual(
    copy.balance('cash'),
    e.state.balance('cash'),
    'round-trip balance',
  );
  expectEqual(
    copy.remaining(copy.debt('dinner:alex')),
    7000,
    'round-trip debt',
  );

  final r = fixture(now: DateTime(2026, 3, 31));
  final plan = SpendRow({
    'id': 'family',
    'title': 'Family plan',
    'start': '2026-01-31',
    'end': '',
    'frequency': 'monthly',
    'interval': 1,
    'next': 0,
    'dueDays': 7,
    'status': 'active',
    'template': entry('template', 'debt', 9000, {
      'personId': 'alex',
      'direction': 'theyOwe',
    }).data,
  });
  r.savePlan(plan);
  r.validate();
  expectEqual(r.state.debts.length, 3, 'catch up missed periods');
  expectEqual(r.state.debts[1].text('date'), '2026-02-28', 'month-end clamps');
  expectEqual(
    r.state.debts[2].text('date'),
    '2026-03-31',
    'month-end anchor preserved',
  );
  expectEqual(r.generate(), false, 'generation idempotent');
  r.deleteDebt('family:0');
  r.generate();
  expectEqual(r.state.debts.length, 2, 'deleted period stays deleted');
  r.savePlan(
    plan.copy({
      'template': entry('template', 'debt', 12000, {
        'personId': 'alex',
        'direction': 'theyOwe',
      }).data,
    }),
  );
  final april = SpendingEngine(
    r.state,
    () => 'new',
    now: DateTime(2026, 4, 30),
  );
  april.generate();
  april.validate();
  expectEqual(r.state.debt('family:3').number('amount'), 12000, 'future price');
  expectEqual(
    r.state.debt('family:1').number('amount'),
    9000,
    'historical price preserved',
  );
  april.planStatus('family', 'paused');
  final june = SpendingEngine(r.state, () => 'new', now: DateTime(2026, 6, 30));
  june.planStatus('family', 'active');
  june.generate();
  expectEqual(r.state.debts.length, 3, 'paused months skipped on resume');
  expectEqual(
    dateKey(
      recurrenceDate(r.state.plans.single, r.state.plans.single.number('next')),
    ),
    '2026-07-31',
    'resume next billing period',
  );
  june.planStatus('family', 'cancelled');
  final future = SpendingEngine(r.state, () => 'new', now: DateTime(2027));
  future.generate();
  expectEqual(r.state.debts.length, 3, 'cancel stops future charges');
  final leap = plan.copy({'start': '2024-02-29', 'frequency': 'yearly'});
  expectEqual(
    dateKey(recurrenceDate(leap, 1)),
    '2025-02-28',
    'annual leap clamp',
  );
  expectEqual(
    dateKey(recurrenceDate(leap, 4)),
    '2028-02-29',
    'annual anchor preserved',
  );
  final foreign = fixture();
  foreign.post(
    entry('fx', 'transfer', 10000, {'toAccountId': 'idr', 'received': 5000000}),
  );
  foreign.validate();
  expectEqual(foreign.state.balance('idr'), 5000000, 'cross currency received');
  expectEqual(
    foreign.state.expenses(DateTime(2026, 9)),
    0,
    'FX transfer excluded',
  );
  final shared = fixture(now: DateTime(2026, 2, 1));
  shared.savePlan(
    plan.copy({
      'id': 'shared',
      'start': '2026-01-01',
      'end': '2026-02-01',
      'template': entry('t', 'split', 30000, {
        'ownAmount': 10000,
        'shares': [
          {'personId': 'alex', 'amount': 10000},
          {'personId': 'sam', 'amount': 10000},
        ],
      }).data,
    }),
  );
  shared.validate();
  expectEqual(shared.state.entries.length, 2, 'shared subscription bills');
  expectEqual(shared.state.debts.length, 4, 'per-person monthly shares');
  expectEqual(
    shared.state.expenses(DateTime(2026, 2)),
    10000,
    'own subscription share',
  );
  final afterEnd = SpendingEngine(
    shared.state,
    () => 'new',
    now: DateTime(2026, 5),
  );
  afterEnd.generate();
  expectEqual(
    shared.state.entries.length,
    2,
    'inclusive end date stops next month',
  );
  stdout.writeln(
    'PASS: money, FX, account balances, transfers, refunds, split expenses, partial repayments, debt direction, serialization, recurrence catch-up, duplicate prevention, month-end/leap anchors, future prices, pause/resume, cancellation and subscription shares.',
  );
}
