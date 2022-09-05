import 'package:test/test.dart';
import 'package:vy_fixed_decimal/vy_fixed_decimal.dart';

void main() {
  group('Scaling policy Adjust', () {
    var adjust = FixedDecimal.parse('1.578');
    var adjust2 = FixedDecimal.parse('1.378', scale: 2);
    var adjust2Truncate =
        FixedDecimal.parse('1.38', rounding: RoundingType.truncate);

    test('Creation', () {
      // The following are the defaults
      expect(adjust.policy, ScalingPolicy.adjust);
      // The minimum value is inferred by the value received
      expect(adjust.minimumValue, Decimal.parse('0.001'));
      expect(adjust.rounding, RoundingType.halfToEven);
      expect(adjust.decimal, Decimal.parse('1.578'));

      // The minimum value is taken from the parameter
      expect(adjust2.minimumValue, Decimal.parse('0.01'));
      // the value have benn rounded with scale 2
      expect(adjust2.decimal, Decimal.parse('1.38'));
    });

    test('Add - operator', () {
      var result = adjust + adjust2;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));

      result = adjust2 + adjust;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));
    });
    test('Add - instance method', () {
      var result = adjust.add(1.38);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));
    });
    test('Add - static method', () {
      var result = FixedDecimal.addition(1.38, adjust);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));
    });
    test('Add - static method - no fixed decimals', () {
      var result = FixedDecimal.addition(1.38, 1.578);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));
    });

    test('Add - operator - different rounding', () {
      var result = adjust + adjust2Truncate;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('2.958'));

      result = adjust2Truncate + adjust;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('2.958'));
    });
    test('Add - instance method - different rounding', () {
      var result = adjust2Truncate.add(1.578);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.01'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('2.95'));
    });
    test('Add - static method - different rounding', () {
      var result = FixedDecimal.addition(1.578, adjust2Truncate);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.01'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('2.95'));
    });

    test('Subtract - operator', () {
      var result = adjust - adjust2;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('0.198'));

      result = adjust2 - adjust;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('-0.198'));
    });
    test('Subtract - instance method', () {
      var result = adjust.subtract(1.38);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('0.198'));
    });
    test('Subtract - static method', () {
      var result = FixedDecimal.subtraction(1.38, adjust);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('-0.198'));
    });
    test('Subtract - static method - no fixed decimals', () {
      var result = FixedDecimal.subtraction(1.38, 1.578);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('-0.198'));
    });

    test('Subtract - operator - different rounding', () {
      var result = adjust - adjust2Truncate;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.halfToEven);
      expect(result.decimal, Decimal.parse('0.198'));

      result = adjust2Truncate - adjust;
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.001'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('-0.198'));
    });
    test('Subtract - instance method - different rounding', () {
      var result = adjust2Truncate.subtract(1.578);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.01'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('-0.19'));
    });
    test('Subtract - static method - different rounding', () {
      var result = FixedDecimal.subtraction(1.578, adjust2Truncate);
      expect(result.policy, ScalingPolicy.adjust);
      expect(result.minimumValue, Decimal.parse('0.01'));
      expect(result.rounding, RoundingType.truncate);
      expect(result.decimal, Decimal.parse('0.19'));
    });
  });
}
