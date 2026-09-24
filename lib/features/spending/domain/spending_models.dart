import 'dart:convert';

const spendingCurrencies = ['TWD', 'IDR', 'USD', 'SGD', 'EUR', 'JPY'];
const defaultExpenseCategories = [
  'Food',
  'Transport',
  'Shopping',
  'Rent',
  'Subscriptions',
  'Entertainment',
  'Health',
  'Education',
  'Other',
];
const defaultIncomeCategories = [
  'Salary',
  'Allowance',
  'Scholarship',
  'Gift',
  'Other income',
];

int currencyDigits(String currency) => currency == 'JPY' ? 0 : 2;
int currencyScale(String currency) => currencyDigits(currency) == 0 ? 1 : 100;
DateTime spendDay(DateTime d) => DateTime(d.year, d.month, d.day);
String dateKey(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
String monthKey(DateTime d) => dateKey(d).substring(0, 7);

/// Exact decimal parsing: monetary amounts never travel through a double.
int parseAmount(
  String input,
  String currency, {
  bool allowZero = false,
  bool signed = false,
}) {
  final text = input.trim().replaceAll(',', '');
  if (!RegExp(signed ? r'^-?\d+(\.\d+)?$' : r'^\d+(\.\d+)?$').hasMatch(text)) {
    throw const FormatException('Enter a valid amount.');
  }
  final negative = text.startsWith('-');
  final parts = text.replaceFirst('-', '').split('.');
  final digits = currencyDigits(currency);
  final fraction = parts.length > 1 ? parts[1] : '';
  if (fraction.length > digits) {
    throw FormatException('$currency supports $digits decimal places.');
  }
  final value =
      int.parse(parts[0]) * currencyScale(currency) +
      (digits == 0 ? 0 : int.parse(fraction.padRight(digits, '0')));
  if (value > 9000000000000 || (!allowZero && value == 0)) {
    throw const FormatException('Amount must be positive and within range.');
  }
  return negative ? -value : value;
}

String amountInput(int minor, String currency) {
  final value = minor.abs();
  final sign = minor < 0 ? '-' : '';
  if (currencyDigits(currency) == 0) return '$sign$value';
  return '$sign${value ~/ 100}.${(value % 100).toString().padLeft(2, '0')}';
}

String money(int minor, String currency) =>
    '$currency ${amountInput(minor, currency)}';

/// Millionths of a TWD per original currency unit, recorded on each entry.
int parseRate(String input) {
  if (!RegExp(r'^\d+(\.\d{1,6})?$').hasMatch(input.trim())) {
    throw const FormatException('Enter a positive rate (up to 6 decimals).');
  }
  final parts = input.trim().split('.');
  final value =
      int.parse(parts[0]) * 1000000 +
      int.parse((parts.length == 1 ? '' : parts[1]).padRight(6, '0'));
  if (value <= 0 || value > 1000000000000) {
    throw const FormatException('Exchange rate is out of range.');
  }
  return value;
}

int toTwd(int minor, String currency, int rate) {
  final numerator = BigInt.from(minor) * BigInt.from(rate) * BigInt.from(100);
  final denominator = BigInt.from(currencyScale(currency) * 1000000);
  return ((numerator +
              (numerator.isNegative
                  ? -denominator ~/ BigInt.two
                  : denominator ~/ BigInt.two)) ~/
          denominator)
      .toInt();
}

/// Typed access to versioned, JSON-compatible records. IDs are stable UUIDs;
/// the engine validates every record and its references before committing.
class SpendRow {
  SpendRow(Map<String, dynamic> data) : data = Map.unmodifiable(data);
  final Map<String, dynamic> data;
  String get id => text('id');
  String text(String key, [String fallback = '']) =>
      data[key] as String? ?? fallback;
  int number(String key, [int fallback = 0]) => data[key] as int? ?? fallback;
  bool flag(String key) => data[key] == true;
  DateTime date(String key) => DateTime.parse(text(key));
  SpendRow copy(Map<String, dynamic> changes) =>
      SpendRow({...data, ...changes});
  Map<String, dynamic> get template =>
      Map<String, dynamic>.from(data['template'] as Map? ?? {});
  List<SpendRow> get shares => [
    for (final s in data['shares'] as List? ?? [])
      SpendRow(Map<String, dynamic>.from(s as Map)),
  ];
}

class SpendingState {
  SpendingState({
    List<SpendRow>? accounts,
    List<SpendRow>? people,
    List<SpendRow>? entries,
    List<SpendRow>? debts,
    List<SpendRow>? plans,
    List<SpendRow>? budgets,
    List<String>? expenseCategories,
    List<String>? incomeCategories,
  }) : accounts = accounts ?? [],
       people = people ?? [],
       entries = entries ?? [],
       debts = debts ?? [],
       plans = plans ?? [],
       budgets = budgets ?? [],
       expenseCategories = expenseCategories ?? [...defaultExpenseCategories],
       incomeCategories = incomeCategories ?? [...defaultIncomeCategories];
  final List<SpendRow> accounts, people, entries, debts, plans, budgets;
  final List<String> expenseCategories, incomeCategories;
  Map<String, dynamic> toJson() => {
    'version': 1,
    'accounts': [for (final r in accounts) r.data],
    'people': [for (final r in people) r.data],
    'entries': [for (final r in entries) r.data],
    'debts': [for (final r in debts) r.data],
    'plans': [for (final r in plans) r.data],
    'budgets': [for (final r in budgets) r.data],
    'expenseCategories': expenseCategories,
    'incomeCategories': incomeCategories,
  };
  String encode() => jsonEncode(toJson());
  factory SpendingState.decode(String text) {
    final j = jsonDecode(text) as Map<String, dynamic>;
    if (j['version'] != 1) {
      throw const FormatException('Unsupported spending data version.');
    }
    List<SpendRow> rows(String key) => (j[key] as List)
        .map((e) => SpendRow(Map<String, dynamic>.from(e as Map)))
        .toList();
    return SpendingState(
      accounts: rows('accounts'),
      people: rows('people'),
      entries: rows('entries'),
      debts: rows('debts'),
      plans: rows('plans'),
      budgets: rows('budgets'),
      expenseCategories: List<String>.from(j['expenseCategories']),
      incomeCategories: List<String>.from(j['incomeCategories']),
    );
  }
  SpendRow account(String id) => accounts.firstWhere(
    (r) => r.id == id,
    orElse: () => throw StateError('Account no longer exists.'),
  );
  SpendRow person(String id) => people.firstWhere(
    (r) => r.id == id,
    orElse: () => throw StateError('Person no longer exists.'),
  );
  SpendRow debt(String id) => debts.firstWhere(
    (r) => r.id == id,
    orElse: () => throw StateError('Debt no longer exists.'),
  );
  int paid(String id) => entries
      .where(
        (e) =>
            e.text('debtId') == id &&
            ['repaymentIn', 'repaymentOut'].contains(e.text('kind')),
      )
      .fold(0, (v, e) => v + e.number('amount'));
  int remaining(SpendRow d) => d.number('amount') - paid(d.id);
  int balance(String accountId) {
    var value = account(accountId).number('opening');
    for (final e in entries) {
      if (e.text('accountId') == accountId) {
        value +=
            [
              'income',
              'refund',
              'borrowing',
              'repaymentIn',
            ].contains(e.text('kind'))
            ? e.number('amount')
            : -e.number('amount');
      }
      if (e.text('kind') == 'transfer' && e.text('toAccountId') == accountId) {
        value += e.number('received');
      }
    }
    return value;
  }

  int refunded(String entryId) => entries
      .where((e) => e.text('refundOf') == entryId)
      .fold(0, (v, e) => v + e.number('amount'));
  int reportAmount(SpendRow e) => toTwd(
    e.text('kind') == 'split' ? e.number('ownAmount') : e.number('amount'),
    e.text('currency'),
    e.number('rate'),
  );
  int income(DateTime month) => entries
      .where(
        (e) =>
            e.text('kind') == 'income' &&
            monthKey(e.date('date')) == monthKey(month),
      )
      .fold(0, (v, e) => v + reportAmount(e));
  int expenses(DateTime month, {String? category}) => entries
      .where(
        (e) =>
            ['expense', 'split', 'refund'].contains(e.text('kind')) &&
            monthKey(e.date('date')) == monthKey(month) &&
            (category == null || e.text('category') == category),
      )
      .fold(
        0,
        (v, e) => v + (e.text('kind') == 'refund' ? -1 : 1) * reportAmount(e),
      );
}

DateTime recurrenceDate(SpendRow plan, int index) {
  final start = plan.date('start');
  final step = plan.number('interval', 1) * index;
  if (plan.text('frequency') == 'weekly') {
    return DateTime(start.year, start.month, start.day + step * 7);
  }
  final months = plan.text('frequency') == 'yearly' ? step * 12 : step;
  final first = DateTime(start.year, start.month + months, 1);
  final lastDay = DateTime(first.year, first.month + 1, 0).day;
  return DateTime(
    first.year,
    first.month,
    start.day > lastDay ? lastDay : start.day,
  );
}
