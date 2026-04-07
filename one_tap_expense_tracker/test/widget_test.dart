import 'package:flutter_test/flutter_test.dart';
import 'package:one_tap_expense_tracker/app/app.dart';

void main() {
  testWidgets('shows 3 bottom tabs and can switch tabs', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('记账'), findsOneWidget);
    expect(find.text('明细'), findsOneWidget);
    expect(find.text('概览'), findsOneWidget);

    expect(find.text('快速记一笔'), findsOneWidget);

    await tester.tap(find.text('明细'));
    await tester.pump();
    expect(find.text('明细'), findsNWidgets(2));

    await tester.tap(find.text('概览'));
    await tester.pump();
    expect(find.text('本月支出'), findsOneWidget);
  });
}
