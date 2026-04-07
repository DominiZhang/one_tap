import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';
import 'package:one_tap_expense_tracker/ui/transactions/widgets/transaction_list_item.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key, required this.controller});

  final TransactionsController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final items = controller.sortedItems;
        return Scaffold(
          appBar: AppBar(title: const Text('明细')),
          body: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final currentDate = _dateKey(item);
              final previousDate =
                  index == 0 ? null : _dateKey(items[index - 1]);
              final showHeader = index == 0 || currentDate != previousDate;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (showHeader)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: Text(
                        currentDate,
                        style: Theme.of(context).textTheme.labelLarge,
                      ),
                    ),
                  Dismissible(
                    key: Key('dismiss-${item.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child:
                          const Icon(Icons.delete, color: Colors.white),
                    ),
                    onDismissed: (_) => controller.deleteById(item.id),
                    child: TransactionListItem(item: item),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  String _dateKey(Transaction item) {
    final dt = item.occurredAt;
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

