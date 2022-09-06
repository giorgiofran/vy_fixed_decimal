/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'dart:math' as math;
import 'package:decimal/decimal.dart';
import 'package:rational/rational.dart';
import 'package:vy_fixed_decimal/src/enums/rounding_type.dart';

import '../enums/fractional_part_criteria.dart';
import '../fixed_decimal.dart';

//Decimal decimal0 = Decimal.zero;
Decimal decimal1 = Decimal.one;
Decimal decimal2 = Decimal.fromInt(2);
Decimal decimal10 = Decimal.parse('10');
Decimal decimal100 = Decimal.parse('100');

Decimal decMinus2 = Decimal.fromInt(-2);
Decimal decMinus1 = Decimal.fromInt(-1);
Decimal decHalf = Decimal.parse('0.5');
Decimal decTenths = Decimal.parse('0.1');
Decimal decHundredths = Decimal.parse('0.01');

final Map<int, Decimal> _dividers = {
  -2: decimal100,
  -1: decimal10,
  0: Decimal.one,
  1: decTenths,
  2: decHundredths,
};

extension DecimalExtension on Decimal {
  /// HasFinitePrecision
  ///
  /// Returns `true` if this [Decimal] has a finite precision.
  /// Having a finite precision means that the number can be exactly represented
  /// as decimal with a finite number of fractional digits.
  bool get hasFinitePrecision => toRational().hasFinitePrecision;
  bool get isInfinite => !hasFinitePrecision;

  /// IsNegative
  ///
  /// Returns `true` if this [Decimal] is lesser than zero.
  bool get isNegative => signum < 0;

  /// IsNaN
  ///
  /// Returns always `false`, as a [Decimal] is always a valid number.
  bool get isNaN => false;

  static Decimal minimumValueFromScale(int scale) {
    if (_dividers[scale] == null) {
      _dividers[scale] = decimal10.power(-scale);
    }
    return _dividers[scale]!;
  }

  static int scaleFromMinimumValue(Decimal minimumValue) => minimumValue.scale;

  static Decimal decimalFromObject(Object value, {int fractiondigits = 10}) {
    /*  if (value == null) {
      return null;
    } */
    Decimal decimal;
    if (value is Decimal) {
      decimal = value;
    } else if (value is FixedDecimal) {
      decimal = value.decimal;
    } else if (value is Money) {
      decimal = value.decimal;
    } else if (value is double) {
      decimal = Decimal.parse(value.toStringAsExponential(fractiondigits));
    } else if (value is int) {
      decimal = Decimal.fromInt(value);
    } else if (value is String) {
      decimal = Decimal.parse(value);
    } else if (value is Rational) {
      if (value.hasFinitePrecision) {
        decimal = value.toDecimal();
      } else {
        decimal = value.toDecimal(scaleOnInfinitePrecision: fractiondigits);
      }
    } else {
      throw Exception('Unexpected parameter type ${value.runtimeType}');
    }
    return decimal;
  }

