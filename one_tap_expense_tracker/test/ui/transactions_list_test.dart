import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';
import 'package:one_tap_expense_tracker/ui/transactions/transactions_page.dart';

void main() {
  testWidgets('shows transactions sorted by occurredAt desc with date headers',
      (tester) async {
    final controller = TransactionsController(
      seedItems: [
        Transaction(
          id: 'old',
          type: TransactionType.expense,
          amount: Money.cents(1000),
          categoryId: 'food',
          accountId: 'cash',
          note: '旧记录',
          occurredAt: DateTime(2026, 3, 15, 9),
          createdAt: DateTime(2026, 3, 15, 9),
          updatedAt: DateTime(2026, 3, 15, 9),
        ),
        Transaction(
          id: 'new',
          type: TransactionType.expense,
          amount: Money.cents(2300),
          categoryId: 'transport',
          accountId: 'cash',
          note: '新记录',
          occurredAt: DateTime(2026, 3, 16, 10),
          createdAt: DateTime(2026, 3, 16, 10),
          updatedAt: DateTime(2026, 3, 16, 10),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionsPage(controller: controller)),
    );

    final newFinder = find.text('新记录');
    final oldFinder = find.text('旧记录');
    expect(newFinder, findsOneWidget);
    expect(oldFinder, findsOneWidget);
    expect(
      tester.getTopLeft(newFinder).dy < tester.getTopLeft(oldFinder).dy,
      isTrue,
    );

    expect(find.text('2026-03-16'), findsOneWidget);
    expect(find.text('2026-03-15'), findsOneWidget);
  });
}

