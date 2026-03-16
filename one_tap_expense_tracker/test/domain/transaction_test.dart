import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

void main() {
  group('Transaction', () {
    test('amount must be positive', () {
      expect(
        () => Transaction(
          id: 't1',
          type: TransactionType.expense,
          amount: Money.cents(0),
          categoryId: 'c1',
          accountId: 'a1',
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('expense must have categoryId and accountId', () {
      expect(
        () => Transaction(
          id: 't2',
          type: TransactionType.expense,
          amount: Money.cents(100),
          categoryId: null,
          accountId: 'a1',
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsArgumentError,
      );

      expect(
        () => Transaction(
          id: 't3',
          type: TransactionType.expense,
          amount: Money.cents(100),
          categoryId: 'c1',
          accountId: null,
          occurredAt: DateTime.now(),
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        throwsArgumentError,
      );
    });

    test('valid expense is created successfully', () {
      final now = DateTime.now();
      final tx = Transaction(
        id: 'ok',
        type: TransactionType.expense,
        amount: Money.cents(1234),
        categoryId: 'food',
        accountId: 'cash',
        note: 'lunch',
        occurredAt: now,
        createdAt: now,
        updatedAt: now,
      );

      expect(tx.id, 'ok');
      expect(tx.amount.cents, 1234);
      expect(tx.categoryId, 'food');
      expect(tx.accountId, 'cash');
      expect(tx.type, TransactionType.expense);
    });
  });
}

