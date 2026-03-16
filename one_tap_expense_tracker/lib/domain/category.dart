class Category {
  final String id;
  final String name;
  final String icon;
  final int color;
  final CategoryType type;
  final int sortOrder;
  final bool isArchived;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.type,
    required this.sortOrder,
    this.isArchived = false,
  });
}

enum CategoryType { expense, income }

