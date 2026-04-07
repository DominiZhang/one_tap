import 'package:one_tap_expense_tracker/domain/category.dart';

abstract class CategoryRepository {
  List<Category> listAll();
}

class InMemoryCategoryRepository implements CategoryRepository {
  InMemoryCategoryRepository(this._items);

  final List<Category> _items;

  @override
  List<Category> listAll() => List<Category>.from(_items);
}

