import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/state/categories_controller.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key, required this.controller});

  final CategoriesController controller;

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  final _addController = TextEditingController();

  @override
  void dispose() {
    _addController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.controller,
      builder: (context, _) {
        final active = widget.controller.activeItems;
        final archived = widget.controller.archivedItems;
        return Scaffold(
          appBar: AppBar(title: const Text('类别管理')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('category-add-input'),
                      controller: _addController,
                      decoration: const InputDecoration(
                        labelText: '新增类别',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('category-add-button'),
                    onPressed: () {
                      widget.controller.addCategory(_addController.text);
                      _addController.clear();
                    },
                    child: const Text('添加'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('启用中'),
              const SizedBox(height: 8),
              ...active.map(
                (c) => ListTile(
                  key: Key('category-item-${c.id}'),
                  title: Text(c.name),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        key: Key('category-rename-${c.id}'),
                        onPressed: () => _showRenameDialog(c.id, c.name),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        key: Key('category-archive-${c.id}'),
                        onPressed: () => widget.controller.archiveCategory(c.id),
                        icon: const Icon(Icons.archive_outlined),
                      ),
                    ],
                  ),
                ),
              ),
              if (archived.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('已归档'),
                const SizedBox(height: 8),
                ...archived.map((c) => ListTile(title: Text(c.name))),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showRenameDialog(String id, String oldName) async {
    final controller = TextEditingController(text: oldName);
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('重命名类别'),
        content: TextField(
          key: const Key('rename-input'),
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('rename-confirm'),
            onPressed: () {
              widget.controller.renameCategory(id, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

