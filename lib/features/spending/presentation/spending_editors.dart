part of 'spending_module.dart';

Future<void> _openEditor(
  BuildContext context, {
  String kind = 'expense',
  String personId = '',
  String direction = 'theyOwe',
  bool recurring = false,
  SpendRow? entry,
  SpendRow? debt,
  SpendRow? plan,
}) => showDialog<void>(
  context: context,
  builder: (_) => _TransactionEditor(
    kind: kind,
    personId: personId,
    direction: direction,
    recurring: recurring,
    entry: entry,
    debt: debt,
    plan: plan,
  ),
);
Future<void> _simpleEditor(
  BuildContext context,
  String mode, {
  SpendRow? initial,
  String? month,
}) => showDialog<void>(
  context: context,
  builder: (_) => _SimpleEditor(mode: mode, initial: initial, month: month),
);
Widget _field(
  String label,
  TextEditingController controller, {
  bool numeric = false,
  int lines = 1,
  bool enabled = true,
  String? hint,
}) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: TextField(
    controller: controller,
    enabled: enabled,
    maxLines: lines,
    keyboardType: numeric
        ? const TextInputType.numberWithOptions(decimal: true, signed: true)
        : lines > 1
        ? TextInputType.multiline
        : TextInputType.text,
    decoration: InputDecoration(
      labelText: label,
      hintText: hint,
      isDense: true,
      border: const OutlineInputBorder(),
    ),
  ),
);
Widget _select(
  String label,
  String value,
  Map<String, String> options,
  ValueChanged<String>? changed,
) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 6),
  child: DropdownButtonFormField<String>(
    key: ValueKey('$label:$value:${options.keys.join(',')}'),
    initialValue: options.containsKey(value) ? value : null,
    isExpanded: true,
    decoration: InputDecoration(
      labelText: label,
      isDense: true,
      border: const OutlineInputBorder(),
    ),
    items: options.entries
        .map(
          (e) => DropdownMenuItem(
            value: e.key,
            child: Text(e.value, overflow: TextOverflow.ellipsis),
          ),
        )
        .toList(),
    onChanged: changed == null
        ? null
        : (v) {
            if (v != null) changed(v);
          },
  ),
);
Widget _dateButton(
  BuildContext context,
  String label,
  DateTime? date,
  ValueChanged<DateTime?> changed, {
  bool optional = false,
  bool enabled = true,
}) => Row(
  children: [
    Expanded(
      child: OutlinedButton.icon(
        onPressed: enabled
            ? () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: date ?? DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2200),
                );
                if (d != null) changed(d);
              }
            : null,
        icon: const Icon(Icons.calendar_today_outlined, size: 16),
        label: Text('$label: ${date == null ? 'None' : dateKey(date)}'),
      ),
    ),
    if (optional && date != null)
      IconButton(
        tooltip: 'Clear $label',
        onPressed: enabled ? () => changed(null) : null,
        icon: const Icon(Icons.close, size: 17),
      ),
  ],
);

class _TransactionEditor extends ConsumerStatefulWidget {
  const _TransactionEditor({
    required this.kind,
    required this.personId,
    required this.direction,
    required this.recurring,
    this.entry,
    this.debt,
    this.plan,
  });
  final String kind, personId, direction;
  final bool recurring;
  final SpendRow? entry, debt, plan;
  @override
  ConsumerState<_TransactionEditor> createState() => _TransactionEditorState();
}

