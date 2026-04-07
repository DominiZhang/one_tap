import 'package:flutter/material.dart';

class CategoryQuickGrid extends StatelessWidget {
  const CategoryQuickGrid({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  final List<CategoryOption> categories;
  final String? selectedId;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in categories)
          ChoiceChip(
            key: Key('category-${category.id}'),
            label: Text(category.name),
            selected: selectedId == category.id,
            onSelected: (_) => onSelect(category.id),
          ),
      ],
    );
  }
}

class CategoryOption {
  const CategoryOption({required this.id, required this.name});

  final String id;
  final String name;
}

