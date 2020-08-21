/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:decimal/decimal.dart';
import 'package:test/test.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart'
    show MoneyFormatter, Money;

Decimal dec(String value) => Decimal.parse(value);

String nbsp = /*String.fromCharCode(0xa0)'\u202f'*/ '\u00a0';

void main() {
  group('Formatting', () {
    test('test formatted amount IT', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('1543213,45', 'it_IT');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, '1.543.213,45 EUR');
    });

    test('test formatted negative amount IT', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('-1543213,45', 'it_IT');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, '-1.543.213,45 EUR');
    });

    test('test formatted amount FR', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('1543213,45', 'fr_FR');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, '1 543 213,45 EUR');
    });

    test('test formatted negative amount FR', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('-1543213,45', 'fr_FR');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, '-1 543 213,45 EUR');
    });

    test('test formatted amount US', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('1543213.45', 'en_US');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, 'USD1,543,213.45');
    });

    test('test formatted negative amount US', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('-1543213.45', 'en_US');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, 'USD-1,543,213.45');
    });

    test('test formatted amount IN', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('1543213,45', 'in_IN');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, 'IDR1.543.213,45');
    });

    test('test formatted negative amount IN', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      final formatted = mf.formatMoney(money, compactCurrencySymbol: false);

      expect(formatted, 'IDR-1.543.213,45');
    });

    test('test formatted amount IT - compact symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('1543213,45', 'it_IT');
      final formatted = mf.formatMoney(money);

      expect(formatted, '1.543.213,45 €');
    });

    test('test formatted negative amount IT - compact symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('-1543213,45', 'it_IT');
      final formatted = mf.formatMoney(money);

      expect(formatted, '-1.543.213,45 €');
    });

    test('test formatted amount US - compact symbol', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('1543213.45', 'en_US');
      final formatted = mf.formatMoney(money);

      expect(formatted, r'$1,543,213.45');
    });

    test('test formatted negative amount US - compact symbol', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('-1543213.45', 'en_US');
      final formatted = mf.formatMoney(money);

      expect(formatted, r'$-1,543,213.45');
    });

    test('test formatted amount IN - compact symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('1543213,45', 'in_IN');
      final formatted = mf.formatMoney(money);

      expect(formatted, 'Rp1.543.213,45');
    });

    test('test formatted negative amount IN - compact symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      final formatted = mf.formatMoney(money);

      expect(formatted, 'Rp-1.543.213,45');
    });

    test('test formatted amount IT - no symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('1543213,45', 'it_IT');
      final formatted = mf.formatMoney(money, implicitSymbol: true);

      expect(formatted, '1.543.213,45');
    });

    test('test formatted negative amount FR - no Symbol', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('-239725471329411543213,54', 'fr_FR');
      final formatted = mf.formatMoney(money, implicitSymbol: true);

      expect(formatted, '-239 725 471 329 411 543 213,54');
    });

    test('test formatted negative amount IN - no symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      final formatted = mf.formatMoney(money, implicitSymbol: true);

      expect(formatted, '-1.543.213,45');
    });
  });

  group('Parsing', () {
    test('test parsing amount IT', () {
      final mf = MoneyFormatter('it_IT');
      const formatted = '1.543.213,45 EUR';
      final money = Money.parse('1543213,45', 'it_IT');

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing small amount IT', () {
      final mf = MoneyFormatter('it_IT');
      const formatted = '-13,80 EUR';
      final money = Money.parse('-13,8', 'it_IT');

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing fractional amount IT', () {
      final mf = MoneyFormatter('it_IT');
      const formatted = '-0,15 EUR';
      final money = Money.parse('-0,15', 'it_IT');

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing big amount IT', () {
      final mf = MoneyFormatter('it_IT');
      const formatted = '-3.975.732.456.097.867.302.988.174.635.233.'
          '748.566.328.199.876.500.938.376.400,55 EUR';
      final money = Money.parse(
          '-3975732456097867302988174635233748566328199876500938376400,55',
          'it_IT');

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount FR', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('1543213,45', 'fr_FR');
      final formatted = '1${nbsp}543${nbsp}213,45 EUR';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount FR', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('-1543213,45', 'fr_FR');
      final formatted = '-1${nbsp}543${nbsp}213,45 EUR';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount US', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('1543213.45', 'en_US');
      const formatted = 'USD1,543,213.45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount US', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('-1543213.45', 'en_US');
      const formatted = 'USD-1,543,213.45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount IN', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('1543213,45', 'in_IN');
      const formatted = 'IDR1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount IN', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      const formatted = 'IDR-1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount IT - compact symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('1543213,45', 'it_IT');
      const formatted = '1.543.213,45 €';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount IT - compact symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('-1543213,45', 'it_IT');
      const formatted = '-1.543.213,45 €';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount US - compact symbol', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('1543213.45', 'en_US');
      const formatted = r'$1,543,213.45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount US - compact symbol', () {
      final mf = MoneyFormatter('en_US');
      final money = Money.parse('-1543213.45', 'en_US');
      const formatted = r'$-1,543,213.45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount IN - compact symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('1543213,45', 'in_IN');
      const formatted = 'Rp1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount IN - compact symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      const formatted = 'Rp-1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing amount IT - no symbol', () {
      final mf = MoneyFormatter('it_IT');
      final money = Money.parse('1543213,45', 'it_IT');
      const formatted = '1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount FR - no Symbol', () {
      final mf = MoneyFormatter('fr_FR');
      final money = Money.parse('-239725471329411543213,54', 'fr_FR');
      final formatted =
          '-239${nbsp}725${nbsp}471${nbsp}329${nbsp}411${nbsp}543${nbsp}213,54';

      expect(mf.parse(formatted), equals(money));
    });

    test('test parsing negative amount IN - no symbol', () {
      final mf = MoneyFormatter('in_IN');
      final money = Money.parse('-1543213,45', 'in_IN');
      const formatted = '-1.543.213,45';

      expect(mf.parse(formatted), equals(money));
    });
  });
}
