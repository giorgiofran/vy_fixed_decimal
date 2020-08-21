/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:decimal/decimal.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';
import 'package:intl/intl.dart';
import 'package:intl/number_symbols.dart';

void main() {
  final NumberFormat nf = NumberFormat.currency(locale: 'en_US');
  print('currency Symbol ${nf.currencySymbol}');
  print('Maximum Fraction digits ${nf.maximumFractionDigits}');
  print('currency Name ${nf.currencyName}');
  print('Decimal Digits ${nf.decimalDigits}');
  print('maximumIntegerDigits ${nf.maximumIntegerDigits}');
  print('minimumIntegerDigits ${nf.minimumIntegerDigits}');

  print('minimumFractionDigits ${nf.minimumFractionDigits}');
  print('significantDigitsIn use ${nf.significantDigitsInUse}');
  final NumberSymbols ns = nf.symbols;
  print('currency Pattern ${ns.CURRENCY_PATTERN}');
  print('decimalSeparator ${ns.DECIMAL_SEP}');
  print('default currency code ${ns.DEF_CURRENCY_CODE}');
  print('group separator ${ns.GROUP_SEP}');
  print('Name ${ns.NAME}');
  print('minus sign ${ns.MINUS_SIGN}');
  print('Percent ${ns.PERCENT}');
  print('Permill ${ns.PERMILL}');
  print('plus sign ${ns.PLUS_SIGN}');

  /*
  print(' 5 %  4 = ${5 % 4}, Reminder ${5.0.remainder(4)}');
  print('-5 %  4 = ${-5 % 4}, Reminder ${-5.0.remainder(4)}');
  print(' 5 % -4 = ${5 % -4}, Reminder ${5.0.remainder(-4)}');
  print('-5 % -4 = ${-5 % -4}, Reminder ${-5.0.remainder(-4)}');
  print('-1.2 % -0.5 = ${-1.2 % -0.5}, Reminder ${-1.2.remainder(-0.5)}');
  */

/*  final FixedDecimal fd_1 =
      FixedDecimal.fromInt(1, scale: 3, policy: ScalingPolicy.biggerScale);
  final FixedDecimal fd_1_23 = FixedDecimal.parse('1.23',
      policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.ceil);
  final FixedDecimal fd_1_358 =
     FixedDecimal.parse('1.358', policy: ScalingPolicy.sameAsFirst, scale: 3);*/
  final FixedDecimal fd_1_3334 = FixedDecimal.parse('1.3334',
      policy: ScalingPolicy.adjust,
      minimumValue: Decimal.parse('0.0002'),
      rounding: RoundingType.truncate);

  final FixedDecimal test = FixedDecimal.parse('2.356');

  final FixedDecimal t4 = test + fd_1_3334;

  print('******* $t4 ******');
  print('Policy ok? ${t4.policy == ScalingPolicy.adjust}');
  print('Minimun Value ok? ${t4.minimumValue == Decimal.parse('0.0002')}');
  print('Rounding ok? ${t4.rounding == RoundingType.halfToEven}');
  print('Value = $t4, is 3.6934');
  final bool valueOk =
      t4 == FixedDecimal.parse('3.6934', minimumValue: Decimal.parse('0.0002'));
  print('Value ok? $valueOk');
  print('String ok? ${t4.toString() == '3.6934'}');

  final FixedDecimal t42 = test.add(fd_1_3334,
      policy: ScalingPolicy.biggerScale, rounding: RoundingType.floor);

  print('******* $t42 ******');
  print('Policy ok? ${t42.policy == ScalingPolicy.biggerScale}');
  print('Minimun Value ok? ${t42.minimumValue == Decimal.parse('0.0002')}');
  print('Rounding ok? ${t42.rounding == RoundingType.floor}');
  print('Value ok? ${t42 == FixedDecimal.parse('3.6934', scale: 4)}');
  print('Value = $t42, is 3.6934');
  print('String ok? ${t42.toString() == '3.6934'}');

  final FixedDecimal t43 = FixedDecimal.addition(test, fd_1_3334,
      policy: ScalingPolicy.thisOrNothing, rounding: RoundingType.halfUp);

  print('******* $t43 ******');
  print('Policy ok? ${t43.policy == ScalingPolicy.thisOrNothing}');
  print('Minimun Value ok? ${t43.minimumValue == Decimal.parse('0.01')}');
  print('Rounding ok? ${t43.rounding == RoundingType.halfUp}');
  print('Value ok? ${t43 == FixedDecimal.parse('3.69')}');
  print('String ok? ${t43.toString() == '3.69'}');
}
