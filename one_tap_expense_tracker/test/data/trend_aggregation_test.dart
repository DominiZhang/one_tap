import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/overview_controller.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';

void main() {
  test('builds daily trend with zero-filled missing days', () {
    final txController = TransactionsController(
      seedItems: [
        Transaction(
          id: 'd1',
          type: TransactionType.expense,
          amount: Money.cents(1000),
          categoryId: 'food',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 10, 8),
          createdAt: DateTime(2026, 3, 10, 8),
          updatedAt: DateTime(2026, 3, 10, 8),
        ),
        Transaction(
          id: 'd2',
          type: TransactionType.expense,
          amount: Money.cents(500),
          categoryId: 'food',
          accountId: 'cash',
          occurredAt: DateTime(2026, 3, 12, 9),
          createdAt: DateTime(2026, 3, 12, 9),
          updatedAt: DateTime(2026, 3, 12, 9),
        ),
      ],
    );

    final overview = OverviewController(transactionsController: txController);
    final trend = overview.dailyExpenseTrend(
      endDate: DateTime(2026, 3, 12),
      days: 3,
    );

    expect(trend.length, 3);
    expect(trend[0].dateKey, '2026-03-10');
    expect(trend[0].totalCents, 1000);
    expect(trend[1].dateKey, '2026-03-11');
    expect(trend[1].totalCents, 0);
    expect(trend[2].dateKey, '2026-03-12');
    expect(trend[2].totalCents, 500);
  });
}