class _TransactionEditorState extends ConsumerState<_TransactionEditor> {
  final title = TextEditingController(),
      amount = TextEditingController(),
      notes = TextEditingController(),
      rate = TextEditingController(text: '1'),
      received = TextEditingController(),
      interval = TextEditingController(text: '1'),
      dueDays = TextEditingController(text: '0');
  final Map<String, TextEditingController> shares = {};
  late String kind, personId, direction;
  String accountId = '',
      toAccountId = '',
      currency = 'TWD',
      category = '',
      frequency = 'monthly';
  late bool recurring;
  bool remind = false, cashLoan = false, busy = false, initialized = false;
  DateTime date = spendDay(DateTime.now());
  DateTime? due, end;
  String? error;
  SpendRow? get original => widget.entry ?? widget.debt;
  bool get editing => original != null;
  @override
  void initState() {
    super.initState();
    final row = widget.plan == null
        ? original
        : SpendRow(widget.plan!.template);
    kind = widget.debt != null ? 'debt' : row?.text('kind') ?? widget.kind;
    personId = row?.text('personId') ?? widget.personId;
    direction = row?.text('direction', widget.direction) ?? widget.direction;
    recurring = widget.plan != null || widget.recurring;
    if (row != null) {
      title.text = widget.plan?.text('title') ?? row.text('title');
      currency = row.text('currency', 'TWD');
      amount.text = amountInput(row.number('amount'), currency);
      accountId = row.text('accountId');
      toAccountId = row.text('toAccountId');
      category = row.text('category');
      notes.text = row.text('notes');
      rate.text = (row.number('rate', 1000000) / 1000000).toString();
      remind = row.flag('remind');
      cashLoan = row.flag('cashLoan');
      if (row.text('date').isNotEmpty) date = row.date('date');
      if (row.text('due').isNotEmpty) due = row.date('due');
      for (final share in row.shares) {
        shares[share.text('personId')] = TextEditingController(
          text: amountInput(share.number('amount'), currency),
        );
      }
    }
    final p = widget.plan;
    if (p != null) {
      date = p.date('start');
      end = p.text('end').isEmpty ? null : p.date('end');
      frequency = p.text('frequency');
      interval.text = '${p.number('interval', 1)}';
      dueDays.text = '${p.number('dueDays')}';
    }
  }

