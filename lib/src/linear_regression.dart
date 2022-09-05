import 'package:decimal/decimal.dart';
import 'utils/decimal_point.dart';
import 'dart:math' as math;

/// Calculates a linear regression based on a list of DecimalPoints
class LinearRegression {
  final List<DecimalPoint> points;

  DecimalPoint? _meanPoint;
  DecimalPoint get meanPoint => _meanPoint ??= calculateMeanPoint();

  Decimal? _a;
  Decimal? _b;
  Decimal? _coefficient;
  Decimal? _deltaX2, _deltaY2, _deltaProduct;

  Decimal get a => _a ??= meanPoint.y - meanPoint.x * b;
  Decimal get b => _b ??= (meanDeltaProduct / meanDeltaX2).toDecimal();
  Decimal get coefficientOfDetermination => _coefficient ??=
      (meanDeltaProduct.pow(2) / (meanDeltaX2 * meanDeltaY2)).toDecimal(
          scaleOnInfinitePrecision: math.max<int>(meanDeltaProduct.scale, 10));
  Decimal get meanDeltaX2 {
    if (_deltaX2 == null) {
      _deltaProduct = calculateDeltaProduct();
    }
    return _deltaX2!;
  }

  Decimal get meanDeltaY2 {
    if (_deltaY2 == null) {
      _deltaProduct = calculateDeltaProduct();
    }
    return _deltaY2!;
  }

  Decimal get meanDeltaProduct => _deltaProduct ??= calculateDeltaProduct();

  LinearRegression(this.points);

  /*  void calculate() {
    _meanPoint = calculateMeanPoint();
    _deltaProduct = calculateDeltaProduct();
    calculateLineCoefficients();
    calculateCoefficientOfDetermination();
  } */

  DecimalPoint calculateMeanPoint() {
    var totalX = Decimal.zero;
    var totalY = Decimal.zero;
    for (var point in points) {
      totalX += point.x;
      totalY += point.y;
    }
    final count = Decimal.fromInt(points.length);
    return DecimalPoint(
        (totalX / count).toDecimal(), (totalY / count).toDecimal());
  }

  Decimal calculateDeltaProduct() {
    var totalX = Decimal.zero;
    var totalY = Decimal.zero;
    var totalProduct = Decimal.zero;
    for (var p in points) {
      totalX += (p.x - meanPoint.x).pow(2);
      totalY += (p.y - meanPoint.y).pow(2);
      totalProduct += (p.x - meanPoint.x) * (p.y - meanPoint.y);
    }
    final count = Decimal.fromInt(points.length);
    _deltaX2 = (totalX / count).toDecimal();
    _deltaY2 = (totalY / count).toDecimal();
    return (totalProduct / count).toDecimal();
  }

  /*  void calculateLineCoefficients() {
    _b = meanDeltaProduct / _deltaX2;
    _a = meanPoint.y - meanPoint.x * _b;
  }

  void calculateCoefficientOfDetermination() =>
      _coefficient = meanDeltaProduct.pow(2) / (_deltaX2 * _deltaY2); */
}
