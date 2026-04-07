import 'package:flutter/foundation.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';
import 'package:one_tap_expense_tracker/state/transactions_controller.dart';

class OverviewController extends ChangeNotifier {
  OverviewController({required this.transactionsController});

  final TransactionsController transactionsController;

  int monthlyExpenseCents(DateTime month) {
    final monthStart = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    return transactionsController.allItems
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.occurredAt.isBefore(monthStart) &&
            t.occurredAt.isBefore(nextMonth))
        .fold<int>(0, (sum, t) => sum + t.amount.cents);
  }

  List<CategoryTotal> topCategories(DateTime month, {int limit = 5}) {
    final monthStart = DateTime(month.year, month.month, 1);
    final nextMonth = DateTime(month.year, month.month + 1, 1);

    final bucket = <String, int>{};
    for (final t in transactionsController.allItems) {
      if (t.type != TransactionType.expense) continue;
      if (t.occurredAt.isBefore(monthStart) || !t.occurredAt.isBefore(nextMonth)) {
        continue;
      }
      final key = t.categoryId ?? 'unknown';
      bucket[key] = (bucket[key] ?? 0) + t.amount.cents;
    }

    final list = bucket.entries
        .map((e) => CategoryTotal(categoryId: e.key, totalCents: e.value))
        .toList()
      ..sort((a, b) => b.totalCents.compareTo(a.totalCents));

    return list.take(limit).toList();
  }

  List<DailyTotal> dailyExpenseTrend({
    required DateTime endDate,
    required int days,
  }) {
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final start = end.subtract(Duration(days: days - 1));
    final bucket = <String, int>{};

    for (final t in transactionsController.allItems) {
      if (t.type != TransactionType.expense) continue;
      final day = DateTime(t.occurredAt.year, t.occurredAt.month, t.occurredAt.day);
      if (day.isBefore(start) || day.isAfter(end)) continue;
      final key = _dateKey(day);
      bucket[key] = (bucket[key] ?? 0) + t.amount.cents;
    }

    final result = <DailyTotal>[];
    for (var i = 0; i < days; i++) {
      final day = start.add(Duration(days: i));
      final key = _dateKey(day);
      result.add(DailyTotal(dateKey: key, totalCents: bucket[key] ?? 0));
    }
    return result;
  }

  String _dateKey(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

class CategoryTotal {
  const CategoryTotal({required this.categoryId, required this.totalCents});

  final String categoryId;
  final int totalCents;
}

class DailyTotal {
  const DailyTotal({required this.dateKey, required this.totalCents});

  final String dateKey;
  final int totalCents;
}

