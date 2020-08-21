/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:vy_fixed_decimal/src/decimal_formatter.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

void main() {
  group('generic', () {
    test('Decimal duplication', () {
      final t1 = Decimal.fromInt(5);
      var t2 = t1;

      expect(t1, t2);
      expect(identical(t1, t2), isTrue);

      t2 += Decimal.fromInt(1);
      expect(t1 == t2, isFalse);
    });
    test('formatting integer', () {
      final decimal = Decimal.fromInt(5);

      final df = DecimalFormatter('it_IT');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '5,000');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '5');
    });
    test('formatting double', () {
      final decimal = Decimal.parse('2517.47972158');

      final df = DecimalFormatter('it_IT');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '2517,480');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '2517,47972158');
      expect(
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: false),
          '2.517,480');
    });
    test('formatting  ...', () {
      final decimal = decimal1 / Decimal.parse('3');

      final df = DecimalFormatter('it_IT');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '0,333');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '0,3333333333');
      expect(
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: false),
          '0,333');
    });
    test('formatting negative', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('it_IT');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '-16572517,879');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '-16572517,87947972158');
      expect(
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: false),
          '-16.572.517,879');
    });
    test('formatting negative fr_FR', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('fr_FR');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '-16572517,879');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '-16572517,87947972158');
      expect(
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: false),
          '-16 572 517,879');
    });
    test('formatting negative en_US', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('en_US');
      expect(
          df.formatDecimal(decimal,
              showGroups: false, optimizedFraction: false),
          '-16572517.879');
      expect(
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true),
          '-16572517.87947972158');
      expect(
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: false),
          '-16,572,517.879');
    });
    test('parsing integer', () {
      final decimal = Decimal.fromInt(5);

      final df = DecimalFormatter('it_IT');
      var result = df.formatDecimal(decimal,
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), decimal);
      result =
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true);
      expect(df.parse(result), decimal);
    });
    test('parsing double', () {
      final decimal = Decimal.parse('2517.47972158');

      final df = DecimalFormatter('it_IT');
      var result = df.formatDecimal(decimal,
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), Decimal.parse('2517.48'));
      result =
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true);
      expect(df.parse(result), decimal);
      result = df.formatDecimal(decimal1 / Decimal.fromInt(3),
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), Decimal.parse('0.333'));
    });
    test('parsing negative double', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('it_IT');
      var result = df.formatDecimal(decimal,
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), Decimal.parse('-16572517.879'));
      result =
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true);
      expect(df.parse(result), decimal);
      result =
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: true);
      expect(df.parse(result), decimal);
    });
    test('parsing negative double fr_FR', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('fr_FR');
      var result = df.formatDecimal(decimal,
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), Decimal.parse('-16572517.879'));
      result =
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true);
      expect(df.parse(result), decimal);
      result =
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: true);
      expect(df.parse(result), decimal);
    });
    test('parsing negative double en_US', () {
      final decimal = Decimal.parse('-16572517.87947972158');

      final df = DecimalFormatter('en_US');
      var result = df.formatDecimal(decimal,
          showGroups: false, optimizedFraction: false);
      expect(df.parse(result), Decimal.parse('-16572517.879'));
      result =
          df.formatDecimal(decimal, showGroups: false, optimizedFraction: true);
      expect(df.parse(result), decimal);
      result =
          df.formatDecimal(decimal, showGroups: true, optimizedFraction: true);
      expect(df.parse(result), decimal);
    });
  });
}
