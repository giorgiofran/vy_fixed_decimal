part of fixed_decimal.fixed_decimal;

class Money implements Comparable<Money> {
  late FixedDecimal _fixed;
  late String _countryLocale;

  Decimal get decimal => _fixed.decimal;
  Decimal get minimumValue => _fixed.minimumValue;
  String get userLocale => _fixed.userLocale;
  ScalingPolicy get policy => _fixed.policy;
  RoundingType get rounding => _fixed.rounding;
  String get countryLocale => _countryLocale;

  Money.fromDecimal(Decimal decimal, String countryLocale,
      /* String userLocale, */
      {RoundingType? rounding}) {
    _countryLocale = countryLocale /* ?? userLocale */;

    var minimumValue = DecimalExtension.minimumValueFromScale(
        _getScaleFromPattern(countryLocale));
    _fixed = FixedDecimal.fromDecimal(decimal,
        //userLocale: userLocale,
        minimumValue: minimumValue,
        rounding: rounding ?? RoundingType.halfAwayFromZero,
        policy: ScalingPolicy.thisOrNothing);
    _fixed.userLocale = _countryLocale;
  }

  static Money parse(String value, String countryLocale,
      {RoundingType? rounding, String? userLocale}) {
    final m =
        Money.fromDecimal(Decimal.zero, countryLocale, rounding: rounding);
    return m.parseFormattedCurrency(value,
        userLocale: userLocale ?? countryLocale, countryLocale: countryLocale);
  }

  static Money fromFixedDecimal(FixedDecimal fixedDecimal, String countryLocale,
      {String? userLocale, String? symbol}) {
    if (userLocale != null) {
      fixedDecimal.userLocale = userLocale;
    }
    return Money.fromDecimal(fixedDecimal._decimal, countryLocale,
        rounding: fixedDecimal._rounding);
  }

