import 'package:one_tap_expense_tracker/domain/account.dart';

abstract class AccountRepository {
  List<Account> listAll();
}

class InMemoryAccountRepository implements AccountRepository {
  InMemoryAccountRepository(this._items);

  final List<Account> _items;

  @override
  List<Account> listAll() => List<Account>.from(_items);
}

