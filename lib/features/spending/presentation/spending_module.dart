import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../tasks/providers/task_providers.dart';
import '../domain/spending_models.dart';
import '../domain/spending_engine.dart';
import '../providers/spending_providers.dart';
part 'spending_editors.dart';

const _accent = Color(0xFF4779A1);
const _spendingSections = [
  ('Overview', Icons.space_dashboard_outlined),
  ('Transactions', Icons.receipt_long_outlined),
  ('Accounts', Icons.account_balance_wallet_outlined),
  ('Budgets', Icons.pie_chart_outline),
  ('Recurring', Icons.repeat),
  ('Debts', Icons.people_outline),
];
Future<void> openDebtTracker(
  BuildContext context, {
  String? personId,
  String direction = 'iOwe',
}) => showDialog<void>(
  context: context,
  builder: (_) => _DebtTrackerDialog(personId: personId, direction: direction),
);

void openFullSpending(BuildContext context, {String initialTab = 'Overview'}) =>
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Spending')),
          body: SafeArea(
            child: SpendingModule(showTitle: false, initialTab: initialTab),
          ),
        ),
      ),
    );
String _error(Object e) => e.toString().replaceFirst(
  RegExp(r'^(FormatException|Bad state|Invalid argument\(s\)): '),
  '',
);
void _message(BuildContext context, String text) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
Future<void> _change(
  BuildContext context,
  WidgetRef ref,
  void Function(SpendingEngine) action,
) async {
  try {
    await ref.read(spendingRepositoryProvider).change(action);
  } catch (e) {
    if (context.mounted) _message(context, _error(e));
  }
}

Future<bool> _confirm(BuildContext context, String title, String text) async =>
    await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(title),
        content: Text(text),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    ) ??
    false;

enum _SpendingCardView { overview, debts }

class SpendingDashboardCard extends ConsumerStatefulWidget {
  const SpendingDashboardCard({super.key});
  @override
  ConsumerState<SpendingDashboardCard> createState() =>
      _SpendingDashboardCardState();
}

class _SpendingDashboardCardState extends ConsumerState<SpendingDashboardCard> {
  _SpendingCardView view = _SpendingCardView.overview;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final spending = ref.watch(spendingProvider);
    final state = spending.asData?.value;
    final hasOwedToMe =
        state?.debts.any(
          (debt) =>
              debt.text('direction') == 'theyOwe' && state.remaining(debt) > 0,
        ) ??
        false;
    final hasIOwe =
        state?.debts.any(
          (debt) =>
              debt.text('direction') == 'iOwe' && state.remaining(debt) > 0,
        ) ??
        false;
    final buttonStyle = IconButton.styleFrom(
      minimumSize: const Size(34, 34),
      maximumSize: const Size(34, 34),
      padding: EdgeInsets.zero,
    );
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: (MediaQuery.textScalerOf(context).scale(14) * 1.5 + 12)
                .clamp(40, double.infinity),
            child: Padding(
              padding: const EdgeInsets.only(left: 10, right: 4),
              child: Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _accent,
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Spending',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  PopupMenuButton<_SpendingCardView>(
                    tooltip: 'Change spending view',
                    initialValue: view,
                    onSelected: (selected) => setState(() => view = selected),
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: _SpendingCardView.overview,
                        child: Text('Overview'),
                      ),
                      PopupMenuItem(
                        value: _SpendingCardView.debts,
                        child: Text('Debts'),
                      ),
                    ],
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            view == _SpendingCardView.overview
                                ? 'Overview'
                                : 'Debts',
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Icon(Icons.arrow_drop_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: view == _SpendingCardView.debts
                        ? 'Add debt'
                        : 'Add transaction',
                    style: buttonStyle,
                    onPressed: () => _openEditor(
                      context,
                      kind: view == _SpendingCardView.debts
                          ? 'debt'
                          : 'expense',
                    ),
                    icon: const Icon(Icons.add, size: 20),
                  ),
                  IconButton(
                    tooltip: view == _SpendingCardView.debts
                        ? 'Open debt tracker'
                        : 'Expand spending',
                    style: buttonStyle,
                    onPressed: () => view == _SpendingCardView.debts
                        ? openDebtTracker(
                            context,
                            direction: hasOwedToMe && !hasIOwe
                                ? 'theyOwe'
                                : 'iOwe',
                          )
                        : openFullSpending(context),
                    icon: const Icon(Icons.open_in_full, size: 18),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: spending.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => _Failure(
                error: e,
                retry: () => ref.invalidate(spendingProvider),
              ),
              data: (s) => view == _SpendingCardView.debts
                  ? _SpendingDashboardDebts(s: s)
                  : _SpendingDashboardBody(s: s),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpendingDashboardBody extends StatelessWidget {
  const _SpendingDashboardBody({required this.s});
  final SpendingState s;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final theme = Theme.of(context);
      final month = DateTime.now();
      final income = s.income(month);
      final expenses = s.expenses(month);
      final balances = <String, int>{};
      for (final account in s.accounts) {
        final currency = account.text('currency');
        balances[currency] = (balances[currency] ?? 0) + s.balance(account.id);
      }
      final currencies = balances.keys.toList()
        ..sort(
          (a, b) => a == 'TWD'
              ? -1
              : b == 'TWD'
              ? 1
              : a.compareTo(b),
        );
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final tiny = bounds.maxHeight < (largeText ? 150 : 115);
      final balanceCount = currencies.length.clamp(
        0,
        tiny
            ? 1
            : bounds.maxHeight >= 360
            ? 3
            : 2,
      );
      final showMonthly =
          bounds.maxHeight >=
          (largeText ? 265 : 160) +
              (currencies.length > 1 ? 35 : 0) +
              (currencies.length > balanceCount ? 30 : 0);
      final recentCount = bounds.maxHeight < (largeText ? 280 : 220)
          ? 0
          : bounds.maxHeight < (largeText ? 400 : 250)
          ? 1
          : bounds.maxHeight < (largeText ? 500 : 330)
          ? 2
          : 3;
      final recent = _sorted(s.entries).take(recentCount);

      return Container(
        width: bounds.maxWidth,
        padding: EdgeInsets.fromLTRB(12, tiny ? 4 : 9, 12, tiny ? 4 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current balance',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.titleSmall,
            ),
            SizedBox(height: tiny ? 2 : 6),
            if (currencies.isEmpty)
              Text('No accounts yet.', style: theme.textTheme.bodySmall)
            else
              for (final currency in currencies.take(balanceCount))
                InkWell(
                  onTap: () =>
                      openFullSpending(context, initialTab: 'Accounts'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            s.accounts.length == 1
                                ? s.accounts.single.text('name')
                                : '$currency accounts',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(money(balances[currency]!, currency)),
                      ],
                    ),
                  ),
                ),
            if (!tiny && currencies.length > balanceCount)
              InkWell(
                onTap: () => openFullSpending(context, initialTab: 'Accounts'),
                child: Text(
                  '+${currencies.length - balanceCount} more currencies in Accounts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (currencies.isEmpty && bounds.maxHeight >= 140) ...[
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () => _simpleEditor(context, 'account'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Set up your first account'),
              ),
            ],
            if (showMonthly && currencies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'This month',
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Text(monthKey(month), style: theme.textTheme.labelSmall),
                ],
              ),
              const SizedBox(height: 4),
              if (largeText) ...[
                Text(
                  'Income ${money(income, 'TWD')}  ·  Expenses ${money(expenses, 'TWD')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Net savings ${money(income - expenses, 'TWD')}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DashboardAmount(label: 'Income', amount: income),
                    _DashboardAmount(label: 'Expenses', amount: expenses),
                    _DashboardAmount(
                      label: 'Net savings',
                      amount: income - expenses,
                    ),
                  ],
                ),
            ],
            if (showMonthly &&
                bounds.maxHeight >= 195 &&
                s.entries.isEmpty &&
                currencies.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'No transactions yet.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else if (recentCount > 0 && s.entries.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Recent', style: theme.textTheme.labelMedium),
              for (final e in recent)
                InkWell(
                  onTap: () =>
                      openFullSpending(context, initialTab: 'Transactions'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            e.text('title'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(money(e.number('amount'), e.text('currency'))),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      );
    },
  );
}

