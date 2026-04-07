import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

class TransactionListItem extends StatelessWidget {
  const TransactionListItem({super.key, required this.item});

  final Transaction item;

  @override
  Widget build(BuildContext context) {
    final amount = (item.amount.cents / 100).toStringAsFixed(2);
    return ListTile(
      key: Key('transaction-${item.id}'),
      title: Text(item.note?.isNotEmpty == true ? item.note! : '未命名账目'),
      subtitle: Text(item.categoryId ?? '-'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('¥$amount'),
          PopupMenuButton<String>(
            key: Key('more-${item.id}'),
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'copy',
                child: Text('复制'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

