/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

Money money(String value, String countryLocale, {RoundingType? rounding}) =>
    Money.parse(value, countryLocale, rounding: rounding);

double round(double value, [double increment = 1.0]) {
  var val = Decimal.parse(value.toString());
  final inc = Decimal.parse(increment.toString());
  val /= inc;
  val = val.round();
  val *= inc;
  return val.toDouble();
}

void main() {
  //String nbsp = new String.fromCharCode(0xa0);
  const locale = 'it_IT';
  const longValue =
      '31.878.018.903.828.899.277.492.024.491.376.690.701.584.023.926.880,10'
      ' EUR';
  const longValue2 =
      '31.878.018.903.828.899.277.492.024.491.376.690.701.584.023.926.880,90'
      ' EUR';

  group('generic', () {
    test('string validation', () {
      expect(() => money('1', locale), returnsNormally);
      expect(() => money('-1', locale), returnsNormally);
      expect(money('1.', locale), money('1,0', locale));
      expect(() => money('1.0', locale), returnsNormally);
    });
    test('get isInteger', () {
      expect(money('1', locale).isInteger, equals(true));
      expect(money('0', locale).isInteger, equals(true));
      expect(money('-1', locale).isInteger, equals(true));
      expect(money('-1,0', locale).isInteger, equals(true));
      expect(money('1,2', locale).isInteger, equals(false));
      expect(money('-1,21', locale).isInteger, equals(false));
    });
    test('operator ==(Decimal other)', () {
      expect(money('1', locale) == (money('1', locale)), equals(true));
      expect(money('1', locale) == (money('2', locale)), equals(false));
      expect(money('1', locale) == (money('1,0', locale)), equals(true));
      expect(money('1', locale) == (money('2,0', locale)), equals(false));
      expect(money('1', locale) != (money('1', locale)), equals(false));
      expect(money('1', locale) != (money('2', locale)), equals(true));
    });
    test('duplicate', () {
      final t1 = money('5', locale);
      var t2 = t1.duplicate();

      expect(t1, t2);
      expect(identical(t1, t2), isFalse);
      t2 += money('1', locale);
      expect(t1 == t2, isFalse);
    });
    test('toString()', () {
      var idx = 0;
      final expected = [
        '0,00 EUR',
        '1,00 EUR',
        '-1,00 EUR',
        '-1,10 EUR',
        '23,00 EUR',
        longValue
      ];
      [
        '0',
        '1',
        '-1',
        '-1,1',
        '23',
        '31878018903828899277492024491376690701584023926880,1'
      ].forEach((String n) {
        expect(money(n, locale).toString(), equals(expected[idx++]));
      });
      expect((money('1', locale) / money('3', locale)).toString(),
          equals('0,33 EUR'));
      expect(money('9,9', locale).toString(), equals('9,90 EUR'));
      expect(
          (money('1,0000000000000000000000000000000000000000000000001', locale)
                  .multiply(money(
                      '1,0000000000000000000000000000000000000000000000001',
                      locale)))
              .toString(),
          equals('1,00 EUR'));
    });
    test('compareTo(Money other)', () {
      expect(money('1', locale).compareTo(money('1', locale)), equals(0));
      expect(money('1', locale).compareTo(money('1,0', locale)), equals(0));
      expect(money('1', locale).compareTo(money('1,1', locale)), equals(-1));
      expect(money('1', locale).compareTo(money('0,9', locale)), equals(1));
    });
    test('operator +(Money other)', () {
      expect((money('1', locale) + money('1', locale)).toString(),
          equals('2,00 EUR'));
      expect((money('1,1', locale) + money('1', locale)).toString(),
          equals('2,10 EUR'));
      expect((money('1,1', locale) + money('0,9', locale)).toString(),
          equals('2,00 EUR'));
      expect(
          (money('31878018903828899277492024491376690701584023926880,0',
                      locale) +
                  money('0,9', locale))
              .toString(),
          equals(longValue2));
    });
    test('operator -(Decimal other)', () {
      expect((money('1', locale) - money('1', locale)).toString(),
          equals('0,00 EUR'));
      expect((money('1,1', locale) - money('1', locale)).toString(),
          equals('0,10 EUR'));
      expect((money('0,1', locale) - money('1,1', locale)).toString(),
          equals('-1,00 EUR'));
      expect(
          (money('31878018903828899277492024491376690701584023926880,0',
                      locale) -
                  money('0,9', locale))
              .toString(),
          equals('31.878.018.903.828.899.277.492.024.491.'
              '376.690.701.584.023.926.879,10 EUR'));
    });
    test('operator *(Decimal other)', () {
      expect((money('1', locale) * money('1', locale)).toString(),
          equals('1,00 EUR'));
      expect((money('1,1', locale) * money('1', locale)).toString(),
          equals('1,10 EUR'));
      expect((money('1,1', locale) * money('0,1', locale)).toString(),
          equals('0,11 EUR'));
      expect((money('1,1', locale) * money('0', locale)).toString(),
          equals('0,00 EUR'));
      expect(
          (money('31878018903828899277492024491376690701584023926880,0',
                      locale) *
                  money('10', locale))
              .toString(),
          equals('318.780.189.038.288.992.774.920.244.913.'
              '766.907.015.840.239.268.800,00 EUR'));
    });
    test('operator %(Decimal other)', () {
      expect((money('2', locale) % money('1', locale)).toString(),
          equals('0,00 EUR'));
      expect((money('0', locale) % money('1', locale)).toString(),
          equals('0,00 EUR'));
      expect((money('8,9', locale) % money('1,1', locale)).toString(),
          equals('0,10 EUR'));
      expect((money('-1,2', locale) % money('0,5', locale)).toString(),
          equals('0,30 EUR'));
      expect((money('-1,2', locale) % money('-0,5', locale)).toString(),
          equals('0,30 EUR'));
      expect(
          money('5', locale) % money('4', locale), equals(money('1', locale)));
      expect(
          money('-5', locale) % money('4', locale), equals(money('3', locale)));
      expect(
          money('5', locale) % money('-4', locale), equals(money('1', locale)));
      expect(money('-5', locale) % money('-4', locale),
          equals(money('3', locale)));
      expect(
          money('4', locale) % money('4', locale), equals(money('0', locale)));
      expect(
          money('-4', locale) % money('4', locale), equals(money('0', locale)));
      expect(
          money('4', locale) % money('-4', locale), equals(money('0', locale)));
      expect(money('-4', locale) % money('-4', locale),
          equals(money('0', locale)));
    });
    test('operator /(Decimal other)', () {
      expect(
          () => money('1', locale) / money('0', locale), throwsA(isNot('Ok')));
      expect((money('1', locale) / money('1', locale)).toString(),
          equals('1,00 EUR'));
      expect((money('1,1', locale) / money('1', locale)).toString(),
          equals('1,10 EUR'));
      expect((money('1,1', locale) / money('0,1', locale)).toString(),
          equals('11,00 EUR'));
      expect((money('0', locale) / money('0,2315', locale)).toString(),
          equals('0,00 EUR'));
      expect(
          (money('31878018903828899277492024491376690701584023926880,0',
                      locale) /
                  money('10', locale))
              .toString(),
          equals('3.187.801.890.382.889.927.749.202.449.'
              '137.669.070.158.402.392.688,00 EUR'));
    });
    test('operator ~/(Decimal other)', () {
      expect(
          () => money('1', locale) ~/ money('0', locale), throwsA(isNot('Ok')));
      expect((money('3', locale) ~/ money('2', locale)).toString(),
          equals('1,00 EUR'));
      expect((money('1,1', locale) ~/ money('1', locale)).toString(),
          equals('1,00 EUR'));
      expect((money('1,1', locale) ~/ money('0,1', locale)).toString(),
          equals('11,00 EUR'));
      expect((money('0', locale) ~/ money('0,2315', locale)).toString(),
          equals('0,00 EUR'));
    });
    test('operator -()', () {
      expect((-money('1', locale)).toString(), equals('-1,00 EUR'));
      expect((-money('-1', locale)).toString(), equals('1,00 EUR'));
    });
    test('remainder(Decimal other)', () {
      expect((money('2', locale).remainder(money('1', locale))).toString(),
          equals('0,00 EUR'));
      expect((money('0', locale).remainder(money('1', locale))).toString(),
          equals('0,00 EUR'));
      expect((money('8,9', locale).remainder(money('1,1', locale))).toString(),
          equals('0,10 EUR'));
      expect((money('-1,2', locale).remainder(money('0,5', locale))).toString(),
          equals('-0,20 EUR'));
      expect(
          (money('-1,2', locale).remainder(money('-0,5', locale))).toString(),
          equals('-0,20 EUR'));
    });
    test('operator <(Decimal other)', () {
      expect(money('1', locale) < money('1', locale), equals(false));
      expect(money('1', locale) < money('1,0', locale), equals(false));
      expect(money('1', locale) < money('1,1', locale), equals(true));
      expect(money('1', locale) < money('0,9', locale), equals(false));
    });
    test('operator <=(Decimal other)', () {
      expect(money('1', locale) <= money('1', locale), equals(true));
      expect(money('1', locale) <= money('1,0', locale), equals(true));
      expect(money('1', locale) <= money('1,1', locale), equals(true));
      expect(money('1', locale) <= money('0,9', locale), equals(false));
    });
    test('operator >(Decimal other)', () {
      expect(money('1', locale) > money('1', locale), equals(false));
      expect(money('1', locale) > money('1,0', locale), equals(false));
      expect(money('1', locale) > money('1,1', locale), equals(false));
      expect(money('1', locale) > money('0,9', locale), equals(true));
    });
    test('operator >=(Decimal other)', () {
      expect(money('1', locale) >= money('1', locale), equals(true));
      expect(money('1', locale) >= money('1,0', locale), equals(true));
      expect(money('1', locale) >= money('1,1', locale), equals(false));
      expect(money('1', locale) >= money('0,9', locale), equals(true));
    });
    test('get isNaN', () {
      expect(money('1', locale).isNaN, equals(false));
    });
    test('get isNegative', () {
      expect(money('-1', locale).isNegative, equals(true));
      expect(money('0', locale).isNegative, equals(false));
      expect(money('1', locale).isNegative, equals(false));
    });
    test('get isInfinite', () {
      expect(money('1', locale).isInfinite, equals(false));
    });
    test('abs()', () {
      expect((money('-1,49', locale).abs()).toString(), equals('1,49 EUR'));
      expect((money('1,498', locale).abs()).toString(), equals('1,50 EUR'));
    });
    test('signum', () {
      expect(money('-1,49', locale).signum, equals(-1));
      expect(money('1,49', locale).signum, equals(1));
      expect(money('0', locale).signum, equals(0));
    });
    test('floor()', () {
      expect((money('1', locale).floor()).toString(), equals('1,00 EUR'));
      expect((money('-1', locale).floor()).toString(), equals('-1,00 EUR'));
      expect((money('1,49', locale).floor()).toString(), equals('1,00 EUR'));
      expect((money('-1,49', locale).floor()).toString(), equals('-2,00 EUR'));
    });
    test('ceil()', () {
      expect((money('1', locale).floor()).toString(), equals('1,00 EUR'));
      expect((money('-1', locale).floor()).toString(), equals('-1,00 EUR'));
      expect((money('-1,49', locale).ceil()).toString(), equals('-1,00 EUR'));
      expect((money('1,49', locale).ceil()).toString(), equals('2,00 EUR'));
    });
    test('round()', () {
      expect((money('1,4999', locale).round()).toString(), equals('2,00 EUR'));
      expect((money('2,5', locale).round()).toString(), equals('3,00 EUR'));
      expect((money('-2,51', locale).round()).toString(), equals('-3,00 EUR'));
      expect((money('-2', locale).round()).toString(), equals('-2,00 EUR'));
    });
    test('truncate()', () {
      expect((money('2,51', locale).truncate()).toString(), equals('2,00 EUR'));
      expect(
          (money('-2,51', locale).truncate()).toString(), equals('-2,00 EUR'));
      expect((money('-2', locale).truncate()).toString(), equals('-2,00 EUR'));
    });
    test('clamp(Decimal lowerLimit, Decimal upperLimit)', () {
      expect(
          (money('2,51', locale).clamp(money('1', locale), money('3', locale)))
              .toString(),
          equals('2,51 EUR'));
      expect(
          (money('2,51', locale)
                  .clamp(money('2,6', locale), money('3', locale)))
              .toString(),
          equals('2,60 EUR'));
      expect(
          (money('2,51', locale)
                  .clamp(money('1', locale), money('2,5', locale)))
              .toString(),
          equals('2,50 EUR'));
    });
    test('toInt()', () {
      expect(money('2,51', locale).toInt(), equals(2));
      expect(money('-2,51', locale).toInt(), equals(-2));
      expect(money('-2', locale).toInt(), equals(-2));
    });
    test('toDouble()', () {
      expect(money('2,51', locale).toDouble(), equals(2.51));
      expect(money('-2,51', locale).toDouble(), equals(-2.51));
      expect(money('-2', locale).toDouble(), equals(-2.0));
    });
    test('hasFinitePrecision', () {
      [
        money('100', locale),
        money('100.100', locale),
        money('1', locale) / money('5', locale),
        (money('1', locale) / money('3', locale)) * money('3', locale),
        money('0,00000000000000000000001', locale)
      ].forEach((Money d) {
        expect(d.hasFinitePrecision, isTrue);
      });
      [money('1', locale) / money('3', locale)].forEach((Money d) {
        expect(d.hasFinitePrecision, isTrue);
      });
    });
    test('precision', () {
      expect(money('100', locale).precision, equals(3));
      expect(money('10000', locale).precision, equals(5));
      expect(money('100,000', locale).precision, equals(3));
      expect(money('100,1', locale).precision, equals(4));
      expect(money('100,0000001', locale).precision, equals(3));
      expect(money('100,000000000000000000000000000001', locale).precision,
          equals(3));
      expect((money('1', locale) / money('3', locale)).precision, equals(2));
    });
    test('scale', () {
      expect(money('100', locale).scale, equals(0));
      expect(money('10000', locale).scale, equals(0));
      expect(money('100,000', locale).scale, equals(0));
      expect(money('100,1', locale).scale, equals(1));
      expect(money('100,0000001', locale).scale, equals(0));
      expect(
          money('100,000000000000000000000000000001', locale).scale, equals(0));
      expect((money('1', locale) / money('3', locale)).scale, equals(2));
    });

    test('toStringAsFixed(int fractionDigits)', () {
      [0.0, 1.0, 23.0, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((double n) {
        [0, 1, 5, 10].forEach((p) {
          expect(money(n.toString(), 'en_US').toStringAsFixed(p),
              equals(round(n, 0.01).toStringAsFixed(p)));
        });
      });
    });
    test('toStringAsExponential(int fractionDigits)', () {
      [0.0, 1.0, 23.0, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((double n) {
        [1, 5, 10].forEach((p) {
          expect(money(n.toString(), 'en_US').toStringAsExponential(p),
              equals(round(n, 0.01).toStringAsExponential(p)));
        });
      });
    });
    test('toStringAsPrecision(int precision)', () {
      [0.0, 1.0, 23.0, 2.2, 2.499999, 2.5, 2.7, 1.235].forEach((double n) {
        [1, 5, 10].forEach((p) {
          expect(money(n.toString(), 'en_US').toStringAsPrecision(p),
              equals(round(n, 0.01).toStringAsPrecision(p)));
        });
      });
    }, skip: true); // At present decimal returns 20 instead of 2e+1

    test('Explicit currency name', () {
      var fix = Money.parse('1000000.32',  'it_IT', userLocale: 'en_US');
      var formatted = fix.formattedCurrency(userLocale: 'en_US', symbol: '€');
      expect(formatted, '1,000,000.32 €');
      fix = Money.parse('1000000.32', 'en_US');
      var ret = fix.parseFormattedCurrency(formatted, userLocale: 'en_US');
      expect(ret, fix);
      fix = Money.parse('1000000.32', 'en_US');
      formatted = fix.formattedCurrency(userLocale: 'en_US', symbol: r'$');
      expect(formatted, r'$1,000,000.32');

      fix = Money.parse('1000000.32','en_US', userLocale: 'de_CH');
      formatted = fix.formattedCurrency(userLocale: 'de_CH', symbol: r'$');
      //var nbsp = new String.fromCharCode(0xa0);
      expect(formatted, r'$1’000’000.32');
      ret = fix.parseFormattedCurrency(formatted,
          userLocale: 'de_CH', countryLocale: 'en_US');
      expect(ret, fix);

      /// Verify we can leave off the currency and it gets filled in.
      fix = Money.parse('1000000.32', 'de_CH');
      formatted = fix.formattedCurrency(userLocale: 'de_CH');
      expect(formatted, r'CHF 1’000’000.32');
      ret = fix.parseFormattedCurrency(formatted,
          userLocale: 'de_CH', countryLocale: 'de_CH');
      expect(ret, fix);
    });
  });

  group('new', () {
    test('Constructors', () {
      expect(FixedDecimal.fromInt(12), equals(money('12', locale)));
      expect(FixedDecimal.fromInt(-12), equals(money('-12', locale)));
    });

    test('Fractional Part', () {
      expect(money('1,34', locale).fractionalPart(FractionalPartCriteria.floor),
          equals(money('0,34', locale)));
      expect(money('1,34', locale).fractionalPart(FractionalPartCriteria.ceil),
          equals(money('0,34', locale)));
      expect(
          money('-1,34', locale).fractionalPart(FractionalPartCriteria.floor),
          equals(money('0,66', locale)));
      expect(
          money('-1,34', locale)
              .fractionalPart(FractionalPartCriteria.absolute),
          equals(money('0,34', locale)));
      expect(money('-1,34', locale).fractionalPart(FractionalPartCriteria.ceil),
          equals(money('-0,34', locale)));
    });

    test('Even Odd', () {
      expect(money('1,34', locale).isEven(), equals(false));
      expect(money('2,1', locale).isEven(), equals(true));
    });

    test('rounding Floor', () {
      expect(
          money('1,15', locale).roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(money('1,1', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(money('-1,2', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: RoundingType.floor),
          equals(money('1,2', locale)));
      expect(
          money('-1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(money('-1,3', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(money('-1,3', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: '0.1', rounding: RoundingType.floor),
          equals(money('1,1', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: RoundingType.floor),
          equals(money('-1,2', locale)));
    });

    test('rounding Ceil', () {
      const rounding = RoundingType.ceil;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
    });

    test('rounding Truncate', () {
      const rounding = RoundingType.truncate;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,1', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,1', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
    });

    test('rounding away from zero (up)', () {
      const rounding = RoundingType.awayFromZero;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,3', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,3', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half floor', () {
      const rounding = RoundingType.halfDown;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,1', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,3', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half ceil', () {
      const rounding = RoundingType.halfUp;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half down', () {
      const rounding = RoundingType.halfTowardsZero;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,1', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half up', () {
      const rounding = RoundingType.halfAwayFromZero;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,3', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half even', () {
      const rounding = RoundingType.halfToEven;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });

    test('rounding half odd', () {
      const rounding = RoundingType.halfToOdd;
      expect(
          money('1,15', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('1,1', locale)));
      expect(
          money('-1,15', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,1', locale)));
      expect(
          money('1,25', locale).roundToNearestMultiple(
              minimumValue: '0.1', scale: 2, rounding: rounding),
          equals(money('1,3', locale)));
      expect(
          money('-1,25', locale)
              .roundToNearestMultiple(minimumValue: '0.1', rounding: rounding),
          equals(money('-1,3', locale)));
      expect(
          money('1,23', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,23', locale).roundToNearestMultiple(
              minimumValue: double.parse('0.1'), rounding: rounding),
          equals(money('-1,2', locale)));
      expect(
          money('1,17', locale).roundToNearestMultiple(
              minimumValue: Decimal.parse('0.1'), rounding: rounding),
          equals(money('1,2', locale)));
      expect(
          money('-1,17', locale)
              .roundToNearestMultiple(scale: 1, rounding: rounding),
          equals(money('-1,2', locale)));
    });
  });

  test('test formatted', () {
    final money = Money.parse('1543213,45', 'it_IT');
    expect(money.toString(), equals('1.543.213,45 EUR'));
    expect(money.formattedCurrency(), equals('1.543.213,45 EUR'));
  });

  test('test formatted', () {
    final money = Money.parse('1543213,45', 'it_IT');
    final formatted = money.formattedCurrency();
    expect(money.parseFormattedCurrency(formatted), money);
  });

  test('test formatted', () {
    final money = Money.parse('1543213,45', 'it_IT');
    expect(money.toString(), equals('1.543.213,45 EUR'));
    expect(money.formattedCurrency(symbol: '€'), equals('1.543.213,45 €'));
  });

  test('test formatted', () {
    final money = Money.parse('1543213,45', 'it_IT');
    final formatted = money.formattedCurrency(symbol: '€');
    expect(money.parseFormattedCurrency(formatted), money);
  });

  test('test formatted', () {
    final money = Money.parse('1543213,45', 'it_IT');
    expect(money.toString(), equals('1.543.213,45 EUR'));
    expect(money.formattedCompactCurrency(), equals('1.543.213,45 €'));
  });

  test('multiply', () {
    final money = Money.parse('213,45', 'it_IT');
    final money2 = Money.parse('32,12', 'it_IT');
    final money3 = money * money2;
    expect(money3.formattedCurrency(), equals('6.856,01 EUR'));
  });
}
