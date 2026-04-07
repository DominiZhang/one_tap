import 'package:flutter/material.dart';
import 'package:one_tap_expense_tracker/ui/nav/root_scaffold.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'One Tap Expense Tracker',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal)),
      home: const RootScaffold(),
    );
  }
}

