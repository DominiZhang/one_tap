import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/data/backup/backup_service.dart';
import 'package:one_tap_expense_tracker/domain/account.dart';
import 'package:one_tap_expense_tracker/domain/category.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

void main() {
  test('json export/import round-trip keeps core fields', () {
    final service = BackupService();
    final categories = const [
      Category(
        id: 'food',
        name: '餐饮',
        icon: 'restaurant',
        color: 0xFFEF5350,
        type: CategoryType.expense,
        sortOrder: 0,
      ),
    ];
    final accounts = const [
      Account(id: 'cash', name: '现金', type: AccountType.cash, sortOrder: 0),
    ];
    final transactions = [
      Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: Money.cents(1234),
        categoryId: 'food',
        accountId: 'cash',
        note: '午饭',
        occurredAt: DateTime(2026, 3, 16, 12),
        createdAt: DateTime(2026, 3, 16, 12),
        updatedAt: DateTime(2026, 3, 16, 12),
      ),
    ];

    final jsonText = service.exportJson(
      categories: categories,
      accounts: accounts,
      transactions: transactions,
    );

    final raw = jsonDecode(jsonText) as Map<String, dynamic>;
    expect(raw['schemaVersion'], BackupService.schemaVersion);

    final restored = service.importJson(jsonText);
    expect(restored.categories.length, 1);
    expect(restored.accounts.length, 1);
    expect(restored.transactions.length, 1);
    expect(restored.transactions.first.amount.cents, 1234);
    expect(restored.transactions.first.categoryId, 'food');
    expect(restored.transactions.first.accountId, 'cash');
    expect(restored.transactions.first.note, '午饭');
  });
}

