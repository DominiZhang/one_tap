import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/domain/money.dart';

void main() {
  group('Money', () {
    test('stores amount in minor units (cents)', () {
      final m = Money.cents(1234);
      expect(m.cents, 1234);
    });
  });
}

