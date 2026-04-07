import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/state/overview_controller.dart';

class OverviewPage extends StatelessWidget {
  const OverviewPage({super.key, required this.controller});

  final OverviewController controller;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final total = controller.monthlyExpenseCents(now);
    final top = controller.topCategories(now, limit: 5);
    final trend7 = controller.dailyExpenseTrend(endDate: now, days: 7);

    return Scaffold(
      appBar: AppBar(title: const Text('概览')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              title: const Text('本月支出'),
              subtitle: Text('¥${(total / 100).toStringAsFixed(2)}'),
            ),
          ),
          const SizedBox(height: 12),
          const Text('Top 类别'),
          const SizedBox(height: 8),
          if (top.isEmpty)
            const Text('本月暂无支出')
          else
            ...top.map(
              (item) => ListTile(
                dense: true,
                title: Text(item.categoryId),
                trailing: Text('¥${(item.totalCents / 100).toStringAsFixed(2)}'),
              ),
            ),
          const SizedBox(height: 12),
          const Text('近 7 天趋势'),
          const SizedBox(height: 8),
          ...trend7.map(
            (d) => ListTile(
              dense: true,
              title: Text(d.dateKey),
              trailing: Text('¥${(d.totalCents / 100).toStringAsFixed(2)}'),
            ),
          ),
        ],
      ),
    );
  }
}

