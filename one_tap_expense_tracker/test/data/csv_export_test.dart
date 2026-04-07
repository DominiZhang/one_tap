import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/data/backup/backup_service.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

void main() {
  test('exports transaction csv with required columns and data', () {
    final service = BackupService();
    final csv = service.exportTransactionsCsv([
      Transaction(
        id: 't1',
        type: TransactionType.expense,
        amount: Money.cents(1234),
        categoryId: 'food',
        accountId: 'cash',
        note: '午饭',
        occurredAt: DateTime(2026, 3, 16, 12, 30),
        createdAt: DateTime(2026, 3, 16, 12, 30),
        updatedAt: DateTime(2026, 3, 16, 12, 30),
      ),
    ]);

    final lines = csv.trim().split('\n');
    expect(lines.first, 'date,type,amount,category,account,note');
    expect(lines.length, 2);
    expect(lines.last.contains('2026-03-16T12:30:00.000'), isTrue);
    expect(lines.last.contains('expense'), isTrue);
    expect(lines.last.contains('12.34'), isTrue);
    expect(lines.last.contains('food'), isTrue);
    expect(lines.last.contains('cash'), isTrue);
    expect(lines.last.contains('午饭'), isTrue);
  });
}