class _SpendingDashboardDebts extends StatelessWidget {
  const _SpendingDashboardDebts({required this.s});
  final SpendingState s;

  String total(Iterable<SpendRow> debts, String direction) {
    final amounts = <String, int>{};
    for (final debt in debts.where((d) => d.text('direction') == direction)) {
      final remaining = s.remaining(debt);
      if (remaining <= 0) continue;
      final currency = debt.text('currency');
      amounts[currency] = (amounts[currency] ?? 0) + remaining;
    }
    final currencies = amounts.keys.toList()..sort();
    return currencies.isEmpty
        ? '—'
        : currencies.map((c) => money(amounts[c]!, c)).join(' · ');
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, bounds) {
      final theme = Theme.of(context);
      final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.4;
      final tiny = bounds.maxHeight < (largeText ? 150 : 110);
      final people = s.people
          .where(
            (p) => s.debts.any(
              (d) => d.text('personId') == p.id && s.remaining(d) > 0,
            ),
          )
          .toList();
      final visiblePeople = largeText || bounds.maxHeight < 200
          ? 0
          : ((bounds.maxHeight - 135) / 55).floor().clamp(0, 4);
      Widget directionRow(String label, String direction) => Row(
        children: [
          Expanded(
            child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              total(s.debts, direction),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
            ),
          ),
        ],
      );
      return Container(
        width: bounds.maxWidth,
        padding: EdgeInsets.fromLTRB(12, tiny ? 4 : 9, 12, tiny ? 4 : 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!tiny) ...[
              Text('Outstanding debts', style: theme.textTheme.titleSmall),
              const SizedBox(height: 7),
            ],
            directionRow('I owe', 'iOwe'),
            directionRow('They owe me', 'theyOwe'),
            if (people.isEmpty && bounds.maxHeight >= 160) ...[
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => _openEditor(context, kind: 'debt'),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add a debt'),
              ),
            ],
            if (visiblePeople > 0 && people.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text('People', style: theme.textTheme.labelMedium),
              for (final person in people.take(visiblePeople))
                InkWell(
                  onTap: () => openDebtTracker(
                    context,
                    personId: person.id,
                    direction:
                        s.debts.any(
                          (d) =>
                              d.text('personId') == person.id &&
                              d.text('direction') == 'theyOwe' &&
                              s.remaining(d) > 0,
                        )
                        ? 'theyOwe'
                        : 'iOwe',
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          person.text('name'),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'I owe ${total(s.debts.where((d) => d.text('personId') == person.id), 'iOwe')}  ·  They owe me ${total(s.debts.where((d) => d.text('personId') == person.id), 'theyOwe')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ),
              if (people.length > visiblePeople)
                Text(
                  '+${people.length - visiblePeople} more people in Debt Tracker',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
            ],
          ],
        ),
      );
    },
  );
}

String _remainingByCurrency(SpendingState state, Iterable<SpendRow> debts) {
  final amounts = <String, int>{};
  for (final debt in debts) {
    final remaining = state.remaining(debt);
    if (remaining <= 0) continue;
    final currency = debt.text('currency');
    amounts[currency] = (amounts[currency] ?? 0) + remaining;
  }
  final currencies = amounts.keys.toList()..sort();
  return currencies.isEmpty
      ? '—'
      : currencies.map((c) => money(amounts[c]!, c)).join(' · ');
}

class _DebtTrackerDialog extends ConsumerStatefulWidget {
  const _DebtTrackerDialog({this.personId, required this.direction});
  final String? personId;
  final String direction;

  @override
  ConsumerState<_DebtTrackerDialog> createState() => _DebtTrackerDialogState();
}

