import 'package:decimal/decimal.dart';
import 'package:quiver/core.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

class DecimalPoint {
  final Decimal x;
  final Decimal y;

  DecimalPoint(Object x, Object y)
      : x = DecimalExtension.decimalFromObject(x),
        y = DecimalExtension.decimalFromObject(y);

  @override
  bool operator ==(Object other) =>
      other is DecimalPoint && x == other.x && y == other.y;

  @override
  int get hashCode => hash2(x.hashCode, y.hashCode);

  @override
  String toString() =>
      'DecimalPoint: x ${x.toStringAsFixed(5)}, y ${y.toStringAsFixed(5)}';
}
