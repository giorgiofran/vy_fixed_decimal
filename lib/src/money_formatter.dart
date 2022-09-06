/// Copyright © 2020 Giorgio Franceschetti. All rights reserved.

import 'package:intl/intl.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

class MoneyFormatter {
  static const String _patternCurrencySign = '\u00A4';

  String _negativePrefix = '-';
  String _positivePrefix = '';
  String _negativeSuffix = '';
  String _positiveSuffix = '';
  final String _nbsp = String.fromCharCode(0xa0);

  final String _userLocale;
  final String _countryLocale;
  late final NumberFormat _nfUser;
  late final NumberFormat _nfCountry;
  late final String decimalSeparator;
  late final String groupsSeparator;
  late bool isPrefixCurrency;
  late bool currencyHasSpace;

  // used to strip non digits.
  static RegExp notDigits = RegExp('[^0-9]');

  //static final RegExp _onlyDigits = RegExp('[0-9]');

  MoneyFormatter(String countryLocale, {String? userLocale})
      : _countryLocale = countryLocale,
        _userLocale = userLocale ?? countryLocale {
    _nfUser = NumberFormat.currency(locale: _userLocale);
    _nfCountry = NumberFormat.currency(locale: _countryLocale);
    decimalSeparator = _findDecimalSeparator();
    groupsSeparator = _findGroupsSeparator();
    _scanPattern();
  }

  String get countryLocale => _countryLocale;

  void _scanPattern() {
    var pattern = _nfCountry.symbols.CURRENCY_PATTERN;
    if (pattern.startsWith('$_patternCurrencySign$_nbsp')) {
      isPrefixCurrency = true;
      currencyHasSpace = true;
      pattern = pattern.substring(2);
    } else if (pattern.startsWith(_patternCurrencySign)) {
      isPrefixCurrency = true;
      currencyHasSpace = false;
      pattern = pattern.substring(1);
    } else if (pattern.endsWith('$_nbsp$_patternCurrencySign')) {
      isPrefixCurrency = false;
      currencyHasSpace = true;
      pattern = pattern.substring(0, pattern.length - 2);
    } else if (pattern.endsWith(_patternCurrencySign)) {
      isPrefixCurrency = false;
      currencyHasSpace = false;
      pattern = pattern.substring(0, pattern.length - 1);
    }
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

  String formatMoney(Money money,
      {bool? showGroups,
      bool? implicitSymbol,
      bool? compactCurrencySymbol,
      String? currencySymbol,
      String? decimalSep,
      String? groupSep,
      bool? optimizedFraction,
      bool? isAccounting}) {
    String ret;
    implicitSymbol ??= false;
    compactCurrencySymbol ??= true;
    showGroups ??= true;
    optimizedFraction ??= true;
    isAccounting ??= false;

    if (implicitSymbol) {
      currencySymbol = '';
    } else {
      if (compactCurrencySymbol) {
        if (currencySymbol == null && _nfCountry.currencyName != null) {
          currencySymbol =
              _nfCountry.simpleCurrencySymbol(_nfCountry.currencyName!);
        }
        currencySymbol ??= _nfCountry.currencySymbol;
      } else {
        currencySymbol ??= _nfCountry.currencyName;
      }
    }
    if (decimalSep == null && _nfUser.maximumFractionDigits > 0) {
      decimalSep = decimalSeparator;
    } else {
      decimalSep = '';
    }
    if (showGroups && groupSep == null) {
      groupSep = groupsSeparator;
    }

    ret = money.decimal.abs().toStringAsFixed(optimizedFraction
        ? _maxInt(money.scale, _nfUser.minimumFractionDigits)
        : _nfUser.maximumFractionDigits);

    final List parts = ret.split('.');
    ret = showGroups ? _formatIntegerPart(parts[0], groupsSeparator) : parts[0];
    final String fractionalPart = parts.length > 1 ? parts[1] : '';

    String prefixCurrency, suffixCurrency;
    if (implicitSymbol) {
      prefixCurrency = '';
      suffixCurrency = '';
    } else {
      final currencySpace = currencyHasSpace ? ' ' : '';
      prefixCurrency = isPrefixCurrency ? '$currencySymbol$currencySpace' : "";
      suffixCurrency = isPrefixCurrency ? "" : '$currencySpace$currencySymbol';
    }

    if (money.isNegative) {
      if (isAccounting) {
        ret = '($prefixCurrency $ret$decimalSep'
            '$fractionalPart $suffixCurrency)';
      } else {
        ret = '$prefixCurrency$_negativePrefix$ret$decimalSep'
            '$fractionalPart$_negativeSuffix$suffixCurrency';
      }
    } else {
      ret = '$prefixCurrency$_positivePrefix$ret$decimalSep'
          '$fractionalPart$_positiveSuffix$suffixCurrency';
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

  Money parse(String value,
      {String? decimal, String? thousands, RoundingType? rounding}) {
    Money money;

    decimal ??= _nfUser.symbols.DECIMAL_SEP;
    final isNegative =
        value.contains(_nfUser.symbols.MINUS_SIGN) || value.contains('(');
    final List parts = value.split(decimal);
    final wholeNumber = value.replaceAll(notDigits, '');
    int scale;
    if (parts.length > 1) {
      final String fractionalPart = parts[1].replaceAll(notDigits, '');
      scale = fractionalPart.length;
    } else {
      scale = 0;
    }

    try {
      var dec =
          Decimal.parse(wholeNumber).safeDivBy(Decimal.fromInt(10).pow(scale));
      if (isNegative) {
        dec = -dec;
      }
      money = Money.fromDecimal(dec, _countryLocale, rounding: rounding);
    } catch (e) {
      rethrow;
    }

    return money;
  }
}
