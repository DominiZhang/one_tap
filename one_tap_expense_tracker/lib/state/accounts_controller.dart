import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:one_tap_expense_tracker/domain/account.dart' as model;

class AccountsController extends ChangeNotifier {
  AccountsController({required List<model.Account> seed})
      : _items = List<model.Account>.from(seed);

  final List<model.Account> _items;
  int _counter = 0;

  List<model.Account> get activeItems =>
      _items.where((a) => !a.isArchived).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<model.Account> get archivedItems =>
      _items.where((a) => a.isArchived).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  void addAccount(String name, {model.AccountType type = model.AccountType.custom}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _items.add(
      model.Account(
        id: 'account-${_counter++}',
        name: trimmed,
        type: type,
        sortOrder: _items.length,
      ),
    );
    notifyListeners();
  }

  void renameAccount(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final index = _items.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = model.Account(
      id: current.id,
      name: trimmed,
      type: current.type,
      sortOrder: current.sortOrder,
      isArchived: current.isArchived,
    );
    notifyListeners();
  }

  void archiveAccount(String id) {
    final index = _items.indexWhere((a) => a.id == id);
    if (index < 0) return;
    final current = _items[index];
    if (current.isArchived) return;
    _items[index] = model.Account(
      id: current.id,
      name: current.name,
      type: current.type,
      sortOrder: current.sortOrder,
      isArchived: true,
    );
    notifyListeners();
  }
}

