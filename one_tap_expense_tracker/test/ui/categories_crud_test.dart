import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/category.dart';
import 'package:one_tap_expense_tracker/state/categories_controller.dart';
import 'package:one_tap_expense_tracker/ui/settings/categories/categories_page.dart';

void main() {
  testWidgets('can add rename and archive category', (tester) async {
    final controller = CategoriesController(
      seed: const [
        Category(
          id: 'food',
          name: '餐饮',
          icon: 'restaurant',
          color: 0xFFEF5350,
          type: CategoryType.expense,
          sortOrder: 0,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(home: CategoriesPage(controller: controller)),
    );

    await tester.enterText(find.byKey(const Key('category-add-input')), '宠物');
    await tester.tap(find.byKey(const Key('category-add-button')));
    await tester.pumpAndSettle();
    expect(find.text('宠物'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-rename-food')));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('rename-input')), '吃饭');
    await tester.tap(find.byKey(const Key('rename-confirm')));
    await tester.pumpAndSettle();
    expect(find.text('吃饭'), findsOneWidget);

    await tester.tap(find.byKey(const Key('category-archive-food')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('category-item-food')), findsNothing);
    expect(find.text('已归档'), findsOneWidget);
  });
}

