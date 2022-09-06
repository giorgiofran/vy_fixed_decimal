import 'package:decimal/decimal.dart';
import 'package:vy_fixed_decimal/src/extension/decimal_extension.dart';
import 'utils/decimal_point.dart';

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
  Decimal get b => _b ??= meanDeltaProduct.safeDivBy(meanDeltaX2);
  Decimal get coefficientOfDetermination => _coefficient ??=
      meanDeltaProduct.power(2).safeDivBy(meanDeltaX2 * meanDeltaY2);
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
    return DecimalPoint(totalX.safeDivBy(count), totalY.safeDivBy(count));
  }

  Decimal calculateDeltaProduct() {
    var totalX = Decimal.zero;
    var totalY = Decimal.zero;
    var totalProduct = Decimal.zero;
    for (var p in points) {
      totalX += (p.x - meanPoint.x).power(2);
      totalY += (p.y - meanPoint.y).power(2);
      totalProduct += (p.x - meanPoint.x) * (p.y - meanPoint.y);
    }
    final count = Decimal.fromInt(points.length);
    _deltaX2 = totalX.safeDivBy(count);
    _deltaY2 = totalY.safeDivBy(count);
    return totalProduct.safeDivBy(count);
  }
}
