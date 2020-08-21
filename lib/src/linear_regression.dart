import 'package:decimal/decimal.dart';
import 'utils/decimal_point.dart';

/// Calculates a linear regression based on a list of DecimalPoints
class LinearRegression {
  final List<DecimalPoint> points;

  DecimalPoint _meanPoint;
  DecimalPoint get meanPoint => _meanPoint;

  Decimal _a;
  Decimal _b;
  Decimal _coefficient;
  Decimal _deltaX2, _deltaY2, _deltaProduct;

  Decimal get a => _a;
  Decimal get b => _b;
  Decimal get coefficientOfDetermination => _coefficient;
  Decimal get meanDeltaX2 => _deltaX2;
  Decimal get meanDeltaY2 => _deltaY2;
  Decimal get meanDeltaProduct => _deltaProduct;

  LinearRegression(this.points);

  void calculate() {
    calculateMeanPoint();
    calculateDeltaSquares();
    calculateLineCoefficients();
    calculateCoefficientOfDetermination();
  }

  void calculateMeanPoint() {
    var totalX = Decimal.zero;
    var totalY = Decimal.zero;
    for (var point in points) {
      totalX += point.x;
      totalY += point.y;
    }
    final count = Decimal.fromInt(points.length);
    _meanPoint = DecimalPoint(totalX / count, totalY / count);
  }

  void calculateDeltaSquares() {
    var totalX = Decimal.zero;
    var totalY = Decimal.zero;
    var totalProduct = Decimal.zero;
    for (var p in points) {
      totalX += (p.x - _meanPoint.x).pow(2);
      totalY += (p.y - _meanPoint.y).pow(2);
      totalProduct += (p.x - _meanPoint.x) * (p.y - _meanPoint.y);
    }
    final count = Decimal.fromInt(points.length);
    _deltaX2 = totalX / count;
    _deltaY2 = totalY / count;
    _deltaProduct = totalProduct / count;
  }

  void calculateLineCoefficients() {
    _b = _deltaProduct / _deltaX2;
    _a = _meanPoint.y - _meanPoint.x * _b;
  }

  void calculateCoefficientOfDetermination() =>
      _coefficient = _deltaProduct.pow(2) / (_deltaX2 * _deltaY2);
}
