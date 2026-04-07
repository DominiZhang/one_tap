import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/overview_controller.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';

void main() {
  test('computes monthly total and top categories', () {
    final txController = TransactionsController(
      seedItems: [
        Transaction(
          id: '1',
          type: TransactionType.expense,
          amount: Money.cents(1200),
          categoryId: 'food',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 1, 8),
          createdAt: DateTime(2026, 3, 1, 8),
          updatedAt: DateTime(2026, 3, 1, 8),
        ),
        Transaction(
          id: '2',
          type: TransactionType.expense,
          amount: Money.cents(2800),
          categoryId: 'transport',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 2, 8),
          createdAt: DateTime(2026, 3, 2, 8),
          updatedAt: DateTime(2026, 3, 2, 8),
        ),
        Transaction(
          id: '3',
          type: TransactionType.expense,
          amount: Money.cents(1800),
          categoryId: 'food',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 3, 8),
          createdAt: DateTime(2026, 3, 3, 8),
          updatedAt: DateTime(2026, 3, 3, 8),
        ),
        Transaction(
          id: '4',
          type: TransactionType.income,
          amount: Money.cents(9999),
          categoryId: 'salary',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 4, 8),
          createdAt: DateTime(2026, 3, 4, 8),
          updatedAt: DateTime(2026, 3, 4, 8),
        ),
        Transaction(
          id: '5',
          type: TransactionType.expense,
          amount: Money.cents(5000),
          categoryId: 'food',
          accountId: 'cash',
          occurredAt: DateTime(2026, 4, 1, 8),
          createdAt: DateTime(2026, 4, 1, 8),
          updatedAt: DateTime(2026, 4, 1, 8),
        ),
      ],
    );

    final overview = OverviewController(transactionsController: txController);

    expect(overview.monthlyExpenseCents(DateTime(2026, 3, 15)), 5800);

    final top = overview.topCategories(DateTime(2026, 3, 15));
    expect(top.first.categoryId, 'food');
    expect(top.first.totalCents, 3000);
    expect(top[1].categoryId, 'transport');
    expect(top[1].totalCents, 2800);
  });
}

