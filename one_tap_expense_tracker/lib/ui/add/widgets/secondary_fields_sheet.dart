import 'package:flutter/material.dart';

class SecondaryFieldsSheet extends StatelessWidget {
  const SecondaryFieldsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return const ExpansionTile(
      title: Text('更多字段（可选）'),
      children: [
        ListTile(title: Text('账户：默认账户（MVP）')),
        ListTile(title: Text('备注：待实现')),
        ListTile(title: Text('时间：当前时间（MVP）')),
      ],
    );
  }
}