  @override
  void dispose() {
    for (final c in [
      title,
      amount,
      notes,
      rate,
      received,
      interval,
      dueDays,
      ...shares.values,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  void _initialize(SpendingState s) {
    if (initialized) return;
    initialized = true;
    if (accountId.isEmpty && s.accounts.isNotEmpty) {
      accountId = s.accounts.first.id;
      if (original == null && widget.plan == null) {
        currency = s.accounts.first.text('currency');
      }
    }
    if (currency != 'TWD' && original == null && widget.plan == null) {
      rate.clear();
    }
    if (personId.isEmpty && s.people.isNotEmpty) personId = s.people.first.id;
    if (category.isEmpty) {
      category =
          (kind == 'income' ? s.incomeCategories : s.expenseCategories).first;
    }
    if (widget.entry?.text('kind') == 'transfer' && toAccountId.isNotEmpty) {
      received.text = amountInput(
        widget.entry!.number('received'),
        s.account(toAccountId).text('currency'),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(spendingProvider).asData?.value;
    if (s == null) {
      return const AlertDialog(content: CircularProgressIndicator());
    }
    _initialize(s);
    final requiresAccount = kind != 'debt' || cashLoan;
    final hasCategory = ['expense', 'income', 'split'].contains(kind);
    final categories = kind == 'income'
        ? s.incomeCategories
        : s.expenseCategories;
    final accounts = {
      for (final a in s.accounts)
        a.id: '${a.text('name')} (${a.text('currency')})',
    };
    return AlertDialog(
      title: Text(
        widget.plan != null
            ? 'Edit future charges'
            : editing
            ? 'Edit ${kind == 'debt' ? 'debt' : 'transaction'}'
            : recurring
            ? 'Recurring plan'
            : 'Add transaction',
      ),
      content: SizedBox(
        width: 510,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _select(
                'Type',
                kind,
                {
                  'expense': 'Expense',
                  'income': 'Income',
                  if (!recurring) 'transfer': 'Transfer',
                  'split': 'Split expense / family subscription',
                  'debt': 'Debt',
                },
                editing || widget.plan != null
                    ? null
                    : (v) => setState(() {
                        kind = v;
                        category =
                            (v == 'income'
                                    ? s.incomeCategories
                                    : s.expenseCategories)
                                .first;
                      }),
              ),
              _field('Title', title),
              if (kind == 'debt') ...[
                _select('Person', personId, {
                  for (final p in s.people) p.id: p.text('name'),
                }, (v) => setState(() => personId = v)),
                TextButton.icon(
                  onPressed: () => _simpleEditor(context, 'person'),
                  icon: const Icon(Icons.person_add_outlined, size: 17),
                  label: const Text('Add person'),
                ),
                _select(
                  'Direction',
                  direction,
                  {'iOwe': 'I owe', 'theyOwe': 'They owe me'},
                  editing ? null : (v) => setState(() => direction = v),
                ),
                if (!editing)
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Money changes hands now'),
                    subtitle: const Text(
                      'Turn on for a cash loan. Off records an existing debt only.',
                    ),
                    value: cashLoan,
                    onChanged: (v) => setState(() => cashLoan = v),
                  ),
              ],
              if (requiresAccount) ...[
                _select(
                  'Account',
                  accountId,
                  accounts,
                  (v) => setState(() {
                    accountId = v;
                    currency = s.account(v).text('currency');
                    rate.text = currency == 'TWD' ? '1' : '';
                  }),
                ),
                if (s.accounts.isEmpty)
                  TextButton(
                    onPressed: () async {
                      await _simpleEditor(context, 'account');
                      if (mounted) setState(() => initialized = false);
                    },
                    child: const Text('Create an account first'),
                  ),
              ] else
                _select(
                  'Currency',
                  currency,
                  {for (final c in spendingCurrencies) c: c},
                  editing ? null : (v) => setState(() => currency = v),
                ),
              _field('Amount ($currency)', amount, numeric: true),
              if (requiresAccount &&
                  !['transfer', 'debt'].contains(kind) &&
                  currency != 'TWD')
                _field(
                  '1 $currency = how many TWD?',
                  rate,
                  numeric: true,
                  hint: 'Recorded rate, e.g. 0.002',
                ),
              if (kind == 'transfer') ...[
                _select(
                  'Destination account',
                  toAccountId,
                  {
                    for (final a in s.accounts.where((a) => a.id != accountId))
                      a.id: '${a.text('name')} (${a.text('currency')})',
                  },
                  (v) => setState(() => toAccountId = v),
                ),
                if (toAccountId.isNotEmpty &&
                    s.accounts.any((a) => a.id == toAccountId) &&
                    s.account(toAccountId).text('currency') != currency)
                  _field(
                    'Amount received (${s.account(toAccountId).text('currency')})',
                    received,
                    numeric: true,
                  ),
                const Text(
                  'Transfer fees can be recorded as a separate expense.',
                ),
              ],
              if (hasCategory) ...[
                _select('Category', category, {
                  for (final c in categories) c: c,
                }, (v) => setState(() => category = v)),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _simpleEditor(context, 'category'),
                    child: const Text('New category'),
                  ),
                ),
              ],
              if (kind == 'split') ...[
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: Text(
                    'Their shares',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                const Text(
                  'Enter each person’s amount. The remainder is your expense.',
                ),
                for (final p in s.people)
                  Row(
                    children: [
                      Checkbox(
                        value: shares.containsKey(p.id),
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            shares[p.id] = TextEditingController();
                          } else {
                            shares.remove(p.id)?.dispose();
                          }
                        }),
                      ),
                      Expanded(child: Text(p.text('name'))),
                      if (shares.containsKey(p.id))
                        SizedBox(
                          width: 110,
                          child: _field(currency, shares[p.id]!, numeric: true),
                        ),
                    ],
                  ),
                TextButton.icon(
                  onPressed: () => _simpleEditor(context, 'person'),
                  icon: const Icon(Icons.person_add_outlined, size: 16),
                  label: const Text('Add person'),
                ),
              ],
              if (!editing && widget.plan == null && kind != 'transfer')
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Repeat automatically'),
                  value: recurring,
                  onChanged: (v) => setState(() => recurring = v),
                ),
              _dateButton(
                context,
                recurring ? 'Start' : 'Date',
                date,
                (v) => setState(() => date = v!),
                enabled: widget.plan == null,
              ),
              if (recurring) ...[
                _select(
                  'Frequency',
                  frequency,
                  {
                    'weekly': 'Weekly',
                    'monthly': 'Monthly',
                    'yearly': 'Yearly',
                  },
                  widget.plan == null
                      ? (v) => setState(() => frequency = v)
                      : null,
                ),
                _field(
                  'Repeat every (interval)',
                  interval,
                  numeric: true,
                  enabled: widget.plan == null,
                ),
                _dateButton(
                  context,
                  'End',
                  end,
                  (v) => setState(() => end = v),
                  optional: true,
                ),
                if (['debt', 'split'].contains(kind))
                  _field(
                    'Debt due after how many days?',
                    dueDays,
                    numeric: true,
                  ),
                const Text(
                  'Past start dates create each missed charge. Pausing skips paused periods.',
                ),
              ] else if (['debt', 'split'].contains(kind))
                _dateButton(
                  context,
                  'Due',
                  due,
                  (v) => setState(() => due = v),
                  optional: true,
                ),
              if (recurring || ['debt', 'split'].contains(kind))
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Remind me in Tasks'),
                  subtitle: const Text('Reminder at 9:00 AM on the due date.'),
                  value: remind,
                  onChanged: (v) => setState(() => remind = v),
                ),
              _field('Notes (optional)', notes, lines: 3),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    error!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy ? null : () => _save(s),
          child: Text(busy ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _save(SpendingState s) async {
    setState(() {
      error = null;
      busy = true;
    });
    try {
      final repo = ref.read(spendingRepositoryProvider);
      final value = parseAmount(amount.text, currency);
      final splitShares = [
        for (final e
            in (kind == 'split'
                ? shares.entries
                : <MapEntry<String, TextEditingController>>[]))
          {'personId': e.key, 'amount': parseAmount(e.value.text, currency)},
      ];
      final shared = splitShares.fold<int>(
        0,
        (sum, s) => sum + (s['amount'] as int),
      );
      if (!recurring && date.isAfter(spendDay(DateTime.now()))) {
        throw const FormatException(
          'Use a recurring plan for future entries, or choose today or an earlier date.',
        );
      }
      if (remind && !recurring && due == null) {
        throw const FormatException('Choose a due date for the reminder.');
      }
      final row = SpendRow({
        ...?original?.data,
        'id': original?.id ?? repo.newId(),
        'kind': kind,
        'title': title.text.trim(),
        'amount': value,
        'accountId': accountId,
        'currency': currency,
        'category': category,
        'rate': currency == 'TWD' || kind == 'debt' || kind == 'transfer'
            ? 1000000
            : parseRate(rate.text),
        'date': dateKey(date),
        'notes': notes.text.trim(),
        'personId': personId,
        'direction': direction,
        'due': due == null ? '' : dateKey(due!),
        'cashLoan': cashLoan,
        'remind': remind,
        if (kind == 'transfer') 'toAccountId': toAccountId,
        if (kind == 'transfer')
          'received': s.account(toAccountId).text('currency') == currency
              ? value
              : parseAmount(
                  received.text,
                  s.account(toAccountId).text('currency'),
                ),
        if (kind == 'split') 'ownAmount': value - shared,
        if (kind == 'split') 'shares': splitShares,
      });
      await repo.change((engine) {
        if (widget.debt != null) {
          engine.editDebt(row);
        } else if (widget.entry != null) {
          engine.editEntry(row);
        } else if (recurring) {
          final every = int.tryParse(interval.text),
              days = int.tryParse(dueDays.text);
          if (every == null || days == null) {
            throw const FormatException(
              'Interval and due days must be whole numbers.',
            );
          }
          engine.savePlan(
            SpendRow({
              'id': widget.plan?.id ?? repo.newId(),
              'title': title.text.trim(),
              'start': dateKey(date),
              'end': end == null ? '' : dateKey(end!),
              'frequency': frequency,
              'interval': every,
              'dueDays': days,
              'status': 'active',
              'next': 0,
              'template': row.data,
            }),
          );
        } else {
          engine.post(row);
        }
      });
      if (remind) {
        try {
          final granted = await ref
              .read(taskNotificationServiceProvider)
              .gateway
              .permission(request: true);
          if (!granted && mounted) {
            _message(
              context,
              'Saved. Enable notifications to receive reminders.',
            );
          }
          ref.invalidate(taskNotificationSyncProvider);
        } catch (_) {
          if (mounted) {
            _message(
              context,
              'Saved. Reminder is in Tasks; system notifications are unavailable.',
            );
          }
        }
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = _error(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _SimpleEditor extends ConsumerStatefulWidget {
  const _SimpleEditor({required this.mode, this.initial, this.month});
  final String mode;
  final SpendRow? initial;
  final String? month;
  @override
  ConsumerState<_SimpleEditor> createState() => _SimpleEditorState();
}

class _SimpleEditorState extends ConsumerState<_SimpleEditor> {
  final name = TextEditingController(), amount = TextEditingController();
  String currency = 'TWD',
      type = 'Cash',
      accountId = '',
      category = '',
      categoryKind = 'expense';
  DateTime date = spendDay(DateTime.now());
  bool busy = false, initialized = false;
  String? error;
  @override
  void initState() {
    super.initState();
    final r = widget.initial;
    if (r != null) {
      name.text = r.text('name');
      currency = r.text('currency', 'TWD');
      type = r.text('type', 'Cash');
      category = r.text('category');
      if (widget.mode == 'account') {
        amount.text = amountInput(r.number('opening'), currency);
      }
      if (widget.mode == 'budget') {
        amount.text = amountInput(r.number('amount'), 'TWD');
      }
    } else if (widget.mode == 'account') {
      amount.text = '0';
    }
  }

  @override
  void dispose() {
    name.dispose();
    amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(spendingProvider).asData?.value;
    if (s == null) {
      return const AlertDialog(content: CircularProgressIndicator());
    }
    if (!initialized) {
      initialized = true;
      category = category.isEmpty ? s.expenseCategories.first : category;
      if (widget.mode == 'repay') {
        amount.text = amountInput(s.remaining(widget.initial!), currency);
        accountId =
            s.accounts
                .where((a) => a.text('currency') == currency)
                .firstOrNull
                ?.id ??
            '';
      }
      if (widget.mode == 'refund') {
        final e = widget.initial!;
        amount.text = amountInput(
          (e.text('kind') == 'split'
                  ? e.number('ownAmount')
                  : e.number('amount')) -
              s.refunded(e.id),
          currency,
        );
      }
    }
    return AlertDialog(
      title: Text(switch (widget.mode) {
        'account' => widget.initial == null ? 'Add account' : 'Edit account',
        'person' => widget.initial == null ? 'Add person' : 'Edit person',
        'budget' => 'Budget · ${widget.month}',
        'category' => 'New category',
        'repay' => 'Record repayment',
        _ => 'Record refund',
      }),
      content: SizedBox(
        width: 420,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (['account', 'person', 'category'].contains(widget.mode))
                _field('Name', name),
              if (widget.mode == 'account') ...[
                _select('Type', type, {
                  for (final t in ['Cash', 'Bank', 'E-wallet', 'Other']) t: t,
                }, (v) => setState(() => type = v)),
                _select(
                  'Currency',
                  currency,
                  {for (final c in spendingCurrencies) c: c},
                  widget.initial == null
                      ? (v) => setState(() => currency = v)
                      : null,
                ),
                _field('Opening balance ($currency)', amount, numeric: true),
                const Text(
                  'Current balance = opening balance + recorded transactions.',
                ),
              ],
              if (widget.mode == 'budget') ...[
                _select('Category', category, {
                  for (final c in s.expenseCategories) c: c,
                }, (v) => setState(() => category = v)),
                _field('Monthly limit (TWD)', amount, numeric: true),
              ],
              if (widget.mode == 'category')
                _select('For', categoryKind, {
                  'expense': 'Expenses',
                  'income': 'Income',
                }, (v) => setState(() => categoryKind = v)),
              if (widget.mode == 'repay') ...[
                _select('Payment account', accountId, {
                  for (final a in s.accounts.where(
                    (a) => a.text('currency') == currency,
                  ))
                    a.id: a.text('name'),
                }, (v) => setState(() => accountId = v)),
                if (!s.accounts.any((a) => a.text('currency') == currency))
                  TextButton(
                    onPressed: () async {
                      await _simpleEditor(context, 'account');
                      if (mounted) setState(() => initialized = false);
                    },
                    child: Text('Add a $currency account'),
                  ),
                const Text(
                  'The amount defaults to the full remaining balance. Enter less for a partial payment.',
                ),
              ],
              if (['repay', 'refund'].contains(widget.mode)) ...[
                _field('Amount ($currency)', amount, numeric: true),
                _dateButton(
                  context,
                  'Date',
                  date,
                  (v) => setState(() => date = v!),
                ),
              ],
              if (widget.mode == 'refund')
                const Text(
                  'Refunds return to the original account. For a split bill, this refunds only your own share.',
                ),
              if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: busy ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: busy ? null : _save,
          child: Text(busy ? 'Saving…' : 'Save'),
        ),
      ],
    );
  }

  Future<void> _save() async {
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final repo = ref.read(spendingRepositoryProvider);
      await repo.change((e) {
        final id = widget.initial?.id ?? repo.newId();
        switch (widget.mode) {
          case 'account':
            e.account(
              SpendRow({
                'id': id,
                'name': name.text.trim(),
                'currency': currency,
                'opening': parseAmount(
                  amount.text,
                  currency,
                  allowZero: true,
                  signed: true,
                ),
                'type': type,
              }),
            );
          case 'person':
            e.person(SpendRow({'id': id, 'name': name.text.trim()}));
          case 'category':
            e.category(name.text, categoryKind == 'income');
          case 'budget':
            e.budget(
              SpendRow({
                'id': id,
                'month': widget.month,
                'category': category,
                'amount': parseAmount(amount.text, 'TWD'),
              }),
            );
          case 'refund':
            if (date.isAfter(spendDay(DateTime.now()))) {
              throw const FormatException('Choose today or an earlier date.');
            }
            e.refund(id, parseAmount(amount.text, currency), date);
          case 'repay':
            if (date.isAfter(spendDay(DateTime.now()))) {
              throw const FormatException('Choose today or an earlier date.');
            }
            e.repay(id, accountId, parseAmount(amount.text, currency), date);
        }
      });
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => error = _error(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }
}

class _FilterDialog extends StatefulWidget {
  const _FilterDialog({required this.s, required this.initial});
  final SpendingState s;
  final Map<String, dynamic> initial;
  @override
  State<_FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<_FilterDialog> {
  late Map<String, dynamic> f;
  late TextEditingController min, max;
  String? error;
  @override
  void initState() {
    super.initState();
    f = {...widget.initial};
    min = TextEditingController(text: f['min']);
    max = TextEditingController(text: f['max']);
  }

  @override
  void dispose() {
    min.dispose();
    max.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Filter transactions'),
    content: SizedBox(
      width: 420,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _select('Type', f['kind'], {
              '': 'All types',
              for (final k in [
                'expense',
                'income',
                'transfer',
                'split',
                'refund',
                'lending',
                'borrowing',
                'repaymentIn',
                'repaymentOut',
              ])
                k: k,
            }, (v) => setState(() => f['kind'] = v)),
            _select('Account', f['account'], {
              '': 'All accounts',
              for (final a in widget.s.accounts) a.id: a.text('name'),
            }, (v) => setState(() => f['account'] = v)),
            _select('Category', f['category'], {
              '': 'All categories',
              for (final c in {
                ...widget.s.expenseCategories,
                ...widget.s.incomeCategories,
              })
                c: c,
            }, (v) => setState(() => f['category'] = v)),
            _select('Currency', f['currency'], {
              '': 'All currencies',
              for (final c in spendingCurrencies) c: c,
            }, (v) => setState(() => f['currency'] = v)),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Search across all months'),
              value: f['all'],
              onChanged: (v) => setState(() => f['all'] = v),
            ),
            _dateButton(
              context,
              'From',
              f['from'],
              (v) => setState(() {
                f['from'] = v;
                if (v != null) f['all'] = true;
              }),
              optional: true,
            ),
            _dateButton(
              context,
              'Until',
              f['until'],
              (v) => setState(() {
                f['until'] = v;
                if (v != null) f['all'] = true;
              }),
              optional: true,
            ),
            _field('Minimum (original currency)', min, numeric: true),
            _field('Maximum (original currency)', max, numeric: true),
            if (error != null)
              Text(
                error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context, {
          'kind': '',
          'account': '',
          'category': '',
          'currency': '',
          'min': '',
          'max': '',
          'all': false,
          'from': null,
          'until': null,
        }),
        child: const Text('Reset'),
      ),
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      FilledButton(
        onPressed: () {
          final a = min.text.trim(), b = max.text.trim();
          if ([a, b].any(
                (v) =>
                    v.isNotEmpty &&
                    (double.tryParse(v) == null ||
                        !double.parse(v).isFinite ||
                        double.parse(v) < 0),
              ) ||
              a.isNotEmpty &&
                  b.isNotEmpty &&
                  double.parse(a) > double.parse(b) ||
              f['from'] != null &&
                  f['until'] != null &&
                  (f['from'] as DateTime).isAfter(f['until'])) {
            setState(() => error = 'Enter a valid amount and date range.');
            return;
          }
          Navigator.pop(context, {...f, 'min': a, 'max': b});
        },
        child: const Text('Apply'),
      ),
    ],
  );
}
