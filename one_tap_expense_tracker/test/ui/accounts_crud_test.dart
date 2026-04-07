import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/account.dart';
import 'package:one_tap_expense_tracker/state/accounts_controller.dart';
import 'package:one_tap_expense_tracker/ui/settings/accounts/accounts_page.dart';

void main() {
  testWidgets('can add rename and archive account', (tester) async {
    final controller = AccountsController(
      seed: const [
        Account(id: 'cash', name: '现金', type: AccountType.cash, sortOrder: 0),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: AccountsPage(controller: controller)),
    );

    await tester.enterText(find.byKey(const Key('account-add-input')), '招行卡');
    await tester.tap(find.byKey(const Key('account-add-button')));
    await tester.pumpAndSettle();
    expect(find.text('招行卡'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-rename-cash')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('account-rename-input')), '钱包');
    await tester.tap(find.byKey(const Key('account-rename-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('钱包'), findsOneWidget);

    await tester.tap(find.byKey(const Key('account-archive-cash')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('account-item-cash')), findsNothing);
    expect(find.text('已归档'), findsOneWidget);
  });
}

