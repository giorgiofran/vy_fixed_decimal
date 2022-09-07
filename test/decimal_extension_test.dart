/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:test/test.dart';
import 'package:vy_fixed_decimal/src/linear_regression.dart';
import 'package:vy_fixed_decimal/src/utils/decimal_point.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

Decimal dec(String value) => Decimal.parse(value);

void main() {
  test('Min', () {
    expect(dec('3.0').min(dec('3.1')), dec('3.0'));
    expect(dec('3.2').min(dec('3.1')), dec('3.1'));
    expect(dec('-3.2').min(dec('-3.1')), dec('-3.2'));
    expect(dec('-3.0').min(dec('-3.1')), dec('-3.1'));
  });

  test('Max', () {
    expect(dec('3.0').max(dec('3.1')), dec('3.1'));
    expect(dec('3.2').max(dec('3.1')), dec('3.2'));
    expect(dec('-3.2').max(dec('-3.1')), dec('-3.1'));
    expect(dec('-3.0').max(dec('-3.1')), dec('-3.0'));
  });

  test('Pow Test', () {
    expect(dec('3.0').pow(2), dec('9.0'));
    expect(dec('3.0').power(2), dec('9.0'));
    expect(dec('3.0').power(-2), Decimal.one.safeDivBy(dec('9.0')));
    expect(dec('3.0').power(0), Decimal.one);
    expect(dec('3.0').power(12), dec('531441'));
    expect(dec('141.0').pow(7), dec('1107984764452581'));
    expect(dec('141').power(7), dec('1107984764452581'));
    expect(dec('20').power(-22),
        dec('0.00000000000000000000000000002384185791015625'));
    /* expect(Decimal.fromInt(3).pow(-2), dec('0.1111111111'),
        skip: 'To be checked with the next version of Decimal'); */
  });

  test('Decimal point', () {
    final point = DecimalPoint(5, 7.0);
    expect(point.x, Decimal.parse('5.0'));
    expect(point.y, Decimal.parse('7.0'));
  });

  group('Decimal regression', () {
    final points = <DecimalPoint>[
      DecimalPoint(62, 164),
      DecimalPoint(64, 178),
      DecimalPoint(68, 176),
      DecimalPoint(75, 178),
      DecimalPoint(78, 182),
      DecimalPoint(80, 180),
      DecimalPoint(84, 182),
      DecimalPoint(89, 184),
    ];
    final reg = LinearRegression(points);
    //reg.calculate();
    test('Mean Point', () {
      expect(reg.meanPoint, DecimalPoint(75, 178));
    });
    test('Delta values', () {
      expect(reg.meanDeltaX2, Decimal.parse('81.25'));
      expect(reg.meanDeltaY2, Decimal.parse('34'));
      expect(reg.meanDeltaProduct, Decimal.parse('42.25'));
    });
    test('Line coefficients', () {
      expect(reg.a, Decimal.parse('139.0'));
      expect(reg.b, Decimal.parse('0.52'));
    });
    test('Coefficient of determination', () {
      expect(reg.coefficientOfDetermination.toStringAsFixed(10),
          Decimal.parse('0.6461764706').toStringAsFixed(10));
    });
  });
}
