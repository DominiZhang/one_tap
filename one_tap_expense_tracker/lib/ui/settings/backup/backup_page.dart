import 'package:flutter/material.dart';

class BackupPage extends StatelessWidget {
  const BackupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('备份与恢复')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('导出 JSON'),
            subtitle: Text('导出包含 schemaVersion 的完整数据'),
          ),
          ListTile(
            title: Text('导入 JSON'),
            subtitle: Text('覆盖导入（MVP）'),
          ),
        ],
      ),
    );
  }
}

