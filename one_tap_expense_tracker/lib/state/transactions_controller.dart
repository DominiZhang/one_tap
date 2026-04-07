import 'package:flutter/foundation.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

class TransactionsController extends ChangeNotifier {
  TransactionsController({required List<Transaction> seedItems})
      : _items = List<Transaction>.from(seedItems);

  final List<Transaction> _items;

  List<Transaction> get allItems => List<Transaction>.unmodifiable(_items);

  List<Transaction> get sortedItems {
    final list = List<Transaction>.from(_items);
    list.sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return list;
  }

  void deleteById(String id) {
    _items.removeWhere((t) => t.id == id);
    notifyListeners();
  }

  void copyById(String id, DateTime now) {
    final original = _items.firstWhere((t) => t.id == id);
    final copy = Transaction(
      id: '${original.id}-${now.microsecondsSinceEpoch}',
      type: original.type,
      amount: original.amount,
      categoryId: original.categoryId,
      accountId: original.accountId,
      fromAccountId: original.fromAccountId,
      toAccountId: original.toAccountId,
      note: original.note,
      occurredAt: now,
      createdAt: now,
      updatedAt: now,
    );
    _items.add(copy);
    notifyListeners();
  }
}

