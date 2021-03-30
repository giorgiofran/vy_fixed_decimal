/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

library fixed_decimal.fixed_decimal;

import 'dart:collection';
import 'dart:math';
import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';
import 'extension/decimal_extension.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart'
    show MoneyFormatter, RoundingType, FractionalPartCriteria;

part 'parts/money.dart';

enum ScalingPolicy { adjust, sameAsFirst, biggerScale, thisOrNothing }

class FixedDecimal implements Comparable<FixedDecimal> {
  late Decimal _decimal;
  late Decimal _minimumValue;
  RoundingType _rounding;
  ScalingPolicy _policy;
  String _userLocale = 'en_US';

  String get userLocale => _userLocale;
  set userLocale(String _value) {
    _userLocale = _value;
    if (loadedLocales[userLocale] == null) {
      loadedLocales[userLocale] = true;
      //Todo, documentation talking about initializing locales,
      // but no initialization function has been found in code.
    }
  }

  Decimal get decimal => _decimal;
  Decimal get minimumValue => _minimumValue;
  RoundingType get rounding => _rounding;
  ScalingPolicy get policy => _policy;

  static Map<String, bool> loadedLocales = SplayTreeMap();

  FixedDecimal._fromDecimal(Decimal decimal,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy /* ,
      String? userLocale */
      })
      : _rounding = rounding ?? RoundingType.halfToEven,
        _policy = policy ?? ScalingPolicy.adjust {
    if (minimumValue == null && scale != null) {
      minimumValue = DecimalExtension.minimumValueFromScale(scale);
    }
    if (minimumValue == null) {
      if (decimal.hasFinitePrecision) {
        minimumValue =
            DecimalExtension.minimumValueFromScale(min<int>(decimal.scale, 10));
      } else {
        minimumValue = DecimalExtension.minimumValueFromScale(10);
      }
    }
    _minimumValue = minimumValue;
    //_rounding = rounding ?? RoundingType.halfToEven;
    //_policy = policy ?? ScalingPolicy.adjust;
    _decimal = DecimalExtension.roundDecimalToNearestMultiple(decimal,
        minimumValue: _minimumValue, rounding: rounding);
    /* _userLocale = userLocale;
    if (userLocale != null && loadedLocales[userLocale] == null) {
      loadedLocales[userLocale] = true;
      //Todo, documentation talking about initializing locales,
      // but no initialization function has been found in code.
    } */
  }

  static FixedDecimal parse(String value,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      /* String userLocale, */
      ScalingPolicy? policy}) {
    return FixedDecimal._fromDecimal(Decimal.parse(value),
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        /*  userLocale: userLocale, */
        policy: policy);
  }

  factory FixedDecimal.fromInt(int value,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return FixedDecimal._fromDecimal(Decimal.fromInt(value),
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  /// Returns the fractional part of a Decimal
  ///
  /// The calculation is done with three different criteria.
  /// Differences are only for negative numbers.
  /// For positive numbers the formula is
  /// For negative numbers:
  /// 1) frac ⁡ ( x ) = x − ⌊ x ⌋
  /// 2) frac ⁡ ( x ) = | x | − ⌊ | x | ⌋
  /// 3) frac ⁡ ( x ) =  x − ⌈ x ⌉
  FixedDecimal fractionalPart(
          [FractionalPartCriteria criteria = FractionalPartCriteria.ceil]) =>
      FixedDecimal._fromDecimal(_fractionalPart(_decimal, criteria),
          minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  Decimal _fractionalPart(Decimal value, FractionalPartCriteria criteria) {
    if (/* value == null || */ value.isNaN || value.isInfinite) {
      return value;
    }
    if (!value.isNegative) {
      return value - value.floor();
    }
    switch (criteria) {
      case FractionalPartCriteria.floor:
        return value - value.floor();
      case FractionalPartCriteria.absolute:
        return value.abs() - value.abs().floor();
      case FractionalPartCriteria.ceil:
        return value - value.ceil();
    }
    //return value;
  }

  bool get isEven => _decimal.isEven;

  FixedDecimal roundToNearestMultiple(
      {Object? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    if (scale == null) {
      minimumValue ??= _minimumValue;
    }
    rounding ??= _rounding;
    policy ??= _policy;
    return FixedDecimal._fromDecimal(
        DecimalExtension.roundDecimalToNearestMultiple(_decimal,
            minimumValue: minimumValue, scale: scale, rounding: rounding),
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  bool get isInteger => _decimal.isInteger;

  @override
  bool operator ==(Object other) {
    if (other is FixedDecimal) {
      return _decimal == other._decimal;
    } else if (other is Decimal) {
      return _decimal == other;
    } else if (other is String) {
      bool ret;
      try {
        ret = _decimal == Decimal.parse(other);
      } catch (e) {
        ret = false;
      }
      return ret;
    }
    return false;
  }

  @override
  int get hashCode => _decimal.hashCode;

  @override
  String toString() => _decimal.toString();

  FixedDecimal duplicate() => FixedDecimal._fromDecimal(_decimal);

  // implementation of Comparable

  @override
  int compareTo(FixedDecimal other) => _decimal.compareTo(other._decimal);

  static Map _decidePolicy(
      FixedDecimal firstOperand, Object secondOperand, bool minValueSet) {
    ScalingPolicy policy;
    policy = firstOperand._policy;
    Decimal minimumValue;
    minimumValue = firstOperand._minimumValue;
    RoundingType rounding;
    rounding = firstOperand._rounding;
    if (secondOperand is FixedDecimal) {
      switch (firstOperand._policy) {
        case ScalingPolicy.thisOrNothing:
          if (!minValueSet &&
              secondOperand._policy == ScalingPolicy.thisOrNothing &&
              firstOperand._minimumValue != secondOperand._minimumValue) {
            throw Exception(
                'Operands scale differently. Cannot return a value.');
          }
          break;
        case ScalingPolicy.biggerScale:
          if (secondOperand._policy == ScalingPolicy.thisOrNothing) {
            policy = secondOperand._policy;
            minimumValue = secondOperand._minimumValue;
            rounding = secondOperand.rounding;
          } else {
            minimumValue =
                    firstOperand._minimumValue.min(secondOperand._minimumValue)
                /*DecimalExtension.min(
                firstOperand._minimumValue, secondOperand._minimumValue)*/
                ;
          }
          break;
        case ScalingPolicy.sameAsFirst:
          if (secondOperand._policy == ScalingPolicy.thisOrNothing) {
            policy = secondOperand._policy;
            minimumValue = secondOperand._minimumValue;
            rounding = secondOperand.rounding;
          } else if (secondOperand._policy == ScalingPolicy.biggerScale) {
            policy = secondOperand._policy;
            minimumValue =
                    firstOperand._minimumValue.min(secondOperand._minimumValue)
                /*       DecimalExtension.min(
                firstOperand._minimumValue, secondOperand._minimumValue)*/
                ;
            rounding = secondOperand.rounding;
          }
          break;
        case ScalingPolicy.adjust:
          if (secondOperand._policy == ScalingPolicy.thisOrNothing) {
            policy = secondOperand._policy;
            minimumValue = secondOperand._minimumValue;
            rounding = secondOperand.rounding;
          } else if (secondOperand._policy == ScalingPolicy.biggerScale) {
            policy = secondOperand._policy;
            minimumValue =
                firstOperand._minimumValue.min(secondOperand._minimumValue);
            rounding = secondOperand.rounding;
          } else if (secondOperand._policy == ScalingPolicy.sameAsFirst) {
            policy = secondOperand._policy;
            rounding = secondOperand.rounding;
          }
          break;
      }
    }
    return {
      'policy': policy,
      'minimumValue': minimumValue,
      'rounding': rounding
    };
  }

  static FixedDecimal _resolveOperation(
      Object firstOperandObj,
      Object secondOperandObj,
      Decimal Function() defineOperation,
      Decimal Function() defineMinimumValue,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    if (minimumValue == null && scale != null) {
      minimumValue = DecimalExtension.minimumValueFromScale(scale);
    }
    if (policy == null || minimumValue == null) {
      if (policy != null) {
        // so minimum value is null
        if (policy == ScalingPolicy.adjust) {
          minimumValue = defineMinimumValue();
        } else {
          if ((firstOperandObj is FixedDecimal) &&
              secondOperandObj is FixedDecimal) {
            if (policy == ScalingPolicy.thisOrNothing) {
              if (firstOperandObj._policy == policy) {
                minimumValue = firstOperandObj._minimumValue;
                rounding ??= firstOperandObj._rounding;
              } else if (secondOperandObj._policy == policy) {
                minimumValue = secondOperandObj._minimumValue;
                rounding ??= secondOperandObj._rounding;
              } else {
                minimumValue = firstOperandObj._minimumValue;
                rounding ??= firstOperandObj._rounding;
              }
            } else if (policy == ScalingPolicy.biggerScale) {
              if (firstOperandObj._policy == ScalingPolicy.thisOrNothing) {
                minimumValue = firstOperandObj._minimumValue;
                rounding ??= firstOperandObj._rounding;
              } else if (secondOperandObj._policy ==
                  ScalingPolicy.thisOrNothing) {
                minimumValue = secondOperandObj._minimumValue;
                rounding ??= secondOperandObj._rounding;
              } else {
                minimumValue = firstOperandObj._minimumValue
                        .min(secondOperandObj._minimumValue)
                    /*DecimalExtension.min(
                    firstOperandObj._minimumValue,
                    secondOperandObj._minimumValue)*/
                    ;
                rounding ??= firstOperandObj._rounding;
              }
            } else if (policy == ScalingPolicy.sameAsFirst) {
              minimumValue = firstOperandObj._minimumValue;
              rounding ??= firstOperandObj._rounding;
            }
          } else {
            if (firstOperandObj is FixedDecimal) {
              minimumValue = firstOperandObj._minimumValue;
              rounding ??= firstOperandObj._rounding;
            } else if (secondOperandObj is FixedDecimal) {
              minimumValue = secondOperandObj._minimumValue;
              rounding ??= secondOperandObj._rounding;
            } else {
              minimumValue = DecimalExtension.minimumValueFromScale(
                  defineOperation().scale);
            }
          }
        }
      } else {
        Map policies;
        if (firstOperandObj is FixedDecimal) {
          policies = _decidePolicy(
              firstOperandObj, secondOperandObj, minimumValue != null);
        } else {
          FixedDecimal firstOperand;
          if (secondOperandObj is FixedDecimal) {
            if (firstOperandObj is int) {
              firstOperand = FixedDecimal.fromInt(firstOperandObj,
                  minimumValue: minimumValue ?? secondOperandObj.minimumValue,
                  scale: scale ?? secondOperandObj.scale,
                  rounding: rounding ?? secondOperandObj.rounding,
                  policy: policy ?? secondOperandObj.policy);
            } else if (firstOperandObj is Decimal) {
              firstOperand = FixedDecimal._fromDecimal(firstOperandObj,
                  minimumValue: minimumValue ?? secondOperandObj.minimumValue,
                  scale: scale ?? secondOperandObj.scale,
                  rounding: rounding ?? secondOperandObj.rounding,
                  policy: policy ?? secondOperandObj.policy);
            } else if (firstOperandObj is double) {
              firstOperand = FixedDecimal.parse(firstOperandObj.toString(),
                  minimumValue: minimumValue ?? secondOperandObj.minimumValue,
                  scale: scale ?? secondOperandObj.scale,
                  rounding: rounding ?? secondOperandObj.rounding,
                  policy: policy ?? secondOperandObj.policy);
            } else {
              throw ArgumentError(
                  'Unmanaged object type "${firstOperandObj.runtimeType}"'
                  ' as first operand');
            }
          } else {
            if (firstOperandObj is int) {
              firstOperand = FixedDecimal.fromInt(firstOperandObj,
                  minimumValue: minimumValue,
                  scale: scale,
                  rounding: rounding,
                  policy: policy);
            } else if (firstOperandObj is Decimal) {
              firstOperand = FixedDecimal._fromDecimal(firstOperandObj,
                  minimumValue: minimumValue,
                  scale: scale,
                  rounding: rounding,
                  policy: policy);
            } else if (firstOperandObj is double) {
              firstOperand = FixedDecimal.parse(firstOperandObj.toString(),
                  minimumValue: minimumValue,
                  scale: scale,
                  rounding: rounding,
                  policy: policy);
            } else {
              throw ArgumentError(
                  'Unmanaged object type "${firstOperandObj.runtimeType}"'
                  ' as first operand');
            }
          }
          policies = _decidePolicy(
              firstOperand, secondOperandObj, minimumValue != null);
        }
        policy = policies['policy'];
        if (minimumValue == null) {
          if (policy == ScalingPolicy.adjust) {
            minimumValue = defineMinimumValue();
          } else {
            minimumValue = policies['minimumValue'];
          }
        }
        rounding ??= policies['rounding'];
      }
    }
    return FixedDecimal._fromDecimal(defineOperation(),
        minimumValue: minimumValue, rounding: rounding, policy: policy);
  }

  /// Addition operator
  ///
  /// The result is created with decimal precision and rounding type taken
  /// from the first addend. If it is needed to change them use the add method.
  FixedDecimal operator +(dynamic other) => addition(this, other);

  FixedDecimal add(Object addendObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return addition(this, addendObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal addition(Object augendObj, Object addendObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final augend = DecimalExtension.decimalFromObject(augendObj);
    /* if (augend == null) {
      return null;
    } */
    if (augend.isNaN || augend.isInfinite) {
      return FixedDecimal._fromDecimal(augend);
    }
    final addend = DecimalExtension.decimalFromObject(addendObj);
    /* if (addend == null) {
      return null;
    } */
    if (addend.isNaN || addend.isInfinite) {
      return FixedDecimal._fromDecimal(addend);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      if (augendObj is FixedDecimal) {
        if (addendObj is FixedDecimal) {
          return augendObj._minimumValue.min(addendObj._minimumValue);
        } else {
          return augendObj._minimumValue;
        }
      } else {
        if (addendObj is FixedDecimal) {
          return addendObj._minimumValue;
        } else {
          return DecimalExtension.minimumValueFromScale(
              min<int>((augend + addend).scale, 10));
        }
      }
    }

    return _resolveOperation(
        augendObj, addendObj, () => augend + addend, _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  /// Subtraction operator.
  ///
  /// The result is created with decimal precision and rounding type taken
  /// from minuend. If it is needed to change them use the subtract method.
  FixedDecimal operator -(Object other) =>
      subtraction(this, other /*, rounding: _rounding*/);
  /*
  new FixedDecimal._fromDecimal(_decimal - other._decimal,
          minimumValue: _minimumValue, rounding: _rounding);
          */

  FixedDecimal subtract(Object subtrahendObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return subtraction(this, subtrahendObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal subtraction(Object minuendObj, Object subtrahendObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final minuend = DecimalExtension.decimalFromObject(minuendObj);
    /* if (minuend == null) {
      return null;
    } */
    if (minuend.isNaN || minuend.isInfinite) {
      return FixedDecimal._fromDecimal(minuend);
    }
    final subtrahend = DecimalExtension.decimalFromObject(subtrahendObj);
    /* if (subtrahend == null) {
      return null;
    } */
    if (subtrahend.isNaN || subtrahend.isInfinite) {
      return FixedDecimal._fromDecimal(subtrahend);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      if (minuendObj is FixedDecimal) {
        if (subtrahendObj is FixedDecimal) {
          return minuendObj._minimumValue.min(subtrahendObj
                  ._minimumValue) /*DecimalExtension.min(
              minuendObj._minimumValue, subtrahendObj._minimumValue)*/
              ;
        } else {
          return minuendObj._minimumValue;
        }
      } else {
        if (subtrahendObj is FixedDecimal) {
          return subtrahendObj._minimumValue;
        } else {
          return DecimalExtension.minimumValueFromScale(
              min<int>((minuend - subtrahend).scale, 10));
        }
      }
    }

    return _resolveOperation(minuendObj, subtrahendObj,
        () => minuend - subtrahend, _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  /// Multiplication operator.
  FixedDecimal operator *(Object other) =>
      multiplication(this, other /*, rounding: _rounding*/);
  /*=>
      new FixedDecimal._fromDecimal(_decimal * other._decimal,
          minimumValue: _minimumValue, rounding: _rounding); */

  FixedDecimal multiply(Object multiplierObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return multiplication(this, multiplierObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal multiplication(
      Object multiplicandObj, Object multiplierObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final multiplicand = DecimalExtension.decimalFromObject(multiplicandObj);

    if (multiplicand.isNaN || multiplicand.isInfinite) {
      return FixedDecimal._fromDecimal(multiplicand);
    }
    final multiplier = DecimalExtension.decimalFromObject(multiplierObj);

    if (multiplier.isNaN || multiplier.isInfinite) {
      return FixedDecimal._fromDecimal(multiplier);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      if (multiplicandObj is FixedDecimal) {
        if (multiplierObj is FixedDecimal) {
          return multiplicandObj._minimumValue * multiplierObj._minimumValue;
        } else {
          return multiplicandObj._minimumValue;
        }
      } else {
        if (multiplierObj is FixedDecimal) {
          return multiplierObj._minimumValue;
        } else {
          return DecimalExtension.minimumValueFromScale(
              min<int>((multiplicand * multiplier).scale, 10));
        }
      }
    }

    return _resolveOperation(multiplicandObj, multiplierObj,
        () => multiplicand * multiplier, _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  static Decimal _mod(Decimal dividend, Decimal divisor) {
    final remainder = dividend.remainder(divisor);
    if (remainder.isNegative) {
      return divisor.abs() + remainder;
    }
    return remainder;
  }

  /// Euclidean modulo operator.
  // Temporarily bypassed because of a bug in rational package.
  /*
  FixedDecimal operator %(FixedDecimal other) =>
      new FixedDecimal._fromDecimal(_decimal % other._decimal,
          minimumValue: _minimumValue, rounding: _rounding); */
  FixedDecimal operator %(Object other) => modulusDivision(this, other);

  FixedDecimal modulo(Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return modulusDivision(this, divisorObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal modulusDivision(Object dividendObj, Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    if (dividend.isNaN || dividend.isInfinite) {
      return FixedDecimal._fromDecimal(dividend);
    }
    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    if (divisor.isNaN || divisor.isInfinite) {
      return FixedDecimal._fromDecimal(divisor);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      if (dividendObj is FixedDecimal) {
        if (divisorObj is FixedDecimal) {
          return divisorObj._minimumValue;
        } else {
          return dividendObj._minimumValue;
        }
      } else {
        if (divisorObj is FixedDecimal) {
          return divisorObj._minimumValue;
        } else {
          return DecimalExtension.minimumValueFromScale(
              min((_mod(dividend, divisor)).scale, 10));
        }
      }
    }

    return _resolveOperation(
        dividendObj,
        divisorObj,
        () => _mod(dividend,
            divisor) /*dividend % divisor (because of bug in Rational modulo*/,
        _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  /// Division operator.
  FixedDecimal operator /(Object other) => division(this, other);

  FixedDecimal divide(Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return division(this, divisorObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal division(Object dividendObj, Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    if (dividend.isNaN || dividend.isInfinite) {
      return FixedDecimal._fromDecimal(dividend);
    }
    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    if (divisor.isNaN || divisor.isInfinite) {
      return FixedDecimal._fromDecimal(divisor);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      if (dividendObj is FixedDecimal) {
        if (divisorObj is FixedDecimal) {
          return dividendObj._minimumValue * divisorObj._minimumValue;
        } else {
          return dividendObj._minimumValue;
        }
      } else {
        if (divisorObj is FixedDecimal) {
          return divisorObj._minimumValue;
        } else {
          return DecimalExtension.minimumValueFromScale(
              min((dividend / divisor).scale, 10));
        }
      }
    }

    return _resolveOperation(
        dividendObj, divisorObj, () => dividend / divisor, _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  /// Truncating division operator.
  ///
  /// The result of the truncating division [:a ~/ b:] is equivalent to
  /// [:(a / b).truncate():].
  FixedDecimal operator ~/(FixedDecimal other) =>
      integerDivision(this, other /*, rounding: _rounding*/);
  /*
  new FixedDecimal._fromDecimal(_decimal ~/ other._decimal,
          minimumValue: _minimumValue, rounding: _rounding); */

  FixedDecimal divideAsInteger(Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    return integerDivision(this, divisorObj,
        minimumValue: minimumValue,
        scale: scale,
        rounding: rounding,
        policy: policy);
  }

  static FixedDecimal integerDivision(Object dividendObj, Object divisorObj,
      {Decimal? minimumValue,
      int? scale,
      RoundingType? rounding,
      ScalingPolicy? policy}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    if (dividend.isNaN || dividend.isInfinite) {
      return FixedDecimal._fromDecimal(dividend);
    }
    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    if (divisor.isNaN || divisor.isInfinite) {
      return FixedDecimal._fromDecimal(divisor);
    }

    Decimal _defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      return Decimal.one;
    }

    return _resolveOperation(
        dividendObj, divisorObj, () => dividend ~/ divisor, _defineMinimumValue,
        minimumValue: minimumValue,
        policy: policy,
        scale: scale,
        rounding: rounding);
  }

  /// Negate operator. */
  FixedDecimal operator -() => FixedDecimal._fromDecimal(-_decimal,
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Return the remainder from dividing this [num] by [other]. */
  FixedDecimal remainder(FixedDecimal other) =>
      FixedDecimal._fromDecimal(_decimal.remainder(other._decimal),
          minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Relational less than operator. */
  bool operator <(FixedDecimal other) => _decimal < other._decimal;

  /// Relational less than or equal operator. */
  bool operator <=(FixedDecimal other) => _decimal <= other._decimal;

  /// Relational greater than operator. */
  bool operator >(FixedDecimal other) => _decimal > other._decimal;

  /// Relational greater than or equal operator. */
  bool operator >=(FixedDecimal other) => _decimal >= other._decimal;

  bool get isNaN => _decimal.isNaN;

  bool get isNegative => _decimal.isNegative;

  bool get isInfinite => _decimal.isInfinite;

  /// Returns the absolute value of this [num]. */
  FixedDecimal abs() => FixedDecimal._fromDecimal(_decimal.abs(),
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// The signum function value of this [num].
  ///
  /// E.e. -1, 0 or 1 as the value of this [num] is negative, zero or positive.
  int get signum => _decimal.signum;

  /// Returns the greatest integer value no greater than this [num]. */
  FixedDecimal floor() => FixedDecimal._fromDecimal(_decimal.floor(),
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Returns the least integer value that is no smaller than this [num]. */
  FixedDecimal ceil() => FixedDecimal._fromDecimal(_decimal.ceil(),
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Returns the integer value closest to this [num].
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  FixedDecimal round() => FixedDecimal._fromDecimal(_decimal.round(),
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Round away from Zero;
  ///
  FixedDecimal roundAwayFromZero() =>
      FixedDecimal._fromDecimal(_decimal.roundAwayFromZero(),
          minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Returns the integer value obtained by discarding any fractional
  /// digits from this [num].
  FixedDecimal truncate() => FixedDecimal._fromDecimal(_decimal.truncate(),
      minimumValue: _minimumValue, rounding: _rounding, policy: _policy);

  /// Returns the integer value closest to `this`.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  ///
  /// The result is a double.
  double roundToDouble() => _decimal.roundToDouble();

  /// Returns the greatest integer value no greater than `this`.
  ///
  /// The result is a double.
  double floorToDouble() => _decimal.floorToDouble();

  /// Returns the least integer value no smaller than `this`.
  ///
  /// The result is a double.
  double ceilToDouble() => _decimal.ceilToDouble();

  /// Returns the integer obtained by discarding any fractional
  /// digits from `this`.
  ///
  /// The result is a double.
  double truncateToDouble() => _decimal.truncateToDouble();

  /// Clamps this to be in the range [lowerLimit]-[upperLimit]. The comparison
  /// is done using [compareTo] and therefore takes [:-0.0:] into account.
  FixedDecimal clamp(FixedDecimal lowerLimit, FixedDecimal upperLimit) =>
      FixedDecimal._fromDecimal(
          _decimal.clamp(lowerLimit._decimal, upperLimit._decimal),
          minimumValue: _minimumValue,
          rounding: _rounding,
          policy: _policy);

  /// Truncates this [num] to an integer and returns the result as an [int].
  int toInt() => _decimal.toInt();

  /// Return this [num] as a [double].
  ///
  /// If the number is not representable as a [double], an
  /// approximation is returned. For numerically large integers, the
  /// approximation may be infinite.
  double toDouble() => _decimal.toDouble();

  /// Inspect if this [num] has a finite precision.
  bool get hasFinitePrecision => _decimal.hasFinitePrecision;

  /// The precision of this [num].
  ///
  /// The sum of the number of digits before and after
  /// the decimal point.
  ///
  /// Throws [StateError] if the precision is infinite,
  /// i.e. when [hasFinitePrecision] is false.
  int get precision => _decimal.precision;

  /// The scale of this [num].
  ///
  /// The number of digits after the decimal point.
  ///
  /// Throws [StateError] if the scale is infinite,
  /// i.e. when [hasFinitePrecision] is false.
  int get scale => _decimal.scale;

  /// Converts a [num] to a string representation with [fractionDigits]
  /// digits after the decimal point.
  String toStringAsFixed(int fractionDigits) =>
      _decimal.toStringAsFixed(fractionDigits);

  /// Converts a [num] to a string in decimal exponential notation with
  /// [fractionDigits] digits after the decimal point.
  String toStringAsExponential([int? fractionDigits]) =>
      _decimal.toStringAsExponential(fractionDigits);

  /// Converts a [num] to a string representation with [precision]
  /// significant digits.
  String toStringAsPrecision(int precision) =>
      _decimal.toStringAsPrecision(precision);

  String formattedString(String pattern, {String? userLocale}) {
    userLocale ??= _userLocale;
    final nf = NumberFormat(pattern, userLocale);
    return nf.format(_decimal.toDouble());
  }

  Decimal parseFormattedString(String value, String pattern,
      {String? userLocale}) {
    userLocale ??= _userLocale;
    final nf = NumberFormat(pattern, userLocale);
    return Decimal.parse(nf.parse(value).toString());
  }

  String formattedCurrency(
      {String? userLocale,
      String? symbol,
      int? decimalDigits,
      bool? turnOffGrouping}) {
    turnOffGrouping ??= false;
    userLocale ??= _userLocale;
    decimalDigits ??= _decimal.scale;
    final currency = NumberFormat.currency(
        locale: userLocale, symbol: symbol, decimalDigits: decimalDigits);
    if (turnOffGrouping) {
      currency.turnOffGrouping();
    }
    return currency.format(_decimal.toDouble());
  }

  Decimal parseFormattedCurrency(String value,
      {String? userLocale, String? symbol}) {
    userLocale ??= _userLocale;
    final currency = NumberFormat.currency(locale: userLocale, symbol: symbol);
    if (value.endsWith(currency.currencySymbol)) {
      value = value.replaceFirst(currency.currencySymbol, '');
    }
    return Decimal.parse(currency.parse(value).toString());
  }
}