class _DebtTrackerDialogState extends ConsumerState<_DebtTrackerDialog>
    with SingleTickerProviderStateMixin {
  late final TabController controller;
  bool includeSettled = false;

  @override
  void initState() {
    super.initState();
    controller = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.direction == 'theyOwe' ? 1 : 0,
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final theme = Theme.of(context);
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: SizedBox(
        width: (size.width - 32).clamp(0.0, 900.0),
        height: (size.height - 32).clamp(0.0, 680.0),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
              child: Row(
                children: [
                  const Icon(Icons.people_outline, color: _accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Debt Tracker',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                  IconButton(
                    tooltip: 'Add person',
                    onPressed: () => _simpleEditor(context, 'person'),
                    icon: const Icon(Icons.person_add_outlined),
                  ),
                  IconButton(
                    tooltip: 'Close debt tracker',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            TabBar(
              controller: controller,
              tabs: const [
                Tab(text: 'I owe'),
                Tab(text: 'They owe me'),
              ],
            ),
            Expanded(
              child: ref
                  .watch(spendingProvider)
                  .when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, _) => _Failure(
                      error: error,
                      retry: () => ref.invalidate(spendingProvider),
                    ),
                    data: (state) => TabBarView(
                      controller: controller,
                      children: [
                        _directionPage(state, 'iOwe'),
                        _directionPage(state, 'theyOwe'),
                      ],
                    ),
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _directionPage(SpendingState state, String direction) {
    final all = state.debts.where((d) => d.text('direction') == direction);
    final visible = all.where((d) => includeSettled || state.remaining(d) > 0);
    final people =
        state.people
            .where(
              (person) => visible.any((d) => d.text('personId') == person.id),
            )
            .toList()
          ..sort((a, b) {
            if (a.id == b.id) return 0;
            if (a.id == widget.personId) return -1;
            if (b.id == widget.personId) return 1;
            return a.text('name').compareTo(b.text('name'));
          });
    final theme = Theme.of(context);
    return ListView(
      key: PageStorageKey('debt-direction:$direction'),
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 4,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            Text(
              'Outstanding: ${_remainingByCurrency(state, all)}',
              style: theme.textTheme.titleSmall,
            ),
            FilterChip(
              label: const Text('Include settled'),
              selected: includeSettled,
              onSelected: (value) => setState(() => includeSettled = value),
            ),
            TextButton.icon(
              onPressed: () => _openEditor(
                context,
                kind: 'debt',
                personId: widget.personId ?? '',
                direction: direction,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add debt'),
            ),
          ],
        ),
        if (people.isEmpty)
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text('No debts in this direction.'),
          ),
        for (final person in people)
          Card(
            child: ExpansionTile(
              key: PageStorageKey('debt-person:$direction:${person.id}'),
              initiallyExpanded: person.id == widget.personId,
              leading: const Icon(Icons.person_outline, color: _accent),
              title: Text(person.text('name')),
              subtitle: Text(
                _remainingByCurrency(
                  state,
                  visible.where((d) => d.text('personId') == person.id),
                ),
              ),
              children: [
                for (final debt in _sorted(
                  visible
                      .where((d) => d.text('personId') == person.id)
                      .toList(),
                ))
                  ListTile(
                    dense: true,
                    leading: Icon(
                      state.remaining(debt) == 0
                          ? Icons.check_circle_outline
                          : debt.text('due').isNotEmpty &&
                                debt
                                    .date('due')
                                    .isBefore(spendDay(DateTime.now()))
                          ? Icons.warning_amber_rounded
                          : Icons.receipt_long_outlined,
                      color: state.remaining(debt) == 0
                          ? Colors.green
                          : debt.text('due').isNotEmpty &&
                                debt
                                    .date('due')
                                    .isBefore(spendDay(DateTime.now()))
                          ? theme.colorScheme.error
                          : _accent,
                    ),
                    title: Text(debt.text('title')),
                    subtitle: Text(
                      '${money(state.remaining(debt), debt.text('currency'))} remaining${debt.text('due').isEmpty ? '' : ' · due ${debt.text('due')}'}',
                    ),
                    onTap: () => _showDebtDetails(context, ref, state, debt),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

Future<void> _showDebtDetails(
  BuildContext context,
  WidgetRef ref,
  SpendingState state,
  SpendRow debt,
) async {
  final action = await showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      scrollable: true,
      title: Text(debt.text('title')),
      content: SizedBox(
        width: 440,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detail(
                'Person',
                state.person(debt.text('personId')).text('name'),
              ),
              _detail(
                'Total',
                money(debt.number('amount'), debt.text('currency')),
              ),
              _detail(
                'Paid',
                money(state.paid(debt.id), debt.text('currency')),
              ),
              _detail(
                'Remaining',
                money(state.remaining(debt), debt.text('currency')),
              ),
              if (debt.text('due').isNotEmpty) _detail('Due', debt.text('due')),
              if (debt.text('notes').isNotEmpty)
                _detail('Notes', debt.text('notes')),
              if (debt.flag('remind')) const Text('Reminder managed in Tasks.'),
              const Divider(),
              const Text('Repayment history'),
              for (final entry in _sorted(state.entries).where(
                (e) =>
                    e.text('debtId') == debt.id &&
                    e.text('kind').startsWith('repayment'),
              ))
                ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    money(entry.number('amount'), entry.text('currency')),
                  ),
                  subtitle: Text(entry.text('date')),
                  trailing: IconButton(
                    tooltip: 'Undo repayment',
                    onPressed: () =>
                        Navigator.pop(dialogContext, 'undo:${entry.id}'),
                    icon: const Icon(Icons.undo),
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, 'delete'),
          child: const Text('Delete'),
        ),
        if (debt.text('originId').isEmpty && debt.text('planId').isEmpty)
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, 'edit'),
            child: const Text('Edit'),
          ),
        if (state.remaining(debt) > 0)
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, 'repay'),
            child: const Text('Record payment'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('Close'),
        ),
      ],
    ),
  );
  if (!context.mounted) return;
  if (action == 'edit') _openEditor(context, debt: debt);
  if (action == 'repay') _simpleEditor(context, 'repay', initial: debt);
  if (action == 'delete' &&
      await _confirm(
        context,
        'Delete debt?',
        'Remove this debt permanently?',
      )) {
    if (context.mounted) {
      await _change(context, ref, (engine) => engine.deleteDebt(debt.id));
    }
  }
  if (!context.mounted) return;
  if (action != null &&
      action.startsWith('undo:') &&
      await _confirm(context, 'Undo repayment?', 'Remove this repayment?')) {
    if (context.mounted) {
      await _change(
        context,
        ref,
        (engine) => engine.deleteEntry(action.substring(5)),
      );
    }
  }
}

class _DashboardAmount extends StatelessWidget {
  const _DashboardAmount({required this.label, required this.amount});
  final String label;
  final int amount;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelSmall),
        Text(
          money(amount, 'TWD'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

List<SpendRow> _sorted(List<SpendRow> rows) =>
    [...rows]..sort((a, b) => b.text('date').compareTo(a.text('date')));

class SpendingModule extends ConsumerStatefulWidget {
  const SpendingModule({
    this.showTitle = true,
    this.initialTab = 'Overview',
    super.key,
  });
  final bool showTitle;
  final String initialTab;
  @override
  ConsumerState<SpendingModule> createState() => _SpendingModuleState();
}

class _SpendingModuleState extends ConsumerState<SpendingModule>
    with WidgetsBindingObserver {
  late String tab;
  String query = '', kind = '', accountId = '', category = '', currency = '';
  String minimum = '', maximum = '';
  DateTime month = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime? from, until;
  bool allDates = false, showPaid = false;
  final search = TextEditingController();
  @override
  void initState() {
    super.initState();
    tab = widget.initialTab;
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    search.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) ref.invalidate(spendingProvider);
  }

  String _primaryLabel(SpendingState state) {
    if (['Overview', 'Transactions'].contains(tab) && state.accounts.isEmpty) {
      return 'Add account';
    }
    if (tab == 'Debts' && state.people.isEmpty) return 'Add person';
    return switch (tab) {
      'Accounts' => 'Add account',
      'Budgets' => 'Set budget',
      'Recurring' => 'Add plan',
      'Debts' => 'Add debt',
      _ => 'Add transaction',
    };
  }

  void _primaryAction(SpendingState state) {
    if (['Overview', 'Transactions'].contains(tab) && state.accounts.isEmpty) {
      _simpleEditor(context, 'account');
      return;
    }
    if (tab == 'Debts' && state.people.isEmpty) {
      _simpleEditor(context, 'person');
      return;
    }
    switch (tab) {
      case 'Accounts':
        _simpleEditor(context, 'account');
      case 'Budgets':
        _simpleEditor(context, 'budget', month: monthKey(month));
      case 'Recurring':
        _openEditor(context, recurring: true);
      case 'Debts':
        _openEditor(context, kind: 'debt');
      default:
        _openEditor(context);
    }
  }

  void _moreAction(String action, SpendingState state) {
    switch (action) {
      case 'income':
        _openEditor(context, kind: 'income');
      case 'split':
        _openEditor(context, kind: 'split');
      case 'transfer':
        _openEditor(context, kind: 'transfer');
      case 'person':
        _simpleEditor(context, 'person');
      case 'category':
        _simpleEditor(context, 'category');
      case 'export':
        _export(state);
    }
  }

  List<PopupMenuEntry<String>> _moreItems() => [
    if (tab == 'Overview' || tab == 'Transactions') ...[
      const PopupMenuItem(value: 'income', child: Text('Add income')),
      const PopupMenuItem(value: 'split', child: Text('Split expense')),
      const PopupMenuItem(
        value: 'transfer',
        child: Text('Transfer between accounts'),
      ),
      const PopupMenuItem(value: 'category', child: Text('Manage categories')),
    ],
    if (tab == 'Accounts')
      const PopupMenuItem(
        value: 'transfer',
        child: Text('Transfer between accounts'),
      ),
    if (tab == 'Budgets')
      const PopupMenuItem(value: 'category', child: Text('Manage categories')),
    if (tab == 'Debts')
      const PopupMenuItem(value: 'person', child: Text('Add person')),
    const PopupMenuItem(
      value: 'export',
      child: Text('Export transactions CSV'),
    ),
  ];

  Widget _periodBar() => Padding(
    padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
    child: Row(
      children: [
        IconButton(
          tooltip: 'Previous month',
          onPressed: () =>
              setState(() => month = DateTime(month.year, month.month - 1)),
          icon: const Icon(Icons.chevron_left),
        ),
        TextButton(
          onPressed: () async {
            final selected = await showDatePicker(
              context: context,
              initialDate: month,
              firstDate: DateTime(2000),
              lastDate: DateTime(2200),
            );
            if (selected != null && mounted) {
              setState(() => month = DateTime(selected.year, selected.month));
            }
          },
          child: Text(monthKey(month)),
        ),
        IconButton(
          tooltip: 'Next month',
          onPressed: () =>
              setState(() => month = DateTime(month.year, month.month + 1)),
          icon: const Icon(Icons.chevron_right),
        ),
        const Spacer(),
        if (monthKey(month) != monthKey(DateTime.now()))
          TextButton(
            onPressed: () => setState(
              () => month = DateTime(DateTime.now().year, DateTime.now().month),
            ),
            child: const Text('This month'),
          ),
      ],
    ),
  );

  Widget _page(SpendingState state) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        child: Row(
          children: [
            Expanded(
              child: Text(
                widget.showTitle ? 'Spending · $tab' : tab,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            PopupMenuButton<String>(
              tooltip: 'More spending actions',
              onSelected: (action) => _moreAction(action, state),
              itemBuilder: (_) => _moreItems(),
              icon: const Icon(Icons.more_horiz),
            ),
            if (MediaQuery.sizeOf(context).width < 520 ||
                MediaQuery.textScalerOf(context).scale(1) > 1.4)
              IconButton.filled(
                tooltip: _primaryLabel(state),
                onPressed: () => _primaryAction(state),
                icon: const Icon(Icons.add),
              )
            else
              FilledButton.icon(
                onPressed: () => _primaryAction(state),
                icon: const Icon(Icons.add, size: 18),
                label: Text(_primaryLabel(state)),
              ),
          ],
        ),
      ),
      if (['Overview', 'Transactions', 'Budgets'].contains(tab)) _periodBar(),
      Expanded(
        child: switch (tab) {
          'Transactions' => _transactions(state),
          'Debts' => _debts(state),
          'Accounts' => _accounts(state),
          'Recurring' => _plans(state),
          'Budgets' => _budgets(state),
          _ => _overview(state),
        },
      ),
    ],
  );

  @override
  Widget build(BuildContext context) => ref
      .watch(spendingProvider)
      .when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _Failure(
          error: error,
          retry: () => ref.invalidate(spendingProvider),
        ),
        data: (state) => LayoutBuilder(
          builder: (context, bounds) {
            final wide = bounds.maxWidth >= 850;
            if (wide) {
              return Row(
                children: [
                  NavigationRail(
                    extended: true,
                    scrollable: true,
                    minExtendedWidth: 174,
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.surfaceContainerLow,
                    selectedIndex: _spendingSections.indexWhere(
                      (section) => section.$1 == tab,
                    ),
                    onDestinationSelected: (index) =>
                        setState(() => tab = _spendingSections[index].$1),
                    destinations: [
                      for (final section in _spendingSections)
                        NavigationRailDestination(
                          icon: Icon(section.$2),
                          label: Text(section.$1),
                        ),
                    ],
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _page(state)),
                ],
              );
            }
            return Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 0),
                  child: Row(
                    spacing: 6,
                    children: [
                      for (final section in _spendingSections)
                        ChoiceChip(
                          avatar: Icon(section.$2, size: 16),
                          label: Text(section.$1),
                          selected: tab == section.$1,
                          onSelected: (_) => setState(() => tab = section.$1),
                        ),
                    ],
                  ),
                ),
                Expanded(child: _page(state)),
              ],
            );
          },
        ),
      );
  Widget _overview(SpendingState s) {
    final previous = DateTime(month.year, month.month - 1);
    final delta = s.expenses(month) - s.expenses(previous);
    final balances = <String, int>{};
    for (final account in s.accounts) {
      final currency = account.text('currency');
      balances[currency] = (balances[currency] ?? 0) + s.balance(account.id);
    }
    final recent = _sorted(s.entries)
        .where((e) => monthKey(e.date('date')) == monthKey(month))
        .take(6)
        .toList();
    final categories =
        s.expenseCategories
            .where((c) => s.expenses(month, category: c) != 0)
            .toList()
          ..sort(
            (a, b) => s
                .expenses(month, category: b)
                .compareTo(s.expenses(month, category: a)),
          );
    final max = categories.fold<int>(
      1,
      (v, c) => s.expenses(month, category: c).abs() > v
          ? s.expenses(month, category: c).abs()
          : v,
    );
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current balance',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
                const SizedBox(height: 4),
                if (balances.isEmpty)
                  const Text('Add an account to see your balance')
                else
                  for (final balance in balances.entries)
                    Text(
                      money(balance.value, balance.key),
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                const SizedBox(height: 8),
                Text(
                  '${s.accounts.length} ${s.accounts.length == 1 ? 'account' : 'accounts'}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        _section('This month'),
        _Totals(s: s, month: month),
        const SizedBox(height: 10),
        Text(
          '${delta >= 0 ? '+' : ''}${money(delta, 'TWD')} spending vs ${monthKey(previous)}',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 16),
        _section('Recent transactions'),
        if (recent.isEmpty) const Text('No transactions this month.'),
        for (final e in recent)
          _EntryTile(s: s, e: e, onTap: () => _entryDetails(s, e)),
        if (recent.isNotEmpty)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => setState(() => tab = 'Transactions'),
              child: const Text('View all transactions'),
            ),
          ),
        const SizedBox(height: 16),
        _section('By category'),
        if (categories.isEmpty) const Text('No expenses this month.'),
        for (final c in categories)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(child: Text(c)),
                    Text(money(s.expenses(month, category: c), 'TWD')),
                  ],
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: s.expenses(month, category: c).abs() / max,
                  minHeight: 5,
                  borderRadius: BorderRadius.circular(3),
                ),
              ],
            ),
          ),
        const SizedBox(height: 18),
        _section('Outstanding debts'),
        _DebtTotals(s: s, debts: s.debts),
      ],
    );
  }

  Widget _section(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
  Widget _transactions(SpendingState s) {
    final rows = _sorted(s.entries).where((e) {
      if (!allDates && monthKey(e.date('date')) != monthKey(month)) {
        return false;
      }
      if (from != null && e.date('date').isBefore(from!) ||
          until != null && e.date('date').isAfter(until!)) {
        return false;
      }
      if (kind.isNotEmpty && e.text('kind') != kind ||
          accountId.isNotEmpty &&
              e.text('accountId') != accountId &&
              e.text('toAccountId') != accountId ||
          category.isNotEmpty && e.text('category') != category ||
          currency.isNotEmpty && e.text('currency') != currency) {
        return false;
      }
      final amount = e.number('amount') / currencyScale(e.text('currency'));
      if (minimum.isNotEmpty && amount < double.parse(minimum) ||
          maximum.isNotEmpty && amount > double.parse(maximum)) {
        return false;
      }
      final haystack =
          '${e.text('title')} ${e.text('notes')} ${e.text('category')} ${s.account(e.text('accountId')).text('name')} ${e.text('personId').isEmpty ? '' : s.person(e.text('personId')).text('name')}'
              .toLowerCase();
      return haystack.contains(query.toLowerCase());
    }).toList();
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: search,
                  decoration: const InputDecoration(
                    isDense: true,
                    hintText: 'Search transactions',
                    prefixIcon: Icon(Icons.search),
                  ),
                  onChanged: (v) => setState(() => query = v),
                ),
              ),
              IconButton(
                tooltip: 'Filter transactions',
                onPressed: () => _filters(s),
                icon: const Icon(Icons.filter_list),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '${rows.length} transactions · ${allDates ? 'all dates' : monthKey(month)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ),
        Expanded(
          child: rows.isEmpty
              ? const _Empty('No matching transactions.')
              : ListView.builder(
                  itemCount: rows.length,
                  itemBuilder: (_, i) => _EntryTile(
                    s: s,
                    e: rows[i],
                    onTap: () => _entryDetails(s, rows[i]),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _debts(SpendingState s) => ListView(
    padding: const EdgeInsets.all(10),
    children: [
      Wrap(
        spacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          TextButton.icon(
            onPressed: () => _simpleEditor(context, 'person'),
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Add person'),
          ),
          FilterChip(
            label: const Text('Include settled'),
            selected: showPaid,
            onSelected: (v) => setState(() => showPaid = v),
          ),
        ],
      ),
      if (s.people.isEmpty)
        const _Empty('Add a person to track what you owe each other.'),
      for (final p in s.people)
        Card(
          child: ExpansionTile(
            key: PageStorageKey('person:${p.id}'),
            leading: const Icon(Icons.person_outline, color: _accent),
            title: Text(p.text('name')),
            subtitle: _DebtTotals(
              s: s,
              debts: s.debts.where((d) => d.text('personId') == p.id).toList(),
            ),
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => _simpleEditor(context, 'person', initial: p),
                  child: const Text('Edit name'),
                ),
              ),
              for (final direction in ['iOwe', 'theyOwe'])
                ExpansionTile(
                  key: PageStorageKey('${p.id}:$direction'),
                  title: Text(direction == 'iOwe' ? 'I owe' : 'They owe me'),
                  children: [
                    for (final d in _sorted(s.debts).where(
                      (d) =>
                          d.text('personId') == p.id &&
                          d.text('direction') == direction &&
                          (showPaid || s.remaining(d) > 0),
                    ))
                      ListTile(
                        dense: true,
                        leading: Icon(
                          s.remaining(d) == 0
                              ? Icons.check_circle_outline
                              : Icons.receipt_long_outlined,
                          color: s.remaining(d) == 0
                              ? Colors.green
                              : d.text('due').isNotEmpty &&
                                    d
                                        .date('due')
                                        .isBefore(spendDay(DateTime.now()))
                              ? Colors.red
                              : _accent,
                          size: 19,
                        ),
                        title: Text(d.text('title')),
                        subtitle: Text(
                          '${money(s.remaining(d), d.text('currency'))} remaining${d.text('due').isEmpty ? '' : ' · due ${d.text('due')}'}',
                        ),
                        onTap: () => _debtDetails(s, d),
                      ),
                    TextButton.icon(
                      onPressed: () => _openEditor(
                        context,
                        kind: 'debt',
                        personId: p.id,
                        direction: direction,
                      ),
                      icon: const Icon(Icons.add, size: 17),
                      label: const Text('Add debt'),
                    ),
                  ],
                ),
            ],
          ),
        ),
    ],
  );
  Widget _accounts(SpendingState s) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      if (s.accounts.isEmpty)
        const _Empty('Add cash, a bank account, or an e-wallet.'),
      for (final a in s.accounts)
        Card(
          child: ListTile(
            leading: const Icon(Icons.account_balance_wallet_outlined),
            title: Text(a.text('name')),
            subtitle: Text(a.text('type', 'Cash')),
            trailing: SizedBox(
              width: (MediaQuery.sizeOf(context).width * .30).clamp(
                80.0,
                150.0,
              ),
              child: Text(
                money(s.balance(a.id), a.text('currency')),
                textAlign: TextAlign.end,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            onTap: () => _simpleEditor(context, 'account', initial: a),
          ),
        ),
      const SizedBox(height: 12),
      TextButton.icon(
        onPressed: () => _openEditor(context, kind: 'transfer'),
        icon: const Icon(Icons.swap_horiz),
        label: const Text('Transfer between accounts'),
      ),
    ],
  );
  Widget _plans(SpendingState s) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      if (s.plans.isEmpty)
        const _Empty(
          'Schedule expenses, income, debts, or a shared family subscription.',
        ),
      for (final p in s.plans)
        Card(
          child: ListTile(
            leading: const Icon(Icons.repeat, color: _accent),
            title: Text(p.text('title')),
            subtitle: Text(
              '${money(SpendRow(p.template).number('amount'), SpendRow(p.template).text('currency'))} · every ${p.number('interval', 1)} ${p.text('frequency') == 'weekly'
                  ? 'week(s)'
                  : p.text('frequency') == 'yearly'
                  ? 'year(s)'
                  : 'month(s)'}\n${_planStatus(p)}',
            ),
            isThreeLine: true,
            onTap: p.text('status') == 'cancelled'
                ? null
                : () => _openEditor(context, plan: p),
            trailing: PopupMenuButton<String>(
              onSelected: (v) async {
                if (v == 'edit') {
                  _openEditor(context, plan: p);
                } else {
                  await _change(context, ref, (e) => e.planStatus(p.id, v));
                }
              },
              itemBuilder: (_) => [
                if (p.text('status') != 'cancelled') ...[
                  const PopupMenuItem(
                    value: 'edit',
                    child: Text('Edit future charges'),
                  ),
                  PopupMenuItem(
                    value: p.text('status') == 'active' ? 'paused' : 'active',
                    child: Text(
                      p.text('status') == 'active' ? 'Pause' : 'Resume',
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'cancelled',
                    child: Text('Cancel future charges'),
                  ),
                ],
              ],
            ),
          ),
        ),
      const SizedBox(height: 12),
      const Text(
        'Due charges are added when the app opens and while it is running. Pausing skips paused periods. Editing a price changes future charges only.',
      ),
    ],
  );
  String _planStatus(SpendRow p) {
    if (p.text('status') != 'active') return p.text('status');
    final date = recurrenceDate(p, p.number('next'));
    return p.text('end').isNotEmpty && date.isAfter(p.date('end'))
        ? 'Finished'
        : 'Next: ${dateKey(date)}';
  }

  Widget _budgets(SpendingState s) => ListView(
    padding: const EdgeInsets.all(12),
    children: [
      for (final b in s.budgets.where(
        (b) => b.text('month') == monthKey(month),
      ))
        Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(child: Text(b.text('category'))),
                    IconButton(
                      tooltip: 'Edit budget',
                      onPressed: () => _simpleEditor(
                        context,
                        'budget',
                        initial: b,
                        month: monthKey(month),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 18),
                    ),
                    IconButton(
                      tooltip: 'Remove budget',
                      onPressed: () => _change(
                        context,
                        ref,
                        (e) => e.state.budgets.removeWhere((r) => r.id == b.id),
                      ),
                      icon: const Icon(Icons.close, size: 18),
                    ),
                  ],
                ),
                Text(
                  '${money(s.expenses(month, category: b.text('category')), 'TWD')} / ${money(b.number('amount'), 'TWD')}',
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value:
                      (s.expenses(month, category: b.text('category')) /
                              b.number('amount'))
                          .clamp(0.0, 1.0),
                  color:
                      s.expenses(month, category: b.text('category')) >
                          b.number('amount')
                      ? Colors.red
                      : _accent,
                ),
                const SizedBox(height: 6),
                Text(
                  '${money((b.number('amount') - s.expenses(month, category: b.text('category'))).abs(), 'TWD')} ${s.expenses(month, category: b.text('category')) > b.number('amount') ? 'over budget' : 'remaining'}',
                ),
              ],
            ),
          ),
        ),
      if (!s.budgets.any((b) => b.text('month') == monthKey(month)))
        const _Empty('No category budgets for this month.'),
      TextButton.icon(
        onPressed: () => _simpleEditor(context, 'category'),
        icon: const Icon(Icons.label_outline),
        label: const Text('Add custom category'),
      ),
    ],
  );

  Future<void> _entryDetails(SpendingState s, SpendRow e) async {
    final action = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(e.text('title')),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(money(e.number('amount'), e.text('currency'))),
              _detail('Type', e.text('kind')),
              _detail('Date', e.text('date')),
              _detail('Account', s.account(e.text('accountId')).text('name')),
              if (e.text('kind') == 'transfer')
                _detail(
                  'Received',
                  '${money(e.number('received'), s.account(e.text('toAccountId')).text('currency'))} → ${s.account(e.text('toAccountId')).text('name')}',
                ),
              if (e.text('category').isNotEmpty)
                _detail('Category', e.text('category')),
              if ([
                'expense',
                'income',
                'split',
                'refund',
              ].contains(e.text('kind')))
                _detail(
                  'Recorded rate',
                  '1 ${e.text('currency')} = ${e.number('rate') / 1000000} TWD',
                ),
              if (e.text('kind') == 'split') ...[
                _detail(
                  'Your share',
                  money(e.number('ownAmount'), e.text('currency')),
                ),
                for (final share in e.shares)
                  _detail(
                    s.person(share.text('personId')).text('name'),
                    money(share.number('amount'), e.text('currency')),
                  ),
              ],
              if (e.text('notes').isNotEmpty) _detail('Notes', e.text('notes')),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, 'delete'),
            child: const Text('Delete'),
          ),
          if (['expense', 'split'].contains(e.text('kind')))
            TextButton(
              onPressed: () => Navigator.pop(c, 'refund'),
              child: const Text('Refund'),
            ),
          if (['expense', 'income', 'transfer'].contains(e.text('kind')) &&
              e.text('planId').isEmpty &&
              s.refunded(e.id) == 0)
            TextButton(
              onPressed: () => Navigator.pop(c, 'edit'),
              child: const Text('Edit'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'edit') _openEditor(context, entry: e);
    if (action == 'refund') _simpleEditor(context, 'refund', initial: e);
    if (action == 'delete' &&
        await _confirm(
          context,
          'Delete transaction?',
          'This removes its effect on balances. A recurring occurrence stays deleted; future charges continue.',
        )) {
      if (mounted) {
        await _change(context, ref, (engine) => engine.deleteEntry(e.id));
      }
    }
  }

  Future<void> _debtDetails(SpendingState s, SpendRow d) async {
    final action = await showDialog<String>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(d.text('title')),
        content: SizedBox(
          width: 440,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detail('Person', s.person(d.text('personId')).text('name')),
                _detail('Total', money(d.number('amount'), d.text('currency'))),
                _detail('Paid', money(s.paid(d.id), d.text('currency'))),
                _detail('Remaining', money(s.remaining(d), d.text('currency'))),
                if (d.text('due').isNotEmpty) _detail('Due', d.text('due')),
                if (d.text('notes').isNotEmpty)
                  _detail('Notes', d.text('notes')),
                if (d.flag('remind')) const Text('Reminder managed in Tasks.'),
                const Divider(),
                const Text('Repayment history'),
                for (final e in _sorted(s.entries).where(
                  (e) =>
                      e.text('debtId') == d.id &&
                      e.text('kind').startsWith('repayment'),
                ))
                  ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                    title: Text(money(e.number('amount'), e.text('currency'))),
                    subtitle: Text(e.text('date')),
                    trailing: IconButton(
                      tooltip: 'View or undo repayment',
                      icon: const Icon(Icons.more_horiz),
                      onPressed: () {
                        Navigator.pop(c);
                        _entryDetails(s, e);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, 'delete'),
            child: const Text('Delete'),
          ),
          if (d.text('originId').isEmpty && d.text('planId').isEmpty)
            TextButton(
              onPressed: () => Navigator.pop(c, 'edit'),
              child: const Text('Edit'),
            ),
          if (s.remaining(d) > 0)
            FilledButton(
              onPressed: () => Navigator.pop(c, 'repay'),
              child: const Text('Record payment'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(c),
            child: const Text('Close'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (action == 'edit') _openEditor(context, debt: d);
    if (action == 'repay') _simpleEditor(context, 'repay', initial: d);
    if (action == 'delete' &&
        await _confirm(
          context,
          'Delete debt?',
          'Remove this debt permanently?',
        )) {
      if (mounted) await _change(context, ref, (e) => e.deleteDebt(d.id));
    }
  }

  Future<void> _filters(SpendingState s) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => _FilterDialog(
        s: s,
        initial: {
          'kind': kind,
          'account': accountId,
          'category': category,
          'currency': currency,
          'min': minimum,
          'max': maximum,
          'all': allDates,
          'from': from,
          'until': until,
        },
      ),
    );
    if (result != null && mounted) {
      setState(() {
        kind = result['kind'];
        accountId = result['account'];
        category = result['category'];
        currency = result['currency'];
        minimum = result['min'];
        maximum = result['max'];
        allDates = result['all'];
        from = result['from'];
        until = result['until'];
      });
    }
  }

  Future<void> _export(SpendingState s) async {
    String cell(Object? v) {
      var text = '$v';
      if (RegExp(r'^[=+@\-\t\r]').hasMatch(text)) text = "'$text";
      return '"${text.replaceAll('"', '""')}"';
    }

    final rows = <List<Object?>>[
      [
        'Date',
        'Title',
        'Type',
        'Account',
        'Category',
        'Currency',
        'Amount',
        'Own share',
        'TWD rate',
        'Notes',
      ],
      for (final e in _sorted(s.entries))
        [
          e.text('date'),
          e.text('title'),
          e.text('kind'),
          s.account(e.text('accountId')).text('name'),
          e.text('category'),
          e.text('currency'),
          amountInput(e.number('amount'), e.text('currency')),
          e.text('kind') == 'split'
              ? amountInput(e.number('ownAmount'), e.text('currency'))
              : '',
          e.number('rate') / 1000000,
          e.text('notes'),
        ],
    ];
    try {
      await FilePicker.saveFile(
        dialogTitle: 'Export all spending transactions',
        fileName: 'spending_${dateKey(DateTime.now())}.csv',
        bytes: Uint8List.fromList(
          utf8.encode(
            '\uFEFF${rows.map((r) => r.map(cell).join(',')).join('\r\n')}',
          ),
        ),
        mimeType: 'text/csv',
        type: FileType.custom,
        allowedExtensions: const ['csv'],
      );
    } catch (e) {
      if (mounted) _message(context, _error(e));
    }
  }
}

Widget _detail(String label, String value) => Padding(
  padding: const EdgeInsets.symmetric(vertical: 4),
  child: Text('$label: $value'),
);

class _Totals extends StatelessWidget {
  const _Totals({required this.s, required this.month});
  final SpendingState s;
  final DateTime month;
  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 12,
    runSpacing: 8,
    children: [
      for (final item in [
        ('Income', s.income(month), Colors.teal),
        ('Expenses', s.expenses(month), _accent),
        (
          'Net savings',
          s.income(month) - s.expenses(month),
          Theme.of(context).colorScheme.primary,
        ),
      ])
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: item.$3.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.$1, style: Theme.of(context).textTheme.labelSmall),
              Text(
                money(item.$2, 'TWD'),
                style: TextStyle(fontWeight: FontWeight.w700, color: item.$3),
              ),
            ],
          ),
        ),
    ],
  );
}

