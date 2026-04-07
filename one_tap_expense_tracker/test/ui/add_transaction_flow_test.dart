import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/state/add_transaction_controller.dart';
import 'package:one_tap_expense_tracker/ui/add/add_transaction_page.dart';

void main() {
  testWidgets('input amount + pick category + save writes record and clears amount',
      (tester) async {
    SaveTransactionInput? savedInput;
    final controller = AddTransactionController(
      onSave: (input) async {
        savedInput = input;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        home: AddTransactionPage(controller: controller),
      ),
    );

    final saveButton = find.byKey(const Key('save-button'));
    expect(tester.widget<FilledButton>(saveButton).onPressed, isNull);

    await tester.enterText(find.byKey(const Key('amount-input')), '12.34');
    await tester.tap(find.byKey(const Key('category-food')));
    await tester.pump();

    expect(tester.widget<FilledButton>(saveButton).onPressed, isNotNull);

    await tester.tap(saveButton);
    await tester.pumpAndSettle();

    expect(savedInput, isNotNull);
    expect(savedInput!.amountCents, 1234);
    expect(savedInput!.categoryId, 'food');
    expect(find.text('12.34'), findsNothing);
  });
}