  static Decimal roundDecimalToNearestMultiple(Object objValue,
      {Object? minimumValue, int? scale, RoundingType? rounding}) {
    Decimal? checkDecimal;
    var locRounding = rounding ?? RoundingType.halfToEven;
    if (minimumValue != null) {
      checkDecimal = decimalFromObject(minimumValue);
    } else if (scale != null) {
      checkDecimal = minimumValueFromScale(scale);
    }
    var decimal = checkDecimal ?? Decimal.one;
    final originalValue = decimalFromObject(objValue);
    if (/* originalValue == null || */
        originalValue.isNaN || originalValue.isInfinite) {
      return originalValue;
    }
    /* var value =
        (originalValue / decimal).toDecimal(scaleOnInfinitePrecision: scale); */
    var value = originalValue.safeDivBy(decimal);
    Decimal fraPart;
    switch (locRounding) {
      case RoundingType.floor:
        value = value.floor();
        break;
      case RoundingType.ceil:
        value = value.ceil();
        break;
      case RoundingType.truncate:
        value = value.truncate();
        break;
      case RoundingType.awayFromZero:
        value = value.roundAwayFromZero();
        break;
      case RoundingType.halfDown:
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart > decHalf) {
          if (value.isNegative) {
            value = value.floor();
          } else {
            value = value.ceil();
          }
        } else if (fraPart < decHalf) {
          value = value.truncate();
        } else {
          value = value.floor();
        }
        break;
      case RoundingType.halfUp: // half Ceil
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart < decHalf) {
          value = value.truncate();
        } else if (fraPart > decHalf) {
          if (value.isNegative) {
            value = value.floor();
          } else {
            value = value.ceil();
          }
        } else {
          value = value.ceil();
        }
        break;
      case RoundingType.halfToEven:
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart < decHalf) {
          value = value.truncate();
        } else if (fraPart > decHalf) {
          if (value.isNegative) {
            value = value.floor();
          } else {
            value = value.ceil();
          }
        } else {
          if (value.isEven) {
            value = value.truncate();
          } else {
            if (value.isNegative) {
              value = value.floor();
            } else {
              value = value.ceil();
            }
          }
        }
        break;
      case RoundingType.halfToOdd:
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart < decHalf) {
          value = value.truncate();
        } else if (fraPart > decHalf) {
          if (value.isNegative) {
            value = value.floor();
          } else {
            value = value.ceil();
          }
        } else {
          if (!value.isEven) {
            value = value.truncate();
          } else {
            if (value.isNegative) {
              value = value.floor();
            } else {
              value = value.ceil();
            }
          }
        }
        break;
      case RoundingType.halfAwayFromZero:
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart < decHalf) {
          value = value.truncate();
        } else {
          value = value.roundAwayFromZero();
        }
        break;
      case RoundingType.halfTowardsZero:
        fraPart = value.fractionalPart(FractionalPartCriteria.absolute);
        if (fraPart > decHalf) {
          if (value.isNegative) {
            value = value.floor();
          } else {
            value = value.ceil();
          }
        } else {
          value = value.truncate();
        }
        break;
    }
    value = value.round();
    value *= decimal;
    return value;
  }

  String toJson() => toString();
  bool get isZero => this == Decimal.zero;
  bool get isEven => truncate() % decimal2 == Decimal.zero;
  // Accepts also negative exponents
  /*  Decimal power(int exponent) => exponent.isNegative
      ? (Decimal.one / pow(-exponent))
          .toDecimal(scaleOnInfinitePrecision: math.max<int>(scale, 10))
      : pow(exponent); */
  Decimal power(int exponent, {int? scaleOnInfinitePrecision}) =>
      exponent.isNegative
          ? Decimal.one.safeDivBy(pow(-exponent),
              scaleOnInfinitePrecision: scaleOnInfinitePrecision)
          : pow(exponent);

  Decimal min(Decimal other) => this < other ? this : other;
  Decimal max(Decimal other) => this > other ? this : other;

  Decimal roundAwayFromZero() => isNegative ? floor() : ceil();

  Decimal fractionalPart(FractionalPartCriteria criteria) {
    if (isNaN || isInfinite) {
      return this;
    }
    if (!isNegative) {
      return this - floor();
    }
    switch (criteria) {
      case FractionalPartCriteria.floor:
        return this - floor();
      case FractionalPartCriteria.absolute:
        return abs() - abs().floor();
      case FractionalPartCriteria.ceil:
        return this - ceil();
    }
    //return this;
  }

  Decimal safeDivBy(Decimal other, {int? scaleOnInfinitePrecision}) {
    Rational r = this / other;
    if (r.hasFinitePrecision) {
      return r.toDecimal();
    }
    scaleOnInfinitePrecision ??= 10;
    return r.toDecimal(scaleOnInfinitePrecision: scaleOnInfinitePrecision);
  }
}
