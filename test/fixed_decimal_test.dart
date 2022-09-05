/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

// ignore_for_file: avoid_function_literals_in_foreach_calls

import 'package:test/test.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

FixedDecimal fixed(String value,
        {Decimal? minimumValue,
        int? scale,
        RoundingType? rounding,
        ScalingPolicy? policy}) =>
    FixedDecimal.parse(value,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);

void main() {
  group('generic', () {
    test('string validation', () {
      expect(() => fixed('1'), returnsNormally);
      expect(() => fixed('-1'), returnsNormally);
      expect(fixed('1.'), fixed('1'));
      expect(() => fixed('1.0'), returnsNormally);
    });
    test('get isInteger', () {
      expect(fixed('1').isInteger, equals(true));
      expect(fixed('0').isInteger, equals(true));
      expect(fixed('-1').isInteger, equals(true));
      expect(fixed('-1.0').isInteger, equals(true));
      expect(fixed('1.2').isInteger, equals(false));
      expect(fixed('-1.21').isInteger, equals(false));
    });
    test('operator ==(Decimal other)', () {
      expect(fixed('1') == (fixed('1')), isTrue);
      expect(fixed('1') == (fixed('2')), equals(false));
      expect(fixed('1') == (fixed('1.0')), equals(true));
      expect(fixed('1') == (fixed('2.0')), equals(false));
      expect(fixed('1') != (fixed('1')), equals(false));
      expect(fixed('1') != (fixed('2')), equals(true));
    });
    test('duplicate', () {
      final t1 = fixed('5');
      var t2 = t1.duplicate();

      expect(t1, t2);
      expect(identical(t1, t2), isFalse);
      t2 += fixed('1');
      expect(t1 == t2, isFalse);
    });
    test('toString()', () {
      [
        '0',
        '1',
        '-1',
        '-1.1',
        '23',
        '31878018903828899277492024491376690701584023926880.1'
      ].forEach((String n) {
        expect(fixed(n).toString(), equals(n));
      });
      expect((fixed('1', scale: 10) / fixed('3', scale: 0)).toString(),
          equals('0.3333333333'));
      expect(fixed('9.9').toString(), equals('9.9'));
      expect(
          (fixed('1.0000000000000000000000000000000000000000000000001',
                      scale: 49)
                  .multiply(
                      fixed(
                          '1.0000000000000000000000000000000000000000000000001',
                          scale: 49),
                      scale: 98))
              .toString(),
          equals('1.0000000000000000000000000000000000000000000000002'
              '0000000000000000000000000000000000000000000000001'));
    });
    test('compareTo(Decimal other)', () {
      expect(fixed('1').compareTo(fixed('1')), equals(0));
      expect(fixed('1').compareTo(fixed('1.0')), equals(0));
      expect(fixed('1').compareTo(fixed('1.1')), equals(-1));
      expect(fixed('1').compareTo(fixed('0.9')), equals(1));
    });
    test('operator +(Decimal other)', () {
      expect((fixed('1') + fixed('1')).toString(), equals('2'));
      expect((fixed('1.1') + fixed('1')).toString(), equals('2.1'));
      expect((fixed('1.1') + fixed('0.9')).toString(), equals('2'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') +
                  fixed('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926880.9'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') +
                  Decimal.parse('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926881'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0',
                      scale: 1) +
                  Decimal.parse('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926880.9'));
    });
    test('operator -(Decimal other)', () {
      expect((fixed('1') - fixed('1')).toString(), equals('0'));
      expect((fixed('1.1') - fixed('1')).toString(), equals('0.1'));
      expect((fixed('0.1') - fixed('1.1')).toString(), equals('-1'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') -
                  fixed('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926879.1'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') -
                  Decimal.parse('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926879'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0',
                      scale: 1) -
                  Decimal.parse('0.9'))
              .toString(),
          equals('31878018903828899277492024491376690701584023926879.1'));
    });
    test('operator *(Decimal other)', () {
      expect((fixed('1') * fixed('1')).toString(), equals('1'));
      expect((fixed('1.1') * fixed('1')).toString(), equals('1.1'));
      expect((fixed('1.1') * fixed('0.1')).toString(), equals('0.11'));
      expect((fixed('1.1') * fixed('0')).toString(), equals('0'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') *
                  fixed('10'))
              .toString(),
          equals('318780189038288992774920244913766907015840239268800'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') *
                  Decimal.parse('10'))
              .toString(),
          equals('318780189038288992774920244913766907015840239268800'));
    });
    test('operator %(Decimal other)', () {
      expect((fixed('2') % fixed('1')).toString(), equals('0'));
      expect((fixed('0') % fixed('1')).toString(), equals('0'));
      expect((fixed('8.9') % fixed('1.1')).toString(), equals('0.1'));
      expect((fixed('-1.2') % fixed('0.5')).toString(), equals('0.3'));
      expect((fixed('-1.2') % fixed('-0.5')).toString(), equals('0.3'));
      expect(fixed('5') % fixed('4'), equals(fixed('1')));
      expect(fixed('-5') % fixed('4'), equals(fixed('3')));
      expect(fixed('5') % fixed('-4'), equals(fixed('1')));
      expect(fixed('-5') % fixed('-4'), equals(fixed('3')));
      expect(fixed('4') % fixed('4'), equals(fixed('0')));
      expect(fixed('-4') % fixed('4'), equals(fixed('0')));
      expect(fixed('4') % fixed('-4'), equals(fixed('0')));
      expect(fixed('-4') % fixed('-4'), equals(fixed('0')));
      expect(fixed('-4') % Decimal.parse('-4'), equals(fixed('0')));
    });
    test('operator /(Decimal other)', () {
      expect(() => fixed('1') / fixed('0'), throwsA(isNot('Ok')));
      expect((fixed('1') / fixed('1')).toString(), equals('1'));
      expect((fixed('1.1') / fixed('1')).toString(), equals('1.1'));
      expect((fixed('1.1') / fixed('0.1')).toString(), equals('11'));
      expect((fixed('0') / fixed('0.2315')).toString(), equals('0'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') /
                  fixed('10'))
              .toString(),
          equals('3187801890382889927749202449137669070158402392688'));
      expect(
          (fixed('31878018903828899277492024491376690701584023926880.0') /
                  Decimal.parse('10'))
              .toString(),
          equals('3187801890382889927749202449137669070158402392688'));
    });
    test('operator ~/(Decimal other)', () {
      expect(() => fixed('1') ~/ fixed('0'), throwsA(isNot('Ok')));
      expect((fixed('3') ~/ fixed('2')).toString(), equals('1'));
      expect((fixed('1.1') ~/ fixed('1')).toString(), equals('1'));
      expect((fixed('1.1') ~/ fixed('0.1')).toString(), equals('11'));
      expect((fixed('0') ~/ fixed('0.2315')).toString(), equals('0'));
    });
    test('operator -()', () {
      expect((-fixed('1')).toString(), equals('-1'));
      expect((-fixed('-1')).toString(), equals('1'));
    });
    test('remainder(Decimal other)', () {
      expect((fixed('2').remainder(fixed('1'))).toString(), equals('0'));
      expect((fixed('0').remainder(fixed('1'))).toString(), equals('0'));
      expect((fixed('8.9').remainder(fixed('1.1'))).toString(), equals('0.1'));
      expect(
          (fixed('-1.2').remainder(fixed('0.5'))).toString(), equals('-0.2'));
      expect(
          (fixed('-1.2').remainder(fixed('-0.5'))).toString(), equals('-0.2'));
    });
    test('operator <(Decimal other)', () {
      expect(fixed('1') < fixed('1'), equals(false));
      expect(fixed('1') < fixed('1.0'), equals(false));
      expect(fixed('1') < fixed('1.1'), equals(true));
      expect(fixed('1') < fixed('0.9'), equals(false));
    });
    test('operator <=(Decimal other)', () {
      expect(fixed('1') <= fixed('1'), equals(true));
      expect(fixed('1') <= fixed('1.0'), equals(true));
      expect(fixed('1') <= fixed('1.1'), equals(true));
      expect(fixed('1') <= fixed('0.9'), equals(false));
    });
    test('operator >(Decimal other)', () {
      expect(fixed('1') > fixed('1'), equals(false));
      expect(fixed('1') > fixed('1.0'), equals(false));
      expect(fixed('1') > fixed('1.1'), equals(false));
      expect(fixed('1') > fixed('0.9'), equals(true));
    });
    test('operator >=(Decimal other)', () {
      expect(fixed('1') >= fixed('1'), equals(true));
      expect(fixed('1') >= fixed('1.0'), equals(true));
      expect(fixed('1') >= fixed('1.1'), equals(false));
      expect(fixed('1') >= fixed('0.9'), equals(true));
    });
    test('get isNaN', () {
      expect(fixed('1').isNaN, equals(false));
    });
    test('get isNegative', () {
      expect(fixed('-1').isNegative, equals(true));
      expect(fixed('0').isNegative, equals(false));
      expect(fixed('1').isNegative, equals(false));
    });
    test('get isInfinite', () {
      expect(fixed('1').isInfinite, equals(false));
    });
    test('abs()', () {
      expect((fixed('-1.49').abs()).toString(), equals('1.49'));
      expect((fixed('1.498', scale: 3).abs()).toString(), equals('1.498'));
    });
    test('signum', () {
      expect(fixed('-1.49').signum, equals(-1));
      expect(fixed('1.49').signum, equals(1));
      expect(fixed('0').signum, equals(0));
    });
    test('floor()', () {
      expect((fixed('1').floor()).toString(), equals('1'));
      expect((fixed('-1').floor()).toString(), equals('-1'));
      expect((fixed('1.49').floor()).toString(), equals('1'));
      expect((fixed('-1.49').floor()).toString(), equals('-2'));
    });
    test('ceil()', () {
      expect((fixed('1').floor()).toString(), equals('1'));
      expect((fixed('-1').floor()).toString(), equals('-1'));
      expect((fixed('-1.49').ceil()).toString(), equals('-1'));
      expect((fixed('1.49').ceil()).toString(), equals('2'));
    });
    test('round()', () {
      expect((fixed('1.4999').round()).toString(), equals('1'));
      expect((fixed('2.5').round()).toString(), equals('3'));
      expect((fixed('-2.51').round()).toString(), equals('-3'));
      expect((fixed('-2').round()).toString(), equals('-2'));
    });
    test('truncate()', () {
      expect((fixed('2.51').truncate()).toString(), equals('2'));
      expect((fixed('-2.51').truncate()).toString(), equals('-2'));
      expect((fixed('-2').truncate()).toString(), equals('-2'));
    });
    test('clamp(Decimal lowerLimit, Decimal upperLimit)', () {
      expect((fixed('2.51').clamp(fixed('1'), fixed('3'))).toString(),
          equals('2.51'));
      expect((fixed('2.51').clamp(fixed('2.6'), fixed('3'))).toString(),
          equals('2.6'));
      expect((fixed('2.51').clamp(fixed('1'), fixed('2.5'))).toString(),
          equals('2.5'));
    });
    test('toInt()', () {
      expect(fixed('2.51').toInt(), equals(2));
      expect(fixed('-2.51').toInt(), equals(-2));
      expect(fixed('-2').toInt(), equals(-2));
    });
    test('toDouble()', () {
      expect(fixed('2.51').toDouble(), equals(2.51));
      expect(fixed('-2.51').toDouble(), equals(-2.51));
      expect(fixed('-2').toDouble(), equals(-2.0));
    });
    test('hasFinitePrecision', () {
      [
        fixed('100'),
        fixed('100.100'),
        fixed('1') / fixed('5'),
        (fixed('1') / fixed('3')) * fixed('3'),
        fixed('0.00000000000000000000001')
      ].forEach((FixedDecimal d) {
        expect(d.hasFinitePrecision, isTrue);
      });
      [fixed('1', scale: 10) / fixed('3', scale: 10)].forEach((FixedDecimal d) {
        expect(d.hasFinitePrecision, isTrue);
      });
    });
    test('precision', () {
      expect(fixed('100').precision, equals(3));
      expect(fixed('10000').precision, equals(5));
      expect(fixed('100.000').precision, equals(3));
      expect(fixed('100.1').precision, equals(4));
      expect(fixed('100.0000001', scale: 7).precision, equals(10));
      expect(fixed('100.000000000000000000000000000001', scale: 30).precision,
          equals(33));
      expect((fixed('1') / fixed('3')).precision, equals(1));
    });
    test('scale', () {
      expect(fixed('100').scale, equals(0));
      expect(fixed('10000').scale, equals(0));
      expect(fixed('100.000').scale, equals(0));
      expect(fixed('100.1').scale, equals(1));
      expect(fixed('100.0000001', scale: 7).scale, equals(7));
      expect(fixed('100.000000000000000000000000000001', scale: 30).scale,
          equals(30));
      expect((fixed('1') / fixed('3')).scale, equals(0));
    });
    test('toStringAsFixed(int fractionDigits)', () {
     /*  expect(fixed(('2.5'), scale: 0).toStringAsFixed(0),
          equals((2.5).toStringAsFixed(0))); */
      [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((num n) {
        [0, 1, 5, 10].forEach((p) {
          print('n: $n, p: $p');
          expect(fixed(n.toString(), scale: p, rounding: RoundingType.halfUp).toStringAsFixed(p),
              equals(n.toStringAsFixed(p)));
        });
      });
    });
    test('toStringAsExponential(int fractionDigits)', () {
      [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((num n) {
        [1, 5, 10].forEach((p) {
          expect(fixed(n.toString(), scale: p).toStringAsExponential(p),
              equals(n.toStringAsExponential(p)));
        });
      });
    });
    test('toStringAsPrecision(int precision)', () {
      [0, 1, 23, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((num n) {
        [1, 5, 10].forEach((p) {
          expect(fixed(n.toString(), scale: 6).toStringAsPrecision(p),
              equals(n.toStringAsPrecision(p)));
        });
      });
    }, skip: true); // At present decimal returns 20 instead of 2e+1
    test('Percent with no decimals and no integer part', () {
      final fix = FixedDecimal.parse('0.12');
      final formatted = fix.formattedString('#%');
      expect(formatted, '12%');
      final dec = fix.parseFormattedString(formatted, '#%');
      expect(dec, Decimal.parse('0.12'));
    });
    test('Explicit currency name', () {
      final fix = FixedDecimal.parse('1000000.32');
      var formatted = fix.formattedCurrency(userLocale: 'en_US', symbol: '€');
      expect(formatted, '€1,000,000.32');
      var decimal = fix.parseFormattedCurrency(formatted,
          userLocale: 'en_US', symbol: '€');
      expect(decimal, Decimal.parse('1000000.32'));

      formatted = fix.formattedCurrency(userLocale: 'de_CH', symbol: r'$');
      final nbsp = String.fromCharCode(0xa0);
      expect(formatted, '\$${nbsp}1’000’000.32');
      decimal = fix.parseFormattedCurrency(formatted,
          userLocale: 'de_CH', symbol: r'$');
      expect(decimal, Decimal.parse('1000000.32'));

      /// Verify we can leave off the currency and it gets filled in.
      formatted = fix.formattedCurrency(userLocale: 'de_CH');
      expect(formatted, 'CHF${nbsp}1’000’000.32');
      decimal = fix.parseFormattedCurrency(formatted, userLocale: 'de_CH');
      expect(decimal, Decimal.parse('1000000.32'));
    });
  });

  group('new', () {
    test('Constructors', () {
      expect(FixedDecimal.fromInt(12), equals(fixed('12')));
      expect(FixedDecimal.fromInt(-12), equals(fixed('-12')));
    });

    test('Fractional Part', () {
      expect(fixed('1.34').fractionalPart(FractionalPartCriteria.floor),
          equals(fixed('0.34')));
      expect(fixed('1.34').fractionalPart(FractionalPartCriteria.ceil),
          equals(fixed('0.34')));
      expect(fixed('-1.34').fractionalPart(FractionalPartCriteria.floor),
          equals(fixed('0.66')));
      expect(fixed('-1.34').fractionalPart(FractionalPartCriteria.absolute),
          equals(fixed('0.34')));
      expect(fixed('-1.34').fractionalPart(FractionalPartCriteria.ceil),
          equals(fixed('-0.34')));
    });

    test('Even Odd', () {
      expect(fixed('1.34').isEven, equals(false));
      expect(fixed('2.1').isEven, equals(true));
    });

    test('rounding Floor', () {
      expect(
          fixed('1.15').roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(fixed('1.1')));
      expect(
          fixed('-1.15')
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(fixed('-1.2')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: RoundingType.floor),
          equals(fixed('1.2')));
      expect(
          fixed('-1.25').roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(fixed('-1.3')));
      expect(
          fixed('1.23')
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(fixed('-1.3')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(fixed('1.1')));
      expect(
          fixed('-1.17')
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(fixed('-1.2')));
    });

    test('rounding Ceil', () {
      const rounding = RoundingType.ceil;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.2')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
    });

    test('rounding Truncate', () {
      const rounding = RoundingType.truncate;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.1')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.2')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.1')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
    });

    test('rounding away from zero (up)', () {
      const rounding = RoundingType.awayFromZero;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.3')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.3')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half floor', () {
      const rounding = RoundingType.halfDown;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.1')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.3')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half ceil', () {
      const rounding = RoundingType.halfUp;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.2')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half down', () {
      const rounding = RoundingType.halfTowardsZero;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.1')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.2')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half up', () {
      const rounding = RoundingType.halfAwayFromZero;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.3')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half even', () {
      const rounding = RoundingType.halfToEven;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.2')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });

    test('rounding half odd', () {
      const rounding = RoundingType.halfToOdd;
      expect(
          fixed('1.15')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('1.1')));
      expect(
          fixed('-1.15').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.1')));
      expect(
          fixed('1.25').roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(fixed('1.3')));
      expect(
          fixed('-1.25')
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(fixed('-1.3')));
      expect(fixed('1.23').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.23').roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(fixed('-1.2')));
      expect(
          fixed('1.17').roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(fixed('1.2')));
      expect(
          fixed('-1.17').roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(fixed('-1.2')));
    });
  });

  group('Policy check on addition', () {
    final fd_1 =
        FixedDecimal.fromInt(1, scale: 3, policy: ScalingPolicy.biggerScale);
    final fd_1_23 = FixedDecimal.parse('1.23',
        policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.ceil);
    final fd_1_358 = FixedDecimal.parse('1.358',
        policy: ScalingPolicy.sameAsFirst, scale: 3);
    final fd_1_3334 = FixedDecimal.parse('1.3334',
        policy: ScalingPolicy.adjust,
        minimumValue: Decimal.parse('0.0002'),
        rounding: RoundingType.truncate);

    test('Check + adjust against others.', () {
      final test = FixedDecimal.parse('2.356');

      final t4 = test + fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.adjust));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(
          t4,
          equals(FixedDecimal.parse('3.6894',
              minimumValue: Decimal.parse('0.0002'))));

      final t42 = test.add(fd_1_3334,
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.6894', scale: 4)));

      final t43 = FixedDecimal.addition(test, fd_1_3334,
          policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.001')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.689')));
    });

    test('Check others against + adjust against others.', () {
      final test = FixedDecimal.parse('2.356');

      final t4 = fd_1_3334 + test;

      expect(t4.policy, equals(ScalingPolicy.adjust));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.truncate));
      expect(
          t4,
          equals(FixedDecimal.parse('3.6894',
              minimumValue: Decimal.parse('0.0002'))));

      final t42 = fd_1_3334.add(test,
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.6894', scale: 4)));

      final t43 = FixedDecimal.addition(fd_1_3334, test,
          policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.0002')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.6894')));
    });

    test('Check + sameAsFirst against others.', () {
      final test =
          FixedDecimal.parse('2.356', policy: ScalingPolicy.sameAsFirst);

      final t4 = test + fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t4.minimumValue, equals(Decimal.parse('0.001')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(t4, equals(FixedDecimal.parse('3.689')));

      final t44 = test + fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.halfToEven));
      expect(t44, equals(FixedDecimal.parse('3.714')));

      final t42 = test.add(fd_1, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.356')));

      final t43 =
          FixedDecimal.addition(test, fd_1_23, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.59')));
    });

    test('Check others against + sameAsFirst.', () {
      final test =
          FixedDecimal.parse('2.356', policy: ScalingPolicy.sameAsFirst);

      final t4 = fd_1_3334 + test;

      expect(t4.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(
          t4,
          equals(FixedDecimal.parse('3.6894',
              minimumValue: Decimal.parse('0.0002'))));

      final t44 = fd_1_358 + test;

      expect(t44.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.halfToEven));
      expect(t44, equals(FixedDecimal.parse('3.714')));

      final t42 = fd_1.add(test, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.356')));

      final t43 =
          FixedDecimal.addition(fd_1_23, test, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.59')));
    });

    test('Check + bigerScale against others.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      final t4 = test + fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.biggerScale));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.floor));
      expect(t4, equals(FixedDecimal.parse('3.8334')));

      final t44 = test + fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.biggerScale));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.floor));
      expect(t44, equals(FixedDecimal.parse('3.858')));

      final t42 = test.add(fd_1, rounding: RoundingType.ceil);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.ceil));
      expect(t42, equals(FixedDecimal.parse('3.5')));

      final t43 =
          FixedDecimal.addition(test, fd_1_23, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.73')));
    });

    test('Check others against + BiggerScale.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      final t4 = fd_1_3334 + test;

      expect(t4.policy, equals(ScalingPolicy.biggerScale));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.floor));
      expect(t4, equals(FixedDecimal.parse('3.8334')));

      final t44 = fd_1_358 + test;

      expect(t44.policy, equals(ScalingPolicy.biggerScale));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.floor));
      expect(t44, equals(FixedDecimal.parse('3.858')));

      final t42 = fd_1.add(test, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.5')));

      final t43 =
          FixedDecimal.addition(fd_1_23, test, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.73')));
    });

    test('Check + thisOnly against others.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.thisOrNothing,
          rounding: RoundingType.halfTowardsZero);

      final t4 = test + fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t4.minimumValue, equals(Decimal.parse('0.1')));
      expect(t4.rounding, equals(RoundingType.halfTowardsZero));
      expect(t4, equals(FixedDecimal.parse('3.8')));

      final t44 = test + fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t44.minimumValue, equals(Decimal.parse('0.1')));
      expect(t44.rounding, equals(RoundingType.halfTowardsZero));
      expect(t44, equals(FixedDecimal.parse('3.9')));

      final t42 = test.add(fd_1, rounding: RoundingType.ceil);

      expect(t42.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t42.minimumValue, equals(Decimal.parse('0.1')));
      expect(t42.rounding, equals(RoundingType.ceil));
      expect(t42, equals(FixedDecimal.parse('3.5')));

      expect(
          () => FixedDecimal.addition(test, fd_1_23,
              rounding: RoundingType.halfUp),
          throwsException);
    });

    test('Check others against + thisOnly.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.thisOrNothing,
          rounding: RoundingType.halfTowardsZero);

      final t4 = fd_1_3334 + test;

      expect(t4.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t4.minimumValue, equals(Decimal.parse('0.1')));
      expect(t4.rounding, equals(RoundingType.halfTowardsZero));
      expect(t4, equals(FixedDecimal.parse('3.8')));

      final t44 = fd_1_358 + test;

      expect(t44.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t44.minimumValue, equals(Decimal.parse('0.1')));
      expect(t44.rounding, equals(RoundingType.halfTowardsZero));
      expect(t44, equals(FixedDecimal.parse('3.9')));

      final t42 = fd_1.add(test, rounding: RoundingType.halfUp, scale: 0);

      expect(t42.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t42.minimumValue, equals(Decimal.parse('1')));
      expect(t42.rounding, equals(RoundingType.halfUp));
      expect(t42, equals(FixedDecimal.parse('4.0')));

      final t43 = FixedDecimal.addition(fd_1_23, test,
          scale: 1, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.1')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.7')));
    });
  });

  // ************** Multiplication **************
  group('Policy check on multiplication', () {
    final fd_1 =
        FixedDecimal.fromInt(1, scale: 3, policy: ScalingPolicy.biggerScale);
    final fd_1_23 = FixedDecimal.parse('1.23',
        policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.ceil);
    final fd_1_358 = FixedDecimal.parse('1.358',
        policy: ScalingPolicy.sameAsFirst, scale: 3);
    final fd_1_3334 = FixedDecimal.parse('1.3334',
        policy: ScalingPolicy.adjust,
        minimumValue: Decimal.parse('0.0002'),
        rounding: RoundingType.truncate);

    test('Check * adjust against others.', () {
      final test = FixedDecimal.parse('2.356');

      final t4 = test * fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.adjust));
      expect(t4.minimumValue, equals(Decimal.parse('0.0000002')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(t4, equals(FixedDecimal.parse('3.1414904')));

      final t42 = test.multiply(fd_1_3334,
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('3.1414')));

      final t43 = FixedDecimal.multiplication(test, fd_1_3334,
          policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.001')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.141')));
    });

    test('Check others against * adjust against others.', () {
      final test = FixedDecimal.parse('2.356');

      final t4 = fd_1_3334 * test;

      expect(t4.policy, equals(ScalingPolicy.adjust));
      expect(t4.minimumValue, equals(Decimal.parse('0.0000002')));
      expect(t4.rounding, equals(RoundingType.truncate));
      expect(t4, equals(FixedDecimal.parse('3.1414904')));

      final t42 = fd_1_3334.multiply(test,
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.halfDown);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t42.rounding, equals(RoundingType.halfDown));
      expect(t42, equals(FixedDecimal.parse('3.1414')));

      final t43 = FixedDecimal.multiplication(fd_1_3334, test,
          policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.0002')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.1414')));
    });

    test('Check * sameAsFirst against others.', () {
      final test =
          FixedDecimal.parse('2.356', policy: ScalingPolicy.sameAsFirst);

      final t4 = test * fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t4.minimumValue, equals(Decimal.parse('0.001')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(t4, equals(FixedDecimal.parse('3.141')));

      final t44 = test * fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.halfToEven));
      expect(t44, equals(FixedDecimal.parse('3.199')));

      final t42 = test.multiply(fd_1, rounding: RoundingType.ceil);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.ceil));
      expect(t42, equals(FixedDecimal.parse('2.356')));

      final t43 = FixedDecimal.multiplication(test, fd_1_23,
          rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('2.90')));
    });

    test('Check others against * sameAsFirst.', () {
      final test =
          FixedDecimal.parse('2.356', policy: ScalingPolicy.sameAsFirst);

      final t4 = fd_1_3334 * test;

      expect(t4.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.halfToEven));
      expect(t4, equals(FixedDecimal.parse('3.1414')));

      final t44 = fd_1_358 * test;

      expect(t44.policy, equals(ScalingPolicy.sameAsFirst));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.halfToEven));
      expect(t44, equals(FixedDecimal.parse('3.199')));

      final t42 = fd_1.multiply(test, rounding: RoundingType.floor);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.floor));
      expect(t42, equals(FixedDecimal.parse('2.356')));

      final t43 = FixedDecimal.multiplication(fd_1_23, test,
          rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('2.9')));
    });

    test('Check * bigerScale against others.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      final t4 = test * fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.biggerScale));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.floor));
      expect(t4, equals(FixedDecimal.parse('3.3334')));

      final t44 = test * fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.biggerScale));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.floor));
      expect(t44, equals(FixedDecimal.parse('3.395')));

      final t42 = test.multiply(fd_1, rounding: RoundingType.ceil);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('0.001')));
      expect(t42.rounding, equals(RoundingType.ceil));
      expect(t42, equals(FixedDecimal.parse('2.5')));

      final t43 = FixedDecimal.multiplication(test, fd_1_23,
          rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.08')));
    });

    test('Check others against * BiggerScale.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

      final t4 = fd_1_3334 * test;

      expect(t4.policy, equals(ScalingPolicy.biggerScale));
      expect(t4.minimumValue, equals(Decimal.parse('0.0002')));
      expect(t4.rounding, equals(RoundingType.floor));
      expect(t4, equals(FixedDecimal.parse('3.3334')));

      final t44 = fd_1_358 * test;

      expect(t44.policy, equals(ScalingPolicy.biggerScale));
      expect(t44.minimumValue, equals(Decimal.parse('0.001')));
      expect(t44.rounding, equals(RoundingType.floor));
      expect(t44, equals(FixedDecimal.parse('3.395')));

      final t42 =
          fd_1.multiply(test, scale: 0, rounding: RoundingType.awayFromZero);

      expect(t42.policy, equals(ScalingPolicy.biggerScale));
      expect(t42.minimumValue, equals(Decimal.parse('1')));
      expect(t42.rounding, equals(RoundingType.awayFromZero));
      expect(t42, equals(FixedDecimal.parse('3')));

      final t43 = FixedDecimal.multiplication(fd_1_23, test,
          rounding: RoundingType.halfTowardsZero);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.01')));
      expect(t43.rounding, equals(RoundingType.halfTowardsZero));
      expect(t43, equals(FixedDecimal.parse('3.07')));
    });

    test('Check * thisOnly against others.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.thisOrNothing,
          rounding: RoundingType.halfTowardsZero);

      final t4 = test * fd_1_3334;

      expect(t4.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t4.minimumValue, equals(Decimal.parse('0.1')));
      expect(t4.rounding, equals(RoundingType.halfTowardsZero));
      expect(t4, equals(FixedDecimal.parse('3.3')));

      final t44 = test * fd_1_358;

      expect(t44.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t44.minimumValue, equals(Decimal.parse('0.1')));
      expect(t44.rounding, equals(RoundingType.halfTowardsZero));
      expect(t44, equals(FixedDecimal.parse('3.4')));

      final t42 = test.multiply(fd_1, rounding: RoundingType.ceil);

      expect(t42.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t42.minimumValue, equals(Decimal.parse('0.1')));
      expect(t42.rounding, equals(RoundingType.ceil));
      expect(t42, equals(FixedDecimal.parse('2.5')));

      expect(
          () => FixedDecimal.multiplication(test, fd_1_23,
              rounding: RoundingType.halfUp),
          throwsException);
    });

    test('Check others against * thisOnly.', () {
      final test = FixedDecimal.parse('2.5',
          policy: ScalingPolicy.thisOrNothing,
          rounding: RoundingType.halfTowardsZero);

      final t4 = fd_1_3334 * test;

      expect(t4.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t4.minimumValue, equals(Decimal.parse('0.1')));
      expect(t4.rounding, equals(RoundingType.halfTowardsZero));
      expect(t4, equals(FixedDecimal.parse('3.3')));

      final t44 = fd_1_358 * test;

      expect(t44.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t44.minimumValue, equals(Decimal.parse('0.1')));
      expect(t44.rounding, equals(RoundingType.halfTowardsZero));
      expect(t44, equals(FixedDecimal.parse('3.4')));

      final t42 =
          fd_1.multiply(test, rounding: RoundingType.halfToOdd, scale: 0);

      expect(t42.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t42.minimumValue, equals(Decimal.parse('1')));
      expect(t42.rounding, equals(RoundingType.halfToOdd));
      expect(t42, equals(FixedDecimal.parse('3')));

      final t43 = FixedDecimal.multiplication(fd_1_23, test,
          scale: 1, rounding: RoundingType.halfUp);

      expect(t43.policy, equals(ScalingPolicy.thisOrNothing));
      expect(t43.minimumValue, equals(fixed('0.1')));
      expect(t43.rounding, equals(RoundingType.halfUp));
      expect(t43, equals(FixedDecimal.parse('3.1')));
    });
  });
}
