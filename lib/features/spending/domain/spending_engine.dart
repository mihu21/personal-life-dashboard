import 'spending_models.dart';

/// Mutates a private state copy inside one SQLite transaction. A failed command
/// never reaches disk. This class has no Flutter or platform dependencies.
class SpendingEngine {
  SpendingEngine(this.state, this.newId, {DateTime? now})
    : today = spendDay(now ?? DateTime.now());
  final SpendingState state;
  final String Function() newId;
  final DateTime today;

  void _put(List<SpendRow> rows, SpendRow row) {
    final index = rows.indexWhere((r) => r.id == row.id);
    if (index < 0) {
      rows.add(row);
    } else {
      rows[index] = row;
    }
  }

  void account(SpendRow row) {
    final previous = state.accounts.where((r) => r.id == row.id).firstOrNull;
    if (previous != null && previous.text('currency') != row.text('currency')) {
      throw StateError('Create a new account to use another currency.');
    }
    _put(state.accounts, row);
  }

  void person(SpendRow row) => _put(state.people, row);
  void budget(SpendRow row) {
    state.budgets.removeWhere(
      (r) =>
          r.text('month') == row.text('month') &&
          r.text('category') == row.text('category'),
    );
    state.budgets.add(row);
  }

  void category(String name, bool income) {
    final value = name.trim();
    final target = income ? state.incomeCategories : state.expenseCategories;
    if (value.isEmpty || value.length > 60) {
      throw StateError('Category must be 1–60 characters.');
    }
    if (!target.any((c) => c.toLowerCase() == value.toLowerCase())) {
      target.add(value);
    }
  }

  void post(SpendRow row) {
    if (state.entries.any((e) => e.id == row.id) ||
        state.debts.any((d) => d.id == row.id)) {
      throw StateError('This record already exists.');
    }
    if (row.text('kind') == 'debt') {
      state.debts.add(row.copy({'originId': '', 'created': row.text('date')}));
      if (row.flag('cashLoan')) {
        final entryId = '${row.id}:loan';
        final kind = row.text('direction') == 'theyOwe'
            ? 'lending'
            : 'borrowing';
        state.entries.add(
          row.copy({'id': entryId, 'kind': kind, 'debtId': row.id}),
        );
        _put(
          state.debts,
          row.copy({'originId': entryId, 'created': row.text('date')}),
        );
      }
      return;
    }
    state.entries.add(row);
    if (row.text('kind') == 'split') {
      for (final share in row.shares) {
        state.debts.add(
          SpendRow({
            'id': '${row.id}:${share.text('personId')}',
            'personId': share.text('personId'),
            'title': row.text('title'),
            'direction': 'theyOwe',
            'amount': share.number('amount'),
            'currency': row.text('currency'),
            'date': row.text('date'),
            'due': row.text('due'),
            'notes': row.text('notes'),
            'remind': row.flag('remind'),
            'originId': row.id,
            'planId': row.text('planId'),
          }),
        );
      }
    }
  }

  void editEntry(SpendRow row) {
    final old = state.entries.firstWhere((e) => e.id == row.id);
    if (old.text('planId').isNotEmpty ||
        !['income', 'expense', 'transfer'].contains(old.text('kind')) ||
        state.entries.any((e) => e.text('refundOf') == old.id)) {
      throw StateError(
        'Linked records cannot be rewritten. Undo their dependents before deleting and recreating them.',
      );
    }
    if (row.text('kind') != old.text('kind')) {
      throw StateError('Transaction type cannot change.');
    }
    _put(state.entries, row);
  }

  void editDebt(SpendRow row) {
    final old = state.debt(row.id);
    if (old.text('originId').isNotEmpty || old.text('planId').isNotEmpty) {
      throw StateError(
        'Edit future charges in Recurring. Linked debt amounts stay with their original transaction.',
      );
    }
    if (row.text('currency') != old.text('currency') ||
        row.text('direction') != old.text('direction')) {
      throw StateError('Currency and debt direction cannot change.');
    }
    if (row.number('amount') < state.paid(row.id)) {
      throw StateError(
        'Amount cannot be lower than repayments already recorded.',
      );
    }
    _put(state.debts, row);
  }

