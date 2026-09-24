# Spending module

## Install

This patch contains only new or changed files, with project-relative paths. It is based on the September 17 project snapshot (`docs (4).zip`) plus the subsequent Note+ patches through September 18.

1. Export a local backup from the app's Settings.
2. Extract the patch into the project root, replacing matching files.
3. Run `flutter pub get`, then restart the app with `flutter run`.
4. To rebuild the phone app, run `flutter build apk --release`.

No new dependencies or generated Drift files are required. The existing SQLite database upgrades from schema 10 to 11 automatically.

## Screens

- **Overview:** current account balances grouped by currency, monthly income, expenses and net savings in TWD, recent transactions, previous-month comparison, category bars and outstanding debts.
- **Transactions:** quick expense/income entry, custom categories, notes, historical dates, search, account/category/type/currency/date/amount filters, edits to unlinked transactions, refunds and CSV export.
- **Accounts:** cash, bank and e-wallet balances with opening balances; same-currency and cross-currency transfers. Record transfer fees separately as an expense.
- **Debts:** person → I owe / They owe me → individual charges. Both totals remain separate by currency. Supports manual debts, cash loans, split bills, partial or full repayment, history and undoing repayments.
- **Recurring:** weekly/monthly/yearly expenses, income, debts and shared subscriptions; interval, start/end dates, due-date offset, pause, resume, cancellation and future price edits.
- **Budgets:** category limits for each selected month, remaining/over-budget amounts and progress bars.
- Desktop has a compact Spending card with live account balances grouped by currency, monthly figures, and up to three recent transactions according to the available height. Selecting a transaction opens the Transactions page. Its view selector switches to a debt summary grouped by person. Expanding the debt view opens a popup with I owe and They owe me tabs; selecting a person in the compact card opens that popup on the matching tab with the person's charges expanded. Mobile uses the full module.
- In the full module, desktop uses a labeled side navigation and smaller layouts use a horizontal section selector. Each page has one primary add action; related actions such as transfers, income, categories and export are in the More menu. On first use, that action creates an account or person before opening transactions or debts. Transaction rows put amounts in a consistent trailing column. The account-first overview and transaction register were informed by [Wallet by BudgetBakers](https://budgetbakers.com/en/blog/2018-02-wallet-now/) and [Actual Budget](https://actualbudget.org/docs/tour/accounts/), adapted to this app's existing Material theme.

## Family subscriptions

For a subscription you pay, choose **Split expense / family subscription**, enter the full charge, choose the paying account and category, select people and enter each person's share, then enable **Repeat automatically**. The remainder is your own expense. Each billing period creates one account charge and one separate debt for each selected person.

For a recurring amount you owe someone, choose **Debt**, select the person and **I owe**, then enable **Repeat automatically**. Leave **Money changes hands now** off to track the obligation without a cash movement. Enable it only for an actual recurring cash loan.

Open a person's charge and select **Record payment**. The amount starts at the full outstanding balance; enter a smaller amount for a partial payment. Select an account in the debt's currency. A different currency can first be transferred into that account.

## Accounting behavior

- Amounts are stored as integer minor units. JPY uses whole yen; other supported currencies use two decimal places.
- Supported currencies: TWD, IDR, USD, SGD, EUR and JPY.
- TWD is the reporting currency. Foreign expenses/income require a manually recorded TWD exchange rate. Rates are not fetched online. Historical values do not change when later rates or recurring prices change.
- Transfers, loans and principal repayments affect account balances but do not inflate income or spending.
- Only your share of a split bill counts as spending. Friends' shares become receivables; collecting them is a repayment.
- A manual debt with no cash movement records only the obligation. If an associated purchase should count as your spending, record that expense separately; repayments themselves are not expenses.
- Refunds return to the original account, retain the original category/rate, and reduce spending in the month received. For split bills, the refund action covers your own share only.
- Fully linked records are protected from conflicting edits. To replace a split bill or loan, undo its repayments and refunds first, then delete and recreate its original transaction.
- Monthly schedules retain their original day: January 31 → February 28 → March 31. Annual leap-day schedules recover February 29 in leap years.
- Missed active billing periods are caught up when the app opens. Generation also runs once per minute while the dashboard is mounted. No background service runs while the app is closed.
- Paused periods are skipped when resumed. Cancellation retains existing charges. Editing materializes already-due periods at the old price before applying future changes.
- Deleting a generated occurrence does not recreate it on restart; the persisted schedule cursor has already advanced.

## Reminders, backup and persistence

Optional reminders are Personal tasks scheduled for 9 AM on the due date. Recurring plans also maintain a next-charge task. The existing Tasks notification service remains the sole system notification owner. Settling a debt completes its managed task. Complete the financial repayment in Spending to update balances; checking a task alone does not settle the debt.

Spending state is versioned JSON in a single SQLite `spending_state` row. Commands are serialized and run in database transactions, validating money, record references, split shares, repayments and recurring settings before commit. Generated reminder tasks are committed in the same transaction. This approach adds no generated-table changes and suits a local personal ledger.

Dashboard backups now use format 7 and include the complete spending state. Import validates spending data before changing records. Version 1–6 backups retain the device's spending data. CSV export contains all cash transactions; the dashboard backup is the complete restore format, including people, debts, budgets and schedules. Existing Note+ backup behavior is unchanged by this patch.

## Verification

The dependency-free accounting regression runner is:

```sh
dart test/spending/spending_engine_check.dart
```

Flutter checks:

```sh
flutter analyze
flutter test test/spending test/dashboard_shell_test.dart
```

Tests cover money precision, FX conversion, transfer exclusion, split expense accounting, refund limits, partial repayments, recurring catch-up, duplicate prevention, deleted occurrences, month ends and leap years, future-only price changes, pause/resume, cancellation, subscription shares, transaction rollback, reminder tasks, backup round trips, malformed/legacy backups, schema migration, and mobile/desktop layouts.

### Verification results

Verified on Windows on September 24, 2026: `flutter analyze --no-pub` reported no issues; the complete `flutter test --no-pub` suite passed (148 tests). The Windows release build succeeded before the compact-card and debt-popup UI changes; it was not rerun afterward. Android release and interactive device behavior have not been checked in this run.
