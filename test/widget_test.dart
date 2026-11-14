import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lumi_beauty/core/formatters.dart';
import 'package:lumi_beauty/widgets/common.dart';

void main() {
  group('formatVnd', () {
    test('them dau cham phan nghin', () {
      expect(formatVnd(0), '0₫');
      expect(formatVnd(999), '999₫');
      expect(formatVnd(1000), '1.000₫');
      expect(formatVnd(1250000), '1.250.000₫');
      expect(formatVnd(-30000), '-30.000₫');
    });

    test('usdToVnd lam tron den nghin', () {
      expect(usdToVnd(9.99), 250000);
      expect(usdToVnd(0.01), 0);
    });
  });

  testWidgets('QuantitySelector tang/giam va gioi han min-max', (tester) async {
    var value = 1;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => QuantitySelector(
              value: value,
              max: 3,
              onChanged: (v) => setState(() => value = v),
            ),
          ),
        ),
      ),
    );

    expect(find.text('1'), findsOneWidget);

    // Dang o min -> nut giam bi disable.
    await tester.tap(find.byKey(const Key('qty_decrease')));
    await tester.pump();
    expect(value, 1);

    for (var i = 0; i < 4; i++) {
      // bam 4 lan nhung max = 3 -> dung o 3
      await tester.tap(find.byKey(const Key('qty_increase')));
      await tester.pump();
    }

    expect(value, 3);
    expect(find.text('3'), findsOneWidget);
  });
}
