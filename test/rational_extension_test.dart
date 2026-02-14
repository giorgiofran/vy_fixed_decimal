/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.
library;

import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:test/test.dart';
import 'package:vy_fixed_decimal/src/extension/rational_extension.dart';

Rational r(String value) => Rational.parse(value);

//Todo write RationalExtension test

void main() {
  test('roundToDecimal', () {
    expect((r('2') / r('3')).toDecimal(scaleOnInfinitePrecision: 5).toString(),
        '0.66666');
    expect(
        (r('2') / r('3'))
            .roundToDecimal(scaleOnInfinitePrecision: 5)
            .toString(),
        '0.66667');
  });
}
