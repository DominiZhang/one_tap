import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/domain/category.dart';
import 'package:one_tap_expense_tracker/domain/account.dart';
import 'package:one_tap_expense_tracker/state/add_transaction_controller.dart';
import 'package:one_tap_expense_tracker/state/accounts_controller.dart';
import 'package:one_tap_expense_tracker/state/categories_controller.dart';
import 'package:one_tap_expense_tracker/ui/add/widgets/amount_input.dart';
import 'package:one_tap_expense_tracker/ui/add/widgets/category_quick_grid.dart';
import 'package:one_tap_expense_tracker/ui/add/widgets/secondary_fields_sheet.dart';
import 'package:one_tap_expense_tracker/ui/settings/accounts/accounts_page.dart';
import 'package:one_tap_expense_tracker/ui/settings/backup/backup_page.dart';
import 'package:one_tap_expense_tracker/ui/settings/categories/categories_page.dart';

class AddTransactionPage extends StatefulWidget {
  const AddTransactionPage({
    super.key,
    required this.controller,
  });

  final AddTransactionController controller;

  @override
  State<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  late final TextEditingController _amountController;
  late final CategoriesController _categoriesController;
  late final AccountsController _accountsController;

  static const _defaultCategories = <CategoryOption>[
    CategoryOption(id: 'food', name: '餐饮'),
    CategoryOption(id: 'transport', name: '交通'),
    CategoryOption(id: 'shopping', name: '购物'),
    CategoryOption(id: 'entertainment', name: '娱乐'),
  ];

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.controller.amountText);
    _categoriesController = CategoriesController(
      seed: const [
        Category(
          id: 'food',
          name: '餐饮',
          icon: 'restaurant',
          color: 0xFFEF5350,
          type: CategoryType.expense,
          sortOrder: 0,
        ),
        Category(
          id: 'transport',
          name: '交通',
          icon: 'directions_bus',
          color: 0xFF42A5F5,
          type: CategoryType.expense,
          sortOrder: 1,
        ),
      ],
    );
    _accountsController = AccountsController(
      seed: const [
        Account(id: 'cash', name: '现金', type: AccountType.cash, sortOrder: 0),
        Account(id: 'wechat', name: '微信', type: AccountType.wechat, sortOrder: 1),
      ],
    );
    widget.controller.addListener(_syncAmountText);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_syncAmountText);
    _amountController.dispose();
    super.dispose();
  }

  void _syncAmountText() {
    if (_amountController.text != widget.controller.amountText) {
      _amountController.value = TextEditingValue(
        text: widget.controller.amountText,
        selection: TextSelection.collapsed(offset: widget.controller.amountText.length),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('快速记一笔'),
            actions: [
              IconButton(
                icon: const Icon(Icons.category_outlined),
                tooltip: '类别管理',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => CategoriesPage(controller: _categoriesController),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.account_balance_wallet_outlined),
                tooltip: '账户管理',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AccountsPage(controller: _accountsController),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.backup_outlined),
                tooltip: '备份与恢复',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const BackupPage()),
                  );
                },
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AmountInput(
                  controller: _amountController,
                  onChanged: widget.controller.updateAmountText,
                ),
                const SizedBox(height: 12),
                CategoryQuickGrid(
                  categories: _defaultCategories,
                  selectedId: widget.controller.categoryId,
                  onSelect: widget.controller.selectCategory,
                ),
                const SizedBox(height: 12),
                const SecondaryFieldsSheet(),
                const Spacer(),
                FilledButton(
                  key: const Key('save-button'),
                  onPressed: widget.controller.canSave ? widget.controller.save : null,
                  child: Text(widget.controller.saving ? '保存中...' : '保存'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

