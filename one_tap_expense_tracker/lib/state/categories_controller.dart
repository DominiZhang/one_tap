import 'package:flutter/foundation.dart' show ChangeNotifier;
import 'package:one_tap_expense_tracker/domain/category.dart' as model;

class CategoriesController extends ChangeNotifier {
  CategoriesController({required List<model.Category> seed})
      : _items = List<model.Category>.from(seed);

  final List<model.Category> _items;
  int _counter = 0;

  List<model.Category> get activeItems =>
      _items.where((c) => !c.isArchived).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  List<model.Category> get archivedItems =>
      _items.where((c) => c.isArchived).toList()
        ..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

  void addCategory(String name,
      {model.CategoryType type = model.CategoryType.expense}) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    final nextOrder = _items.length;
    _items.add(
      model.Category(
        id: 'custom-${_counter++}',
        name: trimmed,
        icon: 'category',
        color: 0xFF00897B,
        type: type,
        sortOrder: nextOrder,
      ),
    );
    notifyListeners();
  }

  void renameCategory(String id, String newName) {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) return;
    final index = _items.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final current = _items[index];
    _items[index] = model.Category(
      id: current.id,
      name: trimmed,
      icon: current.icon,
      color: current.color,
      type: current.type,
      sortOrder: current.sortOrder,
      isArchived: current.isArchived,
    );
    notifyListeners();
  }

  void archiveCategory(String id) {
    final index = _items.indexWhere((c) => c.id == id);
    if (index < 0) return;
    final current = _items[index];
    if (current.isArchived) return;
    _items[index] = model.Category(
      id: current.id,
      name: current.name,
      icon: current.icon,
      color: current.color,
      type: current.type,
      sortOrder: current.sortOrder,
      isArchived: true,
    );
    notifyListeners();
  }
}

