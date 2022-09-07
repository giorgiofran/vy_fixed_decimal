import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';

extension RationalExtension on Rational {
  Decimal roundToDecimal({int? scaleOnInfinitePrecision}) => toDecimal(
        scaleOnInfinitePrecision: scaleOnInfinitePrecision,
        toBigInt: (value) => value.round());
}
