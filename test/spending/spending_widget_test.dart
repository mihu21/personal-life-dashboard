import 'package:drift/native.dart';
import 'package:personal_life_dashboard/features/class_schedule/data/academic_database.dart';
import 'package:personal_life_dashboard/features/spending/data/spending_repository.dart';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:personal_life_dashboard/features/spending/domain/spending_models.dart';
import 'package:personal_life_dashboard/features/spending/presentation/spending_module.dart';
import 'package:personal_life_dashboard/features/spending/providers/spending_providers.dart';

import 'spending_engine_check.dart' as checks;

void main() {
  testWidgets('desktop spending card follows panel layout at varied heights', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final populated = checks.fixture().state;
    populated.entries.add(
      checks.entry('lunch', 'expense', 12000, {'title': 'Lunch'}),
    );
    populated.entries.add(
      checks.entry('taxi', 'expense', 2000, {'title': 'Taxi'}),
    );

    for (final (size, scale, state) in [
      (const Size(440, 115), 1.0, SpendingState()),
      (const Size(620, 305), 1.0, SpendingState()),
      (const Size(440, 260), 2.0, SpendingState()),
      (const Size(620, 305), 1.0, populated),
      (const Size(620, 270), 1.0, populated),
      (const Size(620, 350), 2.0, populated),
    ]) {
      tester.view.physicalSize = size;
      tester.platformDispatcher.textScaleFactorTestValue = scale;
      await tester.pumpWidget(
        ProviderScope(
          key: ValueKey('$size-$scale-${state.entries.length}'),
          overrides: [
            spendingProvider.overrideWith((ref) => Stream.value(state)),
          ],
          child: const MaterialApp(
            home: Scaffold(body: SpendingDashboardCard()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: '$size at ${scale}x');
      expect(find.text('Current balance'), findsOneWidget);
      final cardLeft = tester.getTopLeft(find.byType(SpendingDashboardCard)).dx;
      final summaryLeft = tester.getTopLeft(find.text('Current balance')).dx;
      expect(summaryLeft - cardLeft, lessThan(30));
      if (state.entries.isNotEmpty) {
        expect(find.text('TWD 860.00'), findsOneWidget);
        expect(find.text('IDR 0.00'), findsOneWidget);
        expect(find.text('Recent'), findsOneWidget);
        final visibleItems =
            find.text('Lunch').evaluate().length +
            find.text('Taxi').evaluate().length;
        expect(visibleItems, scale > 1 || size.height < 300 ? 1 : 2);
      }
    }
  });

  testWidgets('compact debt view opens two-tab popup focused on a person', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(620, 305);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    final state = checks.fixture().state;
    state.debts.add(
      SpendRow({
        'id': 'alex-debt',
        'personId': 'alex',
        'title': 'Family subscription',
        'direction': 'theyOwe',
        'amount': 4500,
        'currency': 'TWD',
        'date': '2026-09-01',
      }),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spendingProvider.overrideWith((ref) => Stream.value(state)),
        ],
        child: const MaterialApp(home: Scaffold(body: SpendingDashboardCard())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Overview'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Debts').last);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('I owe'), findsOneWidget);
    expect(find.text('They owe me'), findsOneWidget);
    expect(find.text('TWD 45.00'), findsOneWidget);
    expect(find.text('Alex'), findsOneWidget);
    await tester.tap(find.byTooltip('Open debt tracker'));
    await tester.pumpAndSettle();
    expect(find.text('Debt Tracker'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'I owe'), findsOneWidget);
    expect(find.widgetWithText(Tab, 'They owe me'), findsOneWidget);
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 1);
    await tester.tap(find.byTooltip('Close debt tracker'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Alex'));
    await tester.pumpAndSettle();
    expect(find.text('Debt Tracker'), findsOneWidget);
    expect(tester.widget<TabBar>(find.byType(TabBar)).controller!.index, 1);
    expect(find.text('Family subscription'), findsOneWidget);
    await tester.ensureVisible(find.text('Family subscription'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Family subscription'));
    await tester.pumpAndSettle();
    expect(find.text('Record payment'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('debt popup separates directions at 200 percent text', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 568);
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    final state = checks.fixture().state;
    for (final (id, personId, direction, title) in [
      ('owe', 'sam', 'iOwe', 'Rent'),
      ('owed', 'alex', 'theyOwe', 'Family subscription'),
    ]) {
      state.debts.add(
        SpendRow({
          'id': id,
          'personId': personId,
          'title': title,
          'direction': direction,
          'amount': 4500,
          'currency': 'TWD',
          'date': '2026-09-01',
        }),
      );
    }
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          spendingProvider.overrideWith((ref) => Stream.value(state)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => openDebtTracker(context),
                child: const Text('Open debts'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open debts'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Sam'), findsOneWidget);
    expect(find.text('Alex'), findsNothing);
    await tester.tap(find.widgetWithText(Tab, 'They owe me'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Sam'), findsNothing);
  });

  testWidgets('expense form saves into the ledger', (tester) async {
    final db = AcademicDatabase(NativeDatabase.memory());
    final repo = SpendingRepository(db);
    addTearDown(() async {
      repo.dispose();
      await db.close();
    });
    await repo.change(
      (e) => e.account(
        SpendRow({
          'id': 'cash',
          'name': 'Cash',
          'currency': 'TWD',
          'opening': 100000,
        }),
      ),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [spendingRepositoryProvider.overrideWithValue(repo)],
        child: const MaterialApp(home: Scaffold(body: SpendingModule())),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add transaction'));
    await tester.pumpAndSettle();
    Finder field(String label) => find.byWidgetPredicate(
      (w) => w is TextField && w.decoration?.labelText == label,
    );
    await tester.enterText(field('Title'), 'Lunch');
    await tester.enterText(field('Amount (TWD)'), '120');
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Lunch'), findsWidgets);
    final state = await repo.load();
    expect(state.entries.single.number('amount'), 12000);
    expect(state.balance('cash'), 88000);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('spending screens and dialogs fit narrow and desktop layouts', (
    tester,
  ) async {
    final e = checks.fixture();
    e.post(
      checks.entry('dinner', 'split', 30000, {
        'ownAmount': 10000,
        'shares': [
          {'personId': 'alex', 'amount': 20000},
        ],
        'due': '2026-09-25',
      }),
    );
    e.post(checks.entry('salary', 'income', 2000000));
    e.budget(
      SpendRow({
        'id': 'food',
        'category': 'Food',
        'month': '2026-09',
        'amount': 800000,
      }),
    );
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    for (final size in [
      const Size(390, 844),
      const Size(320, 568),
      const Size(1200, 800),
    ]) {
      tester.view.physicalSize = size;
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            spendingProvider.overrideWith((ref) => Stream.value(e.state)),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: RepaintBoundary(
                key: const ValueKey('capture'),
                child: MediaQuery(
                  data: MediaQueryData(
                    size: size,
                    textScaler: TextScaler.linear(size.width == 320 ? 1.5 : 1),
                  ),
                  child: const SpendingModule(),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      for (final tab in [
        'Transactions',
        'Debts',
        'Accounts',
        'Recurring',
        'Budgets',
        'Overview',
      ]) {
        final finder = size.width >= 850
            ? find.descendant(
                of: find.byType(NavigationRail),
                matching: find.text(tab),
              )
            : find.widgetWithText(ChoiceChip, tab);
        if (size.width < 850) await tester.ensureVisible(finder);
        await tester.tap(finder);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: '$tab at $size');
        if (tab == 'Debts') {
          await tester.tap(find.text('Alex'));
          await tester.pumpAndSettle();
          expect(find.text('I owe'), findsOneWidget);
          expect(find.text('They owe me'), findsOneWidget);
        }
      }
      await tester.tap(
        size.width < 520
            ? find.byTooltip('Add transaction')
            : find.text('Add transaction'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Add transaction'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      const output = String.fromEnvironment('SPENDING_SCREENSHOTS');
      if (output.isNotEmpty) {
        final boundary = tester.renderObject<RenderRepaintBoundary>(
          find.byKey(const ValueKey('capture')),
        );
        final image = await boundary.toImage();
        final data = await image.toByteData(format: ui.ImageByteFormat.png);
        await tester.runAsync(() async {
          await Directory(output).create(recursive: true);
          await File(
            '$output/spending_${size.width.toInt()}.png',
          ).writeAsBytes(data!.buffer.asUint8List());
        });
        image.dispose();
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });
}
