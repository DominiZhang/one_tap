import 'package:flutter/material.dart';

class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('amount-input'),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: const InputDecoration(
        labelText: '金额',
        hintText: '0.00',
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}

