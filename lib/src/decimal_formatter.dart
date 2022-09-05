/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:intl/intl.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

class DecimalFormatter {
  String _negativePrefix = '-';
  String _positivePrefix = '';
  String _negativeSuffix = '';
  String _positiveSuffix = '';

  final String userLocale;
  late final NumberFormat _nfUser;
  late final String decimalSeparator;
  late final String groupsSeparator;

  // used to strip non digits.
  static RegExp notDigits = RegExp('[^0-9]');

  DecimalFormatter(this.userLocale) {
    _nfUser = NumberFormat.decimalPattern(userLocale);
    decimalSeparator = _findDecimalSeparator();
    groupsSeparator = _findGroupsSeparator();
    _scanPattern();
  }

  void _scanPattern() {
    final pattern = _nfUser.symbols.DECIMAL_PATTERN;

    if (pattern.startsWith(_nfUser.symbols.PLUS_SIGN)) {
      _positivePrefix = _nfUser.symbols.PLUS_SIGN;
      _positiveSuffix = '';
    } else if (pattern.startsWith(_nfUser.symbols.MINUS_SIGN)) {
      _negativePrefix = _nfUser.symbols.MINUS_SIGN;
      _negativeSuffix = '';
    } else if (pattern.endsWith(_nfUser.symbols.PLUS_SIGN)) {
      _positiveSuffix = _nfUser.symbols.PLUS_SIGN;
      _positivePrefix = '';
    } else if (pattern.endsWith(_nfUser.symbols.MINUS_SIGN)) {
      _negativeSuffix = _nfUser.symbols.MINUS_SIGN;
      _negativePrefix = '';
    }
  }

  String _findDecimalSeparator() => _nfUser.symbols.DECIMAL_SEP;

  String _findGroupsSeparator() => _nfUser.symbols.GROUP_SEP;

  int _maxInt(int first, int second) => first > second ? first : second;

  String formatDecimal(Decimal decimal,
      {bool? showGroups,
      String? decimalSep,
      String? groupSep,
      bool? optimizedFraction,
      bool? isAccounting}) {
    String ret;
    showGroups ??= true;
    optimizedFraction ??= true;
    isAccounting ??= false;

    if (decimalSep == null && _nfUser.maximumFractionDigits > 0) {
      decimalSep = decimalSeparator;
    } else {
      decimalSep = '';
    }
    if (showGroups && groupSep == null) {
      groupSep = groupsSeparator;
    }

    int scale;
    scale = optimizedFraction
        ? _maxInt(decimal.hasFinitePrecision ? decimal.scale : 10,
            _nfUser.minimumFractionDigits)
        : _nfUser.maximumFractionDigits;
    ret = decimal.abs().toStringAsFixed(scale);

    final List parts = ret.split('.');
    ret = showGroups ? _formatIntegerPart(parts[0], groupsSeparator) : parts[0];
    final String fractionalPart = parts.length > 1 ? parts[1] : '';
    if (fractionalPart.isEmpty) {
      decimalSep = '';
    }

    if (decimal.isNegative) {
      if (isAccounting) {
        ret = '($ret$decimalSep$fractionalPart)';
      } else {
        ret = '$_negativePrefix$ret$decimalSep$fractionalPart$_negativeSuffix';
      }
    } else {
      ret = '$_positivePrefix$ret$decimalSep$fractionalPart$_positiveSuffix';
    }
    return ret;
  }

  String _formatIntegerPart(String toBeFormatted, String separator) {
    var ret = '';

    if (toBeFormatted.startsWith('-')) {
      ret = '-';
      toBeFormatted = toBeFormatted.replaceFirst('-', '');
    }
    final length = toBeFormatted.length.remainder(3);
    if (length > 0) {
      ret += toBeFormatted.substring(0, length);
      toBeFormatted = toBeFormatted.substring(length, toBeFormatted.length);
    } else if (toBeFormatted.isNotEmpty) {
      ret += toBeFormatted.substring(0, 3);
      toBeFormatted = toBeFormatted.substring(3, toBeFormatted.length);
    }
    while (toBeFormatted.isNotEmpty) {
      ret += separator;
      ret += toBeFormatted.substring(0, 3);
      toBeFormatted = toBeFormatted.substring(3, toBeFormatted.length);
    }

    return ret;
  }

  Decimal parse(String value,
      {String? decimalString, String? thousands, RoundingType? rounding}) {
    Decimal decimal;

    decimalString ??= _nfUser.symbols.DECIMAL_SEP;
    final isNegative =
        value.contains(_nfUser.symbols.MINUS_SIGN) || value.contains('(');
    final List parts = value.split(decimalString);
    final wholeNumber = value.replaceAll(notDigits, '');
    int scale;
    if (parts.length > 1) {
      final String fractionalPart = parts[1].replaceAll(notDigits, '');
      scale = fractionalPart.length;
    } else {
      scale = 0;
    }

    try {
      decimal = (Decimal.parse(wholeNumber) / decimal10.pow(scale))
          .toDecimal(scaleOnInfinitePrecision: scale);
      if (isNegative) {
        decimal = -decimal;
      }
    } catch (e) {
      rethrow;
    }

    return decimal;
  }
}
