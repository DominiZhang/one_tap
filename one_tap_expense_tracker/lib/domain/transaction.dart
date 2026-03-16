import 'money.dart';

enum TransactionType { expense, income, transfer }

class Transaction {
  final String id;
  final TransactionType type;
  final Money amount;
  final String? categoryId;
  final String? accountId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? note;
  final DateTime occurredAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.occurredAt,
    required this.createdAt,
    required this.updatedAt,
    this.categoryId,
    this.accountId,
    this.fromAccountId,
    this.toAccountId,
    this.note,
    this.deletedAt,
  }) {
    if (amount.cents <= 0) {
      throw ArgumentError.value(amount.cents, 'amount.cents', 'must be > 0');
    }

    if (type == TransactionType.expense || type == TransactionType.income) {
      if (categoryId == null || categoryId!.isEmpty) {
        throw ArgumentError('categoryId is required for $type');
      }
      if (accountId == null || accountId!.isEmpty) {
        throw ArgumentError('accountId is required for $type');
      }
    }
  }
}