  void refund(String entryId, int amount, DateTime date) {
    final original = state.entries.firstWhere((e) => e.id == entryId);
    if (!['expense', 'split'].contains(original.text('kind'))) {
      throw StateError('Only expenses can be refunded.');
    }
    final limit = original.text('kind') == 'split'
        ? original.number('ownAmount')
        : original.number('amount');
    if (amount <= 0 || amount > limit - state.refunded(entryId)) {
      throw StateError('Refund exceeds your remaining expense.');
    }
    state.entries.add(
      original.copy({
        'id': newId(),
        'kind': 'refund',
        'title': 'Refund: ${original.text('title')}',
        'amount': amount,
        'date': dateKey(date),
        'refundOf': entryId,
        'planId': '',
        'shares': [],
      }),
    );
  }

  void repay(String debtId, String accountId, int amount, DateTime date) {
    final debt = state.debt(debtId);
    if (amount <= 0 || amount > state.remaining(debt)) {
      throw StateError('Payment exceeds the outstanding amount.');
    }
    final account = state.account(accountId);
    if (account.text('currency') != debt.text('currency')) {
      throw StateError('Choose an account in the debt currency.');
    }
    state.entries.add(
      SpendRow({
        'id': newId(),
        'kind': debt.text('direction') == 'theyOwe'
            ? 'repaymentIn'
            : 'repaymentOut',
        'title': 'Repayment: ${debt.text('title')}',
        'amount': amount,
        'currency': debt.text('currency'),
        'accountId': accountId,
        'debtId': debtId,
        'personId': debt.text('personId'),
        'date': dateKey(date),
        'rate': 1000000,
        'category': '',
        'notes': '',
      }),
    );
  }

  void deleteEntry(String id) {
    final row = state.entries.firstWhere((e) => e.id == id);
    if (state.entries.any((e) => e.text('refundOf') == id)) {
      throw StateError(
        'Remove the refunds before deleting their original expense.',
      );
    }
    final linked = state.debts.where((d) => d.text('originId') == id).toList();
    if (linked.any((d) => state.paid(d.id) > 0)) {
      throw StateError('Undo repayments before removing this transaction.');
    }
    state.debts.removeWhere((d) => d.text('originId') == id);
    state.entries.removeWhere((e) => e.id == row.id);
  }

  void deleteDebt(String id) {
    final debt = state.debt(id);
    if (state.paid(id) > 0) {
      throw StateError('Undo repayments before removing this debt.');
    }
    if (debt.text('originId').isNotEmpty) {
      throw StateError('Delete the linked transaction to remove this debt.');
    }
    state.debts.removeWhere((d) => d.id == id);
  }

  void savePlan(SpendRow plan) {
    // Materialize due occurrences under their OLD prices before applying edits.
    generate();
    final old = state.plans.where((r) => r.id == plan.id).firstOrNull;
    if (old != null) {
      if (old.text('status') == 'cancelled') {
        throw StateError(
          'Cancelled plans cannot be restarted. Create a new plan.',
        );
      }
      plan = plan.copy({
        'start': old.text('start'),
        'frequency': old.text('frequency'),
        'interval': old.number('interval'),
        'next': old.number('next'),
        'status': old.text('status'),
      });
    }
    _put(state.plans, plan);
    validate();
    generate();
  }

  void planStatus(String id, String status) {
    generate();
    var plan = state.plans.firstWhere((r) => r.id == id);
    if (plan.text('status') == 'cancelled') {
      throw StateError('This plan is cancelled.');
    }
    var next = plan.number('next');
    if (plan.text('status') == 'paused' && status == 'active') {
      while (!recurrenceDate(plan, next).isAfter(today)) {
        next++;
      }
    }
    plan = plan.copy({'status': status, 'next': next});
    _put(state.plans, plan);
  }

  bool generate() {
    var changed = false;
    for (final original in [...state.plans]) {
      if (original.text('status') != 'active') continue;
      var next = original.number('next');
      var date = recurrenceDate(original, next);
      final end = original.text('end').isEmpty ? null : original.date('end');
      while (!date.isAfter(today) && (end == null || !date.isAfter(end))) {
        final id = '${original.id}:$next';
        if (!state.entries.any((e) => e.id == id) &&
            !state.debts.any((d) => d.id == id)) {
          final template = original.template;
          post(
            SpendRow({
              ...template,
              'id': id,
              'planId': original.id,
              'date': dateKey(date),
              'title': '${original.text('title')} · ${dateKey(date)}',
              'due': dateKey(
                DateTime(
                  date.year,
                  date.month,
                  date.day + original.number('dueDays'),
                ),
              ),
            }),
          );
        }
        next++;
        date = recurrenceDate(original, next);
        changed = true;
      }
      if (next != original.number('next')) {
        _put(state.plans, original.copy({'next': next}));
      }
    }
    return changed;
  }

