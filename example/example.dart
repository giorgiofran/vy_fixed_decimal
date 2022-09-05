/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:decimal/decimal.dart';
import 'package:vy_fixed_decimal/src/fixed_decimal.dart';


void main() {
  var fixed = FixedDecimal.fromInt(5);
  var second = FixedDecimal.fromInt(3);

  FixedDecimal result;

  // simple addition
  result = fixed + FixedDecimal.fromInt(1);
  print(result); // 6

  // addition with int
  result = fixed + 1;
  print(result); // 6

  // addition with double using add function
  result = fixed.add(double.parse('2.3'), scale: 1);
  print(result); // 7.3

  // addition with double using add function
  result = FixedDecimal.addition(fixed, double.parse('2.3'), scale: 1);
  print(result); // 7.3

  // addition with double using add function
  result = FixedDecimal.addition(double.parse('2.3'), fixed, scale: 1);
  print(result); // 7.3

  // addition with double and int
  result = FixedDecimal.addition(double.parse('2.3'), 5, scale: 1);
  print(result); // 7.3

  print((FixedDecimal.parse(
              '31878018903828899277492024491376690701584023926880.0') +
          Decimal.parse('0.9'))
      .toString());
  // '31878018903828899277492024491376690701584023926881'

  print((FixedDecimal.parse(
              '31878018903828899277492024491376690701584023926880.0',
              scale: 1) +
          Decimal.parse('0.9'))
      .toString());
  // '31878018903828899277492024491376690701584023926880.9'

  print(FixedDecimal.addition(
          Decimal.parse('0.9'),
          FixedDecimal.parse(
              '31878018903828899277492024491376690701584023926880.0'))
      .toString());
  // '31878018903828899277492024491376690701584023926881'

  result = second - fixed;
  print(result); // -2
}