class _DebtTotals extends StatelessWidget {
  const _DebtTotals({required this.s, required this.debts});
  final SpendingState s;
  final List<SpendRow> debts;
  @override
  Widget build(BuildContext context) {
    final totals = <String, int>{};
    for (final d in debts) {
      if (s.remaining(d) > 0) {
        final key =
            '${d.text('direction') == 'iOwe' ? 'I owe' : 'They owe me'} · ${d.text('currency')}';
        totals[key] = (totals[key] ?? 0) + s.remaining(d);
      }
    }
    return Text(
      totals.isEmpty
          ? 'All settled'
          : totals.entries
                .map(
                  (e) =>
                      '${e.key} ${amountInput(e.value, e.key.split(' · ').last)}',
                )
                .join('\n'),
      style: Theme.of(context).textTheme.bodySmall,
    );
  }
}

class _EntryTile extends StatelessWidget {
  const _EntryTile({required this.s, required this.e, required this.onTap});
  final SpendingState s;
  final SpendRow e;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final kind = e.text('kind');
    final incoming = [
      'income',
      'refund',
      'repaymentIn',
      'borrowing',
    ].contains(kind);
    final neutral = [
      'transfer',
      'repaymentIn',
      'repaymentOut',
      'borrowing',
      'loan',
    ].contains(kind);
    final color = neutral
        ? Theme.of(context).colorScheme.onSurfaceVariant
        : incoming
        ? Colors.teal
        : Theme.of(context).colorScheme.onSurface;
    final category = e.text('category');
    final account = e.text('accountId');
    final detail = [
      e.text('date'),
      if (category.isNotEmpty) category,
      if (account.isNotEmpty) s.account(account).text('name'),
    ].join(' · ');
    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withValues(alpha: .09),
        child: Icon(
          kind == 'transfer'
              ? Icons.swap_horiz
              : incoming
              ? Icons.south_west
              : Icons.north_east,
          color: color,
          size: 18,
        ),
      ),
      title: Text(
        e.text('title'),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: SizedBox(
        width: (MediaQuery.sizeOf(context).width * .30).clamp(80.0, 150.0),
        child: Text(
          '${incoming
              ? '+'
              : neutral
              ? ''
              : '−'}${money(e.number('amount'), e.text('currency'))}',
          textAlign: TextAlign.end,
          maxLines: 2,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      onTap: onTap,
    );
  }
}

class _Empty extends StatelessWidget {
  const _Empty(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Center(child: Text(text, textAlign: TextAlign.center)),
  );
}

class _Failure extends StatelessWidget {
  const _Failure({required this.error, required this.retry});
  final Object error;
  final VoidCallback retry;
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Text('Could not load Spending: ${_error(error)}'),
      TextButton(onPressed: retry, child: const Text('Retry')),
    ],
  );
}
