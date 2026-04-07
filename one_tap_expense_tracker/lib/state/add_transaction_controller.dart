import 'package:flutter/foundation.dart';

class AddTransactionController extends ChangeNotifier {
  AddTransactionController({required this.onSave});

  final Future<void> Function(SaveTransactionInput input) onSave;

  String _amountText = '';
  String? _categoryId;
  bool _saving = false;

  String get amountText => _amountText;
  String? get categoryId => _categoryId;
  bool get saving => _saving;

  bool get canSave => _parseCents(_amountText) != null && _categoryId != null && !_saving;

  void updateAmountText(String value) {
    _amountText = value;
    notifyListeners();
  }

  void selectCategory(String id) {
    _categoryId = id;
    notifyListeners();
  }

  Future<void> save() async {
    final cents = _parseCents(_amountText);
    if (cents == null || _categoryId == null || _saving) return;

    _saving = true;
    notifyListeners();
    try {
      await onSave(
        SaveTransactionInput(
          amountCents: cents,
          categoryId: _categoryId!,
        ),
      );
      _amountText = '';
      // Keep selected category to optimize continuous entry.
    } finally {
      _saving = false;
      notifyListeners();
    }
  }

  int? _parseCents(String raw) {
    final text = raw.trim();
    if (text.isEmpty) return null;
    final value = double.tryParse(text);
    if (value == null || value <= 0) return null;
    return (value * 100).round();
  }
}

class SaveTransactionInput {
  const SaveTransactionInput({
    required this.amountCents,
    required this.categoryId,
  });

  final int amountCents;
  final String categoryId;
}