  static int _getScaleFromPattern(String countryLocale) {
    final currency = NumberFormat.currency(locale: countryLocale);
    return currency.maximumFractionDigits;
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
  Money fractionalPart(
      [FractionalPartCriteria criteria = FractionalPartCriteria.ceil]) {
    return Money.fromDecimal(
        _fixed._fractionalPart(decimal, criteria), userLocale,
        rounding: rounding);
  }

  bool isEven() => _fixed.isEven;

  Money roundToNearestMultiple(
      {Object? minimumValue, int? scale, RoundingType? rounding}) {
    if (scale == null) {
      minimumValue ??= minimumValue;
    }
    rounding ??= rounding;
    return Money.fromDecimal(
        DecimalExtension.roundDecimalToNearestMultiple(decimal,
            minimumValue: minimumValue, scale: scale, rounding: rounding),
        userLocale,
        rounding: rounding);
  }

  bool get isInteger => _fixed.isInteger;

  @override
  bool operator ==(Object other) {
    if (other is Money) {
      return decimal == other.decimal && countryLocale == other.countryLocale;
    } else if (other is FixedDecimal) {
      return decimal == other.decimal;
    } else if (other is Decimal) {
      return decimal == other;
    } else if (other is String) {
      bool ret;
      try {
        ret = decimal == Decimal.parse(other);
      } catch (e) {
        ret = false;
      }
      return ret;
    }
    return false;
  }

  @override
  int get hashCode => decimal.hashCode;

  // implementation of Comparable

  @override
  int compareTo(Money other) => decimal.compareTo(other.decimal);

  Money duplicate() => Money.fromDecimal(decimal, _countryLocale);

  static int _intMin(int first, int second) => first < second ? first : second;

  static Object _fixedDecimalWhenPossible(Object obj) {
    if (obj is Money) {
      return obj._fixed;
    }
    if (obj is Decimal) {
      return FixedDecimal.fromDecimal(
          obj /*, minimumValue: minimumValue,
            rounding: rounding, policy: policy, locale: locale*/
          );
    } else {
      try {
        final dec = DecimalExtension.decimalFromObject(obj);
        return FixedDecimal.fromDecimal(
            dec /*, minimumValue: minimumValue,
            rounding: rounding, policy: policy, locale: locale*/
            );
      } catch (e) {
        // return obj;
      }
    }
    return obj;
  }

  /// Addition operator
  ///
  /// The result is created with decimal precision and rounding type taken
  /// from the first addend. If it is needed to change them use the add method.
  Money operator +(Money other) => addition(this, other, userLocale);

  Money add(Object addendObj, {Decimal? minimumValue, RoundingType? rounding}) {
    return addition(this, addendObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money addition(
      Object augendObj, Object addendObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final augend = DecimalExtension.decimalFromObject(augendObj);

    final addend = DecimalExtension.decimalFromObject(addendObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      Decimal? augendMin, addendMin;
      if (augendObj is Money) {
        augendMin = augendObj.minimumValue;
      } else if (augendObj is FixedDecimal) {
        augendMin = augendObj.minimumValue;
      }
      if (addendObj is Money) {
        addendMin = addendObj.minimumValue;
      } else if (addendObj is FixedDecimal) {
        addendMin = addendObj.minimumValue;
      }

      if (augendMin == null) {
        if (addendMin == null) {
          return DecimalExtension.minimumValueFromScale(
              min<int>((augend + addend).scale, 10));
        }
        return addendMin;
      } else {
        if (addendMin == null) {
          return augendMin;
        } else {
          return augendMin
              .min(addendMin) /*DecimalExtension.min(augendMin, addendMin)*/;
        }
      }
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(augendObj),
            _fixedDecimalWhenPossible(addendObj),
            () => augend + addend,
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  /// Subtraction operator.
  ///
  /// The result is created with decimal precision and rounding type taken
  /// from minuend. If it is needed to change them use the subtract method.
  Money operator -(Money other) => subtraction(this, other, userLocale);

  Money subtract(Object subtrahendObj,
      {Decimal? minimumValue, RoundingType? rounding}) {
    return subtraction(this, subtrahendObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money subtraction(
      Object minuendObj, Object subtrahendObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final minuend = DecimalExtension.decimalFromObject(minuendObj);

    final subtrahend = DecimalExtension.decimalFromObject(subtrahendObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      Decimal? minuendMin, subtrahendMin;
      if (minuendObj is Money) {
        minuendMin = minuendObj.minimumValue;
      } else if (minuendObj is FixedDecimal) {
        {
          minuendMin = minuendObj.minimumValue;
        }
      }
      if (subtrahendObj is Money) {
        subtrahendMin = subtrahendObj.minimumValue;
      } else if (subtrahendObj is FixedDecimal) {
        {
          subtrahendMin = subtrahendObj.minimumValue;
        }
      }

      if (minuendMin == null) {
        if (subtrahendMin == null) {
          return DecimalExtension.minimumValueFromScale(
              _intMin((minuend - subtrahend).scale, 10));
        }
        return subtrahendMin;
      } else {
        if (subtrahendMin == null) {
          return minuendMin;
        } else {
          return minuendMin.min(
              subtrahendMin) /*DecimalExtension.min(minuendMin, subtrahendMin)*/;
        }
      }
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(minuendObj),
            _fixedDecimalWhenPossible(subtrahendObj),
            () => minuend - subtrahend,
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  /// Multiplication operator.
  Money operator *(Money other) => multiplication(this, other, userLocale);

  Money multiply(Object multiplierObj,
      {Decimal? minimumValue, RoundingType? rounding}) {
    return multiplication(this, multiplierObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money multiplication(
      Object multiplicandObj, Object multiplierObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final multiplicand = DecimalExtension.decimalFromObject(multiplicandObj);

    final multiplier = DecimalExtension.decimalFromObject(multiplierObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      Decimal? multiplicandMin, multiplierMin;
      if (multiplicandObj is Money) {
        multiplicandMin = multiplicandObj.minimumValue;
      } else if (multiplicandObj is FixedDecimal) {
        multiplicandMin = multiplicandObj.minimumValue;
      }
      if (multiplierObj is Money) {
        multiplierMin = multiplierObj.minimumValue;
      } else if (multiplierObj is FixedDecimal) {
        {
          multiplierMin = multiplierObj.minimumValue;
        }
      }

      if (multiplicandMin == null) {
        if (multiplierMin == null) {
          return DecimalExtension.minimumValueFromScale(
              _intMin((multiplicand * multiplier).scale, 10));
        }
        return multiplierMin;
      } else {
        if (multiplierMin == null) {
          return multiplicandMin;
        } else {
          return multiplicandMin.min(
              multiplierMin) /*DecimalExtension.min(multiplicandMin, multiplierMin)*/;
        }
      }
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(multiplicandObj),
            _fixedDecimalWhenPossible(multiplierObj),
            () => multiplicand * multiplier,
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  static Decimal _mod(Decimal dividend, Decimal divisor) {
    final remainder = dividend.remainder(divisor);
    if (remainder.isNegative) {
      return divisor.abs() + remainder;
    }
    return remainder;
  }

  /// Euclidean modulo operator.
  Money operator %(Money other) => modulusDivision(this, other, userLocale);

  Money modulo(Object divisorObj,
      {Decimal? minimumValue, RoundingType? rounding}) {
    return modulusDivision(this, divisorObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money modulusDivision(
      Object dividendObj, Object divisorObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      Decimal? dividendMin, divisorMin;
      if (dividendObj is Money) {
        dividendMin = dividendObj.minimumValue;
      } else if (dividendObj is FixedDecimal) {
        dividendMin = dividendObj.minimumValue;
      }
      if (divisorObj is Money) {
        divisorMin = divisorObj.minimumValue;
      } else if (divisorObj is FixedDecimal) {
        divisorMin = divisorObj.minimumValue;
      }

      if (dividendMin == null) {
        if (divisorMin == null) {
          return DecimalExtension.minimumValueFromScale(
              _intMin((_mod(dividend, divisor)).scale, 10));
        }
        return divisorMin;
      } else {
        if (divisorMin == null) {
          return dividendMin;
        } else {
          return dividendMin.min(
              divisorMin) /*DecimalExtension.min(dividendMin, divisorMin)*/;
        }
      }
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(dividendObj),
            _fixedDecimalWhenPossible(divisorObj),
            () => FixedDecimal._mod(dividend, divisor),
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  /// Division operator.
  Money operator /(Money other) => division(this, other, userLocale);

  Money divide(Object divisorObj,
      {Decimal? minimumValue, RoundingType? rounding}) {
    return division(this, divisorObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money division(
      Object dividendObj, Object divisorObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      Decimal? dividendMin, divisorMin;
      if (dividendObj is Money) {
        dividendMin = dividendObj.minimumValue;
      } else if (dividendObj is FixedDecimal) {
        dividendMin = dividendObj.minimumValue;
      }
      if (divisorObj is Money) {
        divisorMin = divisorObj.minimumValue;
      } else if (divisorObj is FixedDecimal) {
        divisorMin = divisorObj.minimumValue;
      }

      if (dividendMin == null) {
        if (divisorMin == null) {
          /*      return DecimalExtension.minimumValueFromScale(
              _intMin((dividend / divisor).toDecimal().scale, 10)); */
          return DecimalExtension.minimumValueFromScale(
              _intMin(dividend.safeDivBy(divisor).scale, 10));
        }
        return divisorMin;
      } else {
        if (divisorMin == null) {
          return dividendMin;
        } else {
          return dividendMin.min(
              divisorMin) /*DecimalExtension.min(dividendMin, divisorMin)*/;
        }
      }
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(dividendObj),
            _fixedDecimalWhenPossible(divisorObj),
            /*    () => (dividend / divisor).toDecimal(scaleOnInfinitePrecision: 10), */
            () => dividend.safeDivBy(divisor),
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  /// Truncating division operator.
  ///
  /// The result of the truncating division [:a ~/ b:] is equivalent to
  /// [:(a / b).truncate():].
  Money operator ~/(Money other) => integerDivision(this, other, userLocale);

  Money divideAsInteger(Object divisorObj,
      {Decimal? minimumValue, RoundingType? rounding}) {
    return integerDivision(this, divisorObj, userLocale,
        minimumValue: minimumValue, rounding: rounding);
  }

  static Money integerDivision(
      Object dividendObj, Object divisorObj, String countryLocale,
      {Decimal? minimumValue, RoundingType? rounding}) {
    final dividend = DecimalExtension.decimalFromObject(dividendObj);

    final divisor = DecimalExtension.decimalFromObject(divisorObj);

    Decimal defineMinimumValue() {
      if (minimumValue != null) {
        return minimumValue;
      }
      return Decimal.one;
    }

    return Money.fromFixedDecimal(
        FixedDecimal.resolveOperation(
            _fixedDecimalWhenPossible(dividendObj),
            _fixedDecimalWhenPossible(divisorObj),
            () => Decimal.fromBigInt(dividend ~/ divisor),
            defineMinimumValue,
            minimumValue: minimumValue,
            rounding: rounding),
        countryLocale);
  }

  /// Negate operator.
  Money operator -() =>
      Money.fromDecimal(-decimal, userLocale, rounding: rounding);

  /// Return the remainder from dividing this [num] by [other].
  Money remainder(Money other) =>
      Money.fromDecimal(decimal.remainder(other.decimal), userLocale,
          rounding: rounding);

  /// Relational less than operator.
  bool operator <(Money other) => decimal < other.decimal;

  /// Relational less than or equal operator.
  bool operator <=(Money other) => decimal <= other.decimal;

  /// Relational greater than operator.
  bool operator >(Money other) => decimal > other.decimal;

  /// Relational greater than or equal operator.
  bool operator >=(Money other) => decimal >= other.decimal;

  bool get isNegative => decimal.isNegative;

  /// Returns the absolute value of this [num].
  Money abs() =>
      Money.fromDecimal(decimal.abs(), userLocale, rounding: rounding);

  /// The signum function value of this [num].
  ///
  /// E.e. -1, 0 or 1 as the value of this [num] is negative, zero or positive.
  int get signum => decimal.signum;

  /// Returns the greatest integer value no greater than this [num].
  Money floor() =>
      Money.fromDecimal(decimal.floor(), userLocale, rounding: rounding);

  /// Returns the least integer value that is no smaller than this [num].
  Money ceil() =>
      Money.fromDecimal(decimal.ceil(), userLocale, rounding: rounding);

  /// Returns the integer value closest to this [num].
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  Money round() =>
      Money.fromDecimal(decimal.round(), userLocale, rounding: rounding);

  /// Round away from Zero;
  ///
  Money roundAwayFromZero() =>
      Money.fromDecimal(decimal.roundAwayFromZero(), userLocale,
          rounding: rounding);

  /// Returns the integer value obtained by discarding any fractional
  /// digits from this [num].
  Money truncate() =>
      Money.fromDecimal(decimal.truncate(), userLocale, rounding: rounding);

  /// Returns the integer value closest to `this`.
  ///
  /// Rounds away from zero when there is no closest integer:
  ///  [:(3.5).round() == 4:] and [:(-3.5).round() == -4:].
  ///
  /// The result is a double.
  double roundToDouble() => decimal.round().toDouble();

  /// Returns the greatest integer value no greater than `this`.
  ///
  /// The result is a double.
  double floorToDouble() => decimal.floor().toDouble();

  /// Returns the least integer value no smaller than `this`.
  ///
  /// The result is a double.
  double ceilToDouble() => decimal.ceil().toDouble();

  /// Returns the integer obtained by discarding any fractional
  /// digits from `this`.
  ///
  /// The result is a double.
  double truncateToDouble() => decimal.truncate().toDouble();

  /// Clamps this to be in the range [lowerLimit]-[upperLimit]. The comparison
  /// is done using [compareTo] and therefore takes [:-0.0:] into account.
  Money clamp(Money lowerLimit, Money upperLimit) => Money.fromDecimal(
      decimal.clamp(lowerLimit.decimal, upperLimit.decimal), userLocale,
      rounding: rounding);

  /// Truncates this [num] to an integer and returns the result as an [int].
  /// If the number does not fit, clamps to the max (or min) integer.
  ///
  /// **Warning:** the clamping behaves differently between the web and
  /// native platforms due to the differences in integer precision.
  ///
  int toInt() => decimal.toBigInt().toInt();

  /// Return this [num] as a [double].
  ///
  /// If the number is not representable as a [double], an
  /// approximation is returned. For numerically large integers, the
  /// approximation may be infinite.
  double toDouble() => decimal.toDouble();

  /// The precision of this [num].
  ///
  /// The sum of the number of digits before and after
  /// the decimal point.
  ///
  /// Throws [StateError] if the precision is infinite,
  /// i.e. when [hasFinitePrecision] is false.
  int get precision => decimal.precision;

  /// The scale of this [num].
  ///
  /// The number of digits after the decimal point.
  ///
  /// Throws [StateError] if the scale is infinite,
  /// i.e. when [hasFinitePrecision] is false.
  int get scale => decimal.scale;

  /// Converts a [num] to a string representation with [fractionDigits]
  /// digits after the decimal point.
  String toStringAsFixed(int fractionDigits) =>
      decimal.toStringAsFixed(fractionDigits);

  /// Converts a [num] to a string in decimal exponential notation with
  /// [fractionDigits] digits after the decimal point.
  String toStringAsExponential([int? fractionDigits]) =>
      decimal.toStringAsExponential(fractionDigits ?? scale);

  /// Converts a [num] to a string representation with [precision]
  /// significant digits.
  String toStringAsPrecision(int precision) =>
      decimal.toStringAsPrecision(precision);

  @override
  String toString() => formattedCurrency(userLocale: userLocale);

  String formattedValue(
      {String? userLocale,
      bool? optimizedFraction,
      bool? turnOffGrouping,
      bool? isAccounting}) {
    userLocale ??= this.userLocale /* ?? _countryLocale */;
    turnOffGrouping ??= false;
    final mf = MoneyFormatter(_countryLocale, userLocale: userLocale);
    return mf.formatMoney(this,
        showGroups: !turnOffGrouping,
        implicitSymbol: true,
        isAccounting: isAccounting,
        optimizedFraction: optimizedFraction);
  }

  String formattedCompactCurrency(
      {String? userLocale,
      String? symbol,
      bool? optimizedFraction,
      bool? turnOffGrouping,
      bool? isAccounting}) {
    userLocale ??= this.userLocale /*  ?? _countryLocale */;
    turnOffGrouping ??= false;
    final mf = MoneyFormatter(_countryLocale, userLocale: userLocale);
    return mf.formatMoney(this,
        showGroups: !turnOffGrouping,
        compactCurrencySymbol: true,
        optimizedFraction: optimizedFraction,
        currencySymbol: symbol,
        isAccounting: isAccounting);
  }

  String formattedCurrency(
      {String? userLocale,
      String? symbol,
      bool? optimizedFraction,
      bool? turnOffGrouping,
      bool? isAccounting}) {
    if (!isValid()) {
      return 'Invalid Money';
    }
    userLocale ??= /*this.userLocale  ??*/ _countryLocale;
    turnOffGrouping ??= false;
    final mf = MoneyFormatter(_countryLocale, userLocale: userLocale);
    return mf.formatMoney(this,
        showGroups: !turnOffGrouping,
        compactCurrencySymbol: false,
        optimizedFraction: optimizedFraction,
        currencySymbol: symbol,
        isAccounting: isAccounting);
  }

  Money parseFormattedCurrency(String value,
      {String? userLocale, String? countryLocale}) {
    userLocale ??= this.userLocale /* ?? _countryLocale */;
    countryLocale ??= _countryLocale;
    final mf = MoneyFormatter(countryLocale, userLocale: userLocale);
    return mf.parse(value, rounding: rounding);
  }

  bool isValid() => true /* decimal != null && _countryLocale != null */;
}
