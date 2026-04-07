import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/state/accounts_controller.dart';

class AccountsPage extends StatefulWidget {
  const AccountsPage({super.key, required this.controller});

  final AccountsController controller;

  @override
  State<AccountsPage> createState() => _AccountsPageState();
}

class _AccountsPageState extends State<AccountsPage> {
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
          appBar: AppBar(title: const Text('账户管理')),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('account-add-input'),
                      controller: _addController,
                      decoration: const InputDecoration(
                        labelText: '新增账户',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    key: const Key('account-add-button'),
                    onPressed: () {
                      widget.controller.addAccount(_addController.text);
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
                (a) => ListTile(
                  key: Key('account-item-${a.id}'),
                  title: Text(a.name),
                  trailing: Wrap(
                    spacing: 8,
                    children: [
                      IconButton(
                        key: Key('account-rename-${a.id}'),
                        onPressed: () => _showRenameDialog(a.id, a.name),
                        icon: const Icon(Icons.edit_outlined),
                      ),
                      IconButton(
                        key: Key('account-archive-${a.id}'),
                        onPressed: () => widget.controller.archiveAccount(a.id),
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
                ...archived.map((a) => ListTile(title: Text(a.name))),
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
        title: const Text('重命名账户'),
        content: TextField(
          key: const Key('account-rename-input'),
          controller: controller,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('取消'),
          ),
          FilledButton(
            key: const Key('account-rename-confirm'),
            onPressed: () {
              widget.controller.renameAccount(id, controller.text);
              Navigator.of(context).pop();
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }
}

