import 'dart:convert';

import 'package:one_tap_expense_tracker/domain/account.dart';
import 'package:one_tap_expense_tracker/domain/category.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';
import 'package:one_tap_expense_tracker/domain/transaction.dart';

class BackupService {
  static const int schemaVersion = 1;

  String exportJson({
    required List<Category> categories,
    required List<Account> accounts,
    required List<Transaction> transactions,
  }) {
    final payload = <String, dynamic>{
      'schemaVersion': schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'categories': categories.map(_categoryToMap).toList(),
      'accounts': accounts.map(_accountToMap).toList(),
      'transactions': transactions.map(_transactionToMap).toList(),
    };
    return jsonEncode(payload);
  }

  BackupData importJson(String jsonText) {
    final raw = jsonDecode(jsonText) as Map<String, dynamic>;
    final version = raw['schemaVersion'] as int?;
    if (version != schemaVersion) {
      throw FormatException('Unsupported schemaVersion: $version');
    }

    final categories = ((raw['categories'] ?? []) as List)
        .map((e) => _categoryFromMap((e as Map).cast<String, dynamic>()))
        .toList();
    final accounts = ((raw['accounts'] ?? []) as List)
        .map((e) => _accountFromMap((e as Map).cast<String, dynamic>()))
        .toList();
    final transactions = ((raw['transactions'] ?? []) as List)
        .map((e) => _transactionFromMap((e as Map).cast<String, dynamic>()))
        .toList();

    return BackupData(
      categories: categories,
      accounts: accounts,
      transactions: transactions,
    );
  }

  String exportTransactionsCsv(List<Transaction> transactions) {
    final rows = <String>['date,type,amount,category,account,note'];
    for (final t in transactions) {
      rows.add(
        [
          t.occurredAt.toIso8601String(),
          t.type.name,
          (t.amount.cents / 100).toStringAsFixed(2),
          _escapeCsv(t.categoryId ?? ''),
          _escapeCsv(t.accountId ?? ''),
          _escapeCsv(t.note ?? ''),
        ].join(','),
      );
    }
    return '${rows.join('\n')}\n';
  }

  Map<String, dynamic> _categoryToMap(Category c) => {
        'id': c.id,
        'name': c.name,
        'icon': c.icon,
        'color': c.color,
        'type': c.type.name,
        'sortOrder': c.sortOrder,
        'isArchived': c.isArchived,
      };

  Category _categoryFromMap(Map<String, dynamic> m) => Category(
        id: m['id'] as String,
        name: m['name'] as String,
        icon: m['icon'] as String,
        color: m['color'] as int,
        type: CategoryType.values.byName(m['type'] as String),
        sortOrder: m['sortOrder'] as int,
        isArchived: (m['isArchived'] as bool?) ?? false,
      );

  Map<String, dynamic> _accountToMap(Account a) => {
        'id': a.id,
        'name': a.name,
        'type': a.type.name,
        'sortOrder': a.sortOrder,
        'isArchived': a.isArchived,
      };

  Account _accountFromMap(Map<String, dynamic> m) => Account(
        id: m['id'] as String,
        name: m['name'] as String,
        type: AccountType.values.byName(m['type'] as String),
        sortOrder: m['sortOrder'] as int,
        isArchived: (m['isArchived'] as bool?) ?? false,
      );

  Map<String, dynamic> _transactionToMap(Transaction t) => {
        'id': t.id,
        'type': t.type.name,
        'amountCents': t.amount.cents,
        'categoryId': t.categoryId,
        'accountId': t.accountId,
        'fromAccountId': t.fromAccountId,
        'toAccountId': t.toAccountId,
        'note': t.note,
        'occurredAt': t.occurredAt.toIso8601String(),
        'createdAt': t.createdAt.toIso8601String(),
        'updatedAt': t.updatedAt.toIso8601String(),
        'deletedAt': t.deletedAt?.toIso8601String(),
      };

  Transaction _transactionFromMap(Map<String, dynamic> m) => Transaction(
        id: m['id'] as String,
        type: TransactionType.values.byName(m['type'] as String),
        amount: Money.cents(m['amountCents'] as int),
        categoryId: m['categoryId'] as String?,
        accountId: m['accountId'] as String?,
        fromAccountId: m['fromAccountId'] as String?,
        toAccountId: m['toAccountId'] as String?,
        note: m['note'] as String?,
        occurredAt: DateTime.parse(m['occurredAt'] as String),
        createdAt: DateTime.parse(m['createdAt'] as String),
        updatedAt: DateTime.parse(m['updatedAt'] as String),
        deletedAt:
            m['deletedAt'] == null ? null : DateTime.parse(m['deletedAt'] as String),
      );

  String _escapeCsv(String value) {
    if (!value.contains(',') && !value.contains('"') && !value.contains('\n')) {
      return value;
    }
    return '"${value.replaceAll('"', '""')}"';
  }
}

class BackupData {
  const BackupData({
    required this.categories,
    required this.accounts,
    required this.transactions,
  });

  final List<Category> categories;
  final List<Account> accounts;
  final List<Transaction> transactions;
}

