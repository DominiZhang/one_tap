import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';
import 'package:one_tap_expense_tracker/ui/transactions/transactions_page.dart';

void main() {
  testWidgets('can delete and copy transactions from list', (tester) async {
    final controller = TransactionsController(
      seedItems: [
        Transaction(
          id: 't1',
          type: TransactionType.expense,
          amount: Money.cents(1000),
          categoryId: 'food',
          accountId: 'cash',
          note: '午餐',
          occurredAt: DateTime(2026, 3, 16, 12),
          createdAt: DateTime(2026, 3, 16, 12),
          updatedAt: DateTime(2026, 3, 16, 12),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionsPage(controller: controller)),
    );

    // 先复制
    controller.copyById(
      't1',
      DateTime(2026, 3, 16, 13),
    );
    await tester.pumpAndSettle();

    expect(find.text('午餐'), findsNWidgets(2));

    // 再删除原记录
    await tester.drag(
      find.byKey(const Key('dismiss-t1')),
      const Offset(-500, 0),
    );
    await tester.pumpAndSettle();

    expect(find.text('午餐'), findsOneWidget);
  });
}