  void validate() {
    void require(bool condition, String message) {
      if (!condition) throw FormatException(message);
    }

    bool validDate(String text, {bool optional = false}) {
      if (text.isEmpty) return optional;
      final d = DateTime.tryParse(text);
      return d != null &&
          d.year >= 2000 &&
          d.year <= 2200 &&
          dateKey(d) == text;
    }

    void named(SpendRow r) => require(
      r.text('name').trim().isNotEmpty && r.text('name').length <= 100,
      'Name must be 1–100 characters.',
    );
    void amount(SpendRow r) => require(
      r.number('amount') > 0 && r.number('amount') <= 9000000000000,
      'Enter a positive amount within range.',
    );
    void currency(SpendRow r) => require(
      spendingCurrencies.contains(r.text('currency')),
      'Unsupported currency.',
    );
    for (final list in [
      state.accounts,
      state.people,
      state.entries,
      state.debts,
      state.plans,
      state.budgets,
    ]) {
      require(
        list.every((r) => r.id.isNotEmpty) &&
            list.map((r) => r.id).toSet().length == list.length,
        'Duplicate or missing record ID.',
      );
    }
    for (final a in state.accounts) {
      named(a);
      currency(a);
      require(
        a.number('opening').abs() <= 9000000000000,
        'Opening balance is out of range.',
      );
    }
    for (final p in state.people) {
      named(p);
    }
    for (final categories in [
      state.expenseCategories,
      state.incomeCategories,
    ]) {
      require(
        categories.isNotEmpty &&
            categories.every((c) => c.trim().isNotEmpty && c.length <= 60) &&
            categories.toSet().length == categories.length,
        'Invalid categories.',
      );
    }
    void validateTemplate(SpendRow e, {bool template = false}) {
      require(
        e.text('title').trim().isNotEmpty && e.text('title').length <= 180,
        'Title must be 1–180 characters.',
      );
      amount(e);
      currency(e);
      require(
        validDate(e.text('date')) || template,
        'Invalid transaction date.',
      );
      require(validDate(e.text('due'), optional: true), 'Invalid due date.');
      final kind = e.text('kind');
      require(
        [
          'expense',
          'income',
          'transfer',
          'split',
          'debt',
          'refund',
          'lending',
          'borrowing',
          'repaymentIn',
          'repaymentOut',
        ].contains(kind),
        'Invalid transaction type.',
      );
      if (kind == 'debt') {
        state.person(e.text('personId'));
        require(
          ['iOwe', 'theyOwe'].contains(e.text('direction')),
          'Invalid debt direction.',
        );
        if (!e.flag('cashLoan')) return;
      }
      final a = state.account(e.text('accountId'));
      require(
        a.text('currency') == e.text('currency'),
        'Account and transaction currencies must match.',
      );
      require(
        e.number('rate') > 0 && e.number('rate') <= 1000000000000,
        'A recorded exchange rate is required.',
      );
      if (e.text('currency') == 'TWD') {
        require(e.number('rate') == 1000000, 'TWD rate must be 1.');
      }
      if (kind == 'income') {
        require(
          state.incomeCategories.contains(e.text('category')),
          'Select an income category.',
        );
      }
      if (['expense', 'split', 'refund'].contains(kind)) {
        require(
          state.expenseCategories.contains(e.text('category')),
          'Select an expense category.',
        );
      }
      if (kind == 'transfer') {
        state.account(e.text('toAccountId'));
        require(
          e.text('accountId') != e.text('toAccountId') &&
              e.number('received') > 0 &&
              e.number('received') <= 9000000000000,
          'Choose different accounts and a positive received amount.',
        );
        if (state.account(e.text('toAccountId')).text('currency') ==
            e.text('currency')) {
          require(
            e.number('received') == e.number('amount'),
            'Same-currency transfers must have equal amounts. Record fees separately.',
          );
        }
      }
      if (kind == 'split') {
        require(
          e.shares.isNotEmpty &&
              e.shares.map((s) => s.text('personId')).toSet().length ==
                  e.shares.length,
          'Select at least one person, without duplicates.',
        );
        var sum = 0;
        for (final s in e.shares) {
          state.person(s.text('personId'));
          amount(s);
          sum += s.number('amount');
        }
        require(
          e.number('ownAmount') >= 0 &&
              sum + e.number('ownAmount') == e.number('amount'),
          'Your share and others’ shares must equal the total.',
        );
      }
    }

    for (final e in state.entries) {
      validateTemplate(e);
      if (e.text('kind') == 'split') {
        for (final share in e.shares) {
          final linked = state.debt('${e.id}:${share.text('personId')}');
          require(
            linked.number('amount') == share.number('amount') &&
                linked.text('currency') == e.text('currency') &&
                linked.text('personId') == share.text('personId') &&
                linked.text('direction') == 'theyOwe' &&
                linked.text('originId') == e.id,
            'Split expense and linked debt do not match.',
          );
        }
      }
      if (e.text('refundOf').isNotEmpty) {
        final source = state.entries
            .where((s) => s.id == e.text('refundOf'))
            .firstOrNull;
        if (source == null ||
            !['expense', 'split'].contains(source.text('kind'))) {
          throw const FormatException('Refund has no original expense.');
        }
        require(
          e.text('kind') == 'refund' &&
              e.text('currency') == source.text('currency') &&
              e.text('accountId') == source.text('accountId') &&
              e.number('rate') == source.number('rate') &&
              e.text('category') == source.text('category'),
          'Refund must match its original expense.',
        );
        require(
          state.refunded(source.id) <=
              (source.text('kind') == 'split'
                  ? source.number('ownAmount')
                  : source.number('amount')),
          'Refund exceeds original expense.',
        );
      } else {
        require(
          e.text('kind') != 'refund',
          'Refund must reference an expense.',
        );
      }
      if ([
        'repaymentIn',
        'repaymentOut',
        'lending',
        'borrowing',
      ].contains(e.text('kind'))) {
        final debt = state.debt(e.text('debtId'));
        if (['lending', 'borrowing'].contains(e.text('kind'))) {
          require(
            debt.number('amount') == e.number('amount') &&
                debt.text('originId') == e.id,
            'Loan and linked debt do not match.',
          );
        }
        require(
          debt.text('currency') == e.text('currency'),
          'Repayment currency mismatch.',
        );
        final incoming = ['repaymentIn', 'lending'].contains(e.text('kind'));
        require(
          incoming == (debt.text('direction') == 'theyOwe'),
          'Debt direction mismatch.',
        );
      }
    }
    for (final d in state.debts) {
      state.person(d.text('personId'));
      amount(d);
      currency(d);
      require(
        d.text('title').trim().isNotEmpty && d.text('title').length <= 180,
        'Debt title is required.',
      );
      require(
        ['iOwe', 'theyOwe'].contains(d.text('direction')),
        'Invalid debt direction.',
      );
      require(
        validDate(d.text('date')) && validDate(d.text('due'), optional: true),
        'Invalid debt date.',
      );
      require(
        d.text('originId').isEmpty ||
            state.entries.any((e) => e.id == d.text('originId')),
        'Debt has no original transaction.',
      );
      require(state.remaining(d) >= 0, 'Repayments exceed the debt.');
    }
    for (final p in state.plans) {
      require(
        p.text('title').trim().isNotEmpty,
        'Recurring plan needs a title.',
      );
      require(
        validDate(p.text('start')) && validDate(p.text('end'), optional: true),
        'Invalid recurring dates.',
      );
      require(
        p.text('end').isEmpty || !p.date('end').isBefore(p.date('start')),
        'End date cannot precede start date.',
      );
      require(
        ['weekly', 'monthly', 'yearly'].contains(p.text('frequency')) &&
            p.number('interval', 1) >= 1 &&
            p.number('interval', 1) <= 120 &&
            p.number('next') >= 0 &&
            p.number('next') < 100000,
        'Invalid recurrence.',
      );
      require(
        ['active', 'paused', 'cancelled'].contains(p.text('status')) &&
            p.number('dueDays') >= 0 &&
            p.number('dueDays') <= 365,
        'Invalid recurring settings.',
      );
      final t = SpendRow(p.template);
      require(
        ['expense', 'income', 'split', 'debt'].contains(t.text('kind')),
        'Unsupported recurring transaction.',
      );
      validateTemplate(t, template: true);
    }
    final budgetKeys = <String>{};
    for (final b in state.budgets) {
      amount(b);
      require(
        RegExp(r'^\d{4}-(0[1-9]|1[0-2])$').hasMatch(b.text('month')) &&
            state.expenseCategories.contains(b.text('category')) &&
            budgetKeys.add('${b.text('month')}:${b.text('category')}'),
        'Invalid or duplicate monthly category budget.',
      );
    }
  }
}
