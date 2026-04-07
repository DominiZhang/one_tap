import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/add_transaction_controller.dart';
import 'package:one_tap_expense_tracker/state/overview_controller.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';
import 'package:one_tap_expense_tracker/ui/add/add_transaction_page.dart';
import 'package:one_tap_expense_tracker/ui/overview/overview_page.dart';
import 'package:one_tap_expense_tracker/ui/transactions/transactions_page.dart';

class RootScaffold extends StatefulWidget {
  const RootScaffold({super.key});

  @override
  State<RootScaffold> createState() => _RootScaffoldState();
}

class _RootScaffoldState extends State<RootScaffold> {
  int _selectedIndex = 0;
  late final TransactionsController _transactionsController;
  late final OverviewController _overviewController;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _transactionsController = TransactionsController(
      seedItems: [
        Transaction(
          id: 'seed-1',
          type: TransactionType.expense,
          amount: Money.cents(3600),
          categoryId: 'food',
          accountId: 'cash',
          note: '午餐',
          occurredAt: now.subtract(const Duration(hours: 1)),
          createdAt: now,
          updatedAt: now,
        ),
        Transaction(
          id: 'seed-2',
          type: TransactionType.expense,
          amount: Money.cents(1800),
          categoryId: 'transport',
          accountId: 'cash',
          note: '地铁',
          occurredAt: now.subtract(const Duration(days: 1)),
          createdAt: now,
          updatedAt: now,
        ),
      ],
    );
    _overviewController =
        OverviewController(transactionsController: _transactionsController);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      AddTransactionPage(
        controller: AddTransactionController(onSave: (input) async {
          // Database write will be added in data layer tasks.
          return;
        }),
      ),
      TransactionsPage(controller: _transactionsController),
      OverviewPage(controller: _overviewController),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.add_circle_outline), label: '记账'),
          BottomNavigationBarItem(icon: Icon(Icons.list_alt_outlined), label: '明细'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: '概览'),
        ],
      ),
    );
  }
}

